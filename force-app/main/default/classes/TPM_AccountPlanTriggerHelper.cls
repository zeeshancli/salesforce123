/******************************************************************************************************
@Name            TPM_AccountPlanTriggerHelper
@testclass       TPM_PromotionCustomerPlanTriggerTest
@Author          PwC Team
@date            January 27, 2023
@description     Handles business logic for Customer Business Plan Trigger Handler 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_AccountPlanTriggerHelper {
    
    // List to log errors/exceptions 
    public static List<TPM_LoggerException.LogsWrapper> exceptionWrapperList;
    
    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AccountPlanTriggerHelper() { 
        
    }
    
    /********************************************************************************************************** 
	@methodname 	 extendCBPSharingForAccountTeamMembers
	@param           newMap
	@param           oldMap
	@description	 method handles the process to share all CBP Records on insert/update related to account with team members 
	***********************************************************************************************************/  
    public static void extendCBPSharingForAccountTeamMembers(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        // initializing log WrapperList 
        exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();

        // preparing map of new cbp ids and account id for processing
        Map<Id, Id> newCBPIdandAcntIdMap = new Map<Id, Id>();
        
        try{
            Map<Id, cgcloud__Account_Plan__c> cbpOldMap = (Map<Id, cgcloud__Account_Plan__c>)oldMap;

            // iterating over newly created cbp records to prepare map to store cbpid and parentids
            for(cgcloud__Account_Plan__c cbpObj : (List<cgcloud__Account_Plan__c>)newMap.Values()){
                
                if(Trigger.isInsert || (cbpOldMap.get(cbpObj.Id).cgcloud__Account__c != cbpObj.cgcloud__Account__c)){ 
                    // If the parent account is not already in the map, add it
                    if(!newCBPIdandAcntIdMap.containsKey(cbpObj.Id) && cbpObj.cgcloud__Account__c != null){
                        newCBPIdandAcntIdMap.put(cbpObj.Id, cbpObj.cgcloud__Account__c);
                    } 
                }
            }            
			
            if(!newCBPIdandAcntIdMap.isEmpty()){
                TPM_RecordSharingUtils.handleChildSharingForAccountsTeamMembers(newCBPIdandAcntIdMap, TPM_ConstantsUtility.ACCOUNTPLAN_SHARE, exceptionWrapperList,  TPM_ConstantsUtility.TRIGGER_ACCOUNTPLAN_HELPER);
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
	@methodname 	 handleFieldUpdatesForSVF
	@param           svfToCreateList
	@description	 method handles field upddates for svf records from the related account record
	***********************************************************************************************************/
    
     //bypassing since this ruleset is not applicable because the target and destination instance is different: 
    @SuppressWarnings('PMD.IdempotentOperations')
    
    public static void handleFieldUpdatesForSVF(List<SObject> svfToCreateList){ 
        
        Set<Id> accountIdSet = new Set<Id>();
		Map<Id,Account> accountRecordMap = new Map<Id,Account>();
		
        for(cgcloud__Account_Plan__c svfObj : (List<cgcloud__Account_Plan__c>) svfToCreateList){
            
			accountIdSet.add(svfObj.cgcloud__Account__c);
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
		
		
		for(cgcloud__Account_Plan__c svfObj : (List<cgcloud__Account_Plan__c>) svfToCreateList){
				
				if(accountRecordMap.containskey(svfObj.cgcloud__Account__c)){
				
					svfObj.TPM_Segment__c = accountRecordMap.get(svfObj.cgcloud__Account__c).TPM_Segment__c;
					svfObj.TPM_Subsegment__c = accountRecordMap.get(svfObj.cgcloud__Account__c).TPM_Subsegment__c;
					svfObj.TPM_Sector__c = accountRecordMap.get(svfObj.cgcloud__Account__c).TPM_Sector__c;
				}
				
		}
    }

    
}