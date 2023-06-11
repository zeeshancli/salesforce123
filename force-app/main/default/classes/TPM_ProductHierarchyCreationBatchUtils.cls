/******************************************************************************************************
* @Name         : TPM_ProductHierarchyCreationBatchUtils
* @Test Class   : TPM_ProductHierarchyCreationBatchTest
* @author       : PwC Team
* @date         : January 18, 2023
* @description  : Helper class for batch apex - 'TPM_ProductHierarchyCreationBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public with sharing class TPM_ProductHierarchyCreationBatchUtils {


    /******************************************************************************************************
    * @method          fetchProdHierarchyStageDetail
    * @param           phsChildExtIdSet
    * @return          Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>>
    * @description     Method to fetch new product hierarchy staging records using child product ext ids.
    ******************************************************************************************************/
    public static Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>> fetchProdHierarchyStageDetail(Set<String> phsChildExtIdSet){

        Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>> childExIdToPHSIdWithPHSRecordMap = new Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>>();

        // To fetch existing product hierarchy staging records using child product ext ids.
        if(!phsChildExtIdSet.isEmpty()){
            for(TPM_Product_Hierarchy_Staging__c phsObj : [SELECT Id, 
                                                                  Name, 
                                                                  TPM_Child_Prod_ID__c, 
                                                                  TPM_Parnt_Prod_ID__c,
                                                                  TPM_Prod_Hrchy_Strt_Dt__c,
                                                                  TPM_Prod_Hrchy_End_DT__c, 
                                                                  TPM_Convert_Status__c    
                                                        FROM TPM_Product_Hierarchy_Staging__c 
                                                        WHERE TPM_Child_Prod_ID__c IN: phsChildExtIdSet 
                                                        AND TPM_Convert_Status__c =: TPM_ConstantsUtility.PROD_HS_STATUS_NEW 
                                                        ORDER BY TPM_Child_Prod_ID__c, CreatedDate ASC]){

                String childExtString = phsObj.TPM_Child_Prod_ID__c;                                            
                if(!childExIdToPHSIdWithPHSRecordMap.containsKey(childExtString)){
                    childExIdToPHSIdWithPHSRecordMap.put(childExtString, new Map<String, TPM_Product_Hierarchy_Staging__c>{});
                }                                            
                childExIdToPHSIdWithPHSRecordMap.get(childExtString).put(phsObj.Id, phsObj);
            }
        }    
        
        return childExIdToPHSIdWithPHSRecordMap;
    }
    

    /****************************************************************************************************
    * @method          fetchProductHierarchyDetail
    * @param           phsChildExtIdSet
    * @return          Map<String, Map<String, cgcloud__Product_Hierarchy__c>>
    * @description     Method to fetch existing product hierarchy records using child product ext ids.
    ****************************************************************************************************/
    public static Map<String, Map<String, cgcloud__Product_Hierarchy__c>> fetchProductHierarchyDetail(Set<String> phsChildExtIdSet){

        Map<String, Map<String, cgcloud__Product_Hierarchy__c>> childExIdToPHSIdWithProdHierarchyMap = new Map<String, Map<String, cgcloud__Product_Hierarchy__c>>();

        // To fetch existing product hierarchy records using child product ext ids.
        if(!phsChildExtIdSet.isEmpty()){
            for(cgcloud__Product_Hierarchy__c phsObj : [SELECT Id, 
                                                               Name, 
                                                               cgcloud__Child_Product__c,  
                                                               cgcloud__Parent_Product__c,
                                                               cgcloud__Valid_From__c,
                                                               cgcloud__Valid_Thru__c, 
                                                               TPM_PHS_Record_Id__c, 
                                                               cgcloud__Child_Product__r.cgcloud__Consumer_Goods_External_Product_Id__c    
                                                        FROM cgcloud__Product_Hierarchy__c 
                                                        WHERE cgcloud__Child_Product__r.cgcloud__Consumer_Goods_External_Product_Id__c IN: phsChildExtIdSet 
                                                        AND TPM_PHS_Record_Id__c != NULL 
                                                        ORDER BY cgcloud__Child_Product__r.cgcloud__Consumer_Goods_External_Product_Id__c, CreatedDate ASC]){

                String childExtString = phsObj.cgcloud__Child_Product__r.cgcloud__Consumer_Goods_External_Product_Id__c;                                            
                if(!childExIdToPHSIdWithProdHierarchyMap.containsKey(childExtString)){
                    childExIdToPHSIdWithProdHierarchyMap.put(childExtString, new Map<String, cgcloud__Product_Hierarchy__c>{});
                }                                            
                childExIdToPHSIdWithProdHierarchyMap.get(childExtString).put(phsObj.TPM_PHS_Record_Id__c, phsObj);
            }
        }    
        
        return childExIdToPHSIdWithProdHierarchyMap;
    }


    /***********************************************************************************************
    * @method          productRecordAvailabilityHandler
    * @return        : Map<String, String>
    * @param           phsObj
    * @param           prdExtIdToProductMap
    * @description     Method to check product records availability in system
    ************************************************************************************************/
    public static Map<String, String> productRecordAvailabilityHandler(TPM_Product_Hierarchy_Staging__c phsObj, Map<String, Product2> prdExtIdToProductMap){
        
        Map<String, String> prdHSIdToErrorMap = new Map<String, String>();
        
        if(!prdExtIdToProductMap.containsKey(phsObj.TPM_Parnt_Prod_ID__c) && !prdExtIdToProductMap.containsKey(phsObj.TPM_Child_Prod_ID__c)){
            prdHSIdToErrorMap.put(phsObj.Id, System.Label.TPM_PHS_NoProductFound);

        }else if(!prdExtIdToProductMap.containsKey(phsObj.TPM_Parnt_Prod_ID__c)){

            prdHSIdToErrorMap.put(phsObj.Id, System.Label.TPM_PHS_NoParentProductFound);
        }else if(!prdExtIdToProductMap.containsKey(phsObj.TPM_Child_Prod_ID__c)){

            prdHSIdToErrorMap.put(phsObj.Id, System.Label.TPM_PHS_NoChildProductFound);
        }
        
        return prdHSIdToErrorMap;
    }


    /***************************************************************************************************************
    @method          timeFrameOverlapAtPHSHelper
    @return          PHSWrapper
    @param           phsRecord
    @param           childExIdToPHSIdWithPHSObjMap
    @description     Helper method to determine whether time frame overlap exists or not at hierarchy staging level 
                     with same child.
    ****************************************************************************************************************/   
    public static PHSWrapper timeFrameOverlapAtPHSHelper(TPM_Product_Hierarchy_Staging__c phsRecord,  Map<String, Map<String, TPM_Product_Hierarchy_Staging__c>> childExIdToPHSIdWithPHSObjMap){

        PHSWrapper wrapObj = new PHSWrapper();
        wrapObj.phsRecordId = phsRecord.Id;
        wrapObj.isOverlapAtPHS = false;
        wrapObj.existingPHSForChidlIdSet = new Set<String>();

        for(String prodStagingId : childExIdToPHSIdWithPHSObjMap.get(phsRecord.TPM_Child_Prod_ID__c).keySet()){
     
            TPM_Product_Hierarchy_Staging__c existingPHSRecord = childExIdToPHSIdWithPHSObjMap.get(phsRecord.TPM_Child_Prod_ID__c).get(prodStagingId);
            if(phsRecord.Id != prodStagingId && phsRecord.TPM_Prod_Hrchy_Strt_Dt__c != null && phsRecord.TPM_Prod_Hrchy_End_DT__c != null){
                wrapObj.existingPHSForChidlIdSet.add(prodStagingId);
                wrapObj.isOverlapAtPHS = TPM_Utils.isRangeOverlap(existingPHSRecord.TPM_Prod_Hrchy_Strt_Dt__c, 
                                                                  existingPHSRecord.TPM_Prod_Hrchy_End_DT__c, 
                                                                  phsRecord.TPM_Prod_Hrchy_Strt_Dt__c, 
                                                                  phsRecord.TPM_Prod_Hrchy_End_DT__c);
                if(wrapObj.isOverlapAtPHS){
                    break;
                }
            }
        }

        return wrapObj;

    }


    /***********************************************************************************************
    * @method          preparePHRecordForDML
    * @return        : cgcloud__Product_Hierarchy__c
    * @param           prdHSObj
    * @param           prodHSFieldToRecordMap
    * @param           prdExtIdToProductMap
    * @description     Method to prepare product hierarchy records for DML operation.
    ************************************************************************************************/
    public static cgcloud__Product_Hierarchy__c preparePHRecordForDML(TPM_Product_Hierarchy_Staging__c prdHSObj, Map<String, TPM_FieldsMapping__mdt> prodHSFieldToRecordMap, Map<String, Product2> prdExtIdToProductMap){
        
        cgcloud__Product_Hierarchy__c prdHierarchyObj = new cgcloud__Product_Hierarchy__c();

        // Iteration over field mapping to populate product hierarchy fields.
        for(String targetField : prodHSFieldToRecordMap.keySet()){

            TPM_FieldsMapping__mdt mdtObj = prodHSFieldToRecordMap.get(targetField);
            String srcField = mdtObj.TPM_FromFieldApi__c;  

            // If it's a lookup field to populate, then fetch value from corresponding product object field.
            if(mdtObj.TPM_IsLookup__c && String.isNotBlank(mdtObj.Lookup_Relationship_Notation__c)){

                // Fetching and assigning product field value based on external ID in the PHS object for parent and child. 
                Product2 prodObj = prdExtIdToProductMap.get(String.valueOf(prdHSObj.get(srcField)));
                String lookupField = String.valueOf(prodObj.get(mdtObj.Lookup_Relationship_Notation__c));  
                prdHierarchyObj.put(targetField, lookupField);
            } else{
                prdHierarchyObj.put(targetField, prdHSObj.get(srcField));
            }
            
        }
        return prdHierarchyObj;
    }


    /**********************************************************************
    * @method          sequenceNextBatch
    * @description     Method to sequence next batch
    ***********************************************************************/
    public static void sequenceNextBatch(){

        // PBI-163 : Sequencing the flatten product hierarchy batch .
        Integer batchSize = TPM_ConstantsUtility.NUMBER_200;

        // To check for batch sequencing.
        if(System.Label.TPM_IsProductHierarchySequencedWithFlattening.equalsIgnoreCase(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){

            // To fetch the batch size from TPM_QueryDefinition__mdt record.
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_PRD_FLATTENING_CATEGORY);

            if(batchQueryMdt != null && String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            TPM_ProductFlatteningCategoryBatch prodFlattenCategoryBatch = new TPM_ProductFlatteningCategoryBatch(null); 
        
            // Call the batch class to execute.
            Database.executeBatch(prodFlattenCategoryBatch, batchSize);
        }
        
    }


    /******************************************************************
    * @Name            PHSWrapper
    * @description     Wrapper class to store hierarchy staging data
    ******************************************************************/
    public class PHSWrapper{

        public String phsRecordId;
        public Boolean isOverlapAtPHS;
        public Set<String> existingPHSForChidlIdSet;

    }
    
}