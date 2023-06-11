/*******************************************************************************************************
* @Name         : TPM_RTR_ErrorWrapper
* @author       : PwC Team
* @date         : May 12, 2023
* @description  : Wrapper class for helping parse error msg for TPM_GetCSVGuid, TPM_GetStatusOfReport, TPM_CommitCSVExport
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public class TPM_RTR_ErrorWrapper {
	public String message;	
	
    /*****************************************************************************************
	* @method         : parse
	* @return			TPM_RTR_ErrorWrapper
	* @param				json
	* @description    : To parse the error msg from TPM_GetCSVGuid, TPM_GetStatusOfReport, TPM_CommitCSVExport
	******************************************************************************************/
	public static TPM_RTR_ErrorWrapper parse(String json){
		return (TPM_RTR_ErrorWrapper) System.JSON.deserialize(json, TPM_RTR_ErrorWrapper.class);
	}
}