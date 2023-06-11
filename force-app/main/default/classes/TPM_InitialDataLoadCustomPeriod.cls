/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadCustomPeriod
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load  for custom period.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public with sharing class TPM_InitialDataLoadCustomPeriod {
        
        
        static set<string> salesOrg = new set<string>();
        static List<cgcloud__Custom_Period__c> customPerodList = new List<cgcloud__Custom_Period__c>();
        static Map<String,Id> customCalendarMap = new Map<String,Id>();
        static Map<String,Integer> salesOrgMap = new Map<String,Integer>();
        static Map<Map<Integer, String>,string> salesOrgBYNewMap = new  Map<Map<Integer, String>,string>();
        static  Map<Map<Integer, String>,Integer> salesOrgBYAsValMap = new  Map<Map<Integer, String>,Integer>();
        static  Map<Map<Integer, String>,string> salesOrgAsValMap = new  Map<Map<Integer, String>,string>();
        static boolean isFirstRecord;
        static boolean isCurrentYear;
        static Date firstDate;
        static Date lastDate;
        static integer count;
        static Set<String> salesOrgCustomCalendarMissing = new Set<String>();

    /*********************************************************************************
    * @method         : TPM_InitialDataLoadCustomPeriod
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadCustomPeriod(){


    }
       
    
    /*********************************************************************************
    * @method         : customPeriodUpload
    * @param            salesOrgSet
    * @description    : Fetch data from CSV file and create custom period records
    **********************************************************************************/
    public static void customPeriodUpload(Set<String> salesOrgSet){
        
         String customPeriodCSV  = TPM_InitialDataLoadCustomPeriod.getDataForInsertion();
         
        //Split the lines
        String[] customPeriodCsvlines = customPeriodCSV.split('\n');
        String[] headings = customPeriodCsvlines[0].split(',');
        /*for(integer i=0;i<headings.size();i++){
            if(string.isNotBlank(headings[i])){
            headings[i] = headings[i].deleteWhitespace();
            }
            else{
            headings.remove(i); 
            }
        }*/
        headings = TPM_InitialDataLoadCustomPeriod.getHeading(headings);
     
        Integer posOfSalesOrgTemp = headings.indexOf(TPM_AutomationConstantUtilityClass.CGCLOUDSALESORG);
        Integer posOfByear = headings.indexOf(TPM_AutomationConstantUtilityClass.CGCLOUDBUSINESSYEAR);
        Integer posOfPlanningMode = headings.indexOf(TPM_AutomationConstantUtilityClass.PLANNINGMODE);
        for(Integer intNumb=1; intNumb < customPeriodCsvlines.size(); intNumb++){ 
            
            Map<integer,string> busYearSalesOrgTemp = new Map<integer,string>();
            //iterating csv rows to get unique business years
            String[] column  = customPeriodCsvlines[intNumb].split(',');

            //temporary map of business year and sales org
            busYearSalesOrgTemp.put(integer.valueof(column[posOfByear].deleteWhitespace()),column[posOfSalesOrgTemp].deleteWhitespace());
            
            //Map of map of business year and sales org as key and planning mode as value
            salesOrgBYNewMap.put(busYearSalesOrgTemp,column[posOfPlanningMode].deleteWhitespace());

            //Map of map of business year and sales org as key and business year as value
            salesOrgBYAsValMap.put(busYearSalesOrgTemp,integer.valueof(column[posOfByear].deleteWhitespace()));

            //Map of map of business year and sales org as key and sales org as value
            salesOrgAsValMap.put(busYearSalesOrgTemp,column[posOfSalesOrgTemp].deleteWhitespace());

            salesOrg.add(column[posOfSalesOrgTemp].deleteWhitespace());

            
        }

        //Map of salesorg and custom calendar id
        customCalendarMap = TPM_DataLoadAutomationUtil.returnCustomCalendar(salesOrg);

        //Map of salesorg and first day of the week
        salesOrgMap = TPM_DataLoadAutomationUtil.returnSalesOrg(salesOrg);

        //Loop the map containing business year and sales org as key and business year as value

        TPM_InitialDataLoadCustomPeriod.createRecordForCustomPeriod(salesOrg);
        TPM_InitialDataLoadCustomPeriod.createCustomPeriodRec(customPerodList);
        TPM_InitialDataLoadCustomPeriod.createCustomErrorMessage(salesOrgCustomCalendarMissing);
      
    }
    
     /*********************************************************************************
    * @method         : getMonthRecords
    * @return         : List<cgcloud__Custom_Period__c>
    * @param            businessYearVal
    * @param            salesOrgSet
    * @param            keyValue
    * @description    : Create Month records if planning mode is monthly
    **********************************************************************************/
    public static List<cgcloud__Custom_Period__c> getMonthRecords(Integer businessYearVal,Set<string> salesOrgSet,Map<Integer,String> keyValue){

        //method for created records if planning mode is monthly
        while(isCurrentYear){
            cgcloud__Custom_Period__c customPeriodObj = new cgcloud__Custom_Period__c();
            customPeriodObj.cgcloud__Business_Year__c =businessYearVal; 
            //Check if sales org passed by the admin is present in csv file
            if(salesOrgSet.contains(salesOrgAsValMap.get(keyValue))){
            //Get custom calendar id based on the sales org
             customPeriodObj.cgcloud__Custom_Calendar__c=customCalendarMap.get(salesOrgAsValMap.get(keyValue));
            //Calculation and creation of first record for the business year
            if(!isFirstRecord){
                customPeriodObj.cgcloud__Date_From__c = firstDate;
                customPeriodObj.cgcloud__Date_Thru__c = customPeriodObj.cgcloud__Date_From__c.addDays(Date.daysInMonth(customPeriodObj.cgcloud__Date_From__c.year(), customPeriodObj.cgcloud__Date_From__c.month()) - 1);
                customPeriodObj.cgcloud__ExternalId__c = TPM_AutomationConstantUtilityClass.MOUS+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObj.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                customPeriodObj.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.MOUS+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObj.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                firstDate = customPeriodObj.cgcloud__Date_Thru__c.addDays(1);
                isFirstRecord=true;
            }
            else{
                //Calculation and creation of Other record for the business year
                customPeriodObj.cgcloud__Date_From__c = firstDate;
                customPeriodObj.cgcloud__Date_Thru__c = customPeriodObj.cgcloud__Date_From__c.addDays(Date.daysInMonth(customPeriodObj.cgcloud__Date_From__c.year(), customPeriodObj.cgcloud__Date_From__c.month()) - 1);
                customPeriodObj.cgcloud__ExternalId__c = TPM_AutomationConstantUtilityClass.MOUS+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObj.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                customPeriodObj.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.MOUS+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObj.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                firstDate = customPeriodObj.cgcloud__Date_Thru__c.addDays(1);
            }
            
            //If month = 12 stop creation of records
             if(customPeriodObj.cgcloud__Date_Thru__c.month() == 12){
                isCurrentYear = false;
                customPerodList.add(customPeriodObj);
                break;
            }
            
            customPerodList.add(customPeriodObj);
            count++;
        }
       
        else{
        isCurrentYear = false;
          }  
        }
        return customPerodList;
    }

    
    /*********************************************************************************
    * @method         : getWeekRecords
    * @return         : List<cgcloud__Custom_Period__c>
    * @param            businessYearVal
    * @param            salesOrgSet
    * @param            keyValue
    * @description    : Create Week records if planning mode is Weekly
    **********************************************************************************/
    public static List<cgcloud__Custom_Period__c> getWeekRecords(Integer businessYearVal,Set<String> salesOrgSet,Map<Integer,String> keyValue){

    //method for created records if planning mode is Weekly
    count =1;
    while(isCurrentYear){
        cgcloud__Custom_Period__c customPeriodObj = new cgcloud__Custom_Period__c();
         //Check if sales org passed by the admin is present in csv file
            if(salesOrgSet.contains(salesOrgAsValMap.get(keyValue))){
            if(!isFirstRecord){
                //Calculation and creation of first record for the business year
                //Returrns day of week for the sales org
                //Return day of week based on the day of week value from sales org
                string dayofweekval = TPM_DataLoadAutomationUtilNext.dayOfWeek(salesOrgMap.get(salesOrgAsValMap.get(keyValue)));                
                //Returns first date of week based on day of week
                Date firstDateForWeek = TPM_DataLoadAutomationUtilNext.returnDateForFirstDay(dayofweekval,businessYearVal);
                customPeriodObj = TPM_InitialDataLoadCustomPeriod.getWeekRecordsFirst(businessYearVal,firstDateForWeek,keyValue);
                isFirstRecord=true;
                firstDate = customPeriodObj.cgcloud__Date_Thru__c.addDays(1);
            }
            else{

                //Calculation and creation of Other record for the business year
                customPeriodObj.cgcloud__Business_Year__c =businessYearVal; 
                customPeriodObj.cgcloud__Custom_Calendar__c=customCalendarMap.get(salesOrgAsValMap.get(keyValue));
                customPeriodObj.cgcloud__Date_From__c = firstDate;
                customPeriodObj.cgcloud__Date_Thru__c = customPeriodObj.cgcloud__Date_From__c.addDays(6);
                customPeriodObj.cgcloud__ExternalId__c = TPM_AutomationConstantUtilityClass.WEEK+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+businessYearVal+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                customPeriodObj.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.WEEK+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObj.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                firstDate = customPeriodObj.cgcloud__Date_Thru__c.addDays(1);
                
            }

            //If current year>business year or month=12 and date =31 then stop creation of records
            if((customPeriodObj.cgcloud__Date_Thru__c.year() > Integer.valueOf(businessYearVal)) || (customPeriodObj.cgcloud__Date_Thru__c.month() == 12 && customPeriodObj.cgcloud__Date_Thru__c.Day() == 31)){
                customPeriodObj.cgcloud__Date_Thru__c = lastDate;
                customPerodList.add(customPeriodObj);
                isCurrentYear = false;
                break;
            }
            customPerodList.add(customPeriodObj);
            count++;
            }
            else{
                isCurrentYear = false;
                  }  
        }

        return customPerodList;
    }
   
   /*********************************************************************************
    * @method         : getWeekRecordsFirst
    * @return         : cgcloud__Custom_Period__c
    * @param            businessYearVal
    * @param            firstDateForWeek
    * @param            keyValue
    * @description    : Create first Week record if planning mode is Weekly
    **********************************************************************************/
   public static cgcloud__Custom_Period__c getWeekRecordsFirst(Integer businessYearVal,Date firstDateForWeek,Map<Integer,String> keyValue){

                //Calculation and creation of first record for the business year
                cgcloud__Custom_Period__c customPeriodObjtemp = new cgcloud__Custom_Period__c();

                //If first date is same as first date of week then end date will be calculated as below
                if(firstDateForWeek == firstDate){
                    customPeriodObjtemp.cgcloud__Business_Year__c =businessYearVal; 
                    customPeriodObjtemp.cgcloud__Custom_Calendar__c=customCalendarMap.get(salesOrgAsValMap.get(keyValue));
                    customPeriodObjtemp.cgcloud__Date_From__c = firstDate;
                    customPeriodObjtemp.cgcloud__Date_Thru__c = customPeriodObjtemp.cgcloud__Date_From__c.addDays(6);
                    customPeriodObjtemp.cgcloud__ExternalId__c = TPM_AutomationConstantUtilityClass.WEEK+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObjtemp.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                    customPeriodObjtemp.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.WEEK+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObjtemp.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                }   
                else{

                    //If first date is not same as first date of week then end date will be calculated as below
                    customPeriodObjtemp.cgcloud__Business_Year__c =businessYearVal; 
                    customPeriodObjtemp.cgcloud__Custom_Calendar__c = customCalendarMap.get(salesOrgAsValMap.get(keyValue));
                    customPeriodObjtemp.cgcloud__Date_From__c = firstDate;
                    customPeriodObjtemp.cgcloud__Date_Thru__c = firstDateForWeek.addDays(-1);
                    customPeriodObjtemp.cgcloud__ExternalId__c = TPM_AutomationConstantUtilityClass.WEEK+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObjtemp.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                    customPeriodObjtemp.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.WEEK+salesOrgAsValMap.get(keyValue)+TPM_AutomationConstantUtilityClass.UNDERSCORE+customPeriodObjtemp.cgcloud__Date_Thru__c.year()+TPM_AutomationConstantUtilityClass.UNDERSCORE+count;
                }
                return customPeriodObjtemp;

        }
        
    /*********************************************************************************
    * @method         : createCustomPeriodRec
    * @param            customPerodList
    * @description    : Create custom period record i
    **********************************************************************************/
        public static void createCustomPeriodRec(List<cgcloud__Custom_Period__c> customPerodList){
        if(!customPerodList.isempty() && Schema.sObjectType.cgcloud__Custom_Period__c.isCreateable()){
            //Insert records
                TPM_InitialDataLoadHandleError.createAndHandleError(customPerodList,TPM_AutomationConstantUtilityClass.CUSTOMPERIODUPLOAD);
             }

        }

     /*********************************************************************************
      * @method         : createCustomErrorMessage
      * @param            salesOrgCustomCalendarMissing
      * @description    : Create custom error records in logger object if no custom calendar exists
      **********************************************************************************/
      public static void createCustomErrorMessage(Set<String> salesOrgCustomCalendarMissing){
  
        if(!salesOrgCustomCalendarMissing.isEmpty() && Schema.sObjectType.TPM_Logger__c.isCreateable()){
  
           TPM_InitialDataLoadHandleError.insertCustomErrorMessage(salesOrgCustomCalendarMissing,TPM_AutomationConstantUtilityClass.TPMINITIALDATALOAD,TPM_AutomationConstantUtilityClass.CUSTOMPERIODUPLOAD);
         }
  
     }
    
     /*********************************************************************************
      * @method         : getDataForInsertion
      * @return         : String
      * @description    : Get data from csv and dummy data foe test class based on running context
      **********************************************************************************/
        public static String getDataForInsertion(){
        
            //Fetch data from CSV file and insert record for custom period for values passed by admin
            String customPeriodCSVfromMet;
            Blob csvFileBody;
            if(!Test.isRunningTest()){
                StaticResource customPeriodResource = [SELECT Body from StaticResource
                                                    WHERE Name = :System.Label.TPM_Data_Load_File_Name_CustomPeriod
                                                    WITH SECURITY_ENFORCED];
                customPeriodCSVfromMet = customPeriodResource.Body.toString();
                }
                else{
                    String str = TPM_TestAutomationDataUtility.TESTDATAFORCUSTOMPERIOD;   
                    csvFileBody = Blob.valueOf(str);
                    customPeriodCSVfromMet = csvFileBody.toString();
                }

            return customPeriodCSVfromMet;
        }

      /*********************************************************************************
      * @method         : getHeading
      * @return         : String[]
      * @param            headings
      * @description    : Get data from csv and dummy data foe test class based on running context
      **********************************************************************************/
      public static String[] getHeading( String[] headings){
        
        for(integer ihead=0;ihead<headings.size();ihead++){
            if(String.isNotBlank(headings[ihead])){
            headings[ihead] = headings[ihead].deleteWhitespace();
            }
            else{
            headings.remove(ihead); 
            }
        }

        return headings;
      
    }
    
     /*********************************************************************************
      * @method         : createRecordForCustomPeriod
      * @param            salesOrgSet
      * @description    : Get data from csv and dummy data foe test class based on running context
      **********************************************************************************/
        public static void createRecordForCustomPeriod(Set<string> salesOrgSet){

        for(Map<Integer,string> busYesar : salesOrgBYAsValMap.keySet()){
            Integer businessYearVal = salesOrgBYAsValMap.get(busYesar);
            Map<Integer,String> keyVal = busYesar;
            firstDate = Date.newInstance(businessYearVal, 01, 01);
            lastDate = Date.newInstance(businessYearVal, 12, 31);
            isFirstRecord = false;
            isCurrentYear = true;
            count = 1;
            //Creation of month records only if salesorg record is present in the org since we need first day of week value
            if(customCalendarMap.containsKey(salesOrgAsValMap.get(keyVal)) && TPM_AutomationConstantUtilityClass.PLANNING_MODE_MONTHLY == salesOrgBYNewMap.get(busYesar).deleteWhitespace()){
                customPerodList = TPM_InitialDataLoadCustomPeriod.getMonthRecords(businessYearVal,salesOrgSet,keyVal);
            }
            
            //Creation of Week records only if salesorg record is present in the org since we need first day of week value
            else if(customCalendarMap.containsKey(salesOrgAsValMap.get(keyVal)) && salesOrgBYNewMap.get(busYesar).deleteWhitespace() == TPM_AutomationConstantUtilityClass.PLANNING_MODE_WEEKLY){
                customPerodList = TPM_InitialDataLoadCustomPeriod.getWeekRecords(businessYearVal,salesOrgSet,keyVal);
            }

            else if(!customCalendarMap.containsKey(salesOrgAsValMap.get(keyVal)) && salesOrgSet.contains(salesOrgAsValMap.get(keyVal))){
                string salesOrgMiss = salesOrgAsValMap.get(keyVal);
                salesOrgCustomCalendarMissing.add(salesOrgMiss);
            }
        }
    }
    }