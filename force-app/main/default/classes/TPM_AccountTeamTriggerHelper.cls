/*******************************************************************************************************
* @Name         : TPM_AccountTeamTriggerHelper
* @Unit Test    : TPM_AccountTeamTriggerTest
* @Author       : PwC Team
* @Date         : 01/18/2023
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the account team records.
*******************************************************************************************************/

public inherited sharing class TPM_AccountTeamTriggerHelper {

/***************************************************************************************************
@methodname 	TPM_UserTriggerHelper
@createdDate 	01/18/2023
@description	default private constructor
****************************************************************************************************/

@SuppressWarnings('PMD.EmptyStatementBlock')
private TPM_AccountTeamTriggerHelper(){

}


    /*********************************************************************************************************
@methodname   	assignAccountTeamMember
@createdDate  	01/18/2023
@param     	  	newMap
@description  	after the insert of a account team member for a managed account, we need to assign users for the entire account hierarchy. 
*********************************************************************************************************/

public static void assignAccountTeamMember(Map<Id,Sobject> newMap){
    List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
    Set<Id> accountIdSet =  new Set<Id>();
    Set<Id> managedAccountIdSet = new Set<Id>();
   List<AccountTeamMember> accountTeamMemberToCreateList = new List<AccountTeamMember>();
    
    try{
        
        //iterating newMap of the newly created account team member records to fetch the accounts:

        for(AccountTeamMember accTeamMemberObj : (List<AccountTeamMember>)newMap.Values()){
            accountIdSet.add(accTeamMemberObj.AccountId);
        }
    
    //fetching only the managed accounts:

    managedAccountIdSet = TPM_AccountTeamTriggerHelperNext.fetchingManagedAccounts(accountIdSet);
        
    //fetching all the related Account details for the managedAccount

    TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper = TPM_AccountTeamHelper.createChildParentMapForManagedAccount(managedAccountIdSet);
    
    //iterating newMap of the newly created account team member records to add the same account team members to the related accounts as well:
    
    for(AccountTeamMember accTeamMember : (List<AccountTeamMember>)newMap.Values()){
        if(relatedaccountWrapper.managedAccountAndRelatedMap.containskey(accTeamMember.AccountId)){
            accountTeamMemberToCreateList.addAll(TPM_AccountTeamTriggerHelperNext.prepareAccountTeamMemberRecords(accTeamMember,relatedaccountWrapper.managedAccountAndRelatedMap));
        }
    }
        
    //Inserting the account team member for the related accounts of the managed accounts:
    
    if(!accountTeamMemberToCreateList.isEmpty()){
        Database.SaveResult[] saveResultList = database.insert(accountTeamMemberToCreateList,false);
        //Integer index = 0;

        for (Database.SaveResult saveResultListObj : saveResultList) {
            if(!saveResultListObj.isSuccess()){
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.errors = saveResultListObj.getErrors();
                logWrapperObj.className=TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
                logWrapperObj.methodName=TPM_ConstantsUtility.ASSIGN_TEAM_MEMBER;
                logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                //logWrapperObj.TPM_GUID__c=accountTeamMemberToCreateList[index].AccountId;//check again
                exceptionWrapperList.add(logWrapperObj);
            }else{
                //boolean value used tov avoid recursion for the assign team member functionality

                TPM_Utils.isBypassAssignAccountTeamMember=true;
            }
           // index++;
        }
        

        //Call the TPM_LoggerException class log method to save all the exception details during insert

        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }
        
    }
}
catch(Exception exp){
    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
    logWrapperObj.exceptionObj=exp;
    logWrapperObj.className=TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
    logWrapperObj.methodName=TPM_ConstantsUtility.ASSIGN_TEAM_MEMBER;
    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
    exceptionWrapperList.add(logWrapperObj);
    //Call the TPM_LoggerException class log method to save all the exception details during insert
    TPM_LoggerException.log(exceptionWrapperList);
}
}

/*********************************************************************************************************
@methodname   	removeAccountTeamMember
@createdDate  	01/19/2023
@param     	  	oldMap
@description  	after the deletion of a account team member for a managed account, we need to remove users for the entire account hierarchy. 
*********************************************************************************************************/

public static void removeAccountTeamMember(Map<Id,Sobject> oldMap){
    
    Set<Id> accountIdSet =  new Set<Id>();
    Set<Id> managedAccountIdSet = new Set<Id>();
    Map<Id,Set<Id>> childAccountForParentMap = new Map<Id,Set<Id>>();
    Set<Id> accountIdForAccountTeamMember = new Set<Id>();
    List<Id> accTeamMemberToDelete = new List<Id>();
    
    
    for(AccountTeamMember accTeamMemberObj : (List<AccountTeamMember>)oldMap.Values()){
        accountIdSet.add(accTeamMemberObj.AccountId);
    }
    
    managedAccountIdSet = TPM_AccountTeamTriggerHelperNext.fetchingManagedAccounts(accountIdSet);
    
    //fetching all the related Account details for the managedAccount

    TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper = TPM_AccountTeamHelper.createChildParentMapForManagedAccount(managedAccountIdSet);
    
    //creating a map of parent and child accounts, where parent is super-group and groups:

    for(Account childAccObj : [	SELECT
                                ID,
                                PARENTID,
                                TPM_Hierarchy_Level__c
                                FROM Account
                                WHERE PARENTID IN:relatedaccountWrapper.parentSet ORDER BY CREATEDDATE desc]){
        if(!childAccountForParentMap.containskey(childAccObj.PARENTID)){
                childAccountForParentMap.put(childAccObj.PARENTID, new Set<Id>());
            }
            
            childAccountForParentMap.get(childAccObj.PARENTID).add(childAccObj.ID);
            relatedaccountWrapper.allRelatedSet.add(childAccObj.ID);
                                    
    }
    
    accountIdForAccountTeamMember.addAll(relatedaccountWrapper.allRelatedSet);

    //TODO add explanation for this line
    accountIdForAccountTeamMember.addAll(relatedaccountWrapper.parentSet);
    
    //this is used for fetching the account team member id needed to be deleted through the automation:

    Map<String,Id> accountToAccountMemberMap = TPM_AccountTeamTriggerHelperNext.createAccountTeamMemberMap(accountIdForAccountTeamMember);
    
        for(AccountTeamMember accTeamMemberObj : (List<AccountTeamMember>)oldMap.Values()){ 

        //checking whether this managed account is present in the managed account and child(sold to) map

        if(relatedaccountWrapper.managedAccountAndChildMap.containskey(accTeamMemberObj.accountId)){

            //preparing list of all account team members for sold-to accounts to delete(child of managed account - accTeamMemberObj.accountid)
            
            accTeamMemberToDelete.addAll(TPM_AccountTeamTriggerHelperNext.prepareSetForDeleteSoldTo(relatedaccountWrapper.managedAccountAndChildMap,
            accTeamMemberObj.AccountId,
            accTeamMemberObj.UserId,
            accountToAccountMemberMap));  
        }

        //checking whether this managed account is present in the managed account and parent(super group,group) map
        
        if(relatedaccountWrapper.managedAccountAndParentMap.containskey(accTeamMemberObj.AccountId)){
            
            //preparing list of all account team members for parent accounts(groups, super groups) to delete of managed account(accTeamMemberObj.accountid)
            
            accTeamMemberToDelete.addAll(TPM_AccountTeamTriggerHelperNext.prepareSetForDeleteParent(relatedaccountWrapper.managedAccountAndParentMap,
                                                                accTeamMemberObj.AccountId,accTeamMemberObj.UserId,
                                                                accountToAccountMemberMap,childAccountForParentMap));
            
        }
        }

    //if the prepared delete list is not empty, then deleting the records.
    //logging error/exceptions, if any, in logger object

    if(!accTeamMemberToDelete.isEmpty()){
        deleteAndHandlerErrorLogging(accTeamMemberToDelete);
    }
    
}

/*********************************************************************************************************
@methodname   	deleteAndHandlerErrorLogging
@createdDate  	01/19/2023
@param     	  	deleteIdSet
@description  	delete the lis of id, and logging the error in looger object 
*********************************************************************************************************/

public static void deleteAndHandlerErrorLogging(List<Id> deleteIdSet){
    List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
    Database.DeleteResult[] deleteResultList = database.delete(deleteIdSet,false);
        for (Database.DeleteResult deleteResultObj : deleteResultList) {
            if(!deleteResultObj.isSuccess()){
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.errors = deleteResultObj.getErrors();
                logWrapperObj.className=TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
                logWrapperObj.methodName=TPM_ConstantsUtility.REMOVE_TEAM_MEMBER;
                logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                exceptionWrapperList.add(logWrapperObj);
            }else{
                //boolean value used to avoid recursion for the remove team member functionality

                TPM_Utils.isBypassRemoveAccountTeamMember=true;
            }
        }

        //Call the TPM_LoggerException class log method to save all the exception details during insert
        
        TPM_LoggerException.log(exceptionWrapperList);
}

    
/*********************************************************************************************************
@methodname   	teamMemberRecordSharingHandler
@createdDate  	02/28/2023
@param     	  	newMap
@description  	after insert of a account team member for a managed account, 
                share account related Promotion/SVF records with team members across account hierarchy. 
*********************************************************************************************************/

public static void teamMemberRecordSharingHandler(Map<Id,Sobject> newMap){
    List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id, Id> promotionIdByAccountIdMap  = new Map<Id, Id>();
    Map<Id, Id> svfIdByAccountIdMap  = new Map<Id, Id>();
    
    try{
        //iterating newMap of the newly created account team member records to fetch the accounts:
        for(AccountTeamMember accTeamMemberObj : (List<AccountTeamMember>)newMap.Values()){
            accountIdSet.add(accTeamMemberObj.AccountId);
        }
    
        if(!accountIdSet.isEmpty()){
            promotionIdByAccountIdMap = TPM_AccountTeamTriggerHelperNext.fetchingRelatedPromotions(accountIdSet);
            svfIdByAccountIdMap = TPM_AccountTeamTriggerHelperNext.fetchingRelatedSVF(accountIdSet);
        }
        
        if(!promotionIdByAccountIdMap.isEmpty()){
            TPM_RecordSharingUtils.handleChildSharingForAccountsTeamMembers(promotionIdByAccountIdMap, TPM_ConstantsUtility.PROMOTION_SHARE, exceptionWrapperList,  TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER);
        }

        if(!svfIdByAccountIdMap.isEmpty()){
            TPM_RecordSharingUtils.handleChildSharingForAccountsTeamMembers(svfIdByAccountIdMap, TPM_ConstantsUtility.ACCOUNTPLAN_SHARE, exceptionWrapperList,  TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER);
        }      
        
        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    catch(Exception exp){
        TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
        logWrapperObj.exceptionObj = exp;
        logWrapperObj.className = TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
        logWrapperObj.methodName = TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
        logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
        exceptionWrapperList.add(logWrapperObj);
        //Call the TPM_LoggerException class log method to save all the exception details during insert
        TPM_LoggerException.log(exceptionWrapperList);
    }
}

/*********************************************************************************************************
@methodname   	deleteRecordAccessForTeamMembers
@param     	  	oldMap
@description  	after the deletion of a account team member for a managed account, we need to remove sObject shared access 
                from the entire account hierarchy. 
*********************************************************************************************************/

public static void deleteRecordAccessForTeamMembers(Map<Id,Sobject> oldMap){
    List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id, Id> promotionIdByAccountIdMap  = new Map<Id, Id>();
    Map<Id, Id> svfIdByAccountIdMap  = new Map<Id, Id>();
    
    try{
        //iterating newMap of the newly created account team member records to fetch the accounts:
        for(AccountTeamMember accTeamMemberObj : (List<AccountTeamMember>)oldMap.Values()){
            accountIdSet.add(accTeamMemberObj.AccountId);
        }

        if(!accountIdSet.isEmpty()){
            promotionIdByAccountIdMap = TPM_AccountTeamTriggerHelperNext.fetchingRelatedPromotions(accountIdSet);
            svfIdByAccountIdMap = TPM_AccountTeamTriggerHelperNext.fetchingRelatedSVF(accountIdSet);
        }
        
        if(!promotionIdByAccountIdMap.isEmpty()){
            TPM_RecordSharingUtils.handleDeleteSObjectSharing(TPM_ConstantsUtility.PROMOTION_SHARE, promotionIdByAccountIdMap.keySet(), exceptionWrapperList, TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER);
        }

        if(!svfIdByAccountIdMap.isEmpty()){
            TPM_RecordSharingUtils.handleDeleteSObjectSharing(TPM_ConstantsUtility.ACCOUNTPLAN_SHARE, svfIdByAccountIdMap.keySet(), exceptionWrapperList, TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER);
        }        

        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    catch(Exception exp){
        TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
        logWrapperObj.exceptionObj = exp;
        logWrapperObj.className = TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
        logWrapperObj.methodName = TPM_ConstantsUtility.ACCOUNTTEAM_TRIGGER_HELPER;
        logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
        exceptionWrapperList.add(logWrapperObj);
        //Call the TPM_LoggerException class log method to save all the exception details during insert
        TPM_LoggerException.log(exceptionWrapperList);
    }
    
}

}