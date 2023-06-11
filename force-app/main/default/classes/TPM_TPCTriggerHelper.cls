/******************************************************************************************************
* @Name         : TPM_TPCTriggerHelper
* @Test Class   : 
* @author       : PwC Team
* @date         : April 3, 2023
* @description  : 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public inherited sharing class TPM_TPCTriggerHelper {
    
    
    /*************************************************************************************
	* @method         : updateTPCConditions
	* @param            newTPCList
	* @description    : 
	**************************************************************************************/
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts')
    public static void updateTPCConditions(List<cgcloud__Tactic_Product_Condition__c> newTPCList){
        
        Set<Id> tacticIdSet =new Set<Id>();
        Map<Id, cgcloud__Tactic__c> tacticMap = new Map<Id, cgcloud__Tactic__c>();
        
        for(cgcloud__Tactic_Product_Condition__c tpcObj : newTPCList){
            tacticIdSet.add(tpcObj.cgcloud__Tactic__c);
        }
        
        if(!tacticIdSet.isEmpty()){
            for(cgcloud__Tactic__c tacticObj : [SELECT Id,
                                                cgcloud__Tactic_Template__r.TPM_Type__c, 
                                                cgcloud__Promotion__r.cgcloud__Promotion_Template__r.TPM_Type__c, 
                                                cgcloud__Sales_Org__c, 
                                                cgcloud__Compensation_Model__c, 
                                                cgcloud__Payment_Method__c 
                                                FROM cgcloud__Tactic__c
                                                WHERE Id IN :tacticIdSet]){
                                                    
                                                    if(!tacticMap.containsKey(tacticObj.Id)){
                                                        tacticMap.put(tacticObj.Id, tacticObj);
                                                    }
                                                }
        }
        
        if(!tacticMap.isEmpty()){
            
            // Fetch ZCode mapping.
            Map<String, TPM_ZCodeDefinition__mdt> zCodeMap = TPM_ZCodeDefinition__mdt.getAll();
            
            for(cgcloud__Tactic_Product_Condition__c tpcObj : newTPCList){
                if(tacticMap.containsKey(tpcObj.cgcloud__Tactic__c)){
                    
                    String zCodeMDTAPIName = TPM_TacticConditionUtils.fetchMatchingZMetadataAPI(tpcObj.cgcloud__Tactic__c, tacticMap, zCodeMap);
                    tpcObj.TPM_ZCode__c = String.isNotBlank(zCodeMDTAPIName) ? zCodeMap.get(zCodeMDTAPIName).TPM_ZCode__c : tpcObj.TPM_ZCode__c;
                    tpcObj.cgcloud__Measure_Code__c = String.isNotBlank(zCodeMDTAPIName) ? zCodeMap.get(zCodeMDTAPIName).TPM_Measure_Code__c : tpcObj.cgcloud__Measure_Code__c;
                    if(tpcObj.cgcloud__Status__c != 'Deleted'){
                        tpcObj.TPM_ConditionStatus__c = 'Active';
                    }else if(tpcObj.cgcloud__Status__c == 'Deleted'){
                        tpcObj.TPM_ConditionStatus__c = 'Delete';
                    }               
                }
            }
        }        
    }
    
    
    /*************************************************************************************
	* @method         : updateTPCStatusOnPaymentMethod
	* @param            newTPCList
	* @param            oldTPCMap
	* @description    : 
	**************************************************************************************/
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts, PMD.NcssMethodCount')
    public static void updateTPCStatusOnPaymentMethod(List<cgcloud__Tactic_Product_Condition__c> newTPCList, Map<Id, cgcloud__Tactic_Product_Condition__c> oldTPCMap){
        
        Set<Id> tacticIdSet =new Set<Id>();
        Map<Id, cgcloud__Tactic__c> tacticMap = new Map<Id, cgcloud__Tactic__c>();
        
        for(cgcloud__Tactic_Product_Condition__c tpcObj : newTPCList){
            if(tpcObj.cgcloud__Tactic__c != null){
                tacticIdSet.add(tpcObj.cgcloud__Tactic__c);
            }          
        }
        
        
        if(!tacticIdSet.isEmpty()){
            tacticMap = fetchTacticDetails(tacticIdSet);
        }
        
        if(!tacticMap.isEmpty()){
            
            // Fetch ZCode mapping.
            Map<String, TPM_ZCodeDefinition__mdt> zCodeMap = TPM_ZCodeDefinition__mdt.getAll();
            
            Map<String, TPM_CustomMappings__mdt> promoStatusMap = TPM_CustomMappings__mdt.getAll();
            Map<String, String> promoStatusWithTPCStatusMap = new Map<String, String>();
            
            for(TPM_CustomMappings__mdt statusData : promoStatusMap.values()){
                if(statusData.TPM_ProcessName__c == 'TPM_TPCTriggerHelper'){
                    if(!promoStatusWithTPCStatusMap.containsKey(statusData.TPM_Key__c)){
                        promoStatusWithTPCStatusMap.put(statusData.TPM_Key__c, statusData.TPM_Value__c);
                    }
                }
            }
            
            
            for(cgcloud__Tactic_Product_Condition__c tpcObj : newTPCList){
                if(tacticMap.containsKey(tpcObj.cgcloud__Tactic__c)){
                    String zCodeMDTAPIName = TPM_TacticConditionUtils.fetchMatchingZMetadataAPI(tpcObj.cgcloud__Tactic__c, tacticMap, zCodeMap);
                    
                    String tempZCode = String.isNotBlank(zCodeMDTAPIName) ? zCodeMap.get(zCodeMDTAPIName).TPM_ZCode__c : '';
                    if(tpcObj.TPM_ZCode__c != tempZCode){
                        tpcObj.TPM_ZCode__c = tempZCode;
                    }                 
                }
                   
                
                if(tpcObj.cgcloud__Status__c == 'Deleted' && tpcObj.cgcloud__Status__c != oldTPCMap.get(tpcObj.Id).cgcloud__Status__c 
                   && tacticMap.containsKey(tpcObj.cgcloud__Tactic__c) && tacticMap.get(tpcObj.cgcloud__Tactic__c).cgcloud__Payment_Method__c == 'Billback/Retrospective'){
                       tpcObj.TPM_ZCode__c = '';
                       tpcObj.TPM_ConditionStatus__c = 'Delete';
                }else if(tpcObj.cgcloud__Status__c == 'Deleted' && tpcObj.cgcloud__Status__c != oldTPCMap.get(tpcObj.Id).cgcloud__Status__c){
                       tpcObj.TPM_ConditionStatus__c = 'Delete';
					   } else if(tacticMap.containsKey(tpcObj.cgcloud__Tactic__c) && tpcObj.cgcloud__Status__c != oldTPCMap.get(tpcObj.Id).cgcloud__Status__c && tpcObj.cgcloud__Status__c != 'Deleted'){
                    String zCodeMDTAPIName = TPM_TacticConditionUtils.fetchMatchingZMetadataAPI(tpcObj.cgcloud__Tactic__c, tacticMap, zCodeMap);
                    tpcObj.TPM_ZCode__c = String.isNotBlank(zCodeMDTAPIName) ? zCodeMap.get(zCodeMDTAPIName).TPM_ZCode__c : tpcObj.TPM_ZCode__c;
                    tpcObj.cgcloud__Measure_Code__c = String.isNotBlank(zCodeMDTAPIName) ? zCodeMap.get(zCodeMDTAPIName).TPM_Measure_Code__c : tpcObj.cgcloud__Measure_Code__c;
                    if(promoStatusWithTPCStatusMap.containsKey(tacticMap.get(tpcObj.cgcloud__Tactic__c).cgcloud__Promotion__r.TPM_Phase__c)){
                        tpcObj.TPM_ConditionStatus__c = promoStatusWithTPCStatusMap.get(tacticMap.get(tpcObj.cgcloud__Tactic__c).cgcloud__Promotion__r.TPM_Phase__c);
                    }
                }                
            }
        }        
    }
    
    /*************************************************************************************
	* @method         : fetchTacticDetails
	* @param            tacticIdSet
	* @return           Map<Id, cgcloud__Tactic__c>
	* @description    : 
	**************************************************************************************/
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
    public static Map<Id, cgcloud__Tactic__c> fetchTacticDetails(Set<Id> tacticIdSet){
        
        Map<Id, cgcloud__Tactic__c> tacticIdMap = new Map<Id, cgcloud__Tactic__c>();
        
        for(cgcloud__Tactic__c tacticObj : [SELECT Id,
                                            cgcloud__Tactic_Template__r.TPM_Type__c, 
                                            cgcloud__Promotion__r.cgcloud__Promotion_Template__r.TPM_Type__c, 
                                            cgcloud__Promotion__r.TPM_Phase__c, 
                                            cgcloud__Sales_Org__c, 
                                            cgcloud__Compensation_Model__c, 
                                            cgcloud__Payment_Method__c 
                                            FROM cgcloud__Tactic__c
                                            WHERE Id IN :tacticIdSet]){
                                                
                                                if(!tacticIdMap.containsKey(tacticObj.Id)){
                                                    tacticIdMap.put(tacticObj.Id, tacticObj);
                                                }
                                            }
        
        return tacticIdMap;        
    }
    
}