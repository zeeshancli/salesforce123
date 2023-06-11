/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadKPISet
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load in for KPI Set.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public with sharing class TPM_InitialDataLoadKPISet {
    //Below maps to be used in both the methods to access the data
    static set<String> orgValuesToConsider;
    //Map of KPI SET name and record id
    static Map<String,String> kpiSetNameIdMap;
    //Map of KPI SET Name and sales Org
    static Map<String,String> kpiSetNameSalesOrgMap;
    //Map of map of kpi name and sales org as key and name as value
    static Map<Map<String,String>,String> kpiSetOrgKeyNameMap;
    static List<String> headings = new List<String>();
    static Map<String,String> apinameDateTypeMap = TPM_DataLoadAutomationUtilCon.returnApiNameKpi();
    static Map<String,String> setnameOrgMap = new Map<String,String>();
    static  Integer posOfSalesOrg ;
    static Integer  posOfKpiSetName;

     /*********************************************************************************
    * @method         : TPM_InitialDataLoadKPISet
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadKPISet(){


    }
    
   /*********************************************************************************
    * @method         : kpiSetLoad
    * @param            orgVal
    * @description    : Fetch data from CSV file and create KPI Set records
    **********************************************************************************/
    public static void kpiSetLoad(Set<String> orgVal){

        //Fetch data from CSV file and insert records for salesorg present in both csv file and sales org passed from UI
        orgValuesToConsider = orgVal;

        //Get existing KPI set Records
        TPMInitialDataLoadWrapperNext.TPMInitialDataLoadWrapperKpi kpiExistingRec = TPM_DataLoadAutomationUtilNext.kpiSetData();

        //Map of KPI SET name and record id
        kpiSetNameIdMap = kpiExistingRec.kpiRecNameIdMap;


        //Map of KPI SET Name and sales Org
        kpiSetNameSalesOrgMap = kpiExistingRec.kpiRecNameSalesOrgMap;

         //Map of map of kpi name and sales org as key and name as value
        kpiSetOrgKeyNameMap = kpiExistingRec.kpiRecNameSalesOrgAsKeyNameAsValueMap;

        List<cgcloud__KPI_Set__c> kpiSetList = new List<cgcloud__KPI_Set__c>();
        //Get Data from Static Resource
        String kpiCsv;
        //For Test classes use data created in utility class
        if(!Test.isRunningTest()){
            StaticResource kpiSetStaticResource = [SELECT Body 
                                                         FROM StaticResource 
                                                         WHERE Name = :System.Label.TPM_Data_Load_File_Name_KpiSet
                                                         WITH SECURITY_ENFORCED];
         
            kpiCsv = kpiSetStaticResource.Body.toString();
        }

        else{
         //Get data from static resource
               String str = TPM_TestAutomationDataUtility.TESTDATAFORKPISET;   
               Blob csvFileBody = Blob.valueOf(str);
               kpiCsv = csvFileBody.toString();
            }

            String[] kpiCsvlines = kpiCsv.split('\n');
            //Split the headings
            headings = kpiCsvlines[0].split(',');

         //Delete blank spaces from headings if any
            for(integer ihead=0;ihead<headings.size();ihead++){
                  if(string.isNotBlank(headings[ihead])){
                     headings[ihead] = headings[ihead].deleteWhitespace();
                  }
                  else{
                     headings.remove(ihead); 
                  }
            }
        
        //Get position of sales org
        posOfSalesOrg = headings.indexOf(TPM_AutomationConstantUtilityClass.TPMSALESORG);

        //Get position of name
        posOfKpiSetName = headings.indexOf(TPM_AutomationConstantUtilityClass.NAMEFORKPISET);

        setnameOrgMap = TPM_InitialDataLoadKPISet.getsetnameOrgMap(kpiCsvlines);
        //Loop records from CSV
        //Loop entire row
        for(Integer intNumber = 1;  intNumber < kpiCsvlines.size() ; intNumber++){
            if(kpiCsvlines[intNumber].length() !=  0){
            String[] column = kpiCsvlines[intNumber].split(',');
  
            //Create records based on values from CSV file
            String kpiSetName = column[posOfKpiSetName];
            //Get final list of org value to be inserted for the KPI Set
            //Create records based on values from CSV file
            cgcloud__KPI_Set__c kpiInsertRec = TPM_InitialDataLoadKPISet.kpiGetValue(column,kpiSetName);
            if(String.isNotBlank(kpiInsertRec.TPM_Sales_Org__c)){
                kpiSetList.add(kpiInsertRec);
              }
           }
        }
            //Insert KPISet records
               TPM_InitialDataLoadKPISet.insertKpiRec(kpiSetList);
            //After inserting KPISet records check if for any customer template KPI sets is not assigned and assign them
            //if newly created KPI setv can be assigned
               TPM_InitialDataLoadKPISet.updateKPISetMissing(orgVal);
    }  
    
   
   /*********************************************************************************
    * @method         : kpiGetValue
    * @param            column
    * @param            kpiSetName
    * @return         : cgcloud__KPI_Set__c
    * @description    : Fetch data from CSV file and create KPI Set records
    **********************************************************************************/
      public static cgcloud__KPI_Set__c kpiGetValue(String[] column,String kpiSetName){

               cgcloud__KPI_Set__c kpiSetRec = new cgcloud__KPI_Set__c ();
               String setName;
               //Loop all column values and create record
               for (Integer count = 0; count < column.size(); count++) {
               
               // Check if record already exists by using KPI Set Name
               setName = column[posOfKpiSetName];
               //If datatype is boolean get true or false based on value from CSV
               if(apinameDateTypeMap.get(headings[count].deleteWhitespace()) == TPM_AutomationConstantUtilityClass.CHECKBOX){
                     kpiSetRec.put(headings[count].deleteWhitespace(), TPM_DataLoadAutomationUtilNext.getactivevalues(column[count].deleteWhitespace()));
                  }

      
               //if heading is sales org get the final org value and pass it as value and orgs passed by used has the value
               else if(headings[count].deleteWhitespace() == TPM_AutomationConstantUtilityClass.TPMSALESORG && setnameOrgMap.containsKey(setName)){
                        kpiSetRec.put(headings[count].deleteWhitespace(), setnameOrgMap.get(setName));
                  }
               else{
                  //insert heading name along with value
                        kpiSetRec.put(headings[count].deleteWhitespace(), column[count]);
                  }
               }

               //If record already exists modify the record with new sales org value
               if (kpiSetNameIdMap.containsKey(kpiSetName)){
                        kpiSetRec.put('Id', kpiSetNameIdMap.get(kpiSetName));
                  }
               return kpiSetRec;
            }

    
         /*********************************************************************************
          * @method         : getFinalOrg
         * @return         : String
         * @param            orgValues
         * @param            kpiSetName
         * @description    : Get final Org values to be inserted for KPI set records
         **********************************************************************************/
               public static String getFinalOrg(List<String> orgValues, String kpiSetName){

               //Check if the sales org value in CSV file is already present in the org and if not present add the value

               String finalOrgVal;
               Map<String,String> kpiSetNameSalesOrgMapTemp = new Map<String,String>();
               for(String org : orgValues){
                  kpiSetNameSalesOrgMapTemp.put(kpiSetName,org.deleteWhitespace());
                  //First condition is to check if the org values fetched from the file is inputted by admin as well
                  //Second condition is to check that the sales org is not there for existing KPI sets
                  //If both conditions satisfy then store the sales org in finalOrgValue

               if(orgValuesToConsider.contains(org) && !(kpiSetOrgKeyNameMap.containsKey(kpiSetNameSalesOrgMapTemp))){
                     if(String.isNotBlank(finalOrgVal)){
                     finalOrgVal = finalOrgVal+org+';';
                     }
                     else{
                     finalOrgVal = org+';';
                     }
                  }
            }
               //Remove last semicolon from finalorgvalue
               String finalOrg = String.isNotBlank(finalOrgVal) ? finalOrgVal.removeEnd(';') : ' ';
               return finalOrg;
            }
            
         /*********************************************************************************
          * @method         : insertKpiRec
         * @param            kpiSetList
         * @description    : Insert KPI records
         **********************************************************************************/
         public static void insertKpiRec(List<cgcloud__KPI_Set__c> kpiSetList){
            if(!kpiSetList.isempty() && Schema.sObjectType.cgcloud__KPI_Set__c.isCreateable()){
            //Upsert kpiset records
               TPM_InitialDataLoadHandleError.createAndHandleError(kpiSetList,TPM_AutomationConstantUtilityClass.KPISETLOAD);
               } 
         }
         
         /*********************************************************************************
          * @method         : updateKPISetMissing
         * @param            orgVal
         * @description    : Get customer templates where KPI set is not assigned and assign KPI set 
         **********************************************************************************/
         public static void updateKPISetMissing(Set<String> orgVal){
            
            //After inserting KPISet records check if for any customer template KPI sets is not assigned and assign them
            //if newly created KPI setv can be assigned
            List<cgcloud__Account_Template__c> customerTemplateList = new List<cgcloud__Account_Template__c>();
            
            //Get all customer template records where kpi set not assigned
            TPMInitialDataLoadWrapperNext.TPMInitialDataKpi kpiSetRec = TPM_DataLoadAutomationUtilCon.getKpiCustomerAssigned(orgVal);

            //Map of Map of planning mode and sales org as key and KPI Set id as value of customer template record
            Map<Map<string,string>,string> planningModeSalesOrgAsKeyKPISetIdAsValMap = kpiSetRec.kpiIdMap;

            //Map of Map of set type and sales org as key and KPI Set record id as value to store existing KPI Records
            Map<Map<string,string>,string> existingKpiSetOrgval = TPM_DataLoadAutomationUtilCon.getExistingKpiSetForCustomer();

            //Map of Map of planning mode and sales org as key and customerTemplate id as value of customer template record
            Map<Map<string,string>,string> planningModeSalesOrgAsKeyCustTempIdAsValMap = kpiSetRec.kpiRecAssignedCustomerTempIdMap;
            
            //Check if any customer template record exists without KPI set assignment
            if(!planningModeSalesOrgAsKeyKPISetIdAsValMap.isEmpty() ){
            
            //If record exists the loop the map and check if kpi set exists for kpi set type and sales org pair
            for(Map<String,String> key : planningModeSalesOrgAsKeyKPISetIdAsValMap.keySet()){

               // First condition to check that Kpi set is not assigned to customer template based 
               //on planning mode and Sales Org
               //Second condition is that kpi set exists for the planning mode and sales org combination
               //If both condition satisfies then update customer template with Kpi set
               if(planningModeSalesOrgAsKeyKPISetIdAsValMap.get(key) == null && existingKpiSetOrgval.containsKey(key)){
                  //Insert record
                  cgcloud__Account_Template__c updaterec = new cgcloud__Account_Template__c();
                  updaterec.id = planningModeSalesOrgAsKeyCustTempIdAsValMap.get(key);
                  updaterec.cgcloud__KPI_Set_Plan_Dependent__c = existingKpiSetOrgval.get(key);
                  customerTemplateList.add(updaterec);
               }
            }

            }

            if(!customerTemplateList.isempty() && Schema.sObjectType.cgcloud__Account_Template__c.isUpdateable()){
               //Upsert accounttemp records
               TPM_InitialDataLoadHandleError.createAndHandleError(customerTemplateList,TPM_AutomationConstantUtilityClass.KPISETLOAD);
               } 

         }
     
    /*********************************************************************************
    * @method         : getsetnameOrgMap
    * @return         : Map<String,String>
    * @param            kpiCsvlines
    * @description    : Get final Org values to be inserted for KPI set records by checeking
    *                   if sales org passed by admin is present in csv file 
    **********************************************************************************/
      public static Map<String,String> getsetnameOrgMap(String[] kpiCsvlines){

         //This loop is to create final org value based on each column value from CSV
         Map<String,String> setnameOrgMapTemp = new Map<String,String>();
         //Loop all the rows from CSV
         for(Integer intNumber = 1;  intNumber < kpiCsvlines.size() ; intNumber++){
            if(kpiCsvlines[intNumber].length() !=  0){
            
            //Split the values
            String[] column = kpiCsvlines[intNumber].split(',');
            
            //Split sales org values
            List<String> salesOrgValFromCSV = column[posOfSalesOrg].split(';');
            String kpiSetName = column[posOfKpiSetName];
            String finalOrgValue; 
            //Get final list of org value to be inserted for the KPI Set
            finalOrgValue = TPM_InitialDataLoadKPISet.getFinalOrg(salesOrgValFromCSV,kpiSetName);
            //If KPI set record already exists then append the old values of sales org for the kpi set
            if(kpiSetNameSalesOrgMap.ContainsKey(kpiSetName)){
               setnameOrgMapTemp.put(column[posOfKpiSetName],kpiSetNameSalesOrgMap.get(kpiSetName)+';'+finalOrgValue);
            }
            else{
               setnameOrgMapTemp.put(column[posOfKpiSetName],finalOrgValue);
            }
            }
         }
         return setnameOrgMapTemp;
      }
   }