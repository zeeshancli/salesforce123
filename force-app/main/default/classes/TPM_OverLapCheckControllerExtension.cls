/******************************************************************************************************
@Name            TPM_OverLapCheckControllerExtension
@testclass       TPM_OverLapCheckControllerExtensionTest
@Author          PwC Team
@date            24 Mar, 2023
@description     Controller method for custom tpm_overlapcheckcard component 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.IdempotentOperations,PMD.UnusedLocalVariable')
global with sharing class TPM_OverLapCheckControllerExtension implements System.Callable {
    /*******************************************************************************************************
    * @Name          PromotionCardException
    * @Author        PwC Team
    * @date          28 Feb, 2023
    * @description   Exception Class to throw Custom Exceptions
    *******************************************************************************************************
    Change History Story      Modified by               Date                          Desc

    *******************************************************************************************************/
    global class PromotionCardException extends Exception {}
   

    /******************************************************************************************************** 
    @methodname 	call
    @param          method
	@param          params
    @return         Object
    @description	callable interface method
    *********************************************************************************************************/ 
    public Object call(String method, Map<String, Object> params) {
       //Call fetchProductData
       Switch on method{
            when 'fetchProductData'{
                return fetchProductData(params);
            }
            when 'getProductDetails'{
                return getProductDetails(params);
            }
            when else {
                throw new PromotionCardException('Exception in TPM_PromotionMainCardController');
            }
        }
    }
 

    /******************************************************************************************************** 
    @methodname 	fetchProductData
	@param          params
    @return         TPM_Wrapper_OverLapCheck_Ext.ProdCustomLabelData 
    @description	method to fetch product data.
    *********************************************************************************************************/ 
    public static String fetchProductData(Map<String, Object> params) {
        
        TPM_Wrapper_OverLapCheck_Ext.ProdCustomLabelDataPushPromo prodLabelData = new TPM_Wrapper_OverLapCheck_Ext.ProdCustomLabelDataPushPromo();
        Map<String,String> labels = new Map<String,String>();
        List<String> parentPromotionTemplates = new List<String>();
        // Validate parameters
        if (params == null || String.isBlank((String) params.get('objId')) == null) {
            return JSON.serialize(prodLabelData);
        }
        
        // Extract parameter.
        String objectRecordId = String.valueOf(params.get('objId'));
       
        List<cgcloud__Promotion__c> prodData = [SELECT Id, 
                                                        cgcloud__Promotion_Template__c, 
                                                        cgcloud__Promotion_Template__r.name,
                                                        TPM_Phase__c,
                                                        TPM_Push_Failed__c,
                                                        TPM_Overlap_Check_In_Progress__c,
                                                        TPM_Overlap_Details__c
                                                        FROM cgcloud__Promotion__c 
                                                        WHERE Id = :objectRecordId LIMIT 1];
        labels.put('Overlap',System.Label.TPM_Overlapping_Message);
        labels.put('Success',System.Label.TPM_Overlap_Check_Success);
        labels.put('Products',System.Label.TPM_Overlap_Check_Products);
        labels.put('NoProducts',System.Label.TPM_Missing_Products);
        labels.put('NoOverlap',System.Label.TPM_No_Overlap_Found);
        labels.put('Push',System.Label.TPM_Push_Promotion_Message);
        labels.put('PushMessage',System.Label.TPM_OverLap_Push_Message);
        labels.put('PushFail',System.Label.TPM_Push_Fail);
        labels.put('NoPhaseChange',System.Label.TPM_Phase_Change);
        labels.put('Ispreventsubmitforapproval',System.Label.TPM_Promotion_IsActivePreventForApproval);
        labels.put('PushProgress',System.Label.TPM_Overlap_In_Progress);
        //List<String> childPromoTemplate = TPM_Utils_Extension.getchildPromotemplateNames().templateForOverLapChecks; 
        parentPromotionTemplates = TPM_Utils_Extension.getchildPromotemplateNames().templateForOverLapChecks; 
        prodLabelData.promotionData = prodData;
        prodLabelData.label = labels;
        prodLabelData.parentPromotionTemplates = parentPromotionTemplates;
        return JSON.serialize(prodLabelData);
      }

    /******************************************************************************************************** 
    @methodname 	getProductDetails
	@param          params
    @return         Set<String>
    @description	method to fetch products to check if promotion contains atleast one product.
    *********************************************************************************************************/
    public static String getProductDetails(Map<String, Object> params) { 
        
        TPM_Wrapper_OverLapCheck_Ext.ProdResponseData productResponse = new TPM_Wrapper_OverLapCheck_Ext.ProdResponseData();
        Map<String,Object> resultMap = new Map<String,Object>();
        String recordId = String.valueOf(params.get('objId'));
        //Get Details of current promotion
         List<cgcloud__Promotion__c> promoRec = TPM_Utils_Extension.getDetailsForPromotion(recordId);
        //Set of products
        Set<String> productSet = new Set<String>();
        //Callout
        HttpResponse response = TPM_OverLapCheckController.getPromotionData(recordId,promoRec[0].cgcloud__Sales_Org__c);
        //If response is success put products in a mao       
        if(response.getStatusCode() == 200) {
            resultMap=(Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            for(Object obj : ( List< Object > )resultMap.get( 'measures' )){
                    Map < String, Object > keyValPairMap = ( Map < String, Object > )obj;
                    if(string.isNotBlank(((String)keyValPairMap.get(TPM_ConstantsUtility.PRD)))){
                           productSet.add((String)keyValPairMap.get(TPM_ConstantsUtility.PRD));
                    }
                }
        
                //If no products is there make status from planning to draft and active field
                //as false
                if(productSet.isEmpty()){
                    cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                    promoUpdate.id = recordid;
                    promoUpdate.cgcloud__Skip_Version_Update__c = true;
                    promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                    promoUpdate.TPM_Overlap_Check__c = '';
                    promoUpdate.TPM_Overlap_Details__c = '';
                    promoUpdate.cgcloud__Active__c = false;
                    //Update promotion record
                    Database.SaveResult saveResultVar = Database.update(promoUpdate);
                }
        }
                
        else {
                //Store in logger object
                cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                promoUpdate.id = recordid;
                promoUpdate.cgcloud__Skip_Version_Update__c = true;
                promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                promoUpdate.TPM_Overlap_Check__c = '';
                promoUpdate.TPM_Overlap_Details__c = '';
                promoUpdate.cgcloud__Active__c = false;
                //Update promotion record
                Database.SaveResult saveResultVar = Database.update(promoUpdate);
                TPM_OverLapCheckControllerExtension.errorLogDetails(response);
        
            }
        productResponse.productData = productSet;
        productResponse.responseBodyValue = resultMap;
        return JSON.serialize(productResponse);
     }



    /******************************************************************************************************** 
    @methodname 	updatePromoDetails
    @param          overlapTacticPromoList
    @param          recordId
    @param          phase
    @description	method to update active and status field of promotion
    *********************************************************************************************************/ 
    public static void updatePromoDetails(Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticPromoList,String recordId,String phase){
            
                    if(!overlapTacticPromoList.isEmpty()){
                        //If overlap found update active as false and status as overlap found
                        //and status as draft
                        cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                        promoUpdate.id = recordid;
                        promoUpdate.cgcloud__Skip_Version_Update__c = true;
                        promoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.OVERLAPFOUND;
                        promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                        promoUpdate.cgcloud__Active__c = false;
                        promoUpdate.TPM_Overlap_Details__c = JSON.serialize(overlapTacticPromoList);
                        Database.SaveResult saveResultVar = Database.update(promoUpdate);
                    }
                    else if(phase == TPM_ConstantsUtility.PHASE_PLANNING){ 
                        //If no overlap found update active as true and status as No Overlap found and 
                        //status as planning
                        cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                        promoUpdate.id = recordid;
                        promoUpdate.cgcloud__Skip_Version_Update__c = true;
                        promoUpdate.TPM_Overlap_Details__c = null;
                        promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_PLANNING;
                        promoUpdate.cgcloud__Active__c = true;
                        promoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                        Database.SaveResult saveResultVar = Database.update(promoUpdate);
                    }
                    else if(phase == TPM_ConstantsUtility.PHASE_SUBMITTEDFORAPPROVAL){

                         //If no overlap found update active as true and status as No Overlap found and 
                        //status as planning
                        cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                        promoUpdate.id = recordid;
                        promoUpdate.cgcloud__Skip_Version_Update__c = true;
                        promoUpdate.TPM_Overlap_Details__c = null;
                        promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_SUBMITTEDFORAPPROVAL;
                        promoUpdate.cgcloud__Active__c = true;
                        promoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                        Database.SaveResult saveResultVar = Database.update(promoUpdate);


                    }
                    
             }

    /******************************************************************************************************** 
    @methodname 	errorLogDetails
    @param          response
    @description	method to do store error status if status is not 200
    *********************************************************************************************************/ 
    public static void errorLogDetails(HttpResponse response) {
        
        //Store records in logger object
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        TPM_LoggerException.LogsWrapper logsObj = new TPM_LoggerException.LogsWrapper();
        logsObj.className = TPM_ConstantsUtility.TPMOVERLAPCHECKCONTROLLER;
        logsObj.methodName = TPM_ConstantsUtility.GET_DATA_FOR_SINGLE_PROMOTION;
        //use status code
        logsObj.errorMessage = TPM_ConstantsUtility.GET_DATA_SINGLE_PROMOTION_ERROR +' ' + response.getStatusCode() + response.getStatus();
        exceptionWrapperList.add(logsObj);
        TPM_LoggerException.log(exceptionWrapperList);
    }
           

    /******************************************************************************************************** 
    @methodname 	getProductDescriptionForTactic
	@param          productOfCurrentPromo
    @return         Map<String,String>
    @description	method to fetch decription of products for tactic.
    *********************************************************************************************************/ 
    public static Map<String,String> getProductDescriptionForTactic(Set<String> productOfCurrentPromo) {
        Map<String,String> productExternalIdDescriptionMap = new Map<String,String>();

        for(Product2 productNames : [SELECT id,
                                            Name,
                                            cgcloud__Description_1__c,
                                            cgcloud__Consumer_Goods_External_Product_Id__c
                                            FROM Product2
                                            WHERE cgcloud__Consumer_Goods_External_Product_Id__c IN:productOfCurrentPromo
                                            WITH SECURITY_ENFORCED]){
    
    
            productExternalIdDescriptionMap.put(productNames.cgcloud__Consumer_Goods_External_Product_Id__c,productNames.cgcloud__Description_1__c);                     
        }


            return productExternalIdDescriptionMap;
    }

     /******************************************************************************************************** 
	@methodname 	getProducts
	@param          resultMap
    @param          productOfCurrentPromo
	@return         Set<String>
	@description	method to fetch the products of promotion.
	*********************************************************************************************************/ 
    public static Set<String> getProducts( Map<String,Object> resultMap,Set<String> productOfCurrentPromo) {
        //Set of products
        Set<String> productsTemp = new Set<String>();
        Set<String> productsName = new Set<String>();
        for(Object obj : ( List< Object > )resultMap.get( 'measures' )){
            //Store all products in a map
            Map < String, Object > keyValPairMap = ( Map < String, Object > )obj;
            if(String.isNotBlank((String)keyValPairMap.get(TPM_ConstantsUtility.PRD)) && productOfCurrentPromo.contains((String)keyValPairMap.get(TPM_ConstantsUtility.PRD)) && !productsTemp.contains((String)keyValPairMap.get(TPM_ConstantsUtility.PRD))){
                productsTemp.add((String)keyValPairMap.get(TPM_ConstantsUtility.PRD));
            }
        }
        
        for(Product2 productNames : [SELECT id,
                                     cgcloud__Description_1__c
                                     FROM Product2
                                     WHERE cgcloud__Consumer_Goods_External_Product_Id__c IN:productsTemp
                                     WITH SECURITY_ENFORCED]){
                                         productsName.add(productNames.cgcloud__Description_1__c);                      
                                     }
        
        
        return productsName;
    }
}