/******************************************************************************************************
  @Name          TPM_CustomerExtentionHelper
  @testclass     TPM_CustomerExtentionBatchTest
  @Author        PwC Team
  @date          December 12, 2022
  @description   Batch Apex helper class for TPM_CustomerExtentionBatch business logic.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_CustomerExtentionHelper {

    //private static instance of the class
    private static TPM_CustomerExtentionHelper instance;
    
    //private constructor to avoid creating an instance
    private TPM_CustomerExtentionHelper(){
        instance = null;
    }
    
    /********************************************************************************
     @return          TPM_CustomerExtentionHelper
     @description     getInstance
    *********************************************************************************/
    public static TPM_CustomerExtentionHelper getInstance(){
        if(instance == null){
            instance = new TPM_CustomerExtentionHelper();
        }
        return instance;
    }
        
    /*********************************************************************************
     @method          createCustomerExtension
     @param           scope
     @description     handler method for customer creations
    **********************************************************************************/
    public void createCustomerExtension(List<Account> scope) {
        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        List<cgcloud__Account_Extension__c> customerExtensions = new List<cgcloud__Account_Extension__c>();
        try{
            for(Account acc : scope) {
                 customerExtensions.add(customerExtensionFieldsMapping(acc));
            }
            if(!customerExtensions.isEmpty()) {
                // To insert the customer extn records.
                Database.SaveResult[] custExtensionList = Database.insert(customerExtensions,false); 
            	Integer index = 0;
                
                for(Database.SaveResult result : custExtensionList){
                    if(!result.isSuccess()){

                        //Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                        TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(result.getErrors(),TPM_ConstantsUtility.BATCH_CUSTOMEREXTENSION_ASSIGNMENT,custExtensionList[index].Id);

                        //Call the TPM_Utils.prepareBatchLogger
                        logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));
                    }
                    index++;
                }
            }
            
            if(!logWrapperList.isEmpty()){
                // To log the batch errors. 
                TPM_LoggerException.log(logWrapperList);
            }
        } catch(Exception excep) {
            
            //Call TPM_Utils.createException to create Exception records
            TPM_Utils.createException(excep,TPM_ConstantsUtility.FATAL,' ');
        }
    }
    
    /*********************************************************************************
     @method          customerExtensionFieldsMapping
     @return          cgcloud__Account_Extension__c object
     @param           acc
     @description     handler method for customer creations
    **********************************************************************************/
    public cgcloud__Account_Extension__c customerExtensionFieldsMapping(Account acc) {
        cgcloud__Account_Extension__c customerExtension = new cgcloud__Account_Extension__c();
        customerExtension.cgcloud__Account__c = acc.Id;
        customerExtension.cgcloud__Customer_Id__c = acc.cgcloud__ExternalId__c;
        customerExtension.cgcloud__State__c = TPM_ConstantsUtility.ACTIVE_CODE;

        if(acc.RecordType.DeveloperName.equalsIgnoreCase(TPM_ConstantsUtility.CUSTOMER_RECORDTYPE_NAME)) {
            customerExtension.cgcloud__Org_Level__c = TPM_ConstantsUtility.ORG_LEVEL_MAPPING.get(acc.TPM_Hierarchy_Level__c);
        }
        return customerExtension;
    }   
}