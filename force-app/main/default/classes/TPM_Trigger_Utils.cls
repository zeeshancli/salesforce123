/******************************************************************************************************
* @Name         : TPM_Trigger_Utils
* @Test Class   : 
* @author       : PwC Team
* @date         : 7th March, 2023
* @description  : Utility class Trigger Methods
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_Trigger_Utils {



    public static TPM_Trigger_Config_Settings__c triggerConfig; 
    public static Boolean isBypassAssortmentTrigger = false;
    public static Boolean isBypassAccountTrigger = false;
    public static Boolean isBypasspushPromotionStatusTrigger = false;

    /****************************************************************************************************
    @methodname 	TPM_Trigger_Utils
    @createdDate 	12/09/2022
    @description	default private constructor
    *****************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_Trigger_Utils(){

    }
    
   
/************************************************************************************************** 
    @methodname 	validateAccessForAccount
    @createdDate 	02/03/2023
    @description	Avoid Modification of account for Business Admin
    ****************************************************************************************************/ 

    public static void validateAccessForAccount(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger   
        
        //Check if running user is business admin and execute below code only business admin
        TPM_Trigger_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_Account_Trigger_Active__c is flag configured for account trigger in custom setting mentioned above.
       
        if(TPM_Trigger_Utils.triggerConfig.TPM_AccountTrigger_Active__c && !TPM_Trigger_Utils.isBypassAccountTrigger){

            TPM_TriggerDispatcher.createHandler(TPM_AccountTriggerHandler.class);

         } 
    }

    /************************************************************************************************** 
    @methodname 	validateAccessForAssortment
    @createdDate 	02/03/2023
    @description	Avoid Modification of account for Business Admin
    ****************************************************************************************************/ 

    public static void validateAccessForAssortment(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger   
        
        //Check if running user is business admin and execute below code only business admin
        TPM_Trigger_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_AssortmentTrigger_Active__c is flag configured for assortment trigger in custom setting mentioned above.
       
        if(TPM_Trigger_Utils.triggerConfig.TPM_AssortmentTrigger_Active__c && !TPM_Trigger_Utils.isBypassAssortmentTrigger){
                
                TPM_TriggerDispatcher.createHandler(TPM_AssortmentTriggerHandler.class);

         } 
    }

     /************************************************************************************************** 
    @methodname 	checkStatusOfPushPromotion
    @createdDate 	02/03/2023
    @description	Check Status Of Promotion Push
    ****************************************************************************************************/ 

    public static void checkStatusOfPushPromotion(){

        //Trigger_Config_Settings__c is hierarchy custom settings to check for user/profile related
        //checks for trigger   
        
        //Check if running user is business admin and execute below code only business admin
        TPM_Trigger_Utils.triggerConfig = TPM_Trigger_Config_Settings__c.getInstance();
                                     
        // TPM_AssortmentTrigger_Active__c is flag configured for assortment trigger in custom setting mentioned above.
       
        if(TPM_Trigger_Utils.triggerConfig.TPM_Promotion_Push_Status_Active__c && !TPM_Trigger_Utils.isBypasspushPromotionStatusTrigger){
                
                TPM_TriggerDispatcher.createHandler(TPM_PushPromotionStatusTriggerHandler.class);

         } 
    }



}