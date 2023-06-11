trigger TPM_TacticTrigger on cgcloud__Tactic__c (before insert, before update, after insert, after update) {
    
    // Call to handler.                               
    TPM_Utils.validateAndCreateTacticHandler();
    
}