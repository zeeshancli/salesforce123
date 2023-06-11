/*******************************************************************************************************
* @Name         : TPM_AccountTeamTriggerHandler
* @unit Test    : TPM_AccountTeamTriggerTest
* @author       : PwC Team
* @date         : 12/09/2022
* @description  : Handler class for Account Team trigger.
*******************************************************************************************************/

public inherited sharing class TPM_AccountTeamTriggerHandler implements TPM_TriggerInterface  {

    
    /******************************************************************************************************** 
    @methodname 	bulkBefore
    @createdDate 	01/18/2023
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
    @createdDate 	 01/18/2023
    @param           newList
    @description	 Trigger handler mehtod used to process differnet operations in before Insert trigger event	
    ***********************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void beforeInsert(List<SObject> newList) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	 afterInsert
    @createdDate 	 01/18/2023
    @param           newMap
    @description	 Trigger handler mehtod used to process differnet operations in after insert trigger event
    ***********************************************************************************************************/  

    public void afterInsert(Map<Id, SObject> newMap) {
        if(!TPM_Utils.isBypassAssignAccountTeamMember){
           TPM_AccountTeamTriggerHelper.assignAccountTeamMember(newMap); 
        }
        TPM_AccountTeamTriggerHelper.teamMemberRecordSharingHandler(newMap);
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeUpdate
    @createdDate 	01/18/2023
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before update trigger event
    *******************************************************************************************************/ 

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @createdDate 	01/18/2023
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in after update trigger event	
    ************************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeDelete
    @createdDate 	01/18/2023
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
    ************************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void beforeDelete(Map<Id, SObject> oldMap) {
        
    }
    
    /********************************************************************************************************** 
    @methodname 	afterDelete
    @createdDate 	01/18/2023
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before delete trigger event	
    ************************************************************************************************************/ 

    public void afterDelete(Map<Id, SObject> oldMap) { 
        if(!TPM_Utils.isBypassRemoveAccountTeamMember){
            TPM_AccountTeamTriggerHelper.removeAccountTeamMember(oldMap); 
        }
        TPM_AccountTeamTriggerHelper.deleteRecordAccessForTeamMembers(oldMap); 
    }
    
    
    /********************************************************************************************************** 
    @methodname 	afterUnDelete
    @createdDate 	01/18/2023
    @param          newList
    @description	Trigger handler mehtod used to process differnet operations in before after undelete trigger event	
    ************************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterUnDelete(List<SObject> newList) {
    }

    /********************************************************************************************************** 
    @methodname 	andFinally
    @createdDate 	01/18/2023
    @description	This method is called once all records have been processed by the trigger. 
                    Use this method to accomplish any final operations such as creation or updates of other records.
    ************************************************************************************************************/ 
    
    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void andFinally() {
    }
    

}