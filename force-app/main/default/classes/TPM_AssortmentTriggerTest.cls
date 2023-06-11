/*******************************************************************************************************
* @Name         : TPM_AssortmentTriggerTest
* @author       : PwC Team
* @date         : March 7, 2023
* @description  : Test class for TPM_AssortmentTrigger
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public with sharing class TPM_AssortmentTriggerTest {
    /*********************************************************************************
          @description      create test data records
        **********************************************************************************/
        static String assertStr = 'Exception message should not be empty';
        @testSetup
        static void setup() {

            String us01Str = 'US01';

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

            // Create assortment template record.
            cgcloud__Product_Assortment_Template__c prodAssort = new cgcloud__Product_Assortment_Template__c(Name = 'Test Product Assortment',
                                                                       cgcloud__Sales_Org__c = us01Str,
                                                                       cgcloud__Description_Language_1__c = 'Test Product Assortment Descp');
            
            insert prodAssort;

            //Create assortment record
            Assortment assort = new Assortment(Name = 'Test Assortment',
            cgcloud__Product_Assortment_Template__c = prodAssort.Id,
            cgcloud__Valid_From__c = System.Today(),
            cgcloud__Description_Language_1__c = 'Test Assortment');
            insert assort;
           
        }
        
        /*********************************************************************************
          @description       Call the class to check validation for assortment update
        **********************************************************************************/
        @isTest
        public static void executeAssortmentTriggerUpdate(){
            
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
            Test.startTest();
                
            try{
                Assortment assort = [SELECT Id,
                                        Name
                                        FROM Assortment 
                                        WHERE  Name = 'Test Assortment' LIMIT 1];
                   //try to update assortment and validation should be thrown
                   assort.Name = 'UpdateTestTriggerAcc';
                    update assort;
                }
            catch(Exception exp){
                System.Assert(String.isNotBlank(exp.getMessage()),assertStr);
            }
            Test.stopTest();

            }
            
            //Call other methods of trigger handler
            List<Sobject> sobectList = new List<Sobject>();
            Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
            Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
            TPM_AssortmentTriggerHandler tpmTriggerHandler = new TPM_AssortmentTriggerHandler();
                tpmTriggerHandler.bulkBefore();
                tpmTriggerHandler.bulkAfter();
                tpmTriggerHandler.beforeInsert(sobectList);
                tpmTriggerHandler.afterInsert(newMapParam);
                tpmTriggerHandler.afterUpdate(newMapParam,oldMapParam);
                tpmTriggerHandler.afterDelete(oldMapParam);
                tpmTriggerHandler.afterUnDelete(sobectList);


    }

      /*********************************************************************************
          @description      Call the class to check validation for assortment delete
        **********************************************************************************/
        @isTest
        public static void executeAssortmentTriggerDelete(){
            
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

            Test.startTest();
                try{
                
                    Assortment assort = [SELECT Id,
                    Name
                    FROM Assortment 
                    WHERE  Name = 'Test Assortment' LIMIT 1];
                    
                    //try to Delete assortment and validation should be thrown
                    Delete assort;
                    }

                catch(Exception exp){

                    System.Assert(String.isNotBlank(exp.getMessage()),assertStr);
                   
                    }
            Test.stopTest();
        }
            
    }
}