/******************************************************************************************************
* @Name         : TPM_CustomerTemplateAssignmentBatch
* @Test Class   : TPM_CustomerTemplateAssignmentBatchTest
* @author       : PwC Team
* @date         : December 5, 2022
* @description  : Batch Apex is used for customer temmplate assignment to account records.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public without sharing class TPM_CustomerTemplateAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    Map<String, Map<String, cgcloud__Account_Template__c>> salesOrgToModeWithActTemplateMap;
    Set<Id> actRecordIdSet;
    Set<String> salesOrgNameSet;
    Set<Id> emptySAPExtIdSet = new Set<Id>();  // added as part of User Story No : 720 customer external id assignment
    
    /**************************************************************************************
    * @method         : TPM_CustomerTemplateAssignmentBatch
    * @param            actIdSet
    * @description    : Constructor for the batch class
    **************************************************************************************/
    public TPM_CustomerTemplateAssignmentBatch(Set<Id> actIdSet){
        
        salesOrgToModeWithActTemplateMap = new Map<String, Map<String, cgcloud__Account_Template__c>>();
        actRecordIdSet = new Set<Id>();  
        salesOrgNameSet = new Set<String>();
        
        if(actIdSet != null){
            actRecordIdSet = actIdSet;
        }
                
        // To fetch active customer template records.
        for(cgcloud__Account_Template__c acTempObj : [SELECT Id, 
                                                             Name, 
                                                             cgcloud__Active__c, 
                                                             cgcloud__Sales_Org__c, 
                                                             TPM_CustTemp_PlanMode__c 
                                                     FROM cgcloud__Account_Template__c 
                                                     WHERE cgcloud__Sales_Org__c != NULL 
                                                     AND TPM_CustTemp_PlanMode__c != NULL 
                                                     AND cgcloud__Active__c = TRUE 
                                                     ORDER By CreatedDate DESC]){
            
            Map<String, cgcloud__Account_Template__c> modeToCustTemplateMap = new Map<String, cgcloud__Account_Template__c>();
            
            if(salesOrgToModeWithActTemplateMap.containsKey(acTempObj.cgcloud__Sales_Org__c)){
                if(!salesOrgToModeWithActTemplateMap.get(acTempObj.cgcloud__Sales_Org__c).containsKey(acTempObj.TPM_CustTemp_PlanMode__c)){
                    salesOrgToModeWithActTemplateMap.get(acTempObj.cgcloud__Sales_Org__c).put(acTempObj.TPM_CustTemp_PlanMode__c, acTempObj);
                }
            }else{
                modeToCustTemplateMap.put(acTempObj.TPM_CustTemp_PlanMode__c, acTempObj);
                salesOrgToModeWithActTemplateMap.put(acTempObj.cgcloud__Sales_Org__c, modeToCustTemplateMap);
            }
        }
    }
    
    
    /*********************************************************************************
    * @method         : start
    * @return         : Database.QueryLocator
    * @param            bc
    * @description    : Batch start method to fetch the account records.
    **********************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String queryStr = 'SELECT Id, Name, TPM_SAP_Sales_Org__c, TPM_Planning_Mode__c, cgcloud__Sales_Org__c,cgcloud__ExternalId__c, TPM_Hierarchy_Level__c,TPM_Dist_Channel_ID__c,TPM_SAP_External_ID__c,cgcloud__Account_Template__c FROM Account WHERE (( TPM_SAP_Sales_Org__c != null AND cgcloud__Account_Template__c = null ) ' 
                        +' OR (cgcloud__ExternalId__c = null) )' ;   // added as part of User Story No : 720 customer external id assignment
                                
        if(!actRecordIdSet.isEmpty()){
            queryStr += ' AND Id IN: actRecordIdSet ';
        }
        
        return Database.getQueryLocator(queryStr);
    }
    
    
    /********************************************************************************************************
    * @method         : execute
    * @param            bc 
    * @param            accountList
    * @description    : execute method to process account records for customer template assignment
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        
        List<Account> accountsToUpdateList = new List<Account>();
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        // To process the logic for customer template assignment.
        for(Account actObj : accountList){
 
            if(isValidateForTemplateAssignment(actObj)){
                accountsToUpdateList.add(actObj);
            } 
        }
        
        if(!accountsToUpdateList.isEmpty()){

            // To update the account records.
            Database.SaveResult[] accountSRList = Database.update(accountsToUpdateList,false); 
            Integer count = 0;
            
            for(Database.SaveResult actSR : accountSRList){
                
                if(!actSR.isSuccess()){ 

                    //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(actSR.getErrors(),TPM_ConstantsUtility.BATCH_CUSTOMERTEMP_ASSIGNMENT,accountsToUpdateList[count].Id);

                    //Call the TPM_Utils.prepareBatchLogger
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
                }
                count++;
            }
        }
        
        if(!logWrapperList.isEmpty()){

            // To log the batch errors. 
            TPM_LoggerException.log(logWrapperList);
        }
    }
    
    /************************************************************************************
    * @method         : isValidateForTemplateAssignment
    * @return         : Boolean
    * @param            actObj
    * @description    : To check the validity of customer template assignment
    *************************************************************************************/
    public Boolean isValidateForTemplateAssignment(Account actObj) {
        
        Boolean isValid = false;
        
        // added as part of User Story No : 720 customer external id assignment 
        // added && String.isBlank(actObj.cgcloud__Account_Template__c) 
        if(!salesOrgToModeWithActTemplateMap.isEmpty() && salesOrgToModeWithActTemplateMap.containsKey(actObj.TPM_SAP_Sales_Org__c) && String.isBlank(actObj.cgcloud__Account_Template__c)){
            
            // Hierachy Level = Managed Account
            if(actObj.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT 
               && salesOrgToModeWithActTemplateMap.get(actObj.TPM_SAP_Sales_Org__c).containsKey(actObj.TPM_Planning_Mode__c)) {
                    
                    // assign customer template record
                    actObj.cgcloud__Account_Template__c = salesOrgToModeWithActTemplateMap.get(actObj.TPM_SAP_Sales_Org__c).get(actObj.TPM_Planning_Mode__c).Id;                    
                    isValid = true;
                
                // Hierachy Level != Managed Account
            }else if(actObj.TPM_Hierarchy_Level__c != TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT 
                     && salesOrgToModeWithActTemplateMap.get(actObj.TPM_SAP_Sales_Org__c).containsKey(TPM_ConstantsUtility.ACT_TEMPLATE_GENERAL)){ 

                    // assign customer template record
                    actObj.cgcloud__Account_Template__c = salesOrgToModeWithActTemplateMap.get(actObj.TPM_SAP_Sales_Org__c).get(TPM_ConstantsUtility.ACT_TEMPLATE_GENERAL).Id;
                    isValid = true;
                         
                }else{
                    salesOrgNameSet.add(actObj.TPM_SAP_Sales_Org__c);
            }
        // added as part of User Story No : 720 customer external id assignment
        }else if(String.isBlank(actObj.cgcloud__Account_Template__c)){
            salesOrgNameSet.add(actObj.TPM_SAP_Sales_Org__c);
        }
        
        // added as part of User Story No : 720 customer external id assignment
        isValid = checkCustExternalId(actObj,isValid);
        
        return isValid;
    }

    /************************************************************************************
    * @method         : checkCustExternalId
    * @return         : Boolean
    * @param            actObj
    * @param			isValid
    * @description    : To check the whether CGExternalId needs to assigned or not
    *************************************************************************************/
    public boolean checkCustExternalId(Account actObj,boolean isValid){

        // added as part of User Story No : 720 customer external id assignment
        // If cgcloud__ExternalId__c is Blank and TPM_SAP_External_ID__c is not Blank
        if(String.IsBlank(actObj.cgcloud__ExternalId__c) && String.isNotBlank(actObj.TPM_SAP_External_ID__c)){
            isValid = isValidCreateCustExternalId(actObj);
        }else if(String.isBlank(actObj.TPM_SAP_External_ID__c)){
            emptySAPExtIdSet.add(actObj.Id);
        }
        
        return isValid;
    }
    
    /************************************************************************************
    * @method          isValidCreateCustExternalId
    * @param           actObj
    * @return          boolean
    * @description     isValidCreateCustExternalId method to create CustomerExternalIds
    *************************************************************************************/
    public boolean isValidCreateCustExternalId(Account actObj){
        
        Boolean isValid = false;
        //TPM_Hierarchy_Level__c is Managed Account && Planning Mode not blank 
        if( actObj.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT && String.isNotBlank(actObj.TPM_Planning_Mode__c)){
            actObj.cgcloud__ExternalId__c = actObj.TPM_SAP_External_ID__c + '_' + TPM_ConstantsUtility.PLAN_MODE_MAP.get(actObj.TPM_Planning_Mode__c); 
            isValid = true;
            
        //TPM_Hierarchy_Level__c is not Managed Account && TPM_Hierarchy_Level__c is not empty
        }else if(actObj.TPM_Hierarchy_Level__c != TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT ){
            actObj.cgcloud__ExternalId__c = actObj.TPM_SAP_External_ID__c;
            isValid = true;
        }      
        return isValid;
    }
    
    /************************************************************************************
    * @method         : finish
    * @param            bc
    * @description    : Batch finish method to process error logs to track batch failures.
    *************************************************************************************/
    public void finish(Database.BatchableContext bc) {
        
        List<TPM_LoggerException.LogsWrapper> invalidTemplateLogList = new List<TPM_LoggerException.LogsWrapper>();
        List<TPM_LoggerException.LogsWrapper> invalidSAPExtIdLogList = new List<TPM_LoggerException.LogsWrapper>();
        
        for(String salesOrgName : salesOrgNameSet){
            
            String customErrorMsg = salesOrgName + ' - ' + TPM_ConstantsUtility.CUSTOMERTEMPLATE_NOT_FOUND;

            //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
            TPM_Utils.LogParamWrapper logObj = new TPM_Utils.LogParamWrapper();
            logObj.errorList = null;
            logObj.expErrorMessage = customErrorMsg;
            logObj.expClassName = TPM_ConstantsUtility.BATCH_CUSTOMERTEMP_ASSIGNMENT;
            logObj.expRecordId = '';
            logObj.expRecordName = salesOrgName;
            logObj.expLogLevel = TPM_ConstantsUtility.ERROR;

            //Call the TPM_Utils.prepareBatchLogger
            invalidTemplateLogList.add(TPM_Utils.prepareBatchLogger(logObj));            
        }
        
        if(!invalidTemplateLogList.isEmpty()){
            
            // To log the batch errors. 
            TPM_LoggerException.log(invalidTemplateLogList);
        }
        
        // added as part of User Story No : 720 customer external id assignment
        //Iterate over all Records with Empty SAP External Ids
        for(Id accId : emptySAPExtIdSet){
            
            String customErrMsg = accId +' '+TPM_ConstantsUtility.EMPTY_SAP_SALES_ORG;

            //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
            TPM_Utils.LogParamWrapper logObj = new TPM_Utils.LogParamWrapper();
            logObj.errorList = null;
            logObj.expErrorMessage = customErrMsg;
            logObj.expClassName = TPM_ConstantsUtility.BATCH_CUSTOMERTEMP_ASSIGNMENT;
            logObj.expRecordId = accId;
            logObj.expRecordName = '';
            logObj.expLogLevel = TPM_ConstantsUtility.ERROR;

            //Call the TPM_Utils.prepareBatchLogger
            invalidSAPExtIdLogList.add(TPM_Utils.prepareBatchLogger(logObj));            
        }
        
        if(!invalidSAPExtIdLogList.isEmpty()){
            
            // To log the empty SAP Sales Org records errors. 
            TPM_LoggerException.log(invalidSAPExtIdLogList);
        }

        //Check for Batch Sequencing
        if(System.Label.isTPMBatchSequenced.equals(TPM_ConstantsUtility.IS_BATCH_SEQUENCING)){
            
            Integer batchSize = TPM_ConstantsUtility.NUMBER_200;
            //Get the Batch Size from CMDT TPM_QueryDefinition__mdt
            TPM_QueryDefinition__mdt batchQueryMdt = TPM_QueryDefinition__mdt.getInstance(TPM_ConstantsUtility.BATCH_CUSTOMEREXTENSION_ASSIGNMENT);
            
            if(String.isNotBlank(batchQueryMdt.TPM_BatchSize__c)){
                batchSize = Integer.valueOf(batchQueryMdt.TPM_BatchSize__c);
            }
            
            //If Batch is Sequenced, Call Customer Extension Batch next
            Database.executeBatch(new TPM_CustomerExtentionBatch(), batchSize);
        }            
    } 
}