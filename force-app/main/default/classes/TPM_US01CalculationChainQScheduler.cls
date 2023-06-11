/*******************************************************************************************************
* @Name         : TPM_US01CalculationChainQScheduler
* @testclass    : TPM_US01CalculationChainQSchedulerTest
* @Author       : PwC Team
* @date         : April 10, 2023
* @description  : Schedulable Apex is used to schedule the US01 TPMCalculationChain Batches for 10 Mins.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_US01CalculationChainQScheduler implements Schedulable {

     /******************************************************************************************
    * @method			execute
    * @param			scon
    * @description		Schedulable execute method.
    ******************************************************************************************/ 
      
      public void execute(SchedulableContext scon) {
          Integer batchSize = TPM_ConstantsUtility.NUMBER_200;
          // Call the TPM_US01CalculationChainQueue Class
          System.enqueueJob(new TPM_US01CalculationChainQueue());
          Database.executeBatch(new TPM_PopulateExternalIdForPromotionBatch(), batchSize);
      }
}