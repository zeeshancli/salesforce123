/*********************************************************************************************
* @Name         : TPM_HttpMockGenerator
* @author       : PwC Team
* @date         : April 11, 2023
* @description  : Mock Class for generating Response for TPM_NightlyBatch 
                  & TPM_CalculationChain Batch
*********************************************************************************************
Change History Story      Modified by               Date                          Desc

**********************************************************************************************/
@isTest
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class TPM_HttpMockGenerator implements HttpCalloutMock {
    /*********************************************************************************
    * @method          : respond
    * @return          : HTTPResponse
    * @param             req
    * @description     : Constructor
    **********************************************************************************/
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Success');
        res.setStatusCode(200);
        return res;
    }
}