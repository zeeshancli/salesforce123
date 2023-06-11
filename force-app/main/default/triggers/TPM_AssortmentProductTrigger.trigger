/*******************************************************************************************************
* @Name         : TPM_AssortmentProductTrigger
* @Unit Test    : TPM_AssortmentProductTriggerTest
* @Author       : PwC Team
* @Date         : 02/21/2023
* @Description  : Trigger invoked in for different events before/after to process logic whenever Assortment product data is created/manipulated 
*******************************************************************************************************/

trigger TPM_AssortmentProductTrigger on AssortmentProduct (after insert, after delete, after update) {
    
   //Call method to instantiate the handler class
    TPM_Utils.validateAndCreateAssortmentProductHandler();
}