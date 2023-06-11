/*******************************************************************************************************
* @Name         : TPM_SalesOrgUserTriggerHelper
* @Unit Test    : TPM_SalesOrgUserTriggerHelperTest
* @Author       : PwC Team
* @Date         : 02/07/2023
* @description  : Helper class for performing all business logics/ DML operations, for events triggerd 
				  on creation/manipulation of the sales org user records.
*******************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.cyclomaticcomplexity')
public inherited sharing class TPM_SalesOrgUserTriggerHelper {

    public static Boolean isSalesUserDelete = false;
    
     /***************************************************************************************************
	@methodname 	TPM_SalesOrgUserTriggerHelper
	@createdDate 	14/04/2023
	@description	default private constructor
	****************************************************************************************************/
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_SalesOrgUserTriggerHelper(){
        
    }
    
    
    
  	/*********************************************************************************************************
    @methodname   	handleSalesOrgProductManagerOperation
    @createdDate  	02/07/2022
    @param     	  	newMap
	@param			oldMap
    @description  	Handler method to Invoke Upsert or Update Utility methods accordingly
    **********************************************************************************************************/
    public static void handleSalesOrgProductManagerOperation(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        
        Map<Id,cgcloud__Sales_Organization_User__c> salesOrgUserMap;

        //Check if current Trigger Context is
        //Insert or Delete
        if(Trigger.IsInsert){
            salesOrgUserMap = (Map<Id, cgcloud__Sales_Organization_User__c>) newMap;
        }else if(Trigger.IsDelete){
            isSalesUserDelete = True;
            salesOrgUserMap = (Map<Id, cgcloud__Sales_Organization_User__c>) oldMap;
        }
        
        //Call the salesOrgUserTriggerBusinessHandler method to prepare Set & Maps for processing of triggered records
        salesOrgUserTriggerBusinessHandler(salesOrgUserMap);
    }
    
    /*********************************************************************************************************
    @methodname   	salesOrgUserTriggerBusinessHandler
    @createdDate  	02/07/2022
    @param     	  	salesOrgUserMap
    @description  	Method to create necessary Sets & Maps for processing of triggered records 
    **********************************************************************************************************/
    public static void salesOrgUserTriggerBusinessHandler(Map<Id, cgcloud__Sales_Organization_User__c> salesOrgUserMap ){

        Set<Id> salesOrgSet = new Set<Id>();
        Set<Id> userIdsSet = new Set<Id>();
        Set<String> salesOrgNameSet = new Set<String>();
        Map<Id, String> salesOrgIdNameMap = new Map<Id, String>();
        Map<String, Set<Id>> salesOrgToTopNodeProductMap = new Map<String, Set<Id>>();
        Map<String, cgcloud__Product_Category_Share__c> userIdProdIdToProdMgrMap = new Map<String, cgcloud__Product_Category_Share__c>();
      	
        //Iterate over the Trigger.New Or Trigger.Old List i.e the inserting or deleting sales org user record
        //Create a Set of the following
        //1.salesOrgSet - Containing Sales Org Id
        //2.userIdsSet - Containing all the user id lookup field values 
        for(cgcloud__Sales_Organization_User__c salesOrgUsrObj : salesOrgUserMap.values()){
            salesOrgSet.add(salesOrgUsrObj.cgcloud__Sales_Organization__c);
            userIdsSet.add(salesOrgUsrObj.cgcloud__User__c);
        }
        
        //Get all the Existing Sales Org Records
        List<cgcloud__Sales_Organization__c> allSalesOrgList = [SELECT Id, 
                                                                	   Name
                                                                FROM   cgcloud__Sales_Organization__c
                                                                WHERE  Id IN:salesOrgSet];
        
        for(cgcloud__Sales_Organization__c salOrg : allSalesOrgList){
            salesOrgIdNameMap.put(salOrg.Id, salOrg.Name);
            salesOrgNameSet.add(salOrg.Name);
        }

        //Get the Product Records WHERE
        //Sales Org matches with the salesOrgSet created from the inserted records AND
        //Product Level ='Category'
        List<Product2> topNodeProductList = [SELECT  Id,
                                                     Name,
                                                     cgcloud__Consumer_Goods_External_Product_Id__c,
                                                     cgcloud__Product_Level__c,
                                                     cgcloud__Sales_Org__c 
                                             FROM 	 Product2 
                                             WHERE   cgcloud__Sales_Org__c IN:salesOrgNameSet
                                             AND 	 cgcloud__Product_Level__c =: TPM_ConstantsUtility.PRODUCT_CATEGORY];

        //For Each Top-Node / Category level Products 
        for(Product2 prod : topNodeProductList){
            //Create a Map with Key as Product SalesOrg Name and Value as Product Id
            if(!salesOrgToTopNodeProductMap.containsKey(prod.cgcloud__Sales_Org__c)){
                salesOrgToTopNodeProductMap.put(prod.cgcloud__Sales_Org__c, new Set<Id>{prod.Id});
            }else{
                salesOrgToTopNodeProductMap.get(prod.cgcloud__Sales_Org__c).add(prod.Id);
            }
        }

        //Get all the existing product manager records 
        List<cgcloud__Product_Category_Share__c> existingProdManagerList = [SELECT  Id,
                                                                                   Name,
                                                                                   cgcloud__Access__c,
                                                                                   cgcloud__Account__c,
                                                                                   cgcloud__Product__c,
                                                                                   cgcloud__User__c,
                                                                                   cgcloud__Active__c,
                                                                                   cgcloud__Product__r.cgcloud__Sales_Org__c,
                                                                                   cgcloud__Product__r.cgcloud__Product_Level__c 
                                                                           FROM    cgcloud__Product_Category_Share__c 
                                                                           WHERE   cgcloud__User__c IN: userIdsSet];
        
        //Iterate over the existing product manager records
        for(cgcloud__Product_Category_Share__c prodMgr : existingProdManagerList){
            //Check If User lookup field and Product lookup field is populated
            //And then Create a Map with 
            //Key as UserId + ProductId  
            //Value as ProductManager record instance 
            if(prodMgr.cgcloud__User__c != NULL && prodMgr.cgcloud__Product__c != NULL){
                userIdProdIdToProdMgrMap.put((String.valueOf(prodMgr.cgcloud__User__c) + String.valueOf(prodMgr.cgcloud__Product__c)), prodMgr);
            }  
        }
        
        //Check for Upsert or Update Trigger Context and Invoke the coressponding methods to process records
        checkProductMgrRecordUpsertOrUpdate(salesOrgUserMap, salesOrgToTopNodeProductMap, salesOrgIdNameMap, userIdProdIdToProdMgrMap); 
     
    }
    
    /*********************************************************************************************************
    @methodname   	checkProductMgrRecordUpsertOrUpdate
    @createdDate  	02/07/2022
    @param     	  	salesOrgUserMap
	@param			salesOrgToTopNodeProductMap
	@param 			salesOrgIdNameMap
 	@param 			userIdProdIdToProdMgrMap
    @description  	after the insertion or deletion of a sales org user record, product manager record is created/updated
					for the user.
    **********************************************************************************************************/
    public static void checkProductMgrRecordUpsertOrUpdate(Map<Id, cgcloud__Sales_Organization_User__c> salesOrgUserMap, Map<String, Set<Id>> salesOrgToTopNodeProductMap, Map<Id, String> salesOrgIdNameMap, Map<String, cgcloud__Product_Category_Share__c> userIdProdIdToProdMgrMap){
       
        //List to hold the records that will be upserted or updated based on conditions
        List<cgcloud__Product_Category_Share__c> productMrgList = new List<cgcloud__Product_Category_Share__c>();

        //Iterate over the Triggering Records i.e Trigger.New List or Trigger.Old List values
        for(cgcloud__Sales_Organization_User__c salesOrgUsrObj : salesOrgUserMap.values()){
            //If Inserting Sales org user record's sales org field Name matches with
            //Existing Top-Node Product record's Sales Org field Name value then
            //TO-DO Rename salesOrgToTopNodeProductMap to salesOrgToSetOfTopNodeProductIdsMap
            if(salesOrgToTopNodeProductMap.containsKey(salesOrgIdNameMap.get(salesOrgUsrObj.cgcloud__Sales_Organization__c))){
                //Get all the product ids that belong to that sales org value
                //And then Iterate over the list of product ids
                for(Id productId : salesOrgToTopNodeProductMap.get(salesOrgIdNameMap.get(salesOrgUsrObj.cgcloud__Sales_Organization__c))){
                    //Method to perform core logic of upsert or update of triggering records
                    processProductMrgUpdates(userIdProdIdToProdMgrMap, salesOrgUsrObj, productId, productMrgList);
                }   
            }  
        } 
        
        //handleUpsertDML method to Upsert the product manager records
        if(!isSalesUserDelete){
            TPM_SalesOrgUserTriggerHelperExtension.handleUpsertDML(productMrgList); 
        }else{
            //handleUpdateDML method to Update the product manager records
           List<Sobject> recordsToUpdateList = new List<Sobject>();
            recordsToUpdateList.addAll(productMrgList);
            TPM_SalesOrgUserTriggerHelperExtension.handleUpdateDML(recordsToUpdateList);
        }
    }
    
    /*********************************************************************************************************
    @methodname   	processProductMrgUpdates
    @createdDate  	02/07/2022
    @param     	  	userIdProdIdToProdMgrMap
	@param			salesOrgUsrObj
	@param 			productId
 	@param 			productMrgList
    @description  	after the insertion or deletion of a sales org user record, product manager record is created/updated
					for the user.
    **********************************************************************************************************/
    public static void processProductMrgUpdates(Map<String, cgcloud__Product_Category_Share__c> userIdProdIdToProdMgrMap, cgcloud__Sales_Organization_User__c salesOrgUsrObj, Id productId, List<cgcloud__Product_Category_Share__c> productMrgList){
        			
        //To-Control Upsert or Update If-Else Logic 
        Boolean isCreateProdMrg = False;
        
        //Check If the inserting user is present as a product manager for the iterating product
        //If-Yes AND then Check the existing product manager record's Active field is marked as Active or other value
        //salesOrgUsrObj - Outer loop i.e Trigger.New Sales Org User Record
        //productId - Inner loop iterating product Id
        //isSalesUserDelete -Controls the handling of upsert and update of the triggering records
        if((!isSalesUserDelete) && (userIdProdIdToProdMgrMap.containskey(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId))) && (userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Active__c != TPM_ConstantsUtility.ACTIVE)){
            isCreateProdMrg = True;
            //Make the existing product manager record's Active field as Active
            userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Active__c = TPM_ConstantsUtility.ACTIVE;
            // Check If the existing product manager record's Access field is Read / Write
            if(userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Access__c != TPM_ConstantsUtility.READ_WRITE_ACCESS){
                // If not Mark it as Read / Write
                userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Access__c = TPM_ConstantsUtility.READ_WRITE_ACCESS;
            }
            //Add into list to upsert
            productMrgList.add(userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)));
        }
        // Check If existing product manager record is Active and
        
        else if((!isSalesUserDelete) && (userIdProdIdToProdMgrMap.containskey(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId))) && (userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Active__c == TPM_ConstantsUtility.ACTIVE)){
            isCreateProdMrg = True;
            // Check If the Access is Read/Write
            if((userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Access__c != TPM_ConstantsUtility.READ_WRITE_ACCESS)){
                // If not Mark it as Read / Write
                userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Access__c = TPM_ConstantsUtility.READ_WRITE_ACCESS;
            }
           
            //Add into list to upsert
            productMrgList.add(userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)));
        }
        else if(!isCreateProdMrg && !isSalesUserDelete){
            //If no existing product manager record for the product exists then
            //Create a new product manager record With following
            //1.Access = Read/Write 
            //2.ProductId = correspoding sales org top node product 
            //3.User = UserId from creating sales org user record from Trigger.New
            cgcloud__Product_Category_Share__c prodMgrObj = new cgcloud__Product_Category_Share__c();
            //Assign salesOrgUserRecordUserId = UserId from creating sales org user record from Trigger.New
            Id salesOrgUserRecordUserId = salesOrgUsrObj.cgcloud__User__c;
            prodMgrObj.cgcloud__Access__c = TPM_ConstantsUtility.READ_WRITE_ACCESS;
            prodMgrObj.cgcloud__Active__c = TPM_ConstantsUtility.ACTIVE;
            prodMgrObj.cgcloud__Product__c = productId;
            prodMgrObj.cgcloud__User__c = salesOrgUserRecordUserId;
            //Add the new product manager record instance to list
            productMrgList.add(prodMgrObj); 
        }
        
        //Logic for Update i.e For Deletion Scenario Existing Product Manager Record should be updated with Active field as Inactive
        if((isSalesUserDelete) && (userIdProdIdToProdMgrMap.containskey(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId))) && (userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Active__c == TPM_ConstantsUtility.ACTIVE)){
            //Make the existing product manager record's Active field as Inactive
            userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)).cgcloud__Active__c = TPM_ConstantsUtility.INACTIVE;
            //Add into list to update
            productMrgList.add(userIdProdIdToProdMgrMap.get(String.ValueOf(salesOrgUsrObj.cgcloud__User__c) + String.valueOf(productId)));
        }

    }
    
    /*********************************************************************************************************
    @methodname   	updateStandardSalesOrg
    @createdDate  	21/03/2023
    @param     	  	newMap
	@description  	after sales org user record is created , update the sales org field from the default sales org.
    *********************************************************************************************************/
    public static void updateStandardSalesOrg(Map<Id,Sobject> newMap){
        
       Set<Id> userIdList = new Set<Id>();
        Set<SObject> userIdSetToUpdate = new Set<Sobject>();
         Map<Id,cgcloud__Sales_Organization_User__c> salesOrgUserMap = new Map<Id,cgcloud__Sales_Organization_User__c>();
        for(cgcloud__Sales_Organization_User__c salesUserObj: (List<cgcloud__Sales_Organization_User__c>)newMap.values()){
            userIdList.add(salesUserObj.cgcloud__User__c);
        }
       
        
       for(cgcloud__Sales_Organization_User__c salesOrgUser : [SELECT
                                                               Id,
                                                               Name,
                                                               cgcloud__User__c,
                                                               cgcloud__User__r.TPM_Default_Sales_Organization__c,
                                                               cgcloud__User__r.cgcloud__Sales_Org__c,
                                                               cgcloud__Sales_Organization__c,
                                                               cgcloud__Sales_Organization__r.Name,
                                                               createddate
                                                               FROM cgcloud__Sales_Organization_User__c
                                                               WHERE cgcloud__User__c IN :userIdList]){
             
              salesOrgUserMap.put(salesOrgUser.cgcloud__User__c, salesOrgUser);
      }  
        
        for(cgcloud__Sales_Organization_User__c salesUserObj : (List<cgcloud__Sales_Organization_User__c>)newMap.values()){
            if(salesOrgUserMap.containskey(salesUserObj.cgcloud__User__c)){
                if(salesOrgUserMap.get(salesUserObj.cgcloud__User__c).cgcloud__User__r.cgcloud__Sales_Org__c != salesOrgUserMap.get(salesUserObj.cgcloud__User__c).cgcloud__User__r.TPM_Default_Sales_Organization__c){
                    
                    User userObj = new User(Id=salesUserObj.cgcloud__User__c, 
                                            cgcloud__Sales_Org__c= salesOrgUserMap.get(salesUserObj.cgcloud__User__c).cgcloud__User__r.TPM_Default_Sales_Organization__c);
                    userIdSetToUpdate.add(userObj);
                }
            }
            
        }
        
        if(!userIdSetToUpdate.isEmpty()){
            List<Sobject> recordsToUpdateList = new List<Sobject>();
            recordsToUpdateList.addAll(userIdSetToUpdate);
            
            TPM_SalesOrgUserTriggerHelperExtension.handleUpdateDML(recordsToUpdateList);
        }
}
}