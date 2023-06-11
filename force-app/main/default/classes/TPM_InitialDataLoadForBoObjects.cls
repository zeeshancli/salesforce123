/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadForBoObjects
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : January 19, 2023
* @description  : This Apex is used for automating BO data load in salesforce TPM.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadForBoObjects {

    /*********************************************************************************
    * @method         : TPM_InitialDataLoadForBoObjects
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadForBoObjects(){


    }
    
    
    
    /*********************************************************************************
    * @method         : createBoData
    * @param            salesOrg
    * @description    : Insert All Bo Object records for creating promotions
    **********************************************************************************/
    public static void createBoData(Set<String> salesOrg){
        //Methods has to be called in below sequence to successfully insert records
        //Create BO API entity records
        try{   
        TPM_InitialDataLoadBOWorkFlowWorkFlStep.createBoApiEntity();

        //Create BO API records
        TPM_InitialDataLoadBoApi.createBoApi(salesOrg);

        //Create BO APIWorkflow records
        TPM_InitialDataLoadBoApi.createBoApiWorflow(salesOrg);

        //Create BO APIWorkflowStep records
        TPM_InitialDataLoadWorkFlowStep.createBoApiWorflowStep(salesOrg);

        //Create BO APIWorkflowStepInput records
        TPM_InitialDataLoadWorkFlowStep.createBoApiWorflowStepInput(salesOrg);

        //Create BO APIOutputEntity records
        TPM_InitialDataLoadBOOutputAPIWorkflow.createBoApiOutputEntity(salesOrg);

        //Create BO APIOutputWorkflowEntity records
        TPM_InitialDataLoadBOOutputAPIWorkflow.createBoApiOutputWorkflowEntity(salesOrg);

        //Create BO APIOutputWorkflowWorkflowStep records
        TPM_InitialDataLoadBOWorkFlowWorkFlStep.createBoApiWorkflowWfStep(salesOrg);

        }

        catch(Exception exp) {
            //error logging operations
            TPM_Utils.createException(exp,TPM_ConstantsUtility.ERROR,TPM_AutomationConstantUtilityClass.TPMINITIALDATALOAD);
        }

    }
}