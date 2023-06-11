/*******************************************************************************************************
* @Name         : TPM_AssortmentCreationBatchTest
* @ author       : PwC Team
* @date         : February 6, 2023
* @description  : To test the Batch Class TPM_AssortmentCreationBatch 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_AssortmentCreationBatchTest {
    
    public static final String DISPLAY_MSG = 'Assortment Record Not Created';
    public static final String IT_SALESORG = 'IT01';

    /****************************************************************************
    * @method         : executeTest
    * @description    : To test assortment header creation assignment batch execute method
    ****************************************************************************/
    
    @isTest
    public static void executeTest(){
       
        TPM_TestDataUtility.createProductDataWithTemplate(IT_SALESORG,'Product','Category',60);
        
       cgcloud__Product_Assortment_Template__c prodAssortmenttemplate = TPM_TestDataUtility.createProductAssortmentTemplate('Product',IT_SALESORG);
        insert prodAssortmenttemplate;
        
        cgcloud__Account_Template__c custTemplate = TPM_TestDataUtility.createCustomerTemplate(IT_SALESORG);
        insert custTemplate;
        
         Account superGroupAcc = TPM_TestDataUtility.createAccountWithTemplate('SuperGroup',IT_SALESORG,custTemplate.id);
        insert superGroupAcc;
        
        
        
        //TPM_AssortmentCreationBatch batchObj = new TPM_AssortmentCreationBatch();
        //Call the batch execute method
        //Database.executeBatch(batchObj,200);
        
        String cronexp = '0 0 0 * * ?';
        Test.startTest();
        String jobId = System.schedule('Scheduled Assortment creation batch at :'+system.now(),
                                       cronexp, 
                                       new TPM_AssortmentCreationScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(cronexp, ct.CronExpression, 'True');
        
        
        Test.stopTest();
        
        //Check if assortment got created for the account created above :
        /*List<Account> accountList = [SELECT 	Id,
                                               			Name,
                                              			TPM_Is_Assortment_Created__c
                                               FROM   	Account 
                                               WHERE  	TPM_Hierarchy_Level__c='SuperGroup' LIMIT 1 ];
        System.assertEquals(false,!accountList[0].TPM_Is_Assortment_Created__c ,TPM_AssortmentCreationBatchTest.DISPLAY_MSG);*/
    }

}