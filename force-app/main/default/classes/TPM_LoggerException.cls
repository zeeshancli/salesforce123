/*******************************************************************************************************
  @Name           TPM_LoggerException
  @testclass      TPM_LoggerExceptionTest
  @Author         PwC Team
  @date           December 6, 2022
  @description    This Apex is used for error logging framework to record exceptions/erorrs in Business flows.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_LoggerException extends Exception {
    /*used to avoid recursion*/
    private static Boolean isRunOnce = false;			
    
    /******************************************
	  @method          log 
	  @description     Use to trigger error log from diff components
      @param           logRecords
	********************************************/
    public static void log(List<LogsWrapper> logRecords) {							
        try {
            logErrors(logRecords);
        }
        catch(Exception excep) {
            if(!isRunOnce) {
                isRunOnce = true;
                LogsWrapper logNew = new LogsWrapper();
                logNew.exceptionObj = excep; logNew.flow = TPM_ConstantsUtility.ERROR_MODULE; 
                /*reWriting errors from error module itself (when somthing goes wrong creating error/exception details in SF)*/
                log(new List<LogsWrapper>{logNew});	
            }
        }                 
    }
    
    /******************************************
	  @method          logErrors 
	  @description     Use to write exceptions as SF record in TPM_Logger__c Object
      @param           logInfos
	********************************************/
    public static void logErrors(List<LogsWrapper> logInfos) {
        List<TPM_Logger__c> logsCollection = new List<TPM_Logger__c>();
        
        for(LogsWrapper logs : logInfos) {
            TPM_Logger__c logger = new TPM_Logger__c();
            logger.TPM_FlowName__c = logs.flow;
            logger.TPM_LogLevel__c = logs.logLevel;
            logger.TPM_GUID__c = logs.guid;
            logger.TPM_ClassName__c = logs.className;
            logger.TPM_MethodName__c = logs.methodName;
            logger.TPM_ComponentName__c = logs.cmpName;
            logger.TPM_RecordName__c = logs.recordName;
            logger.TPM_Account__c = logs.accountID;
            logger.TPM_Product__c = logs.productID;
            logger.TPM_Product_Hierarchy_Staging__c = logs.productHSID;

            // PBI-1606 : Added to populate CHS lookup.
            logger.TPM_Customer_Hierarchy_Staging__c = logs.customerHSID;
            
            //when it's not exception OR database.error [type] then pass custom error message
            if(logs.errorMessage != null) {
                logger.TPM_ExceptionMessage__c = logs.errorMessage;
            }
            
            if(logs.errors != null && !logs.errors.isEmpty()) {
                String errorMsg = '';
                String errorType = '';
                String stackTrace = '';
                for(Database.Error err :logs.errors) {
                    errorMsg += err.getMessage();
                    errorType += String.valueOf(err.getStatusCode());
                    stackTrace += String.valueOf(err.getMessage()+' \n '+err.getFields()); 
                }
                logger.TPM_ExceptionMessage__c = errorMsg;
                logger.TPM_ExceptionType__c = errorType;
                logger.TPM_StackTrace__c = stackTrace; 
            } else if(logs.exceptionObj != null){
                String stackTrace = logs.exceptionObj.getStackTraceString().substringBefore('\n');
                String className = stackTrace.substringAfter('.').substringBefore('.');
                logger.TPM_ClassName__c = className;
                logger.TPM_MethodName__c = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.'); 
                logger.TPM_ExceptionType__c = logs.exceptionObj.getTypeName();
                logger.TPM_ExceptionMessage__c = logs.exceptionObj.getMessage();
                logger.TPM_StackTrace__c = String.valueOf(logs.exceptionObj) + ' at Line Number : ' + String.valueOf(logs.exceptionObj.getLineNumber()); 
            }
            logsCollection.add(logger);
        }
        insert logsCollection;   
    }

    /*******************************************************************************************************
     @description    LogsWrapper (Custom datatype collection for logs info.)
	 *               errors (List of batch database dml errors), className (apex class name), methodName (apex class name),
	 *			     exceptionObj (Instance of Exception object), flow (Business flow), logLevel (can be Fatal, Error, Warn),
	 *			     guid (recordID/externalID), cmpName (Aura/LWC/Vf name), recordName (SF Record Name e.g.: SalesOrg Name),
     *               accountID (Account Lookup for CustomerExtn Batch), productID (Product Lookup for ProductTemplateExtn Batch),
     * 			     errorMessage (Custom error message string to log)
    *******************************************************************************************************/

    public class LogsWrapper {
        /*For BatchClass/SaveResult Only starts*/
        public List<Database.Error> errors;			
        public String className;					
        public String methodName;					
        /*ends*/
        public Exception exceptionObj;				
        public String flow;							
        public String logLevel;						
        public String guid;		
        public String cmpName;
        public String recordName;
        public String accountID;
        public String productID;
        public String errorMessage;
        public String productHSID;

        // PBI-1606 : Added to populate CHS lookup.
        public String customerHSID;
    }
    
}