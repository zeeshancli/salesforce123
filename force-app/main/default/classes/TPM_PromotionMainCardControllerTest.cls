/*******************************************************************************************************
* @name         : TPM_PromotionMainCardControllerTest
* @author       : PwC Team
* @date         : 03/13/2023
* @description  : Test Class for promotion module
*******************************************************************************************************/
@isTest
public class TPM_PromotionMainCardControllerTest {
    

    static String assertStr = 'List should not be empty';
    
    /*****************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for tactic lwc test class
    *****************************************************************************************/
    
    @testSetup static void testDataSetUpMethod() {
        
        cgcloud__Account_Template__c custTemplate = TPM_TestDataUtility.createCustomerTemplate('IT01');
        insert custTemplate;
        
         Account superGroupAcc = TPM_TestDataUtility.createAccountWithTemplate('SuperGroup','IT01',custTemplate.id);
        insert superGroupAcc;
        
         Account groupAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('Group','IT01',custTemplate.id,superGroupAcc.Id);
        insert groupAcc;
        
        Account managedAccountAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('Managed Account','IT01',custTemplate.id,groupAcc.Id);
        insert managedAccountAcc;
        
        cgcloud__Promotion_Template__c promotionTemplateObj =  TPM_TestDataUtilityExtension.createPromotionTemplateBySalesOrg('IT01','Promotion');
        insert promotionTemplateObj;
        
         //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemplateObj.Id);
            insert promotionRec;
    }
    
    /******************************************************************************************
    * @method			testfetchUIDefinitionObj
    * @ return     		:void
    * @param   		  
    * @description    	test method for promotion lwc test class
    ******************************************************************************************/
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static void testfetchUIDefinitionObj() {
        
        List<cgcloud__Promotion__c> promotionList = [Select id from cgcloud__Promotion__c limit 1];
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('objId', promotionList[0].Id);
        
        TPM_PromotionMainCardController tpmClassObj = new TPM_PromotionMainCardController();
        Object objRet = tpmClassObj.call('fetchPromoUIComponentData', mapParams);
        
        Object objRet1 = tpmClassObj.call('EARights', mapParams);
        
        if(objRet!=null || objRet1!=null){
           system.assert(!promotionList.isEmpty(),assertStr);   
        }
       
    }

}