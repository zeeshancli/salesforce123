/*********************************************************************************************
* @Name         : TPM_DataLoadAutomationUtilCon
* @author       : PwC Team
* @date         : December 22, 2022
* @description  : Utility class for TPM_InitialDataLoad
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/

public with sharing class TPM_DataLoadAutomationUtilCon {
    
    /*********************************************************************************
    * @method         : TPM_DataLoadAutomationUtilCon
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_DataLoadAutomationUtilCon(){


    }
/*********************************************************************************
    * @method         : getFinalOrgVal
    * @return         : Map<String,Set<String>>
    * @param            salesOrg
    * @description    : Returns Map of existing customer template record planning mode and sales org as key and record id as value
    **********************************************************************************/
       
        public static Map<String,Set<String>> getFinalOrgVal(Set<String> salesOrg){
        Map<String,Set<String>> existingCustomerTempRec = new Map<String,Set<String>>();

             //Get existing customer template records
                    for(cgcloud__Account_Template__c existingCustomerRec : [SELECT Id,
                                                                                   Name,
                                                                                   cgcloud__Sales_Org__c,
                                                                                   RecordType.Name,
                                                                                   TPM_CustTemp_PlanMode__c 
                                                                                   FROM cgcloud__Account_Template__c 
                                                                                   WHERE cgcloud__Active__c = true 
                                                                                   AND cgcloud__Sales_Org__c IN:salesOrg 
                                                                                   WITH SECURITY_ENFORCED]){

                         //Map of sales org and set of planning mode                                                                      
                        if(existingCustomerTempRec.containsKey(existingCustomerRec.cgcloud__Sales_Org__c)){
                            existingCustomerTempRec.get(existingCustomerRec.cgcloud__Sales_Org__c).add(existingCustomerRec.TPM_CustTemp_PlanMode__c);
                            } else{
                                existingCustomerTempRec.put(existingCustomerRec.cgcloud__Sales_Org__c, new Set<String>{existingCustomerRec.TPM_CustTemp_PlanMode__c});
                            }

                    }
                
        return existingCustomerTempRec;
     }

   /*********************************************************************************
    * @method         : getProdTempVal
    * @return         : Map<string,string>
    * @param            salesOrg
    * @description    : Returns Map of existing product template record sales org and record type name
    **********************************************************************************/
    public static Map<string,string> getProdTempVal(Set<String> salesOrg){

        Map<String,String> existingProductSalesOrgRecordTypeMap = new Map<String,String>();
        //Get existing product template record
        for(cgcloud__Product_Template__c existingProductTempRec : [SELECT Id,
                                                                        Name,
                                                                        Recordtype.Name,
                                                                        cgcloud__Sales_Org__c 
                                                                        FROM cgcloud__Product_Template__c 
                                                                        WHERE cgcloud__Active__c = true 
                                                                        AND cgcloud__Sales_Org__c IN:salesorg 
                                                                        WITH SECURITY_ENFORCED]){
            //Return map of product template sales org and its corresponding record id
            existingProductSalesOrgRecordTypeMap.put(existingProductTempRec.cgcloud__Sales_Org__c,existingProductTempRec.Recordtype.Name);
        }
    
    return existingProductSalesOrgRecordTypeMap;
  }

/*********************************************************************************
    * @method         : getProdassortmentrec
    * @return         : Set<string>
    * @param            salesOrg
    * @description    : Returns Set of org name for existing prduct template records
    **********************************************************************************/
    public static Set<string> getProdAssortmentRec (Set<String> salesOrg){

    Set<string> existingAssortmentOrgSet = new Set<string>();
    //Get existing product assortment template records
    for(cgcloud__Product_Assortment_Template__c existingProductAssortTempRec : [SELECT Id,
                                                                       Name,
                                                                       cgcloud__Sales_Org__c 
                                                                       FROM cgcloud__Product_Assortment_Template__c 
                                                                       WHERE cgcloud__Active__c = true 
                                                                       AND cgcloud__Sales_Org__c IN:salesorg 
                                                                       WITH SECURITY_ENFORCED]){
        //Return set of existing product template sales org values
        existingAssortmentOrgSet.add(existingProductAssortTempRec.cgcloud__Sales_Org__c);
        }
    
    return existingAssortmentOrgSet;
  }

/*********************************************************************************
    * @method         : getExistingKpiSetForCustomer
    * @return         : Map<Map<string,string>,string>
    * @params         : null
    * @description    : Returns Map of set type and sales org as key and record id as value for existing KPI Set Records
    **********************************************************************************/
    
    public static Map<Map<String,String>,String> getExistingKpiSetForCustomer(){

    Map<Map<String,String>,String> existingKpiSetForCustomerMap = New Map<Map<String,String>,String>();
     //Get existing KPI records
    for(cgcloud__KPI_Set__c existingKpiSetRecordList : [SELECT Id,
                                              TPM_Sales_Org__c,
                                              Name,
                                              TPM_KPISetType__c 
                                              FROM cgcloud__KPI_Set__c 
                                              WHERE Name!=NULL 
                                              WITH SECURITY_ENFORCED]){

    List<String> splitOrgValList = new List<string>();
    if(String.isNotBlank(existingKpiSetRecordList.TPM_Sales_Org__c)){
        splitOrgValList = existingKpiSetRecordList.TPM_Sales_Org__c.split(';');
      }
    for(string splitOrgVal:splitOrgValList){
        Map<string,string> setTypeOrgMap = new Map<string,string>();
        setTypeOrgMap.put(existingKpiSetRecordList.TPM_KPISetType__c,splitOrgVal);
        //Return map of KPI Set salesorg and its corresponding planning mode
        existingKpiSetForCustomerMap.put(setTypeOrgMap,existingKpiSetRecordList.id);
       }
    }
    return existingKpiSetForCustomerMap;
   }
   
   /*********************************************************************************
    * @method         : getKpiCustomerAssigned
    * @return         :TPMInitialDataLoadWrapper.TPMInitialDataKpi
    * @param            salesOrg
    * @description    : Returns Map of set type and sales org as key and record id as value for existing KPI Set Records
    **********************************************************************************/
   public static TPMInitialDataLoadWrapperNext.TPMInitialDataKpi getKpiCustomerAssigned(Set<String> salesOrg){

    Map<Map<String,String>,String>  kpiAssignedCustomerTempMap = new Map<Map<String,String>,String>();
    Map<Map<String,String>,String>  kpiAssignedCustomerTempIdMap = new Map<Map<String,String>,String>();

                //Get account template records where kpi set is not assigned
                for(cgcloud__Account_Template__c custTemplateRecList : [SELECT id,
                                                                  Name,
                                                                  cgcloud__KPI_Set_Plan_Dependent__c,
                                                                  cgcloud__Sales_Org__c,
                                                                  RecordType.Name,
                                                                  TPM_CustTemp_PlanMode__c 
                                                                  FROM cgcloud__Account_Template__c 
                                                                  WHERE cgcloud__Active__c = true 
                                                                  AND cgcloud__Sales_Org__c IN:salesOrg 
                                                                  AND TPM_CustTemp_PlanMode__c !=NULL 
                                                                  WITH SECURITY_ENFORCED]){
                    Map<string,string> planModeOrgMap = new Map<string,string>();
                    planModeOrgMap.put(custTemplateRecList.TPM_CustTemp_PlanMode__c,custTemplateRecList.cgcloud__Sales_Org__c);
                    //Return map of map of planning mode and salesorg and values as corresponding record id to check if record already exists
                    kpiAssignedCustomerTempIdMap.put(planModeOrgMap,custTemplateRecList.id);
                    kpiAssignedCustomerTempMap.put(planModeOrgMap,custTemplateRecList.cgcloud__KPI_Set_Plan_Dependent__c);
                }
            
                TPMInitialDataLoadWrapperNext.TPMInitialDataKpi kpiWrapper = new TPMInitialDataLoadWrapperNext.TPMInitialDataKpi(kpiAssignedCustomerTempIdMap,kpiAssignedCustomerTempMap);
            return kpiWrapper;
 }

 /*********************************************************************************
    * @method         : returnApiName
    * @return         : Map<String,String>
    * @params         : null
    * @description    : Returns API name of all fields of salesorg object
    **********************************************************************************/
public static Map<String,String> returnApiNameKpi(){
    
    Map<String,String> apiDataTypeMap = New Map<String,String>();

        for(FieldDefinition fieldTypeList : [SELECT DataType,
                                                    QualifiedApiName 
                                                    FROM FieldDefinition 
                                                    WHERE EntityDefinitionId =:TPM_AutomationConstantUtilityClass.KPISET
                                                    WITH SECURITY_ENFORCED]){

            apiDataTypeMap.put(fieldTypeList.QualifiedApiName,fieldTypeList.DataType);

                  }
                  return apiDataTypeMap;
      }
}