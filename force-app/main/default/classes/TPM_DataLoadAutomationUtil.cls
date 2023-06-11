/*********************************************************************************************
* @Name         : TPM_DataLoadAutomationUtil
* @author       : PwC Team
* @date         : December 22, 2022
* @description  : Utility class for TPM_InitialDataLoad
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/


public inherited sharing class TPM_DataLoadAutomationUtil {
    
    /*********************************************************************************
    * @method         : TPM_DataLoadAutomationUtil
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_DataLoadAutomationUtil(){


    }

/*********************************************************************************
    * @method         : returnCustomCalendar
    * @return         : Map<String,Id>
    * @param            salesOrg
    * @description    : Returns existing custom calendar (Map of custom calendar salesorg and id)
    **********************************************************************************/
   
    public static Map<String,Id> returnCustomCalendar(Set<String> salesOrg){

        Map<String,Id> customCalendarMap = new Map<String,Id>();
          //Fetch existing customercalendar records based on sales org
            for(cgcloud__Custom_Calendar__c customCalendarObj : [SELECT ID,
                                                                       NAME,
                                                                       cgcloud__Sales_Org__c
                                                                       FROM cgcloud__Custom_Calendar__c
                                                                       WHERE cgcloud__Sales_Org__c in :salesorg 
                                                                       WITH SECURITY_ENFORCED]){   
            //Map of salesorg and custom calendar record id                                          
            customCalendarMap.put(customCalendarObj.cgcloud__Sales_Org__c,customCalendarObj.Id);                                                 

        }
        //Return custom calendar records
        return customCalendarMap;
    }
    
/*********************************************************************************
    * @method         : returnSalesOrg
    * @return         : Map<String,Integer>
    * @param            salesOrg
    * @description    : Returns Map of existing sales org records name and first day of week
    **********************************************************************************/
    public static Map<String,Integer> returnSalesOrg( Set<String> salesOrg ){
        Map<String,Integer> salesOrgMap = new Map<string,Integer>();

        //Fetch existing sales org records based on sales org passed by admin
            for(cgcloud__Sales_Organization__c salesOrgObj : [SELECT Id,
                                                                    Name,
                                                                    cgcloud__First_Day_Of_Week__c
                                                                    FROM cgcloud__Sales_Organization__c
                                                                    WHERE NAME in :salesOrg 
                                                                    WITH SECURITY_ENFORCED]){
           
        // Map of sale
            salesOrgMap.put(salesOrgObj.NAME,Integer.valueof(salesOrgObj.cgcloud__First_Day_Of_Week__c));                                                 
        }
        return salesOrgMap;
    }

/*********************************************************************************
    * @method         : returnWeekDayProfile
    * @return         : Map<string,string>
    * @param            salesOrg
    * @description    : Returns Map of existing weekdayprofile sales org and weekday profile record id
    **********************************************************************************/
    
    public static Map<String,String> returnWeekDayProfile(Set<String> salesOrg){

        Map<string,string> weekdayValuesMap = new Map<string,string>();
        //Get existing weekday share profile records by passing sales org
            for(cgcloud__Week_Day_Share_Profile__c existWeekDay: [SELECT id,
                                                                         cgcloud__Sales_Org__c 
                                                                         FROM cgcloud__Week_Day_Share_Profile__c 
                                                                         WHERE cgcloud__Sales_Org__c in :salesOrg 
                                                                         WITH SECURITY_ENFORCED]){
                //Return map of sales org and week dayrecord id
                weekdayValuesMap.put(existWeekDay.cgcloud__Sales_Org__c,existWeekDay.id);
          }
        
        return weekdayValuesMap;
    }
    
/*********************************************************************************
    * @method         : returnSalesOrgRec
    * @return         : Map<string,string>
    * @param            salesOrg
    * @description    : Returns Map of existing  sales org value and salesorg record id
    **********************************************************************************/
    
    public static Map<String,String> returnSalesOrgRec(Set<String> salesOrg){
        Map<String,String> salesRecValuesMap = new Map<String,String>();
        //Get existing sales org records
                for(cgcloud__Sales_Organization__c salesOrgRec : [SELECT id,
                                                                       cgcloud__Sales_Org_Value__c,
                                                                       cgcloud__Currency__c 
                                                                       FROM cgcloud__Sales_Organization__c 
                                                                       WHERE cgcloud__Sales_Org_Value__c in:salesOrg 
                                                                       WITH SECURITY_ENFORCED]) {
                    //Return map of sales org and record id
                    salesRecValuesMap.put(salesOrgRec.cgcloud__Sales_Org_Value__c,salesOrgRec.id);
                }
            
        return salesRecValuesMap;
    }
    
/*********************************************************************************
    * @method         : returnSalesOrgRec
    * @return         : Map<string,string>
    * @param            salesOrg
    * @description    : Returns Map of existing business year salesorg name and last year for which record is created
    **********************************************************************************/
    
    public static  Map<String,Integer> busYearGetVal(Set<String> salesOrg){

        Map<String,Integer> busYearValueMap = new Map<String,Integer>();
        //Get existing business year records
            for(cgcloud__Business_Year__c byear : [SELECT id,
                                                         cgcloud__Year_Number__c,
                                                         cgcloud__Sales_Organization__r.Name 
                                                         FROM cgcloud__Business_Year__c 
                                                         WHERE cgcloud__Sales_Organization__r.Name IN:salesOrg 
                                                         WITH SECURITY_ENFORCED 
                                                         ORDER BY cgcloud__Year_Number__c DESC]){
                if(!busYearValueMap.containsKey(byear.cgcloud__Sales_Organization__r.Name)){
                    //Return map of sales org and business year number to check whether record should be created or not
                    busYearValueMap.put(byear.cgcloud__Sales_Organization__r.Name,(Integer)byear.cgcloud__Year_Number__c);
                }
            
         }
        return busYearValueMap;
    }
    
/*********************************************************************************
    * @method         : salesOrgValForByear
    * @return         : Map<string,string>
    * @params         : null
    * @description    : Returns Map of existing sales org name and record id
    **********************************************************************************/
    
    public static  Map<String,String> salesOrgValForByear(){

        Map<string,string> existingSalesOrgForByMap = new Map<string,string>();
        //Get existing sales record for business year
        for(cgcloud__Sales_Organization__c salesRecord : [SELECT Id,
                                                          Name,
                                                          cgcloud__Sales_Org_Value__c
                                                          FROM cgcloud__Sales_Organization__c 
                                                          WHERE cgcloud__Sales_Org_Value__c!=NULL
                                                          WITH SECURITY_ENFORCED]){
            //Return map of salesorg name and corresponding record id
            existingSalesOrgForByMap.put(salesRecord.name,salesRecord.id);
        }
      
        return existingSalesOrgForByMap;
    }
   
/*********************************************************************************
    * @method         : custCalValue
    * @return         : Map<string,string>
    * @param            salesOrg
    * @description    : Returns Map of existing custom calendar salesorg and record id
    **********************************************************************************/
    
    public static  Map<String,String> custCalValue(Set<String> salesOrg){

        Map<String,String> custCalendarRecMap = new Map<String,String>();
           
        //Get existing custom calendar records
           for(cgcloud__Custom_Calendar__c custCalendarRec : [SELECT id,
                                                         cgcloud__Sales_Org__c 
                                                         FROM cgcloud__Custom_Calendar__c 
                                                         WHERE cgcloud__Sales_Org__c IN:salesorg 
                                                         WITH SECURITY_ENFORCED]){
            //Return map of sales org and record id
            custCalendarRecMap.put(custCalendarRec.cgcloud__Sales_Org__c,custCalendarRec.id);
        }
       
        return custCalendarRecMap;
    }
    
/*********************************************************************************
    * @method         : metaWizardVal
    * @return         : Map<string,string>
    * @param           salesOrg
    * @description    : Returns Map of existing metadata wiard sales org name and record id
    **********************************************************************************/

    public static  Map<String,String> metaWizardVal(Set<String> salesOrg){

        Map<String,String> metaWizardValMap = new Map<String,String>();
          
        //Get existing metadata wizard records
           for(cgcloud__Metadata_Wizard_Configuration__c existingMetaRec : [SELECT id,
                                                                          cgcloud__Sales_Org__c 
                                                                          FROM cgcloud__Metadata_Wizard_Configuration__c 
                                                                          WHERE cgcloud__Sales_Org__c IN:salesOrg 
                                                                          WITH SECURITY_ENFORCED]){
             //Return map of sales org and record id
             metaWizardValMap.put(existingMetaRec.cgcloud__Sales_Org__c,existingMetaRec.id);
        }
       
        return metaWizardValMap;
    }

}