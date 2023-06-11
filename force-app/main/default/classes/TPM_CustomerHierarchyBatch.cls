/******************************************************************************************************
@Name            TPM_CustomerHierarchyBatch
@testclass       TPM_CustomerHierarchyBatchTest
@Author          PwC Team
@date            January 5, 2023
@description     Batch Apex is used to copy Customer Hierarchy staging into Customer Trade Org Hierarchy object.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public class TPM_CustomerHierarchyBatch implements Database.Batchable<Sobject> { 
    
    // Dynamic Query String
    private String query;
    // Map Holds Customer Trade Org Hierarchy field creation mapping
    private Map<String, TPM_FieldsMapping__mdt> custTradeHrToFromFieldMap;
    // Map Holds Customer Hierarchies for level comparison
    private Map<String, String> custHrLvlSequenceMap;
    // List hold records to process customer hierarchy records for Trade Org Hierarchy creation
    private List<TPM_Customer_Hierarchy_Staging__c> chsRecordsToProcessList;
    // Map Holds SAP External ID as key and Corresponding Customer Record as value
    private Map<String, Account> extnlIDVsCustomerMap;
    // Map Holds Customer Hierarchies Ids and Convert status 
    private Map<String, String> chsConvertStatusUpdateMap;
    // List Hold records for error/exception logging 
    private List<TPM_LoggerException.LogsWrapper> logWrapperList;

    // PBI-1606 : To store customer hierachy staging's child  ext id as key & related existing customer hierarchy staging record map as value.
    Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>> childExIdToCHSIdWithCHSRecordMap;

    // PBI-1606 : Set to store customer hierarchy staging having same child and status as new.
    Set<String> existingCHSSameChidlIdSet;

    // PBI-1606 : To store customer hierachy staging's child  ext id as key & related existing customer trade org hierarchy record map as value.
    Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>> childExIdToCHSIdWithCTOMap;
    

    
    /*********************************************************************************
     @description    Constructor for initial metadata load
    **********************************************************************************/
    public TPM_CustomerHierarchyBatch(){

        // preparing batch query method
        query = TPM_CustomerHierarchyHelper.prepareBatchQuery();
        // preparing maps for Hr Levels and Fields Mapping
        custHrLvlSequenceMap = TPM_CustomerHierarchyHelper.loadHrLevelMapping();
        custTradeHrToFromFieldMap = TPM_CustomerHierarchyHelper.loadBatchFieldMapping();        
    }
    
    /*********************************************************************************
    @method          start
    @param           bc
    @return          Database.QueryLocator
    @description     Batch start method to fetch Customer Hierarchy staging with status as New.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator(query);
    }
    
    /********************************************************************************************************
    @method           execute
    @param            bc
    @param            scope
    @description      Execute method to copy Customer Hierarchy staging into Customer Trade Org Hierarchy object and update status on CHS.
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<TPM_Customer_Hierarchy_Staging__c> scope){

        /* PBI-1606 : START */
        childExIdToCHSIdWithCHSRecordMap = new Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>>();
        childExIdToCHSIdWithCTOMap = new Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>>();
        existingCHSSameChidlIdSet = new Set<String>();

        // To store only child customer external ids from CHS records.
        Set<String> chsChildExtIdSet = new Set<String>();
        /* PBI-1606 : END */

        // below list hold records to process customer hierarchy records for Trade Org Hierarchy creation
        chsRecordsToProcessList = new List<TPM_Customer_Hierarchy_Staging__c>();
        
        // below map contains customer hierarchy staging Id as key and Convert Status(Failed/Complete) as Value. 
        chsConvertStatusUpdateMap = new Map<String, String>();

        // below list hold records for error/exception logging
        logWrapperList = new List<TPM_LoggerException.LogsWrapper>();

        /* PBI-1606 : START */      
        for(TPM_Customer_Hierarchy_Staging__c custHSObj : scope){

            if(String.isNotBlank(custHSObj.TPM_Child_Cust_ID__c)){
                chsChildExtIdSet.add(custHSObj.TPM_Child_Cust_ID__c);
            }
        }
        /* PBI-1606 : END */
        
        
        try{
            // fetches parent/child SF customer records using SAP Ext Ids from CHS object record and fils MAP => extnlIDVsCustomerMap
            extnlIDVsCustomerMap = TPM_CustomerHierarchyHelper.getParentChildCustomerDetails(scope);

            // PBI-1606 : To fetch existing customer hierarchy staging records records using child customer external ids.
            childExIdToCHSIdWithCHSRecordMap = TPM_CustomerHierarchyBatchUtils.fetchCustHierarchyStageDetail(chsChildExtIdSet);

            // PBI-1606 : To fetch existing customer trade org hierarchy records records using child customer external ids.
            childExIdToCHSIdWithCTOMap = TPM_CustomerHierarchyBatchUtils.fetchCTOHierarchyDetail(chsChildExtIdSet);

            for(TPM_Customer_Hierarchy_Staging__c custHrStaging : scope){

                if(String.isBlank(custHrStaging.TPM_Parnt_Cust_ID__c) || String.isBlank(custHrStaging.TPM_Child_Cust_ID__c)){
                    chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
                    logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CustomerStagingPrntChldextIdsNull, null));
                    continue;
                }

                // PBI-1606 : Call to helper method. Restructured this to remove cyclomatic complexity.
                processExexuteHelper(custHrStaging);
                
            }

            // method performs insert trade org hierarchy, update CHS convert status and log errors
            handleDMLOperations();

        } catch(Exception excep){
            TPM_LoggerException.LogsWrapper logObj = new TPM_LoggerException.LogsWrapper();
            logObj.logLevel = TPM_ConstantsUtility.FATAL;

            // PBI-1606 : Added this to populate className at logger.
            logObj.className = TPM_ConstantsUtility.BATCH_CUSTOMERHIERARCHY_AUTOMATION;
            logObj.exceptionObj = excep;
            TPM_LoggerException.log(new List<TPM_LoggerException.LogsWrapper>{logObj});
        }
    }
    
    /***********************************************************************************
    @method          finish
    @param           bc
    @description     Batch finish method to perform completion steps.
    ************************************************************************************/
    public void finish(Database.BatchableContext bc){
        //Check for Batch Sequencing
        if(System.Label.isTPMBatchSequenced.equals(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){
            
            Integer batchSize = TPM_ConstantsUtility.NUMBER_200;
            //Get the Batch Size from CMDT TPM_QueryDefinition__mdt
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_PARENT_ACCOUNT_AUTOMATION);
            
            if(String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            //If Batch is Sequenced, Call Parent Account Batch next
            Database.executeBatch(new TPM_ParentAccountBatch(), batchSize);
        }
    }    


    /************************************************************************************
    * @method         : processExexuteHelper
    * @param            custHrStaging
    * @description    :  PBI-1606 : helper execute method to process CHS records. 
    *************************************************************************************/
    public void processExexuteHelper(TPM_Customer_Hierarchy_Staging__c custHrStaging){

        // Added for - PBI-1606
        Boolean isHierarchyValid = false;

        // checking if queried customer record based on parent/child external id from CHS not null
        if(!extnlIDVsCustomerMap.isEmpty() && extnlIDVsCustomerMap.get(custHrStaging.TPM_Parnt_Cust_ID__c) != null 
            && extnlIDVsCustomerMap.get(custHrStaging.TPM_Child_Cust_ID__c) != null){
                
            isHierarchyValid = checkIntegrityInHierarchy(custHrStaging);
        } else {
            checkCustomerExistence(custHrStaging);
        } 

        /* PBI-1606 : START : To check overlap at CHS and CTO */
        if(isHierarchyValid && !chsConvertStatusUpdateMap.containsKey(custHrStaging.Id)){
            Boolean isOverlapFound = false;
            TPM_CustomerHierarchyBatchUtils.CHWrapper repsonseWrapCHS = TPM_CustomerHierarchyBatchUtils.isTimeFrameOverlapAtCHS(custHrStaging, childExIdToCHSIdWithCHSRecordMap);

            if(repsonseWrapCHS.isOverlap){

                isOverlapFound = true;
                // To update convert status as 'Failed' for error.
                chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
                logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CHS_CHSDuplicateTimeFrame, null));                       
            }else{
                TPM_CustomerHierarchyBatchUtils.CHWrapper repsonseWrapCTO = TPM_CustomerHierarchyBatchUtils.isTimeFrameOverlapAtCTOObj(custHrStaging, repsonseWrapCHS.existingRecordIdSet ,childExIdToCHSIdWithCTOMap);

                if(repsonseWrapCTO.isOverlap){
                    isOverlapFound = true;
                    // To update convert status as 'Failed' for error.
                    chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
                    logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CHS_DuplicateTimeFrameMsg, null));
                }
            }
            if(!isOverlapFound){
                chsRecordsToProcessList.add(custHrStaging);
            }
        }
        /* PBI-1606 : END : To check overlap at CHS and CTO */
    }


    /************************************************************************************
    @method          handleDMLOperations
    @description     dml handler to perform insert trade org hierarchy, update CHS convert status and log errors
    *************************************************************************************/
    public void handleDMLOperations(){
        
        // insert trade org hierarchy
        if(!chsRecordsToProcessList.isEmpty()){
            createCustTradeOrgHr(chsRecordsToProcessList);
        }

        // PBI-1606 : Call to helper method. Restructured this to remove cyclomatic complexity.
        TPM_CustomerHierarchyHelper.dmlOperationsHelper(chsConvertStatusUpdateMap, logWrapperList);
    }


    /************************************************************************************
    @method          checkCustomerExistence
    @param           custHrStaging
    @description     check customer record based on parent/child external id from CHS.
    *************************************************************************************/
    public void checkCustomerExistence(TPM_Customer_Hierarchy_Staging__c custHrStaging){
        
        // PBI-1606 : Call to helper method. Restructured this to remove cyclomatic complexity. 
        Map<String, String> cHSIdToErrorMap = TPM_CustomerHierarchyHelper.customerRecordAvailabilityHandler(custHrStaging, extnlIDVsCustomerMap);
		
        if(cHSIdToErrorMap.containsKey(custHrStaging.Id)){

            chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_REPROCESS);
            logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, cHSIdToErrorMap.get(custHrStaging.Id), null));
        }
    }  
    
    /*************************************************************************************
    @method          checkIntegrityInHierarchy
    @return          Boolean
    @param           custHrStaging
	@description     Validate the integrity of each customer hierarchy record by ensuring the parent is only 1 level above the child.
                     Feb 6, 2023 - PBI-1606 : Added return type for restructuring this to remove cyclomatic complexity. 
	**************************************************************************************/  
    private Boolean checkIntegrityInHierarchy(TPM_Customer_Hierarchy_Staging__c custHrStaging){


        // to avoid doing maths on null values
        Integer chsPrntHrLvlSeq = 0;
        Integer chsChldHrLvlSeq = 0;
        Integer custPrntHrLvlSeq = 0;
        Integer custChldHrLvlSeq = 0;
        String stagingPrntHrLvl = '';
        String stagingChildHrLvl = '';

        // CHS parent/child Hierarchy Level Null check
        if(String.isNotBlank(custHrStaging.TPM_Parnt_Cust_HrLvl__c) && String.isNotBlank(custHrStaging.TPM_Child_Cust_HrLvl__c)){
            stagingPrntHrLvl = custHrStaging.TPM_Parnt_Cust_HrLvl__c;
            stagingChildHrLvl = custHrStaging.TPM_Child_Cust_HrLvl__c;
            chsPrntHrLvlSeq = Integer.valueOf(custHrLvlSequenceMap.get(stagingPrntHrLvl));
            chsChldHrLvlSeq = Integer.valueOf(custHrLvlSequenceMap.get(stagingChildHrLvl)); 
        } else {
            chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CustomerStagingHrLvlBlank, null));
            return false;
        }        
        
        // PARENT CUSTOMERs Hierarchy Levels compare and null check
        if(String.isNotBlank(extnlIDVsCustomerMap.get(custHrStaging.TPM_Parnt_Cust_ID__c).TPM_Hierarchy_Level__c) 
           &&
           extnlIDVsCustomerMap.get(custHrStaging.TPM_Parnt_Cust_ID__c).TPM_Hierarchy_Level__c.equalsIgnoreCase(stagingPrntHrLvl)){
               
            custPrntHrLvlSeq = Integer.valueOf(custHrLvlSequenceMap.get(extnlIDVsCustomerMap.get(custHrStaging.TPM_Parnt_Cust_ID__c).TPM_Hierarchy_Level__c));
        } else{
            chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CustHrParentLvlMisMatch, null));
            return false;
        }
        
        // Child CUSTOMERs Hierarchy Levels compare and null check
        if(String.isNotBlank(extnlIDVsCustomerMap.get(custHrStaging.TPM_Child_Cust_ID__c).TPM_Hierarchy_Level__c) 
           &&
           extnlIDVsCustomerMap.get(custHrStaging.TPM_Child_Cust_ID__c).TPM_Hierarchy_Level__c.equalsIgnoreCase(stagingChildHrLvl)){
               
            custChldHrLvlSeq = Integer.valueOf(custHrLvlSequenceMap.get(extnlIDVsCustomerMap.get(custHrStaging.TPM_Child_Cust_ID__c).TPM_Hierarchy_Level__c));
        } else{
            chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CustHrChildLvlMisMatch, null)); 
            return false;
        }

        // checking integrity in the customer hierarchy parent is only 1 level above the child
        if(Math.abs(custPrntHrLvlSeq-custChldHrLvlSeq) == TPM_ConstantsUtility.NUMBER_1 &&
             Math.abs(chsPrntHrLvlSeq-chsChldHrLvlSeq) == TPM_ConstantsUtility.NUMBER_1){

            return true;
            
        } else{
            // on validation failure logging and updating CHS convert status
            chsConvertStatusUpdateMap.put(custHrStaging.Id, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
            logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custHrStaging.Id, System.Label.TPM_CustomerHrRelationInvalid, null));
            return false;
        }
    }
    
    /************************************************************************************
    @method          createCustTradeOrgHr
    @param           custHrStagings
    @description     Customer Hierarchy staging copying into the standard CGC Customer Trade Org Hierarchy object
    *************************************************************************************/
    private void createCustTradeOrgHr(List<TPM_Customer_Hierarchy_Staging__c> custHrStagings){

        // PBI-1606 : Call to helper method. Restructured this to remove cyclomatic complexity.
        List<cgcloud__Account_Trade_Org_Hierarchy__c> custTradeOrgHrList = TPM_CustomerHierarchyHelper.prepareCTORecordsForUpsert(custHrStagings, 
                                                                                                                                  extnlIDVsCustomerMap, 
                                                                                                                                  custTradeHrToFromFieldMap);
        
        if(!custTradeOrgHrList.isEmpty() && Schema.sObjectType.cgcloud__Account_Trade_Org_Hierarchy__c.isCreateable()){
            // Creating Trade Org Hierarchy record with only CHS records that both match Account records and have integrity in their hierarchy relationships.
            Database.UpsertResult[] custTraddeOrgHrResults = Database.upsert(custTradeOrgHrList, cgcloud__Account_Trade_Org_Hierarchy__c.TPM_CHSRecordId__c, false);
            Integer index = 0;
            for(Database.UpsertResult sResult : custTraddeOrgHrResults){
                if(sResult.isSuccess()){
                    // Update Convert Status for CHS records processed successfully.
                    chsConvertStatusUpdateMap.put(custTradeOrgHrList[index].TPM_CHSRecordId__c, TPM_ConstantsUtility.CONVERT_STATUS_COMPLETE);
                }
                else{
                    chsConvertStatusUpdateMap.put(custTradeOrgHrList[index].TPM_CHSRecordId__c, TPM_ConstantsUtility.CONVERT_STATUS_FAILED);
                    // Operation failed, log errors.  
                    logWrapperList.add(TPM_CustomerHierarchyHelper.loggerHelper(custTradeOrgHrList[index].TPM_CHSRecordId__c, null, sResult.getErrors())); 
                }
                index++;
            }
        }
    }
}