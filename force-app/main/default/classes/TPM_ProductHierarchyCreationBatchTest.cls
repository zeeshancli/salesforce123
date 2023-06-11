/******************************************************************************************************
* @Name         : TPM_ProductHierarchyCreationBatchTest
* @author       : PwC Team
* @date         : January 18, 2023
* @description  : Test class for batch apex - 'TPM_ProductHierarchyCreationBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_ProductHierarchyCreationBatchTest {
    

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
        
        String customerStr = 'Customer'; 
        String us01Str = 'US01';
        String accountTemplateStr = 'cgcloud__Account_Template__c';
        
        System.runAs(adminUser) {            
            
            // Create Customer Template record.
            cgcloud__Account_Template__c accountTemplateBasic = new cgcloud__Account_Template__c(Name = 'Basic_US01', 
                                                                                                 RecordTypeId = TPM_TestDataUtility.fetchRecordTypeId(customerStr, accountTemplateStr), 
                                                                                                 cgcloud__Sales_Org__c = us01Str, 
                                                                                                 cgcloud__Description_Language_1__c = 'Basic_US01', 
                                                                                                 cgcloud__Active__c = True, 
                                                                                                 cgcloud__Initial_Roles__c = 'customer;payer', 
                                                                                                 cgcloud__Available_Product_Level__c = 'SubCategory;Brand;Flavor;Package', 
                                                                                                 TPM_CustTemp_PlanMode__c = 'Basic');
            insert accountTemplateBasic;
            
            //TODO - add data setup
            
        }
    }


    /********************************************************************
	* @method         : testMethodToDo
	* @description    :  
	*********************************************************************/
    @isTest static void testMethodToDo(){
        
        User batchUser = new User();
        
        // Fetch user details.
        batchUser = [SELECT Id 
                     FROM User 
                     WHERE Email = 'tpmadminuser0001@invalidtpm.com' LIMIT 1];
        
        // Run the code as batch user.
        System.runAs(batchUser){
            
            // TODO - Add logic pending
            
            System.assertEquals('', '', 'TODO');
        }
    }

}