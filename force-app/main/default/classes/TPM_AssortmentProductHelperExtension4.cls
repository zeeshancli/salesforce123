/*******************************************************************************************************
* @Name         : TPM_AssortmentProductHelperExtension4
* @Unit Test    : TPM_AssortmentProductTriggerTest
* @Author       : PwC Team
* @Date         : 03/05/2023
* @description  : Helper class for performing all business logics/ DML operations, for assortment product module
*******************************************************************************************************/

public inherited sharing class TPM_AssortmentProductHelperExtension4 {
    
    /***************************************************************************************************
	@methodname 	TPM_AssortmentProductHelperExtension
	@createdDate 	01/03/2022
	@description	default private constructor
	****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentProductHelperExtension4(){
        
    }
    
      
 /*********************************************************************************************************
    @methodname   	WrapReqParamData
    @createdDate  	05/02/2023
    @param     	  	
    @description  	wrapper class to collect all assortment details for helper method to reduce complexity. 
    *********************************************************************************************************/ 
    public class WrapReqParamData{
          
        public TPM_AccountTeamHelper.WrapAccountData relatedaccountWrapper;
        
        public Map<Id, Id> accountForAssortmentMap;
        
        public AssortmentProduct assortmentProdObj;
        
        public Map<Id, Id> assortmentForParentAccount;
        
        public Map<String, AssortmentProduct> assortmentProdForParentAcc;
        
        public Map<Id,Date> productForMaxDateMap;
            
        public Map<Id,Date> productForMinDateMap;
        
        public Map<Id, SObject> oldMap;
        
         public Map<Id, Id> assortmentForAccountHierarchy;
        
        public Map<String, AssortmentProduct> assortmentProdForChildAccount;
        
        public Map<Id,boolean> productForActiveMap;
        
       public Map<Id,Set<Id>> childAccountForParentMap;
        
        public Map<Id, Id> assortmentForChildAccount;
        
       
    }
    

}