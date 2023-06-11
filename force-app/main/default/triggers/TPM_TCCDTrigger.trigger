trigger TPM_TCCDTrigger on cgcloud__Tactic_Condition_Creation_Definition__c (before insert, before update) {

    // Call to handler.                               
    TPM_Utils.validateAndCreateTCCDHandler();
}