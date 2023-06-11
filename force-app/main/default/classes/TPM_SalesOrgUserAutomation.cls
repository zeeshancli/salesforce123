/*******************************************************************************************************
* @Name          TPM_SalesOrgUserAutomation
* @Test Class    TPM_SalesOrgUserAutomationTest
* @Author        PwC Team
* @date          May 5,2023
* @description   Batch Apex Handler is used for user record automation.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.avoiddeeplynestedifstmts')
public without sharing class TPM_SalesOrgUserAutomation {
    
    /*************************************************************************************************** 
    @methodname 	 handleSalesOrgUserRecordCreation
    @createdDate 	 May 6,2023
    @param           userList
    @description	 Method to check whether sales org user records needs to be created or not for the
					 User Records.
    *****************************************************************************************************/
    public static void handleSalesOrgUserRecordCreation(List<User> userList){
        
        Set<String> salesOrgSet = new Set<String>();
        Map<String,Set<Id>> salesOrgNameToUserMap = new Map<String,Set<Id>>();
        
        
        // Get the all available existing
        // Sales Org user records
        List<cgcloud__Sales_Organization_User__c> allSalesOrgUserRecordList = [SELECT Id,
                                                                              		  Name,
                                                                              		  cgcloud__Sales_Organization__c,
                                                                               	      cgcloud__Sales_Organization__r.Name,
                                                                               		  cgcloud__User__r.Name,
                                                                                      cgcloud__User__c
                                                                               FROM   cgcloud__Sales_Organization_User__c
                                                                               WHERE  cgcloud__Sales_Organization__c != NULL];
        
        // Get the list of all available Sales Org Records
        for(cgcloud__Sales_Organization__c salesOrg : [SELECT Id,
                                                       		  Name	
                                                       FROM   cgcloud__Sales_Organization__c
                                                       WHERE  Name != NULL]){
                                                           
                                                           // Add the Name of the sales org 
                                                           salesOrgSet.add(salesOrg.Name);
                                                       }
        
        // Returns Map with Sales Org Name and its recordId
        Map<String,Id> salesOrgMap = TPM_UserTriggerHelperExtension.createSalesOrgMap(salesOrgSet);
        
        // Iterate over the existing sales org user record list
        // And Create a Map with
        // Key as Sales Org Name
        // And Value List of User Ids
        for(cgcloud__Sales_Organization_User__c salesOrgUser : allSalesOrgUserRecordList){
            
            if(!salesOrgNameToUserMap.containsKey(salesOrgUser.cgcloud__Sales_Organization__r.Name)){
                salesOrgNameToUserMap.put(salesOrgUser.cgcloud__Sales_Organization__r.Name, new Set<Id>{salesOrgUser.cgcloud__User__c});
            }else{
                salesOrgNameToUserMap.get(salesOrgUser.cgcloud__Sales_Organization__r.Name).add(salesOrgUser.cgcloud__User__c);
            }
        }
        
        // Invoke createSalesOrgUserRecords Method to create Sales Org User Records
        createSalesOrgUserRecords(userList, salesOrgNameToUserMap, salesOrgMap);   
    }
    
    
    /*************************************************************************************************** 
    @methodname 	 createSalesOrgUserRecords
    @createdDate 	 May 6,2023
    @param           userList
    @param           salesOrgNameToUserMap
    @param           salesOrgMap
    @description	 Method to create sales org user records if in the existing sales org users records
					 not present.
    *****************************************************************************************************/
    public static void createSalesOrgUserRecords(List<User> userList, Map<String,Set<Id>> salesOrgNameToUserMap, Map<String,Id> salesOrgMap ){
        
        List<cgcloud__Sales_Organization_User__c> salesOrgUserListToCreate = new List<cgcloud__Sales_Organization_User__c>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        // Iterate over the List of
        // User Records
        for(User userObj : userList){
            if(userObj.TPM_Sales_Org__c != null){
                // Get the List of all available sales org field
                List<String> selectedSalesOrg = new List<String>();
                selectedSalesOrg.addAll(userObj.TPM_Sales_Org__c.split(';'));
                // Iterate over the available sales org records
                for(String salesOrgObj : selectedSalesOrg){
                    // Check if in the existing sales org user records Matches
                    if(salesOrgNameToUserMap.containsKey(salesOrgObj)){
                        	// If No existing Sales Org User Records found for 
                        	// the User and the corresponding sales org 
                            if(!salesOrgNameToUserMap.get(salesOrgObj).contains(userObj.Id)){
                                cgcloud__Sales_Organization_User__c salesOrgUserObj = new cgcloud__Sales_Organization_User__c(cgcloud__Sales_Organization__c = salesOrgMap.get(salesOrgObj),
                                                                                                                              cgcloud__User__c = userObj.Id);
                                salesOrgUserListToCreate.add(salesOrgUserObj);
                            }
                        }
                    }
                }
            }
        
        //Check if the list is not empty and create the sales org user record 
        if(!salesOrgUserListToCreate.isempty()){
            
            exceptionWrapperList.addAll(TPM_UserTriggerHelperExtension.handleInsertOperation(salesOrgUserListToCreate));
                
                //Call the TPM_LoggerException class log method to save all the exception details during insert
             if(!exceptionWrapperList.isEmpty()){
                    TPM_LoggerException.log(exceptionWrapperList);
             }
            
        }
    }

}