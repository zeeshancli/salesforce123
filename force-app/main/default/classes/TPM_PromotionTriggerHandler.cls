/******************************************************************************************************
@Name            TPM_PromotionTriggerHandler
@testclass       TPM_PromotionCustomerPlanTriggerTest
@Author          PwC Team
@date            January 27, 2023
@description     Handler for Promotion Trigger
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_PromotionTriggerHandler implements TPM_TriggerInterface{
    

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

    public void beforeInsert(List<SObject> newList) {
        TPM_PromotionTriggerHelper.handleFieldUpdatesForPromotion(newList);
        TPM_PromotionTriggerHelper.handleAccountPlanFieldForPromotion(newList);
        
        
    }
    
    /********************************************************************************************************** 
    @methodname 	 afterInsert
    @createdDate 	 01/18/2023
    @param           newMap
    @description	 Trigger handler mehtod used to process differnet operations in after insert trigger event
    ***********************************************************************************************************/  

    public void afterInsert(Map<Id, SObject> newMap) {
        TPM_PromotionTriggerHelper.extendPromotionSharingForAccountTeamMembers(newMap, null);
        TPM_PromotionTriggerHelper.handleDefaultDraftPhasePromotion(newMap);
        TPM_PromotionTriggerHelperExtension.handleFieldUpdateForAccount(newMap);
    }
    
    /********************************************************************************************************** 
    @methodname 	beforeUpdate
    @createdDate 	01/18/2023
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in before update trigger event
    *******************************************************************************************************/ 
	
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {   
        TPM_PromotionTriggerHelper.handleAccountPlanFieldForPromotion(newMap.values()); 
        
        // To keep cgcloud__Phase__c field, TPM_Phase__c in sync
        TPM_PromotionTriggerHelper.handleCGCloudPhaseFieldUpdate(newMap, oldMap); 

        TPM_PromotionTriggerHelperExtension.handlePushPromotionUpdate(newMap, oldMap); 
    }
    
    /********************************************************************************************************** 
    @methodname 	afterUpdate
    @createdDate 	01/18/2023
    @param          newMap
    @param          oldMap
    @description	Trigger handler mehtod used to process differnet operations in after update trigger event	
    ************************************************************************************************************/
    
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        TPM_PromotionTriggerHelper.extendPromotionSharingForAccountTeamMembers(newMap, oldMap);
        
        TPM_PromotionTriggerHelper.processApprovalRecords(newMap, oldMap);

        TPM_PromotionTriggerHelperExtension.processOverLapCheck(newMap, oldMap);

        TPM_PromotionTriggerHelperExtension.handleFieldUpdateForAccount(newMap);
        if(!TPM_Utils.isBypassPromotionUpdateForDraft){
            TPM_PromotionTriggerHelper.handleDraftForCopied(newMap, oldMap);
        }
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

    @SuppressWarnings('PMD.EmptyStatementBlock') 
    public void afterDelete(Map<Id, SObject> oldMap) { 

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