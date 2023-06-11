/******************************************************************************************************
* @Name         : TPM_RecordSharingUtils
* @Test Class   : 
* @author       : PwC Team
* @date         : February 27, 2023
* @description  : Record Sharing Utility class providing reusable methods for grant/fetch/revoke sObject
                  sharing
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_RecordSharingUtils {

    /****************************************************************************************************
    @methodname 	TPM_RecordSharingUtils
    @createdDate 	February 27, 2023
    @description	default private constructor
    *****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public TPM_RecordSharingUtils() {

    }

    /********************************************************************************************************** 
    @methodname 	 fetchExistingSObjectSharedRecords
    @return          Map<Id, Set<Id>>
    @param           objectTypeName
    @param           parentIdsSet
    @description	 method handles the logic to query all existing sObject shared records and return record id 
                     and shared user set
    ***********************************************************************************************************/ 
    public static Map<Id, Set<Id>> fetchExistingSObjectSharedRecords(String objectTypeName, Set<Id> parentIdsSet) {

        Map<Id, Set<Id>> sharedParentIdAndUserORGroupIdMap = new Map<Id, Set<Id>>();
        String queryString = '';

        if(String.isNotBlank(objectTypeName)){
            Map<String, TPM_QueryDefinition__mdt> sharingRecordQueryDefinition = TPM_Utils.getDynamicQueryRecords(new List<String>{TPM_ConstantsUtility.EXISTING_SOBJECTS_SHARED_RECORDS});
        
            // preparing query for share record data using objectTypeName  
            queryString = sharingRecordQueryDefinition.get(TPM_ConstantsUtility.EXISTING_SOBJECTS_SHARED_RECORDS).TPM_BaseQuery__c;
            
            queryString += ' '+ String.escapeSingleQuotes(objectTypeName);

            if(!parentIdsSet.isEmpty()){
                queryString += ' WHERE ParentId IN :parentIdsSet';
            }
            
        }      
        
        for (SObject objSObject : Database.query(queryString)){  
            
            // preparing map of ParentId and Set of UserOrGroupId to return else map of Id and UserOrGroupId
            if(!sharedParentIdAndUserORGroupIdMap.containsKey((Id)objSObject.get(TPM_ConstantsUtility.PARENTID_FIELD))){
                sharedParentIdAndUserORGroupIdMap.put((Id)objSObject.get(TPM_ConstantsUtility.PARENTID_FIELD), new Set<Id>());
            }
            sharedParentIdAndUserORGroupIdMap.get((Id)objSObject.get(TPM_ConstantsUtility.PARENTID_FIELD)).add((Id)objSObject.get('UserOrGroupId'));
        }

        return sharedParentIdAndUserORGroupIdMap;
   }

   /***********************************************************************************************
    @method          shareSObjectRecords
    @return          List<SObject>
    @param           shareObjectName
    @param           parentIdandUserOrGroupIdMap
    @param           accessLevel
    @description     method prepares sObject share record and return list of sobject share records
    ***********************************************************************************************/
    public static List<SObject> shareSObjectRecords(String shareObjectName, Map<Id, Set<Id>> parentIdandUserOrGroupIdMap, String accessLevel){
        
        List<SObject> recordsToShareList = new List<SObject>();

        // dynamically fetching SObjectType using sObjectName
        Schema.SObjectType objShareType = Schema.getGlobalDescribe().get(shareObjectName); 

        if(objShareType != null){

            // iterating over map of parentId as key and set of UserOrGroupIds to share records
            for(Id parentId : parentIdandUserOrGroupIdMap.keySet()){
                for(Id userId : parentIdandUserOrGroupIdMap.get(parentId)){

                    // instantiating share object type
                    SObject newShareObj = objShareType.newSObject();
                    newShareObj.put('ParentId', parentId);
                    newShareObj.put('UserOrgroupId', userId);
                    newShareObj.put('AccessLevel',accessLevel);   
                    recordsToShareList.add(newShareObj);                                                                         
                }
            }
        }

        return recordsToShareList;
    }

    /***********************************************************************************************
    @method          fetchAccountTeamMembers
    @return          Map<Id, Set<Id>>
    @param           accountIdSet
    @description     method prepares sObject share record and return list of sobject share records
    ***********************************************************************************************/
    public static Map<Id, Set<Id>> fetchAccountTeamMembers(Set<Id> accountIdSet){
        
        Map<Id, Set<Id>> accountIdAndUsersIdSetMap = new Map<Id, Set<Id>>();

        // query team members for the set of account ids provided
        for(AccountTeamMember ateamMem : [SELECT Id, AccountId, UserId 
                                          FROM AccountTeamMember
                                          WHERE AccountId IN :accountIdSet]) {
                                                   
            // preparing map of AccountId and Set of UserId to return 
            if(!accountIdAndUsersIdSetMap.containsKey(ateamMem.AccountId)){
                accountIdAndUsersIdSetMap.put(ateamMem.AccountId, new Set<Id>());
            }  
            accountIdAndUsersIdSetMap.get(ateamMem.AccountId).add(ateamMem.UserId);                                                             
        }
        return accountIdAndUsersIdSetMap;
    }

    /***********************************************************************************************
    @method          checksExistingSharingAndPrepareNew
    @return          Map<Id, Set<Id>>
    @param           newRecordToShareIdandRelatedAcntIdMap
    @param           shareObjectName
    @description     method validate if sharing exists for record to share with team members
                     and prepares sObject share record for AccountTeamMembers Sharing
    ***********************************************************************************************/
    public static Map<Id, Set<Id>> checksExistingSharingAndPrepareNew(Map<Id, Id> newRecordToShareIdandRelatedAcntIdMap, String shareObjectName){
        
        // get account team members map for new set of records using related accountIds
        Map<Id, Set<Id>> accountIdAndSetOfTeamMemberUserIdMap = fetchAccountTeamMembers(new Set<Id>(newRecordToShareIdandRelatedAcntIdMap.values())); 
        
        // get existing sharing for records using set of record ids as parentId
        Map<Id, Set<Id>> existingSharedRecordIdandSetOfUserIdMap = fetchExistingSObjectSharedRecords(shareObjectName, newRecordToShareIdandRelatedAcntIdMap.keySet());
        
        Map<Id, Set<Id>> parentIdandUserOrGroupIdSetForNewSharingMap = new Map<Id, Set<Id>>();         		
               
        // iterating over new set of record ids to share
        for(Id childId : newRecordToShareIdandRelatedAcntIdMap.keySet()){

            // skip the record of parent account does not have any team member 
            if(!accountIdAndSetOfTeamMemberUserIdMap.containsKey(newRecordToShareIdandRelatedAcntIdMap.get(childId))){ 
                continue;
            }

            // iterating over parent account's team members
            for(Id userToshareId : accountIdAndSetOfTeamMemberUserIdMap.get(newRecordToShareIdandRelatedAcntIdMap.get(childId))){
                
                // checking if sharing record already exists using new child record id
                if(!existingSharedRecordIdandSetOfUserIdMap.containsKey(childId) || !existingSharedRecordIdandSetOfUserIdMap.get(childId).contains(userToshareId)){
                    
                    // preparing map of new child record id to share with set of users
                    if(!parentIdandUserOrGroupIdSetForNewSharingMap.containsKey(childId)){
                    	parentIdandUserOrGroupIdSetForNewSharingMap.put(childId, new Set<Id>());
                    }
                    parentIdandUserOrGroupIdSetForNewSharingMap.get(childId).add(userToshareId);
                }
            }
        }

        // returns deltas
        return parentIdandUserOrGroupIdSetForNewSharingMap;
    }

    /********************************************************************************************************** 
    @methodname 	 createSObjectSharingWithAccountTeamMembers
    @param           shareRecordsList
    @param           exceptionWrapperList
    @param           flowName
    @description	 method handles the process to share all new records related to customer with account team members 
    ***********************************************************************************************************/ 
    public static void createSObjectSharingWithAccountTeamMembers(List<sObject> shareRecordsList, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList, String flowName){

        // database operation for partial insert
        Database.SaveResult[] shareResults = Database.insert(shareRecordsList, false);
        Integer index = 0;
        
        for(Database.SaveResult sResults : shareResults){
            if(!sResults.isSuccess()){

                // preparing logger records to record failures
                TPM_LoggerException.LogsWrapper logObj = new TPM_LoggerException.LogsWrapper();
                logObj.flow = flowName;
                logObj.logLevel = TPM_ConstantsUtility.ERROR;
                logObj.guid = (String)shareRecordsList[index].get(TPM_ConstantsUtility.PARENTID_FIELD);
                logObj.errors = sResults.getErrors();
                exceptionWrapperList.add(logObj);
            }
            index++;
        }

    }

    /********************************************************************************************************** 
	@methodname 	 handleChildSharingForAccountsTeamMembers
	@param           newChildIdandAcntIdMap
    @param           shareObjectName
    @param           exceptionWrapperList
    @param           flowClassName
	@description	 method handles the process validate and prepare sharing for sObject bject records with related account team members 
	***********************************************************************************************************/  
    public static void handleChildSharingForAccountsTeamMembers(Map<Id, Id> newChildIdandAcntIdMap, String shareObjectName, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList, String flowClassName){ 

        // new list of SObject share type for dml
        List<SObject> sObjectRecordsToShareList = new List<SObject>();
                
        // store record id to share as key and set of user/groupid for new sharing
        Map<Id, Set<Id>> parentIdandUserOrGroupIdSetForNewSharingMap = checksExistingSharingAndPrepareNew(newChildIdandAcntIdMap, shareObjectName);
                
        if(!parentIdandUserOrGroupIdSetForNewSharingMap.isEmpty()){
            sObjectRecordsToShareList =  (List<SObject>)shareSObjectRecords(shareObjectName, parentIdandUserOrGroupIdSetForNewSharingMap, TPM_ConstantsUtility.ACCESSLEVEL_EDIT);
        }
                
        // call dml handler
        if(!sObjectRecordsToShareList.isEmpty()){

            handlerForSharingDMLOperations(sObjectRecordsToShareList, exceptionWrapperList, flowClassName);
        }
    }

    /********************************************************************************************************** 
	@methodname 	 handlerForSharingDMLOperations
	@param           sObjectRecordsToShareList
    @param           exceptionWrapperList
    @param           flowClassName
	@description	 method handles the databse dml operations
	***********************************************************************************************************/  
    public static void handlerForSharingDMLOperations(List<SObject> sObjectRecordsToShareList, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList , String flowClassName){            
        
        if(!sObjectRecordsToShareList.isEmpty()) {
            createSObjectSharingWithAccountTeamMembers(sObjectRecordsToShareList, exceptionWrapperList, flowClassName);
        }
        // Call the TPM_LoggerException class log method to save all the exception details during insert
        if(!exceptionWrapperList.isEmpty()){

            TPM_LoggerException.log(exceptionWrapperList);
        }
    }

    /********************************************************************************************************** 
	@methodname 	 handleDeleteSObjectSharing
	@param           shareObjectName
    @param           parentIdSet
    @param           exceptionWrapperList
    @param           flowClassName
	@description	 method handles the databse dml operations after the deletion of a account team member 
                     to delete shared child record access
	***********************************************************************************************************/  
    public static void handleDeleteSObjectSharing(String shareObjectName, Set<Id> parentIdSet, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList, String flowClassName){            

        // Call the TPM_LoggerException class log method to save all the exception details during insert
        if(!parentIdSet.isEmpty()){
            // dynamically fetching all shring records related to team members for sObjectName provided
			String sharingDeletionQueryStr = 'SELECT Id FROM '+ String.escapeSingleQuotes( shareObjectName ) + ' '; 
            sharingDeletionQueryStr += 'WHERE ParentId IN :parentIdSet AND RowCause = \''+TPM_ConstantsUtility.ROWCAUSE_MANUAL+'\'';
            
            List<SObject> sObjRecordsToDeleteList = Database.query(sharingDeletionQueryStr);
            
            // method handles delete operation
            deleteSharingHelper(sObjRecordsToDeleteList, exceptionWrapperList, flowClassName);
        }
    }

    /********************************************************************************************************** 
	@methodname 	 deleteSharingHelper
	@param           recordsToDeleteList
    @param           exceptionWrapperList
    @param           flowClassName
	@description	 method handles the delete dml operations after the deletion of a account team member 
                     to delete shared child record access
	***********************************************************************************************************/  
    public static void deleteSharingHelper(List<SObject> recordsToDeleteList, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList, String flowClassName){            

        // database operation for partial delete
        Database.DeleteResult[] deleteResults = Database.delete(recordsToDeleteList, false);
        Integer index = 0;
        
        for(Database.DeleteResult dResults : deleteResults){
            
            if(!dResults.isSuccess()){
                
                // preparing logger records to record failures
                TPM_LoggerException.LogsWrapper logObj = new TPM_LoggerException.LogsWrapper();
                logObj.flow = flowClassName;
                logObj.logLevel = TPM_ConstantsUtility.ERROR;
                logObj.guid = (String)recordsToDeleteList[index].Id;
                logObj.errors = dResults.getErrors();
                exceptionWrapperList.add(logObj);
            }
            index++;
        }
    }

}