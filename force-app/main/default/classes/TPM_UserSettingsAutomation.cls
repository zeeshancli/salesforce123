/*******************************************************************************************************
* @Name          TPM_UserSettingsAutomation
* @Test Class    TPM_UserSettingsAutomationTest
* @Author        PwC Team
* @date          May 5,2023
* @description   Batch Apex Handler is used for user record automation.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_UserSettingsAutomation {
    /*************************************************************************************************** 
    @methodname 	 handleUserSettingsRecordsCreation
    @createdDate 	 May 6,2023
    @param           userList
    @description	 Method to check whether User Settings Records needs to be created or not for the
					 User Records.
    *****************************************************************************************************/
    public static void handleUserSettingsRecordsCreation(List<User> userList){
        
        Map<Id,SObject> currentBatchUserIdsMap = new Map<Id,SObject>();
        
        // Create a Map of
        // User record Id and User Record
        for(User userObj : userList){
            currentBatchUserIdsMap.put(userObj.Id, userObj);
        }

        // Get the list of all existing User Settings Records
        List<cgcloud__User_Setting__c> userSettingsRecordToCreateList = [SELECT  Id,
                                                                                 Name,
                                                                                 cgcloud__User__c,
                                                                                 cgcloud__KPI_Subsets__c
                                                                         FROM    cgcloud__User_Setting__c
                                                                         WHERE   cgcloud__KPI_Subsets__c != NULL];
        
        // Iterate over the list of found User Settings Records
        for(cgcloud__User_Setting__c userSettingsObj : userSettingsRecordToCreateList){
            // If User Id matches with the remove the record
            // i.e User Settings Record already exist no need to create again
            if(currentBatchUserIdsMap.containsKey(userSettingsObj.cgcloud__User__c)){
                currentBatchUserIdsMap.remove(userSettingsObj.cgcloud__User__c);
            }
        }
        
        // If currentBatchUserIdsMap not Empty
        // Invoke createUserSetting Method to create
        // User Settings Records
        if(!currentBatchUserIdsMap.isEmpty()){
            TPM_UserTriggerHelper.createUserSetting(currentBatchUserIdsMap);
        } 
    }
}