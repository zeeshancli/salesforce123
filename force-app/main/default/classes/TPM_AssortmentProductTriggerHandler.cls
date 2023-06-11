/*******************************************************************************************************
* @Name         : TPM_AssortmentProductTriggerHandler
* @unit Test    : TPM_AssortmentProductTriggerTest
* @author       : PwC Team
* @date         : 01/03/2022
* @description  : Handler class for Assortment Product trigger.
*******************************************************************************************************/

public inherited sharing class TPM_AssortmentProductTriggerHandler implements TPM_TriggerInterface {

    
    /******************************************************************************************************** 
    @methodname 	bulkBefore
    @createdDate 	01/03/2022
    @description	processing of bulk records
    *********************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkBefore() {      
    }
    
    /******************************************************************************************************** 
    @methodname 	bulkAfter
    @createdDate 	01/03/2022
    @description	processing of bulk records
    *********************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void bulkAfter() {        
    }
    
    /********************************************************************************************************** 
    @methodname 	 beforeInsert
    @createdDate 	 01/03/2022
    @param           newList
    @description	 Trigger handler mehtod used to process differnet operations in before Insert trigger event	
    ***********************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void beforeInsert(List<SObject> newList) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	 afterInsert
    @createdDate 	 01/03/2022
    @param           newMap
    @description	 Trigger handler mehtod used to process differnet operations in after insert trigger event
    ***********************************************************************************************************/  

    public void afterInsert(Map<Id, SObject> newMap) {
        if(!TPM_Utils.isBypassAssignAssortProd){
            
            TPM_AssortmentProductTriggerHelper.assignAssortmentProductForHierarchy(newMap);
        }
        
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeUpdate
    @createdDate 	01/03/2022
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before update trigger event
    *******************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @createdDate 	01/03/2022
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in after update trigger event	
    ************************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        if(!TPM_Utils.isBypassUpdateAssortProd){
        TPM_AssortmentProductTriggerHelper.updateAssortmentProdFromHierarchy(newMap,oldMap);
        }
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeDelete
    @createdDate 	01/03/2022
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
    ************************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterDelete
    @createdDate 	01/03/2022
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
    ************************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterDelete(Map<Id, SObject> oldMap) { 
        if(!TPM_Utils.isBypassRemoveAssortProd){
            
            TPM_AssortmentProductTriggerHelper.removeAssortmentProdFromHierarchy(oldMap); 
        }
      
    }
    
    
    /********************************************************************************************************** 
    @methodname 	afterUnDelete
    @createdDate 	01/03/2022
    @param          newList
    @description	Trigger handler mehtod used to process differnet operations in before after undelete trigger event	
    ************************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUnDelete(List<SObject> newList) {
    }

    /********************************************************************************************************** 
    @methodname 	andFinally
    @createdDate 	01/03/2022
    @description	This method is called once all records have been processed by the trigger. 
                    Use this method to accomplish any final operations such as creation or updates of other records.
    ************************************************************************************************************/ 
    
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void andFinally() {
    }
    

}