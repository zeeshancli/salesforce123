/*******************************************************************************************************
* @Name         : TPM_ApprovalComponentController
* @Unit Test    : TPM_ApprovalComponentControllerTest
* @Author       : PwC Team
* @Date         : 28/04/2023
* @description  : Controller Class to get the Promotion related Approval Records for the lwc component
				  tpmApprovalCardComponent
*******************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public with sharing class TPM_ApprovalComponentController {
    
    /*********************************************************************************************************
    @methodname   	getPromotionRelatedApprovals
    @createdDate  	28/04/2023
    @param     	  	promotionId
	@param			currentUserId
    @return         getPromotionRelatedApprovals
    @description  	Method to get the Promotion Related Approval Records and Check its User Access for 
					the current logged in user. 
    *********************************************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static List<ApprovalWrapperClass> getPromotionRelatedApprovals(Id promotionId, Id currentUserId){
        
        List<ApprovalWrapperClass> approvalWrapperClassList = new List<ApprovalWrapperClass>();

        // If Promotion Id recieved Successfully
        if(promotionId != NULL){
            
            Set<Id> approvalRecordIdsSet = new Set<Id>();
            Map<Id,Boolean> recordIdReadAccessMap = new Map<Id,Boolean>();
            List<UserRecordAccess> userRecordAccessList = new List<UserRecordAccess>();

            // Call the TPM_OpenAccess.getPromotionRelatedApprovals 
            // To get the realted approval records for a Promotion record
            List<TPM_Approval__c> approvalRecordsList = TPM_OpenAccess.getPromotionRelatedApprovals(promotionId);
            
            for(TPM_Approval__c approvalObj : approvalRecordsList){
                approvalRecordIdsSet.add(approvalObj.Id);
            }
            
            // If Current User Id recieved Successfully
            if(currentUserId != NULL){
                // Query whether current user has
                // Read Access to the Approval Records or Not
                userRecordAccessList = [SELECT RecordId,
                                               HasEditAccess,
                                               HasReadAccess
                                        FROM   UserRecordAccess 
                                        WHERE  UserId =: currentUserId 
                                        AND    RecordId IN:approvalRecordIdsSet ]; 
            }
            
            // If UserRecordAccess found successfully
            if(!userRecordAccessList.isEmpty()){
                for(UserRecordAccess userRecordAccObj : userRecordAccessList){
                    // recordIdReadAccessMap contains
                    // Key as Approval Record Id
                    // Value as Read Access Boolean Value of the corresponding record
                    recordIdReadAccessMap.put(userRecordAccObj.RecordId, userRecordAccObj.HasReadAccess);
                }
            }
            
                // Iterate over the approvalRecordsList
                for(TPM_Approval__c approvalObj : approvalRecordsList){
                    
                    ApprovalWrapperClass approvalWrapperObj = new ApprovalWrapperClass();
                    // Check if recordIdReadAccessMap has the 
                    // Approval Record Id If yes then
                    // Get the Read Access Boolean value
                    if(recordIdReadAccessMap.containsKey(approvalObj.Id)){
                        approvalWrapperObj.iscurrentRecordAccess = recordIdReadAccessMap.get(approvalObj.Id);
                        // Check if user has read access to current approval record
                        // If yes then construct the link 
                        // Else assign NULL

                        approvalWrapperObj.approvalRecordURL = recordIdReadAccessMap.get(approvalObj.Id) == true ? TPM_ConstantsUtility.LIGHTNING_URL + TPM_ConstantsUtility.LIGHTNING_RELATED_PATH + approvalObj.Id + TPM_ConstantsUtility.LIGHTNING_URL_VIEW : NULL;
                    }
                    
                    approvalWrapperObj.approvalRecordId = approvalObj.Id;
                    approvalWrapperObj.approvalRecordName = approvalObj.Name;
                    approvalWrapperObj.approvalRecordCreatedDate = Date.newinstance(approvalObj.CreatedDate.year(), approvalObj.CreatedDate.month(), approvalObj.CreatedDate.day());
                    approvalWrapperObj.approvalRecordOwner = approvalObj.Owner.Name;
                    approvalWrapperObj.approvalStatus = approvalObj.TPM_Status__c;
                    approvalWrapperObj.promotionRecordSubmitter = approvalObj.TPM_Promotion_Submitter__r.Name;
                    approvalWrapperClassList.add(approvalWrapperObj);
                }
            

        }
        return approvalWrapperClassList;
    }
    
    /*******************************************************************************************************
    * @Name         : ApprovalWrapperClass
    * @Unit Test    : ApprovalWrapperClassTest
    * @Author       : PwC Team
    * @Date         : 28/04/2023
    * @description  : Wrapper Class to send the list of attributes to the JS Controller
    *******************************************************************************************************/
    public class ApprovalWrapperClass{
        
        /*******************************************************
         * @description approval Record Id
         *******************************************************/
        @AuraEnabled
        public Id approvalRecordId;
        
        /*******************************************************
         * @description approval Record Name
         *******************************************************/
        @AuraEnabled
        public String approvalRecordName;
        
        /*******************************************************
         * @description approval Record Created Date
         *******************************************************/
        @AuraEnabled
        public Date approvalRecordCreatedDate;
        
        /*******************************************************
         * @description approval Record Owner
         *******************************************************/
        @AuraEnabled
        public String approvalRecordOwner;
        
        /*******************************************************
         * @description approval Status
         *******************************************************/
        @AuraEnabled
        public String approvalStatus;
        
        /*******************************************************
         * @description promotion Record Submitter
         *******************************************************/
        @AuraEnabled
        public String promotionRecordSubmitter;
        
        /*******************************************************
         * @description current Record Access
         *******************************************************/
        @AuraEnabled
        public Boolean iscurrentRecordAccess;
        
        /*******************************************************
         * @description approval Record URL
         *******************************************************/
        @AuraEnabled
        public String approvalRecordURL;
    }
}