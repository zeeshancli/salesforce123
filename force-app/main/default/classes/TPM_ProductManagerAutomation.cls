/*******************************************************************************************************
* @Name          TPM_ProductManagerAutomation
* @Test Class    TPM_ProductManagerAutomationTest
* @Author        PwC Team
* @date          May 5,2023
* @description   Batch Apex Handler is used for user record automation.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_ProductManagerAutomation {
    
    /*************************************************************************************************** 
    @methodname 	 handleProductManagerRecords
    @createdDate 	 May 6,2023
    @param           userList
    @description	 Handles Whether the product manager records needs to be created new or updated for the
					 existing records.
    *****************************************************************************************************/
    public static void handleProductManagerRecords(List<User> userList){
        
        Set<Id> currentUserRecordsIdsSet = new Set<Id>();
        
        // Iterate over the user records
        // Make a Set of User Records Ids
        for(User userObj : userList){
            currentUserRecordsIdsSet.add(userObj.Id);
        }
        
        // Get the existing sales org user records
        // for all the users in the current batch of user records
        Map<Id, cgcloud__Sales_Organization_User__c> salesOrgUserRecordsMap = new Map<Id, cgcloud__Sales_Organization_User__c>(
                                                                                                                                [SELECT Id, 
                                                                                                                                 		Name, 
                                                                                                                                 		cgcloud__Sales_Organization__c, 
                                                                                                                                 		cgcloud__Sales_Organization__r.Name,
                                                                                                                                 		cgcloud__User__c, 
                                                                                                                                 		cgcloud__User__r.Name,
                                                                                                                                 		cgcloud__Default_Account__c 
                                                                                                                                 FROM 	cgcloud__Sales_Organization_User__c 
                                                                                                                                 WHERE  cgcloud__User__c IN:currentUserRecordsIdsSet]
        																														);
        // If Sales Org User Records found successfully
        if(!salesOrgUserRecordsMap.isEmpty()){
            // Then Call the Trigger Method to Process the Records
            // for creating or updating the Product Manager Records for the Top Node Products
            // of the corresponding sales orgs
            TPM_SalesOrgUserTriggerHelper.salesOrgUserTriggerBusinessHandler(salesOrgUserRecordsMap);
        }
        
    }

}