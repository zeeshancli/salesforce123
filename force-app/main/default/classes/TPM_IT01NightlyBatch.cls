/*******************************************************************************************************
* @Name         : TPM_IT01NightlyBatch
* @testclass    : TPM_IT01NightlyBatchTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Batch Apex is used to excute the IT01 TPMCalculationChain Nightly Batches.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class TPM_IT01NightlyBatch implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    
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
        //Preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.TPM_IT01_NIGHTLY_BATCH_QUERY]){
                                                      
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
         	
    }
    
    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to Invoke the TPMCalculation Nightly Batches.
    *************************************************************************************/
    public void finish(Database.BatchableContext bc){
        
        TPM_ConfigureNightlyBatch__mdt nightlyBatchCMDT = TPM_ConfigureNightlyBatch__mdt.getInstance(TPM_ConstantsUtility.TPM_EXECUTE_IT01_NIGHTLY_BATCH);
        
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
        cgcloud.TPMCalculationChain calculationChainObj = new cgcloud.TPMCalculationChain(settings);
        
        if(!Test.isRunningTest()){
            // Start the TPMCalculationChain Process
            calculationChainObj.startProcess(); 
        }
        
        
    }

}