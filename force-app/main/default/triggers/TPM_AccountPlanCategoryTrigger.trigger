/*******************************************************************************************************
* @Name         : TPM_AccountPlanCategoryTrigger 
* @Unit Test    : TPM_AccountPlanTriggerTest
* @Author       : PwC Team
* @Date         : 30/01/2022
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_AccountPlanCategoryTrigger on cgcloud__Account_Plan_Category__c (after update) {

    //Call TPM_Utils.validateAndExtendAccessBusinessPlanHandler() on insertion or updation
    //of account plan records  
    //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger                       

    TPM_Utils.validateAndCreateCBPCategoryHandler();

}