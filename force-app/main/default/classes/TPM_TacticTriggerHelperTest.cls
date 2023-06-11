/*******************************************************************************************************
* @Name         : TPM_TacticTriggerHelperTest
* @author       : PwC Team
* @date         : April 6, 2023
* @description  : Test class for batch - 'TPM_TacticTriggerHelper'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_TacticTriggerHelperTest {
    
    /*******************************************
	* @method         : setup
	* @description    : To create test data 
	********************************************/   
    @testSetup static void testDataSetUpMethod() {
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPM1AdminFName',
                                                            'testTPM1AdminLName');
        adminUser.Email = 'tpmadminuser018@invalidtpm.com';
        adminUser.cgcloud__Sales_Org__c = 'US01';
        insert adminUser;
    }
    
    
    /*******************************************************
	* @method         : testTacticTCCDCreation
	* @description    : To test 
	***********************************************************/
    @isTest
    public static void testTacticTCCDCreation(){
        
        User adminUser = [SELECT Id 
                          FROM User 
                          WHERE Email = 'tpmadminuser018@invalidtpm.com' LIMIT 1];
        
        System.runAs(adminUser) {
            
            Test.startTest();
            List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
            insert triggerConfigSettingList;
            
            Account totalSalesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org', null);
            insert totalSalesOrgAcc;
            
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup', totalSalesOrgAcc.Id);
            insert superGroupAcc;
            
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group', superGroupAcc.Id);
            insert groupAcc;
            
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account', GroupAcc.Id);
            insert managedAccountAcc;
            
            cgcloud__Promotion_Template__c promotionTemp = new cgcloud__Promotion_Template__c(Name = 'PromotionTemplateUS01',
                                                                                         cgcloud__Promotion_Type__c =  'Promotion',
                                                                                         cgcloud__Active__c = true,
                                                                                         RecordTypeId = Schema.SObjectType.cgcloud__Promotion_Template__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(),
                                                                                         cgcloud__Sales_Org__c = 'US01',
                                                                                         cgcloud__Description_Language_1__c = 'Test',
                                                                                         cgcloud__Available_Product_Level__c = 'Category;SubCategory;Brand;Flavor',
                                                                                         cgcloud__Calculation_Mode__c = 'No',
                                                                                         cgcloud__Displayed_Product_Level__c = 'Category;SubCategory;Brand;Flavor',
                                                                                         cgcloud__Anchor_Type__c = 'Customer',
                                                                                         cgcloud__Display_Fund_Card__c = true,
                                                                                         cgcloud__Promo_Phases_Cleaning__c = 'Preparation',
                                                                                         cgcloud__UI_Type__c = 'SmartUI',
                                                                                         cgcloud__Product_Definition_Policy__c = 'Dynamic;Static');
            
            promotionTemp.cgcloud__Enable_Condition_Creation__c = true;
            insert promotionTemp;
            
            cgcloud__Promotion__c promotionRec = new cgcloud__Promotion__c();
            
            promotionRec.cgcloud__Anchor_Account__c = managedAccountAcc.Id;
            promotionRec.cgcloud__Promotion_Template__c = promotionTemp.Id;
            promotionRec.cgcloud__Slogan_Language_1__c = 'Test';
            
            promotionRec.cgcloud__Placement_Date_From__c = System.today();
            promotionRec.cgcloud__Placement_Date_Thru__c = System.today() + 7;
            promotionRec.cgcloud__Delivery_Date_From__c = System.today();
            promotionRec.cgcloud__Delivery_Date_Thru__c = System.today() + 7;
            insert promotionRec;          
            
            //Create Tactic template
            cgcloud__Tactic_Template__c tacticTemplate = TPM_TestDataUtilityExtension.createTacticsTemplate();
            insert tacticTemplate;
            
            //Create tactic
            cgcloud__Tactic__c tacticRec = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);
            //tacticRec.cgcloud__Plan_Spend__c = 5000;
            insert tacticRec;
            
            promotionRec.TPM_Phase__c = 'Planning';
            promotionRec.cgcloud__Note__c = 'Test';
            update promotionRec;
            
            List<cgcloud__Tactic__c> tacticList = [SELECT Id, cgcloud__Condition_Maintenance__c FROM cgcloud__Tactic__c WHERE Id = :tacticRec.Id];
            System.assertEquals(null, tacticList[0].cgcloud__Condition_Maintenance__c, 'no value match');
            
            Test.stopTest();
        }
    }
    
}