/*******************************************************************************************************
* @Name         : TPM_AssortmentProductTriggerHelper
* @Unit Test    : TPM_AssortmentProductTriggerTest
* @Author       : PwC Team
* @Date         : 01/03/2022
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
on creation/manipulation of the assortment product records.
*******************************************************************************************************/
@SuppressWarnings('PMD.IdempotentOperations')
public inherited sharing class TPM_AssortmentProductTriggerHelper {
    
    /***************************************************************************************************
	@methodname 	TPM_AccountTeamTriggerHelper
	@createdDate 	01/03/2022
	@description	default private constructor
	****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentProductTriggerHelper(){
        
    }
    
    
    /*********************************************************************************************************
	@methodname   	assignAssortmentProductForHierarchy
	@createdDate  	01/03/2022
	@param     	  	newMap
	@description  	after the insert of a assortment product for a managed account, we need to assign same products to assortment of hierarchy accounts. 
	*********************************************************************************************************/
    
    public static void assignAssortmentProductForHierarchy(Map<Id,Sobject> newMap){
        
        List<AssortmentProduct> assortmentProductListToUpsert = new List<AssortmentProduct>();
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        
        Set<Id> assortmentIdSet = new Set<Id>();
        //iterating newMap of the newly created assortmentProduct member records to fetch the assortment for which product has been assigned:
        
        for(AssortmentProduct assortmentProdObj : (List<AssortmentProduct>) newMap.Values()){
            assortmentIdSet.add(assortmentProdObj.AssortmentId);
        }
        
        //fetching all the managed accounts :
        //fetching all accounts for each assortment :
        //key = assortmentid, value = accountid(managed account)
        
        Map<Id, Id> accountForAssortmentMap = TPM_AssortmentProductHelperExtension2.fetchManagedAccountsForAssortment(assortmentIdSet);
        
        Set<Id> managedAccountIdSet = new Set<Id>(accountForAssortmentMap.values());
        
        //fetching all the parent Account details for the managedAccount
        
        TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper = TPM_AccountTeamHelper.createChildParentMapForManagedAccount(managedAccountIdSet);
        
        List<Id> parentIdList = new List<Id>();
        parentIdList.addAll(relatedaccountWrapper.parentSet);
        
        //fetching all the assortment records for the fetched parent accounts:
        //key = accountId(group/supergroup), value = assortmentid
        
        Map<Id, Id> assortmentForParentAccount = TPM_AssortmentProductHelperExtension2.fetchAssortmentForAccount(parentIdList);
        
        //iterating th newMap of the newly created assortmentProduct:
        
        assortmentProductListToUpsert.addAll(TPM_AssortmentProductHelperExtension1.prepareAssortmentProduct(newMap, accountForAssortmentMap, relatedaccountWrapper, assortmentForParentAccount));
        
        if(!assortmentProductListToUpsert.isEmpty()){
            Database.UpsertResult[] upsertResultList = database.upsert(assortmentProductListToUpsert,false);
            Integer index = 0;
            
            for (Database.UpsertResult upsertResultListObj : upsertResultList) {
                
                if(!upsertResultListObj.isSuccess()){
                    
                    TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                    logWrapperObj.errors = upsertResultListObj.getErrors();
                    logWrapperObj.className=TPM_ConstantsUtility.TRIGGER_ASSORT_PROD_HELPER;
                    logWrapperObj.methodName=TPM_ConstantsUtility.ASSIGN_ASSORTPROD_RECORDS;
                    logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                    logWrapperObj.guid=assortmentProductListToUpsert[index].AssortmentId;
                    exceptionWrapperList.add(logWrapperObj);
                }else{
                    
                    //boolean value used to avoid recursion for the assignment of the assortmentproduct
                    
                    TPM_Utils.isBypassAssignAssortProd=true;
                }
                index++;
            }
            
            
            //Call the TPM_LoggerException class log method to save all the exception details during insert
            
            if(!exceptionWrapperList.isEmpty()){
                TPM_LoggerException.log(exceptionWrapperList);
            }
            
        }
    }
    
    /*********************************************************************************************************
	@methodname   	removeAssortmentProdFromHierarchy
	@createdDate  	01/03/2022
	@param     	  	oldMap
	@description  	after the deletion of an assortment product for a managed account's assortment, we need to remove assortmentproduct for the entire account hierarchy's assortment. 
	*********************************************************************************************************/
    
    public static void removeAssortmentProdFromHierarchy(Map<Id,Sobject> oldMap){
        
        Set<Id> assortmentIdSet = new Set<Id>();
        List<Id> relatedIdList = new List<Id>(); 
        Map<Id,Set<Id>> childAccountForParentMap = new Map<Id,Set<Id>>();
        TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamWrapperObj = new TPM_AssortmentProductHelperExtension4.WrapReqParamData();
        
        List<Id> assortProdIdsToDelete = new List<Id>();
        
        //iterating newMap of the newly created assortmentProduct member records to fetch the assortment for which product has been assigned:
        
        for(AssortmentProduct assortmentProdObj : (List<AssortmentProduct>) oldMap.Values()){
            
            assortmentIdSet.add(assortmentProdObj.AssortmentId);
        }
        
        //fetching all the managed accounts :
        //fetching all accounts for each assortment , taken in above set :
        //key = assortmentid, value = accountid(managed account)
        
        Map<Id, Id> accountForAssortmentMap = TPM_AssortmentProductHelperExtension2.fetchManagedAccountsForAssortment(assortmentIdSet);
        
        Set<Id> managedAccountIdSet = new Set<Id>(accountForAssortmentMap.values());
        
        //fetching all the parent Account details for the managedAccount
        
        TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper = TPM_AccountTeamHelper.createChildParentMapForManagedAccount(managedAccountIdSet);
        
        
        //fetching all the assortment records for the fetched parent accounts:
        //key = accountId(group/supergroup), value = assortmentid
        List<Id> parentIdList = new List<Id>();
        parentIdList.addAll(relatedaccountWrapper.parentSet);
        
        
        for(Account childAccObj : [	SELECT
                                   ID,
                                   PARENTID,
                                   TPM_Hierarchy_Level__c
                                   FROM Account
                                   WHERE PARENTID IN:relatedaccountWrapper.parentSet ORDER BY CREATEDDATE desc]){
                                       if(!childAccountForParentMap.containskey(childAccObj.PARENTID)){
                                           childAccountForParentMap.put(childAccObj.PARENTID, new Set<Id>());
                                       }
                                       
                                       childAccountForParentMap.get(childAccObj.PARENTID).add(childAccObj.ID);
                                       relatedaccountWrapper.allRelatedSet.add(childAccObj.ID);
                                       
                                   }
        
         relatedIdList.addAll(relatedaccountWrapper.allRelatedSet);
        
         Map<Id, Id> assortmentForChildAccount = TPM_AssortmentProductHelperExtension2.fetchAssortmentForAccount(relatedIdList);
        
        //fetching all the assortment product records for the child assortments(for child managed accounts forthe super group and grouplevel)
        //key = assortmentid+productid, value = assortmentproduct record
       Map<String, AssortmentProduct> assortmentProdForChildAccount = TPM_AssortmentProductHelperExtension2.fetchAssortmentProdForParentAccount(assortmentForChildAccount.values());                                                                               
    
        reqParamWrapperObj.relatedaccountWrapper = relatedaccountWrapper;
        reqParamWrapperObj.childAccountForParentMap = childAccountForParentMap;
        reqParamWrapperObj.accountForAssortmentMap = accountForAssortmentMap;
        reqParamWrapperObj.assortmentForChildAccount =assortmentForChildAccount;
        reqParamWrapperObj.assortmentProdForChildAccount = assortmentProdForChildAccount;
        
        for(AssortmentProduct assortmentProdObj : (List<AssortmentProduct>) oldMap.Values()){
           
            reqParamWrapperObj.assortmentProdObj = assortmentProdObj;
            //checking if the assortment product has been added at managed account :
            //and if parent account exists for the managed account:
            
            if(accountForAssortmentMap.containskey(assortmentProdObj.AssortmentId) &&
              	relatedaccountWrapper.managedAccountAndParentMap.containskey(accountForAssortmentMap.get(assortmentProdObj.AssortmentId))){
                
                    assortProdIdsToDelete.addAll(TPM_AssortmentProductHelperExtension1.prepareAssortmentProductToDelete(reqParamWrapperObj));
            }
            
        }
    
    
        if(!assortProdIdsToDelete.isEmpty()){
            TPM_AssortmentProductHelperExtension3.deleteAndHandlerErrorLogging(assortProdIdsToDelete);
        }
    
    }
    
    /*********************************************************************************************************
	@methodname   	updateAssortmentProdFromHierarchy
	@createdDate  	04/03/2022
	@param     	  	newMap
	@param     	  	oldMap
	@description  	after the update of an assortment product for a managed account's assortment, we need to update assortmentproduct for the entire account hierarchy's assortment. 
	*********************************************************************************************************/
    
    public static void updateAssortmentProdFromHierarchy(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        Set<Id> assortmentIdSet = new Set<Id>();
        List<Id> relatedIdList = new List<Id>();
        List<AssortmentProduct> assortmentProductListToUpdate = new List<AssortmentProduct>();
        
        //iterating the updated assortment product records of managed account's assortment
        for(AssortmentProduct assortmentProdObj : (List<AssortmentProduct>) newMap.Values()){
            
            AssortmentProduct oldAssortProdObj = (AssortmentProduct)oldMap.get(assortmentProdObj.Id);
            
            //checking if active, valid from and valid thru fields have been changed:
            if((assortmentProdObj.cgcloud__Active__c != oldAssortProdObj.cgcloud__Active__c) || 
               (assortmentProdObj.cgcloud__Valid_From__c != oldAssortProdObj.cgcloud__Valid_From__c) ||
               (assortmentProdObj.cgcloud__Valid_Thru__c != oldAssortProdObj.cgcloud__Valid_Thru__c)){
                   
                   assortmentIdSet.add(assortmentProdObj.AssortmentId);
               }
        }
        
        //fetching all the managed accounts :
        //fetching all accounts for each assortment , taken in above set :
        //key = assortmentid, value = accountid(managed account)
        
        Map<Id, Id> accountForAssortmentMap = TPM_AssortmentProductHelperExtension2.fetchManagedAccountsForAssortment(assortmentIdSet);
        
        Set<Id> managedAccountIdSet = new Set<Id>(accountForAssortmentMap.values());
        
        //fetching all the parent Account details for the managedAccount
        
        TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper = TPM_AccountTeamHelper.createChildParentMapForManagedAccount(managedAccountIdSet);
        
        relatedIdList.addAll(relatedaccountWrapper.allRelatedSet);  
                
        TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamWrapperObj = TPM_AssortmentProductHelperExtension1.prepareMasterDataWrapperForUpdate(relatedIdList, relatedaccountWrapper);
        reqParamWrapperObj.relatedaccountWrapper =  relatedaccountWrapper;
        reqParamWrapperObj.oldMap = oldMap;
        reqParamWrapperObj.accountForAssortmentMap = accountForAssortmentMap;
        //iterating the updated assortment product records of managed account's assortment
        
        for(AssortmentProduct assortmentProdObj : (List<AssortmentProduct>) newMap.Values()){
            
           reqParamWrapperObj.assortmentProdObj = assortmentProdObj;
            //checking if this assortment is at a managed account level and reuired fields have been changed :
            
            if(accountForAssortmentMap.containskey(assortmentProdObj.AssortmentId)){
                
                //checking if the managed account has any parent accounts(G and SG)
                if(relatedaccountWrapper.managedAccountAndParentMap.containskey(accountForAssortmentMap.get(assortmentProdObj.AssortmentId))){
                    
                 assortmentProductListToUpdate.addAll(TPM_AssortmentProductHelperExtension1.prepareAssortmentProductToUpdate(reqParamWrapperObj));
                }
            }
            
            
        }
        
        if(!assortmentProductListToUpdate.isEmpty()){
            TPM_AssortmentProductHelperExtension3.updateAndHandlerErrorLogging(assortmentProductListToUpdate);
        }
     }
    
}