/******************************************************************************************************
@Name            TPM_PushPromotionStatusTriggerHelper
@testclass       TPM_PushPromotionStatusTriggerHelperTest
@Author          PwC Team
@date            January 27, 2023
@description     Handles business logic for Push Promotion status trigger helper
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.IdempotentOperations')
public inherited sharing class TPM_PushPromotionStatusTriggerHelper {
    
    public static List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();

    /***************************************************************************************************
    @description	default private constructor
    ****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_PushPromotionStatusTriggerHelper() {
        
    }
    // List to log errors/exceptions 
    /********************************************************************************************************** 
	@methodname 	 validateStatusOfPushPromotions
	@param           newMap
	@param           oldMap
	@description	 method to show users that push has failed
	***********************************************************************************************************/  
    public static void validateStatusOfPushPromotions(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        
        try{
            Map<String,String> parentPromoStatusMap = new Map<String,String>();
            List<cgcloud__Promotion__c> updateParentPromoList = new List<cgcloud__Promotion__c>();
            List<cgcloud__Promotion__c> updatePromoList = new List<cgcloud__Promotion__c>();
            List<cgcloud__Promotion__c> updateChildList = new List<cgcloud__Promotion__c>();
            List<String> parentPromoId = new List<String>();

            List<String> childParentPromoTemplate = TPM_Utils_Extension.getchildPromotemplateNames().templateForOverLapChecks;

           for(cgcloud__Promotion_Push_Status__c promoPush : (List<cgcloud__Promotion_Push_Status__c>) newMap.Values()){
            parentPromoStatusMap.put(promoPush.cgcloud__Parent_Promotion__c,promoPush.cgcloud__Status__c);
           }
             
           for(cgcloud__Promotion__c promotionObjFetched : [SELECT id,
                                                                    Name,
                                                                    cgcloud__Active__c,
                                                                    TPM_Phase__c,
                                                                    cgcloud__Promotion_Template__c,
                                                                    cgcloud__Promotion_Template__r.Name
                                                                    FROM cgcloud__Promotion__c
                                                                    WHERE Id IN :parentPromoStatusMap.keySet()]){

                if(childParentPromoTemplate.contains(promotionObjFetched.cgcloud__Promotion_Template__r.Name) && parentPromoStatusMap.get(promotionObjFetched.id) == TPM_ConstantsUtility.ERROR && promotionObjFetched.TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING){
                    
                    parentPromoId.add(promotionObjFetched.id);
                    cgcloud__Promotion__c updateRec = new cgcloud__Promotion__c();
                    updateRec.id = promotionObjFetched.id;
                    updateRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                    updateRec.TPM_Overlap_Check__c = 'Push Failed';
                    updateRec.cgcloud__Active__c = false;
                    updateRec.TPM_Overlap_Check_In_Progress__c = false;
                    updateRec.TPM_OverLap_Check_Status__c = ' ';
                    updateRec.TPM_Push_Failed__c = true;
                    updateParentPromoList.add(updateRec);
                    TPM_OverlapCheckQueableExt.publishEvent('Push Failed',promotionObjFetched.id);

                }
            }
            
            for(cgcloud__Promotion__c childPromo : [SELECT id,
                                                           Name,
                                                           cgcloud__Parent_Promotion__c
                                                           FROM cgcloud__Promotion__c
                                                           WHERE cgcloud__Parent_Promotion__c IN: parentPromoId]){
                cgcloud__Promotion__c updateChildRec = new cgcloud__Promotion__c();
                updateChildRec.id = childPromo.id;
                updateChildRec.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                updateChildRec.TPM_Overlap_Check__c = 'Push Failed';
                updateChildRec.cgcloud__Active__c = false;
                updateChildRec.TPM_Overlap_Check_In_Progress__c = false;
                updateChildRec.TPM_OverLap_Check_Status__c = ' ';
                updateChildRec.TPM_Push_Failed__c = true;
                updateChildList.add(updateChildRec);
         }
            
            updatePromoList.addAll(updateParentPromoList);
            updatePromoList.addAll(updateChildList);
            validateStatusOfPushPromotions(updatePromoList);

          
    }
        catch(Exception exp){
            TPM_PromotionTriggerHelperExtension.handleExceptions(exp);
        }
    }

    // List to log errors/exceptions 
    /********************************************************************************************************** 
	@methodname 	 updatePushPromotionStatusRecords
	@param           updatePromoList
	@description	 method to update records
	***********************************************************************************************************/ 
    public static void validateStatusOfPushPromotions(List<cgcloud__Promotion__c> updatePromoList){ 

    if(!updatePromoList.isEmpty()){
            
        Integer count = 0;
        
        Database.saveResult[] saveResultList = Database.update(updatePromoList,false);
        
        for (Database.saveResult saveResultListObj : saveResultList) {
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = updatePromoList[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.BATCH_ASSORTMENT_HELPER;
                    logWrapperObj.methodName=TPM_ConstantsUtility.UPDATE_ACCOUNT_RECORDS;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
        
                count++;
            }
        
            TPM_LoggerException.log(exceptionWrapperList);
                                                                                    
            }
        }

    }