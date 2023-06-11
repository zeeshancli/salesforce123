/*******************************************************************************************************
* @Name         : TPM_AccountPlanTrigger 
* @Unit Test    : TPM_AccountPlanTriggerTest
* @Author       : PwC Team
* @Date         : 30/01/2022
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_AccountPlanTrigger on cgcloud__Account_Plan__c (after insert,after update, before insert) {

    //Call TPM_Utils.validateAndExtendAccessBusinessPlanHandler() on insertion or updation
    //of account plan records  
    //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger                       

    TPM_Utils.validateAndExtendAccessAccountPlanHandler();

}