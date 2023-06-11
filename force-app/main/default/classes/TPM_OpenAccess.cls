/*******************************************************************************************************
* @Name         : TPM_OpenAccess
* @Unit Test    : TPM_OpenAccessTest
* @Author       : PwC Team
* @Date         : 28/04/2023
* @description  : A Generic Without Sharing Class to perform DML without enforcing Object and Record
				  Sharing
*******************************************************************************************************/
public without sharing class TPM_OpenAccess {
    
    /*********************************************************************************************************
    @methodname   	getPromotionRelatedApprovals
    @createdDate  	28/04/2023
    @param     	  	promotionId
	@return 		List<TPM_Approval__c>
    @description  	Method to get the Promotion Related Approval Records.
    *********************************************************************************************************/
    public static List<TPM_Approval__c> getPromotionRelatedApprovals(Id promotionId){
        
        List<TPM_Approval__c> approvalRecordsList = [SELECT Id, 
                                              		 Name, 
                                              		 CreatedDate, 
                                              		 CreatedById, 
                                              		 CreatedBy.Name,
                                              	     TPM_Status__c,
                                                     TPM_Promotion_Submitter__c,
                                                     TPM_Promotion_Submitter__r.Name ,
                                                     TPM_Promotion__c, 
                                                     TPM_Phase__c,
                                                     OwnerId,
                                                     Owner.Name
                                              FROM   TPM_Approval__c 
                                              WHERE  TPM_Promotion__c =: promotionId];
        
            return approvalRecordsList;
    }
    
    /*********************************************************************************************************
    @methodname   	isUpdateAccountRecordFlag
    @createdDate  	May 10 2023
    @param     	  	objectRecordId
	@param			executeTPMCalculationChainBatch
	@return 		boolean
    @description  	Method to update the custom flag field on Account Record on Promotion After Save Process. 
    *********************************************************************************************************/
    public static boolean isUpdateAccountRecordFlag(String objectRecordId, Boolean executeTPMCalculationChainBatch){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
        
        // Get the Promotion Record
        cgcloud__Promotion__c promoObj = [SELECT Id,
                                          		 Name,
                                          		 cgcloud__Anchor_Account__c
                                         FROM 	 cgcloud__Promotion__c
                                         WHERE 	 Id =:objectRecordId];
       
        // Get the Related Account for the Promotion Record
        Account accObj = [SELECT Id,
                          		 Name,
                          		 TPM_ProcessTPMCalculationChain__c
                          FROM   Account
                          WHERE  Id = : promoObj.cgcloud__Anchor_Account__c];
        
        // Check if the TPM_ProcessTPMCalculationChain__c already 
        // Set as True or not 
        if(accObj.TPM_ProcessTPMCalculationChain__c != TRUE){
            // If not True 
            // Check the field TPM_ProcessTPMCalculationChain__c
            accObj.TPM_ProcessTPMCalculationChain__c = TRUE;
            try{
                // Update the Account Record
                 update accObj;
                 executeTPMCalculationChainBatch = TRUE;
                 
            }catch(Exception exp){
                
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.exceptionObj = exp;
                logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
                logWrapperObj.className = TPM_ConstantsUtility.TPM_PROMOTION_MAIN_CARD_CONTROLLER;
                logWrapperObj.methodName = TPM_ConstantsUtility.EXECUTE_TPM_CACULATION_CHAIN_BATCH;
                exceptionWrapperList.add(logWrapperObj);
                TPM_LoggerException.log(exceptionWrapperList);
            } 
        }
        
        return executeTPMCalculationChainBatch;
    }
}