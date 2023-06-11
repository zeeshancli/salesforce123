/*******************************************************************************************************
* @name         : TPM_TacticCardContainerControllerTest
* @author       : PwC Team
* @date         : 03/13/2023
* @description  : Test Class for Tactic module
*******************************************************************************************************/
@isTest
public class TPM_TacticCardContainerControllerTest {
    

    static String assertStr = 'List should not be empty';
    
    /*****************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for tactic lwc test class
    *****************************************************************************************/
    
    @testSetup static void testDataSetUpMethod() {
        
        cgcloud__Tactic_Template__c tacticTemplateObj =  TPM_TestDataUtilityExtension.createTacticTemplateBySalesOrg('IT01','Display');
        insert tacticTemplateObj;
        
    }
    
    /******************************************************************************************
    * @method			testTacticMethod1
    * @ return     		:void
    * @param   		  
    * @description    	test method for tactic lwc test class
    ******************************************************************************************/
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses') 
    public static void testfetchUIDefinitionObj() {
        List<cgcloud__Tactic_Template__c> tacticTempList = [Select id from cgcloud__Tactic_Template__c limit 1];
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('objId', tacticTempList[0].Id);
        
        TPM_TacticCardContainerController tpmClassObj = new TPM_TacticCardContainerController();
        Object objRet = tpmClassObj.call('fetchUIComponentData', mapParams);
        
        if(objRet!=null){
           system.assert(!tacticTempList.isEmpty(),assertStr); 
        }
       

    }
}