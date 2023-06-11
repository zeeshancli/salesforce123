/******************************************************************************************************
@Name            TPM_CustomerHierarchyHelper
@testclass       TPM_CustomerHierarchyBatchTest
@Author          PwC Team
@date            January 12, 2023
@description     Batch Apex helper class for  TPM_CustomerHierarchyBatch business logic.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_CustomerHierarchyHelper {

    /*********************************************************************************
     @description    private Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_CustomerHierarchyHelper(){
        
    }

    /********************************************************************************
    @method          prepareBatchQuery
    @return          String
    @description     method preparing batch query based on custommetadata record
    *********************************************************************************/
    public static String prepareBatchQuery(){
        
        String query = '';
        
        // preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c = :TPM_ConstantsUtility.BATCH_CUSTOMERHIERARCHY_AUTOMATION]){
        
            if(String.isNotBlank(queryDef.TPM_BaseQuery__c)){
                query = queryDef.TPM_BaseQuery__c;
            }
            if(String.isNotBlank(queryDef.TPM_QueryCondition__c)){
                query = query + ' ' + queryDef.TPM_QueryCondition__c;
            }
        }
        return query;
    } 

    /*********************************************************************************
    @method          loadHrLevelMapping
    @return          Map<String, String>
    @description     method preparing custommetadata maps for Hr Levels and Fields Mapping
    **********************************************************************************/
    public static Map<String, String> loadHrLevelMapping(){
        
        Map<String, String> custHrLvlSequenceMap = new Map<String, String>();
        for (TPM_CustomMappings__mdt custHrLvl : [SELECT Id, TPM_Key__c, TPM_Sequence__c FROM TPM_CustomMappings__mdt 
                                                  WHERE TPM_ProcessName__c = :TPM_ConstantsUtility.CUSTOMER_HIERARCHY_LEVELS]){

            if(String.isNotBlank(custHrLvl.TPM_Key__c) && String.isNotBlank(custHrLvl.TPM_Sequence__c)){
                // customer hierarchy comparison map with Hierarchy name as key and Sequence as value
                custHrLvlSequenceMap.put(custHrLvl.TPM_Key__c, custHrLvl.TPM_Sequence__c);
            }
        }
        return custHrLvlSequenceMap;
    }

    /*********************************************************************************
    @method          loadBatchFieldMapping
    @return          Map<String, TPM_FieldsMapping__mdt>
    @description     method preparing custommetadata maps for Hr Levels and Fields Mapping
    **********************************************************************************/
    public static Map<String, TPM_FieldsMapping__mdt> loadBatchFieldMapping(){
        
        Map<String, TPM_FieldsMapping__mdt> custTradeHrToFromMap = new Map<String, TPM_FieldsMapping__mdt>();
        for(TPM_FieldsMapping__mdt batchFldsMap : [SELECT Id, TPM_ToFieldApi__c, TPM_FromFieldApi__c, TPM_IsLookup__c, 
                                                    TPM_DefaultValue__c, TPM_UseDefaultValue__c 
                                                    FROM TPM_FieldsMapping__mdt 
                                                    WHERE TPM_ProcessName__c = :TPM_ConstantsUtility.BATCH_CUSTOMERHIERARCHY_AUTOMATION]){
            
            if(String.isNotBlank(batchFldsMap.TPM_ToFieldApi__c) && String.isNotBlank(batchFldsMap.TPM_FromFieldApi__c)){
                // customer hierarchy comparison map with Hierarchy name as key and Sequence as value
                custTradeHrToFromMap.put(batchFldsMap.TPM_ToFieldApi__c, batchFldsMap);
            }
        }
        return custTradeHrToFromMap;
    }

    /************************************************************************************
    @method          updateCHSConvertStatus
    @param           chsForConvertStatus
    @description     Customer Hierarchy Staging mark Status field as "Complete/Failed"
    *************************************************************************************/
    public static void updateCHSConvertStatus(Map<String, String> chsForConvertStatus){
        
    	List<TPM_Customer_Hierarchy_Staging__c> chsUpdateConvertStatusList = new List<TPM_Customer_Hierarchy_Staging__c>();
        
        // iterating over CHS Ids and corresponding status to update
        for(String custHrStageId : chsForConvertStatus.keySet()){
            TPM_Customer_Hierarchy_Staging__c custHrStageNew = new TPM_Customer_Hierarchy_Staging__c();
            custHrStageNew.Id = custHrStageId;
            custHrStageNew.TPM_Convert_Status__c = chsForConvertStatus.get(custHrStageId);
            chsUpdateConvertStatusList.add(custHrStageNew);
        }

        // Updating Convert Status field on the CHS object as "Complete" for success and "Failed" for errors. 
        if(!chsUpdateConvertStatusList.isEmpty()){
            update chsUpdateConvertStatusList;
        }
    }

    /*************************************************************************************
    @method          getParentChildCustomerDetails
    @param           custHrStagRecords
    @return          Map<String, Account>
	@description     fetches parent/child SF customer records using SAP Ext Ids from CHS object record
	**************************************************************************************/  
    public static Map<String, Account> getParentChildCustomerDetails(List<TPM_Customer_Hierarchy_Staging__c> custHrStagRecords){
        
        Map<String, Account> extnlIDVsCustomerMap = new Map<String, Account>();
        
        // iterating over Customer Hierarchy records to prepare Parent/Child Ids for Account Query
        for(TPM_Customer_Hierarchy_Staging__c custHrStaging : custHrStagRecords){
            if(String.isNotBlank(custHrStaging.TPM_Parnt_Cust_ID__c) && !extnlIDVsCustomerMap.containsKey(custHrStaging.TPM_Parnt_Cust_ID__c)){
                extnlIDVsCustomerMap.put(custHrStaging.TPM_Parnt_Cust_ID__c, null);
            }
            
            if(String.isNotBlank(custHrStaging.TPM_Child_Cust_ID__c) &&  !extnlIDVsCustomerMap.containsKey(custHrStaging.TPM_Child_Cust_ID__c)){
                extnlIDVsCustomerMap.put(custHrStaging.TPM_Child_Cust_ID__c, null);
            }
        }

        // preparing map of cust SAP externalId as key and customer record as value
        // Added cgcloud__Number_Of_Extensions__c >0 as part of previous batch sequencing logic
        for(Account pcCust : [SELECT Id, RecordType.Name, TPM_Hierarchy_Level__c, TPM_SAP_External_ID__c FROM Account 
                              WHERE TPM_SAP_External_ID__c IN :extnlIDVsCustomerMap.keySet() 
                              AND RecordType.Name = :TPM_ConstantsUtility.CUSTOMER_RECORDTYPE_NAME
                              AND cgcloud__Number_Of_Extensions__c >0]){

            // map holds customer SAP External ID as key and corresponding Customer Record                      
            extnlIDVsCustomerMap.put(pcCust.TPM_SAP_External_ID__c, pcCust);
        }
        
        return extnlIDVsCustomerMap;
    }
    
    /*************************************************************************************
    @method          loggerHelper
	@return          TPM_LoggerException.LogsWrapper
    @param           recordId
    @param           errMessage
    @param           errorList
	@description     Method to prepare exception logger for batch errors.
	**************************************************************************************/   
    public static TPM_LoggerException.LogsWrapper loggerHelper(String recordId, String errMessage, List<Database.Error> errorList){
        // logger instanciation
        TPM_LoggerException.LogsWrapper logObj = new TPM_LoggerException.LogsWrapper();

        // PBI-1606 : Added to populate class name at logger
        logObj.className = TPM_ConstantsUtility.BATCH_CUSTOMERHIERARCHY_AUTOMATION;
        logObj.logLevel = TPM_ConstantsUtility.ERROR;
        logObj.guid = recordId;

        // PBI-1606 : Added to populate CHS lookup at logger
        logObj.customerHSID = recordId;

        // check custom validation message, if not then database saveresults errors
        if(String.isEmpty(errMessage)){
            logObj.errors = errorList;
        }else{
            logObj.errorMessage = errMessage;
        }
        return logObj; 
    }

    /************************************************************************************************************
    @method          dmlOperationsHelper
    @param           chsConvertStatusUpdateMap
    @param           logWrapperList
    @description     Added for - PBI-1606 : DML helper to update CHS status and log error records.
    *************************************************************************************************************/
    public static void dmlOperationsHelper(Map<String, String> chsConvertStatusUpdateMap, List<TPM_LoggerException.LogsWrapper> logWrapperList){

        // update CHS convert status
        if(!chsConvertStatusUpdateMap.isEmpty()){
            updateCHSConvertStatus(chsConvertStatusUpdateMap);
        }

        // To log the batch errors. 
        if(!logWrapperList.isEmpty()){
            TPM_LoggerException.log(logWrapperList);
        }

    }

    /*************************************************************************************
    @method          prepareCTORecordsForUpsert
	@return          List<cgcloud__Account_Trade_Org_Hierarchy__c>
    @param           custHrStagings
    @param           extnlIDVsCustomerMap
    @param           custTradeHrToFromFieldMap
	@description     Method to prepare CTO hierachy records for upsert operation.
	**************************************************************************************/ 
    public static List<cgcloud__Account_Trade_Org_Hierarchy__c> prepareCTORecordsForUpsert(List<TPM_Customer_Hierarchy_Staging__c> custHrStagings, 
                                                                                           Map<String, Account> extnlIDVsCustomerMap, 
                                                                                           Map<String, TPM_FieldsMapping__mdt> custTradeHrToFromFieldMap){

        List<cgcloud__Account_Trade_Org_Hierarchy__c> custTradeOrgHrList = new List<cgcloud__Account_Trade_Org_Hierarchy__c>();

        for(TPM_Customer_Hierarchy_Staging__c custHrStage : custHrStagings){
            cgcloud__Account_Trade_Org_Hierarchy__c custTradeOrgHr = new cgcloud__Account_Trade_Org_Hierarchy__c();
            // Iterating over dynamic mapping to populate Trade Org Hierarchy fields.
            for(String trgtField :custTradeHrToFromFieldMap.keySet()){
                TPM_FieldsMapping__mdt srcRecord = custTradeHrToFromFieldMap.get(trgtField);
                String srcField = srcRecord.TPM_FromFieldApi__c;  
                // If its a lookup field to populate, then fetching SFId instead of value in corresponding customer hierarchy object field
                if(srcRecord.TPM_IsLookup__c){
                    // Fetching and Assigning Customer SF Id based on external ID in the CHS object for parent and child 
                    String sfIdToAssign = extnlIDVsCustomerMap.get(String.valueOf(custHrStage.get(srcField))).Id;  
                    custTradeOrgHr.put(trgtField, sfIdToAssign);
                } else{
                    custTradeOrgHr.put(trgtField, custHrStage.get(srcField));
                }
                
            }
            custTradeOrgHrList.add(custTradeOrgHr);
        }

        return custTradeOrgHrList;
    }

    /***********************************************************************************************
    * @method          customerRecordAvailabilityHandler
    * @return        : Map<String, String>
    * @param           custHrStaging
    * @param           extnlIDVsCustomerMap
    * @description     Method to check customer record availability 
    ************************************************************************************************/
    public static Map<String, String> customerRecordAvailabilityHandler(TPM_Customer_Hierarchy_Staging__c custHrStaging, Map<String, Account> extnlIDVsCustomerMap){

        Map<String, String> cHSIdToErrorMap = new Map<String, String>();

        if(extnlIDVsCustomerMap.get(custHrStaging.TPM_Parnt_Cust_ID__c) == null 
            && extnlIDVsCustomerMap.get(custHrStaging.TPM_Child_Cust_ID__c) == null){

            //if both External ID matches are not found
            cHSIdToErrorMap.put(custHrStaging.Id, System.Label.TPM_CustHrBothCustNotFound);   
        }
        else if(extnlIDVsCustomerMap.get(custHrStaging.TPM_Parnt_Cust_ID__c) == null){

            // If an External ID match is not found for parent
            cHSIdToErrorMap.put(custHrStaging.Id, System.Label.TPM_CustHrParentNotFound);
        } else if(extnlIDVsCustomerMap.get(custHrStaging.TPM_Child_Cust_ID__c) == null){

            // If an External ID match is not found for child
            cHSIdToErrorMap.put(custHrStaging.Id, System.Label.TPM_CustHrChildNotFound);
        }

        return cHSIdToErrorMap;
    }
       
}