/*******************************************************************************************************
* @Name         : TPM_ApprovalComponentControllerTest
* @Unit Test    : TPM_ApprovalComponentControllerTest
* @Author       : PwC Team
* @Date         : 28/04/2023
* @description  : Test Class for the lwc component
				  tpmApprovalCardComponent
*******************************************************************************************************/
@isTest
public class TPM_ApprovalComponentControllerTest {
    
    static String assertStr = 'List should not be empty';
    
     /*****************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Test Setup method for TPM_ApprovalComponentController Class
    *****************************************************************************************/
    @testSetup
    public static void createTestData(){
        
        // Create Sales Profile Record
        String salesProfileId = TPM_TestDataUtility.getProfileId('Sales Profile');
        
        // Create a Sales Profile User Record
        User testSalesProfileUser = TPM_TestDataUtility.createTestUser(salesProfileId,'Test Sales','Profile User');
        insert testSalesProfileUser;
        
        // Create Customer Template
        cgcloud__Account_Template__c accountTemplate = TPM_TestDataUtility.createCustomerTemplate('US01');
		insert accountTemplate;
        
        // Create Account
        Account accRecord = TPM_TestDataUtility.createAccountWithTemplate('Managed Account','US01',accountTemplate.Id);
        insert accRecord;
        
        // Create Promotion Template
        cgcloud__Promotion_Template__c promotionTemplateUS01 = TPM_TestDataUtilityExtension.createPromotionTemplate();
        insert promotionTemplateUS01;
        
        // Create Promotion Record
        cgcloud__Promotion__c promotionRecord = TPM_TestDataUtilityExtension.createPromotionWithPhase(accRecord.Id,promotionTemplateUS01.Id,'Planning');
        insert promotionRecord;
        
        // Update the Promotion Record
        // Status to Submitted for Approval
        promotionRecord.TPM_Phase__c = 'Submitted For Approval';
        update promotionRecord;
        
        // Create Approval Record
        TPM_Approval__c approvalObj = new TPM_Approval__c();
        approvalObj.TPM_Promotion__c =  promotionRecord.Id;
        approvalObj.TPM_Promotion_Submitter__c = testSalesProfileUser.Id;
        approvalObj.OwnerId = testSalesProfileUser.Id;
        insert approvalObj;
        
    }
    
    /******************************************************************************************
    * @method			tpmApprovalCardComponentTest
    * @ return     		void
    * @param   		  
    * @description    	Test Method for TPM_ApprovalCardComponent Class
    * 					getPromotionRelatedApprovals()
    ******************************************************************************************/
    @isTest
    public static void tpmApprovalCardComponentTest(){
        
        // Get the created Promotion Record
        List<cgcloud__Promotion__c> promotionRecordList = [SELECT Id,
                                                           		  Name,
                                                           		  cgcloud__Slogan_Language_1__c
                                                           FROM   cgcloud__Promotion__c
                                                           WHERE  cgcloud__Slogan_Language_1__c = 'Test'
                                                           LIMIT	1];
        // Get the created Sales Profile User
        List<User> testSalesProfileUserList = [SELECT Id,
                                              		  Name,
                                               		  FirstName
                                               FROM   User
                                               WHERE  FirstName = 'Test Sales'];
        
        List<TPM_ApprovalComponentController.ApprovalWrapperClass> approvalWrapperClassList = TPM_ApprovalComponentController.getPromotionRelatedApprovals(promotionRecordList[0].Id,testSalesProfileUserList[0].Id);
        // Check If the records are there in the Wrapper Class
        System.assertEquals(false, approvalWrapperClassList.isEmpty(), assertStr);
         
    }
    
}