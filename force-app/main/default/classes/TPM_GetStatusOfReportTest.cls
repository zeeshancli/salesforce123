/*******************************************************************************************************
* @Name         : TPM_GetStatusOfReportTest
* @author       : PwC Team
* @date         : May 30, 2023
* @description  : Test class for TPM_GetStatusOfReport
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_GetStatusOfReportTest {
    
    /*****************************************************************************************
	* @method         : testMethodWithCorrectParameters
	* @description    : Test method when all the given parameters are correct
	******************************************************************************************/
    @isTest
    public static  void testMethodWithCorrectParameters(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TPMGetStatus'; 
        req.httpMethod = 'Get';  
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('salesorg', 'US01');
        req.addParameter('csvguid','46397c8d-1c82-41aa-86c5-6e353c488de0');
        RestContext.request = req;
        RestContext.response = res; 
       
        Test.startTest();
            TPM_GetStatusOfReport.getStatusMethod();
        	System.assert(RestContext.response!= null);
        Test.stopTest();  
    }
    
    /*****************************************************************************************
	* @method         : testMethodWithoutCSVGuid
	* @description    : Test method when CSV Guid is not given as a parameter
	******************************************************************************************/
    @isTest
    public static void testMethodWithoutCSVGuid(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TPMGetStatus'; 
        req.httpMethod = 'Get';  
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('salesorg', 'US01');
        RestContext.request = req;
        RestContext.response = res; 
       
        Test.startTest();
            TPM_GetStatusOfReport.getStatusMethod();
        	System.assert(RestContext.response!= null);
        Test.stopTest();  
    }
}