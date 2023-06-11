/*******************************************************************************************************
* @Name         : TPM_ComponentVolumeWebServiceTest
* @author       : PwC Team
* @date         : 03/24/2023
* @description  : Test Class for the Class TPM_ComponentVolumeWebService
*******************************************************************************************************/
@isTest
public class TPM_ComponentVolumeWebServiceTest {
    
	 static String assertStr = 'List should not be empty';
    
    /*****************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for ComponentVolumePlan Controller Class.
    *****************************************************************************************/
    
    @testSetup static void testDataSetUpMethod() {
        
        //Create Account Template
        cgcloud__Account_Template__c custTemplate = TPM_TestDataUtility.createCustomerTemplate('IT01');
        insert custTemplate;
        
        //Create Account with Template
        Account superGroupAcc = TPM_TestDataUtility.createAccountWithTemplate('SuperGroup','IT01',custTemplate.id);
        insert superGroupAcc;
        
        //Create Account with Template
        Account groupAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('Group','IT01',custTemplate.id,superGroupAcc.Id);
        insert groupAcc;
        
        //Create Account with Template
        Account managedAccountAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('Managed Account','IT01',custTemplate.id,groupAcc.Id);
        insert managedAccountAcc;
        
        //Create Promotion Template
        cgcloud__Promotion_Template__c promotionTemplateObj =  TPM_TestDataUtilityExtension.createPromotionTemplateBySalesOrg('IT01','Promotion');
        insert promotionTemplateObj;
        
        //Create promotion
        cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotionWithPhase(managedAccountAcc.Id,promotionTemplateObj.Id,'Planning');
        insert promotionRec;
		
		//Create promotion with cancelled phase        
        cgcloud__Promotion__c promotionRecTwo = TPM_TestDataUtilityExtension.createPromotionWithPhase(managedAccountAcc.Id,promotionTemplateObj.Id,'Cancelled');
        insert promotionRecTwo;
        
      	//Create Tactic Template
        cgcloud__Tactic_Template__c tacticTemplateObj =  TPM_TestDataUtilityExtension.createTacticTemplateBySalesOrg('IT01','Display');
        insert tacticTemplateObj;
		
        // Create Tactic
        cgcloud__Tactic__c tacticRecord = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id,tacticTemplateObj.Id);
        insert tacticRecord;
        
        // Create Tactic 
        cgcloud__Tactic__c tacticRecordTwo = TPM_TestDataUtilityExtension.createTactic(promotionRecTwo.Id,tacticTemplateObj.Id);
        insert tacticRecordTwo;
        
    }
    
    /******************************************************************************************
    * @method			testexecuteComponentVolumeDisplayShipper
    * @ return     		:void
    * @param   		  
    * @description    	test method for testexecuteComponentVolumeDisplayShipper
    ******************************************************************************************/
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static void testexecuteComponentVolumeDisplayShipper() {
        
        List<cgcloud__Promotion__c> promotionListOne = [SELECT 	Id,
                                                     			cgcloud__Sales_Org__c ,
                                                     			TPM_Phase__c
                                                     	FROM    cgcloud__Promotion__c
                                                     	WHERE   TPM_Phase__c = 'Planning'
                                                     	LIMIT 	1];
      
        System.assertEquals(promotionListOne.isEmpty(), false);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TPM_Promotion_Mock_JSON');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json'); 
       
       	// Set the mock callout mode
       	Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Map<String, Object> mapParamsOne = new Map<String, Object>();
        mapParamsOne.put('objId', promotionListOne[0].Id);
        TPM_ComponentVolumePlanController tpmClassObjOne = new TPM_ComponentVolumePlanController();
        tpmClassObjOne.call('executeComponentVolumeDisplayShipper', mapParamsOne);
        Test.stopTest();
    }
}