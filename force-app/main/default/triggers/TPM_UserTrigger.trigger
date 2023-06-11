/*******************************************************************************************************
* @Name         : TPM_UserTrigger
* @Unit Test    : TPM_UserTriggerTest
* @Author       : PwC Team
* @Date         : 12/09/2022
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_UserTrigger on User (after insert,after update, before insert, before update) {
    
    //Call TPM_Utils.validateAndCreateHandler()
    //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger                              
    
    TPM_Utils.validateAndCreateUserHandler();
}