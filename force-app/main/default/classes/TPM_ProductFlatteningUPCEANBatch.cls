/******************************************************************************************************
* @Name         : TPM_ProductFlatteningUPCEANBatch
* @Test Class   : TPM_ProductFlatteningCategoryBatchTest
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Batch Apex is used to update product hierarchy lookups on product record 
                  where product level is UPC/EAN.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_ProductFlatteningUPCEANBatch implements Database.Batchable<sObject> {
    

    // To store start query string
    String startQuery;

    // To store UPC/EAN product record ids which are passed from batch run command.
    Set<Id> objectIdSet;


    /*************************************************************************************
    * @method         : TPM_ProductFlatteningUPCEANBatch
    * @param            prdUpcEANIdSet
    * @description    : Parameterized constructor for the batch class to pass 
                        specific UPC/EAN product record ids set
    **************************************************************************************/
    public TPM_ProductFlatteningUPCEANBatch(Set<Id> prdUpcEANIdSet){

        objectIdSet = prdUpcEANIdSet;

        // To fetch the start query from CMT object - TPM_QueryDefinition__mdt record.
        startQuery = TPM_ProductFlatteningUtils.prepareBatchStartQuery(TPM_ConstantsUtility.BATCH_PRD_FLATTENING_UPCEAN, objectIdSet);
    }


    /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the product records.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){

        // To collect the UPC/EAN product records & to pass to the interface method execute.
        return Database.getQueryLocator(startQuery);
    }

    
    /********************************************************************************************************
    * @method         : execute
    * @param            bc
    * @param            prodScopeList
    * @description    : Execute method to process UPC/EAN product records to update hierarchy lookups.
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Product2> prodScopeList){

        try {

            // To fetch product hierarchy records based on product scope.
            Map<String, cgcloud__Product_Hierarchy__c> childIdWithPHObjectMap = TPM_ProductFlatteningUtils.fetchProductHierarchyDetails(prodScopeList);

            // To prepare product records for update DML operation.
            List<Product2> productsToUpdateList = TPM_ProductFlatteningUPCEANBatchHelper.prepareProductsForDMLOperation(prodScopeList, childIdWithPHObjectMap);

            // To perform update DML operations for product records.
            List<TPM_LoggerException.LogsWrapper> logWrapperList = TPM_ProductFlatteningUtils.performDMLOperation(productsToUpdateList, TPM_ConstantsUtility.BATCH_PRD_FLATTENING_UPCEAN);

            // To log the errors.
            if(!logWrapperList.isEmpty()){
                TPM_LoggerException.log(logWrapperList);
            }
            
        } catch(Exception ex){

            // To log exception.
            TPM_Utils.createException(ex, 
                                      TPM_ConstantsUtility.FATAL, 
                                      TPM_ConstantsUtility.BATCH_PRD_FLATTENING_UPCEAN);
        }
    }


    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to execute post-processing action.
    *************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc){
        
    }

}