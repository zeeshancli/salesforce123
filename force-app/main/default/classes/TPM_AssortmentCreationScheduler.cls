/*******************************************************************************************************
* @Name         : TPM_AssortmentCreationScheduler
* @testclass    :  TPM_AssortmentCreationBatchTest
* @Author       : PwC Team
* @date         : February 7, 2023
* @description  : Schedulable Apex is used to schedule assortment creation for account records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_AssortmentCreationScheduler implements Schedulable {
    
    /******************************************************************************************
    * @method			 execute
    * @param			 scon
    * @description		 Schedulable execute method.
    ******************************************************************************************/ 
    public void execute(SchedulableContext scon) {
        
        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;

        // To fetch the batch size from TPM_QueryDefinition__mdt record.
        TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_ASSORTMENT_CREATION);

        if(batchQueryMdt != null && String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
            batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
        }
        
        TPM_AssortmentCreationBatch assortmentCreation = new TPM_AssortmentCreationBatch();
        
        // Call the batch class to execute.
        Database.executeBatch(assortmentCreation, batchSize);
   }
    
}