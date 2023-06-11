/*******************************************************************************************************
* @Name         : TPM_IT01CalculationChainBatch
* @testclass    : TPM_IT01CalculationChainBatchTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Batch Apex is used to excute the IT01 TPMCalculationChain Batches for every 10 Mins.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_IT01CalculationChainBatch implements Database.Batchable<Sobject>, Database.AllowsCallouts, Database.Stateful{
    
    Set<Id> accountIdsSet = new Set<Id>();
    List<Account> queriedAccList = new List<Account>();
    /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the account records with 
    * 					salesOrg = IT01.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){
             
        String query = '';
        //Query Accounts WHERE 
        //Sales Org = IT01
        //AND TPM_ProcessTPMCalculationChain__c = TRUE
        //Preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.TPM_IT01_CALCULATIONCHAIN_BATCH_QUERY]){
                                                      
                                                      if(String.isNotBlank(queryDef.TPM_BaseQuery__c)){
                                                          query = queryDef.TPM_BaseQuery__c;
                                                      }
                                                      if(String.isNotBlank(queryDef.TPM_QueryCondition__c)){
                                                          query = query + ' ' + queryDef.TPM_QueryCondition__c;
                                                      }
                                                  }
        return Database.getQueryLocator(query);
            
         }
    
    /********************************************************************************************************
    * @method         : execute
    * @param            bc 
    * @param            accountList
    * @description    : execute method to process account records for TPMCalculation Nightly Batch Invocation
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> accountList){
        
        for(Account accObj : accountList){
            accountIdsSet.add(accObj.Id);
            queriedAccList.add(accObj);
        }
         	
    }
    
    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to Invoke the TPMCalculation Nightly Batches.
    *************************************************************************************/
    public void finish(Database.BatchableContext bc){
        
        List<Account> accToUpdateList = new List<Account>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        
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
            TPM_ConfigureNightlyBatch__mdt nightlyBatchCMDT = TPM_ConfigureNightlyBatch__mdt.getInstance(TPM_ConstantsUtility.TPM_EXECUTE_IT01_CALCHAIN_BATCH);
            
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
            cgcloud.TPMCalculationChain calculationChainObj = new cgcloud.TPMCalculationChain(settings);
            
            if(!Test.isRunningTest()){
                // Start the TPMCalculationChain Process
                calculationChainObj.startProcess(); 
            }
            
        }
        
        // After Invocation of the TPM Batches
        // Set the Boolean field to FALSE
        for(Account accObj : queriedAccList){
            accObj.TPM_ProcessTPMCalculationChain__c = FALSE;
            accToUpdateList.add(accObj);
        }
        
        try{
            if(!accToUpdateList.isEmpty()){
                // Update the Account Records
                update accToUpdateList;
            }
        }catch(Exception exp){
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = TPM_ConstantsUtility.TPM_IT01_CALCULATION_CHAIN_BATCH;
            logWrapperObj.methodName = TPM_ConstantsUtility.IT01_CALCULATION_CHAIN_BATCH_FINISH_METHOD;
            exceptionWrapperList.add(logWrapperObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }

}