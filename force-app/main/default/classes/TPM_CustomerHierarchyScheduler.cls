/*******************************************************************************************************
* @Name           TPM_CustomerHierarchyScheduler
* @author         PwC Team
* @date           January 19, 2023
* @description    Scheduler Apex is used for customer hierarchy staging batch.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_CustomerHierarchyScheduler implements Schedulable {
    
    /*******************************************************************************************
    * @method          : execute
    * @param             sch
    * @description     : method to schedule execution for TPM_CustomerHierarchyBatch batch
    ********************************************************************************************/
    public void execute(SchedulableContext sch) {
        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;
        
        TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_CUSTOMERHIERARCHY_AUTOMATION);
        if(String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
            batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
        }
        
        TPM_CustomerHierarchyBatch custHierarchyBatch = new TPM_CustomerHierarchyBatch();       
        database.executeBatch(custHierarchyBatch, batchSize);       
    }
}