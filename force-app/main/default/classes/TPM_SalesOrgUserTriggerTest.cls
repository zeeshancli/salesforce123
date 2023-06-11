@isTest
public class TPM_SalesOrgUserTriggerTest {
    
     /******************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for user test class
    ******************************************************************************************/
    @testSetup static void testDataSetUpMethod() {
        
        //Create Trigger Config Settings for Activation of Trigger based on Profile.
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        insert triggerConfigSettingList;
        User userObj = TPM_TestDataUtility.createUser('System Administrator');
        insert userObj;
    }
    
     /******************************************************************************************
    * @method			createTestUserRecords
    * @ return     		void		  
    * @description    	Test Method to create Test User Records 
    ******************************************************************************************/
   
    public static void createTestUserRecords(){
        //Get the Profile ID for the User
        String profileId = TPM_TestDataUtility.getProfileId('System Administrator');
        
        //Create Test User Records
        User createTestOneUser = TPM_TestDataUtility.createTestUser(profileId,'FNameOne','LNameOne');
        insert createTestOneUser;
        
        //Create Test User Records
        User createTestTwoUser = TPM_TestDataUtility.createTestUser(profileId,'FNameTwo','LNameTwo');
        insert createTestTwoUser;
        
        //Create Test User Records
        User createTestThreeUser = TPM_TestDataUtility.createTestUser(profileId,'FNameThree','LNameThree');
        insert createTestThreeUser;
        
        //Create Test User Records
        User createTestFourUser = TPM_TestDataUtility.createTestUser(profileId,'FNameFour','LNameFour');
        insert createTestFourUser;
    }
    
     /******************************************************************************************
    * @method			assignProductTemplate
    * @ return     		void		  
    * @description    	Test Method for assigning productTemplate to product records
    ******************************************************************************************/
    
    public static void assignProductTemplate(){

        Test.startTest();
        //Call the batch execute method
        Database.executeBatch(new TPM_ProductTemplateAssignmentBatch(),200);
        Test.stopTest();
    }
    
    /******************************************************************************************
    * @method			createProductMgrTest
    * @ return     		void		  
    * @description    	Test Method for salesOrgUserTriggerHelper Class 
    ******************************************************************************************/
    @isTest
    public static void createProductMgrTest(){
        
        //Create Sales Org Test Records
        cgcloud__Sales_Organization__c salesOrgToCreate = TPM_TestDataUtility.createCGCloudSalesOrg('US01');
        insert salesOrgToCreate;
        
        //Create Product Records at Category Level With Template
        TPM_TestDataUtility.createProductData('US01','Product','Category',5,true); 
        
        //Assgin Product Template Records
        assignProductTemplate();

        //Create Test User Records
        createTestUserRecords();
        
        //Get the created Test Sales Org Record
		Id createdSalesOrgID = [SELECT  Id,
                                    	Name
                                FROM    cgcloud__Sales_Organization__c
                                WHERE   Name = 'US01'].Id;
        
        //Get the created Test User Record
        Id usrOneID = [SELECT Id,
                      		  firstname,
                      		  lastName
                       FROM	  User
                       WHERE  firstname = 'FNameOne'].Id;

		//Create Sales Org User Record to fire the Trigger
        cgcloud__Sales_Organization_User__c   salesOrgUsrOne = new  cgcloud__Sales_Organization_User__c(cgcloud__User__c = usrOneID,
                                                                                                        cgcloud__Sales_Organization__c = createdSalesOrgID);
        insert salesOrgUsrOne;
        
        //Get the created Product Manager Record
        List<cgcloud__Product_Category_Share__c> createdProductMgrList = [SELECT  Id, 
                                                                                  Name,
                                                                                  cgcloud__Account__c,
                                                                                  cgcloud__Active__c,
                                                                                  cgcloud__User__c 
                                                                          FROM 	  cgcloud__Product_Category_Share__c 
                                                                          WHERE   cgcloud__Product__r.cgcloud__Sales_Org__c = 'US01' 
                                                                          AND     cgcloud__Product__r.cgcloud__Product_Level__c = 'Category'
                                                                          AND	  cgcloud__Active__c = 'Active'
                                                                          LIMIT	  1];
        
        System.assertEquals('Active',createdProductMgrList[0].cgcloud__Active__c , 'Newly inserted Product Manager Record is not Active');
        System.assertEquals(true,!createdProductMgrList.isEmpty() , 'No Product Manager Records are created');         
    }
    
     /******************************************************************************************
    * @method			testsalesOrgUserHandlerMethod
    * @ return     		:void
    * @param   		  
    * @description    	test method for sales org user trigger helper
    ******************************************************************************************/
   
    public static void testsalesOrgUserHandlerMethod() {
        List<Sobject> sobjectList = new List<Sobject>();
        Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
        Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
        TPM_SalesOrgUserTriggerHandler tpmTriggerHandler = new TPM_SalesOrgUserTriggerHandler();
        tpmTriggerHandler.bulkBefore();
        tpmTriggerHandler.beforeInsert(sobjectList);
        tpmTriggerHandler.afterInsert(newMapParam);
        tpmTriggerHandler.beforeUpdate(newMapParam,oldMapParam);
        tpmTriggerHandler.beforeDelete(oldMapParam);
        tpmTriggerHandler.afterDelete(oldMapParam);
        tpmTriggerHandler.afterUnDelete(sobjectList);
    }   

}