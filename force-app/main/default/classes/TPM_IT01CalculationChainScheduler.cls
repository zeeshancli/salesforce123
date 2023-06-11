/*******************************************************************************************************
* @Name         : TPM_IT01CalculationChainScheduler
* @testclass    : TPM_IT01CalculationChainSchedulerTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Schedulable Apex is used to schedule the IT01 TPMCalculationChain Batches for 10 Mins.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPM_IT01CalculationChainScheduler implements Schedulable {

     /******************************************************************************************
    * @method			execute
    * @param			scon
    * @description		Schedulable execute method.
    ******************************************************************************************/ 
      
      public void execute(SchedulableContext scon) {
          // Call the TPM_IT01CalculationChainBatch Class
          Database.executeBatch(new TPM_IT01CalculationChainBatch());
      }
}