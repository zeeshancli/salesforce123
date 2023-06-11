/*********************************************************************************************
* @Name         : TPM_AutomationConstantUtilityClass
* @author       : PwC Team
* @date         : December 22, 2022
* @description  : Constants Class for TPM automation
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/
public with sharing class TPM_AutomationConstantUtilityClass {

//Final Variables for DataLoadAutomation
//Planning mode values
public static final String PLANNING_MODE_MONTHLY = 'Monthly';
public static final String PLANNING_MODE_WEEKLY = 'Weekly';
//Week day share profile value
public static final string WEEKDAY_SHARE_PROFILE = ' Week Day Share Profile';
//Date for creation of business year
public static final string FROMDATE = '1/1/';
public static final string TODATE = '12/31/';
//Calendar value
public static final string CALENDAR = 'Calendar_';
public static final string CALENDARSPACE = ' Calendar';
//picklist value for metadata as object name for metadatawizard
public static final string METADATA_WIZARD = 'cgcloud__Metadata_Wizard_Configuration__c';
//picklist value for metadata as object name for Business year
public static final string BUSINESS_YEAR = 'cgcloud__Business_Year__c';
public static final string BUSINESS_YEAR_SPACE = 'Business Year ';
//picklist value for metadata as object name for Week day share profile
public static final string WEEKDAY_PROFILE = 'cgcloud__Week_Day_Share_Profile__c';
public static final string WEEKDAY_PROFILE_VALUES = 'Week_Day_share_Profile_values';
//Method name for custom period
public static final string PRODUCT = 'Product';
//Value for all when all records to be inserted
//Value for creating description of product template
//Value for creating description of Customer template
//KPI set
//Method name for weekday share profile
public static final string WEEKDAYPROFILELOAD = 'weekDayProfileLoad';
//Method name for sales org
public static final string SALESORGLOAD = 'salesOrgLoad';
//Method name for Business year
public static final string BUSINESSYEARLOAD = 'businessYearLoad';
//Method name for Customer Template
public static final string CUSTOMERTEMPLATELOAD = 'customerTemplateLoad';
public static final string CUSTOMPERIODUPLOAD = 'customPeriodUpload';
public static final string CUSTOMERTEMPLATEPLANNINGMODE = 'cgcloud__Account_Template__c';
public static final string CUSTOMCALENDARLOAD = 'customCalendarLoad';
public static final string METAWIZARDLOAD = 'metaWizardLoad';
public static final string PRODUCTASSORTMENTLOAD = 'productAssortmentLoad';
public static final string KPISETLOAD = 'kpiSetLoad';
public static final string PRODUCTTEMPLATELOAD = 'productTemplateLoad';
public static final string TPMINITIALDATALOAD = 'TPM_InitialDataLoad';
public static final string MONDAY = 'Monday';
public static final string TUESDAY = 'Tuesday';
public static final string WEDNESDAY = 'Wednesday';
public static final string THURSDAY = 'Thursday';
public static final string FRIDAY = 'Friday';
public static final string SATURDAY = 'Saturday';
public static final string SUNDAY = 'Sunday';
//Custome error message for weekday
public static final string ERRORMESSAGEFORSALESORG = 'Week Day Profile record doesnot exist for this ';
public static final string ERRORMESSAGEFORSALESORGCONTINUE = '.Create Week Day Profile Record first and then try to create Sales Org Record.';
//Custome error message for Sales Org
public static final string ERRORMESSAGEFORBYEAR = ' Sales Org record is not yet created';
public static final string ERRORMESSAGEFORBYEARCONTINUE = '.Create Sales Org Record first and then try to create Business Year Record.';
public static final string ERRORMESSAGEFORCUSTPERIOD = ' Custom calendar record is not yet created for ths sales Org ';
public static final string ERRORMESSAGEFORCUSTPERIODCONTINUE = '.Create Custom calendar Record first and then try to create Custom Period Record.';
public static final string SALESORGOBJECTNAME = 'cgcloud__Sales_Organization__c';
public static final string WEEKDAYSHAREPROFILEFIELD = 'cgcloud__Week_Day_Share_Profile__c';
public static final string CHECKBOX = 'CheckBox';
public static final string SALESORGFIELD = 'cgcloud__Sales_Org_Value__c';
public static final string CUSTOMERTEMP = ' Customer Template';
public static final string PRODUCTGROUPTEMP = 'Product Group_ ';
public static final string PRODUCTTEMP = 'Product_ ';
public static final string UNDERSCORE = '_';
public static final string MOUS = 'MOUS_';
public static final string WEEK = 'WK_';
public static final string ASSORTMENT = ' Assortment';
public static final string ASSORTMENTTEMPLATE = 'AssortmentTemplate';
public static final string ONE = '1';
//final string variables for BO Object methods
public static final string GETBOAPIENTITY = 'getBoApiEntity';
public static final string GETBOAPI = 'createBoApi';
public static final string CREATEBOAPIWORKFLOW = 'createBoApiWorflow';
//Concatenation value
public static final string PROMOTION = 'Promotion';
//Method name for bo api methods
public static final string CREATEBOAPIWORKFLOWSTEP = 'createBoApiWorflowStep';
public static final string CREATEBOAPIWORKFLOWSTEPINPUT = 'createBoApiWorflowStepInput';
public static final string CREATEBOAPIWORKFLOWWFSTEP = 'createBoApiWorkflowWfStep';
public static final string CREATEBOAPIENTITY = 'createBoApiEntity';
public static final string CREATEBOAPIOUTPUTENTITY = 'createBoApiOutputEntity';
public static final string CREATEBOAPIOUTPUTWORKFLOWENTITY = 'createBoApiOutputWorkflowEntity';
public static final string CGCLOUDSALESORG = 'cgcloud__Sales_Org__c';
public static final string CGCLOUDBUSINESSYEAR= 'cgcloud__Business_Year__c';
public static final string PLANNINGMODE= 'PLANNINGMODE';
public static final string TPMSALESORG= 'TPM_Sales_Org__c';
public static final string NAMEFORKPISET = 'Name';
public static final string APIWORKFLOW = 'cgcloud__BO_API_Workflow__c';
public static final string APIWORKFLOWSTEP = 'cgcloud__BO_API_Workflow_Step__c';
public static final string APISTEPINPUT = 'cgcloud__BO_API_Step_Input_Structure__c';
public static final string APIOUTPUTENTITY = 'cgcloud__BO_API_Output_Entity__c';
public static final string APIWORKFLOWENTITY = 'cgcloud__BO_API_Workflow_Entity__c';
public static final string APIWORKFLOWWORKFLOWSTEP = 'cgcloud__BO_API_Workflow_Workflow_Step__c';
public static final string BOAPIENTITY = 'cgcloud__BO_API_Entity__c';
public static final string KPISET = 'cgcloud__KPI_Set__c';

}