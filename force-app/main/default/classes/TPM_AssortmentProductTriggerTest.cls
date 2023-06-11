/*******************************************************************************************************
* @Name         : TPM_AssortmentProductTriggerTest
* @ author       : PwC Team
* @date         : March 6, 2023
* @description  : To test the Assortment Product
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_AssortmentProductTriggerTest {
    
    static String assertStr = 'List should not be empty';
    static String itOrg = 'IT01';

    /******************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for assortment product test class
    ******************************************************************************************/
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    @testSetup static void testDataSetUpMethod() {
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        insert triggerConfigSettingList;
        
        TPM_TestDataUtility.createProductDataWithTemplate(itOrg,'Product','Category',60);
        
        List<Product2> topNodeProduct= [select id from product2 where cgcloud__Product_Level__c = 'Category' limit 1];
        cgcloud__Product_Assortment_Template__c prodAssortmenttemplate = TPM_TestDataUtility.createProductAssortmentTemplate('Product',itOrg);
        insert prodAssortmenttemplate;
        
        cgcloud__Account_Template__c custTemplate = TPM_TestDataUtility.createCustomerTemplate(itOrg);
        insert custTemplate; 
        
        List<Account> accountList = new List<Account>();
        
         Account superGroupAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('SuperGroup',itOrg,custTemplate.id,null);
        insert superGroupAcc;
        
        
        accountList.add(superGroupAcc);
        
        Account groupAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('Group',itOrg,custTemplate.id,superGroupAcc.Id);
        insert groupAcc;
        
        accountList.add(groupAcc);
        
        Account managedAccountAcc = TPM_TestDataUtility.createAccountWithTemplateAndParent('Managed Account',itOrg,custTemplate.id,GroupAcc.Id);
        insert managedAccountAcc;
        
        accountList.add(managedAccountAcc);
        
        Account managedAccountAcc1 = TPM_TestDataUtility.createAccountWithTemplateAndParent('Managed Account',itOrg,custTemplate.id,GroupAcc.Id);
        insert managedAccountAcc1;
        
        accountList.add(managedAccountAcc1);
        
        TPM_TestDataUtility.createAssortmentHeaders(accountList,prodAssortmenttemplate.id,topNodeProduct[0].Id);
        
        List<StoreAssortment> assortmentList = [select id,assortmentId from storeassortment where accountid = :managedAccountAcc.Id];
        
        Date thruDate =  Date.newInstance(2099, 12, 31);
        AssortmentProduct assortProd = new AssortmentProduct(assortmentId = assortmentList[0].assortmentId, ProductId =topNodeProduct[0].Id, 
                                                            cgcloud__Valid_From__c = system.today(),
                                                            cgcloud__Valid_Thru__c = thruDate,
                                                            cgcloud__Active__c = true);
        
        insert assortProd;
        
     }
    
    /******************************************************************************************
    * @method			testAccountTeamDelete
    * @ return     		:void
    * @param   		  
    * @description    	test method for deleting account team members for managed account
    ******************************************************************************************/
    
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static void testAccountTeamDelete() {
        
        Account managedAcc = [Select id from Account where TPM_Hierarchy_Level__c = 'Managed Account' limit 1];
        
        StoreAssortment storeAssort = [select id,assortmentId from storeassortment where accountid =: managedAcc.Id limit 1];
        
        List<AssortmentProduct> assortmentProductList = [Select id,name from assortmentProduct where assortmentid =: storeAssort.assortmentId  limit 1];
        delete assortmentProductList;
        
        system.assert(!assortmentProductList.isEmpty(),assertStr);
        
    }
    
    
    /******************************************************************************************
    * @method			testAccountTeamUpdate
    * @ return     		:void
    * @param   		  
    * @description    	test method for updating assortment product for managed account
    ******************************************************************************************/
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static void testAccountTeamUpdate() {
        
        Account managedAcc = [Select id from Account where TPM_Hierarchy_Level__c = 'Managed Account' limit 1];
        
        StoreAssortment storeAssort = [select id,assortmentId from storeassortment where accountid =: managedAcc.Id limit 1];
        
        List<AssortmentProduct> assortmentProductList = [Select id,name from assortmentProduct where assortmentid =: storeAssort.assortmentId  limit 1];
        
        assortmentProductList[0].cgcloud__Active__c = false;
        update assortmentProductList[0];
        
        system.assert(!assortmentProductList.isEmpty(),assertStr);
        
    }
     
        
}