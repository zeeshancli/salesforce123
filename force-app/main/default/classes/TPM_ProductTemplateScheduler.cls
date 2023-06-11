/*******************************************************************************************************
* @Name          TPM_ProductTemplateScheduler
* @Author        PwC Team
* @date          December 13, 2022
* @description   Schedulable Apex is used schedule product template assignment to product records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_ProductTemplateScheduler implements Schedulable {
    
    /******************************************************************************************
     @method			 execute
     @param			     sc
     @description		 Schedulable execute method.
    ******************************************************************************************/ 
    public void execute(SchedulableContext sc) {
        
        // Call the Batch Class to execute
        Database.executeBatch(new TPM_ProductTemplateAssignmentBatch());
    }
    
}