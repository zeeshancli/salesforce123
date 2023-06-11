/*******************************************************************************************************
* @Name         : TPM_CustomerTemplateAssignmentScheduler
* @author       : PwC Team
* @date         : December 13, 2022
* @description  : Batch Apex is used for customer temmplate assignment to account records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_CustomerTemplateAssignmentScheduler implements Schedulable {
    
    
    /*******************************************************************************************
    * @method          : execute
    * @param             sc
    * @description     : Execute method to execute TPM_CustomerTemplateAssignmentBatch
    ********************************************************************************************/
    public void execute(SchedulableContext sc) {
        
        Integer batchSize = 200;
        
        // Custom Label - TPM_CustomerTemplateAssignmentBatchSize to set batch size.
        if(String.isNotEmpty(System.Label.TPM_CustomerTemplateAssignmentBatchSize)){
            batchSize = Integer.valueOf(System.Label.TPM_CustomerTemplateAssignmentBatchSize);
        }
        
        TPM_CustomerTemplateAssignmentBatch custTemplateAssignBatch = new TPM_CustomerTemplateAssignmentBatch(null);       
        database.executeBatch(custTemplateAssignBatch, batchSize);       
    }
    
}