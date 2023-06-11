/******************************************************************************************************
@Name            TPM_AccountTriggerHelper
@testclass       TPM_AccountTriggerTest
@Author          PwC Team
@date            March 02, 2023
@description     Handles business logic for Account Trigger Handler 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_AccountTriggerHelper {
    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AccountTriggerHelper() { 
        
    }



    /********************************************************************************************************** 
	@methodname 	 preventModificationOfAccount
	@param           newMap
	@param           oldMap
	@description	 method handles the process to prevent updation of account records for Business Admin
	***********************************************************************************************************/  
    public static void preventModificationOfAccount(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        //Map of Old Records
        Map<Id, Account> assortmentOldMap = (Map<Id, Account>)oldMap;
        
        //Loop new records and check if the values of the fields in fieldsets 
        //are changed and if changed by business admin throw error
        for(Account acc : (List<Account>)newMap.Values()){
            Account accOld = assortmentOldMap.get(acc.id);
           for(FieldSetMember fld : SObjectType.Account.FieldSets.TPM_Account.getFields()) {

            //Compare old and new values of fields in field set
               if(accOld.get(fld.getSObjectField()) != acc.get(fld.getSObjectField())){
                acc.addError(System.Label.TPM_Account_Error_Message);
               }
          }

        }


    }
        
    /********************************************************************************************************** 
	@methodname 	 preventDeletionOfAccount
	@param           oldMap
	@description	 method handles the process to prevent Deletion of Account records for Business Admin
	***********************************************************************************************************/  
    public static void preventDeletionOfAccount(Map<Id,SObject> oldMap){
        //Loop all records which are going to be deleted and avoid 
        //deletion of records for business admin

        for(Account acc : (List<Account>)oldMap.Values()){
           acc.addError(System.Label.TPM_Account_Error_Message_Delete);
       }
    }

    /*********************************************************************************************************
    @methodname   	updateAccountChildInfo
    @createdDate  	03/06/2023
    @param     	  	newMap
    @param     	  	oldMap
    @description  	handles accounts sector, segment, subsegment sync for promotions and svf
    *********************************************************************************************************/
    public static void updateRelatedRecordsInfo(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {

        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        // list of Sobject to update account's related child record updates
        List<SObject> childRecordsToUpdate = new List<SObject>();

        // to filter out account ids set to process for child records query
        Set<Id> accountsToConsiderIdSet = new Set<Id>();
        try{
            //typecasting oldMap to map of accounts by Id
            Map<Id, Account> oldAccountMap = (Map<Id, Account>)oldMap;

            for(Account accountObj : (List<Account>)newMap.values()) {
                if(accountObj.TPM_Sector__c != oldAccountMap.get(accountObj.Id).TPM_Sector__c 
                || accountObj.TPM_Segment__c != oldAccountMap.get(accountObj.Id).TPM_Segment__c
                || accountObj.TPM_Subsegment__c != oldAccountMap.get(accountObj.Id).TPM_Subsegment__c){

                    accountsToConsiderIdSet.add(accountObj.Id);
                }
            }
                
            for(Account accountObj : [SELECT Id, TPM_Sector__c, TPM_Segment__c, TPM_Subsegment__c,
                                        (SELECT Id, TPM_Sector__c, TPM_Segment__c, TPM_Subsegment__c 
                                            FROM cgcloud__Promotions__r),
                                        (SELECT Id, TPM_Sector__c, TPM_Segment__c, TPM_Subsegment__c 
                                            FROM cgcloud__Customer_Business_Plans__r)
                                        FROM Account WHERE Id IN: accountsToConsiderIdSet]){
            
                preparePromotionSVFFieldUpdate(accountObj, childRecordsToUpdate);
            }

            if(!childRecordsToUpdate.isEmpty()){
                updateAccountRelatedSobjectRecords(childRecordsToUpdate, exceptionWrapperList, TPM_ConstantsUtility.ACCOUNT_TRIGGER_HELPER);
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
    @methodname 	 preparePromotionSVFFieldUpdate
    @param           accountObj
    @param           childRecordsToUpdate
    @description	 method updates sector, segment, subsegment on promotions and svf
    ***********************************************************************************************************/ 
    //bypassing since this ruleset is not applicable because the target and destination instance is different: 
    @SuppressWarnings('PMD.IdempotentOperations')
    public static void preparePromotionSVFFieldUpdate(Account accountObj, List<SObject> childRecordsToUpdate){

        // promotion field update assigment
        for(cgcloud__Promotion__c promoObj :  accountObj.cgcloud__Promotions__r) {
            promoObj.TPM_Sector__c = accountObj.TPM_Sector__c;
            promoObj.TPM_Segment__c = accountObj.TPM_Segment__c;
            promoObj.TPM_Subsegment__c = accountObj.TPM_Subsegment__c;
            childRecordsToUpdate.add(promoObj);
        }

        // SVF field update assigment
        for(cgcloud__Account_Plan__c accountPlanObj :  accountObj.cgcloud__Customer_Business_Plans__r) {
            accountPlanObj.TPM_Sector__c = accountObj.TPM_Sector__c;
            accountPlanObj.TPM_Segment__c = accountObj.TPM_Segment__c;
            accountPlanObj.TPM_Subsegment__c = accountObj.TPM_Subsegment__c;
            childRecordsToUpdate.add(accountPlanObj);
        }
    }

    /********************************************************************************************************** 
    @methodname 	 updateAccountRelatedSobjectRecords
    @param           recordsToUpdateList
    @param           exceptionWrapperList
    @param           flowName
    @description	 method handles the process to share all new records related to customer with account team members 
    ***********************************************************************************************************/ 
    public static void updateAccountRelatedSobjectRecords(List<sObject> recordsToUpdateList, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList, String flowName){

        // database operation for partial insert
        Database.SaveResult[] shareResults = Database.update(recordsToUpdateList, false);
        Integer index = 0;
        
        for(Database.SaveResult sResults : shareResults){
            if(!sResults.isSuccess()){

                // preparing logger records to record failures
                TPM_LoggerException.LogsWrapper logObj = new TPM_LoggerException.LogsWrapper();
                logObj.flow = flowName;
                logObj.logLevel = TPM_ConstantsUtility.ERROR;
                logObj.guid = (String)recordsToUpdateList[index].Id;
                logObj.errors = sResults.getErrors();
                exceptionWrapperList.add(logObj);
            }
            index++;
        }
    }
    
}