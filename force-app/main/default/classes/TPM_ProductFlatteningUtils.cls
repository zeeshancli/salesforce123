/******************************************************************************************************
* @Name         : TPM_ProductFlatteningUtils
* @Test Class   : TPM_ProductFlatteningCategoryBatchTest
* @author       : PwC Team
* @date         : February 9, 2023
* @description  : Utililty class for product flattening automation.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public inherited sharing class TPM_ProductFlatteningUtils {
    

    /*****************************************************************************************
    * @method          prepareBatchStartQuery
    * @param           metadataRecordAPI
    * @param           objectIdSet
    * @return          String
    * @description     Method to prepare batch start query based on custom metadata record.
    ******************************************************************************************/
    public static String prepareBatchStartQuery(String metadataRecordAPI, Set<Id> objectIdSet){
        
        String query = '';
        Boolean isQueryConditionPresent = false;

        // fetch query from TPM_QueryDefinition__mdt custom metadata record.
        List<TPM_QueryDefinition__mdt>  startQueryMdtList = new List<TPM_QueryDefinition__mdt>();

        startQueryMdtList = [SELECT Id, 
                                    TPM_BaseQuery__c, 
                                    TPM_ProcessName__c, 
                                    TPM_QueryCondition__c, 
                                    TPM_Query_Footer__c  
                            FROM TPM_QueryDefinition__mdt 
                            WHERE TPM_ProcessName__c =: metadataRecordAPI   
                            LIMIT 1];

        if(String.isNotBlank(startQueryMdtList[0].TPM_BaseQuery__c)){
            query = startQueryMdtList[0].TPM_BaseQuery__c;
        }       

        if(String.isNotBlank(startQueryMdtList[0].TPM_QueryCondition__c)){
            query += ' ' + startQueryMdtList[0].TPM_QueryCondition__c;
            isQueryConditionPresent = true;
        }

        if(objectIdSet != null && !objectIdSet.isEmpty()){
            String preSelectedQuery = isQueryConditionPresent ? ' AND Id IN: objectIdSet ' : ' WHERE Id IN: objectIdSet ';
            query += preSelectedQuery;
        }

        if(String.isNotBlank(startQueryMdtList[0].TPM_Query_Footer__c)){
            query += ' ' + startQueryMdtList[0].TPM_Query_Footer__c;
        }

        return query;
    }


    /*********************************************************************************************************
    * @method          fetchProductHierarchyDetails
    * @param           objScopeList
    * @return          Map<String, cgcloud__Product_Hierarchy__c>
    * @description     Method to fetch product hierarchy records based on product scope.
    **********************************************************************************************************/
    public static Map<String, cgcloud__Product_Hierarchy__c> fetchProductHierarchyDetails(List<Product2> objScopeList){

        Map<String, cgcloud__Product_Hierarchy__c> childIdWithPHObjMap = new Map<String, cgcloud__Product_Hierarchy__c>();

        // To fetch product hierachy records.
        if(!objScopeList.isEmpty()){
            for(cgcloud__Product_Hierarchy__c phObj : [SELECT   Id,  
                                                                cgcloud__Child_Product__c, 
                                                                cgcloud__Parent_Product__c, 
                                                                cgcloud__Parent_Product__r.cgcloud__Criterion_1_Product__c, 
                                                                cgcloud__Parent_Product__r.cgcloud__Criterion_2_Product__c, 
                                                                cgcloud__Parent_Product__r.cgcloud__Criterion_3_Product__c, 
                                                                cgcloud__Parent_Product__r.cgcloud__Criterion_4_Product__c, 
                                                                cgcloud__Parent_Product__r.cgcloud__Criterion_5_Product__c 
                                                                FROM cgcloud__Product_Hierarchy__c 
                                                                WHERE cgcloud__Child_Product__c IN :objScopeList  
                                                                AND cgcloud__Valid_From__c <= TODAY 
                                                                AND cgcloud__Valid_Thru__c >= TODAY 
                                                                ORDER BY cgcloud__Child_Product__c, CreatedDate DESC]){

                if(!childIdWithPHObjMap.containsKey(phObj.cgcloud__Child_Product__c)){
                    childIdWithPHObjMap.put(phObj.cgcloud__Child_Product__c, phObj);
                }
            }
        }     

        return childIdWithPHObjMap;
    }


    /*********************************************************************************************************
    * @method          performDMLOperation
    * @param           objDMLList
    * @param           batchName
    * @return          List<TPM_LoggerException.LogsWrapper>
    * @description     Methdo to perform update DML operations for product records.
    **********************************************************************************************************/
    public static List<TPM_LoggerException.LogsWrapper> performDMLOperation(List<Product2> objDMLList, String batchName){

        List<TPM_LoggerException.LogsWrapper> logWrapperList = new List<TPM_LoggerException.LogsWrapper>();

        // To check create CRUD permission for the current user-running the batch.
        Boolean isUpdateableObj = Schema.sObjectType.Product2.isUpdateable();

        if(!objDMLList.isEmpty() && isUpdateableObj){

            Database.SaveResult[] srList = Database.update(objDMLList, false);
            Integer index = 0;

            for(Database.SaveResult srObj : srList){
                if(!srObj.isSuccess()){
                    
                    // Operation failed, log errors.
                    // Create an instance of Wrapper Class of TPM_Utils.LogParamWrapper
                    TPM_Utils.LogParamWrapper logObj = TPM_Utils.createLogParamWrapper(srObj.getErrors(), 
                                                                                       batchName, 
                                                                                       objDMLList[index].Id);

                    // Call the TPM_Utils.prepareBatchLogger
                    logWrapperList.add(TPM_Utils.prepareBatchLogger(logObj));           
                }
                index++;
            }
        }                

        if(!isUpdateableObj){

            // To log exception.
            TPM_LoggerException.LogsWrapper logObj = new TPM_LoggerException.LogsWrapper();
            logObj.logLevel = TPM_ConstantsUtility.FATAL;
            logObj.className = batchName;
            logObj.errorMessage = System.Label.TPM_ProductFlatteningNoEditOnProduct;   
            logWrapperList.add(logObj);              
        }

        return logWrapperList;
    }

}