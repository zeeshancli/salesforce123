/*******************************************************************************************************
* @name         : TPM_AccountTeamTriggerTest
* @author       : PwC Team
* @date         : 01/19/2023
* @description  : Test Class for Account Team trigger/handler/helper
*******************************************************************************************************/
@isTest
public class TPM_AccountTeamTriggerTest {

    static String assertStr = 'List should not be empty';
    static String test ='Test';
    
    /*****************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for account Team test class
    *****************************************************************************************/
    
    @testSetup static void testDataSetUpMethod() {
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        insert triggerConfigSettingList;
        
        User userObj = TPM_TestDataUtility.createUser('System Administrator');
        insert userObj;
        Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',null);
        insert superGroupAcc;
        Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
        insert groupAcc;
        Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
        insert managedAccountAcc;
        Account soldToAcc = TPM_TestDataUtility.createAccountByHierarchy('Sold-To',managedAccountAcc.Id);
        insert soldToAcc;
        
        AccountTeamMember accTeamMemberObj = TPM_TestDataUtility.createAccountTeamMember(managedAccountAcc.Id,userObj.Id);
        insert accTeamMemberObj;
    }
    
 /******************************************************************************************
    * @method			testAccountTeamHandlerMethod
    * @ return     		:void
    * @param   		  
    * @description    	test method for account team trigger handler
    ******************************************************************************************/
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static void testAccountTeamHandlerMethod() {
        List<Sobject> sobectList = new List<Sobject>();
        Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
        Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
        TPM_AccountTeamTriggerHandler tpmTriggerHandler = new TPM_AccountTeamTriggerHandler();
        tpmTriggerHandler.bulkBefore();
            tpmTriggerHandler.beforeInsert(sobectList);
            tpmTriggerHandler.beforeUpdate(newMapParam,oldMapParam);
            tpmTriggerHandler.beforeDelete(oldMapParam);
            tpmTriggerHandler.afterDelete(oldMapParam);
            tpmTriggerHandler.afterUnDelete(sobectList);
           List<AccountTeamMember> accountTeamList = [select id,user.name from AccountTeamMember LIMIT 1];
       system.assert(!accountTeamList.isEmpty(),assertStr);
   }
    
    /******************************************************************************************
    * @method			testAccountTeamDelete
    * @ return     		:void
    * @param   		  
    * @description    	test method for deleting account team members for managed account
    ******************************************************************************************/
    
    @isTest
    @SuppressWarnings('PMD.useCollectionsWithWhereClauses')
    public static void testAccountTeamDelete() {
        Account managedAccount = [SELECT Id FROM Account WHERE TPM_Hierarchy_Level__c='Managed Account' LIMIT 1];
        List<User> userObjList = [SELECT Id FROM user WHERE Alias='standt' LIMIT 1];
        AccountTeamMember accountTeamMemberObj = [Select id from accountteammember where accountid =: managedAccount.id and userid =:userObjList[0].id];
        delete accountTeamMemberObj;
        system.assert(!userObjList.isEmpty(),assertStr);
    } 
    
    /******************************************************************************************
    * @method			testAccountTeamRecordShare
    * @ return     		void
    * @param   		  
    * @description    	test method for record share with account team members for managed account
    ******************************************************************************************/
    @isTest
    public static void testAccountTeamRecordShare() {
        
        Account managedAccount = [SELECT Id FROM Account WHERE TPM_Hierarchy_Level__c='Managed Account' LIMIT 1];
        User adminUser = [SELECT Id FROM user WHERE Alias='standt' LIMIT 1];
        
        System.runAs(adminUser) {   
            AccountTeamMember accTeamMemberObj1 = TPM_TestDataUtility.createAccountTeamMember(managedAccount.Id, adminUser.Id);
            insert accTeamMemberObj1;
            
            List<AccountTeamMember> teamMemberRecord = [SELECT Id FROM AccountTeamMember WHERE id != NULL LIMIT 1];
            System.assertEquals(1, teamMemberRecord.size(), TPM_TestAutomationDataUtility.RECORDSDONTMATCH);
        }
    } 
    
    /******************************************************************************************
    * @method			testErrorHandler
    * @ return     		void
    * @param   		  
    * @description    	test method for account team trigger exception handling
    ******************************************************************************************/
    @isTest
    public static void testErrorHandler() {
        
        System.Test.startTest();
        try{
            TPM_AccountTeamTriggerHelper.teamMemberRecordSharingHandler(Null);
            TPM_AccountTeamTriggerHelper.deleteRecordAccessForTeamMembers(Null);
        }catch(Exception excep){
            System.assert(excep.getMessage().contains('MISSING_ARGUMENT'));
        }
        System.Test.stopTest();
    }
}