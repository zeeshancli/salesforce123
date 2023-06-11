/*******************************************************************************************************
* @Name         : TPM_GetCSVGuidTest
* @author       : PwC Team
* @date         : May 30, 2023
* @description  : Test class for TPM_GetCSVGuid
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_GetCSVGuidTest {
    
    /*****************************************************************************************
	* @method         : testMethodWithCorrectParameters
	* @description    : Test method when all the given parameters are correct
	******************************************************************************************/
    @isTest
    public static void testMethodWithCorrectParameters(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TPMGetCSVGuid'; 
        req.httpMethod = 'Get';  
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('metaname','Integration Promotion Volume Export US01');
        req.addParameter('salesorg', 'US01');
        req.addParameter('businessyear','2023');
        RestContext.request = req;
        RestContext.response = res; 
       
        Test.startTest();
            TPM_GetCSVGuid.getCSVGuidMethod();
        	System.assert(RestContext.response!= null);
        Test.stopTest();  
    }
    
    
    /*****************************************************************************************
	* @method         : testMethodWithoutBusinessYear
	* @description    : Test method when business year is not given as a parameter
	******************************************************************************************/
    @isTest
    public static void testMethodWithoutBusinessYear(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/TPMGetCSVGuid'; 
        req.httpMethod = 'Get';  
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('metaname','Integration Promotion Volume Export US01');
        req.addParameter('salesorg', 'US01');
        RestContext.request = req;
        RestContext.response = res; 
       
        Test.startTest();
            TPM_GetCSVGuid.getCSVGuidMethod();
        	System.assert(RestContext.response!= null);
        Test.stopTest();  
    }
}