/******************************************************************************************************
@Name            TPM_CBPCategoryTriggerHandler
@testclass       TPM_CBPCategoryTriggerTest
@Author          PwC Team
@date            April 10, 2023
@description     Handler for CBP Category Trigger
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing  class TPM_CBPCategoryTriggerHandler implements TPM_TriggerInterface{

    

    /******************************************************************************************************** 
   @methodname 	bulkBefore
   @createdDate 01/18/2023
   @description	processing of bulk records
   *********************************************************************************************************/ 
   @SuppressWarnings('PMD.EmptyStatementBlock')
   public void bulkBefore() {      

   }
   
   /******************************************************************************************************** 
   @methodname 	bulkAfter
   @createdDate 12/09/2022
   @description	processing of bulk records
   *********************************************************************************************************/ 
   @SuppressWarnings('PMD.EmptyStatementBlock')
   public void bulkAfter() {    

   }
   
   /********************************************************************************************************** 
   @methodname 	 beforeInsert
   @createdDate  01/18/2023
   @param        newList
   @description	 Trigger handler mehtod used to process differnet operations in before Insert trigger event	
   ***********************************************************************************************************/ 
  @SuppressWarnings('PMD.EmptyStatementBlock')
   public void beforeInsert(List<SObject> newList) {
       
   }
   
   /********************************************************************************************************** 
   @methodname 	 afterInsert
   @createdDate  01/18/2023
   @param           newMap
   @description	 Trigger handler mehtod used to process differnet operations in after insert trigger event
   **********************************************************************************************************/  
  @SuppressWarnings('PMD.EmptyStatementBlock')
   public void afterInsert(Map<Id, SObject> newMap) {
       
   }
   
   /********************************************************************************************************** 
   @methodname 	beforeUpdate
   @createdDate 01/18/2023
   @param       newMap
   @param       oldMap
   @description	Trigger handler mehtod used to process differnet operations in before update trigger event
   *******************************************************************************************************/ 
   @SuppressWarnings('PMD.EmptyStatementBlock') 
   public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
       
   }
   
   /********************************************************************************************************** 
   @methodname 	afterUpdate 
   @createdDate 01/18/2023
   @param       newMap
   @param       oldMap
   @description	Trigger handler mehtod used to process differnet operations in after update trigger event	
   ************************************************************************************************************/
   public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
       TPM_CBPCategoryTriggerHelper.updateFieldsForAccounts(newMap, oldMap);
   }
   
   /********************************************************************************************************** 
   @methodname 	beforeDelete
   @createdDate 01/18/2023
   @param       oldMap
   @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
   ************************************************************************************************************/
   @SuppressWarnings('PMD.EmptyStatementBlock') 
   public void beforeDelete(Map<Id, SObject> oldMap) {
       
   }
   
   /********************************************************************************************************** 
   @methodname 	afterDelete
   @createdDate 01/18/2023
   @param       oldMap
   @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
   ************************************************************************************************************/ 
   @SuppressWarnings('PMD.EmptyStatementBlock') 
   public void afterDelete(Map<Id, SObject> oldMap) { 

   }
   
   
   /********************************************************************************************************** 
   @methodname 	afterUnDelete
   @createdDate 01/18/2023
   @param       newList
   @description	Trigger handler mehtod used to process differnet operations in before after undelete trigger event	
   ************************************************************************************************************/
   @SuppressWarnings('PMD.EmptyStatementBlock') 
   public void afterUnDelete(List<SObject> newList) {

   }

   /********************************************************************************************************** 
   @methodname 	andFinally
   @createdDate 01/18/2023
   @description	This method is called once all records have been processed by the trigger. 
                Use this method to accomplish any final operations such as creation or updates of other records.
   ************************************************************************************************************/ 
   @SuppressWarnings('PMD.EmptyStatementBlock') 
   public void andFinally() {

   }

}