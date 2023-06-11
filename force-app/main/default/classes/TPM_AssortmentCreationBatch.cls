/******************************************************************************************************
@Name            TPM_AssortmentCreationBatch
@testclass       TPM_AssortmentCreationBatchTest
@Author          PwC Team
@date            February 1, 2023
@description     Batch apex to create assortments and store assortments .
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_AssortmentCreationBatch implements Database.Batchable<Sobject> {
    
    
    /**************************************************************************************
	* @method         : TPM_AssortmentCreationBatch
	* @description    : Constructor for the batch class
	**************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public TPM_AssortmentCreationBatch(){
        
    }
    
    /*********************************************************************************
	@method          start
	@param           bc
	@return          Database.QueryLocator
	@description     Batch start method to fetch all active accounts after they have been made active
	**********************************************************************************/
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = '';
        //Query Accounts WHERE 
        //SalesOrg != NULL AND TPM_Is_Assortment_Created__c = FALSE AND cgcloud__ExternalId__c != null
        // preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_ASSORTMENT_CREATION]){
                                                      
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
	@param            accountList
	@description      Execute method to create assortment object and store assortment object records for the accounts.
	********************************************************************************************************/
    
    public void execute(Database.BatchableContext bc, List<Account> accountList){
        
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        List<cgcloud__Product_Assortment_Product_Share__c> productCategoryToCreateList = new List<cgcloud__Product_Assortment_Product_Share__c>();
        Map<String, Set<Id>> topNodeForSalesOrgMap = TPM_AssortmentCreationHelper.loadTopNodeForSalesOrg();
        Map<Id, String> accountToSalesOrgMap = new Map<Id,String>();
        
        //preparing a map of assortmentObjects to be created for each account:
        Map<Id,Assortment> accountToAssortmentMap = TPM_AssortmentCreationHelper.prepareAssortmentRecords(accountList);
        
        //creating a map of account and its salesorg value:
        for(Account accObj : accountList){
            accountToSalesOrgMap.put(accObj.id,accObj.cgcloud__Sales_Org__c);
        }
        
        //inserting and logging error(if any), for assortment objects:
        if(!accountToAssortmentMap.isEmpty()){
            String objectName = TPM_ConstantsUtility.OBJECT_ASSORTMENT;
            logWrapperList.addAll(TPM_AssortmentCreationHelper.insertingAndLoggingError(accountToAssortmentMap.values(), ObjectName, accountToAssortmentMap));
            
        }
        
        //checking if the assortment records are created then prepare records to be inserted for related objects:
        if(TPM_Utils.isSuccessAssortment){
            
            //looping through the map of account id and assortment objects, created for creating assortment objects:
            for(Id accountid :accountToAssortmentMap.keyset()){
                
                Assortment assortmentObj = accountToAssortmentMap.get(accountid);
                 
                productCategoryToCreateList.addAll(TPM_AssortmentCreationHelperExtension.prepareForCategoryAssortmentHeaders(accountToSalesOrgMap, accountid, assortmentObj, topNodeForSalesOrgMap));
            	
            }
        }
        
        
        TPM_AssortmentCreationHelper.handleRelatedAssortmentHeader(productCategoryToCreateList, logWrapperList, accountToAssortmentMap);
        
        if(!logWrapperList.isEmpty()){
            
            // To log the batch errors.
             TPM_LoggerException.log(logWrapperList);
        }
    }
    
    
    /************************************************************************************
	@method          finish
	@param           bc
	@description     Batch finish method to perform completion steps.
	*************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc){
        
    }
    
    
    
}