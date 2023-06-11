/******************************************************************************************************
* @Name         : TPM_TCCDTriggerHelper
* @Test Class   : 
* @author       : PwC Team
* @date         : April 3, 2023
* @description  : 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_TCCDTriggerHelper {
    
    
    /*************************************************************************************
	* @method         : updateMaintenanceOnTCCD
	* @param            newTCCDList
	* @param            oldTCCDMap
	* @description    : 
	**************************************************************************************/
    public static void updateMaintenanceOnTCCD(List<cgcloud__Tactic_Condition_Creation_Definition__c> newTCCDList, Map<Id, cgcloud__Tactic_Condition_Creation_Definition__c> oldTCCDMap){
        
        Set<Id> tacticIdSet = new Set<Id>();
        
        for(cgcloud__Tactic_Condition_Creation_Definition__c tccdObj : newTCCDList){
            tacticIdSet.add(tccdObj.cgcloud__Tactic__c);
        }
        
        Map<ID, cgcloud__Tactic__c> tacticIdMap = new Map<ID, cgcloud__Tactic__c>([SELECT Id, Name, cgcloud__Condition_Maintenance__c, cgcloud__Payment_Method__c FROM cgcloud__Tactic__c WHERE Id IN :tacticIdSet]);
        
        for(cgcloud__Tactic_Condition_Creation_Definition__c tccdObj : newTCCDList){
            if(tacticIdMap.containsKey(tccdObj.cgcloud__Tactic__c)){
                tccdObj.cgcloud__Maintenance__c = tacticIdMap.get(tccdObj.cgcloud__Tactic__c).cgcloud__Condition_Maintenance__c;
            }
        }         
    }
    
}