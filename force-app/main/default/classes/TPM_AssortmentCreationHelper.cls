/******************************************************************************************************
@Name            TPM_AssortmentCreationHelper
@testclass       TPM_AssortmentCreationBatchTest
@Author          PwC Team
@date            January 12, 2023
@description     Batch Apex helper class for  TPM_AssortmentCreationBatch business logic.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_AssortmentCreationHelper {

    /*********************************************************************************
     @description    private Constructor
    **********************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentCreationHelper(){
        
    }
    
    /*********************************************************************************
    @method          loadAssortmentTemplate
    @return          Map<String, Id>
    @description     method preparing map for sales org and assortment template
    **********************************************************************************/
    
    public static Map<String, Id> loadAssortmentTemplate(){
        
        Map<String,Id> assortmentTemplateMap = new Map<String,Id>();
        
        //preparing a map of assortment template to be used while creating assortment records for accounts:
        for(cgcloud__Product_Assortment_Template__c assortmentTemplate : [SELECT 
                                                                          Id,
                                                                          cgcloud__Sales_Org__c
                                                                          FROM cgcloud__Product_Assortment_Template__c
                                                                          WHERE cgcloud__Active__c = true 
                                                                          AND recordtype.name = : TPM_ConstantsUtility.PLANNING_ASSORTMENT_TEMPLATE_RECORDTYPE]){
                                                                              
                       assortmentTemplateMap.put(assortmentTemplate.cgcloud__Sales_Org__c,assortmentTemplate.id);                
                                                                          }
        return assortmentTemplateMap;
    }
    
    
     /*********************************************************************************
    @method          loadSalesOrgHierarchyMap
    @return          Map<String,Date>
    @description     method preparing map for sales org and hierarchy levels enabled for push promotion
    **********************************************************************************/
    public static Map<String,Date> loadSalesOrgHierarchyMap(){
        
        Map<String,Date> salesOrgHierarchyMap = new Map<String,Date>();
        
        //iterating through custom metadata to create a map storing the details of pushable hierarchy levels for a sales org:
        //key= salesorg+hierarchylevel, value = End_date
        
        for(TPM_SalesOrg_Hierarchy_For_Promotion__mdt metadataObj : TPM_SalesOrg_Hierarchy_For_Promotion__mdt.getAll().values()){
            salesorghierarchyMap.put(metadataObj.TPM_Sales_Org__c+metadataObj.TPM_Hierarchy_Level__c,metadataObj.TPM_End_Date__c);
        }
        
        return salesOrgHierarchyMap;
        
    }
    
    /*********************************************************************************
    @method          loadTopNodeForSalesOrg
    @return          Map<String,Date>
    @description     method preparing map for sales org and hierarchy levels enabled for push promotion
    **********************************************************************************/
    public static Map<String,Set<Id>> loadTopNodeForSalesOrg(){
        
        Map<String,Set<Id>> topNodeForSalesOrgMap = new Map<String,Set<Id>>();
        
        //for the creation of product assortment category records, we need to link all the top node products for a particular sales org:
        //creating a map to store the above mentioned details:
        //key= salesorg, value= set<id> of all the top node products:
        
        for(Product2 prodObj : [SELECT
                                Id,
                                cgcloud__Sales_Org__c,
                                cgcloud__Product_Level__c 
                                FROM
                                Product2 
                                WHERE
                                cgcloud__Sales_Org__c != null
                                AND cgcloud__Product_Level__c =: TPM_ConstantsUtility.TOP_NODE_PRODUCT]){
                                    
                                    if(!topNodeForSalesOrgMap.containskey(prodObj.cgcloud__Sales_Org__c)){
                                        if(prodObj.id!=null){
                                            topNodeForSalesOrgMap.put(prodObj.cgcloud__Sales_Org__c,new set<Id>());
                                        }
                                    }
                                    if(topNodeForSalesOrgMap.containskey(prodObj.cgcloud__Sales_Org__c)){
                                        topNodeForSalesOrgMap.get(prodObj.cgcloud__Sales_Org__c).add(prodObj.id);
                                    }
                                    
                                }
        
        return topNodeForSalesOrgMap;
    }

    
    /*********************************************************************************
    @method          insertingAndLoggingError
    @return          Map<String,Date>
	@param     	  	 recordsToInsert
    @param     	  	 objectName
	@param     	  	 recordToInsertMap
    @description     method to insert the received list of objects(assortment,store assortment,product assortment category) 
    **********************************************************************************/
    
    public static List<TPM_LoggerException.LogsWrapper> insertingAndLoggingError(List<sObject> recordsToInsert, 
                                                                                 String objectName, Map<Id,Sobject> recordToInsertMap){
        
        
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        Set<Id> accountIdSet = new Set<Id>();
        
        //inserting the received list of sobjects:
        Database.SaveResult[] saveResultList = Database.insert(recordsToInsert,false); 
        Integer count = 0;
        
        for (Database.SaveResult saveResultListObj : saveResultList) {
            
            if(!saveResultListObj.isSuccess()){
                  
                //checking the type of sobject passed to fetch the particular id to be logged as guid in the logger object in case of any error is encountered:
                if(objectName == TPM_ConstantsUtility.PROD_ASSORTMENT_CATEGORY){
                    
                    List<cgcloud__Product_Assortment_Product_Share__c> productCategoryList = (List<cgcloud__Product_Assortment_Product_Share__c>)recordsToInsert;
                    
                    TPM_Utils.LogParamWrapper loggerObj = TPM_Utils.createLogParamWrapper(saveResultListObj.getErrors(),
                                                                                          TPM_ConstantsUtility.BATCH_ASSORTMENT_CREATION,
                                                                                          productCategoryList[count].cgcloud__Product_Assortment__c);
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(loggerObj));
                    
                }else if(objectName == TPM_ConstantsUtility.STORE_ASSORTMENT){
                    
                    List<StoreAssortment> storeAssortmentList = (List<StoreAssortment>)recordsToInsert;
                    
                    TPM_Utils.LogParamWrapper loggerObj = TPM_Utils.createLogParamWrapper(saveResultListObj.getErrors(),
                                                                                          TPM_ConstantsUtility.BATCH_ASSORTMENT_CREATION,
                                                                                          storeAssortmentList[count].AccountId);
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(loggerObj));
                    
                  }else if(objectName == TPM_ConstantsUtility.OBJECT_ASSORTMENT){
                     
                    List<Id> accountIdList = new List<Id>(recordToInsertMap.keyset());
                    
                    TPM_Utils.LogParamWrapper loggerObj = TPM_Utils.createLogParamWrapper(saveResultListObj.getErrors(),
                                                                                          TPM_ConstantsUtility.BATCH_ASSORTMENT_CREATION,
                                                                                          accountIdList[count]);
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(loggerObj));
                    
                }
                
            }else{
                //in case no error happens:
                TPM_AssortmentCreationHelperExtension.handleInsertSuccessAssortment(objectName, recordsToInsert, count, accountIdSet);
            }
            
            count++;
            
        }
        
        return logWrapperList;
    }
    
    
    /*********************************************************************************
    @method          prepareAssortmentRecords
    @return          Map<Id,Assortment>
	@param     	  	accountList
    @description     method to prepare assortment records
    **********************************************************************************/
    public static Map<Id,Assortment> prepareAssortmentRecords(List<account> accountList){
        
        Map<Id, Assortment> accountToAssortmentMap = new Map<Id, Assortment>();
        Map<String, Date> salesOrgHierarchyMap = loadSalesOrgHierarchyMap();
        Map<String, Id> assortmentTemplateMap = loadAssortmentTemplate();
        
        //iterating through the retrieved list of accounts :
        for(Account accObj : accountList){
            
            //checking if the account's hierarchy level is allowed for the assortment header creation for the account's sales org:
            if(salesOrgHierarchyMap.containskey(accObj.cgcloud__Sales_Org__c + accObj.TPM_Hierarchy_Level__c)){
                    
                    //preparing assortment objects:
                    Assortment assortmentObj  = new  Assortment(name = TPM_ConstantsUtility.RECORD_NAME_ASSORTMENT + '-' + accObj.Name + '-' + accObj.cgcloud__Sales_Org__c,
                                                                cgcloud__Product_Assortment_Template__c = assortmentTemplateMap.get(accObj.cgcloud__Sales_Org__c),
                                                                cgcloud__Valid_From__c = System.Today(),
                                                                cgcloud__Valid_Thru__c = salesOrgHierarchyMap.get(accObj.cgcloud__Sales_Org__c + accObj.TPM_Hierarchy_Level__c));
                    
                    //making a map of account id and assortment object:
                    //this has been created so that the assortment id gets updated in the assortment object for every account:
                    //aacount id and assortment id combination is needed for child objects creation:
                    
                    accountToAssortmentMap.put(accObj.Id, assortmentObj);
                    
                } 
        }
        
        return accountToAssortmentMap;
             
    }
    /*********************************************************************************
    @method          prepareProductAssortmentRecords
    @return          List<cgcloud__Product_Assortment_Product_Share__c>
	@param     	  	topNodeForSalesOrgMap
    @param     	  	accountid
	@param     	  	assortmentId
    @param     	  	accountToSalesOrgMap
    @description     method to prepare the list of product assortment category records
    **********************************************************************************/
    public static List<cgcloud__Product_Assortment_Product_Share__c> prepareProductAssortmentRecords(Map<String,Set<Id>> topNodeForSalesOrgMap,
                                                                                                     Id accountid, Id assortmentId, 
                                                                                                     Map<Id,String> accountToSalesOrgMap){
                                                                         
        List<cgcloud__Product_Assortment_Product_Share__c> productCategoryToCreateList = new List<cgcloud__Product_Assortment_Product_Share__c>();    
        
        
        
        //checking if the salesorg is present in the map containing the sales org and top node products:
        if(topNodeForSalesOrgMap.containskey(accountToSalesOrgMap.get(accountid))){
            
            //fetching the list of top node products for the accounts salesorg for which assortment headers are being created:
            Set<Id> topeNodeProducts = topNodeForSalesOrgMap.get(accountToSalesOrgMap.get(accountid));
            
            //in case there are multiple top node products for a particular sales org:
            if(topeNodeProducts.size()>1){
                
                //iterating through the multiple products to create the product assortment category records:
                for(Id productid : topeNodeProducts){
                      
                    cgcloud__Product_Assortment_Product_Share__c productCategoryObj = new cgcloud__Product_Assortment_Product_Share__c(
                            cgcloud__Product_Assortment__c = assortmentId,
                            cgcloud__Product__c = productid);
                        
                        productCategoryToCreateList.add(productCategoryObj);
                    
                    
                 }
               }
               else{
                   
                   List<Id> productIdList = new List<Id>(topNodeForSalesOrgMap.get(accountToSalesOrgMap.get(accountid)));
                   cgcloud__Product_Assortment_Product_Share__c productCategoryObj = new cgcloud__Product_Assortment_Product_Share__c(
                       cgcloud__Product_Assortment__c = assortmentId,
                       cgcloud__Product__c = productIdList[0]);
                   
                   productCategoryToCreateList.add(productCategoryObj);
                   
                }
        }
               
      return productCategoryToCreateList;
    }
    
    /*********************************************************************************
    @method          prepareStoreAssortmentRecords
    @return          List<StoreAssortment>
	@param     	  	assortmentObj
	@param     	  	accountid
    @description     method to prepare store assortments records:
    **********************************************************************************/
    
    public static List<StoreAssortment> prepareStoreAssortmentRecords(Assortment assortmentObj, Id accountid){
        
        List<StoreAssortment> storeAssortmentToCreateList = new List<StoreAssortment>();
        
        StoreAssortment storeAssortmentobj = new StoreAssortment(EndDate=assortmentObj.cgcloud__Valid_Thru__c,
                                                                 StartDate = System.today(),
                                                                 accountid = accountid,
                                                                 AssortmentId = assortmentObj.id);
        storeAssortmentToCreateList.add(storeAssortmentobj);   
        
        
        return storeAssortmentToCreateList;
    }
    
    
        /*********************************************************************************
    @method          upsertAccountRecords
    @param     	  	accountIdSet
    @description     method to update accounts, to mark that assortment records have been created for this record : 
    **********************************************************************************/
    public static void upsertAccountRecords(Set<Id> accountIdSet){
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
             
        List<Account> accountToUpdateList = new List<Account>();
        
        //iterating through the accounts and marking the checkbox field to true:
        for(Account accObj : [SELECT
                              ID,
                              TPM_Is_Assortment_Created__c
                             FROM Account
                             WHERE Id IN :accountIdSet]){
                                 
                   accObj.TPM_Is_Assortment_Created__c = true;
                                 
                  accountToUpdateList.add(accObj);
            
        }
        
        if(!accountToUpdateList.isEmpty()){
            
            Integer count = 0;
            
            Database.saveResult[] saveResultList = Database.update(accountToUpdateList,false);
            
            for (Database.saveResult saveResultListObj : saveResultList) {
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = accountToUpdateList[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.BATCH_ASSORTMENT_HELPER;
                    logWrapperObj.methodName=TPM_ConstantsUtility.UPDATE_ACCOUNT_RECORDS;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
            
                count++;
            }
            
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
	  /*********************************************************************************
    @method          handleRelatedAssortmentHeader
    @param     	  	productCategoryToCreateList
	@param     	  	logWrapperList
	@param     	  	accountToAssortmentMap
    @description     method to prepare and insert child assortment records.
    **********************************************************************************/
    public static void handleRelatedAssortmentHeader(List<cgcloud__Product_Assortment_Product_Share__c> productCategoryToCreateList,
                                                     List<TPM_LoggerException.LogsWrapper> logWrapperList,
                                                     Map<Id,Assortment> accountToAssortmentMap){
         
        List<StoreAssortment> storeAssortmentToCreateList = new List<StoreAssortment>();                                                 
                                                         
          if(!productCategoryToCreateList.isEmpty()){
            
            //inserting and logging error(if any), product assortment category records :
            String objectName = TPM_ConstantsUtility.PROD_ASSORTMENT_CATEGORY;
            
            logWrapperList.addAll(TPM_AssortmentCreationHelper.insertingAndLoggingError(productCategoryToCreateList, ObjectName, null));
        
          }
         
          if(TPM_Utils.isSuccessProductAssortment){
            
            for(Id accountid :accountToAssortmentMap.keyset()){
                  
                Assortment assortmentObj = accountToAssortmentMap.get(accountid);
               
                if(assortmentObj.id!=null && TPM_Utils.mapForCategoryAssortment.containskey(assortmentObj.id) && TPM_Utils.mapForCategoryAssortment.get(assortmentObj.id) ){
                      
                    storeAssortmentToCreateList.addAll(TPM_AssortmentCreationHelper.prepareStoreAssortmentRecords(assortmentObj, accountid));
                         
                      
                }
          	}
        }
          
         if(!storeAssortmentToCreateList.isEmpty()){
            
            TPM_AssortmentCreationHelperExtension.handleInsertStoreAssortment(storeAssortmentToCreateList, logWrapperList);
            
        }
        
        if(!TPM_Utils.accountIdSet.isEmpty()){
            
            //calling method to update account records:
            TPM_AssortmentCreationHelper.upsertAccountRecords(TPM_Utils.accountIdSet);
        
        }
     }
    
}