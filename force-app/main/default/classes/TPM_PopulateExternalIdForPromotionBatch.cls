/******************************************************************************************************
@Name            TPM_PopulateExternalIdForPromotionBatch
@testclass       TPM_PopulateExternalIdForPromotionTest
@Author          PwC Team
@date            May 19, 2023
@description     Batch apex to populate external id for child promotions and copied promotions.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public without sharing class TPM_PopulateExternalIdForPromotionBatch implements Database.Batchable<Sobject> {
    
    
    /**************************************************************************************
	* @method         : TPM_PopulateExternalIdForPromotionBatch
	* @description    : Constructor for the batch class
	**************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public TPM_PopulateExternalIdForPromotionBatch(){
        
    }
    
    /*********************************************************************************
	@method          start
	@param           bc
	@return          Database.QueryLocator
	@description     Batch start method to fetch all active accounts after they have been made active
	**********************************************************************************/
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = '';
        //Query promotions WHERE 
        //cgcloud__ExternalId__c = null
        // preparing batch query based on custommetadata record
        for (TPM_QueryDefinition__mdt queryDef : [SELECT Id, TPM_BaseQuery__c, TPM_QueryCondition__c FROM TPM_QueryDefinition__mdt 
                                                  WHERE TPM_ProcessName__c =: TPM_ConstantsUtility.BATCH_POPULATION_EXTERNALID]){
                                                      
                                                      if(String.isNotBlank(queryDef.TPM_BaseQuery__c)){
                                                          query = queryDef.TPM_BaseQuery__c;
                                                      }
                                                      if(String.isNotBlank(queryDef.TPM_QueryCondition__c)){
                                                          query = query + ' ' + queryDef.TPM_QueryCondition__c;
                                                      }
                                                  }
        
        return Database.getQueryLocator(query);
    }
    
     /********************************************************************************************************
	@method           execute
	@param            bc
	@param            promotionLst
	@description      Execute method to populate external id for child promotions and copied promotions.
	********************************************************************************************************/
    
    public void execute(Database.BatchableContext bc, List<cgcloud__promotion__c> promotionLst){
        
        
        List<cgcloud__promotion__c> promotionLstToUpdate = new List<cgcloud__promotion__c>();
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        //iterating all the promotions where external id is not populated
        for(cgcloud__promotion__c promotionObj : promotionLst){
            
            //checking the length of the name 
            if(promotionObj.Name.substringAfter('-').length() >= 9){
                promotionObj.cgcloud__externalid__c = 'P'+promotionObj.Name.substringAfter('-');
                promotionLstToUpdate.add(promotionObj);
            }
            else if(promotionObj.Name.substringAfter('-').length() == 8){
                promotionObj.cgcloud__externalid__c = 'P0'+promotionObj.Name.substringAfter('-');
                promotionLstToUpdate.add(promotionObj);
            }
        }
        
        //updating promotion records with external id
        if(!promotionLstToUpdate.isEmpty()){
            
            Integer count = 0;
            
            Database.saveResult[] saveResultList = Database.update(promotionLstToUpdate,false);
            
            for (Database.saveResult saveResultListObj : saveResultList) {
                
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = promotionLstToUpdate[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.BATCH_POPULATION_EXTERNALID;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
            
                count++;
            }
            
            //logging exceptions (if any)
            if(!exceptionWrapperList.isEmpty()){
               TPM_LoggerException.log(exceptionWrapperList); 
            }
            
        }
    }
    
        /************************************************************************************
	@method          finish
	@param           bc
	@description     Batch finish method to perform completion steps.
	*************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc){
        
    }

}