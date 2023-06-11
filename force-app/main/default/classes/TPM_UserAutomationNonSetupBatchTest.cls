/*******************************************************************************************************
* @Name         : TPM_UserAutomationNonSetupBatchTest
* @Test Class   : TPM_UserAutomationNonSetupBatchTest
* @ author       : PwC Team
* @date         : May 8th,2023
* @description  : To test the Batch Class TPM_UserAutomationNonSetupBatch 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_UserAutomationNonSetupBatchTest {
    
   	public static final String ASSERT_STR = 'No Permission Set Group created';
    
    /******************************************************************************************
    * @method			createTestUserRecords
    * @ return     		:void
    * @param   		  
    * @description    	Test Method for creating Test Data
    ******************************************************************************************/
    @testSetup
    public static void createTestUserRecords(){
        // Create Test User Records
        String profileId = TPM_TestDataUtility.getProfileId('System Administrator');
        User userObj = TPM_TestDataUtility.createTestUser(profileId,'Test','User');
        insert userObj;
        
        //Create Sales Org Test Records
        cgcloud__Sales_Organization__c salesOrgToCreate = TPM_TestDataUtility.createCGCloudSalesOrg('US01');
        insert salesOrgToCreate;
        
        //Create Sales Org User Record
        cgcloud__Sales_Organization_User__c   salesOrgUsrOne = new  cgcloud__Sales_Organization_User__c(cgcloud__User__c = userObj.Id,
                                                                                                        cgcloud__Sales_Organization__c = salesOrgToCreate.Id);
        insert salesOrgUsrOne;
    }
    
    /****************************************************************************
    * @method         : executeTest
    * @description    : To test TPM_UserAutomationSetupObjectBatch execute 
    * 					Method
    ****************************************************************************/  
    @isTest
    public static void executeTest(){
        Test.startTest();
        
        //Call the batch execute method
        Database.executeBatch(new TPM_UserAutomationNonSetupBatch());
        
        Test.stopTest();
        
        User userobj = [SELECT 	Id,
                        		TPM_Persona__c,
                        		FirstName,
                        		IsActive 
                       	FROM    User 
                       	WHERE   FirstName='Test' 
                        LIMIT   1];
        
        //Query User Settings Records and Check If it got created or not
        List<cgcloud__User_Setting__c> userSettingsRecordList = [SELECT Id, 
                                                                 		Name, 
                                                                 		cgcloud__User__c 
                                                                 FROM 	cgcloud__User_Setting__c 
                                                                 WHERE  cgcloud__User__c =: userobj.Id];

        System.assertEquals(false, userSettingsRecordList.isEmpty(), ASSERT_STR);
    }

}