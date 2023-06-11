/*******************************************************************************************************
* @Name         : TPM_SalesOrgUserTriggerHelperExtension
* @Unit Test    : TPM_SalesOrgUserTriggerHelperTest
* @Author       : PwC Team
* @Date         : 02/07/2023
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the sales org user records.(to resolve complexity )
*******************************************************************************************************/
public inherited sharing class TPM_SalesOrgUserTriggerHelperExtension {
    
    /***************************************************************************************************
	@methodname 	TPM_SalesOrgUserTriggerHelperExtension
	@createdDate 	14/04/2023
	@description	default private constructor
	****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_SalesOrgUserTriggerHelperExtension(){
        
    }
    
        /*********************************************************************************************************
    @methodname   	handleUpsertDML
    @createdDate  	02/07/2022
    @param     	  	productMrgUpsertList
    @description  	after the insert of a sales org user record, product manager record is created/updated
					for the user.
    **********************************************************************************************************/ 
    public static void handleUpsertDML(List<cgcloud__Product_Category_Share__c> productMrgUpsertList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();

        //Check if the list is not empty
        if(!productMrgUpsertList.isEmpty()){
            //Upsert the list of records
            Database.UpsertResult[] upsertResultList = database.upsert(productMrgUpsertList,false);
            
            for ( Database.UpsertResult upsertResultObj : upsertResultList) {
                if(!upsertResultObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = upsertResultObj.getErrors();
                    logWrapperObj.className = TPM_ConstantsUtility.SALES_ORG_USER_TRIGGER_HELPER_EXTENSION;
                    logWrapperObj.methodName = TPM_ConstantsUtility.HANDLE_UPSERT_DML;
                    logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
            }
            
            //Call the TPM_LoggerException class log method to save all the exception details during insert
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
    /*********************************************************************************************************
@methodname   	handleUpsertDML
@createdDate  	03/21/2023
@param     	  	recordsToUpdateList
@description  	after the insert of a sales org user record, user record is updated.
**********************************************************************************************************/ 
    public static void handleUpdateDML(List<Sobject> recordsToUpdateList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        Integer count = 0;
        
        Database.saveResult[] saveResultList = Database.update(recordsToUpdateList,false);
        
        for (Database.saveResult saveResultListObj : saveResultList) {
            if(!saveResultListObj.isSuccess()){
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.errors = saveResultListObj.getErrors();
                logWrapperObj.guid = recordsToUpdateList[count].id;
                logWrapperObj.className=TPM_ConstantsUtility.SALES_ORG_USER_TRIGGER_HELPER_EXTENSION;
                logWrapperObj.methodName=TPM_ConstantsUtility.HANDLE_UPDATE_DML;
                logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                exceptionWrapperList.add(logWrapperObj);
            }
            
            count++;
        }
        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }
        
        
    }
    
    
    
    
    
    
}