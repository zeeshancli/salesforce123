/******************************************************************************************************
* @Name         : TPM_CustomerDeactivationBatch
* @Test Class   : TPM_CustomerDeactivationBatchTest
* @author       : PwC Team
* @date         : 11 May 2023 
* @description  : Batch Apex used for deactivating the Customer Records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public class TPM_CustomerDeactivationBatch implements Database.Batchable<sObject> {
    
    Map<String,Id> salesOrgToTemplateMap = new Map<String,Id>();
    
    /*********************************************************************************
    * @method         : TPM_CustomerDeactivationBatch
    * @param            
    * @description    : Batch Class Constructor Method to construct a 
    * 					Map of Key as
    * 					Planning Mode + Sales Org 
    * 					Value as Customer Tempalte Record Id
    **********************************************************************************/
    public TPM_CustomerDeactivationBatch(){

        for(cgcloud__Account_Template__c custTemp :[SELECT  Id, 
                                                    Name, 
                                                    cgcloud__Sales_Org__c, 
                                                    cgcloud__Description_Language_1__c, 
                                                    cgcloud__Active__c, 
                                                    TPM_CustTemp_PlanMode__c 
                                                    FROM 	cgcloud__Account_Template__c 
                                                    WHERE 	cgcloud__Active__c = TRUE 
                                                    AND 	TPM_CustTemp_PlanMode__c  != NULL
                                                    AND 	cgcloud__Sales_Org__c != NULL] ){
                                                        
            salesOrgToTemplateMap.put((custTemp.TPM_CustTemp_PlanMode__c + custTemp.cgcloud__Sales_Org__c),custTemp.Id);
        }
        
    }
    
    /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the account records with 
    * 					Active Flag != NULL AND Hierarchy Level != Total Sales Org.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
         // Use TPM_Utils Method 
         String query = '';
        // Query Accounts WHERE 
        // Active Flag == TRUE AND 
        // Hierarchy Level != Total Sales Org
        // Retrieve the Batch Query from custommetadata record
        Map<String, TPM_QueryDefinition__mdt> sharingRecordQueryDefinition = TPM_Utils.getDynamicQueryRecords(new List<String>{TPM_ConstantsUtility.TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY});
        
        // Preparing batch query based on custommetadata record
        if(String.isNotBlank(sharingRecordQueryDefinition.get(TPM_ConstantsUtility.TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY).TPM_BaseQuery__c)){
            query = sharingRecordQueryDefinition.get(TPM_ConstantsUtility.TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY).TPM_BaseQuery__c;
        }
        // Preparing batch query WHERE Clause
        if(String.isNotBlank(sharingRecordQueryDefinition.get(TPM_ConstantsUtility.TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY).TPM_QueryCondition__c)){
            query = query + ' ' + sharingRecordQueryDefinition.get(TPM_ConstantsUtility.TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY).TPM_QueryCondition__c;
        }

        return Database.getQueryLocator(query);
    }
    
     /********************************************************************************************************
    * @method         : execute
    * @param            bc 
    * @param            accountList
    * @description    : execute method to process the deactivation of account records
    ********************************************************************************************************/
    @SuppressWarnings('PMD.cyclomaticcomplexity')
    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        
        List<Account> accountDeactivationListToUpdate = new List<Account>();
        
        // Check If Account List is 
        // Not Empty
        if(!accountList.isEmpty()){
            // Iterate over each Account
            for(Account accObj : accountList){
                // Check If
                // 1. Parent Id field is Empty OR
                // 2. Hierarchy Level = Managed Account AND It has No Planning Mode Assigned OR
                // 3. Customer Template is Empty OR
                // 4. Hierarchy Level = Other than Managed Account AND It has Planning Mode Assigned OR
                // 5. If Template is not assgined according to Planning Mode for Managed Account
                if(   (accObj.ParentId == NULL) 
                   || (accObj.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT 
                       && accObj.TPM_Planning_Mode__c == NULL)
                   || (accObj.cgcloud__Account_Template__c == NULL)
                   || (accObj.TPM_Hierarchy_Level__c != TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT 
                       && accObj.TPM_Planning_Mode__c != NULL)
                   || (	  (accObj.TPM_Planning_Mode__c != NULL) 
                       && (salesOrgToTemplateMap.get((accObj.TPM_Planning_Mode__c + accObj.cgcloud__Sales_Org__c)) != accObj.cgcloud__Account_Template__c)
                       && (accObj.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT)) ){
                       
                       // Mark Active Flag as False
                       accObj.TPM_IsActive__c = FALSE;
                       accountDeactivationListToUpdate.add(accObj);
                   }
            }
        }
        
        // Invoke updateCustomerDeactivation
        updateCustomerDeactivation(accountDeactivationListToUpdate);
        
    }
	
    /************************************************************************************
    * @method         : updateCustomerDeactivation
    * @param            accountDeactivationListToUpdate
    * @description    : Method to update Active Flag as Flag for all the Accounts that 
    * 					needs to be deactivated.
    *************************************************************************************/
    public  void updateCustomerDeactivation(List<Account> accountDeactivationListToUpdate){
        
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        // If accountDeactivationListToUpdate not Empty
        if(!accountDeactivationListToUpdate.isEmpty()){
			// To update the account records.
            Database.SaveResult[] accountSRList = Database.update(accountDeactivationListToUpdate,false); 
            Integer count = 0;
            
            for(Database.SaveResult actSR : accountSRList){
                
                if(!actSR.isSuccess()){ 
					//Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(actSR.getErrors(),TPM_ConstantsUtility.BATCH_PARENT_ACCOUNT_AUTOMATION,accountDeactivationListToUpdate[count].Id);

                    //Call the TPM_Utils.prepareBatchLogger
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
                }
                count++;
            }
        }
        
        if(!logWrapperList.isEmpty()){
			// To log the batch errors. 
            TPM_LoggerException.log(logWrapperList);
        }
    }
    
    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method.
    *************************************************************************************/
    public void finish(Database.BatchableContext bc) {
        
        //Check for Batch Sequencing
        if(System.Label.isAssortmentBatchSequenced.equals(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){
            
            Integer batchSize = TPM_ConstantsUtility.NUMBER_200;
            //Get the Batch Size from CMDT TPM_QueryDefinition__mdt
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_ASSORTMENT_CREATION);
            
            if(String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            // If Batch is Sequenced, 
            // Call Assortment Creation Batch
            Database.executeBatch(new TPM_AssortmentCreationBatch(), batchSize);
            
        } 
        
    }
}