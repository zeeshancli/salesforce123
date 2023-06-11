/*******************************************************************************************************
* @Name         : TPM_UserTriggerHandler
* @unit Test    : DUR_UserTriggerTest
* @author       : PwC Team
* @date         : 12/09/2022
* @description  : Handler class for user trigger.
*******************************************************************************************************/

public inherited sharing class TPM_UserTriggerHandler implements TPM_TriggerInterface {
    
    /******************************************************************************************************** 
    @methodname 	bulkBefore
    @createdDate 	12/09/2022
    @description	processing of bulk records
    *********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkBefore() {      
    }
    
    /******************************************************************************************************** 
    @methodname 	bulkAfter
    @createdDate 	12/09/2022
    @description	processing of bulk records
    *********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkAfter() {        
    }
    
    /********************************************************************************************************** 
    @methodname 	 beforeInsert
    @createdDate 	 12/09/2022
    @param           newList
    @description	 Trigger handler mehtod used to process differnet operations in before Insert trigger event	
    ***********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void beforeInsert(List<SObject> newList) {
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        try{
            
        TPM_UserTriggerHelperExtension.checkValidationForDefaultSalesOrg(newList);
        }
        catch(Exception exp) {
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.USER_TRIGGER_HANDLER;
            logWrapperObj.methodName = TPM_ConstantsUtility.BEFORE_INSERT_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
    /********************************************************************************************************** 
    @methodname 	 afterInsert
    @createdDate 	 12/09/2022
    @param           newMap
    @description	 Trigger handler mehtod used to process differnet operations in after insert trigger event
    ***********************************************************************************************************/  
    public void afterInsert(Map<Id, SObject> newMap) {
        List<Id> newUserIdList = new List<Id>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        //create your collections here from the newMap parameter.
        //do not perform any business logic/dml in this class
        //write methods in the helper class and call them from here.
        for(User userObj : (List<User>) newMap.values()){ 
            if(userObj.IsActive){
                newUserIdList.add(userObj.id);
            }
        }
        
        try{
            //call your helper methods from here and pass the collections in them created above.
            TPM_UserTriggerHelper.createUserSetting(newMap); 
            if(!newUserIdList.isEmpty()){
                TPM_UserTriggerHelper.assignUserToGroup(newUserIdList);
                TPM_UserTriggerHelper.createSalesOrgRecords(newUserIdList); 
            
                
            }
            
        }catch(Exception exp) {
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.USER_TRIGGER_HANDLER;
            logWrapperObj.methodName = TPM_ConstantsUtility.AFTER_INSERT_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
        
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeUpdate
    @createdDate 	12/09/2022
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before update trigger event
    *******************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        try{
            TPM_UserTriggerHelperExtension.checkValidationForDefaultSalesOrg(newMap.values());
        }
        catch(Exception exp) {
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.USER_TRIGGER_HANDLER;
            logWrapperObj.methodName = TPM_ConstantsUtility.BEFORE_UPDATE_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @createdDate 	12/09/2022
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in after update trigger event	
    ************************************************************************************************************/
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        List<Id> newUserIdList = new List<Id>();
        Map<Id, String> oldMapSalesOrg = new Map<Id, String>();
        
        for(User userObj : (List<User>)newMap.values()){
            User oldUserObj = (User)oldMap.get(userObj.Id);
            if(userObj.TPM_Sales_Org__c != oldUserObj.TPM_Sales_Org__c){
                  newUserIdList.add(userObj.Id);
                oldMapSalesOrg.put(userObj.Id,oldUserObj.TPM_Sales_Org__c);
            }
        }
            
        try{
        TPM_UserTriggerHelper.reassignPermissionGroup(newMap,oldMap);
            if(!newUserIdList.isEmpty() && !oldMapSalesOrg.isEmpty()){
                TPM_UserTriggerHelper.updateSalesOrgRecords(newUserIdList,oldMapSalesOrg); 
            }
             
        }
        catch(Exception exp) {
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.USER_TRIGGER_HANDLER;
            logWrapperObj.methodName = TPM_ConstantsUtility.AFTER_UPDATE_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeDelete
    @createdDate 	12/09/2022
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterDelete
    @createdDate 	12/09/2022
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterDelete(Map<Id, SObject> oldMap) { 
    }
    
    
    /********************************************************************************************************** 
    @methodname 	afterUnDelete
    @createdDate 	12/09/2022
    @param          newList
    @description	Trigger handler mehtod used to process differnet operations in before after undelete trigger event	
    ************************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUnDelete(List<SObject> newList) { 
        
    }

    /********************************************************************************************************** 
    @methodname 	andFinally
    @createdDate 	12/09/2022
    @description	This method is called once all records have been processed by the trigger. 
                    Use this method to accomplish any final operations such as creation or updates of other records.
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void andFinally() {
    }
    
}