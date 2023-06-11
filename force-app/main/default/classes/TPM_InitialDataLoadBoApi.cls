/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadBoApi
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : January 19, 2023
* @description  : This Apex is used for automating data load in for BO API Object
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadBoApi {   

     /*********************************************************************************
    * @method         : TPM_InitialDataLoadBoApi
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadBoApi(){


    }
    
    /*********************************************************************************
    * @method         : createBoApi
    * @param            salesOrg
    * @description    : Insert BO API records for creating promotion and will be 1 
    *                   for each sales org
    **********************************************************************************/
    public static void createBoApi(Set<String> salesOrg){
       //List of BO API
        List<cgcloud__BO_API__c> boApiList = new List<cgcloud__BO_API__c>();
        
        //Loop all the sales org passed by used and create BO API Records
        for(String orgName: salesOrg ){
            
            //Create BO API Records
            cgcloud__BO_API__c boApiRec = new cgcloud__BO_API__c();
            //Concatenate promotion- and salesorg
            boApiRec.Name = TPM_AutomationConstantUtilityClass.PROMOTION;
            boApiRec.CGCLOUD__SALES_ORG__C = orgName;
            boApiList.add(boApiRec);
        }
        
        //if list is not empty insert records
        if(!boApiList.isEmpty() && Schema.sObjectType.cgcloud__BO_API__c.isCreateable()){
            //Insert BO API records
            TPM_InitialDataLoadHandleError.createAndHandleError(boApiList,TPM_AutomationConstantUtilityClass.GETBOAPI);
        }

    }


    /*********************************************************************************
    * @method         : createBoApiWorflow
    * @param            salesOrg
    * @description    : Insert BO API Workflow records for creating Promotion and 
    *                   will be 3 records for each sales org
    **********************************************************************************/
        public static void createBoApiWorflow(Set<String> salesOrg){

        //List of BO API Workflow
        List<cgcloud__BO_API_Workflow__c> boApiWorkflowList = new List<cgcloud__BO_API_Workflow__c>();
        
        //Map of boapisalesorg as key and id as value
        Map<String,String> boApiRecIdMap = TPM_BoApiDataLoadAutomation.getBoApiRecords(salesOrg);
        
        //Get metadata records for Worklfow
        List<TPM_Initial_BO_Load_Data__mdt> mdtRecordsForWorkflowList = [SELECT id,
                                                                            BO_API_Workflow_Name__c,
                                                                            CGCLOUD_DESCRIPTION_C__c,
                                                                            Object_Name__c 
                                                                            FROM TPM_Initial_BO_Load_Data__mdt
                                                                            WHERE TPM_Initial_BO_Load_Data__mdt.Object_Name__c =:TPM_AutomationConstantUtilityClass.APIWORKFLOW
                                                                            WITH SECURITY_ENFORCED];

            //Loop Sales Org
            for(String orgName : salesOrg ){
               
                //Loop and create records
                for(TPM_Initial_BO_Load_Data__mdt boMdt : mdtRecordsForWorkflowList){
                    
                    //Create Workflow records
                    cgcloud__BO_API_Workflow__c boApiWorkflowRec = new cgcloud__BO_API_Workflow__c();
                    boApiWorkflowRec.Name = boMdt.BO_API_Workflow_Name__c;
                    //Map Bo api record to workflow
                    boApiWorkflowRec.cgcloud__BO_API__c = boApiRecIdMap.get(orgName);
                    boApiWorkflowRec.CGCLOUD__DESCRIPTION__C = boMdt.CGCLOUD_DESCRIPTION_C__c;
                    boApiWorkflowList.add(boApiWorkflowRec);
                }

              }

                if(!boApiWorkflowList.isEmpty() && Schema.sObjectType.cgcloud__BO_API_Workflow__c.isCreateable()){
                    //Insert workflow records
                    TPM_InitialDataLoadHandleError.createAndHandleError(boApiWorkflowList,TPM_AutomationConstantUtilityClass.CREATEBOAPIWORKFLOW);
                }
            }
    }