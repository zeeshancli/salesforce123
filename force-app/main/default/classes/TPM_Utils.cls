/******************************************************************************************************
* @Name         : TPM_Utils
* @Test Class   : 
* @author       : PwC Team
* @date         : December 9, 2022
* @description  : Utility class providing reusable methods
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.TooManyFields')
public inherited sharing class TPM_Utils {
    
    public static Boolean isBypassUserTrigger = false;
    public static Boolean isBypassAccountTeamTrigger = false;
    public static Boolean isBypassAssignAccountTeamMember = false;
    public static Boolean isBypassRemoveAccountTeamMember = false;
    public static Boolean isBypassPromotionTrigger = false;
    public static Boolean isBypassAccountPlanTrigger = false;
    public static TPM_Trigger_Config_Settings__c triggerConfig; 
    public static Boolean isSuccessAssortment = false;
    public static Boolean isSuccessProductAssortment = false;
    public static Boolean isBypassSalesOrgUserTrigger = false;
    public static Map<Id, boolean> mapForCategoryAssortment = new Map<Id, boolean>();
    public static Set<Id> accountIdSet = new Set<Id>();
    public static Boolean isBypassAssortmentProductTrigger = false;
    public static Boolean isBypassStoreAssortmentTrigger = false;
    public static Boolean isBypassAssignAssortProd = false;
    public static Boolean isBypassRemoveAssortProd = false;
    public static Boolean isBypassUpdateAssortProd = false;
    public static Boolean isBypassTacticTrigger = false;
    public static Boolean isBypassTCCDTrigger = false;
    public static Boolean isBypassTPCTrigger = false;
    public static Boolean isBypassCBPCategoryTrigger = false;
    public static Boolean isBypassPromotionUpdateForDraft = false;


    /****************************************************************************************************
    @methodname 	TPM_Utils
    @createdDate 	12/09/2022
    @description	default private constructor
    *****************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_Utils(){

    }
    
     /******************************************************************************************************
    @methodname     fetchPersonaToGroupMap
    @createdDate    12/09/2022
    @return         Map<String,List<Id>>
    @description    returns custom metadata records for the combination of persona and the permission set group. 
    *******************************************************************************************************/

    public static Map<String,List<Id>> fetchPersonaToGroupMap(){ 
        Map<String,List<Id>> personaToGroupMap = new Map<String,List<Id>>();
    	Map<String,Id> permissionGroupIdMap = new Map<String,Id>();
    	for(PermissionSetGroup permissionGroupObj : [SELECT 
                                                     Id,
                                                     DeveloperName
                                                     FROM  PermissionSetGroup 
                                                     WHERE DeveloperName != NULL]){
                permissionGroupIdMap.put(permissionGroupObj.DeveloperName, permissionGroupObj.Id);         
                                                         
          }
        for(TPM_Persona_Permission_Set_Group__mdt mdtObj : TPM_Persona_Permission_Set_Group__mdt.getAll().values()){
            List<Id> permissionGroupIdList = new List<Id>();
            if(!personaToGroupMap.containskey(mdtObj.TPM_Persona__c)){
                if(permissionGroupIdMap.containskey(mdtObj.TPM_Permission_Set_Group__c)){
                    	permissionGroupIdList.add(permissionGroupIdMap.get(mdtObj.TPM_Permission_Set_Group__c));
                }
             }
            else{
                permissionGroupIdList.addAll(personaToGroupMap.get(mdtObj.TPM_Persona__c));
                if(permissionGroupIdMap.containskey(mdtObj.TPM_Permission_Set_Group__c)){
                    	permissionGroupIdList.add(permissionGroupIdMap.get(mdtObj.TPM_Permission_Set_Group__c));
                }
             }
            personaToGroupMap.put(mdtObj.TPM_Persona__c, permissionGroupIdList);
        }
        return personaToGroupMap;
   }
        
    /*************************************************************************************
	* @method        prepareBatchLogger
	* @return        TPM_LoggerException.LogsWrapper
	* @param         logsObj
	* @description   Method to prepare exception logger for batch errors.
	**************************************************************************************/

    public static TPM_LoggerException.LogsWrapper prepareBatchLogger(LogParamWrapper logsObj){
        
        TPM_LoggerException.LogsWrapper expLogObj = new TPM_LoggerException.LogsWrapper();
        expLogObj.className = logsObj.expClassName;
        expLogObj.methodName = logsObj.expClassName;
        expLogObj.guid = logsObj.expRecordId;
        expLogObj.logLevel = logsObj.expLogLevel;
        
        if(logsObj.expClassName == TPM_ConstantsUtility.BATCH_CUSTOMERTEMP_ASSIGNMENT){
            if(!String.isEmpty(logsObj.expRecordId)){
                expLogObj.accountID = logsObj.expRecordId;
            }
            expLogObj.recordName = logsObj.expRecordName;
        }
        if(logsObj.expClassName == TPM_ConstantsUtility.BATCH_PRODUCT_TEMP_ASSIGNMENT){
            if(!String.isEmpty(logsObj.expRecordId)){
                expLogObj.productID = logsObj.expRecordId;
            }
            expLogObj.recordName = logsObj.expRecordName;
        }
		
		if(logsObj.expClassName == TPM_ConstantsUtility.BATCH_PRODUCTRHIERARCHY_AUTOMATION){
            if(!String.isEmpty(logsObj.expRecordId)){
                expLogObj.productHSID = logsObj.expRecordId;
            }
        }
        
        
        if(String.isEmpty(logsObj.expErrorMessage)){
            expLogObj.errors = logsObj.errorList;
        }else{
            expLogObj.errorMessage = logsObj.expErrorMessage;
        }
        
        return expLogObj;         
    }
    
    /*************************************************************************************
	* @method        createLogParamWrapper
	* @param         errList
    * @param         className
    * @param         recordId
    * @return        TPM_Utils.LogParamWrapper
	* @description   Method to prepare exception logger for batch errors.
	**************************************************************************************/

    public static TPM_Utils.LogParamWrapper createLogParamWrapper(List<Database.Error> errList,String className,String recordId){
        
        //Create an Instance of TPM_Utils.LogParamWrapper to assign attribute values

        TPM_Utils.LogParamWrapper logObj = new TPM_Utils.LogParamWrapper();
        logObj.errorList = errList;
        logObj.expErrorMessage = '';
        logObj.expClassName =  className;
        logObj.expRecordId = recordId;
        logObj.expRecordName = '';
        logObj.expLogLevel = TPM_ConstantsUtility.ERROR;
        
        // return an instance of TPM_Utils.LogParamWrapper

        return logObj;

    }
    
    /*************************************************************************************
	* @method        createException
	* @param         expObj
	* @param		 expLevel
	* @param		 expClassName
	* @description   Method to prepare exception logger for normal errors.
	**************************************************************************************/ 

    public static void createException(Exception expObj,String expLevel,String expClassName){
        
        //Create an instance of TPM_LoggerException.LogsWrapper Class

        TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
        logWrapperObj.exceptionObj = expObj;
        logWrapperObj.logLevel = expLevel;
        logWrapperObj.className = expClassName;
        
        //Call the Log method to insert record

        TPM_LoggerException.log(new List<TPM_LoggerException.LogsWrapper>{logWrapperObj});
        
    }
    
    /************************************************************************************************** 
    @methodname 	validateAndCreateUserHandler
    @createdDate 	01/18/2023
    @description	check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 

    public static void validateAndCreateUserHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger   

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // User_Trigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassUserSettingTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

            if(TPM_Utils.triggerConfig.TPM_User_Trigger_Active__c && !TPM_Utils.isBypassUserTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_UserTriggerHandler.class);
        }
     } 
    
    /************************************************************************************************** 
    @methodname 	validateAndCreateAccountTeamHandler
    @createdDate 	01/18/2023
    @description	check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 

    public static void validateAndCreateAccountTeamHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger  

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // User_Trigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassUserSettingTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_AccountTeam_Trigger_Active__c && !TPM_Utils.isBypassAccountTeamTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_AccountTeamTriggerHandler.class);
        }
     }
     
    
    /*************************************************************************************
    @method          isRangeOverlap
    @return          Boolean
    @param           startDateOne
    @param           endDateOne
    @param           startDateTwo
    @param           endDateTwo
    @description     Method to determine whether two date ranges overlap
    **************************************************************************************/   
    public static Boolean isRangeOverlap(Date startDateOne, Date endDateOne, Date startDateTwo, Date endDateTwo){

        if(startDateOne <= endDateTwo && endDateOne >= startDateTwo){
            return true;   
        }
        
        return false;
    }
    
    /************************************************************************************************** 
    @methodname 	validateAndExtendAccessAccountPlanHandler
    @createdDate 	01/20/2023
    @description	Extend same access as account to customer Account plan on create and update
    ****************************************************************************************************/ 

    public static void validateAndExtendAccessAccountPlanHandler(){

        //TPM_AccountPlanTrigger_Active__c is hierarchy custom settings to check for user/profile related
        //checks for trigger   

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_AccountPlanTrigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassAccountPlanTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_AccountPlanTrigger_Active__c && !TPM_Utils.isBypassAccountPlanTrigger){

                TPM_TriggerDispatcher.createHandler(TPM_AccountPlanTriggerHandler.class);
         }
     }

    /************************************************************************************************** 
    @methodname 	validateAndExtendAccessPromotionHandler
    @createdDate 	01/20/2023
    @description	Extend same access as account to promotion on create and update
    ****************************************************************************************************/ 

    public static void validateAndExtendAccessPromotionHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger   

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_Promotion_Trigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassPromotionTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_Promotion_Trigger_Active__c && !TPM_Utils.isBypassPromotionTrigger){

                TPM_TriggerDispatcher.createHandler(TPM_PromotionTriggerHandler.class);

         } 
    }

    /********************************************************************************
    @method          getDynamicQueryRecords
    @return          Map<String, TPM_QueryDefinition__mdt>
    @param           processNamesList
    @description     method preparing query based on process names from Query Defination custommetadata record
    *********************************************************************************/
    public static Map<String, TPM_QueryDefinition__mdt> getDynamicQueryRecords(List<String> processNamesList){
        
        Map<String, TPM_QueryDefinition__mdt> processNameAndCorrQueryRecordMap = new Map<String, TPM_QueryDefinition__mdt>();
        
        // iterating over query defination based on process names from custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_ProcessName__c, TPM_BaseQuery__c,
                                                  TPM_QueryCondition__c, TPM_Query_Footer__c
                                                  FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c IN :processNamesList]){
        
            // preparing map of TPM_ProcessName__c and Resp. query defination records
            if(!processNameAndCorrQueryRecordMap.containsKey(queryDef.TPM_ProcessName__c)){
                processNameAndCorrQueryRecordMap.put(queryDef.TPM_ProcessName__c, queryDef);
            }
            
        }
        return processNameAndCorrQueryRecordMap;
    } 
    
     /************************************************************************************************** 
    @methodname 	validateAndCreateSalesOrgUserHandler
    @createdDate 	02/07/2023
    @description	check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/
    
    public static void validateAndCreateSalesOrgUserHandler(){
        
        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related trigger invocation  
        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
        
        // TPM_Sales_Org_User_Trigger__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassSalesOrgUserTrigger flag to check if from code perspective do we need to bypass the sales org user trigger.(mainly to limit recurssion)
        if(TPM_Utils.triggerConfig.TPM_Sales_Org_User_Trigger__c && !TPM_Utils.isBypassSalesOrgUserTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_SalesOrgUserTriggerHandler.class);
        }
    }

    /*******************************************************************************************************
    @description  :  Wrapper Class to log records in the TPM_Logger class.The following are the attributes of the class 
    *                errorList
    *                expErrorMessage
    *                expClassName
    *                expRecordId
    *                expRecordName
    *                expLogLevel
    ********************************************************************************************************/  
    
    public class LogParamWrapper{
        public List<Database.Error> errorList; 
        public String expErrorMessage;
        public String expClassName; 
        public String expRecordId; 
        public String expRecordName; 
        public String expLogLevel;
    }
    
    /************************************************************************************************** 
    @methodname 	validateAndCreateAssortmentProductHandler
    @createdDate 	02/21/2023
    @description	check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 

    public static void validateAndCreateAssortmentProductHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger  

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // User_Trigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassUserSettingTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_AssortmentProduct_Trigger_Active__c && !TPM_Utils.isBypassAssortmentProductTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_AssortmentProductTriggerHandler.class);
        }
     }
    
    
    /************************************************************************************************** 
    @methodname 	validateAndCreateTacticHandler
    @description	To check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 
    public static void validateAndCreateTacticHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger  

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_TacticTrigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassTacticTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_TacticTrigger_Active__c && !TPM_Utils.isBypassTacticTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_TacticTriggerHandler.class);
        }
     }
    
    
    /************************************************************************************************** 
    @methodname 	validateAndCreateTCCDHandler
    @description	To check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 
    public static void validateAndCreateTCCDHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger  

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_TCCDTrigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassTCCDTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_TCCDTrigger_Active__c && !TPM_Utils.isBypassTCCDTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_TCCDTriggerHandler.class);
        }
     }
    
    
    /************************************************************************************************** 
    @methodname 	validateAndCreateTPCHandler
    @description	To check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 
    public static void validateAndCreateTPCHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger  

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_TPCTrigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassTPCTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_TPCTrigger_Active__c && !TPM_Utils.isBypassTPCTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_TPCTriggerHandler.class);
        }
     }
    
     /************************************************************************************************** 
    @methodname 	validateAndCreateCBPCategoryHandler
    @description	To check the TPM_Trigger_Config_Settings__c custom setting to fire the Trigger.
    ****************************************************************************************************/ 
    public static void validateAndCreateCBPCategoryHandler(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger  

        TPM_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_CBPCategoryTrigger_Active__c is flag configured for user trigger in custom setting mentioned above.
        // isBypassCBPCategoryTrigger flag to check if from code perspective we need to bypass the user trigger.(mainly to limit recurssion)

        if(TPM_Utils.triggerConfig.TPM_CBPCategoryTrigger_Active__c && !TPM_Utils.isBypassCBPCategoryTrigger){
            TPM_TriggerDispatcher.createHandler(TPM_CBPCategoryTriggerHandler.class);
        }
     }
    
}