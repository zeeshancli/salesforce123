/*******************************************************************************************************
* @Name         : TPM_IT01NightlyQSchedulerTest
* @author       : PwC Team
* @date         : April 10, 2023
* @description  : Test class for batch - 'TPM_IT01NightlyQScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_IT01NightlyQSchedulerTest {
     /********************************************************************
    * @method         : testIT01NightlyQueueScheduler
    * @description    : To test testIT01NightlyQueueScheduler Class
    *********************************************************************/
    @isTest public static void testIT01NightlyQueueScheduler() {
        
        Test.StartTest();
        TPM_IT01NightlyQScheduler testSchObj = new TPM_IT01NightlyQScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('testIT01NightlyQueuecheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }

}