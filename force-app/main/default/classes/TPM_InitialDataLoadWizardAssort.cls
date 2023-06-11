/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadWizardAssort
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load in for Meta Wizard and Product assortment template.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public with sharing class TPM_InitialDataLoadWizardAssort {

    /*********************************************************************************
    * @method         : TPM_InitialDataLoadWizardAssort
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadWizardAssort(){


    }
   
    
     /*********************************************************************************
    * @method         : metaWizardLoad
    * @param            orgVal
    * @description    : Fetch data from Custom Metadata and insert MetaDataWizardRecords
    **********************************************************************************/
    public static void metaWizardLoad(Set<String> orgVal){
        //Fetch data from custom metadata type  and insert record for metadatawizard records for sales org values passed from UI
        List<cgcloud__Metadata_Wizard_Configuration__c> metaWizardRecordsList = new List<cgcloud__Metadata_Wizard_Configuration__c>();
        //Get existing metadata wizard records
        //Map of salesorg and record id for existing meta wizard records
        Map<string,string> existingWizardSalesOrgRecordIdMap = TPM_DataLoadAutomationUtil.metaWizardVal(orgval);
        //Get wizrad records from custom metadata
        for(TPM_Initial_Data_Load__mdt metaDataWizard : [SELECT Id,
                                                                TPM_Name__c,
                                                                TPM_Configuration__c,
                                                                TPM_Sales_Org__c,
                                                                TPM_ObjectName__c 
                                                                FROM TPM_Initial_Data_Load__mdt 
                                                                WHERE TPM_ObjectName__c =:TPM_AutomationConstantUtilityClass.METADATA_WIZARD 
                                                                WITH SECURITY_ENFORCED]){

            //First condition to check if org passed by admin has metadata record
            //Second condition to check if meta data wizard records already exists for the sales org
            //If both conditions matches then create record
            if(orgval.contains(metaDataWizard.TPM_Sales_Org__c) && !existingWizardSalesOrgRecordIdMap.containsKey(metaDataWizard.TPM_Sales_Org__c)){
                cgcloud__Metadata_Wizard_Configuration__c wizardRecords = new cgcloud__Metadata_Wizard_Configuration__c();
                wizardRecords.Name = metaDataWizard.TPM_Name__c;
                wizardRecords.cgcloud__Configuration_JSON__c = metaDataWizard.TPM_Configuration__c;
                wizardRecords.cgcloud__Sales_Org__c = metaDataWizard.TPM_Sales_Org__c;
                metaWizardRecordsList.add(wizardRecords);
            }
        }
        if(!metaWizardRecordsList.isempty() && Schema.sObjectType.cgcloud__Metadata_Wizard_Configuration__c.isCreateable()){
        //Insert MetaWizard Records
            TPM_InitialDataLoadHandleError.createAndHandleError(metaWizardRecordsList,TPM_AutomationConstantUtilityClass.METAWIZARDLOAD);
        }
    }  
    
       /*********************************************************************************
    * @method         : productAssortmentLoad
    * @param            orgVal
    * @description    : Create product assortment records for sales org passed by admin
    **********************************************************************************/
    public static void productAssortmentLoad(Set<string> orgVal){
            //Create assortment records directly for sales org passed from UI
            //Get existing product assortment records
            //Set of sales org values for existing metawizard records
            Set<string> existingMetaWizardRecordsSet = TPM_DataLoadAutomationUtilCon.getProdAssortmentRec(orgval);
            List<cgcloud__Product_Assortment_Template__c> productTemplateList = new List<cgcloud__Product_Assortment_Template__c>();
            for(String organizationVal : orgval){
                //If record already exists then skip creation of product assortment records based on sales org
                if(!existingMetaWizardRecordsSet.contains(organizationVal)){
                    cgcloud__Product_Assortment_Template__c prodAssortmentTemp = new cgcloud__Product_Assortment_Template__c();
                    //Get record id of product assortment list record type
                    Id planningassortmentlistrecid = Schema.SObjectType.cgcloud__Product_Assortment_Template__c.getRecordTypeInfosByDeveloperName().get('Planning_Assortment_List').getRecordTypeId();
                    prodAssortmentTemp.Name = TPM_AutomationConstantUtilityClass.ASSORTMENTTEMPLATE+TPM_AutomationConstantUtilityClass.UNDERSCORE+organizationVal;
                    prodAssortmentTemp.RecordTypeId = planningassortmentlistrecid;
                    prodAssortmentTemp.cgcloud__Active__c = true;
                    prodAssortmentTemp.cgcloud__Consider_For_APL_Generation__c =  true;
                    prodAssortmentTemp.cgcloud__Account_Multiplicity__c = TPM_AutomationConstantUtilityClass.ONE;
                    prodAssortmentTemp.cgcloud__Product_Level__c = TPM_AutomationConstantUtilityClass.PRODUCT;
                    prodAssortmentTemp.cgcloud__Sales_Org__c = organizationVal;
                    prodAssortmentTemp.cgcloud__Description_Language_1__c =  TPM_AutomationConstantUtilityClass.ASSORTMENTTEMPLATE+TPM_AutomationConstantUtilityClass.UNDERSCORE+organizationVal;
                    productTemplateList.add(prodAssortmentTemp);
                }
            }
            if(!productTemplateList.isempty() && Schema.sObjectType.cgcloud__Product_Assortment_Template__c.isCreateable()){
               //Insert product assortment records
                TPM_InitialDataLoadHandleError.createAndHandleError(productTemplateList,TPM_AutomationConstantUtilityClass.PRODUCTASSORTMENTLOAD);
            }
    }  
}