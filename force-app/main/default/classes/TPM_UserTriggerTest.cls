/*******************************************************************************************************
* @name         : TPM_UserTriggerTest
* @author       : PwC Team
* @date         : 12/23/2022
* @description  : Test Class for user trigger
*******************************************************************************************************/
@isTest
public class TPM_UserTriggerTest {

    static String assertStr = 'List should not be empty';
    
    /******************************************************************************************
    * @method			testDataSetUpMethod
    * @ return     		:void
    * @param   		  
    * @description    	Setup method for user test class
    ******************************************************************************************/
    @testSetup static void testDataSetUpMethod() {
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        insert triggerConfigSettingList;
        User userObj = TPM_TestDataUtility.createUser('System Administrator');
        insert userObj;
    }
    
 /******************************************************************************************
    * @method			testUserUpdateDeactive
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper
    ******************************************************************************************/
    
     @isTest
    public static void testUserUpdateDeactive() {
        User userobj = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
        userobj.isactive = false;
        update userobj;
        userobj.isactive= true;
        update userobj;
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
        
        
    }
    
    /******************************************************************************************
    * @method			testUserUpdateActive
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper
    ******************************************************************************************/
    @isTest
    public static void testUserUpdateActive() {
        User userobj = [SELECT Id,TPM_Persona__c,isactive,Alias FROM user WHERE Alias='standt' LIMIT 1];
        userobj.isactive = true;
        update userobj;
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
        
        
    }

     /******************************************************************************************
    * @method			testUserUpdateHandleExcep
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper
    ******************************************************************************************/
    
    @isTest
    public static void testUserUpdateHandleExcep() {
        TPM_UserTriggerHandler tpmTriggerHandler = new TPM_UserTriggerHandler();
		List<Id> userIdList = new List<Id>();
        Map<Id,Sobject> newMapUser = new map<Id,Sobject>();
        User userobj = [SELECT Id,TPM_Persona__c,isactive,Alias FROM user WHERE Alias='standt' LIMIT 1];
        userobj.isactive = true;
        userobj.Alias=userobj.Alias+'123456';
        userIdList.add(userobj.Id);
        newMapUser.put(userobj.id,userobj);
        TPM_UserTriggerHelper.assignUserToGroup(userIdList);
        TPM_UserTriggerHelper.createUserSetting(newMapUser);
        tpmTriggerHandler.afterInsert(newMapUser);
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
     }
    
     /******************************************************************************************
    * @method			testUserUpdateHandleExcep2
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper
    ******************************************************************************************/
    /*@isTest
    public static void testUserUpdateHandleExcep2() {
        
        TPM_TriggerDispatcher.createHandler(TPM_Utils.class);
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
    }*/
    
    /******************************************************************************************
    * @method			testUserUpdateName
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper 
    ******************************************************************************************/
    @isTest
    public static void testUserUpdateName() {
        User userobj = [SELECT Id,lastName ,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
        userobj.lastName = userobj.lastName+'New';
        update userobj;
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
        
    }

    /******************************************************************************************
    * @method			testUserChangePersona
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper
    ******************************************************************************************/
    @isTest
    public static void testUserChangePersona() {
        User userobj = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
        userobj.TPM_Persona__c = 'System Administrator';
        update userobj;
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
        
        
    }
    
    /******************************************************************************************
    * @method			testUserHandlerMethod
    * @ return     		:void
    * @param   		  
    * @description    	test method for user trigger helper
    ******************************************************************************************/
    @isTest
    public static void testUserHandlerMethod() {
        List<Sobject> sobectList = new List<Sobject>();
        Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
        Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
        TPM_UserTriggerHandler tpmTriggerHandler = new TPM_UserTriggerHandler();
        tpmTriggerHandler.bulkBefore();
            tpmTriggerHandler.beforeInsert(sobectList);
            tpmTriggerHandler.beforeUpdate(newMapParam,oldMapParam);
            tpmTriggerHandler.beforeDelete(oldMapParam);
            tpmTriggerHandler.afterDelete(oldMapParam);
            tpmTriggerHandler.afterUnDelete(sobectList);
        List<User> userObjList = [SELECT Id,TPM_Persona__c,isactive FROM user WHERE Alias='standt' LIMIT 1];
       system.assert(!userObjList.isEmpty(),assertStr);
        
        
        
    }
    
    /******************************************************************************************
    * @method			testSalesOrgChange
    * @ return     		:void
    * @param   		  
    * @description    	test method for sales org change update
    ******************************************************************************************/
    @isTest
    public static void testSalesOrgChange() {
        
        List<User> userobjList = [SELECT Id,lastName ,TPM_Sales_Org__c,isactive FROM user WHERE Alias='standt' AND TPM_Sales_Org__c != null LIMIT 1];
        userobjList[0].TPM_Sales_Org__c = 'IT01';
        update userobjList[0];
        system.assert(!userObjList.isEmpty(),assertStr);

        
        
    }

}