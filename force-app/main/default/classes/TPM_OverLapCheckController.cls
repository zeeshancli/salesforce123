/******************************************************************************************************
@Name            TPM_OverLapCheckController
@testclass       TPM_OverLapCheckControllerTest
@Author          PwC Team
@date            24 Mar, 2023
@description     Controller method for custom tpm_overlapcheckcard component 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.IdempotentOperations,PMD.UnusedLocalVariable')

global with sharing class TPM_OverLapCheckController implements System.Callable {
    
    //Map of string and promotion record
    static String recordId;
    static Set<String> productOfCurrentPromo = new Set<String>();
    static Map<String,TPM_Wrapper_OverLapCheck_Ext.ResponseBody> productTacticShipDateMap = new Map<String,TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
    static String sessionId;
    static List<cgcloud__Promotion__c> promoList =  new List<cgcloud__Promotion__c>();
    static TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper metadataValues = TPM_Utils_Extension.getMetadataForOverlapCheck();
    //List of promotion templates for which overlap check needs to be run
    static List<String> promotionTemplates = metadataValues.prodTemplate;

    static List<String> shortTermEventTemplates = new List<String>{'ShortTermEvent_Basic_IT01','ShortTermEvent_Basic_US01','ShortTermEvent_Intermediate_IT01','ShortTermEvent_Intermediate_US01'};
    
    //List of tactic types for whoch overlap checks need to be run
    static List<String> tacticTypes = metadataValues.tacticType;
    //List of tactic types for whoch overlap checks need to be run
    static List<String> phaseValues = metadataValues.phase;
    
    /*******************************************************************************************************
	* @Name          PromotionCardException
	* @Author        PwC Team
	* @date          24 Mar, 2023
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
        
        if(method == 'getPromotions'){
            return getPromotions(params);
        }  
        else {
            // Throw custom exception.
            throw new PromotionCardException('Exception in TPM_PromotionMainCardController');
        }
    }
    
    /*********************************************************************************************************
	@methodname   	getPromotions
	@createdDate  	24 Mar, 2023
	@param          params
	@return        String
	@description  	Method to get all promotions which are overlapping with existing promotions
	**********************************************************************************************************/
    public static String getPromotions(Map<String, Object> params){
        
        Map<String, Set<String>> tacticProductMap = new Map<String, Set<String>>();
        
        //Map<String,Object> resultMap = new Map<String,Object>();
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapPromoList = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticList = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticPromoList = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        try{
            //Get recordid of promotion
            recordId = String.valueOf(params.get('objId'));
            //Get promotion details for record id
            promoList = TPM_Utils_Extension.getDetailsForPromotion(recordId);
            if(params.containsKey('response')){
                Map<String,Object> resultMap = (Map<String,Object>) JSON.deserializeUntyped (JSON.serialize(params.get('response')));
                tacticProductMap = getTacticProductData(resultMap);
                //Get other promotion details
                overlapPromoList = getOverlappingPromotions(promoList[0]);
                
                //Add overlapping promotions
                overlapTacticPromoList.addAll(overlapPromoList);

                overlapTacticList = getTacticData(recordId,tacticProductMap);
                
                //Add overlapping tactics
                overlapTacticPromoList.addAll(overlapTacticList);                
            }
            TPM_OverLapCheckControllerExtension.updatePromoDetails(overlapTacticPromoList,recordId,promoList[0].TPM_Phase__c);
        }
        catch(Exception exp) {
            //error logging operations
            cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
            promoUpdate.id = recordid;
            promoUpdate.cgcloud__Skip_Version_Update__c = true;
            promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
            promoUpdate.TPM_Overlap_Check__c = '';
            promoUpdate.TPM_Overlap_Details__c = '';
            promoUpdate.cgcloud__Active__c = false;
            Database.SaveResult saveResultVar = Database.update(promoUpdate);
            TPM_Utils.createException(exp,TPM_ConstantsUtility.ERROR,TPM_ConstantsUtility.TPMOVERLAPCHECKCONTROLLER);
        }
        //Return overlapping promotions and tactic
        return JSON.serialize(overlapTacticPromoList);        
    }
    
    /******************************************************************************************************** 
	@methodname 	getTacticProductData
	@param          resultMap
	@return         Map<String, Set<String>>
	@description	method to fetch the get tactic product data.
	*********************************************************************************************************/ 
    public static Map<String, Set<String>> getTacticProductData(Map<String,Object> resultMap) {
        
        //Map of promotion id and its related products
        Map<String, Set<String>> tacticProdMapTemp = new Map<String, Set<String>>();
        Map<String,String> productExternalIdDescriptionMap = new  Map<String,String>();
        
        //Loop the response obtained from endpoint 
        for(Object obj : ( List< Object > )resultMap.get( 'measures' )){
            
            Map < String, Object > keyValPairMap = ( Map < String, Object > )obj;
            
            //Add products
            productOfCurrentPromo.add((String)keyValPairMap.get(TPM_ConstantsUtility.PRD));
        }
        //Get product decription
        productExternalIdDescriptionMap = TPM_OverLapCheckControllerExtension.getProductDescriptionForTactic(productOfCurrentPromo);
        
        for(Object obj : ( List< Object > )resultMap.get( 'measures' )){
            
            Map < String, Object > keyValPairMap = ( Map < String, Object > )obj;
            if(string.isNotBlank(((String)keyValPairMap.get(TPM_ConstantsUtility.TAC))) && string.isNotBlank(((String)keyValPairMap.get(TPM_ConstantsUtility.PRD))) ){
                
                if(!tacticProdMapTemp.containsKey((String)keyValPairMap.get(TPM_ConstantsUtility.TAC))){
                    // If product and tactic combination doesnot exist create a new record
                    tacticProdMapTemp.put((String)keyValPairMap.get(TPM_ConstantsUtility.TAC),new Set<String>{productExternalIdDescriptionMap.get((String)keyValPairMap.get(TPM_ConstantsUtility.PRD))});
                }
                else{
                    // If product and tactic combination already exist update with new products
                    tacticProdMapTemp.get((String)keyValPairMap.get(TPM_ConstantsUtility.TAC)).add(productExternalIdDescriptionMap.get((String)keyValPairMap.get(TPM_ConstantsUtility.PRD)));
                }
            }
        }
        return tacticProdMapTemp;
        
    }
    
    
    /******************************************************************************************************** 
	@methodname 	getOtherPromotionData
	@param          accId
	@param          promoTemp
	@return         Set<TPM_Wrapper_OverLapCheck.ResponseBody>
	@description	method to get product data of other promotions.
	*********************************************************************************************************/ 
    public static Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> getOtherPromotionData(String accId,List<String> promoTemp) {
        
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapPromoListTemp = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        
        //Get other promotion details based on account and promotion templae and phase values from metadata
        for(cgcloud__Promotion__c promoRec : [SELECT id,
                                              cgcloud__Anchor_Account__c,
                                              cgcloud__Sales_Org__c,
                                              TPM_Phase__c,
                                              cgcloud__Promotion_Template__c,
                                              cgcloud__Delivery_Date_From__c,
                                              cgcloud__Delivery_Date_Thru__c,
                                              cgcloud__Slogan_Language_1__c
                                              FROM cgcloud__Promotion__c
                                              WHERE cgcloud__Anchor_Account__c = : accId
                                              AND cgcloud__Promotion_Template__r.Name IN: promoTemp
                                              AND ID!=:recordId
                                              AND TPM_Phase__c IN:phaseValues
                                              FOR UPDATE]){
                                                  
                                                  //Set of products
                                                  Set<String> products = new Set<String>();
                                                  // check if overlap exists based on shipment period 
                                                  if(promoList[0].cgcloud__Delivery_Date_From__c <= promoRec.cgcloud__Delivery_Date_Thru__c && promoList[0].cgcloud__Delivery_Date_Thru__c >=promoRec.cgcloud__Delivery_Date_From__c){
                                                      
                                                      //if overlap exists get product details
                                                      HttpResponse responsenew = getPromotionData(promoRec.id,promoRec.cgcloud__Sales_Org__c);
                                                      
                                                      if(responsenew.getStatusCode() == 200) {
                                                          Map<String,Object> resultMap=(Map<String,Object>) JSON.deserializeUntyped(responsenew.getBody());
                                                          products = TPM_OverLapCheckControllerExtension.getProducts(resultMap,productOfCurrentPromo);
                                                      }
                                                      else {
                                                          TPM_OverLapCheckControllerExtension.errorLogDetails(responsenew);
                                                          break;
                                                      }
                                                      
                                                      if(!products.isEmpty()){
                                                          //Add promotions which are overlapping
                                                          TPM_Wrapper_OverLapCheck_Ext.ResponseBody overlapPromo = new TPM_Wrapper_OverLapCheck_Ext.ResponseBody();
                                                          overlapPromo.PromotionId = promoRec.id;
                                                          overlapPromo.PromotionName = promoRec.cgcloud__Slogan_Language_1__c;
                                                          //Join all products seperated by comma
                                                          overlapPromo.Product = String.join(new List<String>(products), ', ');
                                                          overlapPromo.ShipmentDateFrom = promoRec.cgcloud__Delivery_Date_From__c;
                                                          overlapPromo.ShipmentDateThrough = promoRec.cgcloud__Delivery_Date_Thru__c;
                                                          overlapPromoListTemp.add(overlapPromo);
                                                      }
                                                  } 
                                              }
        return overlapPromoListTemp;
    }
    
   
    
    
    
    /******************************************************************************************************** 
	@methodname 	getTacticData
	@param          recordId
	@param          tacticProductMap
	@return         Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>
	@description	method to fetch tactic related data.
	*********************************************************************************************************/ 
    public static Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> getTacticData(String recordId, Map<String, Set<String>> tacticProductMap) {
        
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticListTemp = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        
        //Get all tactics to check overlap
        List<cgcloud__Tactic__c> tacticList = [SELECT id,
                                               cgcloud__Payment_Method__c,
                                               cgcloud__Promotion__c ,
                                               cgcloud__Shipment_Date_From__c,
                                               cgcloud__Shipment_Date_Thru__c,
                                               cgcloud__Tactic_Template__r.name,
                                               cgcloud__Tactic_Template__r.TPM_Type__c
                                               FROM cgcloud__Tactic__c
                                               WHERE cgcloud__Promotion__c =:RecordId
                                               AND cgcloud__Payment_Method__c = 'OI'
                                               AND id IN:tacticProductMap.KeySet()
                                               AND cgcloud__Tactic_Template__r.TPM_Type__c IN:tacticTypes
                                               WITH SECURITY_ENFORCED];
        for(cgcloud__Tactic__c tacticRecFirst : tacticList){
            //Compare each tactic of same tactic types
            for(cgcloud__Tactic__c tacticRecSecond :  tacticList){
                TPM_Wrapper_OverLapCheck_Ext.ResponseBody overlapTacticListTempCheck = new TPM_Wrapper_OverLapCheck_Ext.ResponseBody();
                //Compare shipment date for overlap
                if(tacticRecSecond.id != tacticRecFirst.id && tacticRecSecond.cgcloud__Tactic_Template__r.TPM_Type__c == tacticRecFirst.cgcloud__Tactic_Template__r.TPM_Type__c){
                    //Add overlapping tactics
                    overlapTacticListTempCheck = getOverTactic(tacticRecFirst,tacticRecSecond,tacticProductMap);
                    if(overlapTacticListTempCheck.TacticName!=null){
                        overlapTacticListTemp.add(overlapTacticListTempCheck);
                    }
                }
            }
        }
        return overlapTacticListTemp;
    }
    
    /******************************************************************************************************** 
	@methodname 	getOverTactic
	@param          tacticRecFirst
	@param          tacticRecSecond
	@param          tacticProductMap
	@return         TPM_Wrapper_OverLapCheck_Ext.ResponseBody
	@description	method to fetch tactic records which are overlapping.
	*********************************************************************************************************/ 
    public static TPM_Wrapper_OverLapCheck_Ext.ResponseBody getOverTactic( cgcloud__Tactic__c tacticRecFirst,cgcloud__Tactic__c tacticRecSecond,Map<String, Set<String>> tacticProductMap) {
        
        Set<String> tacticRecthird = new Set<String>();   
        TPM_Wrapper_OverLapCheck_Ext.ResponseBody overlapTactic = new TPM_Wrapper_OverLapCheck_Ext.ResponseBody();
        if(tacticRecFirst.cgcloud__Shipment_Date_From__c <= tacticRecSecond.cgcloud__Shipment_Date_Thru__c && tacticRecFirst.cgcloud__Shipment_Date_Thru__c >=tacticRecSecond.cgcloud__Shipment_Date_From__c){
            //Check if there is any common data between tactics for overlap
            tacticRecthird.addAll(tacticProductMap.get(tacticRecFirst.id));
            tacticRecthird.retainAll(tacticProductMap.get(tacticRecSecond.id));
            //Final List of overlapping tactics     
            if(!tacticRecthird.isEmpty() && !productTacticShipDateMap.containsKey(tacticRecFirst.id+tacticRecFirst.cgcloud__Tactic_Template__r.name+ String.join(new List<String>(tacticRecthird), ', ')+tacticRecFirst.cgcloud__Shipment_Date_From__c+tacticRecFirst.cgcloud__Shipment_Date_Thru__c)){
                overlapTactic.tacticId = tacticRecFirst.id;
                overlapTactic.tacticName = tacticRecFirst.cgcloud__Tactic_Template__r.name;
                //Add products
                overlapTactic.product = String.join(new List<String>(tacticRecthird), ', ');
                overlapTactic.shipmentDateFrom = tacticRecFirst.cgcloud__Shipment_Date_From__c;
                overlapTactic.shipmentDateThrough = tacticRecFirst.cgcloud__Shipment_Date_Thru__c;
            }
            productTacticShipDateMap.put(tacticRecFirst.id+tacticRecFirst.cgcloud__Tactic_Template__r.name+String.join(new List<String>(tacticRecthird), ', ')+tacticRecFirst.cgcloud__Shipment_Date_From__c+tacticRecFirst.cgcloud__Shipment_Date_Thru__c,overlapTactic);
        }
        return overlapTactic;
    }
    
    
    
    /******************************************************************************************************** 
	@methodname 	getPromotionData
	@param          recordId
	@param          salesOrg
	@return         HttpResponse
	@description	call to get promotion data from Hyperforce.
	*********************************************************************************************************/ 
    public static HttpResponse getPromotionData(String recordId, String salesOrg) {
        //Make callout and get details related to promotion and tactic for which overlap check is beong done
        HttpRequest requestTemp = new HttpRequest();
        requestTemp.setMethod('GET');
        requestTemp.setHeader('Content-Type', 'application/json;charset=UTF-8');
        requestTemp.setEndpoint('callOut:TPM_Hyperforce_Get_Promotion'+'/v2/promotions/'+recordId+'/all/list?salesorg='+salesOrg+'&timeblock=customperiod');
        Http http = new Http();
        HttpResponse responseTemp = http.send(requestTemp);
        return responseTemp;
    }
  
    /******************************************************************************************************** 
	@methodname 	getOverlappingPromotions
	@param          promoRecord
	@return        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>
	@description	get Overlapped promotions
	*********************************************************************************************************/ 
    public static Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> getOverlappingPromotions(cgcloud__Promotion__c promoRecord) {
        
            Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapPromoListTemp = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
            List<String> steTemplates = new List<String>();
            if(promotionTemplates.contains(promoRecord.cgcloud__Promotion_Template__r.Name) && (shortTermEventTemplates.contains(promoRecord.cgcloud__Promotion_Template__r.Name))
                   &&  promoRecord.TPM_Overlap_Check__c != TPM_ConstantsUtility.NOOVERLAPFOUND
                   &&  promoRecord.TPM_Phase__c.equals(TPM_ConstantsUtility.PHASE_PLANNING)) {
                    steTemplates.add(promoRecord.cgcloud__Promotion_Template__r.Name);
                    steTemplates.add('Child_ShortTermEvent_IT01');
                    overlapPromoListTemp = getOtherPromotionData(promoRecord.cgcloud__Anchor_Account__c,steTemplates);
                }
                else if(promotionTemplates.contains(promoRecord.cgcloud__Promotion_Template__r.Name)
                &&  promoRecord.TPM_Overlap_Check__c != TPM_ConstantsUtility.NOOVERLAPFOUND
                &&  promoRecord.TPM_Phase__c.equals(TPM_ConstantsUtility.PHASE_PLANNING)){
                    steTemplates.add(promoRecord.cgcloud__Promotion_Template__r.Name);
                    overlapPromoListTemp = getOtherPromotionData(promoRecord.cgcloud__Anchor_Account__c,steTemplates);
                }

            return overlapPromoListTemp;
    
        }
    }