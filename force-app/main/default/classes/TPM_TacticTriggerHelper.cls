/******************************************************************************************************
* @Name         : TPM_TacticTriggerHelper
* @Test Class   : 
* @author       : PwC Team
* @date         : April 3, 2023
* @description  : 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public inherited sharing class TPM_TacticTriggerHelper {
    
    
    /*************************************************************************************
	* @method         : updateMaintenanceOnTactic
	* @param            newTacticList
    * @param            oldTacticMap
	* @description    : 
	**************************************************************************************/
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts, PMD.CyclomaticComplexity')
    public static void updateMaintenanceOnTactic(List<cgcloud__Tactic__c> newTacticList, Map<Id, cgcloud__Tactic__c> oldTacticMap){
        
        if(Trigger.isInsert){
            for(cgcloud__Tactic__c tacticObj : newTacticList){
                if(tacticObj.RecordTypeId == TPM_TacticConditionUtils.TACTIC_PRICERED_RTID && tacticObj.cgcloud__Payment_Method__c == 'OI'){
                    tacticObj.cgcloud__Condition_Maintenance__c = 'upsert';
                }
            } 
        }
        
        if(Trigger.isUpdate){
            for(cgcloud__Tactic__c tacticObj : newTacticList){
                if(tacticObj.RecordTypeId == TPM_TacticConditionUtils.TACTIC_PRICERED_RTID 
                   && tacticObj.cgcloud__Payment_Method__c != oldTacticMap.get(tacticObj.Id).cgcloud__Payment_Method__c){
                       if(tacticObj.cgcloud__Payment_Method__c == 'OI'){
                           tacticObj.cgcloud__Condition_Maintenance__c = 'upsert';
                       } else if(tacticObj.cgcloud__Payment_Method__c == 'Billback/Retrospective'){
                           tacticObj.cgcloud__Condition_Maintenance__c = 'delete';
                       }
                   }
            }
        }
    }
    
    /*************************************************************************************
	* @method         : updateTCCDRecords
	* @param            newTacticList
    * @param            oldTacticMap
	* @description    : 
	**************************************************************************************/
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
    public static void updateTCCDRecords(List<cgcloud__Tactic__c> newTacticList, Map<Id, cgcloud__Tactic__c> oldTacticMap){    
        
        Set<Id> promoIdsSet = new Set<Id>();
        Map<Id, String> tacticIdConditionMap = new Map<Id, String>();
        Map<Id, String> promoIdWithTemplateNameMap = new Map<Id, String>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        List<String> pushChildTemplateList = new List<String>{'Child_LTA_IT01','Child_OtherPrograms_IT01','Child_ShortTermEvent_IT01','Child_VolumePush_IT01'};
            
        List<cgcloud__Tactic_Condition_Creation_Definition__c> tccdList = new List<cgcloud__Tactic_Condition_Creation_Definition__c>();
        
        for(cgcloud__Tactic__c tacticObj : newTacticList){
            promoIdsSet.add(tacticObj.cgcloud__Promotion__c);
        }
        
        for(cgcloud__Promotion__c promoObj : [SELECT Id, cgcloud__Promotion_Template__r.Name FROM cgcloud__Promotion__c WHERE Id IN :promoIdsSet]){
            
            if(!promoIdWithTemplateNameMap.containsKey(promoObj.Id)){
                promoIdWithTemplateNameMap.put(promoObj.Id, promoObj.cgcloud__Promotion_Template__r.Name);
            }
        }
        
        
        for(cgcloud__Tactic__c tacticObj : newTacticList){
            
            if(promoIdWithTemplateNameMap.containskey(tacticObj.cgcloud__Promotion__c)){
                if(pushChildTemplateList.contains(promoIdWithTemplateNameMap.get(tacticObj.cgcloud__Promotion__c)) 
               && tacticObj.RecordTypeId == TPM_TacticConditionUtils.TACTIC_PRICERED_RTID 
               && tacticObj.cgcloud__Payment_Method__c != oldTacticMap.get(tacticObj.Id).cgcloud__Payment_Method__c){
                   
                   if(!tacticIdConditionMap.containsKey(tacticObj.Id)){
                       tacticIdConditionMap.put(tacticObj.Id, tacticObj.cgcloud__Condition_Maintenance__c);
                   }
               }
            }
            
            
        }

        for(cgcloud__Tactic_Condition_Creation_Definition__c tccdObj : [SELECT Id, cgcloud__Maintenance__c, cgcloud__Tactic__c  FROM cgcloud__Tactic_Condition_Creation_Definition__c WHERE cgcloud__Tactic__c IN :tacticIdConditionMap.keyset()]){                                                                           
            if(tacticIdConditionMap.containskey(tccdObj.cgcloud__Tactic__c)){
                tccdObj.cgcloud__Maintenance__c = tacticIdConditionMap.get(tccdObj.cgcloud__Tactic__c);
                tccdList.add(tccdObj);
            }
        }

        if(!tccdList.isEmpty()){
            
            Integer count = 0;
            Database.saveResult[] saveResultList = Database.update(tccdList,false);
            
            for (Database.saveResult saveResultListObj : saveResultList) {
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = tccdList[count].id;
                    logWrapperObj.className='TPM_TacticTriggerHelper';
                    logWrapperObj.methodName='updateTCCDRecords';
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
            
                count++;
            }
            
            if(!exceptionWrapperList.isEmpty()){
                TPM_LoggerException.log(exceptionWrapperList);
            }
            
        }
    }
    
}