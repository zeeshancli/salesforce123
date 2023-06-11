/******************************************************************************************************
* @Name         : TPM_Utils_Extension
* @Test Class   : 
* @author       : PwC Team
* @date         : March 20, 2023
* @description  : Utility extension class providing reusable methods
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_Utils_Extension {
    
    // to check if promotion approval records are inserted successfully
    public static Boolean isPromotionApprovalSuccess = false;    
    
    /****************************************************************************************************
    @methodname 	TPM_Utils
    @createdDate 	12/09/2022
    @description	default private constructor
    *****************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_Utils_Extension(){

    }


    /****************************************************************************************************
    @methodname 	queryCustomMetadataRecords
    @param          objectName
    @param          fieldsToQueryList
    @param          criteriaMap
    @return         List<SObject>
    @createdDate 	03/20/2023
    @description	common method to query metadata records based on String Type "AND" criteria filter FOR EXAMPLE,
                    objectName = 'TPM_FieldsMapping__mdt';
                    fieldsToQueryList = new List<String>{'TPM_Condition__c', 'TPM_ConditionCriteria__c', ........};
                    criteriaMap = new Map<String,Object>{'TPM_ProcessName__c' => 'THE_PROCESS_NAME', ........};
    *****************************************************************************************************/

    public static List<SObject> queryCustomMetadataRecords(String objectName, List<String> fieldsToQueryList, Map<String, Object> criteriaMap){
        
        // Build SOQL String
        String queryString = 'SELECT ';

        // Adding fields to query string
        for(String fields : fieldsToQueryList){
            queryString += fields + ', ';
        }
        queryString = queryString.removeEnd(', ') + ' FROM ' + objectName; 

        // appending fields and corr. values to filter in WHERE Clause 
        if(!criteriaMap.isEmpty()){
            Object filterVal;
            queryString += ' WHERE ';
            for(String field : criteriaMap.keySet()){
                filterVal = criteriaMap.get(field);
                queryString += field + ' = :filterVal AND ';
            }
            queryString = queryString.removeEnd(' AND ');
        }
                
        // retruns records list to be used...
        return Database.query(String.escapeSingleQuotes(queryString));
    }
    
    /****************************************************************************************************
    @methodname 	getKeyUsingValueFromMap
    @param          value
    @param          mapToIterate
    @return         String
    @createdDate 	03/23/2023
    @description    method returns corresponding key for value provided from map
    *****************************************************************************************************/

    public static String getKeyUsingValueFromMap(String value, Map<String, Object> mapToIterate){
        for(String key : mapToIterate.keySet()){
            if(mapToIterate.get(key) == value){
                return key;
            }
        }
        return '';
    }

    /****************************************************************************************************
    @methodname 	getMetadataForOverlapCheck
    @return         TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper
    @createdDate 	03/23/2023
    @description    method returns metadata records for overlap check
    *****************************************************************************************************/

    public static TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper getMetadataForOverlapCheck(){
        List<String> promoTemp = new List<String>();
        List<String> tacticVal = new List<String>();
        List<String> phaseVal = new List<String>();
        List<String> promotionFields = new List<String>();
        List<String> tacticFields = new List<String>();
        //Get metdata records for overlap checks
        for(TPM_Overlap_Check_Conditions__mdt mdtVal : [SELECT id,
                                                                Promotion_Template__c,
                                                                Tactic_Type__c,
                                                                TPM_PromotionFieldsOverlapHide__c,
                                                                TPM_TacticFieldsOverlapHide__c,
                                                                TPM_PhaseForOverlapCheck__c
                                                                FROM TPM_Overlap_Check_Conditions__mdt
                                                                WHERE DeveloperName = :TPM_ConstantsUtility.OVERLAPCHECKMETADATA]){

            promoTemp = mdtVal.Promotion_Template__c.split(';');
            tacticVal =  mdtVal.Tactic_Type__c.split(';');
            promotionFields =  mdtVal.TPM_PromotionFieldsOverlapHide__c.split(';');
            tacticFields =  mdtVal.TPM_TacticFieldsOverlapHide__c.split(';');
            phaseVal = mdtVal.TPM_PhaseForOverlapCheck__c.split(';');
        }
        TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper overlapSet = new TPM_Wrapper_OverLapCheck.TPMOverLapMetadataWrapper(promoTemp,tacticVal,phaseVal,promotionFields,tacticFields);
        return overlapSet;
    }

    /****************************************************************************************************
    @methodname 	getDetailsForPromotion
    @param          recordId
    @return         List<cgcloud__Promotion__c>
    @createdDate 	03/23/2023
    @description    method returns details related to particular promotion
    *****************************************************************************************************/

    public static List<cgcloud__Promotion__c> getDetailsForPromotion(string recordId){

                List<cgcloud__Promotion__c> promotionList = [SELECT id,
                                                                cgcloud__Sales_Org__c,
                                                                TPM_Phase__c,
                                                                TPM_Overlap_Check__c,
                                                                cgcloud__Anchor_Account__c,
                                                                TPM_OverLap_Check_Status__c,
                                                                cgcloud__Promotion_Template__r.Name,
                                                                cgcloud__Delivery_Date_From__c,
                                                                cgcloud__Slogan_Language_1__c,
                                                                cgcloud__Delivery_Date_Thru__c,
                                                                TPM_Push_Failed__c,
                                                                cgcloud__Push_Target_Account_Selection__c
                                                                FROM cgcloud__Promotion__c
                                                                WHERE id =:recordId
                                                                WITH SECURITY_ENFORCED];

                return promotionList;
         }
    /****************************************************************************************************
    @methodname 	getMinDate
    @param          instoreDateFrom
	@param			shipmentDateFrom
	@param			commitDate
    @return         Date
    @createdDate 	03/24/2023
    @description    Method to return MIN DATE(instoreDateFrom,shipmentDateFrom,commitDate)
    *****************************************************************************************************/
    public static Date getMinDate(Date instoreDateFrom, Date shipmentDateFrom, Date commitDate){
        if(instoreDateFrom < shipmentDateFrom && instoreDateFrom < commitDate){
            return instoreDateFrom;
        }else if(shipmentDateFrom < instoreDateFrom && shipmentDateFrom < commitDate){
            return shipmentDateFrom;
        }else{
            return commitDate;
        }
        
    }
    
    /****************************************************************************************************
    @methodname 	getMaxDate
    @param          instoreDateThru
	@param			shipmentDateThru
    @return         Date
    @createdDate 	03/24/2023
    @description    Method to return MAX DATE(instoreDateThru,shipmentDateThru)
    *****************************************************************************************************/
    public static Date getMaxDate(Date instoreDateThru, Date shipmentDateThru){
        if(instoreDateThru > shipmentDateThru ){
            return instoreDateThru;
        }else{
            return shipmentDateThru;
        }
    }

    /****************************************************************************************************
    @methodname 	getOtherPromotionData
    @param          childAccountIdList
	@param			templateName
    @param			childParentIdSet
    @return         List<cgcloud__Promotion__c>
    @createdDate 	03/24/2023
    @description    Method to get overlapping promotions
    *****************************************************************************************************/
    public static  List<cgcloud__Promotion__c> getOtherPromotionData(List<String> childAccountIdList,List<String> templateName,Set<String> childParentIdSet){

         List<String> phaseValues = TPM_Utils_Extension.getMetadataForOverlapCheck().phase;
        List<cgcloud__Promotion__c> otherPromotionData = [SELECT id,
                                                                cgcloud__Anchor_Account__c,
                                                                cgcloud__Sales_Org__c,
                                                                TPM_Phase__c,
                                                                TPM_OverLap_Check_Status__c,
                                                                cgcloud__Promotion_Template__c,
                                                                cgcloud__Delivery_Date_From__c,
                                                                cgcloud__Delivery_Date_Thru__c,
                                                                cgcloud__Slogan_Language_1__c,
                                                                TPM_Push_Failed__c
                                                                FROM cgcloud__Promotion__c
                                                                WHERE cgcloud__Anchor_Account__c IN : childAccountIdList
                                                                AND cgcloud__Promotion_Template__r.Name IN : templateName
                                                                AND ID NOT IN:childParentIdSet
                                                                AND TPM_Phase__c IN:phaseValues
                                                                WITH SECURITY_ENFORCED];
    
        return otherPromotionData;
        }


    /******************************************************************************************************** 
    @methodname 	getchildPromotemplateNames
    @return         TPM_Wrapper_OverLapCheck_Ext.OverLapMetaDataWrapper
    @description	method to fetch promotion template from metadata for overlap check for push promotions.
    *********************************************************************************************************/ 
    public static TPM_Wrapper_OverLapCheck_Ext.OverLapMetaDataWrapper getchildPromotemplateNames() {

        Map<String,List<String>> parentChildTempMap = new Map<String,List<String>>();

        List<String> templateForOverLapChecksTemp = new List<String>();
        for(TPM_Push_Promotion_Overlap_Check__mdt pushPromoMetdata : TPM_Push_Promotion_Overlap_Check__mdt.getAll().Values()){

            List<String> childPromoTempName = pushPromoMetdata.TPM_Child_Promotion__c.split(';'); 
            parentChildTempMap.put(pushPromoMetdata.TPM_Parent_Promotion__c,childPromoTempName);
            templateForOverLapChecksTemp = pushPromoMetdata.TPM_Promotion_Template_For_OverLap_Check__c.split(';');

            }
            TPM_Wrapper_OverLapCheck_Ext.OverLapMetaDataWrapper metadataWrapper = new TPM_Wrapper_OverLapCheck_Ext.OverLapMetaDataWrapper();
            metadataWrapper.childPromotionTemplates = parentChildTempMap;
            metadataWrapper.templateForOverLapChecks = templateForOverLapChecksTemp;
            return metadataWrapper; 

        }

        
    /******************************************************************************************************** 
    @methodname 	executeOverlapCheck
    @param			recordId
    @description	method to call futuremethod to call overlap check queable class
    *********************************************************************************************************/ 
    @future(callout=true)
    public static void executeOverlapCheck(String recordId) {
        
        System.enqueueJob(new TPM_OverlapCheckQueable(recordId));
            
    }
    
    /******************************************************************************************************** 
    @methodname 	createPermissionSetGroupNameToIdMap
    @return			Map<String,Id>
    @description	method to create a Map of PermissionSetGroupName and PermissionSetGroup Id
    *********************************************************************************************************/ 
    public static Map<String,Id> createPermissionSetGroupNameToIdMap(){
        
        Map<String,Id> permissionGroupNameToIdMap = new Map<String,Id>();
        for(PermissionSetGroup permissionGroupObj : [SELECT 
                                                     Id,
                                                     DeveloperName
                                                     FROM  PermissionSetGroup 
                                                     WHERE DeveloperName != NULL]){
                permissionGroupNameToIdMap.put(permissionGroupObj.DeveloperName, permissionGroupObj.Id);         
                                                         
          }
        return permissionGroupNameToIdMap;
    }
    
    /******************************************************************************************************** 
    @methodname 	getPersonaToPermissionSetGroupCMDT
    @return			Map<String,String>
    @description	Method to query the CMDT TPM_Persona_Permission_Set_Group_Name__mdt and create a Map of
					TPM_Persona_Name__c and TPM_Permission_Set_Group_Name__c
    *********************************************************************************************************/ 
    public static Map<String,String> getPersonaToPermissionSetGroupCMDT(){
        
        Map<String,String> personaNameToPermSetGroupNameMap = new Map<String,String>();
        // Get the TPM_Persona_Permission_Set_Group_Name__mdt all records
        Map<String,TPM_Persona_Permission_Set_Group_Name__mdt> personaPermSetGrpCMDTMap = TPM_Persona_Permission_Set_Group_Name__mdt.getAll();
        
        // Iterate over the TPM_Persona_Permission_Set_Group_Name__mdt records
        // And create a Map of
		// TPM_Persona_Name__c and TPM_Permission_Set_Group_Name__c
        for(String cmdtKey : personaPermSetGrpCMDTMap.keySet()){
            personaNameToPermSetGroupNameMap.put(personaPermSetGrpCMDTMap.get(cmdtKey).TPM_Persona_Name__c,personaPermSetGrpCMDTMap.get(cmdtKey).TPM_Permission_Set_Group_Name__c);
        }
        
        return personaNameToPermSetGroupNameMap;
    }
}