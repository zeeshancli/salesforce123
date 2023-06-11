/*******************************************************************************************************
* @Name         : TPM_TPCTriggerHandler
* @Test Class   : 
* @author       : PwC Team
* @date         : April 3, 2023
* @description  : Handler class for tactic product condition trigger.
*******************************************************************************************************/

public inherited sharing class TPM_TPCTriggerHandler implements TPM_TriggerInterface {
    
    /******************************************************************************************************** 
    @methodname 	bulkBefore
    @description	processing of bulk records
    *********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkBefore() {      
    }
    
    /******************************************************************************************************** 
    @methodname 	bulkAfter
    @description	processing of bulk records
    *********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkAfter() {        
    }
    
    /********************************************************************************************************** 
    @methodname 	 beforeInsert
    @param           newList
    @description	 Trigger handler mehtod 
    ***********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void beforeInsert(List<SObject> newList) {
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        
        try{
            TPM_TPCTriggerHelper.updateTPCConditions((List<cgcloud__Tactic_Product_Condition__c>)newList);
        } catch(Exception exp) {
            
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.FATAL;
            logWrapperObj.className = 'TPM_TPCTriggerHelper';
            logWrapperObj.methodName = TPM_ConstantsUtility.BEFORE_INSERT_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }   
    }
    
    /********************************************************************************************************** 
    @methodname 	 afterInsert
    @param           newMap
    @description	 Trigger handler mehtod 
    ***********************************************************************************************************/  
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void afterInsert(Map<Id, SObject> newMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeUpdate
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod 
    *******************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        
        try{
            TPM_TPCTriggerHelper.updateTPCStatusOnPaymentMethod((List<cgcloud__Tactic_Product_Condition__c>)newMap.values(), (Map<Id, cgcloud__Tactic_Product_Condition__c>)oldMap);
			
        } catch(Exception exp) {
            
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.FATAL;
            logWrapperObj.className = 'TPM_TPCTriggerHelper';
            logWrapperObj.methodName = TPM_ConstantsUtility.BEFORE_UPDATE_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod 	
    ************************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

    }
    
    /********************************************************************************************************** 
    @methodname 	beforeDelete
    @param          oldMap
    @description	Trigger handler mehtod 	
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterDelete
    @param          oldMap
    @description	Trigger handler mehtod 	
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterDelete(Map<Id, SObject> oldMap) { 
    }
    
    
    /********************************************************************************************************** 
    @methodname 	afterUnDelete
    @param          newList
    @description	Trigger handler mehtod 	
    ************************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUnDelete(List<SObject> newList) { 
        
    }

    /********************************************************************************************************** 
    @methodname 	andFinally
    @description	This method is called once all records have been processed by the trigger. 
                    Use this method to accomplish any final operations such as creation or updates of other records.
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void andFinally() {
    }
    
}