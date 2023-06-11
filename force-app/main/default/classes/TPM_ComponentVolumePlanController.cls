/******************************************************************************************************
@Name            TPM_ComponentVolumePlanController
@testclass       TPM_ComponentVolumePlanController
@Author          PwC Team
@date            28 March, 2023
@description     Controller method for custom tpm_promotionMainCard component for executing 
				 Component Volume for Display Shipper Method
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class TPM_ComponentVolumePlanController implements System.Callable {
    
	static final String PARAM_OBJID = 'objId';
    static final String PROMOTION_TIME_BLOCK = 'customperiod';
    static final String BOM_PROMO_TEMPLATE = 'ConsiderBOMs';
    static final String PROMO_PREPARATION_PHASE = 'Draft';
    static final String PROMO_PLANNING_PHASE = 'Planning';
    
    /************************************************************
    * @Name          ComponentVolumePlanControllerException
    * @description   Exception Class to throw custom exception
    *************************************************************/
    global class ComponentVolumePlanControllerException extends Exception {}


    /******************************************************************** 
    @methodname 	call
    @param          method
	@param          params
    @return         Object
    @description	callable interface method
    *********************************************************************/
    public Object call(String method, Map<String, Object> params) {

        // Both method and params will be received
        if(method == 'executeComponentVolumeDisplayShipper'){
            return executeComponentVolumeDisplayShipper(params);
        }
        else {
            
            // Throw custom exception.
            throw new ComponentVolumePlanControllerException('Exception in TPM_ComponentVolumePlanController');
        }
    }

	/***************************************************************************************************
    * @method          executeComponentVolumeDisplayShipper
    * @param           params
    * @return          boolean
    * @description     Method to call Display Shipper Volumes to calculate the
    * 				   component volume for display products.
    ****************************************************************************************************/
    private static boolean executeComponentVolumeDisplayShipper(Map<String, Object> params) {
        
        // Extract parameter Promotione Record Id
        String objectRecordId = String.valueOf(params.get(PARAM_OBJID));
        Boolean isPlanningMethodInvoked = false;
		Boolean isMethodInvoked = false ;
        
        // If Record found
        if(objectRecordId != null){
            // Get the corresponding Promotion Record
            cgcloud__Promotion__c promotionObj = [SELECT  Id, 
                                                          Name, 
                                                          cgcloud__Active__c, 
                                                          cgcloud__Promotion_Template__c,
                                                          cgcloud__Promotion_Template__r.cgcloud__BOM_Handler__c,
                                                  		  cgcloud__Anchor_Account__r.cgcloud__Account_Number__c,
                                                          cgcloud__Anchor_Account__r.cgcloud__ExternalId__c,
                                                  		  cgcloud__ExternalId__c,
                                                          cgcloud__Placement_Date_From__c,
                                                          cgcloud__Placement_Date_Thru__c,
                                                          cgcloud__Delivery_Date_From__c,
                                                          cgcloud__Delivery_Date_Thru__c,
                                                          cgcloud__Commit_Date__c,
                                                          cgcloud__Date_From__c,
                                                          cgcloud__Date_Thru__c,
                                                          cgcloud__Sales_Org__c,
                                                          cgcloud__Phase__c,
                                                          TPM_Phase__c
                                                  FROM 	  cgcloud__Promotion__c 
                                                  WHERE   Id =: objectRecordId 
                                                  AND 	  cgcloud__Active__c = TRUE
                                                  AND	  cgcloud__Promotion_Template__r.cgcloud__BOM_Handler__c =: BOM_PROMO_TEMPLATE
                                                  AND 	  TPM_Phase__c !=: PROMO_PREPARATION_PHASE];
            
            // If corresponding Promotion Record found successfully
            if(promotionObj != NULL && promotionObj.TPM_Phase__c == PROMO_PLANNING_PHASE){
                // Call the Component Volume Display Shipper method 
                // Params : Promotion Record Object
                isPlanningMethodInvoked = True;
                TPM_ComponentVolumeWebService.getDataForPromotionCustomPeriod(promotionObj, isPlanningMethodInvoked );
                isMethodInvoked = isPlanningMethodInvoked;
            }  
        }
        return isMethodInvoked;
    }
}