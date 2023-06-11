/******************************************************************************************************
* @Name         : TPM_AccountSVFAssignmentBatchTest
* @author       : PwC Team
* @date         : May 4, 2023
* @description  : Test class for batch apex - 'TPM_AccountSVFAssignmentBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_AccountSVFAssignmentBatchTest {
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
            
            List<account> acclist = new List<Account>();
            accList.add(new Account(Name = 'test0',cgcloud__Account_Number__c = 'ABC11',
                                   TPM_Hierarchy_Level__c = 'Managed Account',cgcloud__ExternalId__c = '0987654',
                                   TPM_IsActive__c = True));
            accList.add(new Account(Name = 'test1',cgcloud__Account_Number__c = 'ABC12',
                                   TPM_Hierarchy_Level__c = 'Managed Account',cgcloud__ExternalId__c = '0987655',
                                   TPM_IsActive__c = True));
            accList.add(new Account(Name = 'test2',cgcloud__Account_Number__c = 'ABC13',
                                   TPM_Hierarchy_Level__c = 'Managed Account',cgcloud__ExternalId__c = '0987656',
                                   TPM_IsActive__c = True));
            accList.add(new Account(Name = 'test3',cgcloud__Account_Number__c = 'ABC14',
                                   TPM_Hierarchy_Level__c = 'Managed Account',cgcloud__ExternalId__c = '0987657',
                                   TPM_IsActive__c = True));
            insert accList;
            
            List<cgcloud__Account_Plan__c> svfList =new List<cgcloud__Account_Plan__c>();
            for(Integer i=0;i<3;i++){
                svfList.add(new cgcloud__Account_Plan__c(cgcloud__Account__c = accList[i].Id,
                                                                                           cgcloud__Business_Year__c = 2023,
                                                                                           cgcloud__Description_Language_1__c = '2023Test'+i,
                                                                                           cgcloud__Category_Labels_Language_1__c = 'Top Node'));
            }
            svfList.add(new cgcloud__Account_Plan__c(cgcloud__Account__c = accList[1].Id,
                                                                                           cgcloud__Business_Year__c = 2024,
                                                                                           cgcloud__Description_Language_1__c = '2024Test1',
                                                                                           cgcloud__Category_Labels_Language_1__c = 'Top Node'));
            svfList.add(new cgcloud__Account_Plan__c(cgcloud__Account__c = accList[2].Id,
                                                                                           cgcloud__Business_Year__c = 2022,
                                                                                           cgcloud__Description_Language_1__c = '2022Test2',
                                                                                           cgcloud__Category_Labels_Language_1__c = 'Top Node'));
            svfList.add(new cgcloud__Account_Plan__c(cgcloud__Account__c = accList[3].Id,
                                                                                           cgcloud__Business_Year__c = 2024,
                                                                                           cgcloud__Description_Language_1__c = '2024Test3',
                                                                                           cgcloud__Category_Labels_Language_1__c = 'Top Node'));
            svfList.add(new cgcloud__Account_Plan__c(cgcloud__Account__c = accList[3].Id,
                                                                                           cgcloud__Business_Year__c = 2022,
                                                                                           cgcloud__Description_Language_1__c = '2024Test3',
                                                                                           cgcloud__Category_Labels_Language_1__c = 'Top Node'));
            
            insert svfList;                        
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
            Test.startTest();
            // Call the batch execute method
            Database.executeBatch(new TPM_AccountSVFAssignmentBatch());     
            Test.stopTest();
            System.assertEquals('', '', 'TODO');
        }
    }

}