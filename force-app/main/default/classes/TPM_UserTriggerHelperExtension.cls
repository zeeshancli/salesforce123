/*******************************************************************************************************
* @Name         : TPM_UserTriggerHelper
* @Unit Test    : TPM_UserTriggerTest
* @Author       : PwC Team
* @Date         : 12/09/2022
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the user records.
*******************************************************************************************************/

public inherited sharing class TPM_UserTriggerHelperExtension {

    /****************************************************************************************************
    @methodname 	TPM_UserTriggerHelper
    @createdDate 	12/09/2022
    @description	default private constructor
    *****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_UserTriggerHelperExtension(){

    }
    
    /*********************************************************************************************************
    @methodname   	handleInsertOperation
    @createdDate  	03/19/2023
    @param     	  	insertList
	@return			
    @description  	handle DML insert Operation for sObject 
    *********************************************************************************************************/
    public static List<TPM_LoggerException.LogsWrapper> handleInsertOperation(List<Sobject> insertList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        Database.SaveResult[] saveResultList = database.insert(insertList,false);
        Integer index = 0;
        
        for (Database.SaveResult saveResultListObj : saveResultList) {
            if(!saveResultListObj.isSuccess()){
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.errors = saveResultListObj.getErrors();
                logWrapperObj.className=TPM_ConstantsUtility.USER_TRIGGER_HELPER_EXTENSION;
                logWrapperObj.methodName=TPM_ConstantsUtility.HANDLE_INSERT_USER;
                logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                logWrapperObj.guid = insertList[index].Id;
                exceptionWrapperList.add(logWrapperObj);
            }
            index++;
        }        
       
        return exceptionWrapperList;
    }
    
        /*********************************************************************************************************
    @methodname   	handleDeleteOperation
    @createdDate  	03/19/2023
    @param     	  	deleteList
	@return			List<TPM_LoggerException.LogsWrapper>
    @description  	handle DML insert Operation for sObject 
    *********************************************************************************************************/
    public static List<TPM_LoggerException.LogsWrapper> handleDeleteOperation(List<Id> deleteList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        Database.DeleteResult[] deleteResultList = database.delete(deleteList,false);
        
        for (Database.DeleteResult deleteResultObj : deleteResultList) {
            if(!deleteResultObj.isSuccess()){
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.errors = deleteResultObj.getErrors();
                logWrapperObj.className=TPM_ConstantsUtility.USER_TRIGGER_HELPER;
                logWrapperObj.methodName=TPM_ConstantsUtility.HANDLE_DELETE_USER;
                logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                exceptionWrapperList.add(logWrapperObj);
            }
        }
        
        return exceptionWrapperList;
    }
    
    
   /*********************************************************************************************************
    @methodname   	createSalesOrgMap
    @createdDate  	03/19/2023
    @param     	  	salesOrgSet
	@return			Map<String,Id>
    @description  	retrieve sales organization detail
    *********************************************************************************************************/
    public static Map<String,Id> createSalesOrgMap(Set<String> salesOrgSet){
        
       	Map<String, Id> salesOrgMap = new Map<String, Id>();
        for(cgcloud__Sales_Organization__c salesOrgRec : [SELECT 
                                                          Id,
                                                          Name
                                                          FROM
                                                          cgcloud__Sales_Organization__c
                                                          WHERE
                                                          Name IN :salesOrgSet]){
                                                              
           salesOrgMap.put(salesOrgRec.Name,salesOrgRec.Id);                                                
       }
        
       return salesOrgMap;
        
    }
   
    
   /*********************************************************************************************************
    @methodname   	createSalesOrgUserMap
    @createdDate  	03/19/2023
    @param     	  	salesOrgSet
    @param     	  	userIdSet
	@return			Map<String,Id>
    @description  	retrieve sales organization user detail
    *********************************************************************************************************/
    public static Map<String,Id> createSalesOrgUserMap(Set<String> salesOrgSet, Set<Id> userIdSet){
        
        Map<String,Id> salesOrgUserMap = new Map<String,Id>();
        for(cgcloud__Sales_Organization_User__c salesOrgRec : [SELECT 
                                                               Id,
                                                               cgcloud__Sales_Organization__c,
                                                               cgcloud__Sales_Organization__R.Name,
                                                               cgcloud__User__c
                                                               FROM
                                                               cgcloud__Sales_Organization_User__c
                                                               WHERE
                                                               cgcloud__Sales_Organization__R.Name IN :salesOrgSet
                                                               AND cgcloud__User__c IN: userIdSet]){
                                                                   
              salesOrgUserMap.put(salesOrgRec.cgcloud__Sales_Organization__R.Name + salesOrgRec.cgcloud__User__c, salesOrgRec.Id);                                                     
                                                                   
       }
        
       return salesOrgUserMap;
        
    }
    
    
    /*********************************************************************************************************
    @methodname   	prepareSalesOrgUserRecToCreate
    @createdDate  	03/19/2023
    @param     	  	userIdSet
    @param     	  	userObj
    @param     	  	salesOrgSet
    @return			List<cgcloud__Sales_Organization_User__c>
    @description  	prepare salesOrg user to detail when sales organization field is updated
    *********************************************************************************************************/
    public static List<cgcloud__Sales_Organization_User__c> prepareSalesOrgUserRecToCreate(Set<Id> userIdSet, 
                                                                                   User userObj, Set<String> salesOrgSet){
        
                                                                                       
        List<cgcloud__Sales_Organization_User__c> salesOrgUserListToCreate = new List<cgcloud__Sales_Organization_User__c>();
        
		Map<String,Id> salesOrgMap = createSalesOrgMap(salesOrgSet);
        Map<String,Id> salesOrgUserMap = createSalesOrgUserMap(salesOrgSet, userIdSet);
                                          
        List<String> selectedSalesOrg = new List<String>();
        if(userObj.TPM_Sales_Org__c != null){
            selectedSalesOrg.addAll(userObj.TPM_Sales_Org__c.split(';'));                                                                                 
        }                                                                              
                                                                                    
        for(String salesOrgObj : selectedSalesOrg){
            
            if(!salesOrgUserMap.containskey(salesOrgObj + userObj.Id)){
                
                cgcloud__Sales_Organization_User__c salesOrgUserObj = new cgcloud__Sales_Organization_User__c(cgcloud__Sales_Organization__c = salesOrgMap.get(salesOrgObj),
                                                                                                              cgcloud__User__c = userObj.Id);
                salesOrgUserListToCreate.add(salesOrgUserObj);
            }
        }
        
        return salesOrgUserListToCreate;
        
       
    }
    
    /*********************************************************************************************************
    @methodname   	prepareSalesOrgUserRecToDelete
    @createdDate  	03/19/2023
    @param     	  	salesOrgSet
    @param     	  	userIdSet
    @param     	  	userObj
    @param     	  	oldMapSalesOrg
    @return			List<Id>
    @description  	prepare salesOrg user to detail when sales organization field is deleted
    *********************************************************************************************************/
    public static List<Id> prepareSalesOrgUserRecToDelete(Set<String> salesOrgSet,Set<Id> userIdSet, User userObj, Map<Id, String> oldMapSalesOrg){
        
        List<Id> salesOrgUserListToDelete = new List<Id>();
                                                                                           
       	List<String> selectedSalesOrg = new List<String>();
        if(userObj.TPM_Sales_Org__c != null){
        selectedSalesOrg.addAll(userObj.TPM_Sales_Org__c.split(';'));
        }
                 
        List<String> removedSalesOrg = new List<String>();
        removedSalesOrg.addAll(oldMapSalesOrg.get(userObj.Id).split(';'));
             salesOrgSet.addAll(oldMapSalesOrg.get(userObj.Id).split(';'));   
        
        
        Map<String,Id> salesOrgUserMap = createSalesOrgUserMap(salesOrgSet, userIdSet);
         
        for(String salesOrgObj : removedSalesOrg){
            
            if(!selectedSalesOrg.contains(salesOrgObj)){
                
                if(salesOrgUserMap.containskey(salesOrgObj + userObj.Id)){
                    
                    salesOrgUserListToDelete.add(salesOrgUserMap.get(salesOrgObj + userObj.Id));
                }
            }
        }
        
        return  salesOrgUserListToDelete;                                                                                    
        
    }
    
        /*********************************************************************************************************** 
    @methodname 	checkCondition
    @createdDate 	12/14/2022
    @return         boolean
    @param          currentIsActive
    @param          currentTPMPersona
    @param          oldTPMPersona
    @param          oldIsActive
    @description	Used to check condition for the reassignPermissionGroup
    *************************************************************************************************************/
    public static boolean checkCondition(boolean currentIsActive,String currentTPMPersona,String oldTPMPersona,boolean oldIsActive){

        Boolean isCondition = false;
        //Check if the valid condition is met for reassignPermissionGroup
        if( (currentIsActive) && ( (currentTPMPersona != oldTPMPersona) || ( (currentTPMPersona == oldTPMPersona) && (currentIsActive != oldIsActive) ) ) ){
            isCondition = true;
        }
        return isCondition;
    }
    
     /*********************************************************************************************************** 
    @methodname 	invokeFutureMethods
    @createdDate 	12/14/2022
    @param          userIdList
    @param          assigneeIdSet
    @param          groupIdSet
    @description	Used to invoke assignUserToGroup & removeAssignmentsForUser methods
    *************************************************************************************************************/
    public static void invokeFutureMethods(List<Id> userIdList,Set<Id> assigneeIdSet,Set<Id> groupIdSet){

        //Check and Invoke assignUserToGroup to add the Permission Set Group to the user record.
        if(!userIdList.isempty()){
            TPM_UserTriggerHelper.assignUserToGroup(userIdList);
        }

        //Check and Invoke removeAssignmentsForUser to remove the Permission Set Group from the user record.
        if((!assigneeIdSet.isempty() && !groupIdSet.isempty())){
            removeAssignmentsForUser(assigneeIdSet,groupIdSet);
        }
    }
    
    /********************************************************************************************* 
    @methodname 	removeAssignmentsForUser
    @createdDate 	12/14/2022
    @param          userIdSet
    @param          groupIdSet
    @description	Removing the permission assignments for user. 
    ************************************************************************************************/  
    @future
    public static void removeAssignmentsForUser(Set<Id> userIdSet,Set<Id> groupIdSet){
        
            List<Id> assignmentListToDel  = new List<Id>();
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();

            //Iterate over the list of user records to remove assignment
            for(PermissionSetAssignment assignmentObj : [SELECT 
                                                        Id,
                                                        PermissionSetId
                                                        FROM PermissionSetAssignment 
                                                        WHERE Assignee.Id IN : userIdSet 
                                                        AND PermissionSetGroupId IN : groupIdSet]){
                assignmentListToDel.add(assignmentObj.Id);                                    
            }

            //Check if user record list is not empty 
            if(!assignmentListToDel.isempty()){

                exceptionWrapperList.addAll(handleDeleteOperation(assignmentListToDel));
                //Invoke the log method of TPM_LoggerException to log exceptions
                if(!exceptionWrapperList.isEmpty()){
                    TPM_LoggerException.log(exceptionWrapperList);
                }
                
            }    
    }
    
    /*********************************************************************************************************
    @methodname   	checkValidationForDefaultSalesOrg
    @createdDate  	03/21/2023
    @param     	  	userList
	@description  	check validation for default organization.
    *********************************************************************************************************/
    public static void checkValidationForDefaultSalesOrg(List<SObject> userList){
        
        for(User userObj : (List<User>)userList){
           
            if(!userObj.TPM_Sales_Org__c.contains(userObj.TPM_Default_Sales_Organization__c)){
                
                userObj.addError(TPM_ConstantsUtility.DEFAULT_TRIGGER_ERROR_MSG);
            }
        }
    }
    

}