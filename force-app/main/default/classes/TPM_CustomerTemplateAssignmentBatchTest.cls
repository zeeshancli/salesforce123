/*******************************************************************************************************
* @Name         : TPM_CustomerTemplateAssignmentBatchTest
* @author       : PwC Team
* @date         : December 9, 2022
* @description  : Test class for batch - 'TPM_CustomerTemplateAssignmentBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_CustomerTemplateAssignmentBatchTest {
    
    /*********************************************************
    * @method         : createCustomerTemplate
    * @description    : To create customer template test data 
    **********************************************************/
    static void createCustomerTemplate() {
        
        String customerStr = 'Customer'; 
        String us01Str = 'US01';
        String accountTemplateStr = 'cgcloud__Account_Template__c';
        
        // Create Customer Template records.
        cgcloud__Account_Template__c accountTemplateBasic = new cgcloud__Account_Template__c(Name = 'Basic_US01', 
                                                                                             RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountTemplateStr), 
                                                                                             cgcloud__Sales_Org__c = us01Str, 
                                                                                             cgcloud__Description_Language_1__c = 'Basic_US01', 
                                                                                             cgcloud__Active__c = True, 
                                                                                             cgcloud__Initial_Roles__c = 'customer;payer', 
                                                                                             cgcloud__Available_Product_Level__c = 'SubCategory;Brand;Flavor;Package', 
                                                                                             TPM_CustTemp_PlanMode__c = 'Basic');
        insert accountTemplateBasic;
        
        // Create Customer Template records.
        cgcloud__Account_Template__c accountTemplateInter = new cgcloud__Account_Template__c(Name = 'Intermediate_US01', 
                                                                                             RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountTemplateStr), 
                                                                                             cgcloud__Sales_Org__c = us01Str, 
                                                                                             cgcloud__Description_Language_1__c = 'Intermediate_US01', 
                                                                                             cgcloud__Active__c = True, 
                                                                                             cgcloud__Initial_Roles__c = 'customer;payer', 
                                                                                             cgcloud__Available_Product_Level__c = 'SubCategory;Brand;Flavor;Package', 
                                                                                             TPM_CustTemp_PlanMode__c = 'Intermediate');
        insert accountTemplateInter;
        
        // Create Customer Template records.
        cgcloud__Account_Template__c accountTemplateGeneral = new cgcloud__Account_Template__c(Name = 'General_IT01', 
                                                                                               RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountTemplateStr), 
                                                                                               cgcloud__Sales_Org__c = 'IT01', 
                                                                                               cgcloud__Description_Language_1__c = 'General_IT01', 
                                                                                               cgcloud__Active__c = True, 
                                                                                               cgcloud__Initial_Roles__c = 'customer;payer', 
                                                                                               cgcloud__Available_Product_Level__c = 'SubCategory;Brand;Flavor;Package', 
                                                                                               TPM_CustTemp_PlanMode__c = 'General');
        insert accountTemplateGeneral;        
    }
    
    /*********************************************************
    * @method         : createAccount
    * @description    : To create customer test data 
    **********************************************************/
    static void createAccount(){
        
        String customerStr = 'Customer'; 
        String us01Str = 'US01';
        String accountStr = 'Account';
        String managedAccount ='Managed Account';
        
        // Create account record.
        Account accountManagedObjOne = new Account(Name = 'TDC-1 Managed', 
                                                   RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                   cgcloud__Account_Number__c = 'TDC1001', 
                                                   TPM_Hierarchy_Level__c = managedAccount, 
                                                   TPM_SAP_Sales_Org__c = us01Str, 
                                                   TPM_Planning_Mode__c = 'Basic');
        insert accountManagedObjOne;
        
        // Create account record.
        Account accountManagedObjTwo = new Account(Name = 'TDC-2 Managed', 
                                                   RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                   cgcloud__Account_Number__c = 'TDC2002', 
                                                   TPM_Hierarchy_Level__c = managedAccount, 
                                                   TPM_SAP_Sales_Org__c = us01Str, 
                                                   TPM_Planning_Mode__c = 'Intermediate');
        insert accountManagedObjTwo;
        
        // Create account record.
        Account accountUnManagedObjOne = new Account(Name = 'TDC-3 UnManaged', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC3003', 
                                                     TPM_Hierarchy_Level__c = 'Group', 
                                                     TPM_SAP_Sales_Org__c = us01Str, 
                                                     TPM_Planning_Mode__c = '');
        insert accountUnManagedObjOne;
        
        // Create account record.
        Account accountUnManagedObjTwo = new Account(Name = 'TDC-4 UnManaged', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC4004', 
                                                     TPM_Hierarchy_Level__c = 'Sold-To', 
                                                     TPM_SAP_Sales_Org__c = 'IT01', 
                                                     TPM_Planning_Mode__c = '');
        insert accountUnManagedObjTwo;
        
        // Create account record with SAP External Id for Managed Account
        Account accountManagedObjThree = new Account(Name = 'TDC-5 Managed', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC5005', 
                                                     TPM_Hierarchy_Level__c = managedAccount, 
                                                     TPM_SAP_Sales_Org__c = 'IT01', 
                                                     TPM_Planning_Mode__c = 'Basic',
                                                     TPM_SAP_External_ID__c = 'TDC5005_IT01_TDC');
        insert accountManagedObjThree;
        
        // Create account record with SAP External Id for UnManaged Account
        Account accountUnManagedObjThree = new Account(Name = 'TDC-6 UnManaged', 
                                                       RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                       cgcloud__Account_Number__c = 'TDC6006', 
                                                       TPM_Hierarchy_Level__c = '	SuperGroup', 
                                                       TPM_SAP_Sales_Org__c = us01Str, 
                                                       TPM_Planning_Mode__c = '',
                                                       TPM_SAP_External_ID__c = 'TDC6006_US01_TDC');
        insert accountUnManagedObjThree;
    }
    
    /*******************************************
    * @method         : setup
    * @description    : To create test data 
    ********************************************/
    @testSetup
    static void setup() {
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPMAdminFName',
                                                            'testTPMAdminLName');

        adminUser.Email = 'tpmadminuser0001@invalidtpm.com';
        insert adminUser;

        System.runAs(adminUser) {    
            
            // Call createCustomerTemplate to create Template test data.
            createCustomerTemplate();
            
            // Call createAccount to create Account test data.
            createAccount();  
        }
    }
    
    /********************************************************************
    * @method         : testCustomerTemplateAssignment
    * @description    : To test customer template assignment 
    *********************************************************************/
    @isTest static void testCustomerTemplateAssignment(){
        
        User batchUser = new User();
        
        // Fetch user details.
        batchUser = [SELECT Id 
                     FROM   User 
                     WHERE  Email = 'tpmadminuser0001@invalidtpm.com' LIMIT 1];
        
        // Run the code as batch user.
        System.runAs(batchUser){
            
            test.startTest();
            
            // Instantiate the batch.
            TPM_CustomerTemplateAssignmentBatch  templateAssignBatch = new TPM_CustomerTemplateAssignmentBatch(null);
            
            // Execute the batch.
            Database.executeBatch(templateAssignBatch, 200);
            
            test.stopTest();
            
            // Fetch assigned customer template for managed account record detail.
            String accTemplateId = [SELECT Id, 
                                           cgcloud__Account_Template__c 
                                    FROM   Account 
                                    WHERE  Name = 'TDC-1 Managed' LIMIT 1]?.cgcloud__Account_Template__c;
            
            String custTemplateId = [SELECT Id  
                                     FROM   cgcloud__Account_Template__c 
                                     WHERE  Name = 'Basic_US01' LIMIT 1]?.Id;
            
            System.assertEquals(custTemplateId, accTemplateId, 'Issue with customer template');
        }
    }
    
    /********************************************************************
    * @method         : testParameterizedConstructor
    * @description    : To test parameterized constructor of batch 
    *********************************************************************/
    @isTest static void testParameterizedConstructor(){
        
        User batchUser = new User();
        
        // Fetch user details.
        batchUser = [SELECT Id 
                     FROM   User 
                     WHERE  Email = 'tpmadminuser0001@invalidtpm.com' LIMIT 1];
        
        // Run the code as batch user.
        System.runAs(batchUser){
            
            test.startTest();
            
            String actId = [SELECT Id 
                            FROM   Account 
                            WHERE  Name = 'TDC-3 UnManaged' LIMIT 1]?.Id;
            
            // Instantiate the batch.
            TPM_CustomerTemplateAssignmentBatch  templateAssignBatch = new TPM_CustomerTemplateAssignmentBatch(new Set<Id>{actId});
            
            // Execute the batch.
            Database.executeBatch(templateAssignBatch, 200);
            
            test.stopTest();
            
            // Fetch assigned customer template for non-managed account record detail.
            String accTemplateId = [SELECT Id, 
                                    	   cgcloud__Account_Template__c 
                                    FROM   Account 
                                    WHERE  Name = 'TDC-3 UnManaged' LIMIT 1]?.cgcloud__Account_Template__c;
            
            System.assertEquals(null, accTemplateId, 'Customer template assignment mistmatch');
        }
    }
    
    /********************************************************************
    * @method         : testCGCloudExternalIDAssignment
    * @description    : To test cgcloudExternalId is getting assigned
    based on SAP External Id or not
    *********************************************************************/
    @isTest static void testCGCloudExternalIDAssignment(){
        
        User batchUser = new User();
        
        // Fetch user details.
        batchUser = [SELECT Id 
                     FROM   User 
                     WHERE  Email = 'tpmadminuser0001@invalidtpm.com' LIMIT 1];
        
        // Run the code as batch user.
        System.runAs(batchUser){
            
            test.startTest();
            
            // Instantiate the batch.
            TPM_CustomerTemplateAssignmentBatch  templateAssignBatch = new TPM_CustomerTemplateAssignmentBatch(null);
            
            // Execute the batch.
            Database.executeBatch(templateAssignBatch, 200);
            
            test.stopTest();
            
            //Check whether cgcloud__ExternalId__c is assigned or not
            String cgExternalIdManagedAC =[SELECT Id,
                                           		  Name,
                                           		  cgcloud__ExternalId__c 
                                           FROM   Account 
                                           WHERE  Name = 'TDC-5 Managed' LIMIT 1]?.cgcloud__ExternalId__c;
            
            //Check whether cgcloud__ExternalId__c is assigned or not for Managed Account
            System.assertEquals('TDC5005_IT01_TDC_Ba', cgExternalIdManagedAC, 'CG External Id is not assigned for Managed Account');
            
            String cgExternalIdUnManagedAC =[SELECT Id,
                                                    Name,
                                                    cgcloud__ExternalId__c 
                                             FROM 	Account 
                                             WHERE  Name = 'TDC-6 UnManaged' LIMIT 1]?.cgcloud__ExternalId__c;
            
            //Check whether cgcloud__ExternalId__c is assigned or not for UnManaged Account
            System.assertEquals('TDC6006_US01_TDC', cgExternalIdUnManagedAC, 'CG External Id is not assigned for UnManaged Account');
        }  
    }
}
