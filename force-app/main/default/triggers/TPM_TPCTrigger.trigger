trigger TPM_TPCTrigger on cgcloud__Tactic_Product_Condition__c (before insert, before update) {

    // Call to handler.                               
    TPM_Utils.validateAndCreateTPCHandler();
}