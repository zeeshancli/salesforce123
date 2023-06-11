/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadBYearCustomCal
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load  for business year and custom calendar.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public with sharing class TPM_InitialDataLoadBYearCustomCal {

    /*********************************************************************************
    * @method         : TPM_InitialDataLoadBYearCustomCal
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadBYearCustomCal(){


    }
    
    /*********************************************************************************
    * @method         : businessYearLoad
    * @param            orgVal
    * @description    : Fetch data from Custom Metadata and insert business year records
    **********************************************************************************/
    public static void businessYearLoad(Set<String> orgVal){
        //Fetch data from custom metadata type  and insert record for business year for sales orgvalues passed from UI
        //Get id of sales org to be assigned to business records
        
        //Map of sales org name and record id for creation of business year
         Map<String,String> salesOrgValueMap = TPM_DataLoadAutomationUtil.salesOrgValForByear();

         //Map of sales org and start year for busines  year
         Map<String,Integer> startYearMap = TPM_DataLoadAutomationUtilNext.startYearVal();

         //Map of sales org and no of years for busines  year
         Map<String,Integer> noOfYearMap = TPM_DataLoadAutomationUtilNext.noOfYearVal();

         //Get existing business year records
         //map of sales org and business year number for existing records to check whether record should be created or not
         Map<String,Integer> existingBusYearMap = TPM_DataLoadAutomationUtil.busYearGetVal(orgVal);
         List<cgcloud__Business_Year__c> busYearList = new List<cgcloud__Business_Year__c>();
         Set<String> bySalesOrgValues = new Set<String>();

         for(String orgValRec : orgVal){

            //If record already exists and the last year record for a sales org is less than start year for same sales org then skip the record creation
            if(salesOrgValueMap.containsKey(orgValRec) && startYearMap.containsKey(orgValRec) && ((existingBusYearMap.get(orgValRec) < startYearMap.get(orgValRec)) || (!existingBusYearMap.containsKey(orgValRec)))){
                    
                    Integer fromYear = startYearMap.get(orgValRec);
                    Integer toYear = startYearMap.get(orgValRec) + noOfYearMap.get(orgValRec);

                //create records until start year is less than or equal to end year
                while(fromYear<=toYear){
                    cgcloud__Business_Year__c buYear = new cgcloud__Business_Year__c();
                    buYear.cgcloud__Sales_Organization__c = salesOrgValueMap.get(orgValRec);
                    String froDate = TPM_AutomationConstantUtilityClass.FROMDATE+fromYear;
                    String toDate = TPM_AutomationConstantUtilityClass.TODATE+fromYear;
                    buYear.cgcloud__Date_From__c = Date.parse(froDate);
                    buYear.cgcloud__Date_Thru__c = Date.parse(toDate);
                    buYear.cgcloud__Year_Number__c = fromYear;
                    buYear.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.BUSINESS_YEAR_SPACE+fromyear;
                    busYearList.add(buYear);
                    fromYear = fromYear + 1;
                }
            }

                else if(!salesOrgValueMap.containsKey(orgValRec)){
                         bySalesOrgValues.add(orgValRec);
                }
         }

         TPM_InitialDataLoadBYearCustomCal.createByearRecords(busYearList);
         TPM_InitialDataLoadBYearCustomCal.createCustomErrorMessage(bySalesOrgValues);
    }

    /*********************************************************************************
    * @method         : createByearRecords
    * @param            busYearList
    * @description    : Create business year records
    **********************************************************************************/
    public static void createByearRecords(List<cgcloud__Business_Year__c> busYearList){

        if(!busYearList.isempty() && Schema.sObjectType.cgcloud__Business_Year__c.isCreateable()){
            //insert business year records
 
            TPM_InitialDataLoadHandleError.createAndHandleError(busYearList,TPM_AutomationConstantUtilityClass.BUSINESSYEARLOAD);
         }
  
     }
       /*********************************************************************************
      * @method         : createCustomErrorMessage
      * @param            bySalesOrgValues
      * @description    : Create custom error records in logger object if no sales org exists
      **********************************************************************************/
        public static void createCustomErrorMessage(Set<String> bySalesOrgValues){
  
        if(!bySalesOrgValues.isEmpty() && Schema.sObjectType.TPM_Logger__c.isCreateable()){
  
           TPM_InitialDataLoadHandleError.insertCustomErrorMessage(bySalesOrgValues,TPM_AutomationConstantUtilityClass.TPMINITIALDATALOAD,TPM_AutomationConstantUtilityClass.BUSINESSYEARLOAD);
         }
  
     }
    
    /*********************************************************************************
    * @method         : customCalendarLoad
    * @param            orgVal
    * @description    : Create custom calendar records for all sales org passed by admin
    **********************************************************************************/
        public static void customCalendarLoad(Set<String> orgVal){
        //Insert record for custom calendar for sales orgvalues passed from UI

         List<cgcloud__Custom_Calendar__c> customCalendarList = new List<cgcloud__Custom_Calendar__c>();
         //Get existing custom calendar records

         Map<String,String> existingCustomCalMap = TPM_DataLoadAutomationUtil.custCalValue(orgVal);

         for(String orgValRec : orgVal){

            //If record already exists skip creation of records
            if(!existingCustomCalMap.containsKey(orgValRec)){
                cgcloud__Custom_Calendar__c custCalRec = new cgcloud__Custom_Calendar__c();
                custCalRec.cgcloud__Sales_Org__c = orgValRec;
                custCalRec.cgcloud__ExternalId__c = TPM_AutomationConstantUtilityClass.CALENDAR+orgValRec;
                custCalRec.cgcloud__Description_Language_1__c = orgValRec+TPM_AutomationConstantUtilityClass.CALENDARSPACE;
                customCalendarList.add(custCalRec);
            }
        }
    
         if(!customCalendarList.isempty() && Schema.sObjectType.cgcloud__Custom_Calendar__c.isCreateable()){
         //Insert custom calendar records
            TPM_InitialDataLoadHandleError.createAndHandleError(customCalendarList,TPM_AutomationConstantUtilityClass.CUSTOMCALENDARLOAD);
         }
    }
    
}