/*********************************************************************************************
* @Name         : TPM_BoApiDataLoadAutomation
* @author       : PwC Team
* @date         : January 20,2023
* @description  : Utility class for TPM_InitialDataLoadBoApi
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/
public inherited sharing class TPM_BoApiDataLoadAutomation {

   /*********************************************************************************
    * @method         : TPM_BoApiDataLoadAutomation
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_BoApiDataLoadAutomation(){


    }
        

    
  /*********************************************************************************
    * @method         : getBoApiRecords
    * @return         : Map<String,String>
    * @param            salesOrgVal
    * @description    : Returns Map of BO API Sales Org and Id
    **********************************************************************************/
    public static Map<String,String> getBoApiRecords(Set<String> salesOrgVal){
        //Map of BO API Sales Org and Id
        Map<String,String> boApiRec = new Map<String,String>();

        for(cgcloud__BO_API__c boApi : [SELECT id,
                                               CGCLOUD__SALES_ORG__C 
                                               FROM cgcloud__BO_API__c 
                                               WHERE CGCLOUD__SALES_ORG__C 
                                               IN:salesOrgVal]){
             
            //Map of BO API Sales Org and Id
             boApiRec.put(boApi.CGCLOUD__SALES_ORG__C,boApi.id);
         }
         return boApiRec;
      }

    /*********************************************************************************
    * @method         : getBoApiEntity
    * @return         : Map<String,String>
    * @params         : null
    * @description    : Returns Map of BO API Entity name and Id
    **********************************************************************************/
    public static Map<String,String> getBoApiEntity(){
            
      //Map of BO API Entity name and Id
            Map<String,String> boEntityMap = New Map<String,String>();
    
            for(cgcloud__BO_API_Entity__c boEntity : [SELECT Id,
                                                             Name
                                                             FROM cgcloud__BO_API_Entity__c
                                                             WHERE Name!=NULL
                                                             WITH SECURITY_ENFORCED]){
                //Map of BO API Entity name and Id
                boEntityMap.put(boEntity.Name,boEntity.Id);
            } 
            return boEntityMap;
          }
         
    /*********************************************************************************
    * @method         : getWorkflowStepId
    * @return         : Map<<String,String>,String>
    * @param            salesOrgVal
    * @description    : Returns Map of Map of workflow step name and sales org as key and id as value
    **********************************************************************************/
      public static Map<Map<String,String>,String> getWorkflowStepId(Set<String> salesOrgVal){ 
        
        //Map of Map of workflow step name and sales org as key and id as value
        Map<Map<String,String>,String> workflowStepMap = new Map<Map<String,String>,String>();
    
            for(cgcloud__BO_API_Workflow_Step__c wfStep : [SELECT Id,
                                                                  Name,
                                                                  cgcloud__Sales_Org__c
                                                                  FROM cgcloud__BO_API_Workflow_Step__c
                                                                  WHERE cgcloud__Sales_Org__c IN:salesOrgVal
                                                                  WITH SECURITY_ENFORCED]){
                //Map of workflow step name and id
                Map<String,String> workflowStepNameSalesOrgMap = new Map<String,String>();
                workflowStepNameSalesOrgMap.put(wfStep.Name,wfStep.cgcloud__Sales_Org__c);
                workflowStepMap.put(workflowStepNameSalesOrgMap,wfStep.Id);
            }
            return workflowStepMap;

          }
      
    /*********************************************************************************
    * @method         : getWorkflowRecordId
    * @return         : Map<String,String>
    * @description    : Returns Map of workflow step recordtype name and recordtypeid
    **********************************************************************************/
      public static Map<String,String> getWorkflowRecordId(){ 
            
            // Map of workflow step recordtype name and recordtypeid
            Map<String,String> workflowStepRecordIdMap = New Map<String,String>();
    
            for(RecordType wfStepRecordId : [SELECT Id,
                                                      Name
                                                      FROM RecordType 
                                                      WHERE sObjectType =:TPM_AutomationConstantUtilityClass.APISTEPINPUT
                                                      WITH SECURITY_ENFORCED]){
                //Map of workflow step recordtype name and recordtypeid
                workflowStepRecordIdMap.put(wfStepRecordId.Name,wfStepRecordId.Id);
            }
            return workflowStepRecordIdMap;
          }
    
    /*********************************************************************************
    * @method         : getWorkflowRecordId
    * @return         : Map<Map<String,String>,String>
    * @param            salesOrgVal
    * @description    : Returns Map of Map of workflow step name and sales org as key and id as value
    **********************************************************************************/
          public static Map<Map<String,String>,String> getWorkflowStepName(Set<String> salesOrgVal){
            
            //Map of workflow step recordtype name and recordtypeid
            Map<Map<String,String>,String> workflowStepName = new Map<Map<String,String>,String>();

            for(cgcloud__BO_API_Step_Input_Structure__c wfInputRec : [SELECT id,
                                                                             cgcloud__BO_API_Workflow_Step__r.Name,
                                                                             cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c
                                                                             FROM cgcloud__BO_API_Step_Input_Structure__c
                                                                             WHERE cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c IN:salesOrgVal
                                                                             WITH SECURITY_ENFORCED]){
                 //Set of workflow step name
                  Map<String,String> nameSalesOrgTemp = new Map<String,String>();
                  nameSalesOrgTemp.put(wfInputRec.cgcloud__BO_API_Workflow_Step__r.Name,wfInputRec.cgcloud__BO_API_Workflow_Step__r.cgcloud__Sales_Org__c);
                  workflowStepName.put(nameSalesOrgTemp,wfInputRec.Id);

               }

               return workflowStepName;
          }
      
    /*********************************************************************************
    * @method         : getBoApiRecordId
    * @return         : Map<String,String>
    * @param            salesOrgVal
    * @description    : Returns Map of BO API name and Id
    **********************************************************************************/
          public static Map<String,String> getBoApiRecordId(Set<String> salesOrgVal){
            
            //Map of BO API name and Id
            Map<String,String> boApiRec = new Map<String,String>();
    
            for(cgcloud__BO_API__c boApi : [SELECT id,
                                                   Name,
                                                   cgcloud__sales_org__c
                                                   FROM cgcloud__BO_API__c 
                                                   WHERE cgcloud__sales_org__c 
                                                   IN:salesOrgVal
                                                   WITH SECURITY_ENFORCED]){
                //Map of BO API name and Id
                 boApiRec.put(boApi.cgcloud__sales_org__c,boApi.id);
             }
             return boApiRec;
          }
    
    /*********************************************************************************
    * @method         : getBoWorkFlowId
    * @return         : Map<map<String,String>,String>
    * @param            salesOrgVal
    * @description    : Returns Map of Map of workflow name and sales org as key and id as value
    **********************************************************************************/
          public static Map<map<String,String>,String> getBoWorkFlowId(Set<String> salesOrgVal){
            
            //Map of Map of workflow name and sales org as key and id as value
            Map<map<String,String>,String> boWorkflowRec = new Map<map<String,String>,String>();
    
            for(cgcloud__BO_API_Workflow__c boWflow : [SELECT id,
                                                              Name,
                                                              cgcloud__BO_API__r.cgcloud__Sales_Org__c
                                                              FROM cgcloud__BO_API_Workflow__c 
                                                              WHERE cgcloud__BO_API__r.cgcloud__Sales_Org__c IN:salesOrgVal
                                                              WITH SECURITY_ENFORCED]){
              //Map of BOWorkflow name and Id
              Map<String,String> wflowNameOrgAsKeyIdAsValueMap = new Map<String,String>();
              wflowNameOrgAsKeyIdAsValueMap.put(boWflow.Name,boWflow.cgcloud__BO_API__r.cgcloud__Sales_Org__c);
              boWorkflowRec.put(wflowNameOrgAsKeyIdAsValueMap,boWflow.id);
             }
             return boWorkflowRec;
          }
       
        
        }