/*******************************************************************************************************
* @Name         : TPM_IT01CalculationChainQSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_IT01CalculationChainQScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_IT01CalculationChainQSchedulerTest {
    
    /********************************************************************
    * @method         : testIT01CalculationChainQScheduler
    * @description    : To test IT01CalculationChainQScheduler scheduler
    *********************************************************************/
    @isTest public static void testIT01CalculationChainQScheduler() {
        
        Test.StartTest();
        TPM_IT01CalculationChainQScheduler testSchObj = new TPM_IT01CalculationChainQScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testIT01CalculationChainQScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}