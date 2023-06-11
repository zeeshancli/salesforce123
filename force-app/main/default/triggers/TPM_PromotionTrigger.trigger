/*******************************************************************************************************
* @Name         : TPM_PromotionTrigger 
* @Unit Test    : TPM_PromotionTriggerTest
* @Author       : PwC Team
* @Date         : 30/01/2023
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_PromotionTrigger on cgcloud__Promotion__c ( before insert, before update, after insert, after update) {

        //Call TPM_Utils.validateAndExtendAccessPromotionHandler() on insertion or updation
        //of promotion records
        //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger                    
                             
        TPM_Utils.validateAndExtendAccessPromotionHandler();

    }