/*******************************************************************************************************
* @Name         : TPM_IT01CalculationChainQScheduler
* @testclass    : TPM_IT01CalculationChainQSchedulerTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Schedulable Apex is used to schedule the IT01 TPMCalculationChain Batches for 10 Mins.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public class TPM_IT01CalculationChainQScheduler implements Schedulable {

     /******************************************************************************************
    * @method			execute
    * @param			scon
    * @description		Schedulable execute method.
    ******************************************************************************************/ 
      
      public void execute(SchedulableContext scon) {
          // Call the TPM_IT01CalculationChainQueue Class
          System.enqueueJob(new TPM_IT01CalculationChainQueue());
      }
}