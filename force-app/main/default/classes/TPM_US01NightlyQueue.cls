/*******************************************************************************************************
* @Name         : TPM_US01NightlyQueue
* @testclass    : TPM_US01NightlyQueueTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Queuable Apex is used to excute the US01 TPMCalculationChain Nightly Batches.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public class TPM_US01NightlyQueue implements Queueable, Database.AllowsCallouts{
    /*********************************************************************************
    * @method         : execute
    * @param            qc
    * @description    : Queue execute method to fetch the account records with 
    * 					salesOrg = US01 and Process and Call TPMCalculationChain Batch
    **********************************************************************************/
    public void execute(QueueableContext qc) {
        
        TPM_ConfigureNightlyBatch__mdt nightlyBatchCMDT = TPM_ConfigureNightlyBatch__mdt.getInstance(TPM_ConstantsUtility.TPM_EXECUTE_US01_NIGHTLY_BATCH);
        
        // Initialize the Nightly Batch Settings
        cgcloud.TPM_BC_Settings settings = new cgcloud.TPM_BC_Settings(nightlyBatchCMDT.TPM_Sales_Org__c);
        settings.execReorganization = nightlyBatchCMDT.TPM_execReorganization__c;
        settings.execAccountProductList = nightlyBatchCMDT.TPM_execAccountProductList__c;
        settings.execAccountPlanBasic = nightlyBatchCMDT.TPM_execAccountPlanBasic__c;
        settings.execPromotion = nightlyBatchCMDT.TPM_execPromotion__c;
        settings.execAccountPlanBusinessPlan = nightlyBatchCMDT.TPM_execAccountPlanBusinessPlan__c;
        settings.execRBFCalculation = nightlyBatchCMDT.TPM_execRBFCalculation__c;
        settings.execFundCalculation = nightlyBatchCMDT.TPM_execFundCalculation__c;
        settings.batchSizePAAPLA = (Integer.valueOf(nightlyBatchCMDT.TPM_PAAPLA_Batch_Size__c));
        
        // Instantiate the TPMCalculationChain Class
        cgcloud.TPMCalculationChain c = new cgcloud.TPMCalculationChain(settings);
        
        if(!Test.isRunningTest()){
            // Start the TPMCalculationChain Process
            c.startProcess();  
        }
        
    }

}