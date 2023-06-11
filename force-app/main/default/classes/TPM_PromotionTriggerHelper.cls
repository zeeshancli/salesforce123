/******************************************************************************************************
@Name            TPM_PromotionTriggerHelper
@testclass       TPM_PromotionCustomerPlanTriggerTest
@Author          PwC Team
@date            January 27, 2023
@description     Handles business logic for Promotion Trigger Handler 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.EmptyStatementBlock,PMD.CyclomaticComplexity')
public inherited sharing class TPM_PromotionTriggerHelper {

    // List to log errors/exceptions 
    public static List<TPM_LoggerException.LogsWrapper> exceptionWrapperList;
    
    
    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    
    private TPM_PromotionTriggerHelper() {
        
    }
    
    /********************************************************************************************************** 
	@methodname 	 extendPromotionSharingForAccountTeamMembers
	@param           newMap
	@param           oldMap
	@description	 method handles the process to share all Promotions Records on insert/update related to account
					 with team members
	***********************************************************************************************************/  
    public static void extendPromotionSharingForAccountTeamMembers(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        // initializing log WrapperList 
        exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();

        // preparing map of new promotion ids and account id for processing
        Map<Id, Id> newPromoIdandAcntIdMap = new Map<Id, Id>();
        
        try{
            Map<Id, cgcloud__Promotion__c> promotionsOldMap = (Map<Id, cgcloud__Promotion__c>)oldMap;

            // iterating over newly created promotions records to prepare map to store promo ids and parentids
            for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)newMap.Values()){
                
                if(Trigger.isInsert || (promotionsOldMap.get(promotionsObj.Id).cgcloud__Anchor_Account__c != promotionsObj.cgcloud__Anchor_Account__c)){
                    if(!newPromoIdandAcntIdMap.containsKey(promotionsObj.Id) && promotionsObj.cgcloud__Anchor_Account__c != null){
                   		newPromoIdandAcntIdMap.put(promotionsObj.Id, promotionsObj.cgcloud__Anchor_Account__c);
                    }
                } 
            }            

            if(!newPromoIdandAcntIdMap.isEmpty()){
                TPM_RecordSharingUtils.handleChildSharingForAccountsTeamMembers(newPromoIdandAcntIdMap, TPM_ConstantsUtility.PROMOTION_SHARE, exceptionWrapperList,  TPM_ConstantsUtility.TRIGGER_PROMOTION_HELPER);
            }
            
        }
        catch(Exception exp){
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.FATAL;
            exceptionWrapperList.add(logWrapperObj);
            
            // Call the TPM_LoggerException class log method to save all the exception details during insert
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }

     /********************************************************************************************************** 
	@methodname 	 handleFieldUpdatesForPromotion
	@param           promotionToCreateList
	@description	 method handles field upddates for promotion records from the related account record
	***********************************************************************************************************/ 
    
     //bypassing since this ruleset is not applicable because the target and destination instance is different: 
    @SuppressWarnings('PMD.IdempotentOperations')
    
    public static void handleFieldUpdatesForPromotion(List<SObject> promotionToCreateList){ 
        
       Set<Id> accountIdSet = new Set<Id>();
		Map<Id,Account> accountRecordMap = new Map<Id,Account>();
		
        for(cgcloud__Promotion__c promotionObj : (List<cgcloud__Promotion__c>) promotionToCreateList){
            
			accountIdSet.add(promotionObj.cgcloud__Anchor_Account__c);
        }
		
		for(Account accountObj : [SELECT
								  Id,
								  Name,
								  TPM_Segment__c,
								  TPM_Subsegment__c,
								  TPM_Sector__c
                                  FROM Account
                                  WHERE Id in:accountIdSet]){
								  
			accountRecordMap.put(accountObj.Id, accountObj);
		}
		
		
		for(cgcloud__Promotion__c promotionObj : (List<cgcloud__Promotion__c>) promotionToCreateList){
				
				if(accountRecordMap.containskey(promotionObj.cgcloud__Anchor_Account__c)){
				
					promotionObj.TPM_Segment__c = accountRecordMap.get(promotionObj.cgcloud__Anchor_Account__c).TPM_Segment__c;
					promotionObj.TPM_Subsegment__c = accountRecordMap.get(promotionObj.cgcloud__Anchor_Account__c).TPM_Subsegment__c;
					promotionObj.TPM_Sector__c = accountRecordMap.get(promotionObj.cgcloud__Anchor_Account__c).TPM_Sector__c;
				}
				
		}
    }
    
    /********************************************************************************************************** 
	@methodname 	 handleAccountPlanFieldForPromotion
	@param           newPromotionRecords
	@description	 method handles TPM_SVF__c field updates for promotion records
	***********************************************************************************************************/ 
    
    public static void handleAccountPlanFieldForPromotion(List<SObject> newPromotionRecords){

        // Set to store Anchor Account of promotion Records
        Set<Id> accountIdSet = new Set<Id>();
        //Set to store year from "In Store Date From" field of Promotion
        Set<Integer> businessYearSet = new Set<Integer>();
        // Map to store UniqueKey and SVF Ids
        Map<String,Id> accountPlanMap = new Map<String,Id>();
        // Map to store Promotion and Uniquekey for Promotion
        Map<cgcloud__Promotion__c,String> promotionMap = new Map<cgcloud__Promotion__c,String>();
        
        for(cgcloud__Promotion__c promotionObj : (List<cgcloud__Promotion__c>) newPromotionRecords){
            // checking wheter the Anchor Account and In store Date Thru aren't null
            if(promotionObj.cgcloud__Anchor_Account__c!=null && promotionObj.cgcloud__Placement_Date_From__c!=null){
                // adding Account & Year in set
                accountIdSet.add(promotionObj.cgcloud__Anchor_Account__c);
                businessYearSet.add(promotionObj.cgcloud__Placement_Date_From__c.year());
                // creating a UniqueKey for Promotion
                String accountYear = promotionObj.cgcloud__Anchor_Account__c+String.valueOf(promotionObj.cgcloud__Placement_Date_From__c.year());
                // Mapping the Promotion with Unique Key with this we can able to Identify the SVFs
                promotionMap.put(promotionObj,accountYear);
            }
        }
        
        for(cgcloud__Account_Plan__c accountPlanObj : [SELECT Id,cgcloud__Business_Year__c,cgcloud__Account__c FROM cgcloud__Account_Plan__c 
                                                       WHERE cgcloud__Business_Year__c IN :businessYearSet
                                                       AND cgcloud__Account__c IN :accountIdSet]){
                                                           // creating a Uniquekey for SVF which will be similar to Promtion UniqueKey
                                                           String accountYear = accountPlanObj.cgcloud__Account__c+String.valueOf(accountPlanObj.cgcloud__Business_Year__c);
                                                           // Mapping Unique key to AccountPlanID so we can update SVFId to Promotion
                                                           accountPlanMap.put(accountYear,accountPlanObj.Id);
                                                       }
        
        for(cgcloud__Promotion__c promotionRecord : promotionMap.keySet()){
            // Updating the TPM_SVF__c field
            // As PromotionMap has a uniquekey which is similar to uniquekey that has AccountPlan so will be updating PromotionRecord with SVFId
            Id svfIdPromotion = accountPlanMap.get(promotionMap.get(promotionRecord));
            if(svfIdPromotion!=null){
                promotionRecord.TPM_SVF__c = svfIdPromotion;
            }
            else{
                promotionRecord.TPM_SVF__c = null;
            }
        }
    } 


     /********************************************************************************************************** 
	@methodname 	 processApprovalRecords
	@param           newMap
    @param           oldMap
	@description	 create approval & approval tactics records when Phase changes from Planning to Submitted For Approval 
	***********************************************************************************************************/ 
    
    public static void processApprovalRecords(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        // initializing log WrapperList 
        exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        Map<Id, cgcloud__Promotion__c> promotionForApprovalIdMap = new Map<Id, cgcloud__Promotion__c>();
        
        // map contains promotion id as key and promotion template id as value
        Map<String, String> promoIdToPromotionTemplateIdMap = new Map<String, String>();
        
        try{
            Map<Id, cgcloud__Promotion__c> promotionsOldMap = (Map<Id, cgcloud__Promotion__c>)oldMap;
            
            // iterating over newly created promotions records to prepare map to store promo ids and parentids
            for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)newMap.Values()){
                
                if(String.isNotBlank(promotionsObj.TPM_Phase__c) && promotionsOldMap.get(promotionsObj.Id).TPM_Phase__c != promotionsObj.TPM_Phase__c){
                    
                    // method call check conditions to consider records when phase changes from planning to submit for approval
                    if(TPM_PromotionApprovalUtils.checkForApprovalCriteria(promotionsObj, promotionsOldMap.get(promotionsObj.Id))) {

                        promotionForApprovalIdMap.put(promotionsObj.Id, promotionsObj);
                        promoIdToPromotionTemplateIdMap.put(promotionsObj.Id, promotionsObj.cgcloud__Promotion_Template__c);
                    }
                } 
            }
            
            if(!promotionForApprovalIdMap.isEmpty()){
                TPM_PromotionApprovalManager.promotionApprovalHandler(promotionForApprovalIdMap, exceptionWrapperList, promoIdToPromotionTemplateIdMap );
            }
            
            if(!exceptionWrapperList.isEmpty()){
                TPM_LoggerException.log(exceptionWrapperList);
            }
        }
        catch(Exception exp){
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.FATAL;
            exceptionWrapperList.add(logWrapperObj);
            
            // Call the TPM_LoggerException class log method to save all the exception details during insert
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }

    
    /*********************************************************************************
    @method          handleCGCloudPhaseFieldUpdate
	@param     	  	 newMap
	@param     	  	 oldMap
    @description     method to SYNC cgcloud__Phase__c with TPM_Phase__c 
    **********************************************************************************/
    
    public static void handleCGCloudPhaseFieldUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        try{
            Map<Id, cgcloud__Promotion__c> promotionsOldMap = (Map<Id, cgcloud__Promotion__c>)oldMap;

            // iterating over newly updated promotions records to update cgcloud__Phase__c
            for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)newMap.Values()){
                
                if(String.isNotBlank(promotionsObj.TPM_Phase__c) && promotionsOldMap.get(promotionsObj.Id).TPM_Phase__c != promotionsObj.TPM_Phase__c){
                    TPM_PromotionTriggerUtils.doCGcloudPhaseUpdate(promotionsObj);
                } 
            }
        } catch(Exception exp){
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.exceptionObj = exp;
            logWrapperObj.logLevel = TPM_ConstantsUtility.FATAL;
            exceptionWrapperList.add(logWrapperObj);
            
            // Call the TPM_LoggerException class log method to save all the exception details during insert
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }

    /********************************************************************************************************** 
	@methodname 	 handleActivefieldForPromotion
	@param           promotionRecordMap
	@description	 Method to make active checkbox as false while creating promotions
	***********************************************************************************************************/ 
    
    public static void handleActivefieldForPromotion(Map<Id, SObject> promotionRecordMap){

		List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        Set<Id> promotionIdSet = new Set<Id>();
        List<cgcloud__Promotion__c> promotionListToUpdate = new List<cgcloud__Promotion__c>();
        
        for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)promotionRecordMap.Values()){
            promotionIdSet.add(promotionsObj.Id);
        }
        
        for(cgcloud__Promotion__c promotionObjFetched : [SELECT
                                                         Id,
                                                         Name,
                                                         cgcloud__Active__c,
                                                         cgcloud__Promotion_Template__r.Name
                                                         From cgcloud__Promotion__c
                                                         WHERE Id IN :promotionIdSet]){
                                                             
                                                             
             if(!TPM_ConstantsUtility.PARENT_PUSH_PROMOTIONS.contains(promotionObjFetched.cgcloud__Promotion_Template__r.Name)){
                     // make active checkbox as unchecked
                       promotionObjFetched.cgcloud__Active__c = false;
                 promotionListToUpdate.add(promotionObjFetched);
                 }                                              
        }
        
        if(!promotionListToUpdate.isEmpty()){
            
            Integer count = 0;
            
            Database.saveResult[] saveResultList = Database.update(promotionListToUpdate,false);
            
            for (Database.saveResult saveResultListObj : saveResultList) {
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = promotionListToUpdate[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.BATCH_ASSORTMENT_HELPER;
                    logWrapperObj.methodName=TPM_ConstantsUtility.UPDATE_ACCOUNT_RECORDS;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
            
                count++;
            }
            
            TPM_LoggerException.log(exceptionWrapperList);
        }      
    }
    /********************************************************************************************************** 
	@methodname 	 handleDefaultDraftPhasePromotion
	@param           promotionRecordMap
	@description	 Method to make all promotions except for child promotion as draft on creation
	***********************************************************************************************************/ 
    
    public static void handleDefaultDraftPhasePromotion(Map<Id, SObject> promotionRecordMap){

        Set<Id> promotionIdSet = new Set<Id>();
        List<cgcloud__Promotion__c> promotionListToUpdate = new List<cgcloud__Promotion__c>();
		List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
         for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)promotionRecordMap.Values()){
            promotionIdSet.add(promotionsObj.Id);
        }
        
        for(cgcloud__Promotion__c promotionObjFetched : [SELECT
                                                         Id,
                                                         Name,
                                                         cgcloud__Active__c,
                                                         TPM_Phase__c,
                                                         cgcloud__Promotion_Template__r.Name
                                                         From cgcloud__Promotion__c
                                                         WHERE Id IN :promotionIdSet]){
                       
                   if(!System.label.TPM_Child_Promotion_Templates.contains(promotionObjFetched.cgcloud__Promotion_Template__r.Name)){
                    
                       promotionObjFetched.TPM_Phase__c = 'Draft';
                 		promotionListToUpdate.add(promotionObjFetched);
                 }                                             
                                                             
        }
        
        if(!promotionListToUpdate.isEmpty()){
            
            Integer count = 0;
            
            Database.saveResult[] saveResultList = Database.update(promotionListToUpdate,false);
            
            for (Database.saveResult saveResultListObj : saveResultList) {
                
                if(!saveResultListObj.isSuccess()){
                    
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = promotionListToUpdate[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.TRIGGER_PROMOTION_HELPER;
                    logWrapperObj.methodName=TPM_ConstantsUtility.HANDLE_DEFAULT_DRAFT_PHASE;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
                
                count++;
            }
            
            if(!exceptionWrapperList.isEmpty()){
                TPM_LoggerException.log(exceptionWrapperList); 
            }
            
        }
        
        
        
    }
        
       
    /********************************************************************************************************** 
	@methodname 	 handleDraftForCopied
	@param           newMap
	@param           oldMap
	@description	 Method to make the copied promotions as draft after insert
	***********************************************************************************************************/ 
    
    public static void handleDraftForCopied(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){

      	List<cgcloud__Promotion__c> promotionListToUpdate = new List<cgcloud__Promotion__c>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)newMap.values()){
           
            cgcloud__Promotion__c oldPromotionObj = (cgcloud__Promotion__c)oldMap.get(promotionsObj.Id);
            
            if(oldPromotionObj.TPM_Phase__c == 'Draft'&& promotionsObj.TPM_Phase__c != 'Draft' && promotionsObj.cgcloud__Active__c == false){
                cgcloud__Promotion__c promotionObjToUpdate = new cgcloud__Promotion__c(Id = promotionsObj.Id);
                promotionObjToUpdate.TPM_Phase__c = 'Draft';
                promotionListToUpdate.add(promotionObjToUpdate);
            }
        }
        
        
           if(!promotionListToUpdate.isEmpty()){
            
            Integer count = 0;
               
            TPM_Utils.isBypassPromotionUpdateForDraft = true;
            Database.saveResult[] saveResultList = Database.update(promotionListToUpdate,false);
            
            
            for (Database.saveResult saveResultListObj : saveResultList) {
                
                if(!saveResultListObj.isSuccess()){
                    
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = promotionListToUpdate[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.TRIGGER_PROMOTION_HELPER;
                    logWrapperObj.methodName=TPM_ConstantsUtility.HANDLE_DRAFT_COPIED;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
               
                count++;
            }
            if(!exceptionWrapperList.isEmpty()){
               TPM_LoggerException.log(exceptionWrapperList); 
            }
        } 
    }    
       
        
        

    
}