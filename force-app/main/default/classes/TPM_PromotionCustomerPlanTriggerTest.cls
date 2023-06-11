/*******************************************************************************************************
* @name         : TPM_PromotionCustomerPlanTriggerTest
* @author       : PwC Team
* @date         : 01/30/2023
* @description  : Test Class for Promotion and Customer Plan Triggers
*******************************************************************************************************/
@isTest
public with sharing class TPM_PromotionCustomerPlanTriggerTest {

    static String assertStr = 'List should not be empty';
    static String testNew ='Test new';
    static String test ='Test';
    static String us ='LA';
    static String foodDrug ='TI';
    static String drug ='Drug';
    static String phaseUpdateSuccessMsg = 'Promtion Phase Sync Update Matched!';
    
    /*****************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for account Team test class
    *****************************************************************************************/
    
    @testSetup static void testDataSetUpMethod() {
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPMAdminFName',
                                                            'testTPMAdminLName');
        
        //Add email
        adminUser.Email = 'tpmadminuser007@invalidtpm.com';
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
        
        // Create Admin adminUserThird.
        User adminUserThird = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                               'testTPMAdminNewFNameThird',
                                                               'testTPMAdminNewLNameThird');
        
        //Add email
        adminUserThird.Email = 'tpmadminusernew009@invalidtpm.com';
        //Insert admin new user
        insert adminUserThird;
        
        // Create Admin adminUserFourth.
        User adminUserFourth = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                               'testTPMAdminNewFNameFourth',
                                                               'testTPMAdminNewLNameFourth');
        
        //Add email
        adminUserFourth.Email = 'tpmadminusernew010@invalidtpm.com';
        //Insert admin new user
        insert adminUserFourth;
        
        // Create Admin adminUserFifth.
        User adminUserFifth = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                               'testTPMAdminNewFNameFourth',
                                                               'testTPMAdminNewLNameFourth');
        
        //Add email
        adminUserFifth.Email = 'tpmadminusernew011@invalidtpm.com';
        //Insert admin new user
        insert adminUserFifth;
        
        // Create Admin adminUserSixth.
        User adminUserSixth = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                               'testTPMAdminNewFNameFourth',
                                                               'testTPMAdminNewLNameFourth');
        
        //Add email
        adminUserSixth.Email = 'tpmadminusernew012@invalidtpm.com';
        //Insert admin new user
        insert adminUserSixth;
        
        // Create Admin adminUserSeventh.
        User adminUserSeventh = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                               'testTPMAdminNewFNameFourth',
                                                               'testTPMAdminNewLNameFourth');
        
        //Add email
        adminUserSeventh.Email = 'tpmadminusernew013@invalidtpm.com';
        //Insert admin new user
        insert adminUserSeventh;
    }
        
    /*****************************************************************************************
    * @method			executeBusPlanPromotionCreation  
    * @description    	Call triggers for business plan and promotion creation
    *****************************************************************************************/
    @isTest
    public static void executeAccountPlanAndPromotionCreation(){
        
        //Insert 1st user
        User adminUser = [SELECT Id 
                          FROM User 
                          WHERE Email = 'tpmadminuser007@invalidtpm.com' LIMIT 1];
        //Insert 2nd user
        User adminUserNew = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew008@invalidtpm.com' LIMIT 1];
        
        System.runAs(adminUser) {   
            
            //Insert triggerconfig settings
            List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
            triggerConfigSettingList[0].TPM_Promotion_Trigger_Active__c = true;
            triggerConfigSettingList[0].TPM_AccountPlanTrigger_Active__c = true;
            insert triggerConfigSettingList;
            
            //insert supergroup
            Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org',null);
            insert totalSaslesOrgAcc;
            
            //insert supergroup
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',totalSaslesOrgAcc.Id);
            insert superGroupAcc;
            
            //insert group
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
            insert groupAcc;
            
            //insert Managed account
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
            insert managedAccountAcc;

            managedAccountAcc.TPM_Sector__c = us;
            managedAccountAcc.TPM_Segment__c = foodDrug;
            managedAccountAcc.TPM_Subsegment__c = drug;

            update managedAccountAcc;
            
            AccountTeamMember accTeamMemberObj1 = TPM_TestDataUtility.createAccountTeamMember(managedAccountAcc.Id,adminUser.Id);
            insert accTeamMemberObj1;
            
            AccountTeamMember accTeamMemberObj2 = TPM_TestDataUtility.createAccountTeamMember(managedAccountAcc.Id,adminUserNew.Id);
            insert accTeamMemberObj2;
            
            //Create customer business plan
            cgcloud__Account_Plan__c busPlanRec = new cgcloud__Account_Plan__c(cgcloud__Account__c = managedAccountAcc.Id,
                                                                               cgcloud__Business_Year__c = 2024,
                                                                               cgcloud__Description_Language_1__c = test,
                                                                               cgcloud__Category_Labels_Language_1__c = test);
            insert busPlanRec;
            
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTemp;
            
            //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
            insert promotionRec;
            
            //Update promotion
            List<cgcloud__Promotion__c> promRec = [SELECT id,TPM_Sector__c,TPM_Segment__c,TPM_Subsegment__c from cgcloud__Promotion__c WHERE id!=NULL];
            System.assertEquals(1,promRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            
            for(cgcloud__Promotion__c existingProm : promRec){
                
                System.assertEquals(us,existingProm.TPM_Sector__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
                System.assertEquals(foodDrug,existingProm.TPM_Segment__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
                System.assertEquals(drug,existingProm.TPM_Subsegment__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            }
                        
            //Update customer business plan
            List<cgcloud__Account_Plan__c> busPlanRecord = [SELECT id,TPM_Sector__c,TPM_Segment__c,TPM_Subsegment__c from cgcloud__Account_Plan__c WHERE id!=NULL LIMIT 1];
            System.assertEquals(1,busPlanRecord.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            
            for(cgcloud__Account_Plan__c exisBusPlan : busPlanRecord){
                
                System.assertEquals(us,exisBusPlan.TPM_Sector__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
                System.assertEquals(foodDrug,exisBusPlan.TPM_Segment__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
                System.assertEquals(drug,exisBusPlan.TPM_Subsegment__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            }
            
            // Update SVF in promotion
            List<cgcloud__Account_Plan__c> busPlanList = [SELECT id from cgcloud__Account_Plan__c WHERE id!=NULL LIMIT 1];
            for(cgcloud__Promotion__c promRecord : [SELECT id,TPM_SVF__c from cgcloud__Promotion__c WHERE id!=NULL LIMIT 1]){
                System.assertEquals(busPlanList[0].id,promRecord.TPM_SVF__c,TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            }
            
            //Call different context methods of account trigger handler
            List<Sobject> sobectList = new List<Sobject>();
            Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
            Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
            TPM_AccountPlanTriggerHandler tpmAccountTriggerHandler = new TPM_AccountPlanTriggerHandler();
            tpmAccountTriggerHandler.bulkBefore();
            tpmAccountTriggerHandler.beforeInsert(sobectList);
            tpmAccountTriggerHandler.beforeUpdate(newMapParam,oldMapParam);
            tpmAccountTriggerHandler.beforeDelete(oldMapParam);
            tpmAccountTriggerHandler.afterDelete(oldMapParam);
            tpmAccountTriggerHandler.afterUnDelete(sobectList);
            //Call different context methods of promotion trigger handler
            TPM_PromotionTriggerHandler tpmPromotion = new TPM_PromotionTriggerHandler();
            tpmPromotion.bulkBefore();
            tpmPromotion.beforeInsert(sobectList);
            tpmPromotion.beforeUpdate(newMapParam,oldMapParam);
            tpmPromotion.beforeDelete(oldMapParam);
            tpmPromotion.afterDelete(oldMapParam);
            tpmPromotion.afterUnDelete(sobectList);
            
        }
    }
    
    /*****************************************************************************************
    * @method			testPromotionApprovalsCreation  
    * @description    	Call triggers for Promotion approval creation
    *****************************************************************************************/
    @isTest
    public static void testPromotionApprovalsCreation(){
        
        //Insert 7th user
        User adminUserSeventh = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew013@invalidtpm.com' LIMIT 1];
        adminUserSeventh.TPM_ApprovalLevel__c = '9';
        adminUserSeventh.cgcloud__Sales_Org__c = 'US01';
        adminUserSeventh.TPM_Is_OutOfOffice__c = false;
        update adminUserSeventh;
        
        //Insert 6th user
        User adminUserSixth = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew012@invalidtpm.com' LIMIT 1];
        adminUserSixth.TPM_ApprovalLevel__c = '6';
        adminUserSixth.cgcloud__Sales_Org__c = 'US01';
        adminUserSixth.TPM_Is_OutOfOffice__c = false;
        adminUserSixth.ManagerId = adminUserSeventh.Id;
        update adminUserSixth;
        
        //Insert 5th user
        User adminUserFifth = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew011@invalidtpm.com' LIMIT 1];
        adminUserFifth.TPM_ApprovalLevel__c = '5';
        adminUserFifth.cgcloud__Sales_Org__c = 'US01';
        adminUserFifth.TPM_Is_OutOfOffice__c = false;
        adminUserFifth.ManagerId = adminUserSixth.Id;
        update adminUserFifth;
        
        //Insert 4th user
        User adminUserFourth = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew010@invalidtpm.com' LIMIT 1];
        adminUserFourth.TPM_ApprovalLevel__c = '4';
        adminUserFourth.cgcloud__Sales_Org__c = 'US01';
        adminUserFourth.TPM_Is_OutOfOffice__c = false;
        adminUserFourth.ManagerId = adminUserFifth.Id;
        update adminUserFourth;
        
        //Insert 3rd user
        User adminUserThird = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew009@invalidtpm.com' LIMIT 1];
        adminUserThird.TPM_ApprovalLevel__c = '3';
        adminUserThird.cgcloud__Sales_Org__c = 'US01';
        adminUserThird.TPM_Is_OutOfOffice__c = false;
        adminUserThird.ManagerId = adminUserFourth.Id;
        update adminUserThird;
        
        //Insert 2nd user
        User adminUserNew = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew008@invalidtpm.com' LIMIT 1];
        adminUserNew.TPM_ApprovalLevel__c = '2';
        adminUserNew.cgcloud__Sales_Org__c = 'US01';
        adminUserNew.TPM_Is_OutOfOffice__c = false;
        adminUserNew.ManagerId = adminUserThird.Id;
        update adminUserNew;
        
        //Insert 1st user
        User adminUser = [SELECT Id 
                          FROM User 
                          WHERE Email = 'tpmadminuser007@invalidtpm.com' LIMIT 1];
        
        adminUser.TPM_ApprovalLevel__c = '1';
        adminUser.cgcloud__Sales_Org__c = 'US01';
        adminUser.ManagerId = adminUserNew.Id;
        update adminUser;        
                
        System.runAs(adminUser) {   
            
            //Insert triggerconfig settings
            List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
            triggerConfigSettingList[0].TPM_Promotion_Trigger_Active__c = true;
            insert triggerConfigSettingList;
            
            //insert supergroup
            Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org',null);
            insert totalSaslesOrgAcc;
            
            //insert supergroup
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',totalSaslesOrgAcc.Id);
            insert superGroupAcc;
            
            //insert group
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
            insert groupAcc;
            
            //insert Managed account
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
            insert managedAccountAcc;

            
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTemp;
            
            //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_PLANNING;
            promotionRec.TPM_Planned_Spend__c = 2500000;
            insert promotionRec;
                        
            //Create Tactic template
            cgcloud__Tactic_Template__c tacticTemplate = TPM_TestDataUtilityExtension.createTacticsTemplate();
            insert tacticTemplate;
            
            //Create tactic
            cgcloud__Tactic__c tacticRec = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);
            tacticRec.cgcloud__Plan_Spend__c = 2500000;
            insert tacticRec;
                        
            //update promotion with phase as submitted for approval
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_SUBMITTEDFORAPPROVAL;
            update promotionRec;
            
            //Asset verifying TPM_Phase__c / cgcloud__Phase__c are in Sync
            List<cgcloud__Promotion__c> promRec = [SELECT Id, TPM_Phase__c, cgcloud__Phase__c from cgcloud__Promotion__c WHERE id != NULL];
            System.assertEquals(promRec[0].cgcloud__Phase__c, TPM_ConstantsUtility.PHASE_FORAPPROVAL, phaseUpdateSuccessMsg);            
            
            
        }
    }
    
    /*****************************************************************************************
    * @method			testPromotionApprovalsRouting  
    * @description    	Call triggers for Promotion approval routing
    *****************************************************************************************/
    @isTest
    public static void testPromotionApprovalsRouting(){
        
        //Insert 3rd user
        User adminUserThird = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew009@invalidtpm.com' LIMIT 1];
        adminUserThird.TPM_ApprovalLevel__c = '9';
        adminUserThird.cgcloud__Sales_Org__c = 'US01';
        adminUserThird.TPM_Is_OutOfOffice__c = false;
        update adminUserThird;
        
        //Insert 2nd user
        User adminUserNew = [SELECT Id 
                             FROM User 
                             WHERE Email = 'tpmadminusernew008@invalidtpm.com' LIMIT 1];
        adminUserNew.TPM_ApprovalLevel__c = '2';
        adminUserNew.cgcloud__Sales_Org__c = 'US01';
        adminUserNew.ManagerId = adminUserThird.Id;
        adminUserNew.TPM_Is_OutOfOffice__c = true;
        update adminUserNew;
        
        //Insert 1st user
        User adminUser = [SELECT Id 
                          FROM User 
                          WHERE Email = 'tpmadminuser007@invalidtpm.com' LIMIT 1];
        
        adminUser.TPM_ApprovalLevel__c = '1';
        adminUser.cgcloud__Sales_Org__c = 'US01';
        adminUser.ManagerId = adminUserNew.Id;
        update adminUser;     
        
        
        System.runAs(adminUser) {   
            
            //Insert triggerconfig settings
            List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
            triggerConfigSettingList[0].TPM_Promotion_Trigger_Active__c = true;
            insert triggerConfigSettingList;
            
            //insert supergroup
            Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org',null);
            insert totalSaslesOrgAcc;
            
            //insert supergroup
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',totalSaslesOrgAcc.Id);
            insert superGroupAcc;
            
            //insert group
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
            insert groupAcc;
            
            //insert Managed account
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
            insert managedAccountAcc;

            
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTemp;
            
            //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_PLANNING;
            promotionRec.TPM_Planned_Spend__c = 120000000;
            insert promotionRec;
            
            //Create Tactic template
            cgcloud__Tactic_Template__c tacticTemplate = TPM_TestDataUtilityExtension.createTacticsTemplate();
            insert tacticTemplate;
            
            //Create tactic
            cgcloud__Tactic__c tacticRec = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);
            tacticRec.cgcloud__Plan_Spend__c = 120000000;
            insert tacticRec;
            
            //update promotion with phase as submitted for approval
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_SUBMITTEDFORAPPROVAL;
            update promotionRec;
               
            //Asset verifying TPM_Phase__c / cgcloud__Phase__c are in Sync
            List<cgcloud__Promotion__c> promRec = [SELECT Id, TPM_Phase__c, cgcloud__Phase__c from cgcloud__Promotion__c WHERE id != NULL];
            System.assertEquals(promRec[0].cgcloud__Phase__c, TPM_ConstantsUtility.PHASE_FORAPPROVAL, phaseUpdateSuccessMsg);            
            
            
        }
    }
    
    /*****************************************************************************************
    * @method			testPromotionPhaseChangeSync  
    * @description    	Call triggers for Phase update sync
    *****************************************************************************************/
    @isTest
    public static void testPromotionPhaseChangeSync(){
        
        //Insert 1st user
        User adminUser = [SELECT Id 
                          FROM User 
                          WHERE Email = 'tpmadminuser007@invalidtpm.com' LIMIT 1];
        
        
        System.runAs(adminUser) {   
            
            //Insert triggerconfig settings
            List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
            triggerConfigSettingList[0].TPM_Promotion_Trigger_Active__c = true;
            insert triggerConfigSettingList;
            
            //insert supergroup
            Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org',null);
            insert totalSaslesOrgAcc;
            
            //insert supergroup
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',totalSaslesOrgAcc.Id);
            insert superGroupAcc;
            
            //insert group
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
            insert groupAcc;
            
            //insert Managed account
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
            insert managedAccountAcc;

            
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTemp;
            
            //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_PLANNING;
            insert promotionRec;
            
            //Create Tactic template
            cgcloud__Tactic_Template__c tacticTemplate = TPM_TestDataUtilityExtension.createTacticsTemplate();
            insert tacticTemplate;
            
            //Create tactic
            cgcloud__Tactic__c tacticRec = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);
            insert tacticRec;
            
            //update promotion with phase as draft
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
            update promotionRec;
            
            //update promotion with phase as approved
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_APPROVED;
            update promotionRec;
            
            //update promotion with phase as closed
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_CLOSED;
            update promotionRec;
            
            //update promotion with phase as finance edit
            promotionRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_FINANCE_EDIT;
            update promotionRec;
               
            //Asset verifying TPM_Phase__c / cgcloud__Phase__c are in Sync
            List<cgcloud__Promotion__c> promRec = [SELECT Id, TPM_Phase__c, cgcloud__Phase__c from cgcloud__Promotion__c WHERE id != NULL];
            System.assertEquals(promRec[0].cgcloud__Phase__c, TPM_ConstantsUtility.PHASE_MODELLING, phaseUpdateSuccessMsg);            
            
            
        }
    }
}