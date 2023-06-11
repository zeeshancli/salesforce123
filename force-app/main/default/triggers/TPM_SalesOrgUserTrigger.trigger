/*******************************************************************************************************
* @Name         : TPM_SalesOrgUserTrigger
* @Unit Test    : TPM_SalesOrgUserTriggerTest
* @Author       : PwC Team
* @Date         : 02/07/2023
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_SalesOrgUserTrigger on cgcloud__Sales_Organization_User__c (after insert,after delete, after update) {
    
    //Call TPM_Utils.validateAndCreateHandler()
    //To validate the Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related checks for trigger 
    TPM_Utils.validateAndCreateSalesOrgUserHandler();                           
}