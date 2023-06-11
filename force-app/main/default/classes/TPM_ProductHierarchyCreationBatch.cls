/******************************************************************************************************
* @Name         : TPM_ProductHierarchyCreationBatch
* @Test Class   : TPM_ProductHierarchyCreationBatchTest
* @author       : PwC Team
* @date         : January 18, 2023
* @description  : Batch Apex is used for product hierarchy record creation from staging object.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_ProductHierarchyCreationBatch implements Database.Batchable<SObject> {

    // To store product external id as key and product details.
    Map<String, Product2> prdExtIdToProductMap;

    // To store product hierarchy staging record ids which are passed from batch run command.
    Set<Id> prdHSRecordIdSet;

    // To store product hierachy staging id as key & related product hierarchy record as value.
    Map<String, cgcloud__Product_Hierarchy__c> prdHierarchyExtIdToRecordMap;

    // To store start query string
    String startQuery;

    // Map to store product hierarchy staging ids & related convert status.
    Map<String, String> prdHSIdToStatusMap;

    // To store field mapping for product hierarchy record creation.
    Map<String, TPM_FieldsMapping__mdt> prodHSFieldToRecordMap;

    // List to store error/exception log records.
    List<TPM_LoggerException.LogsWrapper> logWrapperList;

    // To store product level vs rank to check integrity of parent-child hierarchy.
    Map<String, Decimal> levelToRankMap;

    // Map to store product hierarchy staging ids & related error message.
    Map<String, String> prdHSIdToErrorMap;

    // Set to store product hierarchy staging having same child and status as new.
    Set<String> existingPHSSameChidlIdSet;

    // To store product hierachy staging's child  ext id as key & related existing product hierarchy record map as value.
    Map<String, Map<String, cgcloud__Product_Hierarchy__c>> childExIdToPHSIdWithProdHierarchyMap;

    // To store product hierachy staging's child  ext id as key & related existing product hierarchy staging record map as value.
    Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>> childExIdToPHSIdWithPHSRecordMap;


    /*************************************************************************************
    * @method         : TPM_ProductHierarchyCreationBatch
    * @param            phsIDSet
    * @description    : Parameterized constructor for the batch class to pass 
                        specific staging record ids set
    **************************************************************************************/
    public TPM_ProductHierarchyCreationBatch(Set<Id> phsIDSet) {

        prdHSRecordIdSet = phsIDSet;

        // To fetch the start query from CMT object - TPM_QueryDefinition__mdt record.
        startQuery = TPM_ProductHierarchyCreationBatchHelper.prepareBatchStartQuery(prdHSRecordIdSet);

        // To fetch the product level vs rank mapping from CMT object - TPM_CustomMappings__mdt record.
        levelToRankMap = TPM_ProductHierarchyCreationBatchHelper.prepareProductLevelMapping();

        // To fetch the product hierarchy vs staging fields mapping from CMT object - TPM_FieldsMapping__mdt record.
        prodHSFieldToRecordMap = TPM_ProductHierarchyCreationBatchHelper.fetchProdHSMapping();

    }


    /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the PHS records.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){

        // To collect the PHS records & to pass to the interface method execute.
        return Database.getQueryLocator(startQuery);

    }


    /********************************************************************************************************
    * @method         : execute
    * @param            bc
    * @param            prodStagingList
    * @description    : Execute method to process staging records for product hierarchy record creation.
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<TPM_Product_Hierarchy_Staging__c> prodStagingList){

        prdHSIdToErrorMap = new Map<String, String>();
        prdHSIdToStatusMap = new Map<String, String>();
        prdExtIdToProductMap = new Map<String, Product2>();
        existingPHSSameChidlIdSet = new Set<String>();
        logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        prdHierarchyExtIdToRecordMap = new Map<String, cgcloud__Product_Hierarchy__c>();
        childExIdToPHSIdWithProdHierarchyMap = new Map<String, Map<String, cgcloud__Product_Hierarchy__c>>();
        childExIdToPHSIdWithPHSRecordMap = new Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>>();
        
        // To store the parent product & child product external ids from PHS records.
        Set<String> prdExtIdSet = new Set<String>();

        // To store only child product external ids from PHS records.
        Set<String> phsChildExtIdSet = new Set<String>();
        
        for(TPM_Product_Hierarchy_Staging__c prdHSObj : prodStagingList){

            if(String.isNotBlank(prdHSObj.TPM_Parnt_Prod_ID__c)){
                prdExtIdSet.add(prdHSObj.TPM_Parnt_Prod_ID__c);              
            }

            if(String.isNotBlank(prdHSObj.TPM_Child_Prod_ID__c)){
                prdExtIdSet.add(prdHSObj.TPM_Child_Prod_ID__c);
                phsChildExtIdSet.add(prdHSObj.TPM_Child_Prod_ID__c);
            }
        }

        try {

            // To fetch product records based on PHS record's child and parent product external ids.
            prdExtIdToProductMap = TPM_ProductHierarchyCreationBatchHelper.fetchProductDetails(prdExtIdSet);

            // To fetch existing product hierarchy records using child product external ids.
            childExIdToPHSIdWithProdHierarchyMap = TPM_ProductHierarchyCreationBatchUtils.fetchProductHierarchyDetail(phsChildExtIdSet);

            // To fetch existing product hierarchy staging records records using child product external ids.
            childExIdToPHSIdWithPHSRecordMap = TPM_ProductHierarchyCreationBatchUtils.fetchProdHierarchyStageDetail(phsChildExtIdSet);
            
            // Call to helper method.
            processExexuteHelper(prodStagingList);

            // To create PH records and update PHS records.
            createProductHierachyRecords(prdHierarchyExtIdToRecordMap);

            // To update PHS records with appropriate status
            TPM_ProductHierarchyCreationBatchHelper.updatePHSConvertStatus(prdHSIdToStatusMap);

            if(!logWrapperList.isEmpty()){

                // To log the errors. 
                TPM_LoggerException.log(logWrapperList);
            }

        } catch(Exception ex){

            // To log exception.
            TPM_Utils.createException(ex, 
                                      TPM_ConstantsUtility.FATAL, 
                                      TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION);

        }

    }


    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to execute post-processing action.
    *************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc){

        // To seqence next batch.
        TPM_ProductHierarchyCreationBatchUtils.sequenceNextBatch();   
    }


    /************************************************************************************
    * @method         : processExexuteHelper
    * @param            prodStagingList
    * @description    : Helper execute method to process PHS records.
    *************************************************************************************/
    public void processExexuteHelper(List<TPM_Product_Hierarchy_Staging__c> prodStagingList){

        // Loop through PHS records to validate and prepare PH records for DML operation.
        for(TPM_Product_Hierarchy_Staging__c prdHSObj : prodStagingList){

            if(isValidateForHierarchyCreation(prdHSObj) && !isTimeFrameOverlapAtPHS(prdHSObj) && !isTimeFrameOverlapAtPHObj(prdHSObj)){

                cgcloud__Product_Hierarchy__c prdHierarchyObj = TPM_ProductHierarchyCreationBatchUtils.preparePHRecordForDML(prdHSObj, prodHSFieldToRecordMap, prdExtIdToProductMap);
                prdHierarchyExtIdToRecordMap.put(prdHSObj.Id, prdHierarchyObj);

            }else{

                // create an instance of wrapper class of TPM_Utils.LogParamWrapper
                TPM_Utils.LogParamWrapper logObj = new TPM_Utils.LogParamWrapper();
                logObj.errorList = null;
                logObj.expErrorMessage = prdHSIdToErrorMap.get(prdHSObj.Id);
                logObj.expClassName = TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION;
                logObj.expRecordId = prdHSObj.Id;
                logObj.expRecordName = '';
                logObj.expLogLevel = TPM_ConstantsUtility.ERROR;

                //Call the TPM_Utils.prepareBatchLogger
                logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj)); 
            }
        }
        
    }


    /*****************************************************************************************
    * @method         : createProductHierachyRecords
    * @param            prdHierarchyExtIdToRecordMap
    * @description    : Perform PH DML operation & prepare the PHS srecords for status update
    ******************************************************************************************/
    public void createProductHierachyRecords(Map<String, cgcloud__Product_Hierarchy__c> prdHierarchyExtIdToRecordMap) {

        if(!prdHierarchyExtIdToRecordMap.isEmpty() && Schema.sObjectType.cgcloud__Product_Hierarchy__c.isCreateable()){

            List<cgcloud__Product_Hierarchy__c> prdHierarchyToInsertList = prdHierarchyExtIdToRecordMap.values();

            // To upsert product hierarchy records.
            Database.UpsertResult[] prdHierarchyInsertResultList = Database.upsert(prdHierarchyToInsertList, 
                                                                                   cgcloud__Product_Hierarchy__c.TPM_PHS_Record_Id__c, 
                                                                                   false);
            Integer index = 0;

            for(Database.UpsertResult upSRObj : prdHierarchyInsertResultList){
                if(upSRObj.isSuccess()){

                    // To update convert status as 'Complete' for success.
                    prdHSIdToStatusMap.put(prdHierarchyToInsertList[index].TPM_PHS_Record_Id__c, TPM_ConstantsUtility.CONVERT_STATUS_COMPLETE);
                }else{

                    // To update convert status as 'Failed' for error.
                    prdHSIdToStatusMap.put(prdHierarchyToInsertList[index].TPM_PHS_Record_Id__c, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
                    
                    // Operation failed, log errors.
                    // Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(upSRObj.getErrors(), 
                                                                                        TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION, 
                                                                                        prdHierarchyToInsertList[index].TPM_PHS_Record_Id__c);

                    // Call the TPM_Utils.prepareBatchLogger
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
                }
                index++;
            }
        }
        
    }


    /**************************************************************************************
    * @method         : isValidateForHierarchyCreation
    * @return         : Boolean
    * @param            phsObj
    * @description    : Method to perform validation of PHS record to create PH record
                        Includes product unavailability in system & hierarchy integratity
    ***************************************************************************************/
    public Boolean isValidateForHierarchyCreation(TPM_Product_Hierarchy_Staging__c phsObj) {

        Boolean isValid = false;

        // Call to helper method.
        isValidateForHierarchyHelper(phsObj);

        // To check product hierarchy level integrity.
        if(prdExtIdToProductMap.containsKey(phsObj.TPM_Parnt_Prod_ID__c) && prdExtIdToProductMap.containsKey(phsObj.TPM_Child_Prod_ID__c)){
            if(String.isNotBlank(prdExtIdToProductMap.get(phsObj.TPM_Parnt_Prod_ID__c).cgcloud__Product_Level__c) 
               && String.isNotBlank(prdExtIdToProductMap.get(phsObj.TPM_Child_Prod_ID__c).cgcloud__Product_Level__c) 
               && levelToRankMap.containsKey(prdExtIdToProductMap.get(phsObj.TPM_Parnt_Prod_ID__c).cgcloud__Product_Level__c) 
               && levelToRankMap.containsKey(prdExtIdToProductMap.get(phsObj.TPM_Child_Prod_ID__c).cgcloud__Product_Level__c) 
               && ( levelToRankMap.get(prdExtIdToProductMap.get(phsObj.TPM_Parnt_Prod_ID__c).cgcloud__Product_Level__c) == levelToRankMap.get(prdExtIdToProductMap.get(phsObj.TPM_Child_Prod_ID__c).cgcloud__Product_Level__c) + 1)){
                isValid = true;

            }else{
                prdHSIdToErrorMap.put(phsObj.Id, System.Label.TPM_PHS_InvalidHierarchy);
                
                // To update convert status as 'Failed' for error.
                prdHSIdToStatusMap.put(phsObj.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            }
        }
        
        return isValid;
    }


    /**********************************************************************************************************
    @method          isTimeFrameOverlapAtPHObj
    @return          Boolean
    @param           phsRecord
    @description     Method to determine whether time frame overlap exists or not at product hierarchy level
                     with same child. 
    ***********************************************************************************************************/
    public Boolean isTimeFrameOverlapAtPHObj(TPM_Product_Hierarchy_Staging__c phsRecord){

        Boolean isOverlap = false;
       
        if(!prdHSIdToErrorMap.containsKey(phsRecord.Id) && childExIdToPHSIdWithProdHierarchyMap.containsKey(phsRecord.TPM_Child_Prod_ID__c)){

            isOverlap = TPM_ProductHierarchyCreationBatchHelper.timeFrameOverlapAtPHHelper(phsRecord, existingPHSSameChidlIdSet, childExIdToPHSIdWithProdHierarchyMap);  
            if(isOverlap){
                prdHSIdToErrorMap.put(phsRecord.Id, System.Label.TPM_PHS_DuplicateTimeFrameMsg);

                // To update convert status as 'Failed' for error.
                prdHSIdToStatusMap.put(phsRecord.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            } 
        }

        return isOverlap;
    }


    /******************************************************************************************************
    @method          isTimeFrameOverlapAtPHS
    @return          Boolean
    @param           phsRecord
    @description     Method to determine whether time frame overlap exists or not at staging records level
                     with same child.
    *******************************************************************************************************/
    public Boolean isTimeFrameOverlapAtPHS(TPM_Product_Hierarchy_Staging__c phsRecord){

        Boolean isOverlap = false;

        if(!childExIdToPHSIdWithPHSRecordMap.isEmpty() && childExIdToPHSIdWithPHSRecordMap.containsKey(phsRecord.TPM_Child_Prod_ID__c)){

            TPM_ProductHierarchyCreationBatchUtils.PHSWrapper wrapObj = TPM_ProductHierarchyCreationBatchUtils.timeFrameOverlapAtPHSHelper(phsRecord, childExIdToPHSIdWithPHSRecordMap);
            isOverlap = wrapObj.isOverlapAtPHS;

            if(!wrapObj.existingPHSForChidlIdSet.isEmpty()){
                existingPHSSameChidlIdSet.addAll(wrapObj.existingPHSForChidlIdSet);
            }
            
            if(isOverlap){
                prdHSIdToErrorMap.put(phsRecord.Id, System.Label.TPM_PHS_PHSDuplicateTimeFrame);

                // To update convert status as 'Failed' for error.
                prdHSIdToStatusMap.put(phsRecord.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            } 
        }

        return isOverlap;
    }


    /**************************************************************************************
    * @method         : isValidateForHierarchyHelper
    * @param            phsObj
    * @description    : helper method for isValidateForHierarchyCreation
    ***************************************************************************************/
    public void isValidateForHierarchyHelper(TPM_Product_Hierarchy_Staging__c phsObj) {

        Map<String, String> prdHSIdToErrorDetailMap = TPM_ProductHierarchyCreationBatchUtils.productRecordAvailabilityHandler(phsObj, prdExtIdToProductMap);

        if(!prdHSIdToErrorDetailMap.isEmpty() && prdHSIdToErrorDetailMap.containsKey(phsObj.Id)){

            prdHSIdToErrorMap.put(phsObj.Id, prdHSIdToErrorDetailMap.get(phsObj.Id));

            // To update convert status as 'Failed' for error.
            prdHSIdToStatusMap.put(phsObj.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);           
        }
    }

}