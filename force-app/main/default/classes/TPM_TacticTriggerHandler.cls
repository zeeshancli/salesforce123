/*******************************************************************************************************
* @Name         : TPM_TacticTriggerHandler
* @Test Class   : 
* @author       : PwC Team
* @date         : April 3, 2023
* @description  : Handler class for tactic trigger.
*******************************************************************************************************/

public inherited sharing class TPM_TacticTriggerHandler implements TPM_TriggerInterface {
    
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
        
        TPM_TacticTriggerHelper.updateMaintenanceOnTactic((List<cgcloud__Tactic__c>)newList, null);
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

        TPM_TacticTriggerHelper.updateMaintenanceOnTactic((List<cgcloud__Tactic__c>)newMap.values(), (Map<Id, cgcloud__Tactic__c>)oldMap);
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod 	
    ************************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        TPM_TacticTriggerHelper.updateTCCDRecords((List<cgcloud__Tactic__c>)newMap.values(), (Map<Id, cgcloud__Tactic__c>)oldMap);
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