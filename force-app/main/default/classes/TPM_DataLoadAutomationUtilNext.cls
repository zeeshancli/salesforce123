/*********************************************************************************************
* @Name         : TPM_DataLoadAutomationUtilNext
* @author       : PwC Team
* @date         : December 22, 2022
* @description  : Utility class for TPM_InitialDataLoad
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/

public with sharing class TPM_DataLoadAutomationUtilNext {

    /*********************************************************************************
    * @method         : TPM_DataLoadAutomationUtilNext
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_DataLoadAutomationUtilNext(){


    }

/*********************************************************************************
    * @method         : returnDateForFirstDay
    * @return         : Date
    * @param            dayReceived
    * @param            businessYearVal
    * @description    : Returns Date for first day for creation of weekly or monthly records
    **********************************************************************************/
    public static Date returnDateForFirstDay (String dayReceived , Integer businessYearVal){
        
        //Returns first date for first month for the business year
        Date firstDate = date.newInstance(businessYearVal, 01, 01);
        Date dateObj = date.newInstance(businessYearVal, 01, 01);

        switch on dayReceived {
            when 'Monday' {		
                //When monday add 1
            dateObj = firstDate.tostartofmonth().tostartofweek().addDays(1);
            }
            when 'Tuesday' {	
                //When Tuesday add 2
                dateObj = firstDate.tostartofmonth().tostartofweek().addDays(2);
            }
            when 'Wednesday' {	
                //When Wednesday add 3
                dateObj = firstDate.tostartofmonth().tostartofweek().addDays(3);
            }
            when 'Thursday' {	
                //When Thursday add 4	
                dateObj = firstDate.tostartofmonth().tostartofweek().addDays(4);
            }
            when 'Friday' {	
                //When Friday add 5
                dateObj = firstDate.tostartofmonth().tostartofweek().addDays(5);
            }
            when 'Saturday'{	
                //When Saturday add 6
                dateObj = firstDate.tostartofmonth().tostartofweek().addDays(6);
            }
            when 'Sunday' {	
                //When Sunday add 7
                dateObj = firstDate.tostartofmonth().tostartofweek().addDays(7);
            }
        
    }  
       dateObj = dateObj<firstdate?dateObj.adddays(7):dateObj;
       return dateObj;
     }
     
     /*********************************************************************************
    * @method         : dayOfWeek
    * @return         : String
    * @param            dayVal
    * @description    : Returns day based on first day of the week from the sales org
    **********************************************************************************/
     public static String dayOfWeek (Integer dayVal){
         
        String dayOfWeekValue;

        switch on dayVal {
            when 2 {	
                //When 2 return Monday
                dayOfWeekValue = TPM_AutomationConstantUtilityClass.MONDAY;
            }
            when 3 {	
                //When 3 return Tuesday
                dayOfWeekValue = TPM_AutomationConstantUtilityClass.TUESDAY;
            }
            when 4 {	
                //When 4 return Wednesday
                dayOfWeekValue =  TPM_AutomationConstantUtilityClass.WEDNESDAY;
            }
            when 5 {
                //When 5 return Thursday	
                dayOfWeekValue = TPM_AutomationConstantUtilityClass.THURSDAY;
            }
            when 6 {	
                //When 6 return Friday	
                dayOfWeekValue = TPM_AutomationConstantUtilityClass.FRIDAY;
            }
            when 7{	
                //When 7 return Saturday
                dayOfWeekValue = TPM_AutomationConstantUtilityClass.SATURDAY;
            }
            when 1 {	
                //When 1 return Sunday
                dayOfWeekValue = TPM_AutomationConstantUtilityClass.SUNDAY;
            }
        }

            return dayOfWeekValue;
     }
     
      /*********************************************************************************
    * @method         : startYearVal
    * @return         : Map<String,Decimal>
    * @params          : null
    * @description    : Returns start year from metdata based on sales org for business year
    **********************************************************************************/
     //Get data from metadata and note down start year 
     public static Map<String,Integer> startYearVal(){

        Map<String,Integer> startYearMap = new Map<String,Integer>();
         
        //Get metdata records for business years
         for(TPM_Initial_Data_Load__mdt businessYearMetaDataList : [SELECT Id,
                                                       TPM_Start_Year__c,
                                                       TPM_No_of_years__c,
                                                       TPM_Sales_Org__c 
                                                       FROM TPM_Initial_Data_Load__mdt 
                                                       WHERE TPM_ObjectName__c = :TPM_AutomationConstantUtilityClass.BUSINESS_YEAR 
                                                       WITH SECURITY_ENFORCED]){
            //Map of sales org and start year
            startYearMap.put(businessYearMetaDataList.TPM_Sales_Org__c,(Integer)businessYearMetaDataList.TPM_Start_Year__c);
         }


        return startYearMap;
    }
    
      /*********************************************************************************
    * @method         : noofyearval
    * @return         : Map<String,Decimal>
    * @params         : null
    * @description    : Returns No of years from metdata based on sales org for business year
    **********************************************************************************/
    public static Map<string,Integer> noOfYearVal(){

        Map<String,Integer> noOfYearValueMap = new Map<String,Integer>();


         for(TPM_Initial_Data_Load__mdt businessYearMetaDataList : [SELECT Id,
                                                                           TPM_Start_Year__c,
                                                                           TPM_No_of_years__c,
                                                                           TPM_Sales_Org__c 
                                                                           FROM TPM_Initial_Data_Load__mdt 
                                                                           WHERE TPM_ObjectName__c = :TPM_AutomationConstantUtilityClass.BUSINESS_YEAR 
                                                                           WITH SECURITY_ENFORCED]){

           noOfYearValueMap.put(businessYearMetaDataList.TPM_Sales_Org__c,(Integer)businessYearMetaDataList.TPM_No_of_years__c);
         }
        
        return noOfYearValueMap;
    }
    
       /*********************************************************************************
    * @method         : customerTempMetadata
    * @return         : TPMInitialDataLoadWrapper.TPMInitialDataLoadWrapper1
    * @param            orgVal
    * @description    : Returns Metadata records for creation of customer template records
    **********************************************************************************/
    //Get customer template metdata for insertion of customer template records
    public static TPMInitialDataLoadWrapper.TPMInitialDataLoadWrapper1 customerTempMetadata(Set<String> orgVal){

        Map<String,String> salesOrgPlanningModeMap = new Map<String,String>(); 
        Map<String,TPM_Initial_Data_Load__mdt> metaDataForCustomerTemp = new Map<String,TPM_Initial_Data_Load__mdt>();
        Map<Map<String,String>,String> planningModeProductLevelMap = new Map<Map<String,String>,String>();
        Map<Map<String,String>,String> planningModeInitialRoleMap = new Map<Map<String,String>,String>();


         for(TPM_Initial_Data_Load__mdt customerTemplateMetadataList : [SELECT Id,
                                                                               TPM_Sales_Org__c,
                                                                               TPM_Customer_Template_Planning_Mode__c,
                                                                               TPM_Initial_Roles__c,
                                                                               TPM_Available_Product_Level__c 
                                                                               FROM TPM_Initial_Data_Load__mdt 
                                                                               WHERE TPM_ObjectName__c = :TPM_AutomationConstantUtilityClass.CUSTOMERTEMPLATEPLANNINGMODE 
                                                                               AND TPM_Sales_Org__c IN:orgval 
                                                                               WITH SECURITY_ENFORCED]){

             //Create below maps based on metadata values
             //Map of sales org and metadata record
             metaDataForCustomerTemp.put(customerTemplateMetadataList.TPM_Sales_Org__c,customerTemplateMetadataList);

             //Map of sales org and planning mode from metadata
             salesOrgPlanningModeMap.put(customerTemplateMetadataList.TPM_Sales_Org__c,customerTemplateMetadataList.TPM_Customer_Template_Planning_Mode__c);
             
             //Get json value for product level and deserialize this
             Map<String,Object> prodvalue = (Map<String, Object>)JSON.deserializeUntyped(customerTemplateMetadataList.TPM_Available_Product_Level__c);
             
             //Loop all the json records and create Map
             for(String key: prodValue.keySet()){
                Map<String,String> salesOrgPlanningModeTempMap = new Map<String,String>();
                salesOrgPlanningModeTempMap.put(customerTemplateMetadataList.TPM_Sales_Org__c,key);
                planningModeProductLevelMap.put(salesOrgPlanningModeTempMap,(String)prodValue.get(key));
                }
             //Get json value for initial role and deserialize this
             Map<String,Object> initialRoleValue = (Map<String, Object>)JSON.deserializeUntyped(customerTemplateMetadataList.TPM_Initial_Roles__c);
             //Loop all the initial role records and create Map
                for(String key: initialRoleValue.keySet()){
                Map<String,String> salesOrgPlanModeTempMap = new Map<String,String>();
                salesOrgPlanModeTempMap.put(customerTemplateMetadataList.TPM_Sales_Org__c,key);
                planningModeInitialRoleMap.put(salesOrgPlanModeTempMap,(String)initialRoleValue.get(key));
                }
            }
         
     
            TPMInitialDataLoadWrapper.TPMInitialDataLoadWrapper1 metaDataForCustomerTemplate = new TPMInitialDataLoadWrapper.TPMInitialDataLoadWrapper1(metaDataForCustomerTemp,salesOrgPlanningModeMap,planningModeProductLevelMap,planningModeInitialRoleMap);
            return metaDataForCustomerTemplate;
        }
    

    
       /*********************************************************************************
    * @method         : getActiveValues
    * @return         : Boolean
    * @param           value
    * @description    : Returns True or false based on the value
    **********************************************************************************/
    public static Boolean getActiveValues(String value){

        Boolean ischeckValue = value=='TRUE'?true:false;

        return ischeckValue;
    }
    
       /*********************************************************************************
    * @method         : kpiSetData
    * @return         : TPMInitialDataLoadWrapperNext.TPMInitialDataLoadWrapperKpi
    * @params         : null
    * @description    : Returns Map of existing Kpi set Records
    **********************************************************************************/
    public static TPMInitialDataLoadWrapperNext.TPMInitialDataLoadWrapperKpi kpiSetData(){

        Map<String,String> kpiNameIdMap = new Map<String,String>();
        Map<String,String> kpiNameSalesOrgMap = new Map<String,String>();
        Map<Map<String,String>,String> kpiNameSalesOrgAsKeyNameAsValueMap = new Map<Map<String,String>,String>();

           for(cgcloud__KPI_Set__c existingKpiRecordsList : [SELECT id,
                                                                    TPM_Sales_Org__c,
                                                                    Name,
                                                                    TPM_KPISetType__c 
                                                                    FROM cgcloud__KPI_Set__c 
                                                                    WHERE Name != NULL 
                                                                    WITH SECURITY_ENFORCED]){
            kpiNameIdMap.put(existingKpiRecordsList.Name,existingKpiRecordsList.id);
            kpiNameSalesOrgMap.put(existingKpiRecordsList.Name,existingKpiRecordsList.TPM_Sales_Org__c);
            if(String.isNotBlank(existingKpiRecordsList.TPM_Sales_Org__c)){
                List<String> picklistValExistingList = existingKpiRecordsList.TPM_Sales_Org__c.Split(';');
                for(String pickValue : picklistValExistingList){
                //Create map with combination of KPI Set name and org value
                Map<string,string> kpiSetTypeOrgMap = new Map<string,string>();
                kpiSetTypeOrgMap.put(existingKpiRecordsList.Name,pickValue);
                kpiNameSalesOrgAsKeyNameAsValueMap.put(kpiSetTypeOrgMap,existingKpiRecordsList.Name);
            }
        
        }
    }
    
    TPMInitialDataLoadWrapperNext.TPMInitialDataLoadWrapperKpi metaDataForKpi = new TPMInitialDataLoadWrapperNext.TPMInitialDataLoadWrapperKpi(kpiNameIdMap,kpiNameSalesOrgMap,kpiNameSalesOrgAsKeyNameAsValueMap);
    return metaDataForKpi;

}

    /*********************************************************************************
    * @method         : returnApiName
    * @return         : Map<String,String>
    * @params         : null
    * @description    : Returns API name of all fields of salesorg object
    **********************************************************************************/
public static Map<String,String> returnApiName(){
    
    Map<String,String> apiDataTypeMap = New Map<String,String>();

        for(FieldDefinition fieldTypeList : [SELECT DataType,
                                                    QualifiedApiName 
                                                    FROM FieldDefinition 
                                                    WHERE EntityDefinitionId = :TPM_AutomationConstantUtilityClass.SALESORGOBJECTNAME
                                                    WITH SECURITY_ENFORCED]){

            apiDataTypeMap.put(fieldTypeList.QualifiedApiName,fieldTypeList.DataType);

                  }
                  return apiDataTypeMap;
      }

      
}