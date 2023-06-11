/******************************************************************************************************
@Name            TPM_PromotionTriggerUtils
@testclass       TPM_PromotionCustomerPlanTriggerTest
@Author          PwC Team
@date            March 22, 2023
@description     Handles common methods for Promotion Trigger Helper 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_PromotionTriggerUtils {
    
    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_PromotionTriggerUtils() {
        
    }

    /*********************************************************************************
    @method          doCGcloudPhaseUpdate
	@param     	  	 promotionsObj
    @description     method to update the cgcloud__Phase__c using TPM_Phase__c 
    **********************************************************************************/
    
    public static void doCGcloudPhaseUpdate(cgcloud__Promotion__c promotionsObj) {
        String stage;
        
        // Update corresponding status in cg__cloud Phase field, US #2141 for Reference
        if(promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_DRAFT){
            stage = TPM_ConstantsUtility.PHASE_PLANNING;
        } else if(promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING) {
            stage = TPM_ConstantsUtility.PHASE_MODELLING;
        } else if(promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_SUBMITFORAPPROVAL) {
            // assign Promotion Submitter for approval process
            promotionsObj.TPM_Promotion_Submitter__c = UserInfo.getUserId();
            stage = TPM_ConstantsUtility.PHASE_FORAPPROVAL;
        } else if(promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_APPROVED) {
            stage = TPM_ConstantsUtility.PHASE_COMMITED;
        } else if(promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_CLOSED) {
            stage = TPM_ConstantsUtility.PHASE_COMMITED;
        } else if(promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_FINANCE_EDIT) {
            stage = TPM_ConstantsUtility.PHASE_MODELLING;
        }
        
        promotionsObj.cgcloud__Phase__c = String.isNotBlank(stage) ? stage : promotionsObj.TPM_Phase__c;
        
    }

}