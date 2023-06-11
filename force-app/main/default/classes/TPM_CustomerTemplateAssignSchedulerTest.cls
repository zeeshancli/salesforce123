/*******************************************************************************************************
* @Name         : TPM_CustomerTemplateAssignSchedulerTest
* @author       : PwC Team
* @date         : December 19, 2022
* @description  : Test class for batch - 'TPM_CustomerTemplateAssignmentScheduler'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@isTest
public class TPM_CustomerTemplateAssignSchedulerTest {
    
    
    /********************************************************************
	* @method         : testTemplateAssignmentScheduler
	* @description    : To test customer template assignment scheduler
	*********************************************************************/
    @isTest public static void testTemplateAssignmentScheduler() {
        
        Test.StartTest();
        
        TPM_CustomerTemplateAssignmentScheduler testSchObj = new TPM_CustomerTemplateAssignmentScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('CustomerTemplateScheduler', sch, testSchObj);
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id 
                                            FROM AsyncApexJob 
                                            WHERE JobType = 'ScheduledApex'];
        
        System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
        
        Test.stopTest();
    }
    
}