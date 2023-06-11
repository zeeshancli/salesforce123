/*******************************************************************************************************
* @Name         : TPM_AssortmentProductHelperExtension
* @Unit Test    : TPM_AssortmentProductTriggerTest
* @Author       : PwC Team
* @Date         : 01/03/2022
* @description  : Helper class for performing all business logics/ DML operations, for assortment product module
*******************************************************************************************************/
@SuppressWarnings('PMD.IdempotentOperations')
public inherited sharing class TPM_AssortmentProductHelperExtension1 {
    
    /***************************************************************************************************
	@methodname 	TPM_AssortmentProductHelperExtension
	@createdDate 	01/03/2022
	@description	default private constructor
	****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentProductHelperExtension1(){
        
    }
    
    
   
     /*********************************************************************************************************
	@methodname   	prepareAssortmentProduct
	@createdDate  	01/03/2022
	@param     	  	newMap
	@param     	  	accountForAssortmentMap
    @param     	  	relatedaccountWrapper
    @param     	  	assortmentForParentAccount
	@return         List<AssortmentProduct>
	@description  	prepare assortmentproduct recoords to be created at S and G level. 
	*********************************************************************************************************/
   
    public static List<AssortmentProduct> prepareAssortmentProduct(Map<Id, SObject> newMap,
                                                                  Map<Id, Id> accountForAssortmentMap,
                                                                  TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper,
                                                                  Map<Id, Id> assortmentForParentAccount){
        
        List<AssortmentProduct> assortmentProductListToUpsert = new List<AssortmentProduct>();
        TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamObj = new TPM_AssortmentProductHelperExtension4.WrapReqParamData();
                                                                      
         //optimization to reduce limit exception:starts
         //fetching assortmentProduct for parent account to check for existing data:
        
        reqParamObj.assortmentProdForParentAcc = TPM_AssortmentProductHelperExtension2.fetchAssortmentProdForParentAccount(assortmentForParentAccount.values());                                              
        reqParamObj.assortmentForParentAccount = assortmentForParentAccount;  
        reqParamObj.accountForAssortmentMap = accountForAssortmentMap;  
        reqParamObj.relatedaccountWrapper = relatedaccountWrapper;                                                             
        //fetching the assortmentProduct for any other managed account in the hierarchy 
        //to check the date of the product, if already existing
      
        List<Id> managedAccountInHierarchyList = new List<Id>();  
                                                                      
        for(Account childAccObj : [SELECT
                                  ID,
                                  PARENTID,
                                  TPM_Hierarchy_Level__c
                                  FROM Account
                                  WHERE PARENTID IN:relatedaccountWrapper.parentSet
                                  AND TPM_Hierarchy_Level__c = 'Managed Account' ORDER BY CREATEDDATE desc]){
                                     
                managedAccountInHierarchyList.add(childAccObj.Id);                  
         }
                                                                      
          //fetched all the products with max valid thru date in all the assortmentproducts of all the managed account in the hierarchy
                                                                      
        reqParamObj.productForMaxDateMap = TPM_AssortmentProductHelperExtension2.checkMaxDateThruForProduct(managedAccountInHierarchyList); 
                                                                      
         //fetched all the products with min valid from date in all the assortmentproducts of all the managed account in the hierarchy
                                                                      
        reqParamObj.productForMinDateMap = TPM_AssortmentProductHelperExtension2.checkMinDateFromForProduct(managedAccountInHierarchyList);                                                                 
                                                                      
        //iterating th newMap of the newly created assortmentProduct:                                                             
        for(AssortmentProduct assortmentProdObj : (List<AssortmentProduct>) newMap.Values()){
            
            //checking if the assortment was for managed account
            if(accountForAssortmentMap.containskey(assortmentProdObj.AssortmentId)){
                
                reqParamObj.assortmentProdObj = assortmentProdObj;
                //checking if the managed account has any parent accounts(G and SG)
                if(relatedaccountWrapper.managedAccountAndParentMap.containskey(accountForAssortmentMap.get(assortmentProdObj.AssortmentId))){
                    assortmentProductListToUpsert.addAll(prepareAssortmentProductNext(reqParamObj));
                }
            }
            
        }
        
        return assortmentProductListToUpsert;
    }
    
     
   /*********************************************************************************************************
	@methodname   	prepareAssortmentProductNext
	@createdDate  	03/03/2022
	@param     	  	reqParamObj
	@return         List<AssortmentProduct>
	@description  	processing to check the exisitng assortment product in an assortment for SG and G accounts
	*********************************************************************************************************/
	
    public static List<AssortmentProduct> prepareAssortmentProductNext(TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamObj){
                                                        
        List<AssortmentProduct> assortmentProductListToUpsert = new List<AssortmentProduct>();
                                                        
        for(Id parentAccountId : reqParamObj.relatedaccountWrapper.managedAccountAndParentMap.get(reqParamObj.accountForAssortmentMap.get(reqParamObj.assortmentProdObj.AssortmentId))){
            
            //checking if the product already exists in parent assortment:
            
            if(reqParamObj.assortmentProdForParentAcc.containskey(string.valueOf(reqParamObj.assortmentForParentAccount.get(parentAccountId)+string.valueOf(reqParamObj.assortmentProdObj.ProductId)))){
                
                AssortmentProduct existingAssortmentProduct = reqParamObj.assortmentProdForParentAcc.get(string.valueOf(reqParamObj.assortmentForParentAccount.get(parentAccountId)+string.valueOf(reqParamObj.assortmentProdObj.ProductId)));
                
                //checking if the existing assortment product record is deactivated and activating, if yes:
                
                checkForExistingAssortmentProdRec(existingAssortmentProduct, reqParamObj.assortmentProdObj);
                
                assortmentProductListToUpsert.add(existingAssortmentProduct); 
            }
            else{
                
                //creating new record in case existing record not found :
                
                AssortmentProduct assortProdObj = new AssortmentProduct(AssortmentId = reqParamObj.assortmentForParentAccount.get(parentAccountId),
                                                                        cgcloud__Active__c = reqParamObj.assortmentProdObj.cgcloud__Active__c,
                                                                        ProductId = reqParamObj.assortmentProdObj.ProductId,
                                                                        cgcloud__Valid_From__c = reqParamObj.assortmentProdObj.cgcloud__Valid_From__c,
                                                                        cgcloud__Valid_Thru__c = reqParamObj.assortmentProdObj.cgcloud__Valid_Thru__c);
                
                //checking if product is already present in any other managed account's assortment and picking up the max valid thru from them:
                
                if(reqParamObj.productForMaxDateMap.containskey(reqParamObj.assortmentProdObj.ProductId) && 
                   (reqParamObj.productForMaxDateMap.get(reqParamObj.assortmentProdObj.ProductId) >reqParamObj.assortmentProdObj.cgcloud__Valid_Thru__c)){
                    
                        assortProdObj.cgcloud__Valid_Thru__c = reqParamObj.productForMaxDateMap.get(reqParamObj.assortmentProdObj.ProductId);
                    
                }
                
                //checking if product is already present in any other managed account's assortment and picking up the min valid from from them:
                
                if(reqParamObj.productForMinDateMap.containskey(reqParamObj.assortmentProdObj.ProductId) 
                   && (reqParamObj.productForMinDateMap.get(reqParamObj.assortmentProdObj.ProductId) < reqParamObj.assortmentProdObj.cgcloud__Valid_From__c)){
                    
                        assortProdObj.cgcloud__Valid_From__c = reqParamObj.productForMinDateMap.get(reqParamObj.assortmentProdObj.ProductId);
                    
                }
                
                assortmentProductListToUpsert.add(assortProdObj);
            }
         }
                                                        
      return assortmentProductListToUpsert ;                                              
    }
    
     /*********************************************************************************************************
@methodname   	checkForExistingAssortmentProdRec
@createdDate  	03/03/2022
@param     	  	existingAssortmentProduct
@param     	  	assortmentProdObj
@description  	comparing the valid from and valid thru for an existing product in assortment
*********************************************************************************************************/

public static void checkForExistingAssortmentProdRec(AssortmentProduct existingAssortmentProduct, AssortmentProduct assortmentProdObj){
    
    //checking if the existing assortment product record is deactivated and activating, if yes:
                
                if(existingAssortmentProduct.cgcloud__Active__c != assortmentProdObj.cgcloud__Active__c && assortmentProdObj.cgcloud__Active__c){
                    
                    existingAssortmentProduct.cgcloud__Active__c = assortmentProdObj.cgcloud__Active__c;
                }
                
                //checking if the existing assortment product record valid thru is less than the new record:
                
                if(assortmentProdObj.cgcloud__Valid_Thru__c > existingAssortmentProduct.cgcloud__Valid_Thru__c){
                    
                    existingAssortmentProduct.cgcloud__Valid_Thru__c = assortmentProdObj.cgcloud__Valid_Thru__c;
                }
                
                //checking if the existing assortment product record valid from is greater than the new record:
                
                if(assortmentProdObj.cgcloud__Valid_From__c < existingAssortmentProduct.cgcloud__Valid_From__c){
                    existingAssortmentProduct.cgcloud__Valid_From__c = assortmentProdObj.cgcloud__Valid_From__c;
                }
}
    
    /*********************************************************************************************************
	@methodname   	prepareAssortmentProductToDelete
	@createdDate  	03/03/2022
	@param     	  	reqParamWrapperObj
	@return         List<Id>
	@description  	prepare assortmentproduct recoords to be deleted from S and G level. 
	*********************************************************************************************************/
    
    public static List<Id> prepareAssortmentProductToDelete(TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamWrapperObj){
          
         List<Id> assortProdIdsToDelete = new List<Id>();
                                                                               
        boolean breakForEntireHierarchy = false;
        //iterating the parent accounts:
                    
                    for(Id parentId :reqParamWrapperObj.relatedaccountWrapper.managedAccountAndParentMap.get(reqParamWrapperObj.accountForAssortmentMap.get(reqParamWrapperObj.assortmentProdObj.AssortmentId))){ 
                        
                        //checking if this parent has multiple child 
                        if(reqParamWrapperObj.childAccountForParentMap.containskey(parentId) && reqParamWrapperObj.childAccountForParentMap.get(parentId).size() > 1){
                            //iterating the multiple child to find if the deleted product is present in any other child of the hierarchy:
                                
                                TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj = new TPM_AssortmentProductHelperExtension3.WrapAssortmentData();
                                wrapperObj.childAccountForParentMapNew = reqParamWrapperObj.childAccountForParentMap;
                                wrapperObj.parentIdNew = parentId;
                                wrapperObj.isbreakForEntireHierarchyNew = breakForEntireHierarchy;
                                wrapperObj.accountForAssortmentMapNew = reqParamWrapperObj.accountForAssortmentMap;
                                wrapperObj.assortmentProdObjNew = reqParamWrapperObj.assortmentProdObj;
                                wrapperObj.assortmentForChildAccountNew = reqParamWrapperObj.assortmentForChildAccount;
                                wrapperObj.assortmentProdForChildAccountNew = reqParamWrapperObj.assortmentProdForChildAccount;
                                
                            assortProdIdsToDelete.addAll(TPM_AssortmentProductHelperExtension3.prepareAssortmentProductToDeleteNext(wrapperObj));
                            
                            
                            	breakForEntireHierarchy = wrapperObj.isbreakForEntireHierarchyNew;
                                
                                if(breakForEntireHierarchy){
                                    
                                    break;
                                }
                            
                        }else if(reqParamWrapperObj.childAccountForParentMap.containskey(parentId) && 
                                 reqParamWrapperObj.assortmentProdForChildAccount.containskey(string.valueof(reqParamWrapperObj.assortmentForChildAccount.get(parentId))+string.valueof(reqParamWrapperObj.assortmentProdObj.ProductId))){//incase there is only one child:
                            assortProdIdsToDelete.add(reqParamWrapperObj.assortmentProdForChildAccount.get(string.valueof(reqParamWrapperObj.assortmentForChildAccount.get(parentId))+string.valueof(reqParamWrapperObj.assortmentProdObj.ProductId)).Id);
                        }
                        
                    } 
                                                                               
           return  assortProdIdsToDelete;                                                                   
                                                                  
    }

    
    
    
    
    /*********************************************************************************************************
	@methodname   	prepareAssortmentProductToUpdate
	@createdDate  	03/03/2022
	@param     	  	reqParamWrapperObj
	@return         List<AssortmentProduct>
	@description  	prepare assortmentproduct recoords to be updated in S and G level. 
	*********************************************************************************************************/
   
    public static List<AssortmentProduct> prepareAssortmentProductToUpdate(TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamWrapperObj){
        
                                                           
         
         List<AssortmentProduct> assortmentProductListToUpdate = new List<AssortmentProduct>();
                                                           
        //iterating the parent accounts :
        for(Id parentId : reqParamWrapperObj.relatedaccountWrapper.managedAccountAndParentMap.get(reqParamWrapperObj.accountForAssortmentMap.get(reqParamWrapperObj.assortmentProdObj.AssortmentId))){
            
            AssortmentProduct oldAssortProdObj = (AssortmentProduct)reqParamWrapperObj.oldMap.get(reqParamWrapperObj.assortmentProdObj.Id);
            
            //checking if assortment for the account exist:
            
            if(reqParamWrapperObj.assortmentForAccountHierarchy.containskey(parentId)){
                
                //fetching assortment Product for parent and updating the changed field : 
                
                if(reqParamWrapperObj.assortmentProdForChildAccount.containskey(string.valueOf(reqParamWrapperObj.assortmentForAccountHierarchy.get(parentId)) + string.valueOf(reqParamWrapperObj.assortmentProdObj.ProductId))){
                    
                    AssortmentProduct assortProdForParent = reqParamWrapperObj.assortmentProdForChildAccount.get(string.valueOf(reqParamWrapperObj.assortmentForAccountHierarchy.get(parentId)) + string.valueOf(reqParamWrapperObj.assortmentProdObj.ProductId));
                    
                    TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj = new TPM_AssortmentProductHelperExtension3.WrapAssortmentData();
                    wrapperObj.assortmentProdObjNew = reqParamWrapperObj.assortmentProdObj;
                    wrapperObj.oldAssortProdObjNew = oldAssortProdObj;
                    wrapperObj.assortProdForParentNew = assortProdForParent;
                    wrapperObj.productForMaxDateMapNew = reqParamWrapperObj.productForMaxDateMap;
                    wrapperObj.productForMinDateMapNew = reqParamWrapperObj.productForMinDateMap;
                    wrapperObj.productForActiveMapNew = reqParamWrapperObj.productForActiveMap;
                   
                    assortmentProductListToUpdate.addAll(TPM_AssortmentProductHelperExtension2.prepareAssortmentProductToUpdateNext(wrapperObj));
                    
                }
            }
        }
                                                           
        return  assortmentProductListToUpdate;                                                  
        
    }
    
    /*********************************************************************************************************
	@methodname   	prepareAssortmentProductToUpdate
	@createdDate  	03/03/2022
	@param     	  	relatedIdList
	@param     	  	relatedaccountWrapper
    @return         List<AssortmentProduct>
	@description  	prepare assortmentproduct recoords to be updated in S and G level. 
	*********************************************************************************************************/
   
    public static TPM_AssortmentProductHelperExtension4.WrapReqParamData prepareMasterDataWrapperForUpdate(List<Id> relatedIdList, TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper){
        
        List<Id> managedAccountInHierarchyList = new List<Id>();
        Map<Id,Set<Id>> childAccountForParentMap = new Map<Id,Set<Id>>();
        TPM_AssortmentProductHelperExtension4.WrapReqParamData reqParamWrapperObj = new TPM_AssortmentProductHelperExtension4.WrapReqParamData();
        //optimizing to fix limit exception:
        //fetching all the assortment records for the related accounts in the hierarchy(SuperGroup, Group, Managed Account):
        //key = accountId, value = assortmentid
        
        reqParamWrapperObj.assortmentForAccountHierarchy = TPM_AssortmentProductHelperExtension2.fetchAssortmentForAccount(relatedIdList);
        
        //fetching all the assortment product records for the  assortments(for all the three level)
        //key = assortmentid+productid, value = assortmentproduct record
        
        reqParamWrapperObj.assortmentProdForChildAccount = TPM_AssortmentProductHelperExtension2.fetchAssortmentProdForParentAccount(reqParamWrapperObj.assortmentForAccountHierarchy.values());                                                 
        
        //fetching the assortmentProduct for any other managed account in the hierarchy 
        //to check the date of the product, if already existing
      
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
                                       
                                       if(childAccObj.TPM_Hierarchy_Level__c == 'Managed Account'){
                                           
                                           managedAccountInHierarchyList.add(childAccObj.Id);
                                       }
                                       
                                   }                                                   
                                                           
                                                           
        //fetched all the products with max valid thru date in all the assortmentproducts of all the managed account in the hierarchy
        
        reqParamWrapperObj.productForMaxDateMap = TPM_AssortmentProductHelperExtension2.checkMaxDateThruForProduct(managedAccountInHierarchyList); 
        
        //fetched all the products with min valid from date in all the assortmentproducts of all the managed account in the hierarchy
        
        reqParamWrapperObj.productForMinDateMap = TPM_AssortmentProductHelperExtension2.checkMinDateFromForProduct(managedAccountInHierarchyList);
        
        //fetched all the products with active = true in all the assortmentproducts of all the managed account in the hierarchy
        
        reqParamWrapperObj.productForActiveMap = TPM_AssortmentProductHelperExtension2.checkActiveForProduct(managedAccountInHierarchyList);
        
        return reqParamWrapperObj;

    }

    

}