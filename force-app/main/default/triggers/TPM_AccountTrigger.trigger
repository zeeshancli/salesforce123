
/*******************************************************************************************************
* @Name         : TPM_AccountTrigger 
* @Unit Test    : TPM_AccountTriggerTest
* @Author       : PwC Team
* @Date         : 02/03/2023
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_AccountTrigger on Account (before update, before delete, after update) {

    //Call TPM_Trigger_Utils.validateAccessForAccount() on updation or deletion
    //of account
    
    TPM_Trigger_Utils.validateAccessForAccount();

}

