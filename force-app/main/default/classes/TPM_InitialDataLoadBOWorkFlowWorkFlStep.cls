/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadBOWorkFlowWorkFlStep
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : January 19, 2023
* @description  : This Apex is used for automating BO data load in salesforce TPM.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadBOWorkFlowWorkFlStep {

      /*********************************************************************************
    * @method         : TPM_InitialDataLoadBOWorkFlowWorkFlStep
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadBOWorkFlowWorkFlStep(){


    }
    

     /*********************************************************************************
    * @method         : createBoApiWorkflowWfStep
    * @param            salesOrg
    * @description    : Insert Workflow and Workflow step junction object records  for creating promotion and contains
    *                   37 records for each sales org
    **********************************************************************************/
    public static void createBoApiWorkflowWfStep(Set<String> salesOrg){

        //List of  Workflow and Workflow step 
        List<cgcloud__BO_API_Workflow_Workflow_Step__c > boApiWfWfStep = new List<cgcloud__BO_API_Workflow_Workflow_Step__c >();
       
        //Map of Map of workflow name and sales org as key and id as value
        Map<Map<String,String>,String> boWorkflowMap =  TPM_BoApiDataLoadAutomation.getBoWorkFlowId(salesOrg);
        
        //Map of workflow step name and id
        Map<Map<String,String>,String> boWorkFlowStepMap = TPM_BoApiDataLoadAutomation.getWorkflowStepId(salesOrg);
        
        //Get the metadata records for workflow and workflow step object
        List<TPM_Initial_BO_Load_Data__mdt> mdtRecordsForWfWfStepList = [SELECT id,
                                                                            BO_API_Workflow_Name__c,
                                                                            cgcloud_BO_API_Workflow_Step__c,
                                                                            Sort__c,
                                                                            Enabled__c,
                                                                            Object_Name__c 
                                                                            FROM TPM_Initial_BO_Load_Data__mdt
                                                                            WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c =:TPM_AutomationConstantUtilityClass.APIWORKFLOWWORKFLOWSTEP
                                                                            WITH SECURITY_ENFORCED];

           //Loop the slaes org
            for(String orgValue : salesOrg ){
                
                //Loop metadata records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : mdtRecordsForWfWfStepList){

                    Map<String,String> wfNameStepSalesOrgMap = new Map<String,String>();
                    //Map of worfklow stename and sales org
                    wfNameStepSalesOrgMap.put(boMdt.cgcloud_BO_API_Workflow_Step__c,orgValue);
                    //Map of workflow name and sales org
                    Map<String,String> wfNameSalesOrgMap = new Map<String,String>();
                    wfNameSalesOrgMap.put(boMdt.BO_API_Workflow_Name__c,orgValue);
                    //Create workflow workflow step
                    cgcloud__BO_API_Workflow_Workflow_Step__c boWfWfStepRec = new cgcloud__BO_API_Workflow_Workflow_Step__c();
                    if(boWorkflowMap.containsKey(wfNameSalesOrgMap)){
                        boWfWfStepRec.cgcloud__BO_API_Workflow__c = boWorkflowMap.get(wfNameSalesOrgMap);
                    }
                    if(boWorkFlowStepMap.containsKey(wfNameStepSalesOrgMap)){
                        boWfWfStepRec.cgcloud__BO_API_Workflow_Step__c = boWorkFlowStepMap.get(wfNameStepSalesOrgMap);
                    }
                    boWfWfStepRec.cgcloud__Enabled__c = boMdt.Enabled__c;
                    boWfWfStepRec.cgcloud__Sort__c = boMdt.Sort__c;
                    boApiWfWfStep.add(boWfWfStepRec);
                }

        }
          
            if(!boApiWfWfStep.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Workflow_Workflow_Step__c.isCreateable()){
                //Insert workflowworkflowsteprecords
                TPM_InitialDataLoadHandleError.createAndHandleError(boApiWfWfStep,TPM_AutomationConstantUtilityClass.CREATEBOAPIWORKFLOWWFSTEP);
            }

    }

     /*********************************************************************************
    * @method         : createBoApiEntity
    * @description    : Insert BO API  Entity records  for creating promotion and contains
    *                   15 records and not sales org specific
    **********************************************************************************/
    public static void createBoApiEntity(){

                //List of BO API Entity
                Map<String,String> getBoApiRecord = TPM_BoApiDataLoadAutomation.getBoApiEntity();
                List<cgcloud__BO_API_Entity__c > boApiEntityList = new List<cgcloud__BO_API_Entity__c >();
        
                if(getBoApiRecord.size()!=15){
                //Loop metadata records and insert records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : [SELECT id,
                                                                 Business_Object_API_Entity_Name__c,
                                                                 CGCLOUD_DESCRIPTION_C__c,
                                                                 cgcloud_Path_c__c,
                                                                 Location__c,
                                                                 Object_Name__c 
                                                                 FROM TPM_Initial_BO_Load_Data__mdt
                                                                 WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c =:TPM_AutomationConstantUtilityClass.BOAPIENTITY
                                                                 WITH SECURITY_ENFORCED]){
                    //Create BO Entity records
                    cgcloud__BO_API_Entity__c businessApiRec = new cgcloud__BO_API_Entity__c();
                    businessApiRec.Name = boMdt.Business_Object_API_Entity_Name__c;
                    businessApiRec.cgcloud__Description__c = boMdt.CGCLOUD_DESCRIPTION_C__c;
                    businessApiRec.cgcloud__Location__c = boMdt.Location__c;
                    businessApiRec.cgcloud__Path__c = boMdt.cgcloud_Path_c__c;
                    boApiEntityList.add(businessApiRec);
                }

            }

        if(!boApiEntityList.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Entity__c.isCreateable()){
            //Insert BO API Entity records
            TPM_InitialDataLoadHandleError.createAndHandleError(boApiEntityList,TPM_AutomationConstantUtilityClass.CREATEBOAPIENTITY);
        }

    }
    
}