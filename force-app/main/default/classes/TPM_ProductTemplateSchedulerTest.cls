/*******************************************************************************************************
* @Name         : TPM_ProductTemplateSchedulerTest
* @author       : PwC Team
* @date         : Jan 04, 2023
* @description  : Test class for batch - 'TPM_ProductTemplateScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_ProductTemplateSchedulerTest {
    
/********************************************************************
* @method         : testTemplateAssignmentScheduler
* @description    : To test product template assignment scheduler
*********************************************************************/
    @isTest public static void testTemplateAssignmentScheduler() {
        
        Test.StartTest();
        TPM_ProductTemplateScheduler testSchObj = new TPM_ProductTemplateScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('ProductTemplateScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'One job to be scheduled');
        Test.stopTest();
    }
    
}