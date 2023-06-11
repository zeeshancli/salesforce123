/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadTest
* @author       : PwC Team
* @date         : January 12, 2022
* @description  : Test class for Data Load Automation - 'TPM_InitialDataLoad'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_InitialDataLoadTest {
    
    /*********************************************************************************
      @description      createData test data records
    **********************************************************************************/
    @testSetup
    static void setup() {
        
        // Create Admin User.
        User adminUser = TPM_TestDataUtility.createTestUser(TPM_TestDataUtility.getProfileId('System Administrator'),
                                                            'testTPMAdminFName',
                                                            'testTPMAdminLName');
        
        //Add email
        adminUser.Email = 'tpmadminuser008@invalidtpm.com';
        //Insert admin user
        insert adminUser;
    }
    
    /*********************************************************************************
      @description      Call the class to create records for all objects
    **********************************************************************************/
    @isTest
    public static void executeInitialDataLoad(){
        
        // Fetch user details.
        User adminUser = [SELECT Id 
                     FROM User 
                     WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
        
        System.runAs(adminUser) {   
        //Create Set of Org values
        Set<String> org = new Set<String>();
       //Create list of custom objects for which record has to be created
        List<String> valuesList = new List<String>();
        //Add Org Values
        //Add us01
        org.add(TPM_TestAutomationDataUtility.US01VAL);
        //Add IT01
        org.add(TPM_TestAutomationDataUtility.IT01VAL);
        //Add US130 for negative scenario
        org.add(TPM_TestAutomationDataUtility.US130VAL);
        //Call all methods at once
        valuesList.add('All');
        Test.StartTest();
        //Call the class to insert records
        TPM_InitialDataLoad.tpmInitialDataLoadCall(org,valuesList);
        
        //Create weekday records
        List<cgcloud__Week_Day_Share_Profile__c> weekDayOrgRec = [  SELECT id,
                                                                      cgcloud__Sales_Org__c 
                                                                      FROM cgcloud__Week_Day_Share_Profile__c 
                                                                      WHERE id!=NULL 
                                                                      WITH SECURITY_ENFORCED];
         //No of records should be 2
        System.assertEquals(2,weekDayOrgRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        //Fetch salesorg records
         List<cgcloud__Sales_Organization__c> salesOrgRec = [SELECT id,
                                                                    cgcloud__Sales_Org_Value__c,
                                                                    cgcloud__Currency__c 
                                                                    FROM cgcloud__Sales_Organization__c 
                                                                    WHERE id!=NULL
                                                                    WITH SECURITY_ENFORCED];
           //No of records should be 2
         System.assertEquals(2,salesOrgRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        
         //Fetch KPI Set records
         List<cgcloud__KPI_Set__c> existingKpiRecordsList = [SELECT id,
                                                                    TPM_Sales_Org__c,
                                                                    Name,
                                                                    TPM_KPISetType__c,
                                                             cgcloud__Child_Object_Dependency__c
                                                                    FROM cgcloud__KPI_Set__c 
                                                                    WHERE Name!=NULL 
                                                                    WITH SECURITY_ENFORCED];
         //No of records should be 4
        System.assertEquals(4,existingKpiRecordsList.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        
        Test.StopTest();
        }

    }

/*********************************************************************************
      @description      Call the class to create records for all objects
    **********************************************************************************/
    @isTest
    public static void executeInitialDataLoadCon(){ // Fetch user details.
      User adminUser = [SELECT Id 
                   FROM User 
                   WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
      
      System.runAs(adminUser) {   
      //Create Set of Org values
      Set<String> org = new Set<String>();
     //Create list of custom objects for which record has to be created
      List<String> valuesList = new List<String>();
      //Add Org Values
      //Add us01
      org.add(TPM_TestAutomationDataUtility.US01VAL);
      //Add IT01
      org.add(TPM_TestAutomationDataUtility.IT01VAL);
      //Add US130 for negative scenario
      org.add(TPM_TestAutomationDataUtility.US130VAL);
      //Call all methods at once
      valuesList.add('All');
      Test.StartTest();
          //Call the class to insert records
        TPM_InitialDataLoad.tpmInitialDataLoadCall(org,valuesList);
              //Fetch Existing Customer Template records
              List<cgcloud__Account_Template__c> existingCustomerRec = [SELECT Id,
                                                                                Name,
                                                                                cgcloud__Sales_Org__c,
                                                                                RecordType.Name,
                                                                                TPM_CustTemp_PlanMode__c 
                                                                                FROM cgcloud__Account_Template__c 
                                                                                WHERE cgcloud__Active__c = true 
                                                                                WITH SECURITY_ENFORCED];
          //No of records should be 6
          System.assertEquals(6,existingCustomerRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

          //Fetch Existing Product Template records
          List<cgcloud__Product_Template__c> existingProductTempRec = [SELECT Id,
                                                                              Name,
                                                                              Recordtype.Name,
                                                                              cgcloud__Sales_Org__c 
                                                                              FROM cgcloud__Product_Template__c 
                                                                              WHERE cgcloud__Active__c = true 
                                                                              WITH SECURITY_ENFORCED];
          //No of records should be 4
          System.assertEquals(4,existingProductTempRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

          //Fetch Existing Business year records
          List<cgcloud__Business_Year__c> byear =  [SELECT id,
                                                            cgcloud__Year_Number__c,
                                                            cgcloud__Sales_Organization__r.Name 
                                                            FROM cgcloud__Business_Year__c 
                                                            WHERE id!=NULL 
                                                            WITH SECURITY_ENFORCED ];
          //No of records should be 102
          System.assertEquals(102,byear.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

          //Fetch Existing Custom Calendar records
          List<cgcloud__Custom_Calendar__c> custCalendarRec = [SELECT id,
                                                                      cgcloud__Sales_Org__c 
                                                                      FROM cgcloud__Custom_Calendar__c 
                                                                      WHERE id!=NULL 
                                                                      WITH SECURITY_ENFORCED];

          //No of records should be 2                                                            
          System.assertEquals(2,custCalendarRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

          //Fetch Existing Custom Period records
          List<cgcloud__Custom_Period__c> custPeriodRec = [SELECT   Id,
                                                                    cgcloud__Custom_Calendar__r.Name,
                                                                    cgcloud__Date_From__c,
                                                                    cgcloud__Date_Thru__c,
                                                                    cgcloud__ExternalId__c,
                                                                    cgcloud__Business_Year__c,
                                                                    cgcloud__Description_Language_1__c
                                                                    FROM cgcloud__Custom_Period__c
                                                                    WHERE cgcloud__Custom_Calendar__r.Name!=NULL
                                                                    WITH SECURITY_ENFORCED];
          //No of records should be 65
          System.assertEquals(65,custPeriodRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

          //Fetch Existing Metadata records
          List<cgcloud__Metadata_Wizard_Configuration__c> existingMetaRec = [SELECT id,
                                                                                    cgcloud__Sales_Org__c 
                                                                                    FROM cgcloud__Metadata_Wizard_Configuration__c 
                                                                                    WHERE id!=NULL 
                                                                                    WITH SECURITY_ENFORCED];
          //No of records should be 2
          System.assertEquals(2,existingMetaRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

          //Fetch Existing Product assortment template records
          List<cgcloud__Product_Assortment_Template__c> existingProductAssortTempRec = [SELECT Id,
                                                                                                Name,
                                                                                                cgcloud__Sales_Org__c 
                                                                                                FROM cgcloud__Product_Assortment_Template__c 
                                                                                                WHERE cgcloud__Active__c = true 
                                                                                                WITH SECURITY_ENFORCED];
          //No of records should be 2
          System.assertEquals(2,existingProductAssortTempRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
          Test.StopTest();
      }

    }
     /*********************************************************************************
      @description      Call the class to create Week Day sales org bus year cust calendar and custom epriod records
    **********************************************************************************/
    @isTest
    public static void executeDataLoadCustomerProductBusiness(){
            //Execute data load only for customer,product template and business year
            // Fetch user details.
            User adminUser = [SELECT Id 
            FROM User 
            WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];
            System.runAs(adminUser) {  
              //Create Set of Org values
            Set<String> orgnew = new Set<String>();
            //Create list of custom objects for which record has to be created
            List<String> valuesNewList = new List<String>();
            //Add Org Values
            //Add us01
            orgnew.add(TPM_TestAutomationDataUtility.US01VAL);
           //Add IT01
           orgnew.add(TPM_TestAutomationDataUtility.IT01VAL);
           //Call all methods at once
            valuesNewList.add('weekday');
            valuesNewList.add('salesorg');
            valuesNewList.add('BusinessYear');
            Test.StartTest();

          TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
          //Get weekday records
          List<cgcloud__Week_Day_Share_Profile__c> weekDayOrgRec = [  SELECT id,
                                                                             cgcloud__Sales_Org__c 
                                                                             FROM cgcloud__Week_Day_Share_Profile__c 
                                                                             WHERE id!=NULL
                                                                             WITH SECURITY_ENFORCED];
          //Record count must be 2
           System.assertEquals(2,weekDayOrgRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
           
           //Get sales org records
           List<cgcloud__Sales_Organization__c> salesOrgRec = [SELECT id,
                                                                      cgcloud__Sales_Org_Value__c,
                                                                      cgcloud__Currency__c 
                                                                      FROM cgcloud__Sales_Organization__c 
                                                                      WHERE id!=NULL
                                                                      WITH SECURITY_ENFORCED];
            //Record count must be 2
            System.assertEquals(2,salesOrgRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

           
            //Get business year records
            List<cgcloud__Business_Year__c> byear =  [SELECT id,
                                                             cgcloud__Year_Number__c,
                                                             cgcloud__Sales_Organization__r.Name 
                                                             FROM cgcloud__Business_Year__c 
                                                             WHERE cgcloud__Sales_Organization__r.Name !=NULL 
                                                             WITH SECURITY_ENFORCED ];
             //Record count must be 102
             System.assertEquals(102,byear.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

           
             //Call class again to check that no records should be created if record already exists
             TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
             
             //Get existing weekday profile records
             List<cgcloud__Week_Day_Share_Profile__c> weekDayOrgRecNew = [  SELECT id,
                                                                             cgcloud__Sales_Org__c 
                                                                             FROM cgcloud__Week_Day_Share_Profile__c 
                                                                             WHERE id!=NULL
                                                                             WITH SECURITY_ENFORCED];
              //Record count must be 2
              System.assertEquals(2,weekDayOrgRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            
              //Get existing sales org records
            List<cgcloud__Sales_Organization__c> salesOrgRecNew = [SELECT id,
                                                                      cgcloud__Sales_Org_Value__c,
                                                                      cgcloud__Currency__c 
                                                                      FROM cgcloud__Sales_Organization__c 
                                                                      WHERE id!=NULL
                                                                      WITH SECURITY_ENFORCED];
              //Record count must be 2
              System.assertEquals(2,salesOrgRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

            //Get existing business year records
            List<cgcloud__Business_Year__c> byearNew =  [SELECT id,
                                                                cgcloud__Year_Number__c,
                                                                cgcloud__Sales_Organization__r.Name 
                                                                FROM cgcloud__Business_Year__c 
                                                                WHERE cgcloud__Sales_Organization__r.Name !=NULL 
                                                                WITH SECURITY_ENFORCED ];
             //Record count must be 102
             System.assertEquals(102,byearNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

            Test.StopTest();

    }

}
  /*********************************************************************************
      @description      Call the class to create Customer Temp KPI set and Product Template records
    **********************************************************************************/
    @isTest
    public static void executeDataLoadWeekDaySalesKpi(){
        
         // Fetch user details.
         User adminUser = [SELECT Id 
         FROM User 
         WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];

          System.runAs(adminUser) {  
          Set<String> orgnew = new Set<String>();
          List<String> valuesNewList = new List<String>();
            //Add Org Values
            //Add us01
            orgnew.add(TPM_TestAutomationDataUtility.US01VAL);
           //Add IT01
           orgnew.add(TPM_TestAutomationDataUtility.IT01VAL);
           //Call all methods at once
          valuesNewList.add('CustomerTemplate');
          valuesNewList.add('KPISet');
          valuesNewList.add('ProductTemplate');
       
            Test.StartTest();

            TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
            
            //Get existing customer template records
            List<cgcloud__Account_Template__c> existingCustomerRec = [SELECT Id,
                                                                            Name,
                                                                            cgcloud__Sales_Org__c,
                                                                            RecordType.Name,
                                                                            TPM_CustTemp_PlanMode__c 
                                                                            FROM cgcloud__Account_Template__c 
                                                                            WHERE cgcloud__Active__c = true 
                                                                            WITH SECURITY_ENFORCED];
            //No of records should be 6
            System.assertEquals(6,existingCustomerRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            
            //Get existing KPI Set Records
            List<cgcloud__KPI_Set__c> existingKpiRecordsList = [SELECT id,
                                                                      TPM_Sales_Org__c,
                                                                        Name,
                                                                        TPM_KPISetType__c 
                                                                        FROM cgcloud__KPI_Set__c 
                                                                        WHERE Name!=NULL 
                                                                        WITH SECURITY_ENFORCED];
              //No of records should be 4
            System.assertEquals(4,existingKpiRecordsList.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

            //Get existing product template records
            List<cgcloud__Product_Template__c> existingProductTempRec = [SELECT Id,
                                                                                Name,
                                                                                Recordtype.Name,
                                                                                cgcloud__Sales_Org__c 
                                                                                FROM cgcloud__Product_Template__c 
                                                                                WHERE cgcloud__Active__c = true 
                                                                                WITH SECURITY_ENFORCED];
              //No of records should be 4
            System.assertEquals(4,existingProductTempRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

            //Call the class again to check if new record are not
           //created if record already exists
            TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
           
            //Get existing customer template records
            List<cgcloud__Account_Template__c> existingCustomerRecNew = [SELECT Id,
                                                                            Name,
                                                                            cgcloud__Sales_Org__c,
                                                                            RecordType.Name,
                                                                            TPM_CustTemp_PlanMode__c 
                                                                            FROM cgcloud__Account_Template__c 
                                                                            WHERE cgcloud__Active__c = true 
                                                                            WITH SECURITY_ENFORCED];
             //No of records should be 6
            System.assertEquals(6,existingCustomerRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            
              //Get existing KPI Set records
            List<cgcloud__KPI_Set__c> existingKpiRecordsListNew = [SELECT id,
                                                                        TPM_Sales_Org__c,
                                                                        Name,
                                                                        TPM_KPISetType__c 
                                                                        FROM cgcloud__KPI_Set__c 
                                                                        WHERE Name!=NULL 
                                                                        WITH SECURITY_ENFORCED];
              //No of records should be 4
            System.assertEquals(4,existingKpiRecordsListNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

            //Get existing Product template records
            List<cgcloud__Product_Template__c> existingProductTempRecNew = [SELECT Id,
                                                                                Name,
                                                                                Recordtype.Name,
                                                                                cgcloud__Sales_Org__c 
                                                                                FROM cgcloud__Product_Template__c 
                                                                                WHERE cgcloud__Active__c = true 
                                                                                WITH SECURITY_ENFORCED];
              //No of records should be 4
            System.assertEquals(4,existingProductTempRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

            Test.StopTest();

            }

    }
    
    /*********************************************************************************
      @description      Call the class to create Sales org metadata wizrad and product assortment template
    **********************************************************************************/
    @isTest
    public static void executeDataLoadCustomPeriodCaleMetaAssort(){
         
         // Fetch user details.
         User adminUser = [SELECT Id 
         FROM User 
         WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];

        System.runAs(adminUser) {  

        Set<String> orgnew = new Set<String>();
        List<String> valuesNewList = new List<String>();
         //Add Org Values
         orgnew.add(TPM_TestAutomationDataUtility.US01VAL);
         orgnew.add(TPM_TestAutomationDataUtility.IT01VAL);
         //Call below methods 
         valuesNewList.add('salesorg');
         valuesNewList.add('Metadatawizard');
         valuesNewList.add('Productassortmenttemplate');
         valuesNewList.add('CustomPeriod');
         
         Test.StartTest();
         //Call the class
         TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);

         
         List<cgcloud__Sales_Organization__c> salesOrgRecNew = [SELECT id,
                                                                       cgcloud__Sales_Org_Value__c,
                                                                       cgcloud__Currency__c 
                                                                       FROM cgcloud__Sales_Organization__c 
                                                                       WHERE id!=NULL
                                                                       WITH SECURITY_ENFORCED];
         //No of records should be 0
          System.assertEquals(0,salesOrgRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
         
          //Get existing metadata records
         List<cgcloud__Metadata_Wizard_Configuration__c> existingMetaRec = [SELECT id,
                                                                                  cgcloud__Sales_Org__c 
                                                                                  FROM cgcloud__Metadata_Wizard_Configuration__c 
                                                                                  WHERE Name!=NULL
                                                                                  WITH SECURITY_ENFORCED];
          //No of records should be 2
          System.assertEquals(2,existingMetaRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        
          //Get existing product assortment template records
        List<cgcloud__Product_Assortment_Template__c> existingProductAssortTempRec = [SELECT Id,
                                                                                             Name,
                                                                                             cgcloud__Sales_Org__c 
                                                                                             FROM cgcloud__Product_Assortment_Template__c 
                                                                                             WHERE cgcloud__Active__c = true 
                                                                                             WITH SECURITY_ENFORCED];
            //No of records should be 2
            System.assertEquals(2,existingProductAssortTempRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
        
        //Get existing metadata wizard records
        List<cgcloud__Metadata_Wizard_Configuration__c> existingMetaRecNew = [SELECT id,
                                                                                  cgcloud__Sales_Org__c 
                                                                                  FROM cgcloud__Metadata_Wizard_Configuration__c 
                                                                                  WHERE Name!=NULL
                                                                                  WITH SECURITY_ENFORCED];
            //No of records should be 2
            System.assertEquals(2,existingMetaRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        
            //Get existing product assortment template records
        List<cgcloud__Product_Assortment_Template__c> existingProductAssortTempRecNew = [SELECT Id,
                                                                                             Name,
                                                                                             cgcloud__Sales_Org__c 
                                                                                             FROM cgcloud__Product_Assortment_Template__c 
                                                                                             WHERE cgcloud__Active__c = true 
                                                                                             WITH SECURITY_ENFORCED];
            //No of records should be 2
            System.assertEquals(2,existingProductAssortTempRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
            
            //Get existing custom period records  
            List<cgcloud__Custom_Period__c> custPeriodRecNew = [SELECT   Id,
                                                                          cgcloud__Custom_Calendar__r.Name,
                                                                          cgcloud__Date_From__c,
                                                                          cgcloud__Date_Thru__c,
                                                                          cgcloud__ExternalId__c,
                                                                          cgcloud__Business_Year__c,
                                                                          cgcloud__Description_Language_1__c
                                                                          FROM cgcloud__Custom_Period__c
                                                                          WHERE cgcloud__Custom_Calendar__r.Name!=NULL
                                                                          WITH SECURITY_ENFORCED];
              //No of records should be 0
              System.assertEquals(0,custPeriodRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        Test.StopTest();

    }
  }
    
     /*********************************************************************************
      @description      Call the class to create Custom Calendar and Custom Period
    **********************************************************************************/
    @isTest
    public static void executeDataLoadCustomPeriodCalendar(){
      //Create user
         User adminUser = [SELECT Id 
         FROM User 
         WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];

        System.runAs(adminUser) {  

        Set<String> orgnew = new Set<String>();
        List<String> valuesNewList = new List<String>();
         //Add Org Values
         orgnew.add(TPM_TestAutomationDataUtility.US01VAL);
         orgnew.add(TPM_TestAutomationDataUtility.IT01VAL);
         //Call below methods 
        valuesNewList.add('CustomCalendar');
        valuesNewList.add('CustomPeriod');
        TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
        
        //Get existing custom calendar records
        List<cgcloud__Custom_Calendar__c> custCalendarRec = [SELECT id,
                                                                    cgcloud__Sales_Org__c 
                                                                    FROM cgcloud__Custom_Calendar__c 
                                                                    WHERE cgcloud__ExternalId__c!=NULL
                                                                    WITH SECURITY_ENFORCED];
        //No of records should be 2
        System.assertEquals(2,custCalendarRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        
        //Get existing custom period records
        List<cgcloud__Custom_Period__c> custPeriodRec = [SELECT   Id,
                                                                  cgcloud__Custom_Calendar__r.Name,
                                                                  cgcloud__Date_From__c,
                                                                  cgcloud__Date_Thru__c,
                                                                  cgcloud__ExternalId__c,
                                                                  cgcloud__Business_Year__c,
                                                                  cgcloud__Description_Language_1__c
                                                                  FROM cgcloud__Custom_Period__c
                                                                  WHERE cgcloud__Custom_Calendar__r.Name!=NULL
                                                                  WITH SECURITY_ENFORCED];
        //No of records should be 65
        System.assertEquals(65,custPeriodRec.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

        TPM_InitialDataLoad.tpmInitialDataLoadCall(orgnew,valuesNewList);
        //Get existing custom calendar records
        List<cgcloud__Custom_Calendar__c> custCalendarRecNew = [SELECT id,
                                                                          cgcloud__Sales_Org__c 
                                                                          FROM cgcloud__Custom_Calendar__c 
                                                                          WHERE cgcloud__ExternalId__c!=NULL
                                                                          WITH SECURITY_ENFORCED];

          //No of records should be 2
          System.assertEquals(2,custCalendarRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
           //Get existing custom period records
          List<cgcloud__Custom_Period__c> custPeriodRecNew = [SELECT   Id,
                                                                      cgcloud__Custom_Calendar__r.Name,
                                                                      cgcloud__Date_From__c,
                                                                      cgcloud__Date_Thru__c,
                                                                      cgcloud__ExternalId__c,
                                                                      cgcloud__Business_Year__c,
                                                                      cgcloud__Description_Language_1__c
                                                                      FROM cgcloud__Custom_Period__c
                                                                      WHERE cgcloud__Custom_Calendar__r.Name!=NULL
                                                                      WITH SECURITY_ENFORCED];
         //No of records should be 65
          System.assertEquals(65,custPeriodRecNew.size(),TPM_TestAutomationDataUtility.RECORDSDONTMATCH);

      }

    }
  /*********************************************************************************
      @description      Call the class to check day of week and first day of week
    **********************************************************************************/
    @isTest
    public static void executedayOfWeek(){
      //Create admin user
      User adminUser = [SELECT Id 
         FROM User 
         WHERE Email = 'tpmadminuser008@invalidtpm.com' LIMIT 1];

        System.runAs(adminUser) {  
        Test.StartTest();
        String assertStatement = 'List should not be empty';
        String wed = TPM_DataLoadAutomationUtilNext.dayOfWeek(4);
        String thur = TPM_DataLoadAutomationUtilNext.dayOfWeek(5);
        String fri = TPM_DataLoadAutomationUtilNext.dayOfWeek(6);
        String sat = TPM_DataLoadAutomationUtilNext.dayOfWeek(7);
        String sun = TPM_DataLoadAutomationUtilNext.dayOfWeek(1);
        //wednesday must be returned
        System.assertEquals('Wednesday',wed,TPM_TestAutomationDataUtility.WRONGVALUE);
        //Thursday must be returned
        System.assertEquals('Thursday',thur,TPM_TestAutomationDataUtility.WRONGVALUE);
        //Friday must be returned
        System.assertEquals('Friday',fri,TPM_TestAutomationDataUtility.WRONGVALUE);
        //Saturday must be returned
        System.assertEquals('Saturday',sat,TPM_TestAutomationDataUtility.WRONGVALUE);
        //Sunday must be returned
        System.assertEquals('Sunday',sun,TPM_TestAutomationDataUtility.WRONGVALUE);

        Date firstDayDate = TPM_DataLoadAutomationUtilNext.returnDateForFirstDay('Wednesday',2022);
        Date firstDayDateThur = TPM_DataLoadAutomationUtilNext.returnDateForFirstDay('Thursday',2022);
        Date firstDayDateFri = TPM_DataLoadAutomationUtilNext.returnDateForFirstDay('Friday',2022);
        //Date should noe be blank
        System.assert(String.isNotBlank(String.valueof(firstDayDate)),assertStatement);
        System.assert(String.isNotBlank(String.valueof(firstDayDateThur)),assertStatement);
        System.assert(String.isNotBlank(String.valueof(firstDayDateFri)),assertStatement);
        
        Test.StopTest();
    }

  }
  
}