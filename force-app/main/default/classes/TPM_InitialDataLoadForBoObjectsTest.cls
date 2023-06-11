/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadForBoObjectsTest
* @author       : PwC Team
* @date         : January 25, 2022
* @description  : Test class for BO Data Load Automation - 'TPM_InitialDataLoadForBoObjects'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public with sharing class TPM_InitialDataLoadForBoObjectsTest {

     /*********************************************************************************
      @description      createData test data records
    **********************************************************************************/
    @testSetup
    static void setup() {
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPMAdminFName',
                                                            'testTPMAdminLName');
        
        //Add email
        adminUser.Email = 'tpmadminuser008@invalidtpm.com';
        //Insert admin user
        insert adminUser;
    }

    /*********************************************************************************
      @description      Call the class to create records for all objects
    **********************************************************************************/
    @isTest
    public static void executeInitialDataLoad(){
        
        // Fetch user details.
        User adminUser = [SELECT Id 
                     FROM User 
                     WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
        
        System.runAs(adminUser) {  

              //Create Set of Org values
        Set<String> org = new Set<String>();
         //Add Org Values
        //Add us01
        org.add(TPM_TestAutomationDataUtility.US01VAL);
        //Add IT01
        org.add(TPM_TestAutomationDataUtility.IT01VAL);

        Test.StartTest();
        TPM_InitialDataLoadForBoObjects.createBoData(org);

        List<cgcloud__BO_API__c> boAPiRecords =  [SELECT id,
                                                         CGCLOUD__SALES_ORG__C 
                                                         FROM cgcloud__BO_API__c 
                                                         WHERE CGCLOUD__SALES_ORG__C IN:org];

         //No of records should be 2
         System.assertEquals(2,boAPiRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

         List<cgcloud__BO_API_Entity__c> boAPiEntityRecords = [SELECT Id,
                                                                      Name
                                                                      FROM cgcloud__BO_API_Entity__c
                                                                      WHERE Name!=NULL
                                                                      WITH SECURITY_ENFORCED];
        
        //No of records should be 15
         System.assertEquals(15,boAPiEntityRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

         List<cgcloud__BO_API_Workflow_Step__c> boAPiWorkflowStepRecords =     [SELECT Id,
                                                                                        Name,
                                                                                        cgcloud__Sales_Org__c
                                                                                        FROM cgcloud__BO_API_Workflow_Step__c
                                                                                        WHERE cgcloud__Sales_Org__c IN:org
                                                                                        WITH SECURITY_ENFORCED];
        
        //No of records should be 58
         System.assertEquals(58,boAPiWorkflowStepRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

         List<cgcloud__BO_API_Step_Input_Structure__c> boAPiWorkflowStepInputRecords =   [SELECT id,
                                                                                                cgcloud__BO_API_Workflow_Step__r.Name,
                                                                                                cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c
                                                                                                FROM cgcloud__BO_API_Step_Input_Structure__c
                                                                                                WHERE cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c IN:org
                                                                                                WITH SECURITY_ENFORCED];
        
        //No of records should be 122
        System.assertEquals(122,boAPiWorkflowStepInputRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        Test.StopTest();
        }
    }

 /*********************************************************************************
      @description      Call the class to create records for all objects
    **********************************************************************************/
    @isTest
    public static void executeInitialDataLoadCon(){
        
        // Fetch user details.
        User adminUser = [SELECT Id 
                     FROM User 
                     WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
        
        System.runAs(adminUser) {  

        //Create Set of Org values
        Set<String> org = new Set<String>();
         //Add Org Values
        //Add us01
        org.add(TPM_TestAutomationDataUtility.US01VAL);
        //Add IT01
        org.add(TPM_TestAutomationDataUtility.IT01VAL);

        Test.StartTest();
        TPM_InitialDataLoadForBoObjects.createBoData(org);

        List<cgcloud__BO_API_Workflow__c> boAPiWorkflowRecords =   [SELECT id,
                                                                            Name,
                                                                            cgcloud__BO_API__r.cgcloud__Sales_Org__c
                                                                            FROM cgcloud__BO_API_Workflow__c 
                                                                            WHERE cgcloud__BO_API__r.cgcloud__Sales_Org__c IN:org
                                                                            WITH SECURITY_ENFORCED];

        //No of records should be 6
        System.assertEquals(6,boAPiWorkflowRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        List<cgcloud__BO_API_Output_Entity__c> boAPiOutputRecords = [SELECT  id,
                                                                        Name
                                                                        FROM cgcloud__BO_API_Output_Entity__c 
                                                                        WHERE Name!=NULL
                                                                        WITH SECURITY_ENFORCED];
        
        //No of records should be 8
        System.assertEquals(8,boAPiOutputRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        List<cgcloud__BO_API_Workflow_Entity__c> boAPiWorkflowEntityRecords =   [SELECT Id, 
                                                                                        Name 
                                                                                        FROM cgcloud__BO_API_Workflow_Entity__c
                                                                                        WHERE Name!=NULL
                                                                                        WITH SECURITY_ENFORCED];

        //No of records should be 18
        System.assertEquals(18,boAPiWorkflowEntityRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        List<cgcloud__BO_API_Workflow_Workflow_Step__c> boAPiWorkflowWorkflowStepRecords =     [ SELECT Id, 
                                                                                                Name, 
                                                                                                cgcloud__BO_API_Workflow__c, 
                                                                                                cgcloud__BO_API_Workflow_Step__c 
                                                                                                FROM cgcloud__BO_API_Workflow_Workflow_Step__c
                                                                                                WHERE Name!=NULL
                                                                                                WITH SECURITY_ENFORCED];

        //No of records should be 74
        System.assertEquals(74,boAPiWorkflowWorkflowStepRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        TPM_InitialDataLoadForBoObjects.createBoData(org);

        List<cgcloud__BO_API_Step_Input_Structure__c> boAPiWorkflowStepInputRecords =   [SELECT id,
                                                                                                cgcloud__BO_API_Workflow_Step__r.Name,
                                                                                                cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c
                                                                                                FROM cgcloud__BO_API_Step_Input_Structure__c
                                                                                                WHERE cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c IN:org
                                                                                                WITH SECURITY_ENFORCED];

            //No of records should be 122
            System.assertEquals(122,boAPiWorkflowStepInputRecords.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        Test.StopTest();
        }
    }
 }