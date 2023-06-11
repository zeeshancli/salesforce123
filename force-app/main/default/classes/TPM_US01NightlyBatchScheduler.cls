/*******************************************************************************************************
* @Name         : TPM_US01NightlyBatchScheduler
* @testclass    : TPM_US01NightlyBatchSchedulerTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Schedulable Apex is used to schedule the US01 TPMCalculationChain Nightly Batches.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_US01NightlyBatchScheduler implements Schedulable {

     /******************************************************************************************
    * @method       execute
    * @param        scon
    * @description  Schedulable execute method.
    ******************************************************************************************/ 
      
      public void execute(SchedulableContext scon) {
          // Call TPM_US01NightlyBatch Class
          Database.executeBatch(new TPM_US01NightlyBatch());
      }
}