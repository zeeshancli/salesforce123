/******************************************************************************************************
@Name            TPM_AssortmentTriggerHelper
@testclass       TPM_AssortmentTriggerTest
@Author          PwC Team
@date            March 02, 2023
@description     Handles business logic for Assortment Trigger Handler 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing class TPM_AssortmentTriggerHelper {
    /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentTriggerHelper() { 
        
    }
    
    /********************************************************************************************************** 
	@methodname 	 preventModificationOfAssortment
	@param           newMap
	@param           oldMap
	@description	 method handles the process to prevent updation of assortment records for Business Admin
	***********************************************************************************************************/  
    public static void preventModificationOfAssortment(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){

        Map<Id, Assortment> assortmentOldMap = (Map<Id, Assortment>)oldMap;
        for(Assortment acc : (List<Assortment>)newMap.Values()){
            Assortment accOld = assortmentOldMap.get(acc.id);
           for(FieldSetMember fld :SObjectType.Assortment.FieldSets.TPM_Assortment.getFields()) {
               if(accOld.get(fld.getSObjectField()) != acc.get(fld.getSObjectField())){
                acc.addError(System.Label.TPM_Assortment_Error_Message);
               }
        }

        }


    }
        
    /********************************************************************************************************** 
	@methodname 	 preventDeletionOfAssortment
	@param           oldMap
	@description	 method handles the process to prevent Deletion of assortment records for Business Admin
	***********************************************************************************************************/  
    public static void preventDeletionOfAssortment(Map<Id,SObject> oldMap){
        for(Assortment acc : (List<Assortment>)oldMap.Values()){
           acc.addError(System.Label.TPM_Assortment_Error_Message_Delete);
    }
}
}