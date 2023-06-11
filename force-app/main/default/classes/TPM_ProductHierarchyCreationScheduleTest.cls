/*******************************************************************************************************
* @Name         : TPM_ProductHierarchyCreationScheduleTest
* @author       : PwC Team
* @date         : January 18, 2023
* @description  : Test class for batch - 'TPM_ProductHierarchyCreationScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_ProductHierarchyCreationScheduleTest {


    /********************************************************************
	* @method         : testProdHierarchyCreationScheduler
	* @description    : To test product hierarchy creation scheduler
	*********************************************************************/
    @isTest public static void testProdHierarchyCreationScheduler() {
        
        Test.StartTest();
        
        TPM_ProductHierarchyCreationScheduler testSchObj = new TPM_ProductHierarchyCreationScheduler();
        String cronExp = '0 0 23 * * ?';
        String jobId = System.schedule('ProductHierarchyScheduler', cronExp, testSchObj);

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