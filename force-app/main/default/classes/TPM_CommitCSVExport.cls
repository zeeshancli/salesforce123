/*******************************************************************************************************
* @Name         : TPM_CommitCSVExport
* @author       : PwC Team
* @date         : May 12, 2023
* @description  : Rest API Callout : Commit RTR Reports
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@RestResource(urlMapping='/TPMCommitCSVExport/*')
global with sharing class TPM_CommitCSVExport {
    
    /*****************************************************************************************
	* @method         : commitCSVExportMethod
	* @description    : To commit RTR reports if correct parameter values are given
	******************************************************************************************/
    @HttpGet
    global static void commitCSVExportMethod(){
        try{
            String businessyearStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_BUSINESSYEAR)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_BUSINESSYEAR):'';
            String salesorgStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_SALESORG)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_SALESORG):'';
            String metanameStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_METANAME)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_METANAME):'';
            String csvguidStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_CSVGUID)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_CSVGUID):'';
            
            validateCSVParams(metanameStr, salesorgStr, businessyearStr, csvguidStr);
            
        }
        catch(Exception ex){
           handleExceptionErrors(ex);
        }
    }
    
    /*****************************************************************************************
	* @method         : validateCSVParams
    * @param            metanameStr
    * @param            salesorgStr
    * @param            businessyearStr
    * @param            csvguidStr
	* @description    : Validate the parameters before commiting it.
	******************************************************************************************/
    public static void validateCSVParams(String metanameStr, String salesorgStr, String businessyearStr, String csvguidStr){
        if(String.isBlank(businessyearStr) || String.isBlank(salesorgStr) || String.isBlank(metanameStr) || String.isBlank(csvguidStr)){
            RestContext.response.responseBody  = Blob.valueOf(TPM_GetCSVGuid.getErrorResponse(TPM_ConstantsUtility.TPM_RTR_ERRORMSG));
        }
        else{
            executeCommitCSV(metanameStr,salesorgStr,businessyearStr,csvguidStr);
        }
    }
    /*****************************************************************************************
	* @method         : executeCommitCSV
    * @param            metanameStr
    * @param            salesorgStr
    * @param            businessyearStr
    * @param            csvguidStr
	* @description    : To commit RTR reports if correct parameter values are given
	******************************************************************************************/
    global static void executeCommitCSV(String metanameStr, String salesorgStr, String businessyearStr, String csvguidStr){
        cgcloud.OffPlatformCallout request = new cgcloud.OffPlatformCallout('COMMIT_RTR_EXPORT', salesorgStr);
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('metaname', metanameStr);
        dataMap.put('salesorg', salesorgStr);
        dataMap.put('businessyear', Integer.ValueOf(businessyearStr));
        
        String requestBodyContentStr = JSON.serialize(dataMap, true);
        Map<String, String> paramsMap = new Map<String, String>();
        paramsMap.put('csvGuid', csvguidStr);
        
        cgcloud.OffPlatformCalloutResponse response = request.execute(cgcloud.TransactionHandler.getTransactionIdentifier(), paramsMap, requestBodyContentStr);
        
        RestContext.response.responseBody  = Blob.valueOf(response.result);
    }

    /*****************************************************************************************
	* @method         : handleExceptionErrors
    * @param            ex
	* @description    : To handle Exception Errors and return the exception error message
	******************************************************************************************/
    public static void handleExceptionErrors(Exception ex){
        if(ex.getMessage().contains('{')){
            TPM_RTR_ErrorWrapper errorObj = TPM_RTR_ErrorWrapper.parse(ex.getMessage());
            RestContext.response.responseBody  = Blob.valueOf(errorObj.message);
        }
        else{
            RestContext.response.responseBody  = Blob.valueOf(TPM_GetCSVGuid.getErrorResponse(ex.getMessage()));
        }
    }
}