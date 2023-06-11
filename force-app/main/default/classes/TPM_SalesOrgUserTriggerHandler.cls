/*******************************************************************************************************
* @Name         : TPM_SalesOrgUserTriggerHandler
* @unit Test    : TPM_SalesOrgUserTriggerHandlerTest
* @author       : PwC Team
* @date         : 02/07/2022
* @description  : Handler class for Sales Org User Trigger.
*******************************************************************************************************/

public inherited sharing class TPM_SalesOrgUserTriggerHandler implements TPM_TriggerInterface {
    
    /******************************************************************************************************** 
    @methodname 	bulkBefore
    @createdDate 	02/07/2022
    @description	processing of bulk records
    *********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkBefore() {      
    }
    
    /******************************************************************************************************** 
    @methodname 	bulkAfter
    @createdDate 	02/07/2022
    @description	processing of bulk records
    *********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkAfter() {        
    }
    
    /********************************************************************************************************** 
    @methodname 	 beforeInsert
    @createdDate 	 02/07/2022
    @param           newList
    @description	 Trigger handler method used to process different operations in before Insert trigger event	
    ***********************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void beforeInsert(List<SObject> newList) {
       
        
    }
    
    /********************************************************************************************************** 
    @methodname 	 afterInsert
    @createdDate 	 02/07/2022
    @param           newMap
    @description	 Trigger handler method used to process different operations in after insert trigger event
    ***********************************************************************************************************/  
    public void afterInsert(Map<Id, SObject> newMap) {
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        //create your collections here from the newMap parameter.
        //do not perform any business logic/dml in this class
        //write methods in the helper class and call them from here.
        try{
            //call your helper methods from here and pass the collections in them created above.
    		//handleSalesOrgProductManagerOperation - A Generic Helper Method for Insert / Delete Context based on Parameter
    		//If newMap has values then its Insert Context
            TPM_SalesOrgUserTriggerHelper.handleSalesOrgProductManagerOperation(newMap,NULL); 
            TPM_SalesOrgUserTriggerHelper.updateStandardSalesOrg(newMap); 
        }catch(Exception exp) {
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.SALES_ORG_USER_TRIGGER_HANDLER;
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
    @description	Trigger handler mehtod used to process different operations in before update trigger event
    *******************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @createdDate 	12/09/2022
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process different operations in after update trigger event	
    ************************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
         
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeDelete
    @createdDate 	12/09/2022
    @param          oldMap
    @description	Trigger handler mehtod used to process different operations in before delete trigger event	
    ************************************************************************************************************/ 
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterDelete
    @createdDate 	12/09/2022
    @param          oldMap
    @description	Trigger handler mehtod used to process different operations in before delete trigger event	
    ************************************************************************************************************/ 
    public void afterDelete(Map<Id, SObject> oldMap) {
       List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        //create your collections here from the newMap parameter.
        //do not perform any business logic/dml in this class
        //write methods in the helper class and call them from here.
        try{
            //call your helper methods from here and pass the collections in them created above.
    		//handleSalesOrgProductManagerOperation - A Generic Helper Method for Insert / Delete Context based on Parameter
    		//If oldMap has values then its Delete Context
            TPM_SalesOrgUserTriggerHelper.handleSalesOrgProductManagerOperation(NULL,oldMap);
        }catch(Exception exp) {
            //error logging operations
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.SALES_ORG_USER_TRIGGER_HANDLER;
            logWrapperObj.methodName = TPM_ConstantsUtility.AFTER_DELETE_TRIGGER;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }      
    }

    /********************************************************************************************************** 
    @methodname 	afterUnDelete
    @createdDate 	12/09/2022
    @param          newList
    @description	Trigger handler mehtod used to process different operations in before after undelete trigger event	
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