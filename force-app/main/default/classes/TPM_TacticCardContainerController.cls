/******************************************************************************************************
@Name            TPM_TacticCardContainerController
@testclass       TPM_TacticCardContainerControllerTest
@date            28 Feb, 2023
@description     Apex class for custom tpmTacticInfoCardContainer component 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class TPM_TacticCardContainerController implements System.Callable {


    static final String TYPE_TACTIC = 'Tactic';
    static final String PARAM_OBJID = 'objId';

    /************************************************************
    * @Name          TacticCardException
    * @description   Exception Class to throw custom exception
    *************************************************************/
    global class TacticCardException extends Exception {}


    /******************************************************************** 
    @methodname 	call
    @param          method
	@param          params
    @return         Object
    @description	callable interface method
    *********************************************************************/
    public Object call(String method, Map<String, Object> params) {

        // Both method and params will be received
        if (method == 'fetchUIComponentData') {
            return fetchUIComponentData(params);

        } else {

            // Throw custom exception.
            throw new TacticCardException('Exception in TPM_TacticCardContainerController');
        }
    }


    /***************************************************************************************************
    * @method          fetchUIComponentData
    * @param           params
    * @return          List<String>
    * @description     Method to fetch fetchUIComponentData from org
    ****************************************************************************************************/
    private static List<String> fetchUIComponentData(Map<String, Object> params) {

        // Validate parameters
        if (params == null || String.isBlank((String) params.get(PARAM_OBJID)) == null) {
            return new List<String>();
        }
        
        // Extract parameter.
        String objectRecordId = String.valueOf(params.get(PARAM_OBJID));
        TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper metadataValues = TPM_Utils_Extension.getMetadataForOverlapCheck();

        UIWrapper uiWrapObj = new UIWrapper();

        // Fetch custom labels.
        uiWrapObj.tacticTemplateId = objectRecordId;
        uiWrapObj.customLabelApiToValueMap = fetchCustomLabelFromOrg();
        uiWrapObj.uiDefinitionJSON = fetchUIDefinitionObj(objectRecordId);
        uiWrapObj.tacticFieldsHide = metadataValues.tacticFieldsToHide;

        List<String> retJSONList = new List<String>();
        retJSONList.add(JSON.serialize(uiWrapObj));
        return retJSONList;
    }


    /***************************************************************************************************
    * @method          fetchUIDefinitionObj
    * @param           objectRecordId
    * @return          String
    * @description     Method to fetch UI Definition of tactic template
    ****************************************************************************************************/
    private static String fetchUIDefinitionObj(String objectRecordId) {


        String jsonString;
        List<cgcloud__Tactic_Template__c> tacticTemplateList = new  List<cgcloud__Tactic_Template__c>();
        
        // Fetch cgcloud__Tactic_Template__c's UI Definition detail.
        tacticTemplateList = [SELECT Id, 
                                     TPM_UI_Definition__c, 
                                     TPM_UI_Definition__r.TPM_Usage__c, 
                                     TPM_UI_Definition__r.TPM_JSON_Definition__c 
                              FROM cgcloud__Tactic_Template__c 
                              WHERE Id = :objectRecordId 
                              AND TPM_UI_Definition__c != NULL 
                              AND TPM_UI_Definition__r.TPM_Usage__c = :TYPE_TACTIC 
                              LIMIT 1];

        if(!tacticTemplateList.isEmpty()){
            jsonString = tacticTemplateList[0].TPM_UI_Definition__r.TPM_JSON_Definition__c;
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
        labelApiWithValueMap.put('TPM_RequiredFieldMissingMsg', System.Label.TPM_RequiredFieldMissingMsg);

        return labelApiWithValueMap;
    }


    /************************************************************************
    * @method          UIWrapper
    * @description     Wrapper
    **************************************************************************/
    public class UIWrapper {
        /**
         * @description tactic template id
         */
        public String tacticTemplateId {get; set;}
        /**
         * @description ui Definition JSON
         */
        public String uiDefinitionJSON {get; set;}
        /**
         * @description Cusotm Label API Map
         */
        public Map<String, String> customLabelApiToValueMap {get; set;}
         /** 
        * @description tacticFieldsHide
        */
        public List<String> tacticFieldsHide {get; set;}

    }

}