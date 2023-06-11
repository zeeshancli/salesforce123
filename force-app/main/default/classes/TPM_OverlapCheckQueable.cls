/******************************************************************************************************
@Name            TPM_OverlapCheckQueable
@testclass       TPM_OverlapCheckQueueTest
@Author          PwC Team
@date            April 28, 2023
@description     Perform Overlap check for Push Promotion
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_OverlapCheckQueable implements Queueable, Database.AllowsCallouts{
     
    //Global variables declaration
     String recordIdPromo;
     integer sentCount;
     Boolean ishitLimit;
     Boolean isconnectionFailure;
     public Set<String> childParentIdSet = new Set<String>();
     Map<String, Set<String>> tacticProductMap = new Map<String, Set<String>>();
     public List<String> childAccountIdList = new List<String>();
     Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew> overlapChildPromoSet = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew>();
     Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapParentPromoSet = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
     Map<String,String> childPromoAccountIdMap = new Map<String,String>();
     Map<String,String> childPromotionNameIdMap = new Map<String,String>();
     List<cgcloud__Promotion__c> otherPromoData = new List<cgcloud__Promotion__c>();
     List<cgcloud__Promotion__c> parentPromo = new List<cgcloud__Promotion__c>();
     Map<String,List<String>> parentChildMap = new Map<String,List<String>>();
     Map<String,TPM_Wrapper_OverLapCheck_Ext.ResponseBody> parentChildDetailsMap = new Map<String,TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
 

    
    /********************************************************************************************************** 
    @methodname 	TPM_OverlapCheckQueue
    @createdDate 	04/28/2023
    @param          recordid
    @description	Constructor	
    ************************************************************************************************************/ 
    public TPM_OverlapCheckQueable(String recordid) {
        
        try{    
                //record id
                recordIdPromo = recordid;
                childParentIdSet.add(recordIdPromo);
                //Map of parent promotion as key and child promotions as value
               
                //List<String> templateForPushOverLapCheck = new List<String>();
                //Get details of parent promotion
                parentPromo = TPM_Utils_Extension.getDetailsForPromotion(recordIdPromo);
                //Get all the child promotions for which push will happen and overlap checks needs to run
                childAccountIdList = TPM_OverlapCheckQueableExt.getExternalId(parentPromo[0].cgcloud__Push_Target_Account_Selection__c);
                
                //Prepare maps of child promotion details
                for(cgcloud__Promotion__c childPromo : [SELECT id,
                                                            cgcloud__Slogan__c,
                                                            cgcloud__Anchor_Account__c,
                                                            cgcloud__Sales_Org__c,
                                                            cgcloud__Delivery_Date_From__c,
                                                            cgcloud__Promotion_Template__c,
                                                            cgcloud__Delivery_Date_Thru__c,
                                                            cgcloud__Push_Target_Account_Selection__c 
                                                            FROM cgcloud__Promotion__c
                                                            WHERE cgcloud__Parent_Promotion__c = :recordIdPromo
                                                            AND cgcloud__Anchor_Account__c IN:childAccountIdList]){

                        childParentIdSet.add(childPromo.Id);
                        childPromoAccountIdMap.put(childPromo.cgcloud__Anchor_Account__c,childPromo.id);
                        childPromotionNameIdMap.put(childPromo.cgcloud__Anchor_Account__c,childPromo.cgcloud__Slogan__c);
                    }

                //Get the parent promotion and child promotion templates for which overlap checks need to run
                TPM_Wrapper_OverLapCheck_Ext.OverLapMetaDataWrapper metadataForOverLapChecks = TPM_Utils_Extension.getchildPromotemplateNames();

                parentChildMap=metadataForOverLapChecks.childPromotionTemplates;
                //templateForPushOverLapCheck = metadataForOverLapChecks.templateForOverLapChecks;

                
                //Get other promotions which are overlapping with the child promotions by comparing account
                //shipment dates,products and promotion template
                otherPromoData = TPM_Utils_Extension.getOtherPromotionData(childAccountIdList,parentChildMap.get(parentPromo[0].cgcloud__Promotion_Template__r.Name),childParentIdSet);
        }
        //catch exception if any
        catch(Exception exp) {
            //error logging operations
            TPM_Utils.createException(exp,TPM_ConstantsUtility.ERROR,TPM_ConstantsUtility.TPMOVERLAPCHECKQUEABLE);
        }

    }
    
    /********************************************************************************************************** 
    @methodname 	execute
    @createdDate 	04/28/2023
    @param          context
    @description	Execute Method to do callouts
    ************************************************************************************************************/ 
    public void execute(QueueableContext context){
        //count limit will be 0
        this.sentCount = 0;
        this.ishitLimit = false;
        this.isconnectionFailure = false;
        Set<String> productSet = new Set<String>();
        try{
        Map<String,Object> resultMap = new Map<String,Object>();
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticList = new  Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticPromoList = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
        TPM_Wrapper_OverLapCheck_Ext.ParentChildWrapper overlapPromoListTemp = new TPM_Wrapper_OverLapCheck_Ext.ParentChildWrapper();
        //Do callout and get data from hyperforce
        HttpResponse response = TPM_OverLapCheckController.getPromotionData(this.recordIdPromo,this.parentPromo[0].cgcloud__Sales_Org__c);
        //If response is success put products in a map       
        if(response.getStatusCode() == 200) {
               resultMap=(Map<String,Object>) JSON.deserializeUntyped(response.getBody());
               productSet=TPM_OverlapCheckQueableExt.getProductsOfParentPromo(resultMap);
        //Run tactic overlap checks for parent promotion
        this.tacticProductMap = TPM_OverLapCheckController.getTacticProductData(resultMap);
        overlapTacticList = TPM_OverLapCheckController.getTacticData(this.recordIdPromo,this.tacticProductMap);
     
       //If phase is planning and no overlap found then dont run overlap checks for promotions 
        if(this.parentChildMap.containsKey(this.parentPromo[0].cgcloud__Promotion_Template__r.Name) && this.parentPromo[0].TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING && this.parentPromo[0].TPM_OverLap_Check_Status__c != TPM_ConstantsUtility.NOOVERLAPFOUND){
            //Get all overlapping promotions
            overlapPromoListTemp = getOverlappingPromotion(this.otherPromoData,this.ishitLimit,this.sentCount,productSet);          
            this.overlapChildPromoSet.addAll(overlapPromoListTemp.childPromotions);
            this.overlapParentPromoSet.addAll(overlapPromoListTemp.parentPromotions);
          }
          //If connectivity to hyperforce fails then abort the overlap checks
          if(this.isconnectionFailure){
     
            TPM_OverlapCheckQueableExt.updateParentChildPromotions(this.recordIdPromo,this.childPromoAccountIdMap,'Connection Failure');
            return;
          }
          
          //Check if callout limit is reached and call another queable class
          enqueueQueable();
              
            if(!this.overlapParentPromoSet.isEmpty()){
                overlapTacticPromoList.addAll(overlapParentPromoSet);
            }
            //Add overlapping tactics
            if(!overlapTacticList.isEmpty()){
                overlapTacticPromoList.addAll(overlapTacticList);
            }
            //Update parent promotion and child promotion with overlap status
            TPM_OverlapCheckQueableExt.updateParentChildPromotion(overlapTacticPromoList,this.recordIdPromo,this.childPromoAccountIdMap,this.overlapChildPromoSet);
        
              
            }
            else{
                //If no products found then publish this message
                TPM_OverlapCheckQueableExt.publishEvent('No Products Found',this.recordIdPromo);
                TPM_OverlapCheckQueableExt.updateParentChildPromotions(this.recordIdPromo,this.childPromoAccountIdMap,'No Products Found');
            }
        }
            catch(Exception exp) {
                //error logging operations
                TPM_Utils.createException(exp,TPM_ConstantsUtility.ERROR,TPM_ConstantsUtility.TPMOVERLAPCHECKQUEABLE);
            }
        }

    /******************************************************************************************************** 
    @methodname 	getProducts
	@param          resultMapOtherPromo
    @param          productSet
    @return         Set<String>
    @description	method to compare products of other promotions with current promotion.
    *********************************************************************************************************/ 
    public  Set<String> getProducts(Map<String,Object> resultMapOtherPromo,Set<String> productSet){
      
        Set<String> products = new Set<String>();
        Set<String> productsName = new Set<String>();
        for(Object obj : ( List< Object > )resultMapOtherPromo.get( 'measures' )){
            //Store all products in a map
                Map < String, Object > keyValPairMap = ( Map < String, Object > )obj;
                //Compare if product of other promotions are same as current promotion
                if(String.isNotBlank((String)keyValPairMap.get(TPM_ConstantsUtility.PRD)) && productSet.contains((String)keyValPairMap.get(TPM_ConstantsUtility.PRD)) && !products.contains((String)keyValPairMap.get(TPM_ConstantsUtility.PRD))){
                    products.add((String)keyValPairMap.get(TPM_ConstantsUtility.PRD));
                }
            }
            
            //Get description of products to be displayed on overlap table
            for(Product2 productNamesTemp : [SELECT id,
                                                cgcloud__Description_1__c
                                                FROM Product2
                                                WHERE cgcloud__Consumer_Goods_External_Product_Id__c IN:products
                                                WITH SECURITY_ENFORCED]){
                productsName.add(productNamesTemp.cgcloud__Description_1__c);   
                  
            }

            return productsName;
  
    }
    
    /******************************************************************************************************** 
    @methodname 	getOverlappingPromotion
	@param          otherPromoData
    @param          hitLimit
    @param          sentCount
    @param          productSet
    @return         TPM_Wrapper_OverLapCheck_Ext.ParentChildWrapper
    @description	method to fetch other promotions which are overlapping
    *********************************************************************************************************/ 
    public  TPM_Wrapper_OverLapCheck_Ext.ParentChildWrapper getOverlappingPromotion(List<cgcloud__Promotion__c> otherPromoData,Boolean hitLimit,Integer sentCount,Set<String> productSet){
     //Get other promotion details based on account and promotion templae and phase values from metadata
     Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew> overlappingPromoList = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew>();
     Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlappingParentPromoList = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
     
     //Loop all other promotions and check one by one
     for(cgcloud__Promotion__c promoRec : otherPromoData){

        Set<String> productsTemp = new Set<String>();
        //If callout limits are reached call another queable class to process remaining records
        if (Limits.getCallouts() == Limits.getLimitCallouts()){
                this.ishitLimit = true;
                break;
            }
            //Set of products
            // check if overlap exists based on shipment  period 
            if(parentPromo[0].cgcloud__Delivery_Date_From__c <= promoRec.cgcloud__Delivery_Date_Thru__c && this.parentPromo[0].cgcloud__Delivery_Date_Thru__c >=promoRec.cgcloud__Delivery_Date_From__c){
                
                    //if overlap exists get product details
                    HttpResponse responsenew = TPM_OverLapCheckController.getPromotionData(promoRec.id,promoRec.cgcloud__Sales_Org__c);
                    
                    //If response is success compare products
                    if(responsenew.getStatusCode() == 200) {
                        Map<String,Object> resultMapOtherPromo=(Map<String,Object>) JSON.deserializeUntyped(responsenew.getBody());
                        productsTemp = getProducts(resultMapOtherPromo,productSet);
                         }
                    else {
                        this.isconnectionFailure = true;
                        TPM_OverLapCheckControllerExtension.errorLogDetails(responsenew);
                        break;
                        }
                
                    if(!productsTemp.isEmpty() && !this.parentChildDetailsMap.containsKey(promoRec.cgcloud__Anchor_Account__c)){
                            //Add promotions which are overlapping and also use detials to update parent promotion
                            TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew overlapPromo = new TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew();
                            overlapPromo.accountId = promoRec.cgcloud__Anchor_Account__c;
                            overlapPromo.PromotionId = promoRec.id;
                            overlapPromo.PromotionName = promoRec.cgcloud__Slogan_Language_1__c;
                            //Join all products seperated by comma
                            overlapPromo.Product = String.join(new List<String>(productsTemp), ', ');
                            overlapPromo.ShipmentDateFrom = promoRec.cgcloud__Delivery_Date_From__c;
                            overlapPromo.ShipmentDateThrough = promoRec.cgcloud__Delivery_Date_Thru__c;
                            overlappingPromoList.add(overlapPromo);
                            TPM_Wrapper_OverLapCheck_Ext.ResponseBody overlapParentPromo = new TPM_Wrapper_OverLapCheck_Ext.ResponseBody();
                            overlapParentPromo.PromotionId = this.childPromoAccountIdMap.get(promoRec.cgcloud__Anchor_Account__c);
                            overlapParentPromo.PromotionName = this.childPromotionNameIdMap.get(promoRec.cgcloud__Anchor_Account__c);
                            //Join all products seperated by comma
                            overlapParentPromo.Product = String.join(new List<String>(productsTemp), ', ');
                            overlapParentPromo.ShipmentDateFrom = this.parentPromo[0].cgcloud__Delivery_Date_From__c;
                            overlapParentPromo.ShipmentDateThrough = this.parentPromo[0].cgcloud__Delivery_Date_Thru__c ;
                            overlappingParentPromoList.add(overlapParentPromo);
                            this.parentChildDetailsMap.put(promoRec.cgcloud__Anchor_Account__c,overlapParentPromo);
                            }
                    else if(!productsTemp.isEmpty()){

                            TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew overlapPromo = new TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew();
                            overlapPromo.accountId = promoRec.cgcloud__Anchor_Account__c;
                            overlapPromo.PromotionId = promoRec.id;
                            overlapPromo.PromotionName = promoRec.cgcloud__Slogan_Language_1__c;
                            //Join all products seperated by comma
                            overlapPromo.Product = String.join(new List<String>(productsTemp), ', ');
                            overlapPromo.ShipmentDateFrom = promoRec.cgcloud__Delivery_Date_From__c;
                            overlapPromo.ShipmentDateThrough = promoRec.cgcloud__Delivery_Date_Thru__c;
                            overlappingPromoList.add(overlapPromo);
                            }

                            }
                    this.sentCount++;
                 }       
             
            //Prepare a wrapper of parent and child promotions
            TPM_Wrapper_OverLapCheck_Ext.ParentChildWrapper childParentPromo = new TPM_Wrapper_OverLapCheck_Ext.ParentChildWrapper();
            childParentPromo.childPromotions = overlappingPromoList;
            childParentPromo.parentPromotions = overlappingParentPromoList;
            
            return childParentPromo;
    }
    

    /******************************************************************************************************** 
    @methodname 	enqueueQueable
    @description	method to call another queeable class to process remaining records if callout limit is reached.
    *********************************************************************************************************/ 
    public  void  enqueueQueable(){

    if (this.ishitLimit) {
        // Need to chain this queueable to finish processing. First clean up
        // the list of leads needing a callout, removing all those that have
        // been sent already
        for (Integer index = 0; index < this.sentCount; index++) {
                this.otherPromoData.remove(0);
             }

        // Now ensure the remainder get processed by simply re-enqueuing this
        // queueable with its adjusted state
        System.enqueueJob(this);
        }
    }
}