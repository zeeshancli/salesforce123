/*******************************************************************************************************
* @Name         : TPM_US01NightlyBatchSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_US01NightlyBatchScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_US01NightlyBatchSchedulerTest {
    /********************************************************************
    * @method         : testUS01NightlyBatchScheduler
    * @description    : To test US01NightlyBatchScheduler scheduler
    *********************************************************************/
    @isTest public static void testUS01NightlyBatchScheduler() {
        
        Test.StartTest();
        TPM_US01NightlyBatchScheduler testSchObj = new TPM_US01NightlyBatchScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testUS01NightlyBatchScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}