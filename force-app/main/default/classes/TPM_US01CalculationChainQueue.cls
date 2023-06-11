/*******************************************************************************************************
* @Name         : TPM_US01CalculationChainQueue
* @testclass    : TPM_US01CalculationChainQueueTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Queable Apex is used to excute the US01 TPMCalculationChain Batch for every 10 Mins.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.avoiddeeplynestedifstmts ,PMD.stdcyclomaticcomplexity, PMD.ncssmethodcount, PMD.cyclomaticcomplexity')
public class TPM_US01CalculationChainQueue implements Queueable, Database.AllowsCallouts{
    /*********************************************************************************
    * @method         : execute
    * @param            qc
    * @description    : Queue execute method to fetch the account records with 
    * 					salesOrg = US01 and Process and Call TPMCalculationChain Batch
    **********************************************************************************/
    public void execute(QueueableContext qc) {
        
        Set<Id> accountIdsSet = new Set<Id>();
        List<Account> accToUpdateList = new List<Account>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        String query = '';

        //Query Accounts WHERE 
        //Sales Org = US01
        //AND TPM_ProcessTPMCalculationChain__c = TRUE
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.TPM_US01_CALCULATIONCHAIN_BATCH_QUERY]){
                                                      
                                                      if(String.isNotBlank(queryDef.TPM_BaseQuery__c)){
                                                          query = queryDef.TPM_BaseQuery__c;
                                                      }
                                                      if(String.isNotBlank(queryDef.TPM_QueryCondition__c)){
                                                          query = query + ' ' + queryDef.TPM_QueryCondition__c;
                                                      }
                                                  }
        // Get All the List of Accounts
        List<Account> queriedAccList = Database.query(query);
        
        // Add all the Account Ids
        for(Account accObj : queriedAccList){
            accountIdsSet.add(accObj.Id);
        }
        
        // If Accounts are found
        if(!queriedAccList.isEmpty()){
            // Query If any previously running TPM Batches 
            // are There or Not
            List<AsyncApexJob> activeApexJobsList = [SELECT  Id, 
                                                     JobType, 
                                                     ApexClassId, 
                                                     Status, 
                                                     JobItemsProcessed, 
                                                     TotalJobItems, 
                                                     MethodName, 
                                                     CronTriggerId 
                                                     FROM 	 AsyncApexJob 
                                                     WHERE   ApexClass.Name IN ('TPM_BC_Promotion','TPM_BC_Fund','TPM_BC_RateBasedFunding','TPM_BC_PAAPLA') 
                                                     AND 	 Status IN ('Holding','Queued','Preparing','Processing')];
            // If no previously scheduled batch exists
            if(activeApexJobsList.isEmpty()){
                // Then Schedule batches
                TPM_ConfigureNightlyBatch__mdt nightlyBatchCMDT = TPM_ConfigureNightlyBatch__mdt.getInstance(TPM_ConstantsUtility.TPM_EXECUTE_US01_CALCHAIN_BATCH);
                
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
                settings.accountIds = accountIdsSet;
                // Instantiate the TPMCalculationChain Class
                cgcloud.TPMCalculationChain c = new cgcloud.TPMCalculationChain(settings);
                
                if(!Test.isRunningTest()){
                    // Start the TPMCalculationChain Process
                    c.startProcess(); 
                }
                
                // After Invocation of the TPM Batches
                // Set the Boolean field to FALSE
                for(Account accObj : queriedAccList){
                    accObj.TPM_ProcessTPMCalculationChain__c = FALSE;
                    accToUpdateList.add(accObj);
                }
                
                if(!accToUpdateList.isEmpty()){
                    Integer count = 0;
                    
                    Database.saveResult[] saveResultList = Database.update(accToUpdateList,false);
                    
                    for (Database.saveResult saveResultListObj : saveResultList) {
                        if(!saveResultListObj.isSuccess()){
                            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                            logWrapperObj.errors = saveResultListObj.getErrors();
                            logWrapperObj.guid = accToUpdateList[count].id;
                            logWrapperObj.className = TPM_ConstantsUtility.TPM_US01_CALCULATION_CHAIN_QUEUE;
                            logWrapperObj.methodName = TPM_ConstantsUtility.US01_CALCULATION_CHAIN_QUEUE_EXECUTE_METHOD;
                            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
                            exceptionWrapperList.add(logWrapperObj);
                        }
                        
                        count++;
                    }
                    
                    TPM_LoggerException.log(exceptionWrapperList);
                }
                
            }
            // If Any previously scheduled TPM Batches are running
            // Then Stop the Current Queueing Class
            else{
                Id currentQJobId = [SELECT  Id, 
                                            JobType, 
                                            ApexClassId, 
                                            Status, 
                                            JobItemsProcessed, 
                                            TotalJobItems, 
                                            MethodName, 
                                            CronTriggerId 
                                    FROM 	AsyncApexJob
                                    WHERE   Id =: qc.getJobId()]?.Id;
                // Abort the Current Queueing Job
                System.abortJob(currentQJobId);
            }
        }
    }
}