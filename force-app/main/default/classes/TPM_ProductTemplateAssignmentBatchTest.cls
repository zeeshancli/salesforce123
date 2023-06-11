/*******************************************************************************************************
* @Name         : TPM_ProductTemplateAssignmentBatchTest
* @Test Class   : TPM_ProductTemplateAssignmentBatchTest
* @ author       : PwC Team
* @date         : December 8, 2022
* @description  : To test the Batch Class TPM_ProductTemplateAssignmentBatch 
is used for product temmplate assignment to product records...
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_ProductTemplateAssignmentBatchTest {
    
    public static final String DISPLAY_MSG = 'Product Record Template not updated';

    /****************************************************************************
    * @method         : executeTest
    * @description    : To test product template assignment batch execute method
    ****************************************************************************/
    
    @isTest
    public static void executeTest(){
        
        // Call createProductData to create Test Product records
        TPM_TestDataUtility.createProductData('IT01','Product','Product',60,True);
        TPM_TestDataUtility.createProductData('US01','Product_Group','Flavor',60,False);
        TPM_ProductTemplateAssignmentBatch batchObj = new TPM_ProductTemplateAssignmentBatch();
        
        Test.startTest();
        
        //Call the batch execute method
        Database.executeBatch(batchObj,200);
        
        Test.stopTest();
        
        //Check if product template is assigned for product records with IT01 Sales Org & Product Record Type
        List<Product2> updatedProdLevelList = [SELECT 	Id,
                                               			Name,
                                               		  	cgcloud__Consumer_Goods_External_Product_Id__c, 
                                               			cgcloud__Product_Level__c, 
                                               			TPM_SAP_Sales_Org__c, 
                                               			cgcloud__Product_Template__c, 
                                               			RecordType.DeveloperName 
                                               FROM   	Product2 
                                               WHERE  	cgcloud__Product_Template__c != NULL 
                                               AND 		RecordType.DeveloperName = 'Product'
                                               AND		cgcloud__Sales_Org__c = 'IT01'];
        System.assertEquals(false,updatedProdLevelList.isEmpty() ,TPM_ProductTemplateAssignmentBatchTest.DISPLAY_MSG);
        
        //Check if product template is assigned for product records with US01 Sales Org & Product_Group Record Type
        List<Product2> invalidProductUpdateList = [SELECT	Id,
                                                   			Name,
                                               				cgcloud__Consumer_Goods_External_Product_Id__c, 
                                               				cgcloud__Product_Level__c, 
                                               				TPM_SAP_Sales_Org__c, 
                                               				cgcloud__Product_Template__c, 
                                              			 	RecordType.DeveloperName
                                                   FROM   	Product2 
                                                   WHERE  	cgcloud__Product_Template__c = NULL 
                                                   AND 		RecordType.DeveloperName = 'Product_Group'
                                                   AND		TPM_SAP_Sales_Org__c = 'US01'];
        System.assertEquals(false,invalidProductUpdateList.isEmpty() ,TPM_ProductTemplateAssignmentBatchTest.DISPLAY_MSG);
    } 
}