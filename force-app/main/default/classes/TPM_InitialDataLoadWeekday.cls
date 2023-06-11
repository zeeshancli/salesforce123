/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadWeekday
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load in for Week Day Profile.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadWeekday {

     /*********************************************************************************
    * @method         : TPM_InitialDataLoadWeekday
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadWeekday(){


    }
   
     /*********************************************************************************
    * @method         : weekDayProfileLoad
    * @param            orgVal
    * @description    : Fetch data from Custom Metadata and insert weekday profile records
    **********************************************************************************/
    public static void weekDayProfileLoad(Set<String> orgVal){
        //Fetch data from custom meta data type and insert record for weekday profile
        //Map of weekday sales Org and Week Day Record id
      Map<String,String> existingWeekDayProfileMap = TPM_DataLoadAutomationUtil.returnWeekDayProfile(orgVal);
      List<cgcloud__Week_Day_Share_Profile__c> weekDayRecordList = new List<cgcloud__Week_Day_Share_Profile__c>();
      TPM_Initial_Data_Load__mdt weekDayValues = [SELECT Id,
                                                  TPM_Monday__c,
                                                  TPM_Tuesday__c,
                                                  TPM_Wednesday__c,
                                                  TPM_Thursday__c,
                                                  TPM_Friday__c,
                                                  TPM_Saturday__c,
                                                  TPM_Sunday__c 
                                                  FROM TPM_Initial_Data_Load__mdt 
                                                  WHERE TPM_ObjectName__c = :TPM_AutomationConstantUtilityClass.WEEKDAY_PROFILE
                                                  AND DeveloperName = :TPM_AutomationConstantUtilityClass.WEEKDAY_PROFILE_VALUES 
                                                  WITH SECURITY_ENFORCED];
      for(String orgValRec : orgVal){
        //If record already exists skip creation of records
        //If Weekday record already exists for the org then skip creation of records 
          if(!existingWeekDayProfileMap.containsKey(orgValRec)){
              cgcloud__Week_Day_Share_Profile__c weekday = new cgcloud__Week_Day_Share_Profile__c();
              weekday.cgcloud__Sales_Org__c= orgValRec;
              weekday.cgcloud__Description_Language_1__c = orgValRec+TPM_AutomationConstantUtilityClass.WEEKDAY_SHARE_PROFILE;
              weekday.cgcloud__Monday__c = weekDayValues.TPM_Monday__c;
              weekday.cgcloud__Tuesday__c = weekDayValues.TPM_Tuesday__c;
              weekday.cgcloud__Wednesday__c = weekDayValues.TPM_Wednesday__c;
              weekday.cgcloud__Thursday__c = weekDayValues.TPM_Thursday__c;
              weekday.cgcloud__Friday__c = weekDayValues.TPM_Friday__c;
              weekday.cgcloud__Saturday__c = weekDayValues.TPM_Saturday__c;
              weekday.cgcloud__Sunday__c = weekDayValues.TPM_Sunday__c;
              weekDayRecordList.add(weekday);
            }
    }

    if(!weekDayRecordList.isempty() && Schema.sObjectType.cgcloud__Week_Day_Share_Profile__c.isCreateable()){
    //insert weekday profile records
        TPM_InitialDataLoadHandleError.createAndHandleError(weekDayRecordList,TPM_AutomationConstantUtilityClass.WEEKDAYPROFILELOAD);
      }
    } 
  }