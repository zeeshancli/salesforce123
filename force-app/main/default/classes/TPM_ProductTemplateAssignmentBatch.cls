/*******************************************************************************************************
* @Name          TPM_ProductTemplateAssignmentBatch
* @Test Class    TPM_ProductTemplateAssignmentBatchTest
* @Author        PwC Team
* @date          December 7, 2022
* @description   Batch Apex is used for product template assignment to product records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public class TPM_ProductTemplateAssignmentBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    Map<String,String> salesOrgPTMap = new Map<String,String>();
    Set<String> invalidSalesOrgSet = new Set<String>();
    List<TPM_LoggerException.LogsWrapper> invalidWrapperList = new List<TPM_LoggerException.LogsWrapper>();

    /*************************************************************************************
     @method			 TPM_ProductTemplateAssignmentBatch
     @description    	 Constructor for the batch class to get all Product Template List
     					 with Active = TRUE and has Sales Org assigned.
    **************************************************************************************/
    public TPM_ProductTemplateAssignmentBatch(){
        
        //Get all the Product Template Records with Active as True and Store the Recent Templates into Map
        //Create a Map to Store 
        //SalesOrg+RecordType.DeveloperName of the Product Template and Product Template Record Id
        for(cgcloud__Product_Template__c prodTemp : [SELECT Id, 
                                                     		Name, 
                                                     		RecordType.DeveloperName, 
                                                     		cgcloud__Sales_Org__c 
                                                     FROM   cgcloud__Product_Template__c 
                                                     WHERE  cgcloud__Active__c = TRUE 
                                                     AND 	cgcloud__Sales_Org__c != NULL
                                                     ORDER BY CreatedDate DESC]){
                                                         
            if(!salesOrgPTMap.containsKey((prodTemp.cgcloud__Sales_Org__c+prodTemp.RecordType.DeveloperName))){
                salesOrgPTMap.put((prodTemp.cgcloud__Sales_Org__c+prodTemp.RecordType.DeveloperName),prodTemp.Id);
            } 
        }
    }
    
    /*************************************************************************************
     @method			 Batch Start Method
     @return     		 Database.QueryLocator
     @param     		 bc
     @description    	 Returns all the Product Records with Empty Template 
    **************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        /* Get all the list of Product Records with Empty Product Template*/
        String query = 'SELECT Id, Name,cgcloud__Consumer_Goods_External_Product_Id__c, cgcloud__Product_Level__c, TPM_SAP_Sales_Org__c, cgcloud__Product_Template__c, RecordType.DeveloperName FROM Product2 WHERE cgcloud__Product_Template__c=NULL AND TPM_SAP_Sales_Org__c!=NULL';
        return Database.getQueryLocator(query);
    }
    
    /******************************************************************************************************
     @method			 Batch execute Method
     @param     		 bc
     @param     		 productList
     @description    	 Assigns Product with Matching Product Template based on the Product & Product Template 
     				  	 Record Type, Sales Org Value  
    ******************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Product2> productList) {
        
        List<Product2> productToUpdateList = new List<Product2>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
       
        //Iterate over all the Products
        for(Product2 prod : productList){            
            //Check if current products record's sales org & record type matches with the values with Product template record
            if(salesOrgPTMap.containsKey((prod.TPM_SAP_Sales_Org__c+prod.RecordType.DeveloperName))){
                prod.cgcloud__Product_Template__c = salesOrgPTMap.get((prod.TPM_SAP_Sales_Org__c+prod.RecordType.DeveloperName));
                productToUpdateList.add(prod);
            }
            
            //If no Product Template is assigned for the Product Record,Add the Sales Org Value to store it in the Logger Record
            else{
                invalidSalesOrgSet.add(prod.TPM_SAP_Sales_Org__c);
            }
        }
        
        //Call the handleUpdate method to update the valid product records product template records
        //If any exception occurs during database.update then add those records in the logger records
        exceptionWrapperList.addAll(handleUpdate(productToUpdateList)); 
        
        //Call the TPM_LoggerException to save the logger records
        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
    /******************************************************************************************
     @method			 finish
     @param			     bc
     @description		 Batch finish method to store details of the product records that doesnt
     					 have template assigned after execution.
    ******************************************************************************************/  
    public void finish(Database.BatchableContext bc) {
        
        //Iterate over the unique invalid sales org set   
        for(String salesOrg : invalidSalesOrgSet){

            //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
            TPM_Utils.LogParamWrapper logObj = new TPM_Utils.LogParamWrapper();
            logObj.errorList = NULL;
            logObj.expErrorMessage = salesOrg+ ' ' +TPM_ConstantsUtility.CUST_ERROR;
            logObj.expClassName = TPM_ConstantsUtility.BATCH_PRODUCT_TEMP_ASSIGNMENT;
            logObj.expRecordId = NULL;
            logObj.expRecordName = salesOrg;
            logObj.expLogLevel = TPM_ConstantsUtility.ERROR; 

            //Call the TPM_Utils.prepareBatchLogger
            invalidWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
        }
        //Call the TPM_LoggerException to save the logger records
        if(!invalidWrapperList.isEmpty()){
            TPM_LoggerException.log(invalidWrapperList);
        }

        // PBI-163 : Sequencing the product hierarchy creation batch.
        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;

        // To check for batch sequencing.
        if(System.Label.TPM_IsProductTemplateSequencedWithHierarchy.equalsIgnoreCase(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){

            // To fetch the batch size from TPM_QueryDefinition__mdt record.
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION);

            if(batchQueryMdt != null && String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            TPM_ProductHierarchyCreationBatch prodHierarchyCreationBatch = new TPM_ProductHierarchyCreationBatch(null); 
            
            // Call the batch class to execute.
            Database.executeBatch(prodHierarchyCreationBatch, batchSize);
        }

    }
    
    /******************************************************************************************
     @method			 handleUpdate
     @return			 List<TPM_LoggerException.LogsWrapper>
     @param			     productToUpdateList
     @description		 To handle any Exceptions during Database.Update for valid Product
     					 Records
    ******************************************************************************************/ 
    public List<TPM_LoggerException.LogsWrapper> handleUpdate(List<Product2> productToUpdateList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        if(!productToUpdateList.isEmpty()){
            Integer index = 0;
            
            //Update the Product Records with the Product Template
            Database.SaveResult[] updatedProductSRList = Database.update(productToUpdateList,false);
            
            //Iterate over the Updated Product Records
            for(Database.SaveResult result : updatedProductSRList) {
                if(!result.isSuccess()){
                    
                    //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(result.getErrors(),TPM_ConstantsUtility.BATCH_PRODUCT_TEMP_ASSIGNMENT,productToUpdateList[index].Id);

                    //Call the TPM_Utils.prepareBatchLogger
                    exceptionWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
                }
            }
            index += 1;
        }
        return exceptionWrapperList;
    }
    
}