/******************************************************************************************************
  @Name            TPM_CustomerExtentionBatch
  @testclass       TPM_CustomerExtentionBatchTest
  @Author          PwC Team
  @date            December 12, 2022
  @description     Batch Apex is used for customer extension creation for account records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public class TPM_CustomerExtentionBatch implements Database.Batchable<Sobject> { 
    
    /*********************************************************************************
      @method          start
      @param            bc
      @return          Database.QueryLocator
      @description     Batch start method to fetch the account records with rool-up Number_Of_Extensions equals Zero.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
         
        String query = '';
        //Query Accounts WHERE 
        //Customer Template != NULL AND Customer External Id != NULL AND No of Customer Extensions = 0
        // preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_CUSTOMEREXTENSION_ASSIGNMENT]){
                                                      
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
      @method           execute
      @param            bc
      @param            scope
      @description      execute method to process account records for customer extension creation
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> scope) {
      TPM_CustomerExtentionHelper custExtnHelprObj = TPM_CustomerExtentionHelper.getInstance();
      custExtnHelprObj.createCustomerExtension(scope);
    }
    
    
    /************************************************************************************
      @method          finish
      @param           bc
      @description     Batch finish method to track batch status.
    *************************************************************************************/
    public void finish(Database.BatchableContext bc) {
        
        //Check for Batch Sequencing
        if(System.Label.isTPMBatchSequenced.equals(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){
            
            Integer batchSize = TPM_ConstantsUtility.NUMBER_200;
            //Get the Batch Size from CMDT TPM_QueryDefinition__mdt
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_CUSTOMERHIERARCHY_AUTOMATION);
            
            if(String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            //If Batch is Sequenced, Call Customer Hierarchy Batch next
            Database.executeBatch(new TPM_CustomerHierarchyBatch(), batchSize);
        }        
    }
}