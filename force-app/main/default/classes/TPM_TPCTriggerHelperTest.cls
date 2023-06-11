/*******************************************************************************************************
* @Name         : TPM_TPCTriggerHelperTest
* @author       : PwC Team
* @date         : April 6, 2023
* @description  : Test class for batch - 'TPM_TPCTriggerHelper'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_TPCTriggerHelperTest {
    
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
            tacticRec.cgcloud__Condition_Maintenance__c = 'initial';
            insert tacticRec;
            
            promotionRec.TPM_Phase__c = 'Planning';
            promotionRec.cgcloud__Note__c = 'Test';
            update promotionRec;
            
            //Create KPI Def
            cgcloud__KPI_Definition__c kpiDef = new cgcloud__KPI_Definition__c();
            kpiDef.cgcloud__Aggregation_Merge_Rule__c = 'avg';
            kpiDef.cgcloud__Aggregation_Rule__c = 'avg';
            kpiDef.cgcloud__Aggregation_Time_Rule__c = 'aggregate';
            kpiDef.cgcloud__BoM_Scope__c = 'Product';
            kpiDef.cgcloud__Compound_Main__c = false;
            kpiDef.cgcloud__Data_Source_Aggregation_Mode__c = 'standard';
            kpiDef.cgcloud__Data_Source_Consider_Product_Hierarchy__c = false;
            kpiDef.cgcloud__Data_Source_Load_For_Sub_Accounts__c = false;
            kpiDef.cgcloud__Data_Source_Week_Offset__c = 0;
            kpiDef.cgcloud__Data_Source_Year_Offset__c = 0;
            kpiDef.cgcloud__Description_Language_1__c = 'Rate';
            kpiDef.cgcloud__Display_Enabled__c = true;
            kpiDef.cgcloud__Display_Round__c = 0;
            kpiDef.cgcloud__Distribution_Order__c = 'PlanThenTime';
            kpiDef.cgcloud__Distribution_Plan_Hierarchy_Dist_Type__c = 'copy';
            kpiDef.cgcloud__Distribution_Time_Hierarchy_Dist_Type__c = 'copy';
            kpiDef.cgcloud__Editable_Edit_Mode__c = 'total';
            //kpiDef.cgcloud__Editable_Enable_Past_Weeks__c = false;
            kpiDef.cgcloud__Editable_Measure_Code__c = 'ERTE';
            kpiDef.cgcloud__Is_Storage_Level_Bom_Component__c = false;
            kpiDef.cgcloud__Reporting_Relevant__c = false;
            kpiDef.cgcloud__Reporting_Type__c = 'read';
            kpiDef.cgcloud__Rounding_Order__c = 'default';
            kpiDef.cgcloud__Rounding_Precision__c = '0';
            kpiDef.cgcloud__Rounding_Type__c = 'nocarryover';
            kpiDef.cgcloud__Scope__c = 'promotiontactic';
            kpiDef.cgcloud__Storage_Options_Measure_Code__c = 'PRTE';
            kpiDef.cgcloud__Storage_Options_Storage_Levels__c = 'Product';
            kpiDef.cgcloud__Storage_Options_Writeback__c = true;
            kpiDef.cgcloud__Time_Granularity__c = 'subperiod';
            kpiDef.cgcloud__Time_Scope__c = 'complete';
            kpiDef.cgcloud__Total_Calculation_Cumulative__c = 'off';
            kpiDef.cgcloud__Total_Calculation_Rule__c = 'avg';
            kpiDef.cgcloud__Value_Type__c = 'Money';
            kpiDef.Name = 'Rate';
            kpiDef.RecordTypeId = Schema.SObjectType.cgcloud__KPI_Definition__c.getRecordTypeInfosByDeveloperName().get('editable').getRecordTypeId();
            insert kpiDef;
            
            //Create TCCD
            cgcloud__Tactic_Condition_Creation_Definition__c tccdRec = new cgcloud__Tactic_Condition_Creation_Definition__c();
            tccdRec.cgcloud__Tactic__c = tacticRec.Id;
            tccdRec.cgcloud__Targets__c = 'External;Internal';
            tccdRec.cgcloud__Maintenance__c ='initial';
            tccdRec.cgcloud__Change_Rule__c = 'finish';
            tccdRec.cgcloud__Source_KPI_Definition__c = kpiDef.Id;
            insert tccdRec;
            
            List<cgcloud__Tactic_Condition_Creation_Definition__c> tccdList = [SELECT Id, cgcloud__Maintenance__c FROM cgcloud__Tactic_Condition_Creation_Definition__c WHERE cgcloud__Tactic__c = :tacticRec.Id LIMIT 1];
            System.assertEquals('initial', tccdList[0].cgcloud__Maintenance__c, 'Intial value match');
            
            //Create TPC
            cgcloud__Tactic_Product_Condition__c tpcRec = new cgcloud__Tactic_Product_Condition__c();
            tpcRec.cgcloud__Tactic__c = tacticRec.Id;
            tpcRec.cgcloud__Value__c = 10;
            tpcRec.cgcloud__Status__c ='Modeling';
            tpcRec.cgcloud__Measure_Code__c = 'ZKBR';
            //tpcRec.cgcloud__Source_KPI_Definition__c = kpiDef.Id;
            insert tpcRec;
            
            Test.stopTest();
        }
    }
    
}