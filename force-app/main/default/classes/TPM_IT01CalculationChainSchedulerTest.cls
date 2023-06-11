/*******************************************************************************************************
* @Name         : TPM_IT01CalculationChainSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_IT01CalculationChainScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_IT01CalculationChainSchedulerTest {
    /********************************************************************
    * @method         : testIT01CalculationChainScheduler
    * @description    : To test IT01CalculationChainScheduler scheduler
    *********************************************************************/
    @isTest public static void testIT01CalculationChainScheduler() {
        
        Test.StartTest();
        TPM_IT01CalculationChainScheduler testSchObj = new TPM_IT01CalculationChainScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testIT01CalculationChainScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}