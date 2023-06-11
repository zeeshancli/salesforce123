/*******************************************************************************************************
* @Name         : TPM_InitialDataLoadHandleError
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for inserting error records of automation in logger object.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_InitialDataLoadHandleError {

    /*********************************************************************************
    * @method         : TPM_InitialDataLoadHandleError
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoadHandleError(){


    }
    
    /*********************************************************************************
    * @method         : createAndHandleError
    * @param            recordsToInsert
    * @param            methodName
    * @description    : Insert/update records and create failed records in Logger Object
    **********************************************************************************/
    public static void createAndHandleError(List<sobject> recordsToInsert,String methodName){
        //Create error records in Logger object for exceptions rasied from any of the above methods
       
        if(!recordsToInsert.isEmpty()){ 
            Database.upsertResult[] saveResultList = Database.upsert(recordsToInsert,false);
            TPM_InitialDataLoadHandleError.upsertRecord(saveResultList,recordsToInsert,methodName);

        }
    }
    
    
    /*********************************************************************************
    * @method         : upsertRecord
    * @param            saveResultList
    * @param            recordsToInsert
    * @param            methdName
    * @description    : Update records and create failed records in Logger Object
    **********************************************************************************/
    public static void upsertRecord(Database.upsertResult[] saveResultList,List<sobject> recordsToInsert,String methdName){
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
             Integer count = 0;
            for (Database.upsertResult saveResultListObj : saveResultList) {
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    if(string.isnotblank(recordsToInsert[count].id)){
                        logWrapperObj.guid = recordsToInsert[count].id;
                    }
                    logWrapperObj.className=TPM_AutomationConstantUtilityClass.TPMINITIALDATALOAD;
                    logWrapperObj.methodName=methdName;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
            
                count++;
            }
            TPM_LoggerException.log(exceptionWrapperList);
        }
        
    /*********************************************************************************
    * @method         : insertCustomErrorMessage
    * @param            salesOrg
    * @param            classNameOfError
    * @param            methodNameOfError
    * @description    : Update records and create failed records in Logger Object
    **********************************************************************************/
        public static void insertCustomErrorMessage(Set<String> salesOrg,String classNameOfError,String methodNameOfError){
            
            String customErrorMsg;
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
         
            for(String salesOrgName : salesOrg){
            
            //Based on method name create custom error message
                    Switch on methodNameOfError{
                    when 'salesOrgLoad' {	
                    
                        customErrorMsg = TPM_AutomationConstantUtilityClass.ERRORMESSAGEFORSALESORG +salesOrgName + TPM_AutomationConstantUtilityClass.ERRORMESSAGEFORSALESORGCONTINUE;
                        
                     }
                    when 'businessYearLoad' {	
        
                        customErrorMsg = salesOrgName+TPM_AutomationConstantUtilityClass.ERRORMESSAGEFORBYEAR + TPM_AutomationConstantUtilityClass.ERRORMESSAGEFORBYEARCONTINUE;
                        
                    }

                    when 'customPeriodUpload' {	
        
                        customErrorMsg = TPM_AutomationConstantUtilityClass.ERRORMESSAGEFORCUSTPERIOD +salesOrgName+ TPM_AutomationConstantUtilityClass.ERRORMESSAGEFORCUSTPERIODCONTINUE;
                        
                    }
            }

            //Create an instance of Wrapper Class of TPM_LoggerException.LogsWrapper
            TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
            logWrapperObj.logLevel = TPM_ConstantsUtility.ERROR;
            logWrapperObj.className = classNameOfError;
            logWrapperObj.methodName = methodNameOfError;
            logWrapperObj.errorMessage = customErrorMsg;
            exceptionWrapperList.add(logWrapperObj);
                    
        }
        
        if(!exceptionWrapperList.isEmpty()){
            // To log the custom errors 
            TPM_LoggerException.log(exceptionWrapperList); 
        }        
    }
}