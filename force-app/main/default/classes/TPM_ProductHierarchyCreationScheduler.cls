/******************************************************************************************************
* @Name         : TPM_ProductHierarchyCreationScheduler
* @author       : PwC Team
* @date         : January 18, 2023
* @description  : Schedulable apex is used schedule batch - 'TPM_ProductHierarchyCreationBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_ProductHierarchyCreationScheduler implements Schedulable {
    

    /*******************************************************************************************
    * @method          : execute
    * @param             sc
    * @description     : Execute method to execute TPM_ProductHierarchyCreationBatch
    ********************************************************************************************/
    public void execute(SchedulableContext sc) {
        
        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;

        // To fetch the batch size from TPM_QueryDefinition__mdt record.
        TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION);

        if(batchQueryMdt != null && String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
            batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
        }
        
        TPM_ProductHierarchyCreationBatch prodHierarchyCreationBatch = new TPM_ProductHierarchyCreationBatch(null); 
        
        // Call the batch class to execute.
        Database.executeBatch(prodHierarchyCreationBatch, batchSize);       
    }

}