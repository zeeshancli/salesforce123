/******************************************************************************************************
@Name            TPM_AssortmentCreationHelperExtension
@testclass       TPM_AssortmentCreationBatchTest
@Author          PwC Team
@date            February 7, 2023
@description     Batch Apex helper class for  TPM_AssortmentCreationBatch business logic.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public inherited sharing  class TPM_AssortmentCreationHelperExtension {

    /*********************************************************************************
     @description    private Constructor
    **********************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AssortmentCreationHelperExtension(){
        
    }
    
    
    /*********************************************************************************
    @method          handleInsertSuccessAssortment
    @param     	  	objectName
	@param     	  	recordsToInsert
    @param     	  	count
    @param     	  	accountIdSet
    @description     method preparing map for sales org and hierarchy levels enabled for push promotion
    **********************************************************************************/
    
    public static void handleInsertSuccessAssortment(String objectName, List<sObject> recordsToInsert, Integer count, Set<Id> accountIdSet){
        
        if(objectName == TPM_ConstantsUtility.OBJECT_ASSORTMENT){
                    
                    //marking flag to true in case assortments get created, so that product category records can be prepared and inserted:
                    TPM_Utils.isSuccessAssortment = true;
                    
                }else if(objectName == TPM_ConstantsUtility.PROD_ASSORTMENT_CATEGORY){
                    
                    //preparing a map to store the information whether product assortment category records got created for a particular assortment:
                    List<cgcloud__Product_Assortment_Product_Share__c> productCategoryList = (List<cgcloud__Product_Assortment_Product_Share__c>)recordsToInsert;
                    
                    TPM_Utils.mapForCategoryAssortment.put(productCategoryList[count].cgcloud__Product_Assortment__c,true);
                    
                    //marking flag to true in case product assortments get created, so that store assortments records can be prepared and inserted:
                    TPM_Utils.isSuccessProductAssortment = true;
                    
                    
                }
                else if(objectName == TPM_ConstantsUtility.STORE_ASSORTMENT){
                    
                    //marking flag to true in case product assortments get created, so that account records is updated:
                    //field TPM_Is_Assortment_Created__c is marked true when once store assortment is created:
                    List<StoreAssortment> storeAssortmentList = (List<StoreAssortment>)recordsToInsert;
                    TPM_Utils.accountIdSet.add(storeAssortmentList[count].AccountId);
                    
                }
    }
    
     
     /*********************************************************************************
    @method          handleInsertStoreAssortment
    @param     	  	storeAssortmentToCreateList
	@param     	  	logWrapperList
    @description     method to handle inserting store assortment objects
    **********************************************************************************/
    
    public static void handleInsertStoreAssortment(List<StoreAssortment> storeAssortmentToCreateList, List<TPM_LoggerException.LogsWrapper> logWrapperList ){
        if(!storeAssortmentToCreateList.isEmpty()){
            String objectName = TPM_ConstantsUtility.STORE_ASSORTMENT;
            logWrapperList.addAll(TPM_AssortmentCreationHelper.insertingAndLoggingError(storeAssortmentToCreateList,ObjectName,null));
        }
    }
    
    /*********************************************************************************
    @method          handlInsertForCategoryAssortmentHeaders
	@return 		List<TPM_LoggerException.LogsWrapper>
    @param     	  	accountToSalesOrgMap
	@param     	  	accountid
    @param     	  	assortmentObj
    @param     	  	topNodeForSalesOrgMap
    @description     method to handle inserting related assortment objects
    **********************************************************************************/
    public static List<cgcloud__Product_Assortment_Product_Share__c> prepareForCategoryAssortmentHeaders(Map<Id,String> accountToSalesOrgMap, 
                                                                                                             Id accountid, Assortment assortmentObj, 
                                                                                                             Map<String,Set<Id>> topNodeForSalesOrgMap){

        List<cgcloud__Product_Assortment_Product_Share__c> productCategoryToCreateList = new List<cgcloud__Product_Assortment_Product_Share__c>();
        
        //if the assortment object has been updated with the created id:
		if(assortmentObj.id!=null){
            
            //inserting and logging error(if any), product assortment category records :
            productCategoryToCreateList = TPM_AssortmentCreationHelper.prepareProductAssortmentRecords(topNodeForSalesOrgMap,accountid,assortmentObj.id,accountToSalesOrgMap);
        }
                                                                                                                 
        return productCategoryToCreateList;                                                                                                       
    }
 
  
}