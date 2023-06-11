/******************************************************************************************************
* @Name         : TPM_TacticConditionUtils
* @Test Class   : 
* @author       : PwC Team
* @date         : April 3, 2023
* @description  : 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_TacticConditionUtils {
    
    // To fetch tactic price reduction record type id. 
    public static final Id TACTIC_PRICERED_RTID = Schema.SObjectType.cgcloud__Tactic__c
        										  .getRecordTypeInfosByDeveloperName()
        										  .get(TPM_ConstantsUtility.PRICE_REDUCTION_RT).getRecordTypeId();
    
    
    /*************************************************************************************
	* @method         : fetchMatchingZMetadataAPI
	* @param            tacticId
	* @param            tacticDataMap
	* @param            zCodesMap
    * @return           String
	* @description    : 
	**************************************************************************************/
    public static String fetchMatchingZMetadataAPI(Id tacticId, Map<Id,cgcloud__Tactic__c> tacticDataMap, Map<String, TPM_ZCodeDefinition__mdt> zCodesMap){
        
        String zCodeAPIName = '';
        for(String codeMDTAPIName : zCodesMap.keySet()){
            Boolean isTacticType = isSameMatch(zCodesMap.get(codeMDTAPIName).TPM_TacticType__c, tacticDataMap.get(tacticId).cgcloud__Tactic_Template__r.TPM_Type__c);
            Boolean isPaymentMethod = isSameMatch(zCodesMap.get(codeMDTAPIName).TPM_PaymentMethod__c, tacticDataMap.get(tacticId).cgcloud__Payment_Method__c);
            Boolean isSalesOrg = isSameMatch(zCodesMap.get(codeMDTAPIName).TPM_PromotionType__c, tacticDataMap.get(tacticId).cgcloud__Promotion__r.cgcloud__Promotion_Template__r.TPM_Type__c);
            Boolean isPromotionType = isSameMatch(zCodesMap.get(codeMDTAPIName).TPM_RateBasis__c, tacticDataMap.get(tacticId).cgcloud__Compensation_Model__c);
            Boolean isRateBasis = isSameMatch(zCodesMap.get(codeMDTAPIName).TPM_SalesOrg__c, tacticDataMap.get(tacticId).cgcloud__Sales_Org__c);
            
            if(isSalesOrg && isRateBasis && isPromotionType && isTacticType && isPaymentMethod){
                zCodeAPIName = codeMDTAPIName;
                break;
            }
        }
        return zCodeAPIName;
    }
    
    
    /*************************************************************************************
	* @method         : isSameMatch
	* @param            valueLHS
	* @param            valueRHS
    * @return           Boolean
	* @description    : 
	**************************************************************************************/
    public static Boolean isSameMatch(String valueLHS, String valueRHS){
        return valueLHS == valueRHS;
    }
    
}