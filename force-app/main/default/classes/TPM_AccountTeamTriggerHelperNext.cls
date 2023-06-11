/*******************************************************************************************************
* @Name         : TPM_AccountTeamTriggerHelperNext
* @Unit Test    : TPM_AccountTeamTriggerTest
* @Author       : PwC Team
* @Date         : 01/24/2023
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the account team records.(also to reduce the cyclomatic complexity for TPM_AccountTeamTriggerHelper class )
*******************************************************************************************************/

public inherited sharing  class TPM_AccountTeamTriggerHelperNext {

/***************************************************************************************************
@methodname 	TPM_AccountTeamTriggerHelperNext
@createdDate 	01/24/2023
@description	default private constructor
****************************************************************************************************/

@SuppressWarnings('PMD.EmptyStatementBlock')
private TPM_AccountTeamTriggerHelperNext(){

}


/*********************************************************************************************************
@methodname   	prepareAccountTeamMemberRecords
@createdDate  	01/23/2023
@param     	  	accTeamMemberObj
@param     	  	relatedAccountMap
* @return         : List<AccountTeamMember>
@description  	account team member records preparation for assignment to hierarchy
*********************************************************************************************************/

public static List<AccountTeamMember> prepareAccountTeamMemberRecords(AccountTeamMember accTeamMemberObj,Map<Id,Set<Id>> relatedAccountMap){

    List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
    for(Id relatedAccountId : relatedAccountMap.get(accTeamMemberObj.AccountId)){
                AccountTeamMember newAccountTeamMember =  new AccountTeamMember(AccountId = relatedAccountId,
                                                                                UserId = accTeamMemberObj.UserId,
                                                                                TeamMemberRole = TPM_ConstantsUtility.MANAGED_ACCOUNT_MEMBER,
                                                                                AccountAccessLevel = accTeamMemberObj.AccountAccessLevel,
                                                                                CaseAccessLevel = accTeamMemberObj.CaseAccessLevel,
                                                                                OpportunityAccessLevel = accTeamMemberObj.OpportunityAccessLevel);
                accTeamMemberList.add(newAccountTeamMember);
            }
    return accTeamMemberList;
}


/*********************************************************************************************************
@methodname   	createAccountTeamMemberMap
@createdDate  	01/23/2023
@param     	  	allAccountIdSet
* @return         : List<Id>
@description  	creating a map of all unique account team member for every account id and user id, with the accountteam member id as value
*********************************************************************************************************/

public static Map<String,Id> createAccountTeamMemberMap(Set<Id> allAccountIdSet){
    Map<String,Id> accountTeamMemberMap = new Map<String,Id>();
    for(AccountTeamMember accountTeamMemberObj : [SELECT 
                                                    Id,
                                                    AccountId,
                                                    Account.TPM_Hierarchy_Level__c,
                                                    UserId
                                                    FROM AccountTeamMember
                                                    WHERE AccountId IN:allAccountIdSet]){
                accountTeamMemberMap.put(string.valueof(accountTeamMemberObj.AccountId)+string.valueof(accountTeamMemberObj.UserId),accountTeamMemberObj.Id);
                                                    
    }
    
    return accountTeamMemberMap;
    } 


/*********************************************************************************************************
@methodname   	fetchingManagedAccounts
@createdDate  	01/23/2023
@param     	  	allAccountIdSet
* @return         : Set<Id>
@description  	fetching all the managed account from the accounts which trigger the event.
*********************************************************************************************************/

public static Set<Id> fetchingManagedAccounts(Set<Id> allAccountIdSet){

    Set<Id> managedAccountSet  = new Set<Id>();

    //querying the accounts for which the account team members was added, and taking out the accounts which has hierarchy level as managed account.
    for(Account accountObj : [SELECT
                                Id,
                                TPM_Hierarchy_Level__c
                                FROM Account
                                WHERE ID IN :allAccountIdSet
                                AND TPM_Hierarchy_Level__c =: TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT]){
            managedAccountSet.add(accountObj.Id);                  
    }
    return managedAccountSet;
}


/*********************************************************************************************************
* @methodname   	prepareSetForDeleteSoldTo
* @createdDate  	01/23/2023
* @param            managedAccountForSoldToMap
* @param            accountId
* @param            userId
* @param            accountMemberMap
* @return         : List<Id>
* @description  	creating a map of all unique account team member for every account id and user id, with the accountteam member id as value
*********************************************************************************************************/


public static List<Id> prepareSetForDeleteSoldTo(Map<Id,Set<Id>> managedAccountForSoldToMap,Id accountId,Id userId,Map<String,id> accountMemberMap){
    List<Id> soldToIdsToDelete = new List<Id>();

    // iterating all the sold to for the deleted managed account:

    for(Id soldToId :managedAccountForSoldToMap.get(accountId)){

                //fetching all the account team member id for the particular user(which is deleted from the managedaccount) and child soldto accounts
                
                if(accountMemberMap.containskey(string.valueof(soldToId)+string.valueof(userId))){
                    soldToIdsToDelete.add(accountMemberMap.get(string.valueof(soldToId)+string.valueof(userId)));  
                }
                
            }
    return soldToIdsToDelete;
}


/*********************************************************************************************************
@methodname   	prepareSetForDeleteParent
@createdDate  	01/23/2023
* @param        managedAccountForParentMap
* @param        accountId
* @param        userId
* @param        accountMemberMap
* @param        childToParentMap
* @return         : List<Id>
@description  	creating a map of all unique account team member for every account id and user id, with the accountteam member id as value
*********************************************************************************************************/

@SuppressWarnings('PMD.CyclomaticComplexity')
public static List<Id> prepareSetForDeleteParent(Map<Id,Set<Id>> managedAccountForParentMap,Id accountId,Id userId,Map<String,id> accountMemberMap,Map<Id,Set<Id>> childToParentMap){
    List<Id> parentIdsToDelete = new List<Id>();
    boolean breakForEntireHierarchy = false;
    for(Id parentId :managedAccountForParentMap.get(accountId)){ 

        //checking if this parent has multiple child accounts

                if(childToParentMap.containskey(parentId) && childToParentMap.get(parentId).size() > 1){

                    //if multiple child is there then checking whether the same user is present in any other child records
                    // if(childToParentMap.get(parentId).size() > 1){

                    for(Id childAccountId :childToParentMap.get(parentId)){

                            //if this managed account is not the same for which the deletion happened.
                                //because checking for the same managed account doesnt matter.

                                if(childAccountId != AccountId && accountMemberMap.containskey(string.valueof(childAccountId)+string.valueof(UserId))){
                                    
                                    //if this child account contains the user in account team member then break out of the loop
                                    //if(accountMemberMap.containskey(string.valueof(childAccountId)+string.valueof(UserId))){
                                        
                                        breakForEntireHierarchy= true;
                                        break;
                                    }

                                    //if this child account does not have any team member record for the deleted user then adding the parent account's 
                                    //account team member to delete.
                                    
                                    else if(childAccountId != AccountId && !accountMemberMap.containskey(string.valueof(childAccountId)+string.valueof(UserId))){
                                        parentIdsToDelete.add(accountMemberMap.get(string.valueof(parentId)+string.valueof(UserId)));
                                    }
                                //}
                            }
                        if(breakForEntireHierarchy){
                            break;
                        }
                        //}
                        //if multiple child records is not there then we need to delete the user from the account team member of parent
                        /*else{
                            parentIdsToDelete.add(accountMemberMap.get(string.valueof(parentId)+string.valueof(UserId)));
                        }*/
                    }
        else if(childToParentMap.containskey(parentId) && accountMemberMap.containskey(string.valueof(parentId)+string.valueof(UserId))){
            parentIdsToDelete.add(accountMemberMap.get(string.valueof(parentId)+string.valueof(UserId)));
            
        }
                }
    return parentIdsToDelete;
} 

/*********************************************************************************************************
@methodname   	fetchingRelatedPromotions
@createdDate  	02/28/2023
@param     	  	allAccountIdSet
@return         Map<Id, Id>
@description  	fetching all promotions related to managed accounts and for its account hierarchy.
*********************************************************************************************************/

public static Map<Id, Id> fetchingRelatedPromotions(Set<Id> allAccountIdSet){

    Map<Id, Id> promotionIdByAccountIdMap  = new Map<Id, Id>();

    //querying the Promotion for which the account team members was added, and for managed account hierarchy.
    for(cgcloud__Promotion__c promotionObj : [SELECT
                                                Id, cgcloud__Anchor_Account__c
                                                FROM cgcloud__Promotion__c
                                                WHERE cgcloud__Anchor_Account__c IN :allAccountIdSet]){

        promotionIdByAccountIdMap.put(promotionObj.Id, promotionObj.cgcloud__Anchor_Account__c);                  
    }
    return promotionIdByAccountIdMap;
}

/*********************************************************************************************************
@methodname   	fetchingRelatedSVF
@createdDate  	02/28/2023
@param     	  	allAccountIdSet
@return         Map<Id, Id>
@description  	fetching all SVF(SalesVolumeForecast) related to managed accounts and for its account hierarchy.
*********************************************************************************************************/

public static Map<Id, Id> fetchingRelatedSVF(Set<Id> allAccountIdSet){

    Map<Id, Id> svfIdByAccountIdMap  = new Map<Id, Id>();

    //querying the SVF for which the account team members was added, and for managed account hierarchy.
    for(cgcloud__Account_Plan__c svfObj : [SELECT
                                            Id, cgcloud__Account__c
                                            FROM cgcloud__Account_Plan__c
                                            WHERE cgcloud__Account__c IN :allAccountIdSet]){

        svfIdByAccountIdMap.put(svfObj.Id, svfObj.cgcloud__Account__c);                  
    }
    return svfIdByAccountIdMap;
}


}