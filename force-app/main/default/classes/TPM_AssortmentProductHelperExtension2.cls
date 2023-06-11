/*******************************************************************************************************
* @Name         : TPM_AssortmentProductHelperExtension2
* @Unit Test    : TPM_AssortmentProductTriggerTest
* @Author       : PwC Team
* @Date         : 03/03/2022
* @description  : Helper class for performing all business logics/ DML operations, for assortment product module
*******************************************************************************************************/
@SuppressWarnings('PMD.IdempotentOperations')
public inherited sharing class TPM_AssortmentProductHelperExtension2 {
    
    /***************************************************************************************************
	@methodname 	TPM_AssortmentProductHelperExtension
	@createdDate 	03/03/2022
	@description	default private constructor
	****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentProductHelperExtension2(){
        
    }
    
    /*********************************************************************************************************
	@methodname   	fetchManagedAccountsForAssortment
	@createdDate  	01/03/2022
	@param     	  	assortmentIdSet
	@return         managedAccountIdSet
	@description  	fetch all the accounts for set of assortments. 
	*********************************************************************************************************/
    
    public static Map<Id, Id> fetchManagedAccountsForAssortment(Set<Id> assortmentIdSet){
        
        Map<Id, Id> accountForAssortmentMap = new Map<Id, Id>();
        List<String> salesOrgList = new List<String>();
        
        for(TPM_SalesOrg_For_Assorment_Product__mdt metadataObj : TPM_SalesOrg_For_Assorment_Product__mdt.getAll().values()){
            salesOrgList.add(metadataObj.TPM_Sales_Org__c);
        }
        
        for(StoreAssortment storeAssortmentObj : [SELECT
                                                 Id,
                                                 AccountId,
                                                 AssortmentId,
                                                 Account.cgcloud__Sales_Org__c
                                                 FROM StoreAssortment
                                                 WHERE AssortmentId IN :assortmentIdSet
                                                 AND Account.TPM_Hierarchy_Level__c =: TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT]){//ACCOUNT.cgcloud__Sales_Org__c IN: System.Label.TPM_SalesOrg_for_Assortment_Automation
             
               String salesOrgVal = string.valueof(storeAssortmentObj.Account.cgcloud__Sales_Org__c);                                      
                                                     
              if(salesOrgList.contains(salesOrgVal)){
                  
                  accountForAssortmentMap.put(storeAssortmentObj.AssortmentId, storeAssortmentObj.AccountId);
              }
            
       }
        
        return accountForAssortmentMap;
        
    }
   
     /*********************************************************************************************************
	@methodname   	fetchAssortmentForParentAccount
	@createdDate  	01/03/2022
	@param     	  	accountIdSet
	@return         assortmentForParentAccount
	@description  	fetch all the assortment details for set of account. 
	*********************************************************************************************************/
    
    public static Map<Id, Id> fetchAssortmentForAccount(List<Id> accountIdSet){
        
        Map<Id, Id> assortmentForParentAccount = new Map<Id, Id>();
        for(StoreAssortment storeAssortmentObj : [SELECT
                                                  Id,
                                                  AccountId,
                                                  AssortmentId
                                                  FROM StoreAssortment
                                                  WHERE AccountId IN :accountIdSet]){
                                                      
           assortmentForParentAccount.put(storeAssortmentObj.AccountId, storeAssortmentObj.AssortmentId);                                            
        }
        
        return assortmentForParentAccount;
        
        
    }
    /*********************************************************************************************************
@methodname   	checkMinDateFromForProduct
@createdDate  	03/03/2022
@param     	  	managedAccountInHierarchySet
@return         Map<Id,Date>
@description  	checking the minimum date from value from the existing assortment product records in a hierarchy
*********************************************************************************************************/

public static Map<Id,Date> checkMinDateFromForProduct(List<Id> managedAccountInHierarchySet){
    
     Map<Id, Id> assortmentRecordsMap = fetchAssortmentForAccount(managedAccountInHierarchySet);
    Map<Id,Date> productForMinDateMap = new Map<Id,Date>();
   for(AssortmentProduct assortProductObj : [SELECT 
                                            ID,
                                            ProductId,
                                            cgcloud__Valid_From__c
                                            FROM
                                            AssortmentProduct
                                             WHERE AssortmentId IN :assortmentRecordsMap.values()]){
                                                 
       if(!productForMinDateMap.containsKey(assortProductObj.ProductId)){
        productForMinDateMap.put(assortProductObj.ProductId,assortProductObj.cgcloud__Valid_From__c);
    }
    else{
        if(assortProductObj.cgcloud__Valid_From__c < productForMinDateMap.get(assortProductObj.ProductId)){
            productForMinDateMap.put(assortProductObj.ProductId,assortProductObj.cgcloud__Valid_From__c);
        }
    }                                          
                                                 
   }
    
   return productForMinDateMap;
}
    
    /*********************************************************************************************************
@methodname   	checkMaxDateThruForProduct
@createdDate  	03/03/2022
@param     	  	managedAccountInHierarchySet
@return         Map<Id,Date>
@description  	checking the minimum date from value from the existing assortment product records in a hierarchy
*********************************************************************************************************/

public static Map<Id,Date> checkMaxDateThruForProduct(List<Id> managedAccountInHierarchySet){
    
     Map<Id, Id> assortmentRecordsMap = fetchAssortmentForAccount(managedAccountInHierarchySet);
    Map<Id,Date> productForMaxDateMap = new Map<Id,Date>();
   for(AssortmentProduct assortProductObj : [SELECT 
                                            ID,
                                            ProductId,
                                            cgcloud__Valid_Thru__c
                                            FROM
                                            AssortmentProduct
                                             WHERE AssortmentId IN :assortmentRecordsMap.values()]){
            
         if(!productForMaxDateMap.containsKey(assortProductObj.ProductId)){
             
             productForMaxDateMap.put(assortProductObj.ProductId,assortProductObj.cgcloud__Valid_Thru__c);
         }else{
             
             if(assortProductObj.cgcloud__Valid_Thru__c > productForMaxDateMap.get(assortProductObj.ProductId)){
                 
              productForMaxDateMap.put(assortProductObj.ProductId,assortProductObj.cgcloud__Valid_Thru__c);
          }
    }                                    
                                                 
   }
    
   return productForMaxDateMap;
}
    
    
    /*********************************************************************************************************
@methodname   	checkActiveForProduct
@createdDate  	06/03/2022
@param     	  	managedAccountInHierarchySet
@return         Map<Id,boolean>
@description  	checking the active flag existing assortment product records in a hierarchy
*********************************************************************************************************/

public static Map<Id,boolean> checkActiveForProduct(List<Id> managedAccountInHierarchySet){
    
     Map<Id, Id> assortmentRecordsMap = fetchAssortmentForAccount(managedAccountInHierarchySet);
    Map<Id,boolean> productForActiveMap = new Map<Id,boolean>();
   for(AssortmentProduct assortProductObj : [SELECT 
                                             ID,
                                             ProductId,
                                             cgcloud__Active__c
                                             FROM
                                             AssortmentProduct
                                             WHERE AssortmentId IN :assortmentRecordsMap.values()]){
            
         if(!productForActiveMap.containsKey(assortProductObj.ProductId)){
             if(assortProductObj.cgcloud__Active__c){
                 productForActiveMap.put(assortProductObj.ProductId,assortProductObj.cgcloud__Active__c);
                 
             }
         }else{
             
             if(assortProductObj.cgcloud__Active__c != productForActiveMap.get(assortProductObj.ProductId) ){
                 
              productForActiveMap.put(assortProductObj.ProductId,assortProductObj.cgcloud__Active__c);
          }
    }                                    
                                                 
   }
    
   return productForActiveMap;
}

   	/*********************************************************************************************************
	@methodname   	prepareAssortmentProductToUpdateNext
	@createdDate  	03/06/2022
	@param     	  	wrapperObj
	@return         List<AssortmentProduct>
	@description  	prepare assortmentproduct recoords to be updated in S and G level.(to reduce complexity for calling method) 
	*********************************************************************************************************/
    
    public static List<AssortmentProduct> prepareAssortmentProductToUpdateNext(TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj){
        
         List<AssortmentProduct> assortmentProductListToUpdate = new List<AssortmentProduct>();                                                                           
                                                                                  
                                                                                  
       //processing if the active field has been changed:
        if(wrapperObj.assortmentProdObjNew.cgcloud__Active__c != wrapperObj.oldAssortProdObjNew.cgcloud__Active__c ){
            
            conditionCheckForActiveAssortProd(wrapperObj);
            
        }
        
        //processing if the valid from field has been changed:
        
        if(wrapperObj.assortmentProdObjNew.cgcloud__Valid_From__c != wrapperObj.oldAssortProdObjNew.cgcloud__Valid_From__c ){
            //checking if product is already present in any other managed account's assortment and picking up the min valid from from them:
            
            conditionCheckForDateFromAssortProd(wrapperObj);
           
        }
        
        //processing if the valid thru field has been changed:
        
        if(wrapperObj.assortmentProdObjNew.cgcloud__Valid_Thru__c != wrapperObj.oldAssortProdObjNew.cgcloud__Valid_Thru__c ){
            
            //checking if product is already present in any other managed account's assortment and picking up the max valid thru from them:
            
            
            conditionCheckForDateThruAssortProd(wrapperObj);
            
        }
      assortmentProductListToUpdate.add(wrapperObj.assortProdForParentNew); 
        
      return   assortmentProductListToUpdate;                                                                          
                                                                                  
    }
    
    
   /*********************************************************************************************************
	@methodname   	conditionCheckForActiveAssortProd
	@createdDate  	03/06/2022
	@param     	  	wrapperObj
	@description  	prepare assortmentproduct recoords to be updated in S and G level.(to reduce complexity for calling method) 
	*********************************************************************************************************/
    
    public static void conditionCheckForActiveAssortProd(TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj){
        
        if(wrapperObj.productForActiveMapNew.containskey(wrapperObj.assortmentProdObjNew.ProductId) && !wrapperObj.assortmentProdObjNew.cgcloud__Active__c){
                
                wrapperObj.assortProdForParentNew.cgcloud__Active__c = true;
            }
            else{
                
                wrapperObj.assortProdForParentNew.cgcloud__Active__c = wrapperObj.assortmentProdObjNew.cgcloud__Active__c;
            }
            
    }
    
    
    /*********************************************************************************************************
	@methodname   	conditionCheckForDateThruAssortProd
	@createdDate  	03/06/2022
	@param     	  	wrapperObj
	@description  	prepare assortmentproduct recoords to be updated in S and G level.(to reduce complexity for calling method) 
	*********************************************************************************************************/
   
    public static void conditionCheckForDateThruAssortProd(TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj){
        
        if(wrapperObj.productForMaxDateMapNew.containskey(wrapperObj.assortmentProdObjNew.ProductId) && 
               (wrapperObj.productForMaxDateMapNew.get(wrapperObj.assortmentProdObjNew.ProductId) >wrapperObj.assortmentProdObjNew.cgcloud__Valid_Thru__c)){
                   
                   wrapperObj.assortProdForParentNew.cgcloud__Valid_Thru__c = wrapperObj.productForMaxDateMapNew.get(wrapperObj.assortmentProdObjNew.ProductId);
                   
                   
                   
               }
            else{
                 wrapperObj.assortProdForParentNew.cgcloud__Valid_Thru__c = wrapperObj.assortmentProdObjNew.cgcloud__Valid_Thru__c;
            }
            
    }
    
    /*********************************************************************************************************
	@methodname   	conditionCheckForDateFromAssortProd
	@createdDate  	03/06/2022
	@param     	  	wrapperObj
	@description  	prepare assortmentproduct recoords to be updated in S and G level.(to reduce complexity for calling method) 
	*********************************************************************************************************/
   
	public static void conditionCheckForDateFromAssortProd(TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj){
        
        if(wrapperObj.productForMinDateMapNew.containskey(wrapperObj.assortmentProdObjNew.ProductId) 
               && (wrapperObj.productForMinDateMapNew.get(wrapperObj.assortmentProdObjNew.ProductId) < wrapperObj.assortmentProdObjNew.cgcloud__Valid_From__c)){
                   
                   wrapperObj.assortProdForParentNew.cgcloud__Valid_From__c = wrapperObj.productForMinDateMapNew.get( wrapperObj.assortmentProdObjNew.ProductId);
                   
                   
               }
            else{
                wrapperObj.assortProdForParentNew.cgcloud__Valid_From__c = wrapperObj.assortmentProdObjNew.cgcloud__Valid_From__c;
            }
            
    }
    
    
    /*********************************************************************************************************
	@methodname   	fetchAssortmentProdForParentAccount
	@createdDate  	02/03/2022
	@param     	  	parentAssortmentIdList
	@return         assortmentForParentAccount
	@description  	fetch all the assortment products details for assortments of SuperGroup and Group level
	*********************************************************************************************************/
    
    public static Map<String, AssortmentProduct> fetchAssortmentProdForParentAccount(List<Id> parentAssortmentIdList){
        
        Map<String, AssortmentProduct> assortmentProdForParentAccount = new Map<String, AssortmentProduct>();
        for(AssortmentProduct assortmentProd : [SELECT
                                                Id,
                                                AssortmentId,
                                                ProductId,
                                                cgcloud__Active__c,
                                                cgcloud__Valid_Thru__c,
                                                cgcloud__Valid_From__c
                                                FROM AssortmentProduct
                                                WHERE AssortmentId IN :parentAssortmentIdList]){
                                                      
           assortmentProdForParentAccount.put(string.valueof(assortmentProd.AssortmentId)+string.valueof(assortmentProd.ProductId), assortmentProd);                                            
        }
        
        return assortmentProdForParentAccount;
        
        
    }

   
    
}