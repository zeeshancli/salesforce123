/*******************************************************************************************************
* @Name         : TPM_US01CalculationChainSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_US01CalculationChainScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_US01CalculationChainSchedulerTest {
     /********************************************************************
    * @method         : testUS01CalculationChainScheduler
    * @description    : To test US01CalculationChainScheduler scheduler
    *********************************************************************/
    @isTest public static void testUS01CalculationChainScheduler() {
        
        Test.StartTest();
        TPM_US01CalculationChainScheduler testSchObj = new TPM_US01CalculationChainScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testUS01CalculationChainScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}