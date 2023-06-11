/*******************************************************************************************************
* @Name         : TPM_CustomerExtentionScheduler
* @Author       : PwC Team
* @date         : December 13, 2022
* @description  : Schedulable Apex is used to schedule customer extension creation for account records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_CustomerExtentionScheduler implements Schedulable {
    
    /******************************************************************************************
    * @method			 execute
    * @param			 scon
    * @description		 Schedulable execute method.
    ******************************************************************************************/ 
    public void execute(SchedulableContext scon) {
        TPM_CustomerExtentionBatch customerExtension = new TPM_CustomerExtentionBatch();
        Database.executeBatch(customerExtension, Integer.valueOf(System.Label.TPM_CustomerExtentionBatchSize));
   }
    
}