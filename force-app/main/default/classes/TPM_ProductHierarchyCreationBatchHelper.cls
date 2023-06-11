/******************************************************************************************************
* @Name         : TPM_ProductHierarchyCreationBatchHelper
* @Test Class   : TPM_ProductHierarchyCreationBatchTest
* @author       : PwC Team
* @date         : January 18, 2023
* @description  : Helper class for batch apex - 'TPM_ProductHierarchyCreationBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_ProductHierarchyCreationBatchHelper {


    /*********************************************************************************
     @description    private Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_ProductHierarchyCreationBatchHelper(){
        
    }

    /***************************************************************************************************************
    * @method          fetchProductDetails
    * @param           prdExtIdSet
    * @return          Map<String, Product2>
    * @description     Method to fetch product records based on PHS record's child and parent product external Ids.
    ***************************************************************************************************************/
    public static Map<String, Product2> fetchProductDetails(Set<String> prdExtIdSet){

        Map<String, Product2> prdExtIdToProductMap = new Map<String, Product2>();

        // To fetch product level mapping from TPM_CustomMappings__mdt custom metadata record.
        if(!prdExtIdSet.isEmpty()){
            for(Product2 prdObj : [SELECT Id, 
                                          Name, 
                                          cgcloud__Product_Level__c,  
                                          cgcloud__Consumer_Goods_External_Product_Id__c 
                                  FROM Product2 
                                  WHERE cgcloud__Consumer_Goods_External_Product_Id__c IN: prdExtIdSet 
                                  AND cgcloud__Consumer_Goods_External_Product_Id__c != NULL]){

                prdExtIdToProductMap.put(prdObj.cgcloud__Consumer_Goods_External_Product_Id__c, prdObj);
            }
        }     

        return prdExtIdToProductMap;
    }


    /************************************************************************************
    @method          updatePHSConvertStatus
    @param           prdHSIdToStatusMap
    @description     To update product hierarchy staging convert status field.
    *************************************************************************************/
    public static void updatePHSConvertStatus(Map<String, String> prdHSIdToStatusMap){

    	List<TPM_Product_Hierarchy_Staging__c> phsUpdateStatusList = new List<TPM_Product_Hierarchy_Staging__c>();
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        if(!prdHSIdToStatusMap.isEmpty()){
            for(String prodHSRecordId : prdHSIdToStatusMap.keySet()){

                TPM_Product_Hierarchy_Staging__c prdHSObj = new TPM_Product_Hierarchy_Staging__c();
                prdHSObj.Id = prodHSRecordId;
                prdHSObj.TPM_Convert_Status__c = prdHSIdToStatusMap.get(prodHSRecordId);
                phsUpdateStatusList.add(prdHSObj);
            }
        }

        // To update convert status field on the PHS object as "Complete" for success and "Failed" for any error. 
        if(!phsUpdateStatusList.isEmpty()){

            Database.SaveResult[] phsUpdateResultList = Database.update(phsUpdateStatusList, false);

            Integer index = 0;

            for(Database.SaveResult srObj : phsUpdateResultList){
                if(!srObj.isSuccess()){
                    
                    // Operation failed, log errors.
                    // Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(srObj.getErrors(), 
                                                                                        TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION, 
                                                                                        phsUpdateStatusList[index].Id);

                    // Call the TPM_Utils.prepareBatchLogger
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
                }
                index++;
            }
        }

        if(!logWrapperList.isEmpty()){

            // To log the errors. 
            TPM_LoggerException.log(logWrapperList);
        }
    }


    /*****************************************************************************************
    * @method          prepareBatchStartQuery
    * @param           prdHSRecordIdSet
    * @return          String
    * @description     Method to prepare batch start query based on custom metadata record.
    ******************************************************************************************/
    public static String prepareBatchStartQuery(Set<Id> prdHSRecordIdSet){
        
        String query = '';
        Boolean isQueryConditionPresent = false;

        // fetch query from TPM_QueryDefinition__mdt custom metadata record.
        List<TPM_QueryDefinition__mdt>  startQueryMdtList = new List<TPM_QueryDefinition__mdt>();

        startQueryMdtList = [SELECT Id, 
                                    TPM_BaseQuery__c, 
                                    TPM_ProcessName__c, 
                                    TPM_QueryCondition__c, 
                                    TPM_Query_Footer__c  
                            FROM TPM_QueryDefinition__mdt 
                            WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION  
                            LIMIT 1];

        if(String.isNotBlank(startQueryMdtList[0].TPM_BaseQuery__c)){
            query = startQueryMdtList[0].TPM_BaseQuery__c;
        }       

        if(String.isNotBlank(startQueryMdtList[0].TPM_QueryCondition__c)){
            query += ' ' + startQueryMdtList[0].TPM_QueryCondition__c;
            isQueryConditionPresent = true;
        }

        if(prdHSRecordIdSet != null && !prdHSRecordIdSet.isEmpty()){
            String preSelectedQuery = isQueryConditionPresent ? ' AND Id IN: prdHSRecordIdSet ' : ' WHERE Id IN: prdHSRecordIdSet ';
            query += preSelectedQuery;
        }

        if(String.isNotBlank(startQueryMdtList[0].TPM_Query_Footer__c)){
            query += ' ' + startQueryMdtList[0].TPM_Query_Footer__c;
        }

        return query;
    }


    /*********************************************************************************************************
    * @method          prepareProductLevelMapping
    * @return          Map<String, Decimal>
    * @description     Method to prepare product level vs rank to check integrity of parent-child hierarchy.
    **********************************************************************************************************/
    public static Map<String, Decimal> prepareProductLevelMapping(){

        Map<String, Decimal> productLevelAPIToRankMap = new Map<String, Decimal>();

        // fetch product level mapping from TPM_CustomMappings__mdt custom metadata record.
        for(TPM_CustomMappings__mdt customMappingMdt : [SELECT Id, 
                                                               TPM_ProcessName__c, 
                                                               TPM_Key__c, 
                                                               TPM_Value__c, 
                                                               TPM_Sequence_Number__c 
                                                        FROM TPM_CustomMappings__mdt  
                                                        WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION 
                                                        ORDER BY TPM_Sequence_Number__c DESC]){

            if(String.isNotBlank(customMappingMdt.TPM_Key__c) && customMappingMdt.TPM_Sequence_Number__c != null){

                // To store product level vs rank to check integrity of parent-child hierarchy.
                productLevelAPIToRankMap.put(customMappingMdt.TPM_Key__c, customMappingMdt.TPM_Sequence_Number__c);
            }
        }      

        return productLevelAPIToRankMap;
    }


    /***********************************************************************************************
    * @method          fetchProdHSMapping
    * @return          Map<String, TPM_FieldsMapping__mdt>
    * @description     Method to fetch product hierarchy vs staging field mapping records.  
    ************************************************************************************************/
    public static Map<String, TPM_FieldsMapping__mdt> fetchProdHSMapping(){
        
        Map<String, TPM_FieldsMapping__mdt> prodHSFieldToMDTMap = new Map<String, TPM_FieldsMapping__mdt>();

        for(TPM_FieldsMapping__mdt fieldMapMDT : [SELECT Id, 
                                                         TPM_FromFieldApi__c, 
                                                         TPM_ToFieldApi__c, 
                                                         TPM_IsLookup__c, 
                                                         TPM_DefaultValue__c, 
                                                         TPM_UseDefaultValue__c, 
                                                         Lookup_Relationship_Notation__c, 
                                                         TPM_ProcessName__c 
                                                  FROM TPM_FieldsMapping__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION]){
            
            if(String.isNotBlank(fieldMapMDT.TPM_ToFieldApi__c) && String.isNotBlank(fieldMapMDT.TPM_FromFieldApi__c)){

                prodHSFieldToMDTMap.put(fieldMapMDT.TPM_ToFieldApi__c, fieldMapMDT);
            }
        }

        return prodHSFieldToMDTMap;
    }


    /*****************************************************************************************************************
    @method          timeFrameOverlapAtPHHelper
    @return          Boolean
    @param           phsRecord
    @param           existingPHSSameChidlIdSet
    @param           childExIdToPHSIdWithProdHierarchyMap
    @description     Helper method to determine whether time frame overlap exists or not at product hierarchy level 
                     with same child.
    ******************************************************************************************************************/   
    public static Boolean timeFrameOverlapAtPHHelper(TPM_Product_Hierarchy_Staging__c phsRecord,  Set<String> existingPHSSameChidlIdSet, Map<String, Map<String, cgcloud__Product_Hierarchy__c>> childExIdToPHSIdWithProdHierarchyMap){

        Boolean isOverlap = false;

        for(String prodStagingId : childExIdToPHSIdWithProdHierarchyMap.get(phsRecord.TPM_Child_Prod_ID__c).keySet()){
     
            cgcloud__Product_Hierarchy__c existingPHRecord = childExIdToPHSIdWithProdHierarchyMap.get(phsRecord.TPM_Child_Prod_ID__c).get(prodStagingId);
            if(phsRecord.Id != prodStagingId && !existingPHSSameChidlIdSet.contains(prodStagingId) && phsRecord.TPM_Prod_Hrchy_Strt_Dt__c != null && phsRecord.TPM_Prod_Hrchy_End_DT__c != null){
                isOverlap = TPM_Utils.isRangeOverlap(existingPHRecord.cgcloud__Valid_From__c, 
                                                     existingPHRecord.cgcloud__Valid_Thru__c, 
                                                     phsRecord.TPM_Prod_Hrchy_Strt_Dt__c, 
                                                     phsRecord.TPM_Prod_Hrchy_End_DT__c);
                if(isOverlap){
                    break;
                }
            }
        }

        return isOverlap;
    }

}