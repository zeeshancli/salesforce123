/*******************************************************************************************************
* @Name         : TPM_ProductFlatteningCategorySchedulTest
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Test class for batch - 'TPM_ProductFlatteningCategoryScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_ProductFlatteningCategorySchedulTest {


    /********************************************************************
	* @method         : testProdHierarchyCreationScheduler
	* @description    : To test product hierarchy creation scheduler
	*********************************************************************/
    @isTest public static void testProdHierarchyCreationScheduler() {
        
        Test.StartTest();
        
        TPM_ProductFlatteningCategoryScheduler testSchObj = new TPM_ProductFlatteningCategoryScheduler();
        String cronExp = '0 0 23 * * ?';
        String jobId = System.schedule('ProductFlatteningScheduler', cronExp, testSchObj);

        // Fetch the information from the CronTrigger object.
        CronTrigger ct = [SELECT Id, 
                                 CronExpression 
                          FROM CronTrigger 
                          WHERE Id = :jobId 
                          LIMIT 1];
        
        // Verify the expressions is the same
        System.assertEquals(cronExp, ct.CronExpression, 'CronExpression verified.');
        
        Test.stopTest();
    }

}