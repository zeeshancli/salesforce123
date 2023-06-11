/*******************************************************************************************************
* @Name         : TPM_US01CalculationChainQSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_US01CalculationChainQScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_US01CalculationChainQSchedulerTest {
    
    /********************************************************************
    * @method         : testUS01CalculationChainQScheduler
    * @description    : To test US01CalculationChainQScheduler scheduler
    *********************************************************************/
    @isTest public static void testUS01CalculationChainQScheduler() {
        
        Test.StartTest();
        TPM_US01CalculationChainQScheduler testSchObj = new TPM_US01CalculationChainQScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testUS01CalculationChainQScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}