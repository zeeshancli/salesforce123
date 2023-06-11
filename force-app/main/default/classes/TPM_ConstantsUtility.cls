/*********************************************************************************************
* @Name         : TPM_ConstantsUtility
* @author       : PwC Team
* @date         : December 8, 2022
* @description  : Constants Class
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/

public inherited sharing class TPM_ConstantsUtility {
    
    //Number Constants
    public static final Integer NUMBER_1 = 1;
    public static final Integer NUMBER_200 = 200;
    public static final Integer NUMBER_9 = 9;
    
    // Account Constants
    public static final String ACT_HIERARCHY_MANAGED_ACCOUNT = 'Managed Account';
    public static final String ACT_HIERARCHY_SOLDTO_ACCOUNT = 'Sold-To';
    public static final String ACT_TEMPLATE_GENERAL = 'General';
    public static final String ACT_CUSTOMER_RECORDTYPEAPI = 'Customer';
    public static final String ACT_VENDOR_RECORDTYPEAPI = 'TPM_Vendor';
    
    //Assortment Constants :
    public static final String PLANNING_ASSORTMENT_TEMPLATE_RECORDTYPE = 'Planning Assortment List';
    public static final String OBJECT_ASSORTMENT = 'Assortments';
    public static final String RECORD_NAME_ASSORTMENT = 'Assortment';
    public static final String PROD_ASSORTMENT_CATEGORY = 'Product Assortment Category';
    public static final String STORE_ASSORTMENT = 'Store Assortments';
    public static final String TOP_NODE_PRODUCT = 'Category';
   
    
    // User setting record mapping#137
    public static final String MANAGEMENT_TYPE = 'Sales';
    
    // Apex Class Names
    public static final String BATCH_CUSTOMERTEMP_ASSIGNMENT = 'TPM_CustomerTemplateAssignmentBatch';
    public static final String BATCH_CUSTOMEREXTENSION_ASSIGNMENT = 'TPM_CustomerExtentionBatch';
    public static final String BATCH_CUSTOMERHIERARCHY_AUTOMATION = 'TPM_CustomerHierarchyBatch';
    public static final String USER_TRIGGER_HELPER = 'TPM_UserTriggerHelper';
    public static final String BATCH_PRODUCT_TEMP_ASSIGNMENT = 'TPM_ProductTemplateAssignmentBatch';
    public static final String USER_TRIGGER_HANDLER = 'TPM_UserTriggerHandler';
    public static final String BATCH_PRODUCTRHIERARCHY_AUTOMATION = 'TPM_ProductHierarchyCreationBatch';
    public static final String ACCOUNT_TRIGGER_HELPER = 'TPM_AccountTriggerHelper';
    public static final String ACCOUNTTEAM_TRIGGER_HELPER = 'TPM_AccountTeamTriggerHelper';
    public static final String ACCOUNTTEAM_TRIGGER_HANDLER = 'TPM_AccountTeamTriggerHandler';
    public static final String BATCH_PARENT_ACCOUNT_AUTOMATION = 'TPM_ParentAccountBatch';
    public static final String SALES_ORG_USER_TRIGGER_HELPER = 'TPM_SalesOrgUserTriggerHelper';
    public static final String SALES_ORG_USER_TRIGGER_HANDLER = 'TPM_SalesOrgUserTriggerHandler';
    public static final String TRIGGER_PROMOTION_HELPER = 'TPM_PromotionTriggerHelper';
    public static final String TRIGGER_ACCOUNTPLAN_HELPER = 'TPM_AccountPlanTriggerHelper';
    public static final String BATCH_ASSORTMENT_CREATION = 'TPM_AssortmentCreationBatch';
    public static final String BATCH_ASSORTMENT_HELPER = 'TPM_AssortmentCreationHelper';
    public static final String BATCH_PRD_FLATTENING_CATEGORY = 'TPM_ProductFlatteningCategoryBatch';
    public static final String BATCH_PRD_FLATTENING_REPORTGP = 'TPM_ProductFlatteningReportGrpBatch';
    public static final String BATCH_PRD_FLATTENING_BATTERYDT = 'TPM_ProductFlatteningBatteryDTBatch';
    public static final String BATCH_PRD_FLATTENING_PACKSIZE = 'TPM_ProductFlatteningPackSizeBatch';
    public static final String BATCH_PRD_FLATTENING_UPCEAN = 'TPM_ProductFlatteningUPCEANBatch';
    public static final String TRIGGER_STORE_ASSORTMENT_HELPER = 'TPM_StoreAssortmentTriggerHelper';
    public static final String TRIGGER_ASSORT_PROD_HELPER = 'TPM_AssortmentProductTriggerHelper';
    public static final String TRIGGER_ASSORT_PROD_HELPER_EXTENSION2 = 'TPM_AssortmentProductHelperExtension2';
    public static final String USER_TRIGGER_HELPER_EXTENSION = 'TPM_UserTriggerHelperExtension';
    public static final String SALES_ORG_USER_TRIGGER_HELPER_EXTENSION = 'TPM_SalesOrgUserTriggerHelperExtension';
    public static final String TPM_DISPLAY_SHIPPER_COMPONENT = 'TPM_ComponentVolumeWebService';
    public static final String TPM_PROMOTION_MAIN_CARD_CONTROLLER = 'PromotionMainCardController';
    public static final String TRIGGER_CBP_CATEGORY_HELPER = 'TPM_CBPCategoryTriggerHelper';
    public static final String TPM_US01_CALCULATION_CHAIN_BATCH = 'TPM_US01CalculationChainBatch';
    public static final String TPM_IT01_CALCULATION_CHAIN_BATCH = 'TPM_IT01CalculationChainBatch';
    public static final String TPM_ACC_SVF_EXTID_BATCH = 'TPM_AccountSVFAssignmentBatch';
    public static final String BATCH_POPULATION_EXTERNALID = 'TPM_PopulateExternalIdForPromotionBatch';
    
    
    // Apex Method Names
    public static final String CREATE_USER_SETTING = 'createUserSetting';
    public static final String AFTER_INSERT_TRIGGER = 'afterInsert';
    public static final String AFTER_UPDATE_TRIGGER = 'afterUpdate';
    public static final String AFTER_DELETE_TRIGGER = 'afterDelete';
    public static final String ASSIGN_USER_TO_GROUP = 'assignUserToGroup';
    public static final String REMOVE_ASSIGNMENTS = 'removeAssignmentsForUser';
    public static final String ASSIGN_TEAM_MEMBER = 'assignAccountTeamMember';
    public static final String REMOVE_TEAM_MEMBER = 'removeAccountTeamMember';
    public static final String HANDLE_UPSERT_DML = 'handleUpsertDML';
    public static final String HANDLE_UPDATE_DML = 'handleUpdateDML';
    public static final String UPDATE_ACCOUNT_RECORDS = 'upsertAccountRecords';
    public static final String ASSIGN_ASSORTPROD_RECORDS = 'assignAssortmentProductForHierarchy';
    public static final String UPDATE_ASSORTPROD_RECORDS = 'updateAssortmentProdFromHierarchy';
    public static final String DELETE_ASSORTPROD_RECORDS = 'removeAssortmentProdFromHierarchy';
    public static final String HANDLE_INSERT_USER = 'handleInsertOperation';
    public static final String HANDLE_DELETE_USER = 'handleDeleteOperation';
    public static final String BEFORE_INSERT_TRIGGER = 'beforeInsert';
    public static final String BEFORE_UPDATE_TRIGGER = 'beforeUpdate';
    public static final String REGISTER_TRANSACTION_ID = 'registerTransactionId';
    public static final String GET_DATA_FOR_SINGLE_PROMOTION = 'getDataForPromotionCustomPeriod';
    public static final String CREATE_REQUEST_JSON_BODY = 'createRequestJSONBody';
    public static final String SEND_ACCOUNT_PRODUCT_MEASURE = 'sendAccountProductMeasure';
    public static final String GET_REGISTERED_TRANSACTION_ID = 'registerTransactionId';
    public static final String EXECUTE_TPM_CACULATION_CHAIN_BATCH = 'executeTPMCalculationChainBatch';
    public static final String UPDATE_BATCH_FLAG_ACCOUNT = 'updateFieldsForAccounts';
    public static final String US01_CALCULATION_CHAIN_BATCH_FINISH_METHOD = 'TPM_US01CalculationChainBatch Finish';
    public static final String IT01_CALCULATION_CHAIN_BATCH_FINISH_METHOD = 'TPM_IT01CalculationChainBatch Finish';
    public static final String HANDLE_DRAFT_COPIED = 'handleDraftForCopied';
    public static final String HANDLE_DEFAULT_DRAFT_PHASE = 'handleDefaultDraftPhasePromotion';
    
    
    //Log level
    public static final String ERROR = 'Error';
    public static final String FATAL = 'Fatal';
    public static final String CUST_ERROR = 'Product Template is not Available';
    public static final String CUSTOMERTEMPLATE_NOT_FOUND = 'Customer Template is not avaiable';
    public static final String AT_LINE_NUMBER = ' at Line Number : ';
    
    //Logger Module
    public static final String ERROR_MODULE = 'Logger Module';


    //Trigger Exception
    public static final String TRIGGER_EXCEPTION = 'No Trigger Handler registered for Object Type: ';
    public static final String DEFAULT_TRIGGER_ERROR_MSG = 'Default sales organization can only have value selected in Available Sales Organization';

    //Customer Extension Batch Constants
    public static final Map<String, String> ORG_LEVEL_MAPPING = new Map<String, String>{'SuperGroup' => 'CustLevel01', 'Group' => 'CustLevel02', 'Managed Account' => 'CustLevel03', 'Sold-To' => 'CustLevel04'};
    public static final String CUSTOMER_RECORDTYPE_NAME = 'Customer';
    public static final String MANAGED_ACCOUNT = 'Managed Account';
    public static final String PLAN = 'Plan';
    public static final String SUPER_GROUP = 'SuperGroup';
    public static final String GROUP_NAME = 'Group';
    public static final String ACTIVE_CODE = '010';
    public static final Date VALID_THRU_DATE = Date.newInstance(2099, 12, 31); 

    //User Creation Constants
    public static final String EN_US = 'en_US';

    //Customer Hierarchy Batch Constants
    public static final String CONVERT_STATUS_COMPLETE = 'Complete';
    public static final String CONVERT_STATUS_FAILED = 'Failed';
    public static final String CONVERT_STATUS_REPROCESS = 'Reprocess';
    public static final String CUSTOMER_HIERARCHY_LEVELS = 'CustomerHierarchyLevels';

    //Constant for Batch Sequencing
    public static final String IS_BATCH_SEQUENCING = 'True';
    
    //Constant for External Id Population
    public static final Map<String,String> PLAN_MODE_MAP = new Map<String,String>{'Basic' => 'Ba', 'Intermediate' => 'Int'};   // added as part of User Story No : 720  
    public static final String EMPTY_SAP_SALES_ORG ='SAP External ID field is empty';   // added as part of User Story No : 720 
    
    //Constant for team role value-Account Team Member
    public static final String MANAGED_ACCOUNT_MEMBER = 'Managed Account Member';
    
    // Constants for product hierarchy.
    public static final String PROD_HS_STATUS_NEW = 'New';

    //Constant for Total Sales Org Hierarchy Level
    public static final String TOTAL_SALES_ORG = 'Total Sales Org';

	// PBI-1606 : Constants for customer hierarchy.
	public static final String CUST_HS_STATUS_NEW = 'New';
    
	// Query Definition Constants
	public static final String EXISTING_SOBJECTS_SHARED_RECORDS = 'TPM_ExistingsObjectsSharedRecords';
	public static final String TPM_US01_NIGHTLY_BATCH_QUERY = 'TPM_US01NightlyBatchQuery';
    public static final String TPM_IT01_NIGHTLY_BATCH_QUERY = 'TPM_IT01NightlyBatchQuery';
    public static final String TPM_US01_CALCULATIONCHAIN_BATCH_QUERY = 'TPM_US01CalculationChainBatchQuery';
    public static final String TPM_IT01_CALCULATIONCHAIN_BATCH_QUERY = 'TPM_IT01CalculationChainBatchQuery';

        
	// Record Sharing AccessLevel
	public static final String ACCESSLEVEL_EDIT = 'Edit';
    public static final String PARENTID_FIELD = 'ParentId';
    public static final String ROWCAUSE_MANUAL = 'Manual';

	// Share Object Names
	public static final String PROMOTION_SHARE = 'cgcloud__Promotion__Share';
	public static final String ACCOUNTPLAN_SHARE = 'cgcloud__Account_Plan__Share';
    public static final String ASSORTMENT_SHARE = 'assortmentshare';
    
    //Constant for KPI Subset CMDT for User Settings Creation
    public static final String KPI_PROMO_SUBSET_CMDT_LABEL = 'TPM_Promo_KPI_Subset';
    
    //Constant for Product Manager Record Trigger 
    public static final String ACTIVE = 'Active';
    public static final String INACTIVE = 'Inactive';
    public static final String READ_WRITE_ACCESS = 'Read/Write';
    public static final String PRODUCT_CATEGORY = 'Category';

    //Constants for records approval 
    public static final String FIELDSMAPPING_METADATA_API = 'TPM_FieldsMapping__mdt';
    public static final String CUSTOMMAPPING_METADATA_API = 'TPM_CustomMappings__mdt';
    public static final List<String> FIELDSMAPPING_METADATA_FIELDSLIST = new List<String>{'TPM_Condition__c', 'TPM_ConditionCriteria__c', 'TPM_DefaultValue__c', 'TPM_FromFieldApi__c', 'TPM_IsLookup__c', 'Lookup_Relationship_Notation__c', 'TPM_ProcessName__c','TPM_ToFieldApi__c','TPM_UseDefaultValue__c'};
    public static final List<String> CUSTOMMAPPING_METADATA_FIELDSLIST = new List<String>{'TPM_Key__c', 'TPM_ProcessName__c', 'TPM_Sequence_Number__c', 'TPM_Sequence__c', 'TPM_Value__c'};    
    public static final Map<String,Object> FIELDSMAPPING_CRITERIAMAP_APPROVALPROMOTION = new Map<String,Object>{'TPM_ProcessName__c' => 'TPM_ApprovalPromotion'};
    public static final Map<String,Object> FIELDSMAPPING_CRITERIAMAP_APPROVALTACTICS = new Map<String,Object>{'TPM_ProcessName__c' => 'TPM_ApprovalTactic'};
    public static final Map<String,Object> CUSTOMMAPPING_CRITERIAMAP_PROMOTIONAPPROVALROUTING = new Map<String,Object>{'TPM_ProcessName__c' => 'TPM_PromotionApprovalRouting'};
    public static final String PHASE_SUBMITTEDFORAPPROVAL = 'Submitted For Approval';
    public static final String OBJECT_APPROVAL = 'TPM_Approval__c';
    public static final String APPROVALTACTIC_FIELD_APPROVAL = 'TPM_Approval__c';
    public static final String OBJECT_APPROVALTACTICS = 'TPM_Approval_Tactics__c';    
    public static final String APPROVAL_FIELD_ISDISPLAY = 'TPM_Is_Display__c';    
    public static final String BOM_HANDLER_VAL_CONSIDER = 'ConsiderBOMs'; 
    public static final String PHASE_DRAFT = 'Draft'; 
	public static final String PHASE_PLANNING = 'Planning';
    public static final String PHASE_MODELLING = 'Modeling'; 
    public static final String PHASE_SUBMITFORAPPROVAL = 'Submitted for Approval'; 
    public static final String PHASE_FORAPPROVAL = 'For Approval'; 
    public static final String PHASE_APPROVED = 'Approved'; 
    public static final String PHASE_COMMITED = 'Committed'; 
    public static final String PHASE_CLOSED = 'Closed'; 
    public static final String PHASE_CANCELLED = 'Cancelled'; 
    public static final String PHASE_FINANCE_EDIT = 'Finance Edit'; 
    public static final String FIELD_RECORDTYPEID = 'RecordTypeId'; 
    public static final String RECORDTYPE_PROMOTION = 'TPM_Promotion'; 
    public static final String APPROVAL_LEVEL_NA = 'NA'; 
    public static final String OVERLAPCHECKMETADATA = 'OverLapCheck';
    public static final String PRD = 'prd'; 
    public static final String TAC = 'tac'; 
    public static final String NOOVERLAPFOUND = 'No Overlap Found'; 
    public static final String OVERLAPFOUND = 'Overlap Found'; 
    public static final String OVERLAPINPROGRESS = 'OverLap Check In Progress'; 

    
    // Constants for Component Volume from Display Shipper Class
    public static final String TRANSACTION_ID_ERROR = 'Hyperforce Transaction Id registration failed';
    public static final String CUSTOM_PERIOD = 'customperiod';
    public static final String GET_DATA_SINGLE_PROMOTION_ERROR = 'Failed to fetch Promotion Record';
    public static final String SEND_ACCOUNT_PRODUCT_MEASURE_ERROR = ' Account Product Measure Table API Callout Failed ';
    public static final String NUMBER_ZERO_AS_STRING = '0';
    public static final String PRODUCT_LEVEL_PRODUCT = 'Product';
    public static final String BOM_REQUEST_BODY_MEASURE_CODE_INT = 'PDVL';
    public static final String ACCOUNT_PRODUCT_MEASURE_CODE = 'ADCV';
    public static final String BOM_REQUEST_BODY_MEASURE_CODE_BASIC = 'DSVL';
    public static final string TPMOVERLAPCHECKCONTROLLER = 'TPM_OverLapCheckController';
    public static final string TPMOVERLAPCHECKQUEABLE = 'TPM_OverLapCheckQueable';
    public static final String TPM_PROMOTION_TRIGGER_HELPER_EXTENSION = 'TPM_PromotionTriggerHelperExtension';
    public static final String HANDLEFIELDUPDATEFORACCOUNT = 'handleFieldUpdateForAccount';
    
    // Constants for Tactic RT
    public static final String PRICE_REDUCTION_RT = 'PriceReduction';
    
    // Constants for TPMCalculationNightlyBatch
    public static final String TPM_EXECUTE_US01_NIGHTLY_BATCH = 'TPM_Execute_US01_Nightly_Batch';
    public static final String TPM_EXECUTE_IT01_NIGHTLY_BATCH = 'TPM_Execute_IT01_Nightly_Batch';
    public static final String TPM_EXECUTE_US01_CALCHAIN_BATCH= 'TPM_EXECUTE_US01_CALCHAIN_BATCH';
    public static final String TPM_EXECUTE_IT01_CALCHAIN_BATCH= 'TPM_EXECUTE_IT01_CALCHAIN_BATCH';
    public static final String TPM_US01_CALCULATION_CHAIN_QUEUE = 'TPM_US01CalculationChainQueue';
    public static final String TPM_IT01_CALCULATION_CHAIN_QUEUE = 'TPM_IT01CalculationChainQueue';
    public static final String US01_CALCULATION_CHAIN_QUEUE_EXECUTE_METHOD = 'TPM_US01_CALCULATION_CHAIN_QUEUE EXECUTE METHOD';
    public static final String IT01_CALCULATION_CHAIN_QUEUE_EXECUTE_METHOD = 'TPM_IT01_CALCULATION_CHAIN_QUEUE EXECUTE METHOD';
    //Parent Promotions 
    public static final List<String> PARENT_PUSH_PROMOTIONS = new List<String>{'Child_LTA_IT01', 'Child_OtherPrograms_IT01', 'Child_ShortTermEvent_IT01', 'Child_VolumePush_IT01'};
    // Approval Card Component
    public static final String BASE_URL = (String.valueOf(System.Url.getSalesforceBaseUrl().toExternalForm()));
    public static final String LIGHTNING_URL = BASE_URL.replace('my.salesforce.com','lightning.force.com');
    public static final String LIGHTNING_RELATED_PATH = '/lightning/r/TPM_Approval__c/';
    public static final String LIGHTNING_URL_VIEW = '/view';
    
    // User Automation Batch
    public static final String TPM_USER_AUTOMATION_BATCH_PROCESS_NAME = 'TPM_UserAutomationBatch';
    public static final String TPM_USER_AUTOMATION_BATCH_CMDT_NAME = 'TPM_User_Automation_Batch';

    // Customer Deactivation Batch
    public static final String TPM_CUSTOMER_DEACTIVATION_BATCH_QUERY = 'TPM_CustomerDeactivationBatch';
    public static final String TPM_CUSTOMER_DEACTIVATION_BATCH = 'TPM_CustomerDeactivationBatch';

    //RTR REST API Parameters
    public static final String TPM_RTR_BUSINESSYEAR = 'businessyear';
    public static final String TPM_RTR_SALESORG = 'salesorg';
    public static final String TPM_RTR_METANAME = 'metaname';
    public static final String TPM_RTR_CSVGUID = 'csvguid';
    public static final String TPM_RTR_ERRORMSG = 'Please provide values for the required fields';
}