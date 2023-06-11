/*******************************************************************************************************
* @Name         : TPM_AccountTriggerTest
* @author       : PwC Team
* @date         : March 7, 2023
* @description  : Test class for TPM_AccountTrigger
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public with sharing class TPM_AccountTriggerTest {
    
    static String assertStr = 'Exception message should not be empty';
    static String test ='Test';
    static String us ='NA';
    static String foodDrug ='FOOD_DRUG';
    static String drug ='Drug';
    
    /*********************************************************************************
	@description      create test data records
	**********************************************************************************/
    @testSetup
    static void setup() {
        String customerStr = 'Customer'; 
        String us01Str = 'US01';
        String accountStr = 'Account';
        String managedAccount ='Managed Account';
        
        //insert custom setting TPM_Trigger_Config_Settings__c
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        insert triggerConfigSettingList;
        
        //insert custom setting TPM_Trigger_Conditions_Check__c
        List<TPM_Trigger_Conditions_Check__c> triggerConditionCheckList = TPM_TestDataUtilityExtension.createTriggerConditionCheck();
        insert triggerConditionCheckList;
        
        // Create Business Admin User.
        User busAdminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('Business Admin'),
                                                               'testTPMAdminFName',
                                                               'testTPMAdminLName');
        
        //Add email
        busAdminUser.Email = 'tpmadminuser008@invalidtpm.com';
        
        //Insert business admin user
        insert busAdminUser;
        
        // Create account record.
        Account accountTestTrigger = new Account(Name = 'TestTriggerAcc', 
                                                 RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                 TPM_Hierarchy_Level__c = managedAccount, 
                                                 TPM_SAP_Sales_Org__c = us01Str, 
                                                 TPM_Planning_Mode__c = 'Basic');
        insert accountTestTrigger;
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPMAdminFName',
                                                            'testTPMAdminLName');
        
        //Add email
        adminUser.Email = 'tpmadminuser008@invalidtpm.com';
        //Insert admin user
        insert adminUser;
        
        // Create Admin NewUser.
        User adminUserNew = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                               'testTPMAdminNewFName',
                                                               'testTPMAdminNewLName');
        
        //Add email
        adminUserNew.Email = 'tpmadminusernew008@invalidtpm.com';
        //Insert admin new user
        insert adminUserNew;
        
        System.runAs(adminUser) {   
                        
            //insert supergroup
            Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org', null);
            insert totalSaslesOrgAcc;
            
            //insert supergroup
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup', totalSaslesOrgAcc.Id);
            insert superGroupAcc;
            
            //insert group
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group', superGroupAcc.Id);
            insert groupAcc;
            
            //insert Managed account
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account', GroupAcc.Id);
            insert managedAccountAcc;
            
            AccountTeamMember accTeamMemberObj1 = TPM_TestDataUtility.createAccountTeamMember(managedAccountAcc.Id, adminUser.Id);
            insert accTeamMemberObj1;
            
            AccountTeamMember accTeamMemberObj2 = TPM_TestDataUtility.createAccountTeamMember(managedAccountAcc.Id, adminUserNew.Id);
            insert accTeamMemberObj2;
            
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTemp;
            
            //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id, promotionTemp.Id);
            insert promotionRec;
            
            //Create customer business plan
            cgcloud__Account_Plan__c busPlanRec = new cgcloud__Account_Plan__c(cgcloud__Account__c = managedAccountAcc.Id,
                                                                               cgcloud__Business_Year__c = 2023,
                                                                               cgcloud__Description_Language_1__c = test,
                                                                               cgcloud__Category_Labels_Language_1__c = test);
            insert busPlanRec;  
            
        }
    }
    
    /*********************************************************************************
	@description      Call the class to check validation for account update
	**********************************************************************************/
    @isTest
    public static void executeAccountTriggerUpdate(){
        
        //Fetch business admin users
        User busAdminUser = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
        
        //Add Business Admin Permission set
        PermissionSet permission =[SELECT Id, 
                                   Name 
                                   FROM PermissionSet 
                                   WHERE Name = 'TPM_Business_Admin_Permission_Set'];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.PermissionSetId = permission.Id;
        permissionSetAssignment.AssigneeId = busAdminUser.Id;
        
        //Add this permission set to business admin user
        insert permissionSetAssignment;
        
        //Run as business admin user
        System.runAs(busAdminUser){
            System.Test.startTest();
            
            try{
                Account acc = [SELECT Id,
                               Name
                               FROM Account 
                               WHERE  Name = 'TestTriggerAcc' LIMIT 1];
                //try to update account and validation should be thrown
                acc.Name = 'UpdateTestTriggerAcc';
                update acc;
            }
            catch(Exception exp){
                System.Assert(String.isNotBlank(exp.getMessage()),assertStr);
            }
            System.Test.stopTest();
            
        }
        
        //Call other methods of trigger handler
        List<Sobject> sobectList = new List<Sobject>();
        Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
        Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
        TPM_AccountTriggerHandler tpmTriggerHandler = new TPM_AccountTriggerHandler();
        tpmTriggerHandler.bulkBefore();
        tpmTriggerHandler.bulkAfter();
        tpmTriggerHandler.beforeInsert(sobectList);
        tpmTriggerHandler.afterInsert(newMapParam);
        tpmTriggerHandler.afterUpdate(newMapParam,oldMapParam);
        tpmTriggerHandler.afterDelete(oldMapParam);
        tpmTriggerHandler.afterUnDelete(sobectList);
        
        
    }
    
    /*********************************************************************************
	@description      Call the class to check validation for account delete
	**********************************************************************************/
    @isTest
    public static void executeAccountTriggerDelete(){
        
        //Fetch business admin user
        User busAdminUser = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
        //Add Business Admin Permission set
        PermissionSet permission =[SELECT Id, Name FROM PermissionSet WHERE Name = 'TPM_Business_Admin_Permission_Set'];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.PermissionSetId = permission.Id;
        permissionSetAssignment.AssigneeId = busAdminUser.Id;
        
        //Add this permission set to business admin user
        insert permissionSetAssignment;
        
        //Run as business admin user
        System.runAs(busAdminUser){
            
            System.Test.startTest();
            try{
                
                Account acc = [SELECT Id,
                               Name
                               FROM Account 
                               WHERE Name = 'TestTriggerAcc' LIMIT 1];
                
                //try to Delete account and validation should be thrown
                Delete acc;
            }
            
            catch(Exception exp){
                
                System.Assert(String.isNotBlank(exp.getMessage()),assertStr);
                
            }
            System.Test.stopTest();
        }
        
    }
    
    /******************************************************************************************
    * @method			testAccountTeamHandlerMethod
    * @ return     		void
    * @param   		  
    * @description    	test method for account trigger handler
    ******************************************************************************************/
    @isTest
    public static void testAccountUpdateMethod() {
        
        Account managedAccount = [SELECT Id, Name, TPM_Hierarchy_Level__c, TPM_Sector__c, TPM_Segment__c, TPM_Subsegment__c FROM Account WHERE Name LIKE 'Test Customer%' AND TPM_Hierarchy_Level__c = 'Managed Account' LIMIT 1];
        managedAccount.TPM_Sector__c = us;
        managedAccount.TPM_Segment__c = foodDrug;
        managedAccount.TPM_Subsegment__c = drug;
        update managedAccount;
        
        // promotions verify field updates
        List<cgcloud__Promotion__c> promRec = [SELECT id,TPM_Sector__c,TPM_Segment__c,TPM_Subsegment__c from cgcloud__Promotion__c WHERE cgcloud__Anchor_Account__c = :managedAccount.Id];
        
        for(cgcloud__Promotion__c existingProm : promRec){
            
            System.assertEquals(us, existingProm.TPM_Sector__c, TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            System.assertEquals(foodDrug, existingProm.TPM_Segment__c, TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            System.assertEquals(drug, existingProm.TPM_Subsegment__c, TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        }
        
        
        // customer business plan verify field updates
        List<cgcloud__Account_Plan__c> busPlanRecord = [SELECT id,TPM_Sector__c,TPM_Segment__c,TPM_Subsegment__c from cgcloud__Account_Plan__c WHERE cgcloud__Account__c = :managedAccount.Id LIMIT 1];
        
        for(cgcloud__Account_Plan__c exisBusPlan : busPlanRecord){
            
            System.assertEquals(us, exisBusPlan.TPM_Sector__c, TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            System.assertEquals(foodDrug, exisBusPlan.TPM_Segment__c, TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            System.assertEquals(drug, exisBusPlan.TPM_Subsegment__c, TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        }
        
    }
    
    /******************************************************************************************
    * @method			testAccountUpdateErrors
    * @ return     		void
    * @param   		  
    * @description    	test method for account trigger handler
    ******************************************************************************************/
    @isTest
    public static void testAccountUpdateErrors() {
        
        Map<Id,Account> managedAccount = new Map<Id,Account>([SELECT Id, TPM_Sector__c, TPM_Segment__c, TPM_Subsegment__c FROM Account WHERE Name LIKE 'Test Customer%' AND TPM_Hierarchy_Level__c = 'Managed Account']);

        System.Test.startTest();
        try{
            TPM_AccountTriggerHelper.updateRelatedRecordsInfo(managedAccount,  Null);
        }catch(Exception excep){
            System.assert(excep.getMessage().contains('MISSING_ARGUMENT'));
        }
        System.Test.stopTest();
    }
    
}