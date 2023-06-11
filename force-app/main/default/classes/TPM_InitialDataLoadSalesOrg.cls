/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadSalesOrg
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load in for Sales Org.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadSalesOrg {
    
    //Get data type of all fields for sales org object
    Static Map<String,String> apinameDateTypeMap = TPM_DataLoadAutomationUtilNext.returnApiName();
    Static Map<string,string> existingWeekdaySalesOrgIdMap = new Map<String,String>();

     /*********************************************************************************
    * @method         : TPM_InitialDataLoadSalesOrg
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadSalesOrg(){


    }
   
   /*********************************************************************************
    * @method         : salesOrgLoad
    * @param            orgVal
    * @description    : Fetch data from CSV file and create Sales Org records
    **********************************************************************************/
   public static void salesOrgLoad(Set<String> orgVal){
    //To insert salesorg records
    //Fetch data from CSV file  and insert record for sales org for values passed by admin
    //Get existing sales records
    //Map of sales org and record id
    Map<string,string> existingSalesOrgRecordIdMap = TPM_DataLoadAutomationUtil.returnSalesOrgRec(orgval);
    
    //Get weekday profile records to be associated with salesorg
    //Map of sales org and weekday profile record id
    existingWeekdaySalesOrgIdMap= TPM_DataLoadAutomationUtil.returnWeekDayProfile(orgval);

    Set<String> salesOrgNotContainingWeekDay = new  Set<String>();
    String salesOrgCsv;
    if(!Test.isRunningTest()){
    //Get data from CSV file
        StaticResource salesOrgStaticResource = [SELECT Body 
                                                FROM StaticResource
                                                WHERE Name = :System.Label.TPM_Data_Load_File_Name_SalesOrg 
                                                WITH SECURITY_ENFORCED];
        salesOrgCsv = salesOrgStaticResource.Body.toString();
    }

    else{
            String str =  TPM_TestAutomationDataUtility.TESTDATAFORSALESORG;   
            Blob csvFileBody = Blob.valueOf(str);
            salesOrgCsv = csvFileBody.toString();

    }
    String[] salesOrgCsvLines = salesOrgCsv.split('\n');

    String[] headings = salesOrgCsvLines[0].split(',');

    Integer posOfSalesOrg = headings.indexOf(TPM_AutomationConstantUtilityClass.SALESORGFIELD);

    List<cgcloud__Sales_Organization__c> salesOrgRecordList = new List<cgcloud__Sales_Organization__c>();
    for(Integer intNum = 1; intNum < salesOrgCsvLines.size(); intNum++){
        String salesOrgValue;
        if( salesOrgCsvLines[intNum].length() != 0){
            cgcloud__Sales_Organization__c salesOrgRec = new cgcloud__Sales_Organization__c();
            String[] column = salesorgCsvlines[intNum].split(',');
            salesOrgValue = column[posOfSalesOrg];

            //First Condition to check if sales org from the file is passed by admin as well
            //Second condition if weekday profile exists for the sales org
            //Third condition to check if sales org record is not created already
            //If all the above condition matches then create the record
            if(orgval.contains(salesOrgValue) && existingWeekdaySalesOrgIdMap.containsKey(salesOrgValue) && !existingSalesOrgRecordIdMap.containsKey(salesOrgValue)){
                salesOrgRec = TPM_InitialDataLoadsalesOrg.createSalesOrgRec(headings,salesOrgValue,column);
                  salesOrgRecordList.add(salesOrgRec);
              }

              else if(!existingWeekdaySalesOrgIdMap.containsKey(salesOrgValue) && (orgval.contains(salesOrgValue))){
                salesOrgNotContainingWeekDay.add(salesOrgValue);
              }
       }
   
     }  
     
       TPM_InitialDataLoadSalesOrg.createSalesOrgRecords(salesOrgRecordList);
       TPM_InitialDataLoadSalesOrg.createCustomErrorMessage(salesOrgNotContainingWeekDay);
       
      }
    
      /*********************************************************************************
    * @method         : createSalesOrgRec
    * @return         : cgcloud__Sales_Organization__c
    * @param            headings
    * @param            salesOrgValue
    * @param            column
    * @description    : Create sales org records by using CSV file data
    **********************************************************************************/
    public static cgcloud__Sales_Organization__c createSalesOrgRec(String[] headings, String salesOrgValue, String[] column){
        //Create record with value from csv 
        cgcloud__Sales_Organization__c salesOrgRecord = new cgcloud__Sales_Organization__c();

        //Loop columns one by one and add values
        for (Integer count = 0; count < column.size(); count++) {

          if(String.isNotBlank(headings[count].deleteWhitespace())){ 

                //If field type is Boolean then return true or false
              if(apinameDateTypeMap.get(headings[count].deleteWhitespace()) == TPM_AutomationConstantUtilityClass.CHECKBOX){
                salesOrgRecord.put(headings[count].deleteWhitespace(), TPM_DataLoadAutomationUtilNext.getactivevalues(column[count]));
                  }
                else{
                  salesOrgRecord.put(headings[count].deleteWhitespace(), column[count]);
                  }
         }
       }
           salesOrgRecord.put(TPM_AutomationConstantUtilityClass.WEEKDAYSHAREPROFILEFIELD,existingWeekdaySalesOrgIdMap.get(salesOrgValue));
           return salesOrgRecord;
         }
   
  
   

   /*********************************************************************************
    * @method         : createSalesOrgRecords
    * @param            salesOrgRecordList
    * @description    : Create sales org records
    **********************************************************************************/
    public static void createSalesOrgRecords(List<cgcloud__Sales_Organization__c> salesOrgRecordList){

      if(!salesOrgRecordList.isempty() && Schema.sObjectType.cgcloud__Sales_Organization__c.isCreateable()){
         //insert sales record and created record in logger object if any exception is raised
            TPM_InitialDataLoadHandleError.createAndHandleError(salesOrgRecordList,TPM_AutomationConstantUtilityClass.SALESORGLOAD);
        }

   }
     /*********************************************************************************
    * @method         : createCustomErrorMessage
    * @param            salesOrgNotContainingWeekDay
    * @description    : Create custom error records in logger object if no weekday profile exists for sales org
    **********************************************************************************/
   public static void createCustomErrorMessage(Set<String> salesOrgNotContainingWeekDay){

      if(!salesOrgNotContainingWeekDay.isEmpty() && Schema.sObjectType.TPM_Logger__c.isCreateable()){

          TPM_InitialDataLoadHandleError.insertCustomErrorMessage(salesOrgNotContainingWeekDay,TPM_AutomationConstantUtilityClass.TPMINITIALDATALOAD,TPM_AutomationConstantUtilityClass.SALESORGLOAD);
       }

   }
}