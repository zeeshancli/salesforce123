/*******************************************************************************************************
* @Name         : TPM_AssortmentTrigger 
* @Unit Test    : TPM_AssortmentTriggerTest
* @Author       : PwC Team
* @Date         : 02/03/2023
* @Description  : Trigger invoked in for different events before/after to process logic whenever user data is created/manipulated 
*******************************************************************************************************/
trigger TPM_AssortmentTrigger on Assortment (before update,before Delete) {

    
    //Call TPM_Trigger_Utils.validateAccessForAssortment() on updation or deletion
    //of Assortment
    TPM_Trigger_Utils.validateAccessForAssortment();

}