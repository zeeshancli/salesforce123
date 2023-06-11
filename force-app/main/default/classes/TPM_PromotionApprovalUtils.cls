/******************************************************************************************************
@Name            TPM_PromotionApprovalUtils
@testclass       TPM_PromotionCustomerPlanTriggerTest
@Author          PwC Team
@date            March 22, 2023
@description     Utility class for promotion record approvals/tactics creations and,
				 Handles business logic for approval records approvals routing
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public inherited sharing class TPM_PromotionApprovalUtils {

    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_PromotionApprovalUtils() {

    }


    /*********************************************************************************
    @method          checkForApprovalCriteria
    @return          Boolean
	@param     	  	 promotionsNewObj
	@param     	  	 promotionsOldObj
    @description     method check conditions to consider records to submit for approval
    **********************************************************************************/
    
    public static Boolean checkForApprovalCriteria(cgcloud__Promotion__c promotionsNewObj,  cgcloud__Promotion__c promotionsOldObj) {
        
        // condition checks for phase change on promotion
        return (promotionsOldObj.TPM_Phase__c != null 
                && promotionsOldObj.TPM_Phase__c.equalsIgnoreCase(TPM_ConstantsUtility.PHASE_PLANNING) 
                && promotionsNewObj.TPM_Phase__c.equalsIgnoreCase(TPM_ConstantsUtility.PHASE_SUBMITTEDFORAPPROVAL));
    }


     /*********************************************************************************
    @method          fetchManagerForRecordApproval
	@param     	  	 promotionForApproval
    @param     	  	 submitterUserRecord
    @param     	  	 approverLvlToApprovalThresholdMap
    @param     	  	 promotionIdToApproverIdMap
    @description     method fetches submitter's manager or higher if current OutOfOffice 
					 for record approval routing 
    **********************************************************************************/
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    public static void fetchManagerForRecordApproval(cgcloud__Promotion__c promotionForApproval, User submitterUserRecord, Map<String, String> approverLvlToApprovalThresholdMap, Map<Id, Id> promotionIdToApproverIdMap) {
        
        	Set<Id> managersInHierarchyIdSet = new Set<Id>();
                    
            // If the submitter's 1st level manager has APPROVAL_LEVEL assigned 
            // then validation will force to have manager for that user, assign them as the approver
            
            if(submitterUserRecord.Manager.TPM_ApprovalLevel__c != TPM_ConstantsUtility.APPROVAL_LEVEL_NA 
               && !submitterUserRecord.Manager.TPM_Is_OutOfOffice__c) {
                
                   if(verifyUserForPromotionApproval(submitterUserRecord.Manager.cgcloud__Sales_Org__c, 
                                                     submitterUserRecord.Manager.TPM_ApprovalLevel__c, 
                                                     promotionForApproval.TPM_Planned_Spend__c, approverLvlToApprovalThresholdMap)) {
                                                         
                       promotionIdToApproverIdMap.put(promotionForApproval.Id, submitterUserRecord.ManagerId);
                       return;
                   }
            }
            // Otherwise, find the next active manager at 2nd level up the hierarchy
            if(submitterUserRecord.Manager.Manager.TPM_ApprovalLevel__c != TPM_ConstantsUtility.APPROVAL_LEVEL_NA 
                && !submitterUserRecord.Manager.Manager.TPM_Is_OutOfOffice__c) {                   
                        
                        if(verifyUserForPromotionApproval(submitterUserRecord.Manager.Manager.cgcloud__Sales_Org__c, 
                                                     submitterUserRecord.Manager.Manager.TPM_ApprovalLevel__c, 
                                                     promotionForApproval.TPM_Planned_Spend__c, approverLvlToApprovalThresholdMap)) {
                                                         
                        promotionIdToApproverIdMap.put(promotionForApproval.Id, submitterUserRecord.Manager.ManagerId);
                        return;
                    }                
            }
            // Otherwise, find the next active manager at 3rd level up the hierarchy
            if(submitterUserRecord.Manager.Manager.Manager.TPM_ApprovalLevel__c != TPM_ConstantsUtility.APPROVAL_LEVEL_NA 
                && !submitterUserRecord.Manager.Manager.Manager.TPM_Is_OutOfOffice__c) {
                                        
                    if(verifyUserForPromotionApproval(submitterUserRecord.Manager.Manager.Manager.cgcloud__Sales_Org__c, 
                                                     submitterUserRecord.Manager.Manager.Manager.TPM_ApprovalLevel__c, 
                                                     promotionForApproval.TPM_Planned_Spend__c, approverLvlToApprovalThresholdMap)) {
                        promotionIdToApproverIdMap.put(promotionForApproval.Id, submitterUserRecord.Manager.Manager.ManagerId);
                        return;
                    }
            }
            // Otherwise, find the next active manager at 4th level up the hierarchy
            if(submitterUserRecord.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c != TPM_ConstantsUtility.APPROVAL_LEVEL_NA 
                && !submitterUserRecord.Manager.Manager.Manager.Manager.TPM_Is_OutOfOffice__c) {
                                        
                    if(verifyUserForPromotionApproval(submitterUserRecord.Manager.Manager.Manager.Manager.cgcloud__Sales_Org__c, 
                                                     submitterUserRecord.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c, 
                                                     promotionForApproval.TPM_Planned_Spend__c, approverLvlToApprovalThresholdMap)) {
                                                         
                        promotionIdToApproverIdMap.put(promotionForApproval.Id, submitterUserRecord.Manager.Manager.Manager.ManagerId);
                        return;
                    }
            }
            // Otherwise, find the next active manager at 5th level up the hierarchy
            if(submitterUserRecord.Manager.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c != TPM_ConstantsUtility.APPROVAL_LEVEL_NA 
                && !submitterUserRecord.Manager.Manager.Manager.Manager.Manager.TPM_Is_OutOfOffice__c) {
                                        
                    if(verifyUserForPromotionApproval(submitterUserRecord.Manager.Manager.Manager.Manager.Manager.cgcloud__Sales_Org__c, 
                                                     submitterUserRecord.Manager.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c, 
                                                     promotionForApproval.TPM_Planned_Spend__c, approverLvlToApprovalThresholdMap)) {
                                                         
                        promotionIdToApproverIdMap.put(promotionForApproval.Id, submitterUserRecord.Manager.Manager.Manager.Manager.ManagerId);
                        return;
                    }
            }
            
            if(submitterUserRecord.Manager.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c != null 
               && Integer.valueOf(submitterUserRecord.Manager.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c) < TPM_ConstantsUtility.NUMBER_9) {
                managersInHierarchyIdSet.add(submitterUserRecord.Manager.Manager.Manager.Manager.ManagerId);
            }

        if(!managersInHierarchyIdSet.isEmpty()) {
            List<User> nextLvlUserRecordList = fetchRecordSubmitterUserRecords(managersInHierarchyIdSet).values();
            if(!nextLvlUserRecordList.isEmpty()){
                fetchManagerForRecordApproval(promotionForApproval, nextLvlUserRecordList[0], approverLvlToApprovalThresholdMap, promotionIdToApproverIdMap);
            }
        }
		
    }
    
    
    /*********************************************************************************
    @method          verifyAmountWithInApprovalRange
    @return 	     Boolean
	@param     	  	 maxApprovalAmount
	@param     	  	 amountForApproval
    @description     method verifies approval amount if falls in approval threshold defined.
    **********************************************************************************/
    
    public static Boolean verifyAmountWithInApprovalRange(Object maxApprovalAmount, Object amountForApproval){
        
        Boolean isAmtInApprovalRange = false;

        // checking approval amount within approval threshold
        if(maxApprovalAmount != null && amountForApproval != null){
            isAmtInApprovalRange =  (Double.valueOf(amountForApproval) <= Double.valueOf(maxApprovalAmount));
        }
        return isAmtInApprovalRange;
    }


    /*********************************************************************************
    @method          fetchApproverLevelDataMapping
    @return          Map<String, String>
    @description     method query and return custom metadata records for manager level
                     mapping and threshold amount defined as TPM_PromotionApprovalRouting
    **********************************************************************************/
    
    public static Map<String, String> fetchApproverLevelDataMapping() {

        Map<String, String> approverLvlToApprovalThresholdMap =  new Map<String, String>();

        //Iterating over custom mappping records for TPM_PromotionApprovalRouting and preparing approval level mapping
        for(TPM_CustomMappings__mdt approvalLevelMapping : (List<TPM_CustomMappings__mdt>)TPM_Utils_Extension.queryCustomMetadataRecords(
            												TPM_ConstantsUtility.CUSTOMMAPPING_METADATA_API, 
            												TPM_ConstantsUtility.CUSTOMMAPPING_METADATA_FIELDSLIST, 
            												TPM_ConstantsUtility.CUSTOMMAPPING_CRITERIAMAP_PROMOTIONAPPROVALROUTING)){
             

            approverLvlToApprovalThresholdMap.put(approvalLevelMapping.TPM_Key__c, approvalLevelMapping.TPM_Value__c);
        }

        return approverLvlToApprovalThresholdMap;
    }

    /*********************************************************************************
    @method          promotionAutoApproval
    @return          Boolean
	@param     	  	 submitterUserRecord
    @param           promotionRecord
    @param           approverLvlToApprovalThresholdMap
    @param           promotionIdToApproverIdMap
    @description     method handles promotion auto approval business logic
    **********************************************************************************/
    
    public static Boolean promotionAutoApproval(User submitterUserRecord, cgcloud__Promotion__c promotionRecord, Map<String, String> approverLvlToApprovalThresholdMap, Map<Id, Id> promotionIdToApproverIdMap) {
                        
        if(verifyUserForPromotionApproval(submitterUserRecord.cgcloud__Sales_Org__c, submitterUserRecord.TPM_ApprovalLevel__c, promotionRecord.TPM_Planned_Spend__c, approverLvlToApprovalThresholdMap)){
            promotionIdToApproverIdMap.put(promotionRecord.Id, submitterUserRecord.Id);
            return true;
        } 

        return false;
        
    }

    /*********************************************************************************
    @method          fetchRecordSubmitterUserRecords
	@return          Map<Id, User>
	@param     	  	 recordSubmitterIdSet
    @description     method query records submitter user records
    **********************************************************************************/
    
    public static Map<Id, User> fetchRecordSubmitterUserRecords(Set<Id> recordSubmitterIdSet) {        
        
        // Query for all the users who are the record submitter
        Map<Id, User> submitterUserRecordMap = new Map<Id, User>([ SELECT Id, cgcloud__Sales_Org__c,									   		//owner
                                                          	   		TPM_ApprovalLevel__c, TPM_Is_OutOfOffice__c,                             

                                                          	   		ManagerId, Manager.IsActive, Manager.TPM_Is_OutOfOffice__c,                 //1 level up
                                                               		Manager.cgcloud__Sales_Org__c, Manager.TPM_ApprovalLevel__c,

                                                               		Manager.ManagerId, Manager.Manager.IsActive, 							   //2nd level up
                                                               		Manager.Manager.TPM_Is_OutOfOffice__c,  
                                                               		Manager.Manager.cgcloud__Sales_Org__c, Manager.Manager.TPM_ApprovalLevel__c,

                                                               		Manager.Manager.ManagerId, Manager.Manager.Manager.IsActive,                //3rd level up
                                                               		Manager.Manager.Manager.TPM_Is_OutOfOffice__c,  
                                                               		Manager.Manager.Manager.cgcloud__Sales_Org__c,
                                                               		Manager.Manager.Manager.TPM_ApprovalLevel__c,
                                                               
                                                               		Manager.Manager.Manager.ManagerId, 										  	//4th level up
                                                               		Manager.Manager.Manager.Manager.IsActive,
                                                               		Manager.Manager.Manager.Manager.TPM_Is_OutOfOffice__c,  
                                                               		Manager.Manager.Manager.Manager.cgcloud__Sales_Org__c,
                                                               		Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c,
                                                                  
                                                               		Manager.Manager.Manager.Manager.ManagerId,								   //5th level up
                                                               		Manager.Manager.Manager.Manager.Manager.IsActive,
                                                               		Manager.Manager.Manager.Manager.Manager.TPM_Is_OutOfOffice__c,  
                                                               		Manager.Manager.Manager.Manager.Manager.cgcloud__Sales_Org__c,
                                                               		Manager.Manager.Manager.Manager.Manager.TPM_ApprovalLevel__c
                                                                  
                                                               FROM User WHERE Id IN :recordSubmitterIdSet AND IsActive = true]);

        return submitterUserRecordMap;
    }
    
    
    /*********************************************************************************
    @method          verifyUserForPromotionApproval
    @return          Boolean
    @param     	  	 salesOrg
	@param     	  	 approvalLevel
	@param     	  	 plannedSpend
	@param     	  	 approverLvlToApprovalThresholdMap
    @description     method checks and verify user's approval thrshold
                     using user sales org and approval level combination
    **********************************************************************************/
    
    public static Boolean verifyUserForPromotionApproval(String salesOrg, String approvalLevel, Object plannedSpend, Map<String, String> approverLvlToApprovalThresholdMap) {

        Boolean isWithInApprovalLimit = false;
        
        // preparing key to get manager's approval amount assigned
        String keyForApprovalThreshold = '';
                
        if(salesOrg != null && approvalLevel != null && approvalLevel != TPM_ConstantsUtility.APPROVAL_LEVEL_NA) {
            
            keyForApprovalThreshold = salesOrg+'-'+approvalLevel;
        } 
                
        if(String.isNotBlank(keyForApprovalThreshold) && approverLvlToApprovalThresholdMap.containsKey(keyForApprovalThreshold)){
            
            // get record submitter max approval amount for approval
            isWithInApprovalLimit = verifyAmountWithInApprovalRange(approverLvlToApprovalThresholdMap.get(keyForApprovalThreshold), plannedSpend);
        }   
        
        return isWithInApprovalLimit;
    }
    
    /*********************************************************************************
    @method          assignTopApprover
    @return          Boolean
    @param           promotionRecord
    @param           promotionIdToApproverIdMap
    @description     method checks and assign if promotion spend that is above $20,000,000 
                     should route to TPM_PromotionApproval_TopApproverName
    **********************************************************************************/
    
    public static Boolean assignTopApprover(cgcloud__Promotion__c promotionRecord, Map<Id, Id> promotionIdToApproverIdMap) {

        List<User> topPromotionApprover = [SELECT Id FROM User WHERE Name = :Label.TPM_PromotionApproval_TopApproverName AND IsActive = true LIMIT 1]; 

        if(!topPromotionApprover.isEmpty() && promotionRecord.TPM_Planned_Spend__c != null &&
            promotionRecord.TPM_Planned_Spend__c > Integer.valueOf(System.label.TPM_PromotionApproval_TopApprovalAmount)){

            promotionIdToApproverIdMap.put(promotionRecord.Id, topPromotionApprover[0].Id);
            return true;
        } else {
            return false;
        }

    }

}