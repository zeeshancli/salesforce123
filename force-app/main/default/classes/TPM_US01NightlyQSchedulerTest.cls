/*******************************************************************************************************
* @Name         : TPM_US01NightlyQSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_US01NightlyQScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_US01NightlyQSchedulerTest {
    /********************************************************************
    * @method         : testUS01NightlyQueueScheduler
    * @description    : To test testUS01NightlyQueueScheduler Class
    *********************************************************************/
    @isTest public static void testUS01NightlyQueueScheduler() {
        
        Test.StartTest();
        TPM_US01NightlyQScheduler testSchObj = new TPM_US01NightlyQScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testUS01NightlyQueuecheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}