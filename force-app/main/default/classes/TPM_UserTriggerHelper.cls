/*******************************************************************************************************
* @Name         : TPM_UserTriggerHelper
* @Unit Test    : TPM_UserTriggerTest
* @Author       : PwC Team
* @Date         : 12/09/2022
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the user records.
*******************************************************************************************************/

public inherited sharing class TPM_UserTriggerHelper {

    /****************************************************************************************************
    @methodname 	TPM_UserTriggerHelper
    @createdDate 	12/09/2022
    @description	default private constructor
    *****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_UserTriggerHelper(){

    }
    
    /*********************************************************************************************************
    @methodname   	createUserSetting
    @createdDate  	12/09/2022
    @param     	  	newMap
    @description  	after the insert of a user record, user setting record is created for the user. 
    *********************************************************************************************************/
    public static void createUserSetting(Map<Id,Sobject> newMap){
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        List<cgcloud__User_Setting__c> userSettingsToCreate = new List<cgcloud__User_Setting__c>();
        List<TPM_Promo_KPI_Subsets__mdt> kpiSubSetList = [SELECT  Id,
                                                                  TPM_Subset__c,
                                                                  QualifiedApiName 
                                                          FROM    TPM_Promo_KPI_Subsets__mdt 
                                                          WHERE   QualifiedApiName =: TPM_ConstantsUtility.KPI_PROMO_SUBSET_CMDT_LABEL];
       
        
        //Iterate over the user map values
        //cgcloud__KPI_Subsets__c added as part of Story No:892 New User Provisioning
        //Check if kpiSubSetList is not Empty then assign KPI/Promo Subsets
        //AND TPM_Subset__c is not empty
        for(User userObj : (List<User>)newMap.values()){
            cgcloud__User_Setting__c userSetObj = new cgcloud__User_Setting__c();
            userSetObj.cgcloud__User__c = userObj.Id;
            userSetObj.cgcloud__Default_Management_Type__c = TPM_ConstantsUtility.MANAGEMENT_TYPE;
            if(!kpiSubSetList.isEmpty() && String.isNotEmpty(String.valueOf(kpiSubSetList[0].TPM_Subset__c))){
                userSetObj.cgcloud__KPI_Subsets__c = (String.valueOf(kpiSubSetList[0].TPM_Subset__c));
            }
            userSettingsToCreate.add(userSetObj);
        }
        
        //Check if the list is not empty and create the user settings record 
        if(!userSettingsToCreate.isempty()){

            exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleInsertOperation(userSettingsToCreate));


            //Call the TPM_LoggerException class log method to save all the exception details during insert
            if(!exceptionWrapperList.isEmpty()){
                TPM_LoggerException.log(exceptionWrapperList);
            }
            
        }
    }
    
    /*************************************************************************************************** 
    @methodname 	 assignUserToGroup
    @createdDate 	 12/09/2022
    @param           userIdList
    @description	 after the insert of a user record, if the user is active, user is assigned 
                     to the permission set group on the basis of its persona. 
    *****************************************************************************************************/
    @future
    public static void assignUserToGroup(List<Id> userIdList){
        
            Map<String,List<String>> personaToGroupMap = TPM_Utils.fetchPersonaToGroupMap();
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
            List<PermissionSetAssignment> assignmentList = new List<PermissionSetAssignment>();

            //Iterate over all the active user records
            for(User userobj :  [SELECT id,
                                TPM_Persona__c,
                                IsActive 
                                FROM user
                                WHERE id IN : userIdList]){
                                    
                                    //Check the persona to assign corresponding permission set
                                    if(personaToGroupMap.containsKey(userobj.TPM_Persona__c)){
                                        for(String groupId : personaToGroupMap.get(userobj.TPM_Persona__c)) {
                                            PermissionSetAssignment assignmentObj = new PermissionSetAssignment(
                                                PermissionSetGroupId = groupId,
                                                AssigneeId = userobj.Id);
                                            assignmentList.add(assignmentObj);  
                                        }
                                    }
                            }

            //Check if the list is not empty before creating                   
            if(!assignmentList.isempty()){

                exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleInsertOperation(assignmentList));
                
                //Invoke the log method of TPM_LoggerException to log exceptions
                if(!exceptionWrapperList.isEmpty()){
                    TPM_LoggerException.log(exceptionWrapperList);
                }
                
            }
        
    }
    
    
    /*********************************************************************************************************** 
    @methodname 	reassignPermissionGroup
    @createdDate 	12/14/2022
    @param          userMap
    @param          oldUserRecMap
    @description	If user's active and/or persona field is updated, permission assignments are being checked 
                    and reassigned again based on user's persona 
    *************************************************************************************************************/
    public static void reassignPermissionGroup(Map<Id,SObject> userMap, Map<Id,SObject> oldUserRecMap){ 
        
        List<Id> userIdList = new List<Id>();
        Set<Id> assigneeIdSet = new Set<Id>(); 
        Set<Id> groupIdSet = new Set<Id>(); 
        
        Map<String,List<Id>> personaToGroupMap = TPM_Utils.fetchPersonaToGroupMap();

        //Iterate over the list of user records
        for(User userObj : (List<User>)userMap.values()){

           User oldUserRec = (User)oldUserRecMap.get(userObj.id); 
           Boolean isValidUser =  TPM_UserTriggerHelperExtension.checkCondition(userobj.IsActive,userObj.TPM_Persona__c,oldUserRec.TPM_Persona__c,oldUserRec.IsActive);
           
           //If its a valid user record
           if(isValidUser){
                userIdList.add(userObj.Id);  
           }

            //checking if persona is changed, then removing the previous person assignment
            if(userObj.TPM_Persona__c != oldUserRec.TPM_Persona__c){

                assigneeIdSet.add(userObj.id);
                
                if(personaToGroupMap.containskey(oldUserRec.TPM_Persona__c)){
                    groupIdSet.addAll(personaToGroupMap.get(oldUserRec.TPM_Persona__c));
                } 
            }
            
            //checking if the user has been activated, while no change has been done to persona.
            else if( (!userobj.IsActive) && (userObj.TPM_Persona__c == oldUserRec.TPM_Persona__c) && (userobj.IsActive != oldUserRec.IsActive) ){

                    //if user is deactivate , then previous assignment needs to be removed.
                        assigneeIdSet.add(userObj.id); 
                    
                    if( personaToGroupMap.containskey(oldUserRec.TPM_Persona__c)){
                        groupIdSet.addAll(personaToGroupMap.get(oldUserRec.TPM_Persona__c));
                    }
            }
        }
        TPM_UserTriggerHelperExtension.invokeFutureMethods(userIdList,assigneeIdSet,groupIdSet);
    }

    
	/*********************************************************************************************************
    @methodname   	createSalesOrgRecords
    @createdDate  	18/03/2023
    @param     	  	newUserIdList
	@description  	after the insert of a user record, sales org records needs to created
    *********************************************************************************************************/
    @future
    public static void createSalesOrgRecords(List<Id> newUserIdList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        List<cgcloud__Sales_Organization_User__c> salesOrgUserListToCreate = new List<cgcloud__Sales_Organization_User__c>();
        Set<String> salesOrgSet = new Set<String>();
        
        for(User userObj : [SELECT
                               Id,
                              Name,
                              TPM_Sales_Org__c
                              FROM User
                               WHERE Id IN: newUserIdList]){
                                   
                                   if(userObj.TPM_Sales_Org__c != null){
                                       salesOrgSet.addAll(userObj.TPM_Sales_Org__c.split(';'));  
                                   }                    
         }
        
        
        
        Map<String,Id> salesOrgMap = TPM_UserTriggerHelperExtension.createSalesOrgMap(salesOrgSet);
        
        for(User userObj : [SELECT
                               Id,
                              Name,
                              TPM_Sales_Org__c
                              FROM User
                               WHERE Id IN: newUserIdList]){
            if(userObj.TPM_Sales_Org__c != null){
                List<String> selectedSalesOrg = new List<String>();
                selectedSalesOrg.addAll(userObj.TPM_Sales_Org__c.split(';'));
                for(String salesOrgObj : selectedSalesOrg){
                    cgcloud__Sales_Organization_User__c salesOrgUserObj = new cgcloud__Sales_Organization_User__c(cgcloud__Sales_Organization__c = salesOrgMap.get(salesOrgObj),
                                                                                                                  cgcloud__User__c = userObj.Id);
                    salesOrgUserListToCreate.add(salesOrgUserObj);
                }
            }
        }
        
        //Check if the list is not empty and create the sales org user record 
        if(!salesOrgUserListToCreate.isempty()){
            
            exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleInsertOperation(salesOrgUserListToCreate));
                
                //Call the TPM_LoggerException class log method to save all the exception details during insert
             if(!exceptionWrapperList.isEmpty()){
                    TPM_LoggerException.log(exceptionWrapperList);
             }
            
        }
        
    }
    
    /*********************************************************************************************************
    @methodname   	updateSalesOrgRecords
    @createdDate  	18/03/2023
    @param     	  	newUserIdList
	@param     	  	oldMapSalesOrg
	@description  	after the update of sales organization field of a user record, sales org records needs to deleted/updated
    *********************************************************************************************************/
    @future
    public static void updateSalesOrgRecords(List<Id> newUserIdList, Map<Id,String> oldMapSalesOrg){
        
        Set<String> salesOrgSet = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        List<cgcloud__Sales_Organization_User__c> salesOrgUserListToCreate = new List<cgcloud__Sales_Organization_User__c>();
        List<Id> salesOrgUserListToDelete = new List<Id>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
		for(User userObj : [SELECT
                            Id,
                           NAME,
                           TPM_Sales_Org__c
                           FROM User
                           WHERE Id IN:newUserIdList]){
            if(userObj.TPM_Sales_Org__c != null){
                salesOrgSet.addAll(userObj.TPM_Sales_Org__c.split(';'));
                salesOrgSet.addAll(oldMapSalesOrg.get(userObj.Id).split(';'));
            }
            userIdSet.add(userObj.Id);
        }
        
        for(User userObj : [SELECT
                            Id,
                           NAME,
                           TPM_Sales_Org__c
                           FROM User
                           WHERE Id IN:newUserIdList]){
                               
                               
            if(userObj.TPM_Sales_Org__c != oldMapSalesOrg.get(userObj.Id)){
                
                salesOrgUserListToCreate.addAll(TPM_UserTriggerHelperExtension.prepareSalesOrgUserRecToCreate(userIdSet, userObj, salesOrgSet));
                
                salesOrgUserListToDelete.addAll(TPM_UserTriggerHelperExtension.prepareSalesOrgUserRecToDelete(salesOrgSet, userIdSet, userObj, oldMapSalesOrg));
               
            }
        }
        
         //Check if the list is not empty and create the sales org user record 
        if(!salesOrgUserListToCreate.isEmpty()){
            
            exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleInsertOperation(salesOrgUserListToCreate));
        }
                
        //Check if user record list is not empty 
        if(!salesOrgUserListToDelete.isempty()){
            
            exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleDeleteOperation(salesOrgUserListToDelete));
        }
        
        //Call the TPM_LoggerException class log method to save all the exception details during insert
        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }
        
        
    }
    
}