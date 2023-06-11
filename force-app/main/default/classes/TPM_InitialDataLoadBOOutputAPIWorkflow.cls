/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadBOOutputAPIWorkflow
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : January 19, 2023
* @description  : This Apex is used for automating BO data load in salesforce TPM.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadBOOutputAPIWorkflow {

    
     /*********************************************************************************
    * @method         : TPM_InitialDataLoadBOOutputAPIWorkflow
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadBOOutputAPIWorkflow(){


    }
    
    
    /*********************************************************************************
    * @method         : createBoApiOutputEntity
    * @param            salesOrg
    * @description    : Insert BO API Output Entity records for creating promotion and contains
    *                   4 records for each sales org
    **********************************************************************************/
    public static void createBoApiOutputEntity(Set<String> salesOrg){

        //List of BO API Output Entity
        List<cgcloud__BO_API_Output_Entity__c> boApiOutputList = new List<cgcloud__BO_API_Output_Entity__c>();
        
        //Map of BO Entity name and id
        Map<String,String> boApiEntityMap =  TPM_BoApiDataLoadAutomation.getBoApiEntity();
        
        //Map of BO Api name and Id
        Map<String,String> boApiRecId = TPM_BoApiDataLoadAutomation.getBoApiRecordId(salesOrg);
        
        //Get the metadata records for BOAPIOUTPUT Entity
        List<TPM_Initial_BO_Load_Data__mdt> mdtRecordsForBoOutput = [SELECT id,
                                                                                cgcloud_BO_API_Name__c,
                                                                                BO_API_Entity_Name__c,
                                                                                Object_Name__c 
                                                                                FROM TPM_Initial_BO_Load_Data__mdt
                                                                                WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c =:TPM_AutomationConstantUtilityClass.APIOUTPUTENTITY
                                                                                WITH SECURITY_ENFORCED];

           //Loop the sales org
            for(String orgValue : salesOrg ){
                
                //Loop metadata records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : mdtRecordsForBoOutput){
                    //Create BO Output Entity records
                    cgcloud__BO_API_Output_Entity__c boApiOutputRec = new cgcloud__BO_API_Output_Entity__c();
                    //Map BOApi with BPAPIOUTPUT Entity 
                    if(boApiRecId.containsKey(orgValue)){
                        boApiOutputRec.cgcloud__BO_API__c = boApiRecId.get(orgValue);
                    }
                    //Map BOApi with BPAPIEntity Name 
                    if(boApiEntityMap.containsKey(boMdt.BO_API_Entity_Name__c)){
                        boApiOutputRec.cgcloud__BO_API_Entity__c = boApiEntityMap.get(boMdt.BO_API_Entity_Name__c);
                    }
                    boApiOutputList.add(boApiOutputRec);
                }

        }

        if(!boApiOutputList.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Output_Entity__c.isCreateable()){
            //Insert BOAPIOUTPUT Entity records
            TPM_InitialDataLoadHandleError.createAndHandleError(boApiOutputList,TPM_AutomationConstantUtilityClass.CREATEBOAPIOUTPUTENTITY);
        }

    }

     /*********************************************************************************
    * @method         : createBoApiOutputWorkflowEntity
    * @param            salesOrg
    * @description    : Insert BO API Output Workflow Entity records  for creating promotion and contains
    *                   9 records for each sales org
    **********************************************************************************/
    public static void createBoApiOutputWorkflowEntity(Set<String> salesOrg){

        //List of BO API Workflow Entity
        List<cgcloud__BO_API_Workflow_Entity__c > boApiOutputWorkflowList = new List<cgcloud__BO_API_Workflow_Entity__c >();
        
         //Map of BO Entity name and id
        Map<String,String> boApiEntityMap =  TPM_BoApiDataLoadAutomation.getBoApiEntity();

        //Map of Workflow name and Id
        Map<Map<String,String>,String> boApiWfMap = TPM_BoApiDataLoadAutomation.getBoWorkFlowId(salesOrg);
        
        //Get metadata records for workflow entity
        List<TPM_Initial_BO_Load_Data__mdt> mdtRecordsForBoOutput = [SELECT id,
                                                                            BO_API_Entity_Name__c,
                                                                            BO_API_Workflow_Name__c,
                                                                            Input_Mapping_Field__c,
                                                                            Output_Mapping_Field__c,
                                                                            BO_Output_Entity_Name__c,
                                                                            Object_Name__c 
                                                                            FROM TPM_Initial_BO_Load_Data__mdt
                                                                            WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c =:TPM_AutomationConstantUtilityClass.APIWORKFLOWENTITY
                                                                            WITH SECURITY_ENFORCED];

            //Loop sales org
            for(String orgName : salesOrg ){
                
                //Loop metadata records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : mdtRecordsForBoOutput){

                    Map<String,String> wfNameSalesOrgMap = new Map<String,String>();
                    wfNameSalesOrgMap.put(boMdt.BO_API_Workflow_Name__c,orgName);
                    cgcloud__BO_API_Workflow_Entity__c boApiOutputWorkflowRec = new cgcloud__BO_API_Workflow_Entity__c();
                    //Pass BO API Entity value
                    if(boApiEntityMap.containsKey(boMdt.BO_API_Entity_Name__c)){
                        boApiOutputWorkflowRec.cgcloud__BO_API_Entity__c = boApiEntityMap.get(boMdt.BO_API_Entity_Name__c);
                    }
                    //Pass BO API Workflow value
                    if(boApiWfMap.containsKey(wfNameSalesOrgMap)){
                        boApiOutputWorkflowRec.cgcloud__BO_API_Workflow__c = boApiWfMap.get(wfNameSalesOrgMap);
                    }
                    boApiOutputWorkflowRec.cgcloud__Input_Mapping_Field__c = boMdt.Input_Mapping_Field__c;
                    //Pass output entity value
                    if(boApiEntityMap.containsKey(boMdt.BO_Output_Entity_Name__c)){
                         boApiOutputWorkflowRec.cgcloud__Output_Entity__c = boApiEntityMap.get(boMdt.BO_Output_Entity_Name__c);
                    }
                    boApiOutputWorkflowRec.cgcloud__Output_Mapping_Field__c = boMdt.Output_Mapping_Field__c;
                    boApiOutputWorkflowList.add(boApiOutputWorkflowRec);
                   
                }

        }

        if(!boApiOutputWorkflowList.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Workflow_Entity__c.isCreateable()){
            //Insert BO API Workflow entity records
            TPM_InitialDataLoadHandleError.createAndHandleError(boApiOutputWorkflowList,TPM_AutomationConstantUtilityClass.CREATEBOAPIOUTPUTWORKFLOWENTITY);
        }

    }
}