/*******************************************************************************************************
* @Name          TPM_UserPermissionSetGroupAutomation
* @Test Class    TPM_UserPermissionSetGroupAutomationTest
* @Author        PwC Team
* @date          May 5,2023
* @description   Batch Apex Handler is used for user record automation.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_UserPermissionSetGroupAutomation {
    
    /*************************************************************************************************** 
    @methodname 	 handleUserPermissionSetGroup
    @createdDate 	 May 6,2023
    @param           userList
    @param           exceptionWrapperList
    @description	 Handles Whether the PermissionSetGroup needs to be assigned new or existing 
					 PermissionSetGroup needs to be removed or not. 
    *****************************************************************************************************/
    public static void handleUserPermissionSetGroup(List<User> userList, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList){
        
        Set<Id> currentBatchUserIdSet = new Set<Id>();
        Map<Id,List<String>> userIdToPermissionSetGrpNameMap = new Map<Id,List<String>>();
                
		// Create a Set of User Records Ids for  
		// the current Chunk of user records
        for(User userObj : userList){
            currentBatchUserIdSet.add(userObj.Id);
        }
        
        // For the Current Chunck of User Records
        // Check Whether User Record has Permission Set Group assigned or not
        List<PermissionSetAssignment> userAssignedPermissionSetGrpList = [SELECT Id, 
                                                                          		 PermissionSetId,
                                                                          		 PermissionSet.Name, 
                                                                          		 PermissionSetGroupId,
                                                                          		 PermissionSetGroup.DeveloperName, 
                                                                          		 AssigneeId, 
                                                                          		 IsActive 
                                                                          FROM   PermissionSetAssignment 
                                                                          WHERE  AssigneeId IN: currentBatchUserIdSet 
                                                                          AND 	 PermissionSetGroupId != NULL];
        
        // For the User Records with Permission Set Group Assigned
        // Create a Map with
        // Key as User Record Id
        // Value as List of Permission Set Group assigned to the User Record
        for(PermissionSetAssignment permSetAsgnObj : userAssignedPermissionSetGrpList){
            if(!userIdToPermissionSetGrpNameMap.containsKey(permSetAsgnObj.AssigneeId)){
                userIdToPermissionSetGrpNameMap.put(permSetAsgnObj.AssigneeId, new List<String>{permSetAsgnObj.PermissionSetGroup.DeveloperName});
            }else{
                userIdToPermissionSetGrpNameMap.get(permSetAsgnObj.AssigneeId).add(permSetAsgnObj.PermissionSetGroup.DeveloperName);
            }
        }
        
    	checkAssignOrRemovePermissionSetGroup(userList, userIdToPermissionSetGrpNameMap, exceptionWrapperList);
    }
    
    /********************************************************************************************* 
    @methodname 	checkCreateOrRemovePermissionSetGroup
    @createdDate 	May 6,2023
	@param          userList
    @param          userIdToPermissionSetGrpNameMap
    @param          exceptionWrapperList
    @description	Method to Check Whether to Remove the assigned Permission Set Group or 
					Assign a new Permission Set Group to the User
    ************************************************************************************************/ 
    public static void checkAssignOrRemovePermissionSetGroup(List<User> userList, Map<Id,List<String>> userIdToPermissionSetGrpNameMap, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList){
        
        Set<Id> userIdsToRemoveSet = new Set<Id>();
        Set<Id> permissionSetGrpToRemoveSet = new Set<Id>();
        List<Id> createUserPermissionSetGroupList = new List<Id>();
        Map<String,String> personaNameToPermSetGroupNameMap = TPM_Utils_Extension.getPersonaToPermissionSetGroupCMDT();
        Map<String,Id> permissionGroupIdMap = TPM_Utils_Extension.createPermissionSetGroupNameToIdMap();
        Integer countNoOfPermissionSetGrpToBeRemoved;
        
        // Iterate over the List of
    	// User Records
        for(User userObj : userList){
            // Check if Current User Record 
            // has Permission Set Group Assigned or not
            if(userIdToPermissionSetGrpNameMap.containsKey(userObj.Id)){
                // If Permission Set Group Assigned then 
                // Get All the List of Permission Set Group Assigned
                countNoOfPermissionSetGrpToBeRemoved = 0;
                for(String permissionSetGrpName : userIdToPermissionSetGrpNameMap.get(userObj.Id)){
                    // Check If Persona's Permission Set Group is assigned or not
                    if( permissionSetGrpName != personaNameToPermSetGroupNameMap.get(userObj.TPM_Persona__c)){
                        // If Extra Permission Set Group Records are assigned 
                        // other than Persona related Permission Set Group
                        // Remove those Permission Set Groups
                        userIdsToRemoveSet.add(userObj.Id);
                        permissionSetGrpToRemoveSet.add(permissionGroupIdMap.get(permissionSetGrpName));
                        countNoOfPermissionSetGrpToBeRemoved +=1;
                    }
                }
                // If All the Extra Assigned Permission Set Groups are removed 
                // Then According to Persona Permission Set Group has to assigned
                if(countNoOfPermissionSetGrpToBeRemoved == (userIdToPermissionSetGrpNameMap.get(userObj.Id).size())){
                    createUserPermissionSetGroupList.add(userObj.Id);
                }
            }
            // If no Permission Set Groups are assigned then
            // Assign the Correct Permission Set Group according to Persona
            else{
                createUserPermissionSetGroupList.add(userObj.Id);
            }
        }
        
        removeAssignmentsForUser(userIdsToRemoveSet,permissionSetGrpToRemoveSet,exceptionWrapperList);
        assignUserToGroup(createUserPermissionSetGroupList,exceptionWrapperList);
    }
    
    /********************************************************************************************* 
    @methodname 	removeAssignmentsForUser
    @createdDate 	May 6,2023
    @param          userIdSet
    @param          groupIdSet
    @param          exceptionWrapperList
    @description	Removing the permission assignments for user. 
    ************************************************************************************************/  
    public static void removeAssignmentsForUser(Set<Id> userIdSet,Set<Id> groupIdSet, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList){
        
            List<Id> assignmentListToDel  = new List<Id>();

            //Iterate over the list of user records to remove assignment
            for(PermissionSetAssignment assignmentObj : [SELECT 
                                                        Id,
                                                        PermissionSetId
                                                        FROM PermissionSetAssignment 
                                                        WHERE Assignee.Id IN : userIdSet 
                                                        AND PermissionSetGroupId IN : groupIdSet]){
                assignmentListToDel.add(assignmentObj.Id);                                    
            }

            //Check if user record list is not empty 
            if(!assignmentListToDel.isempty()){

                exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleDeleteOperation(assignmentListToDel));
            }    
    }
    
    /*************************************************************************************************** 
    @methodname 	 assignUserToGroup
    @createdDate 	 May 6,2023
    @param           userIdList
    @param           exceptionWrapperList
    @description	 after the insert of a user record, if the user is active, user is assigned 
                     to the permission set group on the basis of its persona. 
    *****************************************************************************************************/
    public static void assignUserToGroup(List<Id> userIdList, List<TPM_LoggerException.LogsWrapper> exceptionWrapperList){
        
            Map<String,List<String>> personaToGroupMap = TPM_Utils.fetchPersonaToGroupMap();
            List<PermissionSetAssignment> assignmentList = new List<PermissionSetAssignment>();

            //Iterate over all the active user records
            for(User userobj :  [SELECT id,
                                TPM_Persona__c,
                                IsActive 
                                FROM user
                                WHERE id IN : userIdList]){
                                    
                                    //Check the persona to assign corresponding permission set
                                    if(personaToGroupMap.containsKey(userobj.TPM_Persona__c)){
                                        for(String groupId : personaToGroupMap.get(userobj.TPM_Persona__c)) {
                                            PermissionSetAssignment assignmentObj = new PermissionSetAssignment(
                                                PermissionSetGroupId = groupId,
                                                AssigneeId = userobj.Id);
                                                assignmentList.add(assignmentObj);  
                                        }
                                    }
                            }

            //Check if the list is not empty before creating                   
            if(!assignmentList.isempty()){
                
                exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleInsertOperation(assignmentList));
    
            }
    }
}