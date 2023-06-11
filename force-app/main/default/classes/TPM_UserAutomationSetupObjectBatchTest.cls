/*******************************************************************************************************
* @Name         : TPM_UserAutomationSetupObjectBatchTest
* @Test Class   : TPM_UserAutomationSetupObjectBatchTest
* @ author       : PwC Team
* @date         : May 8th,2023
* @description  : To test the Batch Class TPM_UserAutomationSetupObjectBatch 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_UserAutomationSetupObjectBatchTest {
    
   	public static final String ASSERT_STR = 'No Permission Set Group created';
    
    /******************************************************************************************
    * @method			createTestUserRecords
    * @ return     		:void
    * @param   		  
    * @description    	Test Method for creating Test Data
    ******************************************************************************************/
    @testSetup
    public static void createTestUserRecords(){
        String profileId = TPM_TestDataUtility.getProfileId('System Administrator');
        User userObj = TPM_TestDataUtility.createTestUser(profileId,'Test','User');
        insert userObj;
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
        Database.executeBatch(new TPM_UserAutomationSetupObjectBatch());
        
        Test.stopTest();
        
        User userobj = [SELECT 	Id,
                        		TPM_Persona__c,
                        		FirstName,
                        		IsActive 
                       	FROM    User 
                       	WHERE   FirstName='Test' 
                        LIMIT   1];
        
        List<PermissionSetAssignment> permissionSetGrpAssignment = [SELECT 	Id, 
                                                                         	PermissionSetId,
                                                                         	PermissionSetGroupId,
                                                                            PermissionSetGroup.DeveloperName,
                                                                         	AssigneeId,
                                                                    		Assignee.Name,
                                                                         	IsActive 
                                                                  	FROM   	PermissionSetAssignment
                                                                  	WHERE  	AssigneeId =: userobj.Id];
        
       System.assertEquals(false, permissionSetGrpAssignment.isEmpty(), ASSERT_STR);
    }

}