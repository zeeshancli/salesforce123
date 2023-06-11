/*******************************************************************************************************
* @Name         : TPM_PopulateExternalIdForPromotionTest
* @ author       : PwC Team
* @date         : May 19, 2023
* @description  : To test the Batch Class TPM_PopulateExternalIdForPromotionBatch 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_PopulateExternalIdForPromotionTest {
    
        static String assertStr = 'List should be empty';

     /****************************************************************************
    * @method         : executeTest
    * @description    : To test assortment header creation assignment batch execute method
    ****************************************************************************/
    
    @isTest
    public static void executeTest(){
        
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
        
        promotionRec.cgcloud__externalid__c = null;
        update promotionRec;
        
        
        Test.startTest();
       Database.executeBatch(new TPM_PopulateExternalIdForPromotionBatch());   
        
        List<cgcloud__promotion__c> promotionlst = [SELECT Id,cgcloud__Promotion__c.Name,cgcloud__externalid__c FROM cgcloud__promotion__c WHERE cgcloud__externalid__c=null];

        system.assert(!promotionlst.isEmpty(),assertStr);
        
        Test.stopTest();
        
 }
    

}