/*******************************************************************************************************
* @Name         : TPM_US01NightlyQScheduler
* @testclass    : TPM_US01NightlyQSchedulerTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Schedulable Apex is used to schedule the US01 TPMCalculationChain Batches nightly.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public class TPM_US01NightlyQScheduler implements Schedulable {

     /******************************************************************************************
    * @method			execute
    * @param			scon
    * @description		Schedulable execute method.
    ******************************************************************************************/ 
      
      public void execute(SchedulableContext scon) {
          // Call the TPM_US01NightlyQueue Class
          System.enqueueJob(new TPM_US01NightlyQueue());
      }
}