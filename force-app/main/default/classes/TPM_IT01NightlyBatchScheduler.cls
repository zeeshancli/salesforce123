/*******************************************************************************************************
* @Name         : TPM_IT01NightlyBatchScheduler
* @testclass    : TPM_IT01NightlyBatchSchedulerTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Schedulable Apex is used to schedule the IT01 TPMCalculationChain Nightly Batches.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_IT01NightlyBatchScheduler  implements Schedulable {

     /******************************************************************************************
    * @method			 execute
    * @param			 scon
    * @description		 Schedulable execute method.
    ******************************************************************************************/ 
      
      public void execute(SchedulableContext scon) {
          Database.executeBatch(new TPM_IT01NightlyBatch());
      }
}