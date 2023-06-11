/*******************************************************************************************************
* @Name         : TPM_CBPCategoryTriggerHelper
* @Unit Test    : TPM_CBPCategoryTriggerTest
* @Author       : PwC Team
* @Date         : April 10, 2023
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the CBP Category records.
*******************************************************************************************************/
public inherited sharing class TPM_CBPCategoryTriggerHelper {

    /***************************************************************************************************
    @methodname 	TPM_CBPCategoryTriggerHelper
    @createdDate 	April 10, 2023
    @description	default private constructor
    ****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_CBPCategoryTriggerHelper(){
    
    }
        
        /*********************************************************************************************************
    @methodname   	updateFieldsForAccounts
    @createdDate  	April 10, 2023
    @param     	  	newMap
    @param     	  	oldMap
    @description  	after the update of a cbp category we need to check the flag true for accounts
    *********************************************************************************************************/
    @SuppressWarnings('PMD.CyclomaticComplexity')
        public static void updateFieldsForAccounts(Map<Id,Sobject> newMap, Map<Id,Sobject> oldMap){
            
            
            Set<Id> accountPlanIdSet = new Set<Id>();
            set<Id> accountIdSet = new Set<Id>();
            List<Account> accountListToUpdate = new List<Account>();
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
            
            for(cgcloud__Account_Plan_Category__c cbpCategoryObj : (List<cgcloud__Account_Plan_Category__c>)newMap.Values()){
                cgcloud__Account_Plan_Category__c oldCbpCategoryObj = (cgcloud__Account_Plan_Category__c)oldMap.get(cbpCategoryObj.Id);
                if(cbpCategoryObj.cgcloud__Manual_Calculation_Input__c != oldCbpCategoryObj.cgcloud__Manual_Calculation_Input__c ||
                  cbpCategoryObj.cgcloud__Manual_Calculation_Input_2__c	!= oldCbpCategoryObj.cgcloud__Manual_Calculation_Input_2__c ||
                  cbpCategoryObj.cgcloud__Manual_Calculation_Input_3__c	!= oldCbpCategoryObj.cgcloud__Manual_Calculation_Input_3__c){
                    accountPlanIdSet.add(cbpCategoryObj.cgcloud__Account_Plan__c);
                }
                
            }
            
            for(cgcloud__Account_Plan__c accountPlanObj : [SELECT 
                                                           Id,
                                                           cgcloud__Account__c
                                                          FROM cgcloud__Account_Plan__c
                                                          WHERE Id IN :accountPlanIdSet]){
                accountIdSet.add(accountPlanObj.cgcloud__Account__c);
            }
            
            for(Account accountObj : [SELECT 
                                      Id,
                                     TPM_ProcessTPMCalculationChain__c
                                     FROM Account
                                     WHERE Id IN :accountIdSet]){
                                         if(!accountObj.TPM_ProcessTPMCalculationChain__c) {
                                             accountObj.TPM_ProcessTPMCalculationChain__c = true;
                                             accountListToUpdate.add(accountObj);
                                         }                     
                
                                         
            }
            
            if(!accountListToUpdate.isEmpty()){
                
                Integer count = 0;
                
                Database.saveResult[] saveResultList = Database.update(accountListToUpdate,false);
                
                for (Database.saveResult saveResultListObj : saveResultList) {
                    if(!saveResultListObj.isSuccess()){
                        TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                        logWrapperObj.errors = saveResultListObj.getErrors();
                        logWrapperObj.guid = accountListToUpdate[count].id;
                        logWrapperObj.className=TPM_ConstantsUtility.TRIGGER_CBP_CATEGORY_HELPER;
                        logWrapperObj.methodName=TPM_ConstantsUtility.UPDATE_BATCH_FLAG_ACCOUNT;
                        logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                        exceptionWrapperList.add(logWrapperObj);
                    }
                
                    count++;
                }
                
                TPM_LoggerException.log(exceptionWrapperList);
            }
            
            
        
    
        }
    }