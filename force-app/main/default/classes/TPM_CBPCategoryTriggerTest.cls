/*******************************************************************************************************
* @name         : TPM_CBPCategoryTriggerTest
* @author       : PwC Team
* @date         : 12/23/2022
* @description  : Test Class for TPM_CBPCategoryTrigger
*******************************************************************************************************/
@isTest
public class TPM_CBPCategoryTriggerTest {
    
    /******************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for user test class
    ******************************************************************************************/
    @testSetup static void testDataSetUpMethod() {
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        insert triggerConfigSettingList;
        User userObj = TPM_TestDataUtility.createUser('System Administrator');
        insert userObj;
        
        // Create Test Product Record
        TPM_TestDataUtility.createProductData('US01','Product','Category',1,true);
        
        // Create Test Account Record
        List<Account> accList = TPM_TestDataUtility.createAccounts(1);
        insert accList;
        
        // Get the Created Account Record
        Account createdAccObj = [SELECT Id,
                                 		Name
                                 FROM   Account 
                                 WHERE 	Name = 'Test Customer1'];

        // Get the Created Product Record
        Product2 createdprodObj = [SELECT Id,
                           		   Name 
                            FROM   Product2
                           	WHERE  Name = 'US01 Product Test Product 1'];
        
        // Create Test SVF Record
        cgcloud__Account_Plan__c testSVFObj = new cgcloud__Account_Plan__c();
        testSVFObj.cgcloud__Business_Year__c = 2024;
        testSVFObj.cgcloud__Account__c = createdAccObj.Id;
        insert testSVFObj;

        // Create Test SVF Category Record
        cgcloud__Account_Plan_Category__c testAccPlanCat = new cgcloud__Account_Plan_Category__c();
        testAccPlanCat.cgcloud__Category__c = createdprodObj.Id;
        testAccPlanCat.cgcloud__Account_Plan__c = testSVFObj.Id;
        insert testAccPlanCat;

    }
    
     /******************************************************************************************
    * @method			testCBPCategory
    * @ return     		:void
    * @param   		  
    * @description    	test method for CBP Category Trigger
    ******************************************************************************************/
    
     @isTest
    public static void testCBPCategory() {
        
        // Get the Created Product Record 
        Product2 createdprodObj = [SELECT Id,
                           		   Name 
                            FROM   Product2
                           	WHERE  Name = 'US01 Product Test Product 1'];
        
        // Get the Created SVF Category Record
        cgcloud__Account_Plan_Category__c createdSVFCategoryObj = [SELECT Id,
                                                                   		  Name,
                                                                   		  cgcloud__Category__c
                                                                   FROM   cgcloud__Account_Plan_Category__c
                                                                   WHERE  cgcloud__Category__c =: createdprodObj.Id];
        
        // Update Test SVF Category
        createdSVFCategoryObj.cgcloud__Manual_Calculation_Input__c = 'Updating cgcloud__Manual_Calculation_Input__c field Value';
        update createdSVFCategoryObj;
        
        System.assertEquals('Updating cgcloud__Manual_Calculation_Input__c field Value', createdSVFCategoryObj.cgcloud__Manual_Calculation_Input__c, 'Field Value is not updated');
        
    }

}