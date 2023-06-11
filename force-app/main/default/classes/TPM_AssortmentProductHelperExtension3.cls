/*******************************************************************************************************
* @Name         : TPM_AssortmentProductHelperExtension3
* @Unit Test    : TPM_AssortmentProductTriggerTest
* @Author       : PwC Team
* @Date         : 06/03/2022
* @description  : Helper class for performing all business logics/ DML operations, for assortment product module
*******************************************************************************************************/
public inherited sharing class TPM_AssortmentProductHelperExtension3 {
    
    /***************************************************************************************************
@methodname 	TPM_AssortmentProductHelperExtension
@createdDate 	03/03/2022
@description	default private constructor
****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentProductHelperExtension3(){
        
    }
    
    /*********************************************************************************************************
	@methodname   	deleteAndHandlerErrorLogging
	@createdDate  	02/03/2022
	@param     	  	deleteIdSet
	@description  	delete the list of id, and logging the error in logger object 
	*********************************************************************************************************/
    
    public static void deleteAndHandlerErrorLogging(List<Id> deleteIdSet){
        
        List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
        Database.DeleteResult[] deleteResultList = database.delete(deleteIdSet,false);
        for (Database.DeleteResult deleteResultObj : deleteResultList) {
            if(!deleteResultObj.isSuccess()){
                TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                logWrapperObj.errors = deleteResultObj.getErrors();
                logWrapperObj.className=TPM_ConstantsUtility.TRIGGER_ASSORT_PROD_HELPER_EXTENSION2;
                logWrapperObj.methodName=TPM_ConstantsUtility.DELETE_ASSORTPROD_RECORDS;
                logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                exceptionWrapperList.add(logWrapperObj);
            }else{
                //boolean value used to avoid recursion for the remove assortment product functionality
                
                TPM_Utils.isBypassRemoveAssortProd=true;
            }
        }
        
        //Call the TPM_LoggerException class log method to save all the exception details during insert
        
        TPM_LoggerException.log(exceptionWrapperList);
    }
     
      /*********************************************************************************************************
	@methodname   	updateAndHandlerErrorLogging
	@createdDate  	02/06/2022
	@param     	  	assortmentProductListToUpdate
	@description  	update the list of assortment product, and logging the error in logger object 
	*********************************************************************************************************/
     public static void updateAndHandlerErrorLogging(List<AssortmentProduct> assortmentProductListToUpdate){
        
         List<TPM_LoggerException.LogsWrapper> exceptionWrapperList = new List<TPM_LoggerException.LogsWrapper>();
         
         Integer count = 0;
         
         Database.saveResult[] saveResultList = Database.update(assortmentProductListToUpdate,false);
         
         for (Database.saveResult saveResultListObj : saveResultList) {
             if(!saveResultListObj.isSuccess()){
                 TPM_LoggerException.LogsWrapper logWrapperObj = new TPM_LoggerException.LogsWrapper();
                 logWrapperObj.errors = saveResultListObj.getErrors();
                 logWrapperObj.guid = assortmentProductListToUpdate[count].id;
                 logWrapperObj.className=TPM_ConstantsUtility.TRIGGER_ASSORT_PROD_HELPER;
                 logWrapperObj.methodName=TPM_ConstantsUtility.UPDATE_ASSORTPROD_RECORDS;
                 logWrapperObj.logLevel=TPM_ConstantsUtility.ERROR;
                 exceptionWrapperList.add(logWrapperObj);
             }
             else{
                 //boolean value used to avoid recursion for the update assortment product functionality
                 
                 TPM_Utils.isBypassUpdateAssortProd=true;
             }
             
             count++;
         }
         
         TPM_LoggerException.log(exceptionWrapperList);
    }
    
    /*********************************************************************************************************
	@methodname   	prepareAssortmentProductToDeleteNext
	@createdDate  	03/03/2022
	@param     	  	wrapperObj
	@return         List<Id>
	@description  	prepare assortmentproduct recoords to be deleted from S and G level(to reduce complexity above method). 
	*********************************************************************************************************/
   @SuppressWarnings('PMD.CyclomaticComplexity')
    public static List<Id> prepareAssortmentProductToDeleteNext(TPM_AssortmentProductHelperExtension3.WrapAssortmentData wrapperObj){
        
         List<Id> assortProdIdsToDelete = new List<Id>();
                                                               
        for(Id childAccountId :wrapperObj.childAccountForParentMapNew.get(wrapperObj.parentIdNew)){
           
            //if this managed account is not the same for which the deletion happened.
            //because checking for the same managed account doesnt matter.
            if(childAccountId != wrapperObj.accountForAssortmentMapNew.get(wrapperObj.assortmentProdObjNew.AssortmentId)){
                 
                if(wrapperObj.assortmentForChildAccountNew.containsKey(childAccountId) 
                   && wrapperObj.assortmentProdForChildAccountNew.containsKey(string.valueof(wrapperObj.assortmentForChildAccountNew.get(childAccountId))+string.valueof(wrapperObj.assortmentProdObjNew.ProductId))){
                      
                       wrapperObj.isbreakForEntireHierarchyNew= true;
                       break;   
                       
                }else if(wrapperObj.assortmentForChildAccountNew.containsKey(childAccountId) 
                         && !wrapperObj.assortmentProdForChildAccountNew.containsKey(string.valueof(wrapperObj.assortmentForChildAccountNew.get(childAccountId))+string.valueof(wrapperObj.assortmentProdObjNew.ProductId))){
                    
                             assortProdIdsToDelete.add(wrapperObj.assortmentProdForChildAccountNew.get(string.valueof(wrapperObj.assortmentForChildAccountNew.get(wrapperObj.parentIdNew))+string.valueof(wrapperObj.assortmentProdObjNew.ProductId)).Id);       
                }else if(!wrapperObj.assortmentForChildAccountNew.containsKey(childAccountId)){
                    
                    assortProdIdsToDelete.add(wrapperObj.assortmentProdForChildAccountNew.get(string.valueof(wrapperObj.assortmentForChildAccountNew.get(wrapperObj.parentIdNew))+string.valueof(wrapperObj.assortmentProdObjNew.ProductId)).Id); 
                }
            }
            
            //if this child account does not have any assortment record for the deleted product then adding the parent account's 
            //assortment to delete.
            else if(childAccountId != wrapperObj.accountForAssortmentMapNew.get(wrapperObj.assortmentProdObjNew.AssortmentId) && (wrapperObj.assortmentForChildAccountNew.containsKey(childAccountId) 
                   && !wrapperObj.assortmentProdForChildAccountNew.containsKey(string.valueof(wrapperObj.assortmentForChildAccountNew.get(childAccountId))+string.valueof(wrapperObj.assortmentProdObjNew.ProductId)))){
                
                     assortProdIdsToDelete.add(wrapperObj.assortmentProdForChildAccountNew.get(string.valueof(wrapperObj.assortmentForChildAccountNew.get(wrapperObj.parentIdNew))+string.valueof(wrapperObj.assortmentProdObjNew.ProductId)).Id); 
            }
        }
            
                                                               
      return assortProdIdsToDelete;
    }
    
    /*********************************************************************************************************
    @methodname   	WrapAssortmentData
    @createdDate  	03/03/2023
    @param     	  	
    @description  	wrapper class to collect all assortment details for helper method to reduce complexity. 
    *********************************************************************************************************/ 

    public class WrapAssortmentData{
        
       
    public Map<Id,Set<Id>> childAccountForParentMapNew;
    
    public Id parentIdNew;
    
    public boolean isbreakForEntireHierarchyNew;
    
    public Map<Id, Id> accountForAssortmentMapNew;
    
    public AssortmentProduct assortmentProdObjNew;
                                    
    public Map<Id, Id> assortmentForChildAccountNew; 
    
    public Map<String, AssortmentProduct> assortmentProdForChildAccountNew;
        
    public AssortmentProduct oldAssortProdObjNew;
        
    public AssortmentProduct assortProdForParentNew;
        
    public Map<Id,Date> productForMaxDateMapNew;
        
    public Map<Id,Date> productForMinDateMapNew;
        
    public Map<Id,boolean> productForActiveMapNew;
        
    }
}