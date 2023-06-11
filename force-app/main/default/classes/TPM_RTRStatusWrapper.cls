/*******************************************************************************************************
* @Name         : TPM_RTRStatusWrapper
* @author       : PwC Team
* @date         : May 12, 2023
* @description  : Wrapper class for helping parse response from TPM_GetStatusOfReport
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.FieldNamingConventions')
public class TPM_RTRStatusWrapper {
public String Status;	
    
    /*****************************************************************************************
	* @method         : parse
	* @return			TPM_RTRStatusWrapper
	* @param			json
	* @description    : To parse the response from TPM_GetStatusOfReport
	******************************************************************************************/
	public static TPM_RTRStatusWrapper parse(String json){
		return (TPM_RTRStatusWrapper) System.JSON.deserialize(json, TPM_RTRStatusWrapper.class);
	}
}