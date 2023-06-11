/******************************************************************************************************
@Name            TPM_PromotionApprovalManager
@testclass       TPM_PromotionCustomerPlanTriggerTest
@Author          PwC Team
@date            March 22, 2023
@description     methods for promotion record approvals/tactics creations and,
				 Handles business logic for approval records approvals routing
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_PromotionApprovalManager {
    
    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_PromotionApprovalManager() {

    }
    
    /*********************************************************************************
    @method          promotionApprovalHandler
	@param     	  	 promotionForApprovalMap
    @param     	  	 exceptionWrapperList
    @param           promoIdToPromotionTemplateIdMap
    @description     method to handle promotion and tactics approval creations
    **********************************************************************************/
    
    public static void promotionApprovalHandler(Map<Id, cgcloud__Promotion__c> promotionForApprovalMap, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList, Map<String, String> promoIdToPromotionTemplateIdMap){
         
        //preparing a map of approval to be created for each promotion
        Map<Id, TPM_Approval__c> promotionIdToApprovalObjMap = prepareApprovalRecords(promotionForApprovalMap, promoIdToPromotionTemplateIdMap);
        
        //inserting and logging error(if any), for approval objects:
        if(!promotionIdToApprovalObjMap.isEmpty()){
            String objectName = TPM_ConstantsUtility.OBJECT_APPROVAL;
            createApprovalRecordsHandler(promotionIdToApprovalObjMap.values(), objectName, exceptionWrapperList);
        }
        
        //checking if the approval records are created then prepare records to be inserted for approval tactics
        if(TPM_Utils_Extension.isPromotionApprovalSuccess) {
            String objectName = TPM_ConstantsUtility.OBJECT_APPROVALTACTICS;
            createApprovalRecordsHandler(prepareApprovalTacticsRecords(promotionIdToApprovalObjMap), objectName, exceptionWrapperList);
        }
    }
    

     /********************************************************************************************************** 
	@methodname 	 prepareApprovalRecords
	@return          Map<Id, TPM_Approval__c>
	@param           promotionForApprovalMap
    @param           promoIdToPromotionTemplateIdMap
	@description	 create approval records when Phase changes from Planning to For Approval 
	***********************************************************************************************************/ 
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static Map<Id, TPM_Approval__c> prepareApprovalRecords(Map<Id, cgcloud__Promotion__c> promotionForApprovalMap, Map<String, String> promoIdToPromotionTemplateIdMap) {
        
        Map<Id, TPM_Approval__c> promoIdApprovalRecordMap = new Map<Id, TPM_Approval__c>();
        
        List<TPM_FieldsMapping__mdt> approvalFieldMappingRecordsList =  (List<TPM_FieldsMapping__mdt>)TPM_Utils_Extension.queryCustomMetadataRecords(TPM_ConstantsUtility.FIELDSMAPPING_METADATA_API, TPM_ConstantsUtility.FIELDSMAPPING_METADATA_FIELDSLIST, TPM_ConstantsUtility.FIELDSMAPPING_CRITERIAMAP_APPROVALPROMOTION);
        
        Map<Id, cgcloud__Promotion_Template__c> promoIdPromoTemplateRecordMap = fetchPromotionTemplateRecords(promoIdToPromotionTemplateIdMap);
        
		// recordid and submitter's manager or higher approverId assignment map       
        Map<Id, Id> promoIdToApproverIdMap = promotionApprovalRouting(promotionForApprovalMap);
                
        for(cgcloud__Promotion__c promoObj : promotionForApprovalMap.values()){
                          
            // initializing new approval recrod for promotion approval insert
            TPM_Approval__c newApprovalRecord = new TPM_Approval__c();
                        
            // iterating over field mapping for TPM_ApprovalPromotion
            for(TPM_FieldsMapping__mdt fieldMapRecord : approvalFieldMappingRecordsList){
                
                if(fieldMapRecord.TPM_IsLookup__c && String.isNotBlank(fieldMapRecord.Lookup_Relationship_Notation__c)){
                    
                    cgcloud__Promotion_Template__c promoTempObj = promoIdPromoTemplateRecordMap.get(promoObj.Id);
                    
                    if(fieldMapRecord.TPM_ToFieldApi__c.equalsIgnoreCase(TPM_ConstantsUtility.APPROVAL_FIELD_ISDISPLAY)){
                        
                        // is display marked TRUE on approval will depend on promotion template cgcloud__BOM_Handler__c if its value is ConsiderBOMs
                        Boolean isBOM = promoTempObj.get(fieldMapRecord.Lookup_Relationship_Notation__c) == TPM_ConstantsUtility.BOM_HANDLER_VAL_CONSIDER ? true : false;
                        newApprovalRecord.put(fieldMapRecord.TPM_ToFieldApi__c, isBOM);
                    } else {
                        newApprovalRecord.put(fieldMapRecord.TPM_ToFieldApi__c, promoTempObj.get(fieldMapRecord.Lookup_Relationship_Notation__c));
                    }
                    
                } else {
					newApprovalRecord.put(fieldMapRecord.TPM_ToFieldApi__c, promoObj.get(fieldMapRecord.TPM_FromFieldApi__c));
                    newApprovalRecord.put(TPM_ConstantsUtility.FIELD_RECORDTYPEID, Schema.SObjectType.TPM_Approval__c.getRecordTypeInfosByDeveloperName().get(TPM_ConstantsUtility.RECORDTYPE_PROMOTION).getRecordTypeId());
                } 
            } 
            
            // record owner assignment for approval
            if(promoIdToApproverIdMap.containsKey(promoObj.Id)) {
                newApprovalRecord.put('OwnerId', (Id) promoIdToApproverIdMap.get(promoObj.Id));
            } else {
                throw new TPM_PromotionApprovalException(System.Label.TPM_PromotionApproval_ApproverNotFoundError+''+promoObj.Id); 
            }

            // assign status approved when promotion current submitter is assigned as approver, auto-approved case
            if(promoObj.TPM_Promotion_Submitter__c == promoIdToApproverIdMap.get(promoObj.Id)){
                newApprovalRecord.put('TPM_Status__c', TPM_ConstantsUtility.PHASE_APPROVED);
            }
            
            promoIdApprovalRecordMap.put(promoObj.Id, newApprovalRecord);
        }
        
        return promoIdApprovalRecordMap;
    }
    
    /********************************************************************************************************** 
	@methodname 	 fetchPromotionTemplateRecords
	@return          Map<Id, cgcloud__Promotion_Template__c>
	@param           promoIdToPromotionTemplateIdMap
	@description	 create approval records when Phase changes from Planning to For Approval 
	***********************************************************************************************************/ 
    
    public static Map<Id, cgcloud__Promotion_Template__c> fetchPromotionTemplateRecords(Map<String, String> promoIdToPromotionTemplateIdMap) {

        // map of promotion id and template record
        Map<Id, cgcloud__Promotion_Template__c> promoIdPromoTemplateRecordMap = new Map<Id, cgcloud__Promotion_Template__c>();
                
        for(cgcloud__Promotion_Template__c promoTemplateObj : [SELECT Id, TPM_Type__c, cgcloud__BOM_Handler__c
                                             					FROM cgcloud__Promotion_Template__c 
                                             					WHERE Id IN : promoIdToPromotionTemplateIdMap.values()]){
                
            // method to get corr. key using value from map promoIdToPromotionTemplateIdMap
            String corrPromotionId = TPM_Utils_Extension.getKeyUsingValueFromMap(promoTemplateObj.Id, promoIdToPromotionTemplateIdMap);  

            if(!promoIdPromoTemplateRecordMap.containsKey(corrPromotionId)){
                promoIdPromoTemplateRecordMap.put(corrPromotionId, promoTemplateObj);
            }                                                                    
        }

        // returns map of promotion id and template records
        return promoIdPromoTemplateRecordMap;
    }
    
     /********************************************************************************************************** 
	@methodname 	 prepareApprovalTacticsRecords
	@return 	     List<TPM_Approval_Tactics__c>
	@param           promotionIdApprovalObjMap
	@description	 create approval tactics records when Phase changes from Planning to For Approval 
	***********************************************************************************************************/ 
    
    public static List<TPM_Approval_Tactics__c> prepareApprovalTacticsRecords(Map<Id, TPM_Approval__c> promotionIdApprovalObjMap){

        List<TPM_Approval_Tactics__c> tacticApprovalRecordList = new List<TPM_Approval_Tactics__c>();
        
        List<TPM_FieldsMapping__mdt> approvalTacticsFieldMappingRecordsList =  (List<TPM_FieldsMapping__mdt>)TPM_Utils_Extension.queryCustomMetadataRecords(TPM_ConstantsUtility.FIELDSMAPPING_METADATA_API, TPM_ConstantsUtility.FIELDSMAPPING_METADATA_FIELDSLIST, TPM_ConstantsUtility.FIELDSMAPPING_CRITERIAMAP_APPROVALTACTICS);
                
        for(cgcloud__Tactic__c tacticObj : [SELECT Id, cgcloud__Tactic_Type__c, 
                              					cgcloud__Compensation_Model__c, TPM_Volume_Basis__c, 
                              					cgcloud__Plan_Spend__c, cgcloud__Payment_Method__c, 
                              					cgcloud__Instore_Date_From__c, 
                              					cgcloud__Instore_Date_Thru__c, 
                              					cgcloud__Shipment_Date_From__c, 
                              					cgcloud__Shipment_Date_Thru__c,
                              					cgcloud__To_Date_Paid_Amount__c, 
                              					cgcloud__Promotion_Phase__c, cgcloud__Promotion__c,
                              					cgcloud__Pending_Amount__c, cgcloud__Included__c, 
                              					TPM_Redemption_Pct__c, TPM_Depth_of_Deal__c,
                              					cgcloud__Comment__c,TPM_Payment_Info__c  
                            				FROM cgcloud__Tactic__c
                            				WHERE cgcloud__Promotion__c IN : promotionIdApprovalObjMap.keySet()]) {
                                                                  
            // initializing new approval recrod for promotion approval insert
            TPM_Approval_Tactics__c newApprovalTacticsRecord = new TPM_Approval_Tactics__c();
            
            // iterating over field mapping for TPM_ApprovalTactic
            for(TPM_FieldsMapping__mdt fieldMapRecord : approvalTacticsFieldMappingRecordsList){

                if(String.isNotBlank(fieldMapRecord.TPM_ToFieldApi__c)){
					newApprovalTacticsRecord.put(fieldMapRecord.TPM_ToFieldApi__c, tacticObj.get(fieldMapRecord.TPM_FromFieldApi__c));
                } 
            } 
                                                          
            newApprovalTacticsRecord.put(TPM_ConstantsUtility.APPROVALTACTIC_FIELD_APPROVAL, promotionIdApprovalObjMap.get((String)tacticObj.get('cgcloud__Promotion__c')).Id);

            tacticApprovalRecordList.add(newApprovalTacticsRecord);
        }
        return tacticApprovalRecordList;
    }
    
    /*********************************************************************************
    @method          createApprovalRecordsHandler
	@param     	  	 recordsToInsert
	@param     	  	 objectName
    @param     	  	 exceptionWrapperList
    @description     method to insert the received approval objects(approval, approval tactics) 
    **********************************************************************************/
    
    public static void createApprovalRecordsHandler(List<sObject> recordsToInsert, String objectName, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList){
                
        //inserting the received list of sobjects:
        Database.SaveResult[] saveResultList = Database.insert(recordsToInsert,false); 
        Integer index = 0;
                
        for (Database.SaveResult saveResultListObj : saveResultList) {
                        
            if(!saveResultListObj.isSuccess()){
                // preparing logger records to record failures                
                //checking the type of sobject passed to fetch the particular id to be logged as guid in the logger object in case of any error is encountered:
                // to detect approval object insertion failed and log error
                if(objectName == TPM_ConstantsUtility.OBJECT_APPROVAL){
                    List<TPM_Approval__c> approvalList = (List<TPM_Approval__c>)recordsToInsert;
                    TPM_Utils.LogParamWrapper loggerObj = TPM_Utils.createLogParamWrapper(saveResultListObj.getErrors(),
                                                                                          TPM_ConstantsUtility.TRIGGER_PROMOTION_HELPER,
                                                                                          approvalList[index].TPM_Promotion__c);
                    
                    exceptionWrapperList.add(TPM_Utils.prepareBatchLogger(loggerObj));
                    
                } 
                // to detect approval tactic object insertion failed and log error
                else if(objectName == TPM_ConstantsUtility.OBJECT_APPROVALTACTICS){
                    List<TPM_Approval_Tactics__c> approvalTacticList = (List<TPM_Approval_Tactics__c>)recordsToInsert;
                    TPM_Utils.LogParamWrapper loggerObj = TPM_Utils.createLogParamWrapper(saveResultListObj.getErrors(),
                                                                                          TPM_ConstantsUtility.TRIGGER_PROMOTION_HELPER,
                                                                                          approvalTacticList[index].TPM_Approval__c);
                    
                    exceptionWrapperList.add(TPM_Utils.prepareBatchLogger(loggerObj));
                }
                
            } else {
                if(objectName == TPM_ConstantsUtility.OBJECT_APPROVAL){
                    //marking flag to true in case approvals get created, so that approval tactics records can be prepared and inserted:
                    TPM_Utils_Extension.isPromotionApprovalSuccess = true;
                }
            }
            index++;
        }
        
    }
    
     /*********************************************************************************
    @method          promotionApprovalRouting
	@return          Map<Id, Id>
	@param     	  	 promotionForApprovalIdMap
    @description     method handles promotion approval routing 
    **********************************************************************************/
    
    public static Map<Id, Id> promotionApprovalRouting(Map<Id, cgcloud__Promotion__c> promotionForApprovalIdMap) {

        // map to return promotionid as key and user id as value for approver assignment
        Map<Id, Id> promotionIdToApproverIdMap = new Map<Id, Id>();
                
        // Map contains 'salesorg-approvallevel' as key and approval amount threshold stored as value in custom mapping metadata records
        Map<String, String> approverLvlToApprovalThresholdMap = TPM_PromotionApprovalUtils.fetchApproverLevelDataMapping();

        // collect all the unique submitter ids from the records List 
        Set<Id> recordSubmitterIdSet = new Set<Id>();
        
        for(cgcloud__Promotion__c promoObj : promotionForApprovalIdMap.values()){

            recordSubmitterIdSet.add(promoObj.TPM_Promotion_Submitter__c);
        }
		        
        // Query for all the users who are the record submitter
        Map<Id, User> promoSubmitterUserRecordMap = TPM_PromotionApprovalUtils.fetchRecordSubmitterUserRecords(recordSubmitterIdSet);
        
        for(String promoId : promotionForApprovalIdMap.keySet()) {
                        
            Boolean isAutoApprovalChecked = false;
            
            cgcloud__Promotion__c promotionRecord = promotionForApprovalIdMap.get(promoId);

            // Any promotion spend that is above $20,000,000 should be routed to Label.TPM_PromotionApproval_TopApproverName
            if(TPM_PromotionApprovalUtils.assignTopApprover(promotionRecord, promotionIdToApproverIdMap)){
                continue;
            }

            // check if record submitter has approval threshold to approve itself
            isAutoApprovalChecked = TPM_PromotionApprovalUtils.promotionAutoApproval(promoSubmitterUserRecordMap.get(promotionRecord.TPM_Promotion_Submitter__c), promotionRecord, approverLvlToApprovalThresholdMap, promotionIdToApproverIdMap);
                        
            if(!isAutoApprovalChecked) {
                
                // get submitter's manager or higher for approval assignment
        		// record submitter as key and manager as value
                TPM_PromotionApprovalUtils.fetchManagerForRecordApproval(promotionRecord, promoSubmitterUserRecordMap.get(promotionRecord.TPM_Promotion_Submitter__c), approverLvlToApprovalThresholdMap, promotionIdToApproverIdMap);                
            }            
        }

        return promotionIdToApproverIdMap;
    }
	
    /*******************************************************************************************************
    * @Name          TPM_PromotionApprovalException
    * @Author        PwC Team
    * @date          17 Apr, 2023
    * @description   Exception Class to throw Custom Exceptions
    *******************************************************************************************************
    Change History Story      Modified by               Date                          Desc

    *******************************************************************************************************/
    public class TPM_PromotionApprovalException extends Exception {}

}