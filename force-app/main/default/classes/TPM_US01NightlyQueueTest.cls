/*******************************************************************************************************
* @Name         : TPM_US01NightlyQueueTest
* @author       : PwC Team
* @date         : April 11, 2023
* @description  : Test class for Queue - 'TPM_US01NightlyQueue'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_US01NightlyQueueTest {
    
     static String assertStr = 'Queue Class could not execute';

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
        
        cgcloud__Account_Template__c accountTemplateBasic = [SELECT Id,
                                                               		  Name
                                                               FROM   cgcloud__Account_Template__c
                                                               WHERE  Name = 'Basic_US01'];
        
        cgcloud__Account_Template__c accountTemplateInter = [SELECT Id,
                                                               		  Name
                                                               FROM   cgcloud__Account_Template__c
                                                               WHERE  Name = 'Intermediate_US01'];
        // Create account record.
        Account accountManagedObjOne = new Account(Name = 'TDC-1 Managed', 
                                                   RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                   cgcloud__Account_Number__c = 'TDC1001', 
                                                   TPM_Hierarchy_Level__c = managedAccount, 
                                                   TPM_SAP_Sales_Org__c = us01Str, 
                                                   TPM_Planning_Mode__c = 'Basic',
                                                   TPM_SAP_External_ID__c = 'TDC1001_US01_TDC',
                                                   cgcloud__Account_Template__c = accountTemplateBasic.Id );
        insert accountManagedObjOne;
        
        // Create account record.
        Account accountManagedObjTwo = new Account(Name = 'TDC-2 Managed', 
                                                   RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                   cgcloud__Account_Number__c = 'TDC2002', 
                                                   TPM_Hierarchy_Level__c = managedAccount, 
                                                   TPM_SAP_Sales_Org__c = us01Str, 
                                                   TPM_Planning_Mode__c = 'Intermediate',
                                                   TPM_SAP_External_ID__c = 'TDC2002_US01_TDC',
                                                   cgcloud__Account_Template__c = accountTemplateInter.Id);
        insert accountManagedObjTwo; 
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
    * @method         : us01NightlyQueue
    * @description    : To test US01 Nightly Queue Class 
    *********************************************************************/
    @isTest static void us01NightlyQueue(){
        
        // Instantiate the Queue.
        TPM_US01NightlyQueue  us01NightlyQueueObj = new TPM_US01NightlyQueue();

        test.startTest();
        
        // Execute the Queue.
		Test.setMock(HttpCalloutMock.class, new TPM_HttpMockGenerator());
        Id jobId = System.enqueueJob(us01NightlyQueueObj);
		System.assertNotEquals(null, jobId, assertStr);
        test.stopTest();
    }

}