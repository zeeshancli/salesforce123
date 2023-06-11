/******************************************************************************************************
* @Name         : TPM_ProductFlatteningCategoryBatchTest
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Test class for batch apex - 'TPM_ProductFlatteningCategoryBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_ProductFlatteningCategoryBatchTest {
    
    
    /******************************************
	* @method         : setup
	* @description    : To create test data 
	********************************************/
    @testSetup
    static void setup() {
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPMAdminFName',
                                                            'testTPMAdminLName');
        
        
        adminUser.Email = 'tpmadminuser0001@invalidtpm.com';
        insert adminUser;

        String usCode = 'US01';
        String newStatus = 'New';
        
        System.runAs(adminUser) {       
            
            cgcloud__Product_Template__c prodGroupTemplate = new cgcloud__Product_Template__c();
            prodGroupTemplate.cgcloud__Active__c = true;
            prodGroupTemplate.cgcloud__Sales_Org__c = usCode;
            prodGroupTemplate.Name = 'US01TempName';
            prodGroupTemplate.RecordTypeId = Schema.SObjectType.cgcloud__Product_Template__c.getRecordTypeInfosByDeveloperName().get('Product_Group').getRecordTypeId();
            
            insert prodGroupTemplate;
            
            cgcloud__Product_Template__c prodTemplate = new cgcloud__Product_Template__c();
            prodTemplate.cgcloud__Active__c = true;
            prodTemplate.cgcloud__Sales_Org__c = usCode;
            prodGroupTemplate.Name = 'US01GroupTemplate'; 
            prodGroupTemplate.RecordTypeId = Schema.SObjectType.cgcloud__Product_Template__c.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();

            insert prodTemplate;
            
            // Create Product Record Test data.
            List<Product2> testProductList = new List<Product2>();
            
            Id productRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
            Id productGrpRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product_Group').getRecordTypeId();
            for(Integer itr = 1; itr <= 5; itr++){
                testProductList.add(new Product2(TPM_SAP_Sales_Org__c=usCode,
                                                 cgcloud__Consumer_Goods_External_Product_Id__c='US01CGPRIDCAT' + itr,
                                                 cgcloud__Consumer_Goods_Product_Code__c = 'US01CGPRCCAT'+itr,
                                                 cgcloud__Product_Level__c='Category',
                                                 cgcloud__Description_1_Language_1__c='US01Categorydesc'+itr,
                                                 RecordTypeId=productGrpRTId,
                                                 cgcloud__Product_Template__c = prodGroupTemplate.Id,  
                                                 Name='testCategory'+itr));
                testProductList.add(new Product2(TPM_SAP_Sales_Org__c=usCode,
                                                 cgcloud__Consumer_Goods_External_Product_Id__c='US01CGPRIDSUBCAT'+itr,
                                                 cgcloud__Consumer_Goods_Product_Code__c = 'US01CGPRCSUBCAT'+itr,
                                                 cgcloud__Product_Level__c='SubCategory',
                                                 cgcloud__Description_1_Language_1__c='US01SubCategorydesc'+itr,
                                                 RecordTypeId=productGrpRTId,
                                                 cgcloud__Product_Template__c = prodGroupTemplate.Id, 
                                                 Name='testSubCategory'+itr));
                testProductList.add(new Product2(TPM_SAP_Sales_Org__c=usCode,
                                                 cgcloud__Consumer_Goods_External_Product_Id__c='US01CGPRIDBRAN'+itr,
                                                 cgcloud__Consumer_Goods_Product_Code__c = 'US01CGPRCBRAN'+itr,
                                                 cgcloud__Product_Level__c='Brand',
                                                 cgcloud__Description_1_Language_1__c='US01Branddesc'+itr,
                                                 RecordTypeId=productGrpRTId,
                                                 cgcloud__Product_Template__c = prodGroupTemplate.Id, 
                                                 Name='testBrand'+itr));
                testProductList.add(new Product2(TPM_SAP_Sales_Org__c=usCode,
                                                 cgcloud__Consumer_Goods_External_Product_Id__c='US01CGPRIDFLAV'+itr,
                                                 cgcloud__Consumer_Goods_Product_Code__c = 'US01CGPRCFLAV'+itr,
                                                 cgcloud__Product_Level__c='Flavor',
                                                 cgcloud__Description_1_Language_1__c='US01Flavordesc'+itr,
                                                 RecordTypeId=productGrpRTId,
                                                 cgcloud__Product_Template__c = prodGroupTemplate.Id, 
                                                 Name='testFlavor'+itr));
                testProductList.add(new Product2(TPM_SAP_Sales_Org__c=usCode,
                                                 cgcloud__Consumer_Goods_External_Product_Id__c='US01CGPRIDPACK'+itr,
                                                 cgcloud__Consumer_Goods_Product_Code__c = 'US01CGPRCPACK'+itr,
                                                 cgcloud__Product_Level__c='Package',
                                                 cgcloud__Description_1_Language_1__c='US01PAckagedesc'+itr,
                                                 RecordTypeId=productGrpRTId,
                                                 cgcloud__Product_Template__c = prodGroupTemplate.Id, 
                                                 Name='testPackage'+itr));
                testProductList.add(new Product2(TPM_SAP_Sales_Org__c=usCode,
                                                 cgcloud__Consumer_Goods_External_Product_Id__c='US01CGPRIDPRO'+itr,
                                                 cgcloud__Consumer_Goods_Product_Code__c = 'US01CGPRCPRO'+itr,
                                                 cgcloud__Product_Level__c='Product',
                                                 cgcloud__Description_1_Language_1__c='US01Productdesc'+itr,
                                                 RecordTypeId=productRTId,
                                                 cgcloud__Product_Template__c = prodTemplate.Id, 
                                                 Name='testProduct'+itr));
            }
            insert testProductList;
            
            // Create product hierarchy staging records.
            List<TPM_Product_Hierarchy_Staging__c> pHSList = new List<TPM_Product_Hierarchy_Staging__c>();
            for(Integer itr = 1; itr <= 5; itr++){
                pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDCAT'+itr,
                                                                 TPM_Child_Prod_ID__c='US01CGPRIDSUBCAT'+itr,
                                                                 TPM_External_ID__c='US01EXCSID'+itr,
                                                                 TPM_Convert_Status__c=newStatus,
                                                                 TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                                 TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2026, 01, 22)
                                                                ));
                pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDSUBCAT'+itr,
                                                                 TPM_Child_Prod_ID__c='US01CGPRIDBRAN'+itr,
                                                                 TPM_External_ID__c='US01EXSBID'+itr,
                                                                 TPM_Convert_Status__c=newStatus,
                                                                 TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                                 TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2026, 01, 22)
                                                                ));
                pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDBRAN'+itr,
                                                                 TPM_Child_Prod_ID__c='US01CGPRIDFLAV'+itr,
                                                                 TPM_External_ID__c='US01EXBFID'+itr,
                                                                 TPM_Convert_Status__c=newStatus,
                                                                 TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                                 TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2026, 01, 22)
                                                                ));
                pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDFLAV'+itr,
                                                                 TPM_Child_Prod_ID__c='US01CGPRIDPACK'+itr,
                                                                 TPM_External_ID__c='US01EXFPID'+itr,
                                                                 TPM_Convert_Status__c=newStatus,
                                                                 TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                                 TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2026, 01, 22)
                                                                ));
                pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDPACK'+itr,
                                                                 TPM_Child_Prod_ID__c='US01CGPRIDPRO'+itr,
                                                                 TPM_External_ID__c='US01EXPPID'+itr,
                                                                 TPM_Convert_Status__c=newStatus,
                                                                 TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                                 TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2026, 01, 22)
                                                                ));
            }
            
            // For Negative testing of hierarchy by changing TPM_Parnt_Prod_ID__c for hierarchy
            pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDFLAV1',
                                                             TPM_Child_Prod_ID__c='US01CGPRIDPRO1',
                                                             TPM_External_ID__c='US01EXPPID1',
                                                             TPM_Convert_Status__c=newStatus,
                                                             TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                             TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2024, 01, 22)
                                                            ));
            // For Negative testing by making TPM_Parnt_Prod_ID__c as wrong ID
            pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='WRONGID1',
                                                             TPM_Child_Prod_ID__c='US01CGPRIDPRO1',
                                                             TPM_External_ID__c='US01EXPPID1',
                                                             TPM_Convert_Status__c=newStatus,
                                                             TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                             TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2024, 01, 22)
                                                            ));
            // For Negative testing by making TPM_Child_Prod_ID__c as wrong ID
            pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='US01CGPRIDPRO1',
                                                             TPM_Child_Prod_ID__c='WRONGID',
                                                             TPM_External_ID__c='US01EXPPID1',
                                                             TPM_Convert_Status__c=newStatus,
                                                             TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                             TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2024, 01, 22)
                                                            ));
            // For Negative testing by making both TPM_Parnt_Prod_ID__c &TPM_Child_Prod_ID__c as wrong ID
            pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='WRONGID',
                                                             TPM_Child_Prod_ID__c='WRONGID',
                                                             TPM_External_ID__c='US01EXPPID1',
                                                             TPM_Convert_Status__c=newStatus,
                                                             TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                             TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2024, 01, 22)
                                                            ));
            // For Negative testing by making by providing no TPM_Prod_Hrchy_Strt_Dt__c
            pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c='WRONGID',
                                                             TPM_Child_Prod_ID__c='WRONGID',
                                                             TPM_External_ID__c='US01EXPPID1',
                                                             TPM_Convert_Status__c=newStatus,
                                                             TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2024, 01, 22)
                                                            ));
            // For Negative testing by making both TPM_Parnt_Prod_ID__c &TPM_Child_Prod_ID__c as null
            pHSList.add(new TPM_Product_Hierarchy_Staging__c(TPM_Parnt_Prod_ID__c=null,
                                                             TPM_Child_Prod_ID__c=null,
                                                             TPM_External_ID__c='US01EXPPID1',
                                                             TPM_Convert_Status__c=newStatus,
                                                             TPM_Prod_Hrchy_Strt_Dt__c=Date.newInstance(2023, 01, 25),
                                                             TPM_Prod_Hrchy_End_DT__c=Date.newInstance(2024, 01, 22)
                                                            ));
            
            insert pHSList;   
        }
        
    }
    
    
    /********************************************************************
	* @method         : testProductHierarchyCreation
	* @description    : To test creation of product hierarchy
	*********************************************************************/
    @isTest static void testProductHierarchyCreation(){
        
        User batchUser = new User();
        
        // Fetch user details.
        batchUser = [SELECT Id 
                     FROM User 
                     WHERE Email = 'tpmadminuser0001@invalidtpm.com' LIMIT 1];
        
        // Run the code as batch user.
        System.runAs(batchUser){
            Test.startTest();
            TPM_ProductHierarchyCreationBatch hierarchyCreationBatch = new TPM_ProductHierarchyCreationBatch(null);
            Database.executeBatch(hierarchyCreationBatch, 200);
            Test.stopTest();
            System.assertEquals('', '', 'TODO');
        }
    }
    
    
    /********************************************************************
	* @method         : testProductFlattening
	* @description    : to test product hierarchy flattening
	*********************************************************************/
    @isTest static void testProductFlattening(){
        
        User batchUser = new User();
        
        // Fetch user details.
        batchUser = [SELECT Id 
                     FROM User 
                     WHERE Email = 'tpmadminuser0001@invalidtpm.com' LIMIT 1];
        
        // Run the code as batch user.
        System.runAs(batchUser){
            
            Test.startTest();
            TPM_ProductFlatteningCategoryBatch prodFlatteningBatch = new TPM_ProductFlatteningCategoryBatch(null);
            Database.executeBatch(prodFlatteningBatch, 200);
            Test.stopTest();
            System.assertEquals('', '', 'TODO');
        }
    }
    
    
}