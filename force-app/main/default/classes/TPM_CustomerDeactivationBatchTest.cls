/*******************************************************************************************************
* @Name         : TPM_CustomerDeactivationBatchTest
* @author       : PwC Team
* @date         : Jan 25, 2022
* @description  : Test class for batch - 'TPM_CustomerDeactivationBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_CustomerDeactivationBatchTest {
    /************************************************************
    * @method         : createAccountTemplate
    * @description    : To create Account Template test data 
    **************************************************************/
    static void createAccountTemplate(){
        
        String customerStr = 'Customer'; 
        String us01Str = 'US01';
        String accountTemplateStr = 'cgcloud__Account_Template__c';
        
        // Create Customer US01 Basic Template record
        cgcloud__Account_Template__c accountTemplateBasic = new cgcloud__Account_Template__c(Name = 'Basic_US01', 
                                                                                             RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountTemplateStr), 
                                                                                             cgcloud__Sales_Org__c = us01Str, 
                                                                                             cgcloud__Description_Language_1__c = 'Basic_US01', 
                                                                                             cgcloud__Active__c = True, 
                                                                                             cgcloud__Initial_Roles__c = 'customer;payer', 
                                                                                             cgcloud__Available_Product_Level__c = 'SubCategory;Brand;Flavor;Package', 
                                                                                             TPM_CustTemp_PlanMode__c = 'Basic');
        insert accountTemplateBasic;
        
        // Create Customer US01 General Template record
        cgcloud__Account_Template__c accountTemplateGeneral = new cgcloud__Account_Template__c(Name = 'General_US01', 
                                                                                               RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountTemplateStr), 
                                                                                               cgcloud__Sales_Org__c = us01Str, 
                                                                                               cgcloud__Description_Language_1__c = 'General_US01', 
                                                                                               cgcloud__Active__c = True, 
                                                                                               cgcloud__Initial_Roles__c = 'customer;payer', 
                                                                                               cgcloud__Available_Product_Level__c = 'SubCategory;Brand;Flavor;Package', 
                                                                                               TPM_CustTemp_PlanMode__c = 'General');
        insert accountTemplateGeneral;       
    }
   
     /************************************************************
    * @method         : createAccount
    * @description    : To create Account test data 
    **************************************************************/
    static void createAccount(){
        
        String customerStr = 'Customer'; 
        String us01Str = 'US01';
        String accountStr = 'Account';
        // Create account record hierarchy level = Managed Account
        // ParentId field = Empty
        Account accountManagedObjOne = new Account(Name = 'TDC-1 Managed', 
                                                   RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                   cgcloud__Account_Number__c = 'TDC1001', 
                                                   TPM_Hierarchy_Level__c = 'Managed Account', 
                                                   TPM_SAP_Sales_Org__c = us01Str, 
                                                   TPM_Planning_Mode__c = 'Basic');
        insert accountManagedObjOne;
        
        //Get created account record
        List<Account> accountManagedObjOneList = [SELECT  Id,
                                                          Name,
                                                          TPM_Hierarchy_Level__c,
                                                          ParentId
                                                  FROM    Account
                                                  WHERE   Name ='TDC-1 Managed'
                                                  LIMIT   1];
        
        
        // Create account record hierarchy level = Sold-To
        // ParentId field = Managed Account & its Expired 
        Account accountUnManagedObjOne = new Account(Name = 'TDC-2 UnManaged', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC2002', 
                                                     TPM_Hierarchy_Level__c = 'Sold-To', 
                                                     TPM_SAP_Sales_Org__c = us01Str,
                                                     ParentId = accountManagedObjOneList[0].Id);
        insert accountUnManagedObjOne;
               
        // Create account record hierarchy level = Group
        // ParentId field = Empty
        Account accountUnManagedObjTwo = new Account(Name = 'TDC-3 UnManaged', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC3003', 
                                                     TPM_Hierarchy_Level__c = 'Group', 
                                                     TPM_SAP_Sales_Org__c = us01Str, 
                                                     TPM_Planning_Mode__c = '');
        insert accountUnManagedObjTwo;
        
        // Create account record hierarchy level = Total Sales Org
        // ParentId field = Empty
        Account accountUnManagedObjThree = new Account(Name = 'TDC-4 UnManaged', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC4004', 
                                                     TPM_Hierarchy_Level__c = 'Total Sales Org', 
                                                     TPM_SAP_Sales_Org__c = us01Str, 
                                                     TPM_Planning_Mode__c = '');
        insert accountUnManagedObjThree;  
        
        // Create account record hierarchy level = SuperGroup
        // ParentId field = Empty
        // And with Planning Mode as Basic - To make it as Invalid Account Record
        Account accountUnManagedObjFour = new Account(Name = 'TDC-5 UnManaged', 
                                                     RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountStr), 
                                                     cgcloud__Account_Number__c = 'TDC5005', 
                                                     TPM_Hierarchy_Level__c = 'SuperGroup', 
                                                     TPM_SAP_Sales_Org__c = us01Str, 
                                                     TPM_Planning_Mode__c = 'Basic');
        insert accountUnManagedObjFour;
    }
    
    /***********************************************************************
    * @method         : createCustomerExtension
    * @description    : To create customer extension record test data. 
    ************************************************************************/
    static void createCustomerExtension(){
        //Get created account record WHERE Hierarchy Level = Managed Account
        List<Account> accountManagedObjOneList = [SELECT  Id,
                                                          Name,
                                                          TPM_Hierarchy_Level__c,
                                                          ParentId,
                                                          cgcloud__ExternalId__c
                                                  FROM    Account
                                                  WHERE   Name ='TDC-1 Managed'
                                                  LIMIT   1];
        
        //Get created account record WHERE Hierarchy Level = Sold-To
        List<Account> accountUnManagedObjOneList =[SELECT  Id,
                                                           Name,
                                                           TPM_Hierarchy_Level__c,
                                                           ParentId,
                                                   		   cgcloud__ExternalId__c
                                                   FROM    Account
                                                   WHERE   Name ='TDC-2 UnManaged'
                                                   LIMIT   1];
        
        //Get created account record WHERE Hierarchy Level = Super Group
        List<Account> accountUnManagedObjTwoList =[SELECT  Id,
                                                           Name,
                                                           TPM_Hierarchy_Level__c,
                                                           ParentId,
                                                   		   cgcloud__ExternalId__c
                                                   FROM    Account
                                                   WHERE   Name ='TDC-5 UnManaged'
                                                   LIMIT   1];
        
        //Get created account record WHERE Hierarchy Level = Total Sales Org
        List<Account> accountUnManagedObjThreeList =[SELECT  Id,
                                                             Name,
                                                             TPM_Hierarchy_Level__c,
                                                             ParentId,
                                                             cgcloud__ExternalId__c
                                                     FROM    Account
                                                     WHERE   Name ='TDC-4 UnManaged'
                                                     LIMIT   1];
        
        //Create one Customer Extension record
        cgcloud__Account_Extension__c custExeOne = new cgcloud__Account_Extension__c();
        custExeOne.cgcloud__Account__c = accountManagedObjOneList[0].Id;
        custExeOne.cgcloud__Customer_Id__c = accountManagedObjOneList[0].cgcloud__ExternalId__c;
        custExeOne.cgcloud__State__c = TPM_ConstantsUtility.ACTIVE_CODE;
        
        insert custExeOne;
        
        //Create one Customer Extension record
        cgcloud__Account_Extension__c custExeTwo = new cgcloud__Account_Extension__c();
        custExeTwo.cgcloud__Account__c = accountUnManagedObjOneList[0].Id;
        custExeTwo.cgcloud__Customer_Id__c = accountUnManagedObjOneList[0].cgcloud__ExternalId__c;
        custExeTwo.cgcloud__State__c = TPM_ConstantsUtility.ACTIVE_CODE;
        
        insert custExeTwo;
        
        //Create one Customer Extension record
        cgcloud__Account_Extension__c custExeThree = new cgcloud__Account_Extension__c();
        custExeThree.cgcloud__Account__c = accountUnManagedObjTwoList[0].Id;
        custExeThree.cgcloud__Customer_Id__c = accountUnManagedObjTwoList[0].cgcloud__ExternalId__c;
        custExeThree.cgcloud__State__c = TPM_ConstantsUtility.ACTIVE_CODE;
        
        insert custExeThree; 
        
        //Create one Customer Extension record
        cgcloud__Account_Extension__c custExeFour = new cgcloud__Account_Extension__c();
        custExeFour.cgcloud__Account__c = accountUnManagedObjThreeList[0].Id;
        custExeFour.cgcloud__Customer_Id__c = accountUnManagedObjThreeList[0].cgcloud__ExternalId__c;
        custExeFour.cgcloud__State__c = TPM_ConstantsUtility.ACTIVE_CODE;
        
        insert custExeFour;
    }
    
    /***********************************************************************
    * @method         : createCTORecords
    * @description    : To create customer trade org hierarchy test data 
    ************************************************************************/
    static void createCTORecords(){
        //Get created account record WHERE Hierarchy Level = Managed Account
        List<Account> accountManagedObjOneList = [SELECT  Id,
                                                          Name,
                                                          TPM_Hierarchy_Level__c,
                                                          ParentId
                                                  FROM    Account
                                                  WHERE   Name ='TDC-1 Managed'
                                                  LIMIT   1];
        
        //Get created account record WHERE Hierarchy Level = Group
        List<Account> accountUnManagedObjTwoList =[SELECT  Id,
                                                           Name,
                                                           TPM_Hierarchy_Level__c,
                                                           ParentId
                                                   FROM    Account
                                                   WHERE   Name ='TDC-3 UnManaged'
                                                   LIMIT   1];
        
        //Get created account record WHERE Hierarchy Level = Sold-To
        List<Account> accountUnManagedObjOneList =[SELECT  Id,
                                                           Name,
                                                           TPM_Hierarchy_Level__c,
                                                           ParentId
                                                   FROM    Account
                                                   WHERE   Name ='TDC-2 UnManaged'
                                                   LIMIT   1];
        
        //Get created account record WHERE hierarchy level = Total Sales Org
        List<Account> accountUnManagedObjThreeList =[SELECT  Id,
                                                           Name,
                                                           TPM_Hierarchy_Level__c,
                                                           ParentId
                                                   FROM    Account
                                                   WHERE   Name ='TDC-4 UnManaged'
                                                   LIMIT   1];
        
        //Get created account record WHERE hierarchy level = SuperGroup
        List<Account> accountUnManagedObjFourList =[SELECT  Id,
                                                           Name,
                                                           TPM_Hierarchy_Level__c,
                                                           ParentId
                                                   FROM    Account
                                                   WHERE   Name ='TDC-5 UnManaged'
                                                   LIMIT   1];
        
        //Create customer trade org hierarchy records
        //Parent Account = Group & Child Account = Managed Account & Valid Record
        cgcloud__Account_Trade_Org_Hierarchy__c ctoObjOne = new cgcloud__Account_Trade_Org_Hierarchy__c(cgcloud__Parent_Account__c = accountUnManagedObjTwoList[0].Id,
                                                                                                        cgcloud__Child_Account__c = accountManagedObjOneList[0].Id,
                                                                                                        cgcloud__Valid_From__c = System.today()-1,
                                                                                                        cgcloud__Valid_Thru__c = date.newInstance(2099, 2, 17));
        
        insert ctoObjOne;
        
        //Create customer trade org hierarchy records
        //Parent Account = Managed Account & Child Account = Sold-To & Expired Record
        cgcloud__Account_Trade_Org_Hierarchy__c ctoObjTwo = new cgcloud__Account_Trade_Org_Hierarchy__c(cgcloud__Parent_Account__c = accountManagedObjOneList[0].Id,
                                                                                                        cgcloud__Child_Account__c = accountUnManagedObjOneList[0].Id,
                                                                                                        cgcloud__Valid_From__c = date.newInstance(2010, 2, 17),
                                                                                                        cgcloud__Valid_Thru__c = System.today()-2);
        
        insert ctoObjTwo;  
        
        //Create customer trade org hierarchy records
        //Parent Account = Total Sales Org & Child Account = SuperGroup & Valid Record
        cgcloud__Account_Trade_Org_Hierarchy__c ctoObjThree = new cgcloud__Account_Trade_Org_Hierarchy__c(cgcloud__Parent_Account__c = accountUnManagedObjThreeList[0].Id,
                                                                                                        cgcloud__Child_Account__c = accountUnManagedObjFourList[0].Id,
                                                                                                        cgcloud__Valid_From__c = System.today()-1,
                                                                                                        cgcloud__Valid_Thru__c = date.newInstance(2099, 2, 17));
        
        insert ctoObjThree;   
    }
    
    /******************************************
    * @method         : setup
    * @description    : To create test data 
    *******************************************/
    @testSetup
    static void setup() {
            // Call createAccountTemplate to create Customer Template Test Data.
            createAccountTemplate();
            
			// Call createAccount to create Customer Test Data.
            createAccount();
			
            // Call createCustomerExtension to create Customer Extension Test Data
            createCustomerExtension();
            
            // Call createCTORecords to create Customer Trade Org Hierarchy Test Data.
            createCTORecords();
    }
    
    /********************************************************************
    * @method         : customerDeactivationBatchTest
    * @description    : To test customer deactivation batch class
    *********************************************************************/
    @isTest static void customerDeactivationBatchTest(){
        
        Test.startTest();
        // Instantiate the batch.
        TPM_CustomerTemplateAssignmentBatch  templateAssignBatch = new TPM_CustomerTemplateAssignmentBatch(null);
        Database.executeBatch(templateAssignBatch, 200);
        Test.stopTest();
        
        // Get the Account Record 
        // At Level = SuperGroup
        // which is a Invalid Record 
        List<Account> accList = [SELECT  Id, 
                                         ParentId,
                                         TPM_Hierarchy_Level__c,
                                         TPM_IsActive__c
                                 FROM    Account 
                                 WHERE   Name = 'TDC-5 UnManaged' 
                                 LIMIT   1];
        
        System.assertEquals(true,!accList.isEmpty(),'Account List is Empty');
        System.assertEquals(false, accList[0].TPM_IsActive__c, 'Customer is not deactivated');
    }

}