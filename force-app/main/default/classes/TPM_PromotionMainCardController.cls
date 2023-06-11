/******************************************************************************************************
@Name            TPM_PromotionMainCardController
@testclass       TPM_PromotionMainCardControllerTest
@Author          PwC Team
@date            28 Feb, 2023
@description     Controller method for custom tpm_promotionMainCard component 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.ExcessivePublicCount,PMD.CyclomaticComplexity')
global with sharing class TPM_PromotionMainCardController implements System.Callable {


    static final String TYPE_PROMOTION = 'Promotion';
    static final String PARAM_OBJID = 'objId';

    /************************************************************
    * @Name          PromotionCardException
    * @description   Exception Class to throw custom exception
    *************************************************************/
    global class PromotionCardException extends Exception {}


    /******************************************************************** 
    @methodname 	call
    @param          method
	@param          params
    @return         Object
    @description	callable interface method
    *********************************************************************/
    public Object call(String method, Map<String, Object> params) {        
        
        // Both method and params will be received
        if (method == 'fetchPromoUIComponentData') {
            return fetchPromoUIComponentData(params);

        } 
        // handles Promotion Level Edit Access Rights
        else if(method == 'EARights'){
            return eARights(params);
        }
        // handles invokation of TPMCalculationChainBatch
        else if(method == 'executeTPMCalculationChainBatch'){
            return executeTPMCalculationChainBatch(params);
        }
        // handles invokation of TPMCalculationChainBatch
        else if(method == 'fetchParticipatingCustomerDetails'){
            
            return fetchParticipatingCustomerDetails(params);
        }
        // handles invokation of Incctive Customer Validation
        else if(method == 'checkIfActiveCustomer'){
            
            return checkIfActiveCustomer(params);
        }
        else {
            // Throw custom exception.
            throw new PromotionCardException('Exception in TPM_PromotionMainCardController');
        }
    }


   /***************************************************************************************************
    * @method          fetchPromoUIComponentData
    * @param           params
    * @return          List<String>
    * @description     Method to fetch fetchPromoUIComponentData from org
    ****************************************************************************************************/
    public static List<String> fetchPromoUIComponentData(Map<String, Object> params) {

        // Validate parameters
        if (params == null || String.isBlank((String) params.get(PARAM_OBJID)) == null) {
            return new List<String>();
        }
        
        // Extract parameter.
        String objectRecordId = String.valueOf(params.get(PARAM_OBJID));

        UIWrapper uiWrapObj = new UIWrapper();
        uiWrapObj.promoId = objectRecordId;
        
         TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper metadataValues = TPM_Utils_Extension.getMetadataForOverlapCheck();

        // Fetch custom labels.
        uiWrapObj.customLabelApiToValueMap = fetchCustomLabelFromOrg();
        uiWrapObj.uiDefinitionJSON = fetchUIDefinitionObj(objectRecordId);
        uiWrapObj.promotionData = TPM_Utils_Extension.getDetailsForPromotion(objectRecordId);
        uiWrapObj.promotionFieldsHide = metadataValues.promotionFieldsToHide;
        List<String> retJSONList = new List<String>();
        retJSONList.add(JSON.serialize(uiWrapObj));
        return retJSONList;
    }


    /***************************************************************************************************
    * @method          fetchUIDefinitionObj
    * @param           objectRecordId
    * @return          String
    * @description     Method to fetch UI Definition of promotion template
    ****************************************************************************************************/
    private static String fetchUIDefinitionObj(String objectRecordId) {


        String jsonString;
        List<cgcloud__Promotion__c> promoList = new  List<cgcloud__Promotion__c>();
        
        // Fetch promotion template's UI Definition detail.
        promoList = [SELECT Id, 
                            cgcloud__Promotion_Template__c, 
                            cgcloud__Promotion_Template__r.TPM_UI_Definition__c, 
                            cgcloud__Promotion_Template__r.TPM_UI_Definition__r.TPM_Usage__c, 
                            cgcloud__Promotion_Template__r.TPM_UI_Definition__r.TPM_JSON_Definition__c 
                    FROM cgcloud__Promotion__c 
                    WHERE Id = :objectRecordId 
                    AND cgcloud__Promotion_Template__c != NULL 
                    AND cgcloud__Promotion_Template__r.TPM_UI_Definition__c != NULL 
                    AND cgcloud__Promotion_Template__r.TPM_UI_Definition__r.TPM_Usage__c = :TYPE_PROMOTION  
                    LIMIT 1];

        if(!promoList.isEmpty()){
            jsonString = promoList[0].cgcloud__Promotion_Template__r.TPM_UI_Definition__r.TPM_JSON_Definition__c;
        }

        return jsonString;
    }


    /***************************************************************************************************
    * @method          fetchCustomLabelFromOrg
    * @return          Map<String, String>
    * @description     Method to fetch custom label
    ****************************************************************************************************/
    private static Map<String, String> fetchCustomLabelFromOrg() {

        Map<String, String> labelApiWithValueMap = new Map<String, String>();
        labelApiWithValueMap.put('TPM_Promotion_Custom_Error_Message', System.Label.TPM_Promotion_Custom_Error_Message);
        labelApiWithValueMap.put('TPM_Promotion_PreventSubmissionForApproval', System.Label.TPM_Promotion_PreventSubmissionForApproval);
        labelApiWithValueMap.put('TPM_Promotion_IsActivePreventForApproval', System.Label.TPM_Promotion_IsActivePreventForApproval);
		labelApiWithValueMap.put('TPM_IsActiveCustomerValidationMessage',System.Label.TPM_IsActiveCustomerValidationMessage);
        return labelApiWithValueMap;
    }


    /************************************************************************
    * @method          UIWrapper
    * @description     Wrapper
    **************************************************************************/
    public class UIWrapper {
        /**
         * @description promotion id
         */
        public String promoId {get; set;}
        /**
         * @description ui Definition JSON
         */
        public String uiDefinitionJSON {get; set;}
        /**
         * @description Cusotm Label API Map
         */
        public Map<String, String> customLabelApiToValueMap {get; set;}
         /**
         * @description Promortion Data
         */
        public List<cgcloud__Promotion__c> promotionData{get; set;}
         
        /**
         * @description Tactic Data
         */
        public List<String> promotionFieldsHide{get; set;}

    }
    
    /***************************************************************************************************
    * @method          eARights
    * @param           args
    * @return          Boolean
    * @description     Method to handle Promotion Access Rights from UI Definition on Save&Refresh
    ****************************************************************************************************/
    public static Boolean eARights(Map<String, Object> args){

        Boolean isFlagEdit = false;        
        // Get the Promotion Id
        Id promotionId = (String)args.get('promotionId'); 

        // Get the EARigths
        List<cgcloud.EARightsAccess> promotionRights = (List<cgcloud.EARightsAccess>) args.get('EARights');

        // Get the Promotion Template name
        List<cgcloud__Promotion__c> promos = [SELECT id,
                                                     TPM_Phase__c,
                                                     TPM_Overlap_Check__c 
                                                     FROM cgcloud__Promotion__c
            								         WHERE Id = :promotionId LIMIT 1 ];
        if(!promos.isEmpty() && promos[0].TPM_Phase__c != null 
        && ((promos[0].TPM_Phase__c.equalsIgnoreCase(TPM_ConstantsUtility.PHASE_SUBMITFORAPPROVAL) ||( promos[0].TPM_Phase__c.equalsIgnoreCase(TPM_ConstantsUtility.PHASE_PLANNING) && promos[0].TPM_Overlap_Check__c ==TPM_ConstantsUtility.OVERLAPINPROGRESS)))) {
            isFlagEdit = eARightsPromotionVisibility(promotionRights,isFlagEdit);
        }
	
        else if(!promos.isEmpty() && promos[0].TPM_Phase__c != null 
                && promos[0].TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING && promos[0].TPM_Overlap_Check__c != null && promos[0].TPM_Overlap_Check__c ==TPM_ConstantsUtility.NOOVERLAPFOUND){
                    isFlagEdit = eARightsTacticVisibility(promotionRights,isFlagEdit);
        }

        return isFlagEdit;
        
    }
    /***************************************************************************************************
    * @method          executeTPMCalculationChainBatch
    * @param           params
    * @return          Boolean
    * @description     Method to handle invokation of TPMCalculationChain on Promotion Save & Refresh or 
    * 				   Done
    ****************************************************************************************************/
    public static boolean executeTPMCalculationChainBatch(Map<String, Object> params){
        
          
        Boolean executeTPMCalculationChainBatch = false;
        
        // Validate parameters
        if (params == null || String.isBlank((String) params.get(PARAM_OBJID)) == null) {
            return executeTPMCalculationChainBatch;
        }
        
        // Extract parameter.
        String objectRecordId = String.valueOf(params.get(PARAM_OBJID));
        
        // Invoke TPM_OpenAccess isUpdateAccountRecordFlag to update
        // the custom flag field on Account Records
        
        if(objectRecordId != NULL){
            executeTPMCalculationChainBatch = TPM_OpenAccess.isUpdateAccountRecordFlag(objectRecordId, executeTPMCalculationChainBatch);
        }
        
        
        return executeTPMCalculationChainBatch;
    }


    /***************************************************************************************************
    * @method          eARightsTacticVisibility
    * @param           promotionRights
    * @param           isFlagEdit
    * @return          Boolean
    * @description     Method to handle invokation of TPMCalculationChain on Promotion Save & Refresh or 
    * 				   Done
    ****************************************************************************************************/
    private static boolean eARightsTacticVisibility (List<cgcloud.EARightsAccess> promotionRights, Boolean isFlagEdit){

             // Search the related EARightsAccess instance
             for (cgcloud.EARightsAccess acl : promotionRights) {
                
                Switch on acl.Name{
                    when 'ADD_TACTIC_BUTTON'{
                        acl.Visible = false;
                        acl.Editable = false;
                        isFlagEdit = true;
                    }
                    when 'TACTIC_DUPLICATE_BUTTON'{
                        acl.Visible = false;
                        acl.Editable = false;
                        isFlagEdit = true;
                    }
                    when 'TACTIC_DELETE_BUTTON'{
                        acl.Visible = false;
                        acl.Editable = false;
                        isFlagEdit = true;
                    }
                }
                    
            }
            return isFlagEdit;
        }
      
    /***************************************************************************************************
    * @method          eARightsPromotionVisibility
    * @param           promotionRights
    * @param            isFlagEdit
    * @return          Boolean
    * @description     Method to handle invokation of TPMCalculationChain on Promotion Save & Refresh or 
    * 				   Done
    ****************************************************************************************************/
    private static boolean eARightsPromotionVisibility (List<cgcloud.EARightsAccess> promotionRights, Boolean isFlagEdit){

        for (cgcloud.EARightsAccess acl : promotionRights) {
                                      
            if (acl.Name == 'PROMOTION_EDIT_BUTTON') {
                acl.Visible = false;
                acl.Editable = false;
                isFlagEdit = true;
                }
            }

            return isFlagEdit;
    }

    /***************************************************************************************************
* @method          fetchParticipatingCustomerDetails
* @param           params
* @return          String
* @description     Method to fetch child accounts and promotion details for participating customers component for planning phase
****************************************************************************************************/
public static String fetchParticipatingCustomerDetails(Map<String, Object> params) {
    
    
    Map<String,string> pushableAccountMap = new Map<String,string>();
    List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();

    
    // Extract parameter.
    String objectRecordId = String.valueOf(params.get(PARAM_OBJID));
    ParticipatingCustomerWrapper wrapperObj =new ParticipatingCustomerWrapper();

    try{

        List<TPM_Domain_Name__mdt> mdtObjLst = TPM_Domain_Name__mdt.getAll().values(); 
           
    cgcloud__Promotion__c promoObj = [SELECT
                                        Id,
                                        Name,
                                        cgcloud__Phase__c,
                                        TPM_Phase__c,
                                        cgcloud__Anchor_Account__c,
                                        cgcloud__Is_Push_In_Progress__c,
                                        cgcloud__Push_Target_Account_Selection__c,
                                        cgcloud__Anchor_Account__r.TPM_Hierarchy_Level__c
                                        FROM cgcloud__Promotion__c
                                        WHERE Id = :objectRecordId];
    
    if(promoObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING 
        /*&& promoObj.cgcloud__Is_Push_In_Progress__c*/
        && promoObj.cgcloud__Push_Target_Account_Selection__c != null){
            
            wrapperObj.promoId = promoObj.Id; 
            wrapperObj.loadCmpFlag = true;
            wrapperObj.totalActiveChildPromo=0;
        
            for(String eachMAAcc : promoObj.cgcloud__Push_Target_Account_Selection__c.replaceAll('^\\[|\\]$', '').replaceAll('^\\{|\\}$', '').split('\\}\\,\\{')){
                if(eachMAAcc.contains('true')){
                    pushableAccountMap.put(eachMAAcc.substring(30,eachMAAcc.length()-1),eachMAAcc.substring(11,15));
                    wrapperObj.totalActiveChildPromo++;
                }
                else if(eachMAAcc.contains('false')){
                    pushableAccountMap.put(eachMAAcc.substring(31,eachMAAcc.length()-1),eachMAAcc.substring(11,16));
                }
            }
            
        
            List<TPM_PromotionMainCardControllerExtension.PushableAcocuntDetailWrapper> pushableAccountLst = new List<TPM_PromotionMainCardControllerExtension.PushableAcocuntDetailWrapper>();
            Map<Id,Id> accountToPromoMap = new Map<Id,Id>();

            for(cgcloud__promotion__c promotionObj : [SELECT 
                                                Id,
                                                Name,
                                                cgcloud__Anchor_Account__c
                                                FROM cgcloud__Promotion__C
                                                WHERE cgcloud__Parent_Promotion__c =: promoObj.Id ]){

                accountToPromoMap.put(promotionObj.cgcloud__Anchor_Account__c,promotionObj.Id);                              

            }

            for(Account accDetail : [SELECT 
                                    Id, 
                                    Name, 
                                    TPM_Hierarchy_Level__c,
                                    cgcloud__ExternalId__c
                                    FROM Account 
                                    WHERE 
                                    cgcloud__ExternalId__c IN : pushableAccountMap.keyset()]){
                                        
                TPM_PromotionMainCardControllerExtension.PushableAcocuntDetailWrapper accWrapperObj = new TPM_PromotionMainCardControllerExtension.PushableAcocuntDetailWrapper();
                accWrapperObj.accountId = accDetail.Id;
                accWrapperObj.accountName = accDetail.Name;
                accWrapperObj.externalId = accDetail.cgcloud__ExternalId__c;
                accWrapperObj.pushedFlag = boolean.valueof(pushableAccountMap.get(accDetail.cgcloud__ExternalId__c));
                if(accountToPromoMap.containskey(accDetail.Id)){
                
                    accWrapperObj.childRecordCreated = true;
                    accWrapperObj.promotionId = accountToPromoMap.get(accDetail.Id);
                    accWrapperObj.promotionLink = mdtObjLst[0].TPM_Org_Link__c+accountToPromoMap.get(accDetail.Id);
                }                      
                                        else{
                                            accWrapperObj.childRecordCreated = false;
                                        }
                                        accWrapperObj.accountLink = mdtObjLst[0].TPM_Org_Link__c+accWrapperObj.accountId;
               
                pushableAccountLst.add(accWrapperObj);
                
            }
            wrapperObj.childAccountLst = pushableAccountLst;
            
        }
    else{
            wrapperObj.loadCmpFlag = false;
    }
}
catch(Exception exp){
        
        TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
        logWrapperObj.exceptionObj = exp;
        logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
        logWrapperObj.className = TPM_ConstantsUtility.TPM_PROMOTION_MAIN_CARD_CONTROLLER;
        exceptionWrapperList.add(logWrapperObj);
        TPM_LoggerException.log(exceptionWrapperList);
    }
    
    return JSON.serialize(wrapperObj);
}

    /***************************************************************************************************
    * @method          checkIfActiveCustomer
    * @param           params
    * @return          Boolean
    * @description     Method to handle invokation of checkIfActiveCustomer to throw Validation Message
    * 				   on before save of the Promotion if the Customer is Inactive.
    ****************************************************************************************************/
    public static boolean checkIfActiveCustomer(Map<String, Object> params){

        Boolean isInActiveCustomer = false;
        
        // Validate parameters
        if (params == null || String.isBlank((String) params.get(PARAM_OBJID)) == null) {
            return isInActiveCustomer;
        }
        
        // Extract parameter.
        String objectRecordId = String.valueOf(params.get(PARAM_OBJID));

        if(objectRecordId != NULL){
          cgcloud__Promotion__c promotionObj = [SELECT 	Id, 
                                                Name, 
                                                cgcloud__Active__c, 
                                                cgcloud__Anchor_Account__c, 
                                                cgcloud__Anchor_Account__r.TPM_IsActive__c,
                                                cgcloud__Promotion_Template__c ,
                                                cgcloud__Promotion_Template__r.Name 
                                                FROM 	cgcloud__Promotion__c 
                                                WHERE Id =: objectRecordId]; 
            
           isInActiveCustomer = ( promotionObj.cgcloud__Anchor_Account__r.TPM_IsActive__c == False ) ? True : False; 
        }
        return isInActiveCustomer;
        }
        
    /************************************************************************
* @method          ParticipatingCustomerWrapper
* @description     Wrapper
**************************************************************************/
public class ParticipatingCustomerWrapper {
    /**
     * @description promotion id
     */
    public String promoId {get; set;}
    /**
     * @description active promo accounts
     */
    public Integer totalActiveChildPromo {get; set;}
    /**
     * @description flag to load custom participating customers
     */
    public boolean loadCmpFlag {get; set;}
    /**
     * @description child Managed accounts
     */
    public List<TPM_PromotionMainCardControllerExtension.PushableAcocuntDetailWrapper> childAccountLst {get; set;}
        

}
}