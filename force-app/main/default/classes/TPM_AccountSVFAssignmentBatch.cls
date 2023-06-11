/*****************************************************************************************************************************
* @Name          TPM_AccountSVFAssignmentBatch
* @Test Class    TPM_AccountSVFAssignmentBatchTest
* @Author        PwC Team
* @date          May 4, 2023
* @description   Batch Apex is used to populate current year, previous year and next year SVF external Ids in Account object
********************************************************************************************************************************
Change History Story      Modified by               Date                          Desc

********************************************************************************************************************************/
public with sharing class TPM_AccountSVFAssignmentBatch implements Database.Batchable<sObject>{
    
    /**************************************************************************************************
     @method       Batch Start Method
     @return       Database.QueryLocator
     @param        bc
     @description  Returns all the Account Records in which TPM_Hierarchy_Level__c as Managed Account 
    ****************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){
        /* Get all the list of Managed Account records*/
        String query = 'SELECT Id FROM Account WHERE TPM_Hierarchy_Level__c =\'Managed Account\''; 
        return Database.getQueryLocator(query);
    }
    
    /******************************************************************************************************
     @method       Batch execute Method
     @param        bc
     @param        accList
     @description  Assigning SVF External Id of current year, previous year and next year in Account object
    ******************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> accList){
        // To store Account Id from the SVFs
        Set<Id> accountIdSet = new Set<Id>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        // To store svf Ids and Unique key which is Account id + Business year
        Map<String,Id> svfMap = new Map<String,Id>();
        
        // To store current year, previous year and next year
        Set<String> businessYears = new Set<String>();
        Integer currentYear = System.Today().year();
        businessYears.add(String.valueOf(currentYear));
        businessYears.add(String.valueOf(currentYear-1));
        businessYears.add(String.valueOf(currentYear+1));
        
        // retrieving SVFs where current,previous,next Businesyears and Account
        for(cgcloud__Account_Plan__c svfObj : [SELECT Id,cgcloud__Account__c,cgcloud__Business_Year_Label__c FROM cgcloud__Account_Plan__c 
                                                WHERE cgcloud__Business_Year_Label__c IN :businessYears AND cgcloud__Account__c IN :accList ] ){
                                                    if(!svfMap.containsKey(svfObj.cgcloud__Account__c+svfObj.cgcloud__Business_Year_Label__c)){
                                                        accountIdSet.add(svfObj.cgcloud__Account__c);
            											String uniqueAccountYear = svfObj.cgcloud__Account__c+svfObj.cgcloud__Business_Year_Label__c;
            											svfMap.put(uniqueAccountYear,svfObj.Id);                                                        
                                                    }
                                                }
        // Updating the Particular Account in which SVF External ID should be populate        
        if(!accountIdSet.isEmpty()){
            List<Account> accountList = [SELECT Id,TPM_Current_Year_SVF__c,TPM_Previous_Year_SVF__c,TPM_Next_Year_SVF__c FROM Account WHERE Id IN :accountIdSet];
            for(Account accObj : accountList){
                if(svfMap.containsKey(accObj.Id+String.valueOf(currentYear))){
                    accObj.TPM_Current_Year_SVF__c = svfMap.get(accObj.Id+String.valueOf(currentYear));   
                }
                if(svfMap.containsKey(accObj.Id+String.valueOf(currentYear-1))){
                    accObj.TPM_Previous_Year_SVF__c = svfMap.get(accObj.Id+String.valueOf(currentYear-1));   
                }
                if(svfMap.containsKey(accObj.Id+String.valueOf(currentYear+1))){
                    accObj.TPM_Next_Year_SVF__c = svfMap.get(accObj.Id+String.valueOf(currentYear+1));
                }
            }
            exceptionWrapperList.addAll(handleUpdate(accountList));
            if(!exceptionWrapperList.isEmpty()){ 
                TPM_LoggerException.log(exceptionWrapperList);
            }
        }
       

    }
    
    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to process error logs to track batch failures.
    *************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc){
        
    }
    
    /******************************************************************************************
     @method			 handleUpdate
     @return			 List<TPM_LoggerException.LogsWrapper>
     @param			     accountList
     @description		 To handle any Exceptions during Database.Update for valid Account
     					 Records
    ******************************************************************************************/ 
    public List<TPM_LoggerException.LogsWrapper> handleUpdate(List<Account> accountList){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        Integer index=0;
        Database.SaveResult[] updatedAccountList = Database.update(accountList,false);
        for(Database.SaveResult result : updatedAccountList) {
            if(!result.isSuccess()){
                //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(result.getErrors(),TPM_ConstantsUtility.TPM_ACC_SVF_EXTID_BATCH,accountList[index].Id);
                //Call the TPM_Utils.prepareBatchLogger
                exceptionWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
            }
            index+=1;
        }
        return exceptionWrapperList;
    }

}