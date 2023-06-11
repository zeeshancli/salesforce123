/*******************************************************************************************************
* @Name          TPM_UserAutomationSetupObjectBatch
* @Test Class    TPM_UserAutomationSetupObjectBatchTest
* @Author        PwC Team
* @date          May 6,2023
* @description   Batch Apex is used for user record automation to handle any failures by User Automation
				 Triggers.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_UserAutomationSetupObjectBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
    
	/*************************************************************************************
     @method			 Batch Start Method
     @return     		 Database.QueryLocator
     @param     		 bc
     @description    	 Returns all the User Records which are Active
    **************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = '';
        //Query All User Records WHERE 
        //User Records are Active
        //Preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c 
                                                  FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.TPM_USER_AUTOMATION_BATCH_PROCESS_NAME]){
                                                      
                                                      if(String.isNotBlank(queryDef.TPM_BaseQuery__c)){
                                                          query = queryDef.TPM_BaseQuery__c;
                                                      }
                                                      if(String.isNotBlank(queryDef.TPM_QueryCondition__c)){
                                                          query = query + ' ' + queryDef.TPM_QueryCondition__c;
                                                      }
                                                  }
        return Database.getQueryLocator(query);
    }
    
     /******************************************************************************************************
     @method			 Batch execute Method
     @param     		 bc
     @param     		 userList
     @description    	 Process User Records and do User Automations based on conditions.  
    ******************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<User> userList) {
        
        // If userList not Empty
        if(!userList.isEmpty()){
            // Invoke handleUserPermissionSetGroup
             TPM_UserPermissionSetGroupAutomation.handleUserPermissionSetGroup(userList ,exceptionWrapperList);
        }  
    }
    
    /******************************************************************************************
     @method			 finish
     @param			     bc
     @description		 Batch finish method.
    ******************************************************************************************/  
    public void finish(Database.BatchableContext bc) {
        
        // To log error records 
        if(!exceptionWrapperList.isEmpty()){
            TPM_LoggerException.log(exceptionWrapperList);
        }  
        
    }
}