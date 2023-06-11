/*******************************************************************************************************
* @Name         : TPM_GetCSVGuid
* @author       : PwC Team
* @date         : May 12, 2023
* @description  : Rest API Callout : Get CSV Guid for RTR Reports
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@RestResource(urlMapping='/TPMGetCSVGuid/*')
global with sharing class TPM_GetCSVGuid {
    
    /*****************************************************************************************
	* @method         : getCSVGuidMethod
	* @description    : To get the CSV Guid if correct parameter values are given
	******************************************************************************************/
    @HttpGet
    global static void getCSVGuidMethod() {
        try{
            String businessyearStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_BUSINESSYEAR)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_BUSINESSYEAR):'';
            String salesorgStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_SALESORG)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_SALESORG):'';
            String metanameStr = RestContext.request.params.containsKey(TPM_ConstantsUtility.TPM_RTR_METANAME)?RestContext.request.params.get(TPM_ConstantsUtility.TPM_RTR_METANAME):'';
            if(String.isEmpty(businessyearStr) || String.isEmpty(salesorgStr) || String.isEmpty(metanameStr)){               
                RestContext.response.responseBody  = Blob.valueOf(getErrorResponse(TPM_ConstantsUtility.TPM_RTR_ERRORMSG));
            }
            else{
                cgcloud.OffPlatformCallout request = new cgcloud.OffPlatformCallout('SCHEDULE_RTR_EXPORT', salesorgStr);
                Map<String, Object> dataMap = new Map<String, Object>();
                dataMap.put('metaname', metanameStr);
                dataMap.put('salesorg', salesorgStr);
                dataMap.put('businessyear', Integer.ValueOf(businessyearStr));
                
                String requestBodyContentStr = JSON.serialize(dataMap, true);
                Map<String, String> paramsMap = new Map<String, String>();
                
                cgcloud.OffPlatformCalloutResponse response = request.execute(cgcloud.TransactionHandler.getTransactionIdentifier(), paramsMap, requestBodyContentStr);
                
                TPM_RTRcsvGuidWrapper obj = TPM_RTRcsvGuidWrapper.parse(response.result);
                RestContext.response.responseBody  = Blob.valueOf(JSON.serialize(obj));
            }
        }
        catch(Exception ex){
            if(ex.getMessage().contains('{')){
            	TPM_RTR_ErrorWrapper errorObj = TPM_RTR_ErrorWrapper.parse(ex.getMessage());
                RestContext.response.responseBody  = Blob.valueOf(errorObj.message);
            }
            else{
                RestContext.response.responseBody  = Blob.valueOf(getErrorResponse(ex.getMessage()));
            }
        }
    }

    /****************************************************************************
	* @method         : getErrorResponse
    * @return           String
    * @param            message
	* @description    : To display the error message when an error occurs
	*****************************************************************************/
    public static String getErrorResponse(String message){        
        Map<String, String> errorMap = new Map<String, String>(); 
        errorMap.put('error', message);
        String errorMsgStr =JSON.serialize(errorMap);
        return errorMsgStr;
    }
}