@isTest
public with sharing class TPM_OverlapCheckQueueTest {
    @SuppressWarnings('PMD.UnusedLocalVariable')
   
       /*****************************************************************************************
        * @method			generateData  
        * @description    	Call for overlap check
        *****************************************************************************************/
        @testSetup
        public static void generateData(){
    
                
            List<TPM_Trigger_Config_Settings__c> triggerConfigSettingList = TPM_TestDataUtility.createTriggerConfigSetting();
            insert triggerConfigSettingList;
            
            //insert supergroup
            Account totalSaslesOrgAcc = TPM_TestDataUtility.createAccountByHierarchy('Total Sales Org',null);
            insert totalSaslesOrgAcc;
            
            //insert supergroup
            Account superGroupAcc = TPM_TestDataUtility.createAccountByHierarchy('SuperGroup',totalSaslesOrgAcc.Id);
            insert superGroupAcc;
            
            Product2 createProducts = new Product2(Name = 'AA_Batteries',cgcloud__Consumer_Goods_External_Product_Id__c = 'AA_Batteries',cgcloud__Description_1_Language_1__c = 'AA_Batteries');
            insert createProducts;
            //insert group
            Account groupAcc = TPM_TestDataUtility.createAccountByHierarchy('Group',superGroupAcc.Id);
            insert groupAcc;
    
            //insert Managed account
                Account managedAccountAcc = TPM_TestDataUtility.createAccountByHierarchy('Managed Account',GroupAcc.Id);
                managedAccountAcc.cgcloud__ExternalId__c = '3244978990';
                insert managedAccountAcc;
             
                //Create Promotion template
                cgcloud__Promotion_Template__c promotionTemp = TPM_TestDataUtilityExtension.createPromotionTemplateByName('Parent_ShortTermEvent_IT01');
                insert promotionTemp;
                

                //Create promotion
                cgcloud__Promotion__c promotionRec = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTemp.Id);
                promotionRec.cgcloud__Push_Target_Account_Selection__c  = ' [{"included":true,"externalid":"3244978990"},{"included":true,"externalid":"86868969"}]';
                promotionRec.TPM_Phase__c = 'Planning';
                insert promotionRec;

                promotionRec.cgcloud__Is_Push_In_Progress__c = true;
                update promotionRec;
                promotionRec.cgcloud__Is_Push_In_Progress__c = false;
                update promotionRec;
               
                 //Create Promotion template
                cgcloud__Promotion_Template__c promotionTempChild = TPM_TestDataUtilityExtension.createPromotionTemplateByName('Child_ShortTermEvent_IT01');
                insert promotionTempChild;
                cgcloud__Promotion__c childRecord = new cgcloud__Promotion__c(cgcloud__Parent_Promotion__c = promotionRec.id, cgcloud__Promotion_Template__c = promotionTempChild.id,
                cgcloud__Slogan_Language_1__c = 'Test',
                cgcloud__Anchor_Account__c = managedAccountAcc.Id,
                cgcloud__Note__c = 'Test Notes',
                TPM_IsBypassValidationRule__c = false,
                cgcloud__Date_From__c= Date.newInstance(2024, 3, 5),
                cgcloud__Date_Thru__c=Date.newInstance(2024, 3, 27),
                cgcloud__Delivery_Date_From__c=Date.newInstance(2024, 3, 5),
                cgcloud__Delivery_Date_Thru__c=Date.newInstance(2024, 3, 25),
                cgcloud__Commit_Date__c=Date.newInstance(2024, 3, 5),
                cgcloud__Order_Date_From__c=Date.newInstance(2024, 3, 5),
                cgcloud__Order_Date_Thru__c=Date.newInstance(2024, 3, 27),
                cgcloud__Placement_Date_From__c=Date.newInstance(2024, 3, 7),
                cgcloud__Placement_Date_Thru__c=Date.newInstance(2024, 3, 27),
                cgcloud__Active__c= true);

                insert childRecord;
    
                 //Create Tactic template
                 cgcloud__Tactic_Template__c tacticTemplate = TPM_TestDataUtilityExtension.createTacticsTemplate();
                 tacticTemplate.TPM_Type__c = '100% TPR';
                 insert tacticTemplate;
                //Create tactic
                cgcloud__Tactic__c tacticRec = TPM_TestDataUtilityExtension.createTactic(promotionRec.Id, tacticTemplate.Id);               
                insert tacticRec;
             
               
                
                //Create promotion
                cgcloud__Promotion__c promotionRecNew = TPM_TestDataUtilityExtension.createPromotion(managedAccountAcc.Id,promotionTempChild.Id);
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
        public static void executeOverlapCheckQueue(){
            
            List<cgcloud__Promotion__c> promotionList = [Select Id,cgcloud__Sales_Org__c from cgcloud__Promotion__c WHERE id!=null];
                            
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('TPM_Promotion_Mock_JSON');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json'); 
            System.Test.StartTest();
            System.Test.setMock(HttpCalloutMock.class, mock);
            TPM_Utils_Extension.executeOverlapCheck( promotionList[0].Id);

            System.Test.StopTest();
            System.Assert(!promotionList.isEmpty(),false);
    
        }

            /*****************************************************************************************
        * @method			executeOverlapCheck  
        * @description    	Mock Callouts
        *****************************************************************************************/
        @isTest
        public static void executeOverlapCheckQueueNext(){
            
            List<cgcloud__Promotion__c> promotionList = [Select Id,cgcloud__Sales_Org__c from cgcloud__Promotion__c WHERE id!=null];            
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('TPM_Promotion_Mock_JSON');
            mock.setStatusCode(400);
            mock.setHeader('Content-Type', 'application/json'); 
            System.Test.StartTest();
            System.Test.setMock(HttpCalloutMock.class, mock);

            TPM_Utils_Extension.executeOverlapCheck( promotionList[0].Id);

            System.Test.StopTest();
            System.Assert(!promotionList.isEmpty(),false);
    
        }

         /*****************************************************************************************
        * @method			executeOverlapCheck  
        * @description    	Mock Callouts
        *****************************************************************************************/
        @isTest
        public static void executeOverlapCheckParentPromo(){
            List<cgcloud__Promotion__c> promotionList = [Select Id,cgcloud__Sales_Org__c from cgcloud__Promotion__c WHERE id!=null];
            Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> blankData = new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody>();
            TPM_OverlapCheckQueableExt.updateParentPromotion(blankData,promotionList[0].Id);
            cgcloud__Promotion_Push_Status__c pushPromotionRec = new cgcloud__Promotion_Push_Status__c(cgcloud__Parent_Promotion__c =promotionList[0].Id,cgcloud__Status__c = 'InProgress' );
            insert pushPromotionRec;

            pushPromotionRec.cgcloud__Status__c = 'Error';
            update pushPromotionRec;

            List<Sobject> sobectList = new List<Sobject>();
            Map<Id, SObject> newMapParam = new  Map<Id, SObject>();
            Map<Id, SObject> oldMapParam = new  Map<Id, SObject>();
            TPM_PushPromotionStatusTriggerHandler tpmTriggerHandler = new TPM_PushPromotionStatusTriggerHandler();
            tpmTriggerHandler.bulkBefore();
            tpmTriggerHandler.bulkAfter();
            tpmTriggerHandler.beforeInsert(sobectList);
            tpmTriggerHandler.afterInsert(newMapParam);
            tpmTriggerHandler.beforeUpdate(newMapParam,oldMapParam);
            tpmTriggerHandler.afterDelete(oldMapParam);
            tpmTriggerHandler.afterUnDelete(sobectList);
            System.Assert(!promotionList.isEmpty(),false);
    
        }
}