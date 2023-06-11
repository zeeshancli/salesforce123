/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadCustomerProductTemp
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load  for customer and product template.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

    public with sharing class TPM_InitialDataLoadCustomerProductTemp {

        static Map<Map<String,String>,String> existingKpiSetRecordMap;
        static Map<String,TPM_Initial_Data_Load__mdt> metaDataRecordsForCustomer;
        static  Map<Map<String,String>,String> productLevelMap;
        static  Map<Map<String,String>,String> initialRoleMap;
        static Id customerRecordTypeId = Schema.SObjectType.cgcloud__Account_Template__c.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    /*********************************************************************************
    * @method         : TPM_InitialDataLoadCustomerProductTemp
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadCustomerProductTemp(){


    }
        
    /*********************************************************************************
    * @method         : customerTemplateLoad
    * @param            orgVal
    * @description    : Fetch data from Custom Metadata and insert customer template records
    **********************************************************************************/
        public static void customerTemplateLoad(Set<String> orgVal){
            // Create customer template records by fetching data from Metadata

            //Get map of map of kpi set and org and value as Record id of existing customer template
            existingKpiSetRecordMap = TPM_DataLoadAutomationUtilCon.getExistingKpiSetForCustomer();

            TPMInitialDataLoadWrapper.TPMInitialDataLoadWrapper1 wrapperRec = TPM_DataLoadAutomationUtilNext.customerTempMetadata(orgVal);

            //Get existing customer reccords
            //Map of sales org and set of planning mode
            Map<String,Set<String>> existingCustTempRec = TPM_DataLoadAutomationUtilCon.getFinalOrgVal(orgVal);
            //Get metadata records
            //Map of sales org and metadata record
            metaDataRecordsForCustomer = wrapperRec.metaDataRecordMap;
            
            //Map of sales org and planning mode of metadata record
            Map<String,String> salesOrgPlanModeMapOfMetaData = wrapperRec.salesOrgPlanningModeMap;

            productLevelMap = wrapperRec.salesOrgPlanningModeProductLevelMap;

            initialRoleMap = wrapperRec.salesOrgInitialRoleMap;

            //Get Recordif of Customer Record Type
            //String customerRecordTypeId = Schema.SObjectType.cgcloud__Account_Template__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
            List<cgcloud__Account_Template__c> customerTemplateList = new List<cgcloud__Account_Template__c>();

            //Loop the org values passed from UI
            for(String orgValues : orgVal){
                
                List<String> custTempPlanningMode = new List<String>();

                //Check if metadata contains the record for sales org passed by admin
                //Second condition to check if planning mode exists in metadata

                if(salesOrgPlanModeMapOfMetaData.containsKey(orgValues) && String.isNotBlank(salesOrgPlanModeMapOfMetaData.get(orgValues))) {

                  //Split the planning mode values sepereated by semicolon stored in metadata
                    custTempPlanningMode = salesOrgPlanModeMapOfMetaData.get(orgValues).split(';');
                
                //Loop custom planning mode obtained from metadata for each org and insert only if record doesnt exist for combination of planning mode and sales org
                  for(String custMode : custTempPlanningMode){

                    //First Condition to check whether record already exists for sales org
                    //Second Condition to check if record already exists for sales org and planning mode
                  if(metaDataRecordsForCustomer.containsKey(orgValues) && (!existingCustTempRec.containsKey(orgValues) || (existingCustTempRec.containsKey(orgValues) && !existingCustTempRec.get(orgValues).contains(custMode)))){
                    //Map to store planning mode and org in order to get KPI set associated with it
                    cgcloud__Account_Template__c custRec = TPM_InitialDataLoadCustomerProductTemp.createCustomerRec(custMode,orgValues);
                    customerTemplateList.add(custRec);
                      }
                }
             }        
            }
            TPM_InitialDataLoadCustomerProductTemp.insertCustomerRec(customerTemplateList);
          
    }
 
   /*********************************************************************************
    * @method         : productTemplateLoad
    * @param            orgVal
    * @description    : Create Product template records for all the sales org passed by admin
    **********************************************************************************/
      public static void productTemplateLoad(Set<String> orgVal){

              //Create product template records directly by using salesorg from UI
              //Get existing product template records
              //Map of sales org and record type name
                Map<String,String> existingProductTemplateRecordMap = TPM_DataLoadAutomationUtilCon.getProdTempVal(orgVal);

                //Get recordtype id for product and product group record types
                Id productGroupRecordTypeId = Schema.SObjectType.cgcloud__Product_Template__c.getRecordTypeInfosByDeveloperName().get('Product_Group').getRecordTypeId();
                Id productRecordTypeId = Schema.SObjectType.cgcloud__Product_Template__c.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
                List<cgcloud__Product_Template__c> productTemplateList = new List<cgcloud__Product_Template__c>();
                for(String organVal : orgVal){

                //Check If record already exists for the product template based on sales org
                if(!existingProductTemplateRecordMap.containsKey(organVal)){
                    cgcloud__Product_Template__c prodGroup = new cgcloud__Product_Template__c();
                    prodGroup.Name = TPM_AutomationConstantUtilityClass.PRODUCTGROUPTEMP+organVal;
                    prodGroup.RecordTypeId= productGroupRecordTypeId;
                    prodGroup.cgcloud__Sales_Org__c = organVal;
                    prodGroup.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.PRODUCTGROUPTEMP+organVal;
                    prodGroup.cgcloud__Active__c = true;
                    productTemplateList.add(prodGroup);
                    cgcloud__Product_Template__c product = new cgcloud__Product_Template__c();
                    product.Name = TPM_AutomationConstantUtilityClass.PRODUCTTEMP+organVal;
                    product.RecordTypeId = productRecordTypeId;
                    product.cgcloud__Sales_Org__c = organVal;
                    product.cgcloud__Description_Language_1__c = TPM_AutomationConstantUtilityClass.PRODUCTTEMP+organVal;
                    product.cgcloud__Active__c = true;
                    productTemplateList.add(product);
          }
      }
            if(!productTemplateList.isempty() && Schema.sObjectType.cgcloud__Product_Template__c.isCreateable()){

              //insert product template records
              TPM_InitialDataLoadHandleError.createAndHandleError(productTemplateList,TPM_AutomationConstantUtilityClass.PRODUCTTEMPLATELOAD);
            }
      }

    /*********************************************************************************
    * @method         : insertCustomerRec
    * @param            customerTemplateList
    * @description    : Create Customer template records for all the sales org passed by admin
    **********************************************************************************/
      public static void insertCustomerRec(List<cgcloud__Account_Template__c> customerTemplateList){

      if(!customerTemplateList.isempty() && Schema.sObjectType.cgcloud__Account_Template__c.isCreateable()){
        //Insert Customer Template records
          TPM_InitialDataLoadHandleError.createAndHandleError(customerTemplateList,TPM_AutomationConstantUtilityClass.CUSTOMERTEMPLATELOAD);
        }
      }
 
  /*********************************************************************************
    * @method         : createCustomerRec
    * @return         : cgcloud__Account_Template__c
    * @param            custMode
    * @param            orgValues
    * @description    : Create customer Metadata Records
    **********************************************************************************/
    public static cgcloud__Account_Template__c createCustomerRec(String custMode,String orgValues ){

                    Map<String,String> planTypeOrgMap = new Map<String,String>();
                    planTypeOrgMap.put(custMode,orgValues);
                    //Create a map of sales org and planning mode
                    Map<String,String> planTypeOrgMapNew = new Map<String,String>();
                    planTypeOrgMapNew.put(orgValues,custMode);
                    cgcloud__Account_Template__c cust = new cgcloud__Account_Template__c ();
                    //Pass customer name
                    cust.Name = custMode+TPM_AutomationConstantUtilityClass.UNDERSCORE+orgValues;
                    //Pass sales Org
                    cust.cgcloud__Sales_Org__c = orgValues;
                    //Pass customer record id
                    cust.RecordTypeId= customerRecordTypeId;
                    //Pass Description
                    cust.cgcloud__Description_Language_1__c = custMode+TPM_AutomationConstantUtilityClass.UNDERSCORE+orgValues;
                    cust.cgcloud__Active__c = true;
                    //Pass initial Roles
                    if(String.isNotBlank(initialRoleMap.get(planTypeOrgMapNew))){
                        cust.cgcloud__Initial_Roles__c = initialRoleMap.get(planTypeOrgMapNew);
                    }
                    //Pass product level values
                    if(String.isNotBlank(productLevelMap.get(planTypeOrgMapNew))){
                        cust.cgcloud__Available_Product_Level__c = productLevelMap.get(planTypeOrgMapNew);
                    }
                    //Pass Kpi set
                      if(String.isNotBlank(existingKpiSetRecordMap.get(planTypeOrgMap))){
                        cust.cgcloud__KPI_Set_Plan_Dependent__c = existingKpiSetRecordMap.get(planTypeOrgMap);
                      }
                    cust.TPM_CustTemp_PlanMode__c= custMode;
                    return cust;
        }
}