/*******************************************************************************************************
* @Name         : TPM_AccountTeamTrigger
* @Unit Test    : TPM_AccountTeamTriggerTest
* @Author       : PwC Team
* @Date         : 01/18/2023
* @Description  : Trigger invoked in for different events before/after to process logic whenever Account team data is created/manipulated 
*******************************************************************************************************/

trigger TPM_AccountTeamTrigger on AccountTeamMember (after insert,after update,after delete,after undelete) {
	//Call TPM_Utils.validateAndCreateHandler()
    //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger 
    
    TPM_Utils.validateAndCreateAccountTeamHandler();
}