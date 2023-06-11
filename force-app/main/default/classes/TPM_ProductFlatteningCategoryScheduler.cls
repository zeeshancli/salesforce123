/******************************************************************************************************
* @Name         : TPM_ProductFlatteningCategoryScheduler
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Schedulable apex is used schedule batch - 'TPM_ProductFlatteningCategoryBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_ProductFlatteningCategoryScheduler implements Schedulable {


    /*******************************************************************************************
    * @method          : execute
    * @param             sc
    * @description     : Execute method to execute TPM_ProductFlatteningCategoryBatch
    ********************************************************************************************/
    public void execute(SchedulableContext sc) {
        
        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;

        // To fetch the batch size from TPM_QueryDefinition__mdt record.
        TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_PRD_FLATTENING_CATEGORY);

        if(batchQueryMdt != null && String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
            batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
        }
        
        TPM_ProductFlatteningCategoryBatch prodFlattenCategoryBatch = new TPM_ProductFlatteningCategoryBatch(null); 
        
        // Call the batch class to execute.
        Database.executeBatch(prodFlattenCategoryBatch, batchSize);       
    }
    
}