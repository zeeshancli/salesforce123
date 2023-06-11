/*******************************************************************************************************
* @Name         : TPM_RTRcsvGuidWrapper
* @author       : PwC Team
* @date         : May 12, 2023
* @description  : Wrapper class for helping parse response from TPM_GetCSVGuid
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public class TPM_RTRcsvGuidWrapper{
	public String csvGuid;	
    
    /*****************************************************************************************
	* @method         : parse
	* @return 			TPM_RTRcsvGuidWrapper
	* @param			json
	* @description    : To parse the response from TPM_GetCSVGuid
	******************************************************************************************/
	public static TPM_RTRcsvGuidWrapper parse(String json){
		return (TPM_RTRcsvGuidWrapper) System.JSON.deserialize(json, TPM_RTRcsvGuidWrapper.class);
	}
}