/******************************************************************************************************
* @Name         : TPM_ParentAccountBatch
* @Test Class   : TPM_ParentAccountBatchTest
* @author       : PwC Team
* @date         : Feb 09, 2022
* @description  : Batch Apex is used for parent Id field assignment to account records and updating customer extension records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public class TPM_ParentAccountBatch implements Database.Batchable<sObject> {
    
    Map<String,String> salesOrgHierarchyPlanMap = new Map<String,String>();
    Map<String,Date> salesOrgHierarchyPlanEndDate = new Map<String,Date>();

    /**************************************************************************************
    * @method         : TPM_ParentAccountBatch
    * @description    : Constructor for the batch class
    **************************************************************************************/
    
    public TPM_ParentAccountBatch(){

    //Fetch metadata records for Customer extension creation
    
        for(TPM_SalesOrg_Hierarchy_For_Promotion__mdt metadataObj : TPM_SalesOrg_Hierarchy_For_Promotion__mdt.getAll().values()){
            
            //Map of sales org and heirarchy level as key and plan type as value
            salesOrgHierarchyPlanMap.put(metadataObj.TPM_Sales_Org__c+metadataObj.TPM_Hierarchy_Level__c,metadataObj.TPM_Account_Plan_Type__c);
             //Map of sales org and heirarchy level as key and End date as value
            salesOrgHierarchyPlanEndDate.put(metadataObj.TPM_Sales_Org__c+metadataObj.TPM_Hierarchy_Level__c,metadataObj.TPM_End_Date__c);
        }
            
    }
    
     /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the account records with 
    * 					parentId = NULL.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = '';
        //Query Accounts WHERE 
        //Customer Template != NULL AND Accounts with only Customer Record Type AND No of Customer Extension > 0
        //Preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_PARENT_ACCOUNT_AUTOMATION]){
                                                      
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
    * @description    : execute method to process account records for parentId field assignment
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        
        Map<Id,Id> childAccToParentAccIdMap = new Map<Id,Id>();
        Set<Id> totalSalesOrgIdSet = new Set<Id>();
        Set<Id> totalSalesOrgLevelAccIdSet = new Set<Id>();
        Set<Id> nonTotalSalesOrgLevelAccIdSet = new Set<Id>();
        
        for(Account acc : accountList){
            if(acc.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.TOTAL_SALES_ORG){
                totalSalesOrgLevelAccIdSet.add(acc.Id);
            }else{
                nonTotalSalesOrgLevelAccIdSet.add(acc.Id);
            }
        }
        
        //Get the Valid Customer Trade Org Hierarchy records 
        //WHERE Today's date falls between Valid from and Valid thru 
        List<cgcloud__Account_Trade_Org_Hierarchy__c> custTradeOrgList = [SELECT Id, 
                                                                                 cgcloud__Parent_Account__c, 
                                                                          		 cgcloud__Parent_Account__r.TPM_Hierarchy_Level__c,
                                                                                 cgcloud__Child_Account__c, 
                                                                              	 cgcloud__Valid_From__c, 
                                                                              	 cgcloud__Valid_Thru__c 
                                                                          FROM 	 cgcloud__Account_Trade_Org_Hierarchy__c 
                                                                          WHERE  cgcloud__Valid_From__c <= TODAY 
                                                                          AND 	 cgcloud__Valid_Thru__c >= TODAY
                                                                          AND 	 (cgcloud__Child_Account__c IN: nonTotalSalesOrgLevelAccIdSet 
                                                                          OR      cgcloud__Parent_Account__c IN: totalSalesOrgLevelAccIdSet)];
        
        if( !custTradeOrgList.isEmpty() ){
            
           //Iterate over CTO Records
            for(cgcloud__Account_Trade_Org_Hierarchy__c cto : custTradeOrgList ){
                //Check If current CTO Record has parentid whose hierarchy level = Total Sales Org and has child account
                if(cto.cgcloud__Parent_Account__r.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.TOTAL_SALES_ORG){
                    totalSalesOrgIdSet.add(cto.cgcloud__Parent_Account__c);
                }
                //Create a Map of ChildId,ParentId from Customer Trade Org Hierarchy
                childAccToParentAccIdMap.put(cto.cgcloud__Child_Account__c,cto.cgcloud__Parent_Account__c);
            }
            
            //checkValidCTORecords method to assign parentId field
        	checkValidCTORecords(accountList,childAccToParentAccIdMap,totalSalesOrgIdSet);
        }  
    }
    
    /************************************************************************************
    * @method         : checkValidCTORecords
    * @param            accountList
    * @param			childAccToParentAccIdMap
    * @param			totalSalesOrgIdSet
    * @description    : Method to assign parentId field from valid customer trade org
    * 					hierarchy to parentId field on Account record.
    *************************************************************************************/
    public void checkValidCTORecords(List<Account> accountList,Map<Id,Id> childAccToParentAccIdMap,Set<Id> totalSalesOrgIdSet){
        
        List<Account> accountsToUpdateList = new List<Account>();
        
        //Iterate over the Accounts
        for(Account acc : accountList){
            //If Valid customer trade org hierarchy record exists
            if(childAccToParentAccIdMap.containsKey(acc.Id)){
                    acc.parentId = childAccToParentAccIdMap.get(acc.Id);
                    acc.TPM_IsActive__c = True;
                    accountsToUpdateList.add(acc);
            //Check if the current account is at Hierarchy level = 'Total Sales Org'
            //And has child account record
            }else if(totalSalesOrgIdSet.contains(acc.Id) && acc.TPM_IsActive__c != True){
                acc.TPM_IsActive__c = True;
                accountsToUpdateList.add(acc);  
            }
            else {
                //If assigned parentId field on 
                //account record is expired
                if(String.IsNotBlank(acc.ParentId)){
                    acc.parentId = null;
                    accountsToUpdateList.add(acc);
                }
            }    
        }
        //handleAccountUpdate to update parentId field
        handleAccountCustomerExtensionUpdate(accountsToUpdateList);
        //create customer extension
        updateCustomerExtensionRec(accountList);
    }
    
    /************************************************************************************
    * @method         : handleAccountCustomerExtensionUpdate
    * @param            accountsCustomerExtensionToUpdateList
    * @description    : Method to update account and customer extension records
    *************************************************************************************/
    public void handleAccountCustomerExtensionUpdate(List<SObject> accountsCustomerExtensionToUpdateList){
        
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        if(!accountsCustomerExtensionToUpdateList.isEmpty()){
			// To update the account records.
            Database.SaveResult[] accountSRList = Database.update(accountsCustomerExtensionToUpdateList,false); 
            Integer count = 0;
            
            for(Database.SaveResult actSR : accountSRList){
                
                if(!actSR.isSuccess()){ 
					//Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(actSR.getErrors(),TPM_ConstantsUtility.BATCH_PARENT_ACCOUNT_AUTOMATION,accountsCustomerExtensionToUpdateList[count].Id);

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
    * @method         : updateCustomerExtensionRec
    * @param            accountList
    * @description    : Method to fetch customer extension and update valid from and
                        valid through and pla type from metadata
    *************************************************************************************/
            public void updateCustomerExtensionRec(List<Account> accountList){
     
            List<cgcloud__Account_Extension__c> customerExtensionsList = new List<cgcloud__Account_Extension__c>();
            
            //Fetch Customer extension records
            for(cgcloud__Account_Extension__c custoExt : [SELECT id,
                                                            Name,
                                                            cgcloud__Account__r.TPM_IsActive__c,
                                                            cgcloud__Account__r.CreatedDate,
                                                            cgcloud__Account__r.TPM_Hierarchy_Level__c,
                                                            cgcloud__Account__r.cgcloud__Sales_Org__c
                                                            FROM cgcloud__Account_Extension__c
                                                            WHERE  cgcloud__Account__c IN:accountList
                                                            AND cgcloud__Account__r.TPM_IsActive__c = TRUE
                                                            AND cgcloud__Bill_To_Role_Valid_From__c=null
                                                            AND cgcloud__Bill_To_Role_Valid_Thru__c=null]){
              
            //First condition to check if metadata contains sales org and heirarchy level combination for the extension record being updated                                             

             if(salesOrgHierarchyPlanMap.containsKey(custoExt.cgcloud__Account__r.cgcloud__Sales_Org__c+custoExt.cgcloud__Account__r.TPM_Hierarchy_Level__c)){
                if(salesOrgHierarchyPlanMap.containsKey(custoExt.cgcloud__Account__r.cgcloud__Sales_Org__c+custoExt.cgcloud__Account__r.TPM_Hierarchy_Level__c)){
                    custoExt.cgcloud__Account_Plan_Type__c = salesOrgHierarchyPlanMap.get(custoExt.cgcloud__Account__r.cgcloud__Sales_Org__c+custoExt.cgcloud__Account__r.TPM_Hierarchy_Level__c);
                }
                // Added Promo Role Start Date as : 01 - Jan - Account Created Date Year 
                custoExt.cgcloud__Promotion_Valid_From__c = Date.newInstance(Date.valueOf(custoExt.cgcloud__Account__r.CreatedDate).year(), 01, 01);
                custoExt.cgcloud__Promotion_Valid_Thru__c = salesOrgHierarchyPlanEndDate.get(custoExt.cgcloud__Account__r.cgcloud__Sales_Org__c+custoExt.cgcloud__Account__r.TPM_Hierarchy_Level__c); 
                customerExtensionsList.add(custoExt);
             }   
            }

            //Update customer extension records
            handleAccountCustomerExtensionUpdate(customerExtensionsList);
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
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY);
            
            if(String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            // If Batch is Sequenced, 
            // Call Customer Deactivation Batch
            Database.executeBatch(new TPM_CustomerDeactivationBatch(), batchSize);
            
        } 
        
    }
    
}