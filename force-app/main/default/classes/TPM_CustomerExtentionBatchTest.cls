/*******************************************************************************************************
* @Name          TPM_CustomerExtentionBatchTest
* @Author        PwC Team
* @date          December 9, 2022
* @description   Test class for batch - 'TPM_CustomerExtentionBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_CustomerExtentionBatchTest {

    /********************************************************************************
      @description      createData test method to run batch for dummy records.
    *********************************************************************************/
    @testSetup static void createData() {
        Id vendorAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Id customerAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		List<Account> accounts = TPM_TestDataUtility.createAccounts(4);
        
        accounts[0].RecordTypeId = customerAccRecordTypeId;
        accounts[1].RecordTypeId = customerAccRecordTypeId;
        accounts[2].RecordTypeId = vendorAccRecordTypeId;
        
        accounts[0].TPM_Hierarchy_Level__c = 'SuperGroup';
        accounts[1].TPM_Hierarchy_Level__c = 'Managed Account';
        accounts[2].TPM_Hierarchy_Level__c = 'Group';
        
        insert accounts;

        System.assertEquals(accounts.size()>0, true, 'createData');        
    }
    
    /*********************************************************************************
      @description     testCustomerExtensionCreations method to test positive Batch scenarios to fetch the account records and create extensions.
    **********************************************************************************/
    @isTest static void testCustomerExtensionCreations() {
        List<Account> accounts = [SELECT Id, Name, RecordType.DeveloperName, cgcloud__Account_Number__c, TPM_Hierarchy_Level__c FROM Account WHERE TPM_Hierarchy_Level__c != 'Sold-To' LIMIT 10];
        System.assertEquals(accounts.size()>0, true, 'testCustomerExtensionCreations');

        String cronexp = '0 0 0 * * ?';
        Test.startTest();
        String jobId = System.schedule('Scheduled Customer Extention batch at :'+system.now(),
                                       cronexp, 
                                       new TPM_CustomerExtentionScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(cronexp, ct.CronExpression, 'True');        
             
        Test.stopTest();
    }
    /******************************************
	* @method         : testLoggerExceptions
	* @description    : To test the exceptions 
	********************************************/
	@isTest
    static void testLoggerExceptions(){
        
        //Invoke the Exception Creation methods of TPM_Utils
        Test.startTest();
        
        //Invoke TPM_Utils.createException
        TPM_Utils.createException(null,TPM_ConstantsUtility.FATAL,'TestClass');
        List<TPM_Logger__c> loggerList = [SELECT Id, 
                                          		 Name, 
                                          		 TPM_LogLevel__c, 
                                             	 TPM_ClassName__c 
                                          FROM   TPM_Logger__c
                                          WHERE  TPM_LogLevel__c =: TPM_ConstantsUtility.FATAL
                                          LIMIT   1];
        
        //Verify records inserted or not
        System.assertEquals(false, loggerList.isEmpty(), 'No Log Record Inserted');
        
        //Invoke TPM_Utils.createException
       TPM_Utils.LogParamWrapper logParamObj = TPM_Utils.createLogParamWrapper(null,TPM_ConstantsUtility.BATCH_CUSTOMEREXTENSION_ASSIGNMENT,null);
       
        
        //Verify records inserted or not
        System.assertEquals(true, logParamObj != NULL, 'No Exception Record Inserted');
        Test.stopTest();
    } 
}