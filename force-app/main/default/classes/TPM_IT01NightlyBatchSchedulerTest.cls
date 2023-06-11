/*******************************************************************************************************
* @Name         : TPM_IT01NightlyBatchSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_IT01NightlyBatchScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_IT01NightlyBatchSchedulerTest {
    /********************************************************************
    * @method         : testIT01NightlyBatchScheduler
    * @description    : To test IT01NightlyBatchScheduler scheduler
    *********************************************************************/
    @isTest public static void testIT01NightlyBatchScheduler() {
        
        Test.StartTest();
        TPM_IT01NightlyBatchScheduler testSchObj = new TPM_IT01NightlyBatchScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testIT01NightlyBatchScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }


}