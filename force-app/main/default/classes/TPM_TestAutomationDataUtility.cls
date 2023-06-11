/*****************************************************************************************************
* @Name         : TPM_TestAutomationDataUtility
* @author       : PwC Team
* @date         : January 13, 2022
* @description  : Test Data Utility
*****************************************************************************************************
Change History Story      Modified by               Date                          Desc

******************************************************************************************************/
public with sharing class TPM_TestAutomationDataUtility {
    
    //Test data for testing automated data load 
    //Test data for sales org
    public static final String TESTDATAFORSALESORG = 'Name,cgcloud__Sales_Org_Value__c,cgcloud__Currency__c,cgcloud__Distance_Unit__c,cgcloud__Description_Language_1__c,cgcloud__Language_1__c,cgcloud__Language_2__c,cgcloud__Language_3__c,cgcloud__Language_4__c,cgcloud__Account_Product_List_Type__c,cgcloud__Used_Reference_Date__c,cgcloud__Promotion_Access_Definition_Policy__c,cgcloud__Promotion_Aggregation_Level__c,cgcloud__First_Week_Of_Year__c,cgcloud__First_Day_Of_Week__c,cgcloud__Weight_Unit__c,cgcloud__Volume_Unit__c,cgcloud__Description_Language_2__c,cgcloud__Description_Language_3__c,cgcloud__Description_Language_4__c,cgcloud__Sales_Organization_Cluster__c,cgcloud__Street__c,cgcloud__City__c,cgcloud__Country__c,cgcloud__Zip_Code__c,cgcloud__Phone__c,cgcloud__Email__c,cgcloud__Tax_Jurisdiction_Code__c,cgcloud__Account_Number__c,cgcloud__Bank__c,cgcloud__Bank_Code__c,cgcloud__IBAN__c,cgcloud__BIN__c,cgcloud__SWIFT__c,cgcloud__Enable_Auto_Tactic_Fund_Assignment__c,cgcloud__Enable_Tactic_Condition_Creation__c,cgcloud__Automatic_Promotion_Push__c,cgcloud__Enable_Account_Set_Search_in_TPC__c,cgcloud__Enable_Sub_Account_Search_In_TPC__c,cgcloud__Enable_Acc_Cat_WDS_Profile__c,cgcloud__Enable_Subset_Load_Optimization__c,cgcloud__Postbox__c,cgcloud__No__c,cgcloud__Fax__c,cgcloud__State__c,cgcloud__Legal_Information__c,cgcloud__Available_Trade_Calendar_Color_Schemas__c,cgcloud__Enable_Subperiod_Writeback__c,cgcloud__Enable_Payment_Overwrite__c\nUS01,US01,USD,miles,Duracell US SRD,en,,,,timedependent,dynamic,Combined_Anchors,Product,3,2,pound,gallon,,,,NA,,,,,,,,,,,,,,FALSE,TRUE,FALSE,FALSE,TRUE,TRUE,TRUE,,,,,,1;2,FALSE,TRUE\nIT01,IT01,USD,miles,Duracell US SRD,en,,,,timedependent,dynamic,Combined_Anchors,Product,3,3,pound,gallon,,,,NA,,,,,,,,,,,,,,FALSE,TRUE,FALSE,FALSE,TRUE,TRUE,TRUE,,,,,,1;2,FALSE,TRUE';
    //Test data for KPI Set
    public static final String TESTDATAFORKPISET = 'Name,cgcloud__Usage__c,cgcloud__Description_Language_1__c,TPM_Sales_Org__c,cgcloud__Description_Language_2__c,cgcloud__Description_Language_3__c,cgcloud__Description_Language_4__c,cgcloud__Child_Object_Dependency__c,TPM_KPISetType__c\nBasicPlanningMode,Plan,Basic Planning Mode,US01,,,,TRUE,Basic\nIntermediatePlanningMode,Plan,Intermediate Planning Mode,US01,,,,TRUE,Intermediate\nBasicPlanningMode_Push,Plan,Basic Planning Mode with Push Down Volume,IT01,,,,TRUE,Basic\nIntermediatePlanningMode_Push,Plan,Intermediate Planning Mode with Push Down Volume,IT01,,,,TRUE,Intermediate';
    //Test data for Custom Period
    public static final String TESTDATAFORCUSTOMPERIOD = 'cgcloud__Sales_Org__c,cgcloud__Business_Year__c,PLANNINGMODE\nUS01,2022,Monthly\nIT01,2022,Weekly';
    public static final String US01VAL = 'US01';
    public static final String IT01VAL = 'IT01';
    public static final String US130VAL = 'US130';
    //Records dont match
    public static final String RECORDSDONTMATCH = 'Records dont match';
    public static final String WRONGVALUE = 'Wrong value';
}