/*****************************************************************************************************
* @Name         : TPM_TestDataUtility
* @author       : PwC Team
* @date         : December 14, 2022
* @description  : Test Data Utility
*****************************************************************************************************
Change History Story      Modified by               Date                          Desc

******************************************************************************************************/
@SuppressWarnings('sf:TestClassWithoutTestCases')
@isTest
public class TPM_TestDataUtility {
    
    static String testCustomerName = 'Test Customer';
     static String testProductName = 'Test Product';
       static String testStr = 'Test';
    /********************************************************************************************
	* @method         : createTestUser
	* @return		  : User
	* @param		    profileID
    * @param		    firstName
    * @param		    lastName
	* @description    : Method to create test user record.
	*********************************************************************************************/
    public static User createTestUser(Id profileID, String firstName, String lastName) {
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        // Generate random number.
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User testUser = new User(firstname = firstName,
                                 lastName = lastName,
                                 email = uniqueName + '@test' + orgId + '.org',
                                 Username = uniqueName + '@test' + orgId + '.org',
                                 EmailEncodingKey = 'ISO-8859-1',
                                 Alias = uniqueName.substring(18, 23),
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 LocaleSidKey = TPM_ConstantsUtility.EN_US,
                                 LanguageLocaleKey = TPM_ConstantsUtility.EN_US,
                                 TPM_ApprovalLevel__c = 'NA',
                                 ProfileId = profileID);
        return testUser;
    }
    
    
    /****************************************************************
	* @method         : getProfileId
	* @return		  : String
	* @param		    profileName
	* @description    : Method to fetch profile record id
	******************************************************************/
    public static String getProfileId(String profileName){
        
        return [SELECT Id,
                	   Name 
                FROM   Profile 
                WHERE  Name =: profileName 
                LIMIT 1]?.Id;
    }
    
    
    /******************************************************************************************
	* @method         : fetchRecordTypeId
	* @return		  : String
	* @param		    recordTypeDevName
    * @param		    objectAPIName
	* @description    : Method to fetch RecordTypeId
	********************************************************************************************/
    @SuppressWarnings('PMD.EagerlyLoadedDescribeSObjectResult')
    public static String fetchRecordTypeId(String recordTypeDevName, String objectAPIName){
        
        Id recTypeId;
        if(String.isNotBlank(objectAPIName) && String.isNotBlank(recordTypeDevName)){
            recTypeId = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        }  
        return recTypeId;  
    }
    

    /******************************************************************************************
    * @method			: createAccounts
    * @return     		: List<Account>
    * @param   		      numOfAccounts
    * @description    	: Method to create accounts (Customer)
    ******************************************************************************************/

    public static List<Account> createAccounts(Integer numOfAccounts) {
        List<Account> newAccounts = new List<Account>();        
        for(Integer accCount = 0; accCount<=numOfAccounts ; accCount++) {
            newAccounts.add(new Account(Name = testCustomerName+accCount, cgcloud__Account_Number__c = 'CE000000'+accCount,
                                       	TPM_Hierarchy_Level__c = 'SuperGroup', cgcloud__ExternalId__c = '0987654'+accCount,
                                        TPM_IsActive__c = True));
            
        }
        return newAccounts;
    }
    
    /******************************************************************************************
    * @method			  : createCustomerHierarchyStaging
    * @return     		  : List<TPM_Customer_Hierarchy_Staging__c>
    * @param   		        numOfCHS
    * @description    	  : Method to create Customer Hierarchy Staging 
    ******************************************************************************************/

    public static List<TPM_Customer_Hierarchy_Staging__c> createCustomerHierarchyStaging(Integer numOfCHS) {
        List<TPM_Customer_Hierarchy_Staging__c> custHrStagings = new List<TPM_Customer_Hierarchy_Staging__c>();  
        
        for(Integer chsCount = 0; chsCount<=numOfCHS ; chsCount++) {
            custHrStagings.add(new TPM_Customer_Hierarchy_Staging__c(TPM_Convert_Status__c = 'New', TPM_Cust_Hrchy_Strt_Dt__c = Date.today(), 
                                                                    TPM_Cust_Hrchy_End_DT__c = Date.newInstance(2030, 1, 30)));
            
        }
        
        return custHrStagings;
    }

    /******************************************************************************************
    * @method			: createUser
    * @return     		: User
    * @param   		  profileName
    * @description    	: Method to create user
    ******************************************************************************************/
    public static User createUser(String profileName) {
        Profile profileObj = [SELECT Id 
                              FROM Profile 
                              WHERE Name = 'System Administrator']; 
        string values = 'US01;IT01';
        User userObj = new User(Alias = 'standt', Email=System.now().millisecond() + '@gmail.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = TPM_ConstantsUtility.EN_US, 
            LocaleSidKey = TPM_ConstantsUtility.EN_US, ProfileId = profileObj.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', username= System.now().millisecond() + '@sb.com', TPM_Sales_Org__c = values, TPM_ApprovalLevel__c = 'NA');
        
        return userObj;  
    }

    /******************************************************************************************
    * @method			: createTriggerConfigSetting
    * @return     		: List<TPM_Trigger_Config_Settings__c>
    * @params     		: null
    * @description    	: Method to create custom setting : TPM_Trigger_Config_Settings__c
    ******************************************************************************************/
    public static List<TPM_Trigger_Config_Settings__c> createTriggerConfigSetting() {
        List<TPM_Trigger_Config_Settings__c> configSettingList =  new List<TPM_Trigger_Config_Settings__c>();
        TPM_Trigger_Config_Settings__c userConfig = new TPM_Trigger_Config_Settings__c();
        userConfig.TPM_User_Trigger_Active__c = true;
        userConfig.TPM_AccountTeam_Trigger_Active__c =  true;
        userConfig.TPM_Sales_Org_User_Trigger__c = true;
        userConfig.TPM_AssortmentProduct_Trigger_Active__c =true;
        userConfig.TPM_AccountTrigger_Active__c = true;
        userConfig.TPM_AssortmentTrigger_Active__c = true;
        userConfig.TPM_TacticTrigger_Active__c = true;
        userConfig.TPM_TCCDTrigger_Active__c = true;
        userConfig.TPM_TPCTrigger_Active__c = true;
        userConfig.TPM_CBPCategoryTrigger_Active__c = true;
        userConfig.TPM_Promotion_Push_Status_Active__c = true;
        userConfig.TPM_Promotion_Trigger_Active__c = true;
        configSettingList.add(userConfig);
        return configSettingList;
        

     }
    
    /******************************************************************************************
    * @method			: createProductTemplateData
   * @ return     		: void
   * @param     		  tempName
   * @param              salesOrg
   * @param              recordType
   * @description    	: Method to create product template test data with
   * 					  Template Name,Sales Org,Recordtype Name
    ******************************************************************************************/
    public static void createProductTemplateData(String tempName, String salesOrg, String recordType){
        
        //Create product template record
        cgcloud__Product_Template__c prodTempObj = new cgcloud__Product_Template__c();
        prodTempObj.Name = salesOrg+' '+recordType+' '+tempName;
        prodTempObj.RecordTypeId = Schema.SObjectType.cgcloud__Product_Template__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        prodTempObj.cgcloud__Sales_Org__c = salesOrg;
        prodTempObj.cgcloud__Description_Language_1__c = salesOrg+' '+recordType+' '+tempName;
        prodTempObj.cgcloud__Active__c = True;
        
        //Insert Product template record
        insert prodTempObj;
    }
    
     /***********************************************************************************************************************
    * @method			: createProductData
    * @ return     		: void
    * @ param     		: prodName,
    * @param              salesOrg
    * @param              recordType
    * @param              prodLevel
    * @param              count
    * @param              isTemplate
    * @description    	: Method to create product template test data with
    * 					  Productname,Sales Org,Recordtype Name,Productlevel,Template if required
    **************************************************************************************************************************/
    public static void createProductData(String salesOrg, String recordType, String prodLevel,Integer count, Boolean isTemplate){
        
        List<Product2> createProdList = new List<Product2>();
        
        //Call createProductTemplateData method if Product template if required
        if(isTemplate){
            createProductTemplateData('Test Template',salesOrg,recordType);
        }
        
        //Create test product data 
        for(Integer itr = 1; itr <= count; itr++){
            Product2 prodObj = new Product2();
            prodObj.Name = salesOrg+' '+recordType+' '+testProductName+' '+itr;
            prodObj.TPM_SAP_Sales_Org__c = salesOrg;
            prodObj.cgcloud__Consumer_Goods_External_Product_Id__c = salesOrg +'CGPRID'+itr;
            prodObj.cgcloud__Consumer_Goods_Product_Code__c = salesOrg +'CGPRC'+itr;
            prodObj.cgcloud__Description_1_Language_1__c = salesOrg+' '+recordType+' '+testProductName+' '+itr;
            prodObj.cgcloud__Product_Level__c = prodLevel;
            prodObj.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            createProdList.add(prodObj);
        }
        
        //Insert the test data list of Product Records
        if(!createProdList.isEmpty()){
            
            insert createProdList;
            
        }
    }
    /******************************************************************************************
    * @method			: createAccountTeamMember
     * @return     		: AccountTeamMember
    * @param              accountId
    * @param              userId
    * @description    	: Method to create account team member
    ******************************************************************************************/
    public static AccountTeamMember createAccountTeamMember(Id accountId,Id userId) {
        AccountTeamMember accountTeamMemberObj =  new AccountTeamMember(AccountId = accountId,UserId = userId,
                                                                        TeamMemberRole = 'Account Manager',
                                                                        AccountAccessLevel = 'Read',
                                                                        CaseAccessLevel = 'None',
                                                                        OpportunityAccessLevel = 'None');
        return accountTeamMemberObj;  
    }
    /******************************************************************************************
    * @method			: createTestAccount
    * @return     		: Account
    * @param              hierarchy
    * @param   		      parentId
    * @description    	: Method to create accounts for a specific hierarchy (Customer)
    ******************************************************************************************/

    public static Account createAccountByHierarchy(String hierarchy,Id parentId) {
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        Account accountObj = new Account(Name = testCustomerName+randomInt, cgcloud__Account_Number__c = 'CE'+randomInt,
                                         TPM_Hierarchy_Level__c = Hierarchy, cgcloud__ExternalId__c = '098'+randomInt,ParentId=ParentId,TPM_IsActive__c=true);
         return accountObj;
    }
    
        /******************************************************************************************
    * @method			: createCustomerTemplate
    * @return     		: cgcloud__Account_Template__c
    * @param              salesOrg
    * @description    	: Method to create customer template for a particular sales org.
    ******************************************************************************************/

    public static cgcloud__Account_Template__c createCustomerTemplate(String salesOrg) {
        
        cgcloud__Account_Template__c accountTemplate = new cgcloud__Account_Template__c(Name=salesOrg+'Cust_Template',
                                                                                        cgcloud__Sales_Org__c=salesOrg,
                                                                                       cgcloud__Active__c = true);
        
        return accountTemplate;
    }
    
    /******************************************************************************************
    * @method			: createTestAccount
    * @return     		: Account
    * @param              hierarchy
    * @param   		      salesOrg
    * @param   		      customerTemplateId
    * @description    	: Method to create accounts for a specific hierarchy (Customer) with a customer template
    ******************************************************************************************/

    public static Account createAccountWithTemplate(String hierarchy,String salesOrg,Id customerTemplateId) {
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        Account accountObj = new Account(Name = testCustomerName+randomInt, cgcloud__Account_Number__c = 'CE'+randomInt,cgcloud__Account_Template__c=customerTemplateId,
                                         TPM_Hierarchy_Level__c = Hierarchy, cgcloud__ExternalId__c = '098'+randomInt,TPM_IsActive__c=true);
         return accountObj;
    }
    
    /******************************************************************************************
    * @method			: createProductAssortmentTemplate
    * @return     		: cgcloud__Product_Assortment_Template__c
    * @param              prodLevel
    * @param   		      salesOrg
    * @description    	: Method to create product assortment template for a sales org
    ******************************************************************************************/

    public static cgcloud__Product_Assortment_Template__c createProductAssortmentTemplate(String prodLevel,String salesOrg) {
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
         String recordTypeIdVal = fetchRecordTypeId('Planning_Assortment_List','cgcloud__Product_Assortment_Template__c');
        cgcloud__Product_Assortment_Template__c prodAssortment = new cgcloud__Product_Assortment_Template__c(Name=testStr+randomInt,
                                                                                                            cgcloud__Account_Multiplicity__c=String.valueof(1),
                                                                                                            cgcloud__Product_Level__c=prodLevel,
                                                                                                            cgcloud__Sales_Org__c=salesOrg,
                                                                                                                 recordtypeId = recordTypeIdVal,
                                                                                                                cgcloud__Description_Language_1__c=testStr+randomInt);
   		return prodAssortment;
    }
    
    /***********************************************************************************************************************
    * @method			: createProductDataWithTemplate
    * @ return     		: void
     * @param              salesOrg
    * @param   		      recordType
    * @param   		      prodLevel
    * @param   		      count
    * @description    	: Method to create product template test data with
    * 					  Productname,Sales Org,Recordtype Name,Productlevel,Template if required
    **************************************************************************************************************************/
    public static void createProductDataWithTemplate(String salesOrg, String recordType, String prodLevel,Integer count){
        
        List<Product2> createProdList = new List<Product2>();
        
        cgcloud__Product_Template__c prodTempObj = new cgcloud__Product_Template__c();
        prodTempObj.Name = salesOrg+' '+recordType+' '+testStr;
        prodTempObj.RecordTypeId = Schema.SObjectType.cgcloud__Product_Template__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        prodTempObj.cgcloud__Sales_Org__c = salesOrg;
        prodTempObj.cgcloud__Description_Language_1__c = salesOrg+' '+recordType+' '+testStr;
        prodTempObj.cgcloud__Active__c = True;
        
        //Insert Product template record
        insert prodTempObj;
        
        
        //Create test product data 
        for(Integer itr = 1; itr <= count; itr++){
            Product2 prodObj = new Product2();
            prodObj.Name = salesOrg+' '+recordType+' '+testProductName+' '+itr;
            prodObj.cgcloud__Product_Template__c =prodTempObj.id;
            prodObj.TPM_SAP_Sales_Org__c = salesOrg;
            prodObj.cgcloud__Consumer_Goods_External_Product_Id__c = salesOrg +'CGPRID'+itr;
            prodObj.cgcloud__Consumer_Goods_Product_Code__c = salesOrg +'CGPRC'+itr;
            prodObj.cgcloud__Description_1_Language_1__c = salesOrg+' '+recordType+' '+testProductName+' '+itr;
            prodObj.cgcloud__Product_Level__c = prodLevel;
            prodObj.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            createProdList.add(prodObj);
        }
        
        //Insert the test data list of Product Records
        if(!createProdList.isEmpty()){
            
            insert createProdList;
            
        }
    }
    /******************************************************************************************
    * @method			: createCGCloudSalesOrg
    * @return     		: cgcloud__Sales_Organization__c
    * @param              salesOrgName
    * @description    	: Method to create sales org test records.
    ******************************************************************************************/
    public static cgcloud__Sales_Organization__c createCGCloudSalesOrg(String salesOrgName){
        
        cgcloud__Sales_Organization__c salesOrgObj = new cgcloud__Sales_Organization__c();
        salesOrgObj.Name = salesOrgName;
        salesOrgObj.cgcloud__Sales_Org_Value__c = salesOrgName;
        salesOrgObj.cgcloud__Currency__c = 'USD';
        salesOrgObj.cgcloud__Distance_Unit__c = 'km';
        salesOrgObj.cgcloud__Description_Language_1__c = 'Test Description' + salesOrgName;
        salesOrgObj.cgcloud__Language_1__c = 'en';
        salesOrgObj.cgcloud__Account_Product_List_Type__c = 'global';
        salesOrgObj.cgcloud__Used_Reference_Date__c = 'startdate';
        salesOrgObj.cgcloud__Promotion_Access_Definition_Policy__c = 'Independent_Anchors';
        salesOrgObj.cgcloud__Promotion_Aggregation_Level__c = 'Category';
        salesOrgObj.cgcloud__First_Day_Of_Week__c = '1';
        salesOrgObj.cgcloud__First_Week_Of_Year__c = '1';
        
        return salesOrgObj;
    }
    
    /******************************************************************************************
    * @method			: createTestAccount
    * @return     		: Account
    * @param              hierarchy
    * @param   		      salesOrg
    * @param   		      customerTemplateId
    * @param   		      parentIdVal
    * @description    	: Method to create accounts for a specific hierarchy (Customer) with a customer template
    ******************************************************************************************/

    public static Account createAccountWithTemplateAndParent(String hierarchy,String salesOrg,Id customerTemplateId, Id parentIdVal) {
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        Account accountObj = new Account(Name = testCustomerName+randomInt, cgcloud__Account_Number__c = 'CE'+randomInt,cgcloud__Account_Template__c=customerTemplateId,
                                         TPM_Hierarchy_Level__c = Hierarchy, cgcloud__ExternalId__c = '098'+randomInt,TPM_IsActive__c=true, parentId = parentIdVal);
         return accountObj;
    
    }
    
    /******************************************************************************************
    * @method			: createAssortment
    * @param              accountList
    * @param   		      assortmentTemplate
    * @param   		      productid
    * @description    	: Method to create assortmentHeader for an account
    ******************************************************************************************/
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    public static void createAssortmentHeaders(List<Account> accountList, Id assortmentTemplate, Id productid) {
        
        Date thruD =  Date.newInstance(2099, 12, 31);
       Map<String,Assortment> asortmentMap = new Map<String,Assortment>();
        List<StoreAssortment> storeAssortmentList = new List<StoreAssortment>();
        List<cgcloud__Product_Assortment_Product_Share__c> prodAssortmentList = new List<cgcloud__Product_Assortment_Product_Share__c>();
        
        for(Integer intVar = 0; intVar < accountList.size(); intVar++){
            
            Assortment assortmentObj  = new  Assortment(name = 'Assortment-'+accountList[intVar].name+'-'+'IT01',
                                                        cgcloud__Product_Assortment_Template__c = assortmentTemplate,
                                                        cgcloud__Valid_From__c = system.today(),
                                                        cgcloud__Valid_Thru__c = thruD);
            
            asortmentMap.put(accountList[intVar].Id, assortmentObj);
            //insert assortmentObj;
        }
        insert asortmentMap.values();
            
        for(Integer intVar = 0; intVar < accountList.size(); intVar++){
            
            StoreAssortment storeAssortmentobj = new StoreAssortment(EndDate=asortmentMap.get(accountList[intVar].Id).cgcloud__Valid_Thru__c,
                                                                     StartDate = System.today(),
                                                                     accountid = accountList[intVar].Id,
                                                                     AssortmentId = asortmentMap.get(accountList[intVar].Id).Id);
            
            storeAssortmentList.add(storeAssortmentobj);
        }
        insert storeAssortmentList;
            
            
        for(Integer intVar = 0; intVar < storeAssortmentList.size(); intVar++){
            cgcloud__Product_Assortment_Product_Share__c productCategoryObj = new cgcloud__Product_Assortment_Product_Share__c(
                cgcloud__Product_Assortment__c = storeAssortmentList[intVar].AssortmentId,
                cgcloud__Product__c = productid);
            
            prodAssortmentList.add(productCategoryObj);
        }
        
        insert prodAssortmentList;
            
       }
        
    
        
}