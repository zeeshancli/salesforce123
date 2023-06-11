/*******************************************************************************************************
* @Name         : TPM_GetStatusOfReport
* @author       : PwC Team
* @date         : May 12, 2023
* @description  : Rest API Callout : Get Status for RTR Reports
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@RestResource(urlMapping='/TPMGetStatus/*')
global with sharing class TPM_GetStatusOfReport {
    
    /*****************************************************************************************
	* @method         : getStatusMethod
	* @description    : To get the Status if correct parameter values are given
	******************************************************************************************/
    @HttpGet
    global static void getStatusMethod() {
        try{
            String salesorgStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_SALESORG)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_SALESORG):'';
            String csvguidStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_CSVGUID)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_CSVGUID):'';
            if(String.isEmpty(csvguidStr) || String.isEmpty(salesorgStr)){
                 RestContext.response.responseBody  = Blob.valueOf(TPM_GetCSVGuid.getErrorResponse(TPM_ConstantsUtility.TPM_RTR_ERRORMSG));
            }
            else{
                cgcloud.OffPlatformCallout request = new cgcloud.OffPlatformCallout('GET_RTR_EXPORT_STATUS', salesorgStr);
                Map<String, String> paramsMap = new Map<String, String>();
                paramsMap.put('csvGuid', csvguidStr);
                cgcloud.OffPlatformCalloutResponse response = request.execute(cgcloud.TransactionHandler.getTransactionIdentifier(), paramsMap, null);
                
                TPM_RTRStatusWrapper obj = TPM_RTRStatusWrapper.parse(response.result);
                RestContext.response.responseBody  = Blob.valueOf(JSON.serialize(obj)); 
            }
        }
        catch(Exception ex){
            if(ex.getMessage().contains('{')){
                TPM_RTR_ErrorWrapper errorObj = TPM_RTR_ErrorWrapper.parse(ex.getMessage());
                RestContext.response.responseBody  = Blob.valueOf(errorObj.message);
            }
            else{
				RestContext.response.responseBody  = Blob.valueOf(TPM_GetCSVGuid.getErrorResponse(ex.getMessage()));
            }
        }
    }
}