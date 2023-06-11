/*******************************************************************************************************
* @name         : TPM_OverLapCheckControllerTest
* @author       : PwC Team
* @date         : 01/30/2023
* @description  : Test Class for OverlapChecks
*******************************************************************************************************/
@SuppressWarnings('PMD.UnusedLocalVariable')
@isTest
public with sharing class TPM_OverLapCheckControllerTest {
   /*****************************************************************************************
    * @method			generateData  
    * @description    	Call for overlap check
    *****************************************************************************************/
    @testSetup
    public static void generateData(){

            
        List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
        triggerConfigSettingList[0].TPM_Promotion_Trigger_Active__c = true;
        insert triggerConfigSettingList;
        
        //insert supergroup
        Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org',null);
        insert totalSaslesOrgAcc;
        
        //insert supergroup
        Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',totalSaslesOrgAcc.Id);
        insert superGroupAcc;
        
        //insert group
        Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
        insert groupAcc;

        //insert Managed account
            Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
            insert managedAccountAcc;
         
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTemp;
            
            //Create promotion
            cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
            promotionRec.TPM_Phase__c = 'Planning';
            insert promotionRec;

             //Create Tactic template
             cgcloud__Tactic_Template__c tacticTemplate = TPM_TestDataUtilityExtension.createTacticsTemplate();
             tacticTemplate.TPM_Type__c = '100% TPR';
             insert tacticTemplate;
            //Create tactic
            cgcloud__Tactic__c tacticRec = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);
            insert tacticRec;
         
            //Create Promotion template
            cgcloud__Promotion_Template__c promotionTempNew = TPM_TestDataUtilityExtension.createPromotionTemplate();
            insert promotionTempNew;
            
            //Create promotion
            cgcloud__Promotion__c promotionRecNew = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
            promotionRecNew.TPM_Phase__c = 'Planning';
            insert promotionRecNew;
            //Create tactic
            cgcloud__Tactic__c tacticRecNew = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);
            insert tacticRecNew;
            
}


    /*****************************************************************************************
    * @method			executeOverlapCheck  
    * @description    	Mock Callouts
    *****************************************************************************************/
    @isTest
    public static void executeOverlapCheck(){
        
        List<cgcloud__Promotion__c> promotionList = [Select Id,cgcloud__Sales_Org__c from cgcloud__Promotion__c WHERE id!=null];
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        
        StaticResource sr= [SELECT id,body FROM StaticResource WHERE Name = 'TPM_Promotion_Mock_JSON'];
        StaticResource prodMock= [SELECT id,body FROM StaticResource WHERE Name = 'TPM_Promotion_Mock_Product'];
        
        Map<String,Object> resultMap=(Map<String,Object>) JSON.deserializeUntyped(sr.body.toString());
        Map<String,Object> prodMap=(Map<String,Object>) JSON.deserializeUntyped(prodMock.body.toString());
        multimock.setStaticResource('https://duracell-sales--qa.sandbox.my.salesforce.com/services/oauth2/token','TPM_SF_Session_ID_Mock_JSON');
        multimock.setStaticResource('https://rcg-integration.industries.sfdc-yfeipo.svc.sfdcfc.net/api/v2/promotions/'+promotionList[0].Id+'/all/list?salesorg='+promotionList[0].cgcloud__Sales_Org__c+'&timeblock='+TPM_ConstantsUtility.CUSTOM_PERIOD,'TPM_Promotion_Mock_JSON');
        multimock.setStaticResource('https://duracell-sales--qa.sandbox.my.salesforce.com/services/oauth2/token','TPM_SF_Session_ID_Mock_JSON');
        multimock.setStaticResource('https://rcg-integration.industries.sfdc-yfeipo.svc.sfdcfc.net/api/v2/promotions/'+promotionList[1].Id+'/all/list?salesorg='+promotionList[1].cgcloud__Sales_Org__c+'&timeblock='+TPM_ConstantsUtility.CUSTOM_PERIOD,'TPM_Promotion_Mock_JSON');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        System.Test.StartTest();
        System.Test.setMock(HttpCalloutMock.class, multimock);
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('objId', promotionList[0].Id);
        mapParams.put('response',resultMap);
        TPM_OverLapCheckController overlap = new TPM_OverLapCheckController();
        Object callendPoint = overlap.call('getPromotions',mapParams);
        System.Test.StopTest();
        TPM_OverLapCheckControllerExtension overlapextension = new TPM_OverLapCheckControllerExtension();
        Object prodData = overlapextension.call('fetchProductData',mapParams);
        System.Assert(!promotionList.isEmpty(),false);

    }

     /*****************************************************************************************
    * @method			executeOverlapCheckExtend  
    * @description    	Mock Callouts
    *****************************************************************************************/
    @isTest
    public static void executeOverlapCheckExtend(){
        
            List<cgcloud__Promotion__c> promotionListOne = [SELECT 	Id,
                                                                            cgcloud__Sales_Org__c ,
                                                                            TPM_Phase__c
                                                                            FROM    cgcloud__Promotion__c
                                                                            //WHERE   TPM_Phase__c = 'Planning'
                                                                            LIMIT 	1];

            System.assertEquals(promotionListOne.isEmpty(), false);
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('TPM_Promotion_Mock_JSON');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json'); 

            // Set the mock callout mode
            System.Test.setMock(HttpCalloutMock.class, mock);
            System.Test.startTest();
            Map<String, Object> mapParamsOne = new Map<String, Object>();
            mapParamsOne.put('objId', promotionListOne[0].Id);
            TPM_OverLapCheckControllerExtension tpmClassObjOne = new TPM_OverLapCheckControllerExtension();
            tpmClassObjOne.call('getProductDetails', mapParamsOne);
           
            System.Test.stopTest();

    }
    
    /*****************************************************************************************
    * @method			executeOverlapCheckExtendNew  
    * @description    	Mock Callouts
    *****************************************************************************************/
    @isTest
    public static void executeOverlapCheckExtendNew(){

        
        List<cgcloud__Promotion__c> promotionListOne = [SELECT 	Id,
                                                     			cgcloud__Sales_Org__c ,
                                                     			TPM_Phase__c
                                                     	FROM    cgcloud__Promotion__c
                                                     	//WHERE   TPM_Phase__c = 'Planning'
                                                     	LIMIT 	1];
      
        System.assertEquals(promotionListOne.isEmpty(), false);
        StaticResource prodMock= [SELECT id,body FROM StaticResource WHERE Name = 'TPM_Promotion_Mock_Product'];
        Map<String,Object> prodMap=(Map<String,Object>) JSON.deserializeUntyped(prodMock.body.toString());
        StaticResourceCalloutMock mockNew = new StaticResourceCalloutMock();
        mockNew.setStaticResource('TPM_Promotion_Mock_Product');
        mockNew.setStatusCode(200);
        mockNew.setHeader('Content-Type', 'application/json'); 
       
       	// Set the mock callout mode
       	    System.Test.setMock(HttpCalloutMock.class, mockNew);

        // Set the mock callout mode
        System.Test.setMock(HttpCalloutMock.class, mockNew);
        System.Test.startTest();
        Map<String, Object> mapParamsNew = new Map<String, Object>();
        mapParamsNew.put('objId', promotionListOne[0].Id);
        mapParamsNew.put('response',prodMap);
        TPM_OverLapCheckControllerExtension tpmClassObjOne = new TPM_OverLapCheckControllerExtension();
        tpmClassObjOne.call('getProductDetails', mapParamsNew);
        
        System.Test.stopTest();

    }
     

    
}