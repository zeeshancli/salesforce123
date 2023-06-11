/*****************************************************************************************************
* @Name         : TPM_TestDataUtilityExtension
* @author       : PwC Team
* @date         : January 31, 2023
* @description  : Test Data Utility
*****************************************************************************************************
Change History Story      Modified by               Date                          Desc

******************************************************************************************************/
@SuppressWarnings('sf:TestClassWithoutTestCases')
@isTest

public class TPM_TestDataUtilityExtension {
    
    /********************************************************************************************
	* @method         : createPromotionTemplate
	* @return		  : cgcloud__Promotion_Template__c
	* @description    : Method to create promotion template record.
	*********************************************************************************************/
    public static cgcloud__Promotion_Template__c createPromotionTemplate() {
        
        
         // Create promotion template records.
        cgcloud__Promotion_Template__c testprod = new cgcloud__Promotion_Template__c(Name = 'DisplayShipper_Intermediate_IT01',
        cgcloud__Promotion_Type__c =  'Promotion',
        cgcloud__Active__c = true,
        RecordTypeId = Schema.SObjectType.cgcloud__Promotion_Template__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(),
        cgcloud__Sales_Org__c = 'US01',
        cgcloud__Description_Language_1__c = 'Test',
        cgcloud__Available_Product_Level__c = 'Category;SubCategory;Brand;Flavor',
        cgcloud__Calculation_Mode__c = 'No',
        cgcloud__Displayed_Product_Level__c = 'Category;SubCategory;Brand;Flavor',
        cgcloud__Anchor_Type__c = 'Customer',
        cgcloud__Display_Fund_Card__c = true,
        cgcloud__Promo_Phases_Cleaning__c = 'Preparation',
        cgcloud__UI_Type__c = 'SmartUI',
        cgcloud__Product_Definition_Policy__c = 'Dynamic;Static',
        cgcloud__BOM_Handler__c ='ConsiderBOMs');
		

        return testprod;
    }
    
    /********************************************************************************************
	* @method         : createTacticsTemplate
	* @return		  : cgcloud__Tactic_Template__c
	* @description    : Method to create tactic template record.
	*********************************************************************************************/
    public static cgcloud__Tactic_Template__c createTacticsTemplate() {
        
        // Create tactics template records.
        cgcloud__Tactic_Template__c objTactictemplate = new cgcloud__Tactic_Template__c(
            Name = 'TacticTemplateUS01',
            cgcloud__Active__c =  true,
            cgcloud__Tactic_Type__c = 'Display',
            cgcloud__Possible_Lift_Types__c = 'Percentage',
            cgcloud__Default_Lift_Type__c = 'Percentage',
            cgcloud__Description_Language_1__c = 'test desc',
            cgcloud__Display_KPI_Subset__c = 'SPC'
        );
        
        return objTactictemplate;
    }
    
    /********************************************************************************************
	* @method         : createPromotion
	* @return		  : cgcloud__Promotion__c
    * @param		    accountId
    * @param		    promotionTemplateId
	* @description    : Method to create promotion record.
	*********************************************************************************************/
    public static cgcloud__Promotion__c createPromotion(String accountId,String promotionTemplateId) {
        
        // Create promotion  record.
        cgcloud__Promotion__c testprod = new cgcloud__Promotion__c(cgcloud__Anchor_Account__c = accountId,
        cgcloud__Promotion_Template__c = promotionTemplateId,
        cgcloud__Slogan_Language_1__c = 'Test',
        cgcloud__Note__c = 'Test Notes',
        TPM_IsBypassValidationRule__c = false,
        cgcloud__Date_From__c= Date.newInstance(2024, 3, 5),
        cgcloud__Date_Thru__c=Date.newInstance(2024, 3, 27),
        cgcloud__Delivery_Date_From__c=Date.newInstance(2024, 3, 5),
        cgcloud__Delivery_Date_Thru__c=Date.newInstance(2024, 3, 25),
        cgcloud__Commit_Date__c=Date.newInstance(2024, 3, 5),
        cgcloud__Order_Date_From__c=Date.newInstance(2024, 3, 5),
        cgcloud__Order_Date_Thru__c=Date.newInstance(2024, 3, 27),
        cgcloud__Placement_Date_From__c=Date.newInstance(2024, 3, 7),
        cgcloud__Placement_Date_Thru__c=Date.newInstance(2024, 3, 27),
        cgcloud__Active__c= true);
        return testprod;
    }
    
     /********************************************************************************************
	* @method         : createPromotionWithPhase
	* @return		  : cgcloud__Promotion__c
    * @param		    accountId
    * @param		    promotionTemplateId
    * @param			promotionPhase
	* @description    : Method to create promotion record.
	*********************************************************************************************/
    public static cgcloud__Promotion__c createPromotionWithPhase(String accountId,String promotionTemplateId,String promotionPhase) {
        
        // Create promotion  record.
        cgcloud__Promotion__c testprod = new cgcloud__Promotion__c(cgcloud__Anchor_Account__c = accountId,
        cgcloud__Promotion_Template__c = promotionTemplateId,
        cgcloud__Slogan_Language_1__c = 'Test',
        cgcloud__Note__c = 'Test Notes',
        cgcloud__Date_From__c= Date.newInstance(2024, 3, 5),
        cgcloud__Date_Thru__c=Date.newInstance(2024, 3, 27),
        cgcloud__Delivery_Date_From__c=Date.newInstance(2024, 3, 5),
        cgcloud__Delivery_Date_Thru__c=Date.newInstance(2024, 3, 25),
        cgcloud__Commit_Date__c=Date.newInstance(2024, 3, 5),
        cgcloud__Order_Date_From__c=Date.newInstance(2024, 3, 5),
        cgcloud__Order_Date_Thru__c=Date.newInstance(2024, 3, 27),
        cgcloud__Placement_Date_From__c=Date.newInstance(2024, 3, 7),
        cgcloud__Placement_Date_Thru__c=Date.newInstance(2024, 3, 27),
        cgcloud__Active__c= true,
        TPM_Phase__c = promotionPhase);
        return testprod;
    }
    
    /********************************************************************************************
	* @method         : createTactic
	* @return		  : cgcloud__Tactic__c
    * @param		    promotionId
    * @param		    tacticTemplateId
	* @description    : Method to create promotion record.
	*********************************************************************************************/
    public static cgcloud__Tactic__c createTactic(String promotionId, String tacticTemplateId) {
        
        // Create Tactic record.
        cgcloud__Tactic__c objTactic = new cgcloud__Tactic__c(
            cgcloud__Promotion__c = promotionId,
            cgcloud__Tactic_Template__c = tacticTemplateId,
            cgcloud__Included__c = True,
            RecordTypeId = Schema.SObjectType.cgcloud__Tactic__c.getRecordTypeInfosByDeveloperName().get('Display').getRecordTypeId(),
            cgcloud__Date_From__c= Date.newInstance(2024, 3, 5),
            cgcloud__Date_Thru__c= Date.newInstance(2024, 3, 27),
            cgcloud__Plan_Spend__c = 50000,
        	TPM_Payment_Info__c ='Rebates');
        return objTactic;
    }
    
    /********************************************************************************************
	* @method         : createTriggerConditionCheck
	* @return		  : List<TPM_Trigger_Conditions_Check__c>
	* @description    :  Method to create custom setting : TPM_Trigger_Conditions_Check__c
	*********************************************************************************************/
    public static List<TPM_Trigger_Conditions_Check__c> createTriggerConditionCheck() {
        List<TPM_Trigger_Conditions_Check__c> configSettingList =  new List<TPM_Trigger_Conditions_Check__c>();
        TPM_Trigger_Conditions_Check__c conditionCheck = new TPM_Trigger_Conditions_Check__c();
        conditionCheck.TPM_Account_Prevent_Edit_Delete__c = true;
        conditionCheck.TPM_Assortment_Prevent_Edit_Delete__c =  true;
        configSettingList.add(conditionCheck);
        return configSettingList;
    
}

    /******************************************************************************************
    * @method			: createTacticTemplateBySalesOrg
    * @return     		: cgcloud__Tactic_Template__c
    * @param              salesOrgName
     * @param              tacticType
    * @description    	: Method to create tactice template test records.
    ******************************************************************************************/
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static cgcloud__Tactic_Template__c createTacticTemplateBySalesOrg(String salesOrgName, String tacticType){
        
        StaticResource sr= [select id,body from StaticResource Where Name = 'TPM_Sample_JSON'];
        
        TPM_UI_Definition__c uiDefObj = new TPM_UI_Definition__c();
        uiDefObj.TPM_Usage__c = 'Tactic';
        uiDefObj.TPM_JSON_Definition__c	= sr.body.toString();
        uiDefObj.TPM_Description_Language_1__c = 'test';
        insert uiDefObj;
        
        cgcloud__Tactic_Template__c ttObj = new cgcloud__Tactic_Template__c();
        ttObj.cgcloud__Tactic_Type__c = tacticType;
        ttObj.cgcloud__Sales_Org__c = salesOrgName;
        ttObj.cgcloud__Description_Language_1__c = 'Test';
        ttObj.TPM_UI_Definition__c = uiDefObj.Id;
        ttObj.cgcloud__Possible_Lift_Types__c = 'Percentage';
        ttObj.cgcloud__Default_Lift_Type__c = 'Percentage';
        ttObj.cgcloud__Display_KPI_Subset__c = 'SPC';
        
        return ttObj;
    }
    
    
    /******************************************************************************************
    * @method			: createPromotionTemplateBySalesOrg
    * @return     		: cgcloud__Tactic_Template__c
    * @param              salesOrgName
     * @param              promotionType
    * @description    	: Method to create promotion template test records.
    ******************************************************************************************/
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static cgcloud__Promotion_Template__c createPromotionTemplateBySalesOrg(String salesOrgName, String promotionType){
        
        StaticResource sr= [select id,body from StaticResource Where Name = 'TPM_Sample_Promotion_JSON'];
        
        TPM_UI_Definition__c uiDefObj = new TPM_UI_Definition__c();
        uiDefObj.TPM_Usage__c = 'Promotion';
        uiDefObj.TPM_JSON_Definition__c	= sr.body.toString();
        uiDefObj.TPM_Description_Language_1__c = 'test';
        insert uiDefObj;
        
        cgcloud__Promotion_Template__c ptObj = new cgcloud__Promotion_Template__c();
        ptObj.name = 'DisplayShipper_Intermediate_IT01';
        ptObj.cgcloud__Promotion_Type__c = promotionType;
        ptObj.cgcloud__Sales_Org__c = salesOrgName;
        ptObj.cgcloud__Description_Language_1__c = 'test';
        ptObj.cgcloud__UI_Type__c = 'SmartUI';
        ptObj.cgcloud__Product_Definition_Level__c = 'Promotion';
        ptObj.cgcloud__Product_Definition_Policy__c = 'Dynamic';
        ptObj.cgcloud__Consider_Product_KAM_Status__c = 'PromotionCommitDate';
        ptObj.cgcloud__BOM_Handler__c = 'ConsiderBOMs';
        ptObj.TPM_UI_Definition__c =uiDefObj.Id;
        
        return ptObj;
    }

    /********************************************************************************************
	* @method         : createPromotionTemplate
    * @param            promoTempName
	* @return		  : cgcloud__Promotion_Template__c
	* @description    : Method to create promotion template record.
	*********************************************************************************************/
    public static cgcloud__Promotion_Template__c createPromotionTemplateByName(String promoTempName) {
        
        
        // Create promotion template records.
       cgcloud__Promotion_Template__c testprod = new cgcloud__Promotion_Template__c(Name = promoTempName,
       cgcloud__Promotion_Type__c =  'Promotion',
       cgcloud__Active__c = true,
       RecordTypeId = Schema.SObjectType.cgcloud__Promotion_Template__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(),
       cgcloud__Sales_Org__c = 'US01',
       cgcloud__Description_Language_1__c = 'Test',
       cgcloud__Available_Product_Level__c = 'Category;SubCategory;Brand;Flavor',
       cgcloud__Calculation_Mode__c = 'No',
       cgcloud__Displayed_Product_Level__c = 'Category;SubCategory;Brand;Flavor',
       cgcloud__Anchor_Type__c = 'Customer',
       cgcloud__Display_Fund_Card__c = true,
       cgcloud__Promo_Phases_Cleaning__c = 'Preparation',
       cgcloud__UI_Type__c = 'SmartUI',
       cgcloud__Product_Definition_Policy__c = 'Dynamic;Static',
       cgcloud__BOM_Handler__c ='ConsiderBOMs');
       

       return testprod;
   }
    
}