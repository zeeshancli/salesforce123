/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadWorkFlowStep
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : January 19, 2023
* @description  : This Apex is used for automating BO data load in salesforce TPM.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadWorkFlowStep {

      /*********************************************************************************
    * @method         : TPM_InitialDataLoadWorkFlowStep
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadWorkFlowStep(){


    }

    
    /*********************************************************************************
    * @method         : createBoApiWorflowStep
    * @param            salesOrg
    * @description    : Insert BO API Workflow Step records for creating promotion and contains
    *                   29 records for each sales org
    **********************************************************************************/
    public static void createBoApiWorflowStep(Set<String> salesOrg){

        //List of BO API Workflow Step
        List<cgcloud__BO_API_Workflow_Step__c> boApiWorkflowStepList = new List<cgcloud__BO_API_Workflow_Step__c>();
        
        //Map of BO API Entity name and Id
        Map<String,String> boApiEntityMap =  TPM_BoApiDataLoadAutomation.getBoApiEntity();
        
        //Get records from metadata for workflow step object
        List<TPM_Initial_BO_Load_Data__mdt> mdtRecordsForWorkflowStep = [SELECT id,
                                                                                CGCLOUD_CLASSNAME_C__c,
                                                                                CGCLOUD_DESCRIPTION_C__c,
                                                                                CGCLOUD_ENTITY_C__c,
                                                                                CGCLOUD_METHOD_C__c,
                                                                                Name__c,
                                                                                Object_Name__c 
                                                                                FROM TPM_Initial_BO_Load_Data__mdt
                                                                                WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c = :TPM_AutomationConstantUtilityClass.APIWORKFLOWSTEP
                                                                                WITH SECURITY_ENFORCED];

            //Loop the sales org and create all records of metadata for each sales org
            for(String orgValue : salesOrg ){
                
                //Loop metadata records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : mdtRecordsForWorkflowStep){
                    
                    //Create workflow step records
                    cgcloud__BO_API_Workflow_Step__c boApiWorkflowStepRec = new cgcloud__BO_API_Workflow_Step__c();
                    //BO API entity id
                    if(boApiEntityMap.containsKey(boMdt.CGCLOUD_ENTITY_C__c)){
                        boApiWorkflowStepRec.cgcloud__Entity__c = boApiEntityMap.get(boMdt.CGCLOUD_ENTITY_C__c);
                    }
                    boApiWorkflowStepRec.Name = boMdt.Name__c;
                    boApiWorkflowStepRec.CGCLOUD__CLASSNAME__C = boMdt.CGCLOUD_CLASSNAME_C__c;
                    boApiWorkflowStepRec.CGCLOUD__DESCRIPTION__C = boMdt.CGCLOUD_DESCRIPTION_C__c;
                    boApiWorkflowStepRec.CGCLOUD__METHOD__C = boMdt.CGCLOUD_METHOD_C__c;
                    boApiWorkflowStepRec.cgcloud__Sales_Org__c = orgValue;
                    boApiWorkflowStepList.add(boApiWorkflowStepRec);
                }

            }

            if(!boApiWorkflowStepList.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Workflow_Step__c.isCreateable()){
                //Insert workflow step records
                TPM_InitialDataLoadHandleError.createAndHandleError(boApiWorkflowStepList,TPM_AutomationConstantUtilityClass.CREATEBOAPIWORKFLOWSTEP);
            }

    }

    /*********************************************************************************
    * @method         : createBoApiWorflowStepInput
    * @param            salesOrg
    * @description    : Insert BO API Step Input Structure for creating promotion and contains
    *                   61 records for each sales org
    **********************************************************************************/
    public static void createBoApiWorflowStepInput(Set<String> salesOrg){

        //List of BO API Workflow
        List<cgcloud__BO_API_Step_Input_Structure__c> boStepInput = new List<cgcloud__BO_API_Step_Input_Structure__c>();
        
        //Returns Map of Map of workflow step name and sales org as key to check and prevent record creation of record already exists
        Map<Map<String,String>,String> workflowStepName = TPM_BoApiDataLoadAutomation.getWorkflowStepName(salesOrg);

        //Returns Map of Map of workflow step name and sales org as key and id as value
        Map<Map<String,String>,String> workflowStepIdMap =  TPM_BoApiDataLoadAutomation.getWorkflowStepId(salesOrg);

        //Map of workflow step input record type name and id
        Map<String,String> workflowStepRecordIdMap = TPM_BoApiDataLoadAutomation.getWorkflowRecordId();
         
        //Get metadata records for step input objects
        List<TPM_Initial_BO_Load_Data__mdt> mdtRecordsForStepInput = [SELECT id,
                                                                       cgcloud_BO_API_Workflow_Step__c,
                                                                       cgcloud_Maps_To_c__c,
                                                                       cgcloud_Path_c__c,
                                                                       CGCLOUD_DESCRIPTION_C__c,
                                                                       cgcloud_Maximum_Length_c__c,
                                                                       Object_Name__c,
                                                                       cgcloud_Pattern__c,
                                                                       Required__c,
                                                                       RecordType__c
                                                                       FROM TPM_Initial_BO_Load_Data__mdt
                                                                       WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c = :TPM_AutomationConstantUtilityClass.APISTEPINPUT
                                                                       WITH SECURITY_ENFORCED];

            //Loop sales org
            for(String orgName : salesOrg ){
                
                //Loop metadata records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : mdtRecordsForStepInput){

                    Map<String,String> nameSalesOrgMap = new Map<String,String>();
                    //Create map of workflow step and sales org value
                    nameSalesOrgMap.put(boMdt.cgcloud_BO_API_Workflow_Step__c,orgName);
                     
                    //First condition to check if workflow step already exists by comparing step name and org
                    if(!workflowStepName.containsKey(nameSalesOrgMap)){
                        //Create step input structure
                        cgcloud__BO_API_Step_Input_Structure__c boStepInputStructure = new cgcloud__BO_API_Step_Input_Structure__c();
                        //map workflow with workflow step
                        if(workflowStepIdMap.containsKey(nameSalesOrgMap)){
                        boStepInputStructure.cgcloud__BO_API_Workflow_Step__c = workflowStepIdMap.get(nameSalesOrgMap);
                        }
                        boStepInputStructure.cgcloud__Path__c = boMdt.cgcloud_Path_c__c;
                        boStepInputStructure.cgcloud__Maximum_Length__c = boMdt.cgcloud_Maximum_Length_c__c;
                        boStepInputStructure.cgcloud__Description__c = boMdt.CGCLOUD_DESCRIPTION_C__c;
                        boStepInputStructure.cgcloud__Maps_To__c = boMdt.cgcloud_Maps_To_c__c;
                        boStepInputStructure.cgcloud__Required__c = boMdt.Required__c;
                        boStepInputStructure.cgcloud__Pattern__c = boMdt.cgcloud_Pattern__c;
                        //Get recordtypeid and assign according to value from metadata
                        if(workflowStepRecordIdMap.containsKey(boMdt.RecordType__c)){
                        boStepInputStructure.RecordTypeId = workflowStepRecordIdMap.get(boMdt.RecordType__c);
                        }
                        boStepInput.add(boStepInputStructure);
                    }
            }

        }

        if(!boStepInput.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Step_Input_Structure__c.isCreateable()){
            //Insert step input structure records
            TPM_InitialDataLoadHandleError.createAndHandleError(boStepInput,TPM_AutomationConstantUtilityClass.CREATEBOAPIWORKFLOWSTEPINPUT);
        }

    }
}