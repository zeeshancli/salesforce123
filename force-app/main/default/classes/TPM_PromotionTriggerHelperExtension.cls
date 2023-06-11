/********************************************************************************************************** 
	@methodname 	 TPM_PromotionTriggerHelperExtension
	@description	 method handles the process to share all Promotions Records on insert/update related to account
					 with team members
	***********************************************************************************************************/  
    public inherited sharing class TPM_PromotionTriggerHelperExtension {
   
   
      /***************************************************************************************************
	@description	default private constructor
	****************************************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_PromotionTriggerHelperExtension() {
        
    }
    /*********************************************************************************
    @method          processOverLapCheck
	@param     	  	 newMap
	@param     	  	 oldMap
    @description     method to call overlap check queable class
    **********************************************************************************/
    public static void processOverLapCheck(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        // initializing log WrapperList 
        
        try{
            Map<Id, cgcloud__Promotion__c> promotionsOldMap = (Map<Id, cgcloud__Promotion__c>)oldMap;
            //Get parent promotion template for which we need to run overlap checks
            List<String> childParentPromoTemplate = TPM_Utils_Extension.getchildPromotemplateNames().templateForOverLapChecks;
            
            //Get promotion template of current recotd
            Map<id,cgcloud__Promotion__c> relatedTemplateList = new Map<id,cgcloud__Promotion__c>([
                                                                                                    SELECT id,
                                                                                                    cgcloud__Promotion_Template__c,
                                                                                                    cgcloud__Promotion_Template__r.Name
                                                                                                    FROM cgcloud__Promotion__c
                                                                                                    WHERE id IN:newMap.keySet()]);


            // iterating over newly created promotions records to prepare map to store promo ids and parentids
            for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)newMap.Values()){
                //if phase is planning and promotion template is there in parent promotion template map and push is completed then call
                //future method to run overlap checks
                    if((promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING  || promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_SUBMITFORAPPROVAL )
                        && (childParentPromoTemplate.contains(relatedTemplateList.get(promotionsObj.id).cgcloud__Promotion_Template__r.Name)
                        && (promotionsOldMap.get(promotionsObj.Id).cgcloud__Is_Push_In_Progress__c == true 
                        && promotionsObj.cgcloud__Is_Push_In_Progress__c == false))){
      
                            execOverLapCheck(promotionsObj.Id);
                    } 
                 } 
            }
        catch(Exception exp){
            handleExceptions(exp);
        }
    }

    /*********************************************************************************
    @method          handlePushPromotionUpdate
	@param     	  	 newMap
	@param     	  	 oldMap
    @description     method to update fields for push promotions
    **********************************************************************************/
    
    public static void handlePushPromotionUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        try{
            
            Map<Id, cgcloud__Promotion__c> promotionsOldMap = (Map<Id, cgcloud__Promotion__c>)oldMap;
            Map<id,cgcloud__Promotion__c> relatedTemplateList = new Map<id,cgcloud__Promotion__c>([
                                                                                                    SELECT id,
                                                                                                    cgcloud__Promotion_Template__c,
                                                                                                    cgcloud__Promotion_Template__r.Name
                                                                                                    FROM cgcloud__Promotion__c
                                                                                                    WHERE id IN:newMap.keySet()]);
            // iterating over newly updated promotions records to update cgcloud__Phase__c
            List<String> childParentPromoTemplate = TPM_Utils_Extension.getchildPromotemplateNames().templateForOverLapChecks;
            for(cgcloud__Promotion__c promotionsObj : (List<cgcloud__Promotion__c>)newMap.Values()){
                //if phase is planning and  push is initiated  then make these updated
                if(childParentPromoTemplate.contains(relatedTemplateList.get(promotionsObj.id).cgcloud__Promotion_Template__r.Name) 
                && (promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING ||  (promotionsObj.TPM_Phase__c == TPM_ConstantsUtility.PHASE_SUBMITFORAPPROVAL && promotionsOldMap.get(promotionsObj.Id).TPM_Phase__c == TPM_ConstantsUtility.PHASE_PLANNING ))
                &&  promotionsObj.cgcloud__Is_Push_In_Progress__c == true){

                    promotionsObj.TPM_Overlap_Check_In_Progress__c = true;
                    promotionsObj.TPM_Overlap_Check__c = TPM_ConstantsUtility.OVERLAPINPROGRESS;
                    promotionsObj.TPM_Push_Failed__c = false;
                  }
                }
        } catch(Exception exp){
            handleExceptions(exp);
        }
    }

     /*********************************************************************************
    @method          handleExceptions
	@param     	  	 exp
    @description     method to handle exceptions
    **********************************************************************************/
    
    public static void handleExceptions(Exception exp) {

        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>() ;
        TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
        logWrapperObj.exceptionObj = exp;
        logWrapperObj.logLevel = TPM_ConstantsUtility.FATAL;
        exceptionWrapperList.add(logWrapperObj);
        
        // Call the TPM_LoggerException class log method to save all the exception details during insert
        TPM_LoggerException.log(exceptionWrapperList);
    }

     /*********************************************************************************
    @method          execOverLapCheck
    @param     	  	 promotionRecId
    @description     method to call overlap check queable class
    **********************************************************************************/
    public static void execOverLapCheck(String promotionRecId){
            
        TPM_Utils_Extension.executeOverlapCheck(promotionRecId);
    
    }

    /********************************************************************************************************** 
    @methodname 	 handleFieldUpdateForAccount
    @param           newMap
    @description	 Method to make TPM_ProcessTPMCalculationChain__c as true for child Promotions
    ***********************************************************************************************************/ 
    public static void handleFieldUpdateForAccount(Map<Id, SObject> newMap){

        List<String> childPromotionTemplatesList = new List<String>();
        Set<String> accountIdSet = new Set<String>();
        List<Account> accountListToUpdate = new List<Account>();
        //Get child template names from Custom Label
        childPromotionTemplatesList = System.Label.TPM_Child_Promotion_Templates.split(',');
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        //Loop all the records and get promotion template names
        for(cgcloud__Promotion__c promotionObjFetched : [SELECT  Id,
                                                            Name,
                                                            cgcloud__Anchor_Account__c,
                                                            cgcloud__Promotion_Template__r.Name
                                                            From cgcloud__Promotion__c
                                                            WHERE Id IN :newMap.KeySet()]){
            //Collect all promotion ids for child promotion templates                                                  
                if(childPromotionTemplatesList.contains(promotionObjFetched.cgcloud__Promotion_Template__r.Name)){
                    accountIdSet.add(promotionObjFetched.cgcloud__Anchor_Account__c);
                    }
                                                                
            }
        
        //Get all accounts for child promotion templates and update calculation chain field to true.
        for(Account accountFetched : [SELECT id,
                                        TPM_ProcessTPMCalculationChain__c
                                        FROM Account
                                        WHERE id IN:accountIdSet
                                        AND TPM_ProcessTPMCalculationChain__c!=TRUE]){
                                            
                accountFetched.TPM_ProcessTPMCalculationChain__c = TRUE;
                accountListToUpdate.add(accountFetched);
                                            
        }
        
        if(!accountListToUpdate.isEmpty()){
            Integer count = 0;
            
            Database.SaveResult[] saveResultList =  Database.Update(accountListToUpdate,false);
            
            for(Database.SaveResult saveResultListObj : saveResultList){
                
                if(!saveResultListObj.isSuccess()){
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = saveResultListObj.getErrors();
                    logWrapperObj.guid = accountListToUpdate[count].id;
                    logWrapperObj.className=TPM_ConstantsUtility.TPM_PROMOTION_TRIGGER_HELPER_EXTENSION;
                    logWrapperObj.methodName=TPM_ConstantsUtility.HANDLEFIELDUPDATEFORACCOUNT;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    exceptionWrapperList.add(logWrapperObj);
                }
                
                count++;
            }
            
            
        }
        
        TPM_LoggerException.log(exceptionWrapperList);
        }
}