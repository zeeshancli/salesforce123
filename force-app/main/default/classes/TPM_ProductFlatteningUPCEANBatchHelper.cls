/******************************************************************************************************
* @Name         : TPM_ProductFlatteningUPCEANBatchHelper
* @Test Class   : TPM_ProductFlatteningCategoryBatchTest
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Helper class for batch apex - 'TPM_ProductFlatteningUPCEANBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_ProductFlatteningUPCEANBatchHelper {

    
    /*********************************************************************************
     @description    private Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_ProductFlatteningUPCEANBatchHelper(){
        
    }


    /********************************************************************************************
    * @method          prepareProductsForDMLOperation
    * @param           objScopeList
    * @param           childIdWithPHObjMap
    * @return          List<Product2>
    * @description     Method to prepare product records for update DML operation.
    *********************************************************************************************/
    @SuppressWarnings('PMD.IdempotentOperations')
    public static List<Product2> prepareProductsForDMLOperation(List<Product2> objScopeList, Map<String, cgcloud__Product_Hierarchy__c> childIdWithPHObjMap){

        List<Product2> productsReocrdsToUpdateList = new List<Product2>();

        // Loop through all the product records in scope.
        for(Product2 prdObj : objScopeList){

            if(childIdWithPHObjMap.containsKey(prdObj.Id)){

                Boolean isProductEligible = false;
                Product2 prdRecord = new Product2();
                prdRecord.Id = prdObj.Id;

                // To update the immediate parent's lookup.
                if(prdObj.cgcloud__Criterion_5_Product__c != childIdWithPHObjMap.get(prdObj.Id).cgcloud__Parent_Product__c){
                    prdRecord.cgcloud__Criterion_5_Product__c = childIdWithPHObjMap.get(prdObj.Id).cgcloud__Parent_Product__c;
                    isProductEligible = true;
                }

                // To check all scenarios even if immediate parent is not updated, because same immediate parent's can have different hierarchy,
                // so we need to update other lookups from immediate parant's new hierarchy.
                String criterion4Id = childIdWithPHObjMap.get(prdObj.Id).cgcloud__Parent_Product__r.cgcloud__Criterion_4_Product__c;
                if(prdObj.cgcloud__Criterion_4_Product__c != criterion4Id){
                    prdRecord.cgcloud__Criterion_4_Product__c = criterion4Id;
                    isProductEligible = true;
                }                
                
                String criterion3Id = childIdWithPHObjMap.get(prdObj.Id).cgcloud__Parent_Product__r.cgcloud__Criterion_3_Product__c;
                if(prdObj.cgcloud__Criterion_3_Product__c != criterion3Id){
                    prdRecord.cgcloud__Criterion_3_Product__c = criterion3Id;
                    isProductEligible = true;
                }
                
                String criterion2Id = childIdWithPHObjMap.get(prdObj.Id).cgcloud__Parent_Product__r.cgcloud__Criterion_2_Product__c;
                if(prdObj.cgcloud__Criterion_2_Product__c != criterion2Id){
                    prdRecord.cgcloud__Criterion_2_Product__c = criterion2Id;
                    isProductEligible = true;
                }
                
                String criterion1Id = childIdWithPHObjMap.get(prdObj.Id).cgcloud__Parent_Product__r.cgcloud__Criterion_1_Product__c;
                if(prdObj.cgcloud__Criterion_1_Product__c != criterion1Id){
                    prdRecord.cgcloud__Criterion_1_Product__c = criterion1Id;
                    isProductEligible = true;
                }
                
                if(isProductEligible){
                    productsReocrdsToUpdateList.add(prdRecord);
                }                 
            }
        }    

        return productsReocrdsToUpdateList;
    }

}