/******************************************************************************************************
* @Name         : TPM_ProductFlatteningPackSizeBatch
* @Test Class   : TPM_ProductFlatteningCategoryBatchTest
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Batch Apex is used to update product hierarchy lookups on product record 
                  where product level is Pack Size.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_ProductFlatteningPackSizeBatch implements Database.Batchable<sObject> {
    

    // To store start query string
    String startQuery;

    // To store pack size product record ids which are passed from batch run command.
    Set<Id> objectIdSet;


    /*************************************************************************************
    * @method         : TPM_ProductFlatteningPackSizeBatch
    * @param            prdPackSizeIdSet
    * @description    : Parameterized constructor for the batch class to pass 
                        specific Pack Size product record ids set
    **************************************************************************************/
    public TPM_ProductFlatteningPackSizeBatch(Set<Id> prdPackSizeIdSet){

        objectIdSet = prdPackSizeIdSet;

        // To fetch the start query from CMT object - TPM_QueryDefinition__mdt record.
        startQuery = TPM_ProductFlatteningUtils.prepareBatchStartQuery(TPM_ConstantsUtility.BATCH_PRD_FLATTENING_PACKSIZE, objectIdSet);
    }


    /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the product records.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){

        // To collect the pack size project records & to pass to the interface method execute.
        return Database.getQueryLocator(startQuery);
    }


    /********************************************************************************************************
    * @method         : execute
    * @param            bc
    * @param            prodScopeList
    * @description    : Execute method to process Pack Size product records to update hierarchy lookups.
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Product2> prodScopeList){

        try {          

            // To fetch product hierarchy records based on product scope.
            Map<String, cgcloud__Product_Hierarchy__c> childIdWithPHObjectMap = TPM_ProductFlatteningUtils.fetchProductHierarchyDetails(prodScopeList);

            // To prepare product records for update DML operation.
            List<Product2> productsToUpdateList = TPM_ProductFlatteningPackSizeBatchHelper.prepareProductsForDMLOperation(prodScopeList, childIdWithPHObjectMap);

            // To perform update DML operations for product records.
            List<TPM_LoggerException.LogsWrapper> logWrapperList = TPM_ProductFlatteningUtils.performDMLOperation(productsToUpdateList, TPM_ConstantsUtility.BATCH_PRD_FLATTENING_PACKSIZE);            

            // To log the errors.
            if(!logWrapperList.isEmpty()){         
                TPM_LoggerException.log(logWrapperList);
            }

        } catch(Exception ex){

            // To log exception.
            TPM_Utils.createException(ex, 
                                      TPM_ConstantsUtility.FATAL, 
                                      TPM_ConstantsUtility.BATCH_PRD_FLATTENING_PACKSIZE);
        }

    }


    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to execute post-processing action.
    *************************************************************************************/
    public void finish(Database.BatchableContext bc){

        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;

        // To check for batch sequencing.
        if(System.Label.TPM_IsProductFlatteningSequenced.equalsIgnoreCase(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){

            // To fetch the batch size from TPM_QueryDefinition__mdt record.
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_PRD_FLATTENING_UPCEAN);

            if(batchQueryMdt != null && String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            TPM_ProductFlatteningUPCEANBatch prodFlatteningUPCEANDTBatch = new TPM_ProductFlatteningUPCEANBatch(null); 
            
            // Call the batch class to execute.
            Database.executeBatch(prodFlatteningUPCEANDTBatch, batchSize); 
        }  
    }

}