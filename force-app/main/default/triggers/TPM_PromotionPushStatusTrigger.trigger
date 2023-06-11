/*******************************************************************************************************
* @Name         : TPM_AccountPlanTrigger 
* @Unit Test    : TPM_AccountPlanTriggerTest
* @Author       : PwC Team
* @Date         : 30/01/2022
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_PromotionPushStatusTrigger on cgcloud__Promotion_Push_Status__c (after update) {

    //Call TPM_Trigger_Utils.checkStatusOfPushPromotion()  updation
    //of apush promotion statusrecords  
    //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger                       

    TPM_Trigger_Utils.checkStatusOfPushPromotion();

}