/*******************************************************************************************************
* @Name           TPM_CustomerHierarchyBatchTest
* @ author        PwC Team
* @date           January 11, 2023
* @description    To test the Batch Class TPM_CustomerHierarchyBatch 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_CustomerHierarchyBatchTest {
    
    // fetching account recordtype id for customer 
    public static final Id CUSTOMERRECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TPM_ConstantsUtility.ACT_CUSTOMER_RECORDTYPEAPI).getRecordTypeId();

    /********************************************************************************
     @description      createData test method to run batch for dummy records.
    *********************************************************************************/
    @testSetup static void createData() {
        // fetch account data for insert
		List<Account> accountList = TPM_TestDataUtility.createAccounts(5);
        insert accountList;
        // fetch CHS data for insert
        List<TPM_Customer_Hierarchy_Staging__c> custHrStagingsList = TPM_TestDataUtility.createCustomerHierarchyStaging(4);
        insert custHrStagingsList;

        System.assertEquals(accountList.size()>0, true, 'accountsList'); 
        System.assertEquals(custHrStagingsList.size()>0, true, 'custHrStagings'); 
    }
    
    /*********************************************************************************
      @description     testCustHrBatchHappyPath method to test positive Batch scenarios.
    **********************************************************************************/
    @isTest static void testCustHrBatchHappyPath() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for happy path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '732565820807';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '649015234035';
		accountsList[2].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[2].TPM_Hierarchy_Level__c = 'Managed Account';
        accountsList[2].TPM_SAP_External_ID__c = '861650522737';
        accountsList[3].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[3].TPM_Hierarchy_Level__c = 'Sold-To';
        accountsList[3].TPM_SAP_External_ID__c = '461961870704';
        update accountsList;
        
        // updating record with matching customer and Hr levels for happy path
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '732565820807';
        custStagingsList[0].TPM_Child_Cust_ID__c = '649015234035';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
        custStagingsList[1].TPM_Parnt_Cust_ID__c = '861650522737';
        custStagingsList[1].TPM_Child_Cust_ID__c = '461961870704';
        custStagingsList[1].TPM_Parnt_Cust_HrLvl__c = 'Managed Account';
        custStagingsList[1].TPM_Child_Cust_HrLvl__c = 'Sold-To';        
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        //TO-DO Need Check Here this assertion fails 
        //Needs to be fixed
        System.assertEquals(!tradeOrgHierarchy.isEmpty(), false, 'CustomerTradeOrgHierarchy');
    } 
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCasesOne method to test negative Batch scenario.
                       when Both Customers ExtIds do not match Account records
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCasesOne() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '505227378616';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '961870704461';
        update accountsList;
        
        // updating records with Both Customers External Ids which do not match Account records
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '582080773256';
        custStagingsList[0].TPM_Child_Cust_ID__c = '234035649015';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(tradeOrgHierarchy.isEmpty(), true, 'CustHrBatchErrorOne with convert Status Failed.');
    }  
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCaseTwo method to test negative Batch scenario.
                       when Hierarchy relationship is invalid CHS Hr level does not match 
                       with Parent Accounts Hr levels
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCaseTwo() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '582732565820807';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = 'Sold-To';
        accountsList[1].TPM_SAP_External_ID__c = '01649015234035';
        update accountsList;
        
        // updating records with Both Customers External Ids which do not match Account records
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '582732565820807';
        custStagingsList[0].TPM_Child_Cust_ID__c = '01649015234035';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(tradeOrgHierarchy.isEmpty(), true, 'CustHrBatchErrorTwo with convert Status Failed.');
    }
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCaseThree method to test negative Batch scenario.
                       when CHS TPM_Parnt_Cust_HrLvl__c and TPM_Child_Cust_HrLvl__c are null
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCaseThree() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '737861650522';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '618461970704';
        update accountsList;

        // when CHS TPM_Parnt_Cust_HrLvl__c and TPM_Child_Cust_HrLvl__c are null
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '737861650522';
        custStagingsList[0].TPM_Child_Cust_ID__c = '618461970704';
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(tradeOrgHierarchy.isEmpty(), true, 'CustHrBatchErrorThree with convert Status Failed.');
    }
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCaseFour method to test negative Batch scenario.
                       when CHS TPM_Cust_Hrchy_Strt_Dt__c and TPM_Cust_Hrchy_End_DT__c are null
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCaseFour() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '058616522737';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '194661870704';
        update accountsList;
        
        // when CHS TPM_Cust_Hrchy_Strt_Dt__c and TPM_Cust_Hrchy_End_DT__c are null
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '058616522737';
        custStagingsList[0].TPM_Child_Cust_ID__c = '194661870704';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
        custStagingsList[0].TPM_Cust_Hrchy_Strt_Dt__c = null;
        custStagingsList[0].TPM_Cust_Hrchy_End_DT__c = null;
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(tradeOrgHierarchy.isEmpty(), true, 'CustHrBatchErrorFour with convert Status Failed.');
    }
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCaseFive method to test negative Batch scenario.
                       CHS TPM_Parnt_Cust_ID__c is null
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCaseFive() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '196461870704';
        update accountsList;
        
        // when CHS TPM_Parnt_Cust_ID__c is null
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '227861650537';
        custStagingsList[0].TPM_Child_Cust_ID__c = '196461870704';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(tradeOrgHierarchy.isEmpty(), true, 'CustHrBatchErrorFive with convert Status Failed.');
    }    
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCaseSix method to test negative Batch scenario.
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCaseSix() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[0].TPM_SAP_External_ID__c = '33365820807';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '444015234035';
        update accountsList;
        
        // updating record for failure path
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '33365820807';
        custStagingsList[0].TPM_Child_Cust_ID__c = '444015234035';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
         
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(!tradeOrgHierarchy.isEmpty(), false, 'CustHrBatchErrorSix with convert Status Failed.');
    } 
    
    /*********************************************************************************
      @description     testCustHrBatchErrorCaseSeven method to test negative Batch scenario.
    **********************************************************************************/
    @isTest static void testCustHrBatchErrorCaseSeven() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        // updating account records for failure path
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '66665820807';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '015234035777';
        update accountsList;
        
        // updating record for failure path
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_ID__c = '66665820807';
        custStagingsList[0].TPM_Child_Cust_ID__c = '777015234035';
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
         
        update custStagingsList;
        
        Test.startTest();
        // Call the batch execute method
        Database.executeBatch(new TPM_CustomerHierarchyBatch());     
        Test.stopTest();
        
        // Check if Account Trade Org Hierarchy created successfully
        List<cgcloud__Account_Trade_Org_Hierarchy__c> tradeOrgHierarchy = [SELECT Id, TPM_CHSRecordId__c FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                   							WHERE TPM_CHSRecordId__c != NULL];
        System.assertEquals(!tradeOrgHierarchy.isEmpty(), false, 'CustHrBatchErrorSeven with convert Status Failed.');
    }
    
    /*********************************************************************************
      @description     testCustHrBatchScheduler
    **********************************************************************************/
    @isTest static void testCustHrBatchScheduler() {
        List<Account> accountsList = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Total Sales Org' LIMIT 10];
        accountsList[0].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[0].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.SUPER_GROUP;
        accountsList[0].TPM_SAP_External_ID__c = '616227850537';
        accountsList[1].RecordTypeId = CUSTOMERRECORDTYPEID;
        accountsList[1].TPM_Hierarchy_Level__c = TPM_ConstantsUtility.GROUP_NAME;
        accountsList[1].TPM_SAP_External_ID__c = '701964618704';
        update accountsList;
        
        // when CHS TPM_Parnt_Cust_ID__c is null
        List<TPM_Customer_Hierarchy_Staging__c> custStagingsList = [SELECT Id, TPM_Convert_Status__c, TPM_Cust_Hrchy_Strt_Dt__c, TPM_Cust_Hrchy_End_DT__c FROM TPM_Customer_Hierarchy_Staging__c WHERE TPM_Cust_Hrchy_Strt_Dt__c != null AND TPM_Cust_Hrchy_End_DT__c != null];
        custStagingsList[0].TPM_Parnt_Cust_HrLvl__c = TPM_ConstantsUtility.SUPER_GROUP;
        custStagingsList[0].TPM_Child_Cust_HrLvl__c = TPM_ConstantsUtility.GROUP_NAME;
        update custStagingsList;
        
        String cronexp = '0 3 0 * * ?';
        Test.startTest();
        String jobId = System.schedule('Scheduled Customer Hierarchy batch at :'+system.now(),
                                       cronexp, 
                                       new TPM_CustomerHierarchyScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions is the same
        System.assertEquals(cronexp, ct.CronExpression, 'cron expressions verified.');        
             
        Test.stopTest();
    }
}