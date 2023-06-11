/*******************************************************************************************************
* @Name         : TPM_ComponentVolumeWebService
* @unit Test    : TPM_ComponentVolumeWebServiceTest
* @author       : PwC Team
* @date         : 03/24/2023
* @description  : Apex Webservice Class to callout Hyperforce Integration APIs.
*******************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.NcssMethodCount,PMD.CyclomaticComplexity,PMD.AvoidDeeplyNestedIfStmts')
public with sharing class TPM_ComponentVolumeWebService {
    
    /*********************************************************************************************************
    @methodname   	createRandomTransactionId
    @createdDate  	03/18/2023
	@return			String
    @description  	Method to generate a random transaction id
    **********************************************************************************************************/
    public static String createRandomTransactionId(){
        Integer randomNumber = Integer.valueof((Math.random() * 1000));
        String transactionId='SFDCTRANSID'+String.valueOf(randomNumber);
        return transactionId;
    }
    
    /*********************************************************************************************************
    @methodname   	registerTransactionId
    @createdDate  	03/18/2023
	@return			String
    @param			noOfMessages
    @description  	Method to register a transaction id to hyperforce
    **********************************************************************************************************/
    public static String registerTransactionId(Integer noOfMessages){
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        String transactionId=createRandomTransactionId();
        req.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        req.setEndpoint('callOut:TPM_Hyperforce_Register_Transaction_Id'+'/transaction?messages='+noOfMessages+'&transaction='+transactionId);
        Http http = new Http();
        HttpResponse response = http.send(req);
        // If Sucessfully executed
        if(response.getStatusCode() != 200) {
            
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
            TPM_LoggerException.LogsWrapper logsObj = new TPM_LoggerException.LogsWrapper();
            logsObj.className = TPM_ConstantsUtility.TPM_DISPLAY_SHIPPER_COMPONENT;
            logsObj.methodName = TPM_ConstantsUtility.GET_REGISTERED_TRANSACTION_ID;
            logsObj.errorMessage = TPM_ConstantsUtility.TRANSACTION_ID_ERROR +' '+response.getStatusCode() + ' ' +response.getStatus();
            exceptionWrapperList.add(logsObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
        return transactionId;
    }   
    
    /*********************************************************************************************************
    @methodname   	getDataForPromotionCustomPeriod
    @createdDate  	03/18/2023
    @param			promotionRecordObj
    @param          isPlanningMethod
    @description  	Method to get Data for the Processed Promotions from CG Cloud Processing Services.
    **********************************************************************************************************/
   
    public static void getDataForPromotionCustomPeriod(cgcloud__Promotion__c promotionRecordObj, Boolean isPlanningMethod){
        
        
        // Set the TPM Base URL, Request Method, Header to Get SF Session Id
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setEndpoint('callOut:TPM_Hyperforce_Get_Promotion'+'/v2/promotions/'+promotionRecordObj.Id+'/all/list?salesorg='+promotionRecordObj.cgcloud__Sales_Org__c+'&timeblock=customperiod');
        Http http = new Http();
        
        Map<String, List<Integer>> bomProdExtIdValListMap = new Map<String, List<Integer>>();
        Map<String, String> bomProdExtIdFromDateMap = new Map<String, String>();
        Map<Id, String> bomProductIdExtIdMap = new Map<Id, String>();
        Map<Id, List<cgcloud__Product_Part__c>>  parentProductIdChildProdPartMap = new Map<Id, List<cgcloud__Product_Part__c>>();
        String fromDate = '';
        
        HttpResponse response = http.send(request);
        
        // If Response recieved successfully
        if(response.getStatusCode() == 200) {
            Map<String,Object> resultMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
           
            for(Object obj : ( List< Object > )resultMap.get( 'measures' )){
                Map <String, Object> keyValPairMap = ( Map < String, Object > )obj;
                fromDate = (String)keyValPairMap.get('from') ;
                if(   keyValPairMap.get('measurecode') == TPM_ConstantsUtility.BOM_REQUEST_BODY_MEASURE_CODE_BASIC 
                   || keyValPairMap.get('measurecode') == TPM_ConstantsUtility.BOM_REQUEST_BODY_MEASURE_CODE_INT){
                    
                    List<Integer> valIntList = new List<Integer>();
                    for(Object valObj:(List<Object>)keyValPairMap.get('value')){
                        valIntList.add(Integer.valueOf(valObj));
                    }
                        bomProdExtIdValListMap.put((String)keyValPairMap.get('prd'), valIntList);
                        bomProdExtIdFromDateMap.put((String)keyValPairMap.get('prd'), (String)keyValPairMap.get('from'));  
                }
            }
        }else{
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
            TPM_LoggerException.LogsWrapper logsObj = new TPM_LoggerException.LogsWrapper();
            logsObj.className = TPM_ConstantsUtility.TPM_DISPLAY_SHIPPER_COMPONENT;
            logsObj.methodName = TPM_ConstantsUtility.GET_DATA_FOR_SINGLE_PROMOTION;
            logsObj.errorMessage = TPM_ConstantsUtility.GET_DATA_SINGLE_PROMOTION_ERROR +' '+response.getStatusCode() +' '+response.getStatus();
            exceptionWrapperList.add(logsObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
     
        // For Each Recieved BOM Product and List of Values
        if(!bomProdExtIdValListMap.isEmpty()){

            // Get all the BOM Products 
            // BOM Product with the help of bomProdExtIdValListMap
            for(Product2 prod : [SELECT  Id, 
                                         Name, 
                                         cgcloud__Consumer_Goods_External_Product_Id__c	, 
                                         cgcloud__Is_Bill_Of_Material__c, 
                                         cgcloud__Product_Level__c 
                                 FROM 	 Product2 
                                 WHERE   cgcloud__Is_Bill_Of_Material__c = TRUE 
                                 AND 	 cgcloud__Product_Level__c =: TPM_ConstantsUtility.PRODUCT_LEVEL_PRODUCT
                                 AND 	 cgcloud__Consumer_Goods_External_Product_Id__c IN:bomProdExtIdValListMap.keySet()]){
                                     
                                     // Create bomProductIdExtIdMap 
                                     // Key as BOM Product SFDC ID
                                     // Value as BOM Product External ID          
                                     bomProductIdExtIdMap.put(prod.Id, prod.cgcloud__Consumer_Goods_External_Product_Id__c);
            }
            
            // Get all the Corresponding Product Part Records
            // for Each BOM Product
            for(cgcloud__Product_Part__c prodPartObj : [SELECT  Id, 
                                                                Name, 
                                                                cgcloud__Quantity__c, 
                                                                cgcloud__Parent_Product__c, 
                                                                cgcloud__Child_Product__c,
                                                                cgcloud__Child_Product__r.cgcloud__Consumer_Goods_External_Product_Id__c,
                                                                cgcloud__ExternalId__c 
                                                        FROM   	cgcloud__Product_Part__c 
                                                        WHERE  	cgcloud__Parent_Product__c IN:bomProductIdExtIdMap.keySet()]){
                                                            
                                                            // For Each Product Part Record
                                                            // Create a Map of parentProductIdChildProdPartMap which consist of 
                                                            // Key as Parent Product SFDC Id
                                                            // Value as All Corresponding Product Parts of Each Parent BOM Product
                                                            if(!parentProductIdChildProdPartMap.containsKey(prodPartObj.cgcloud__Parent_Product__c)){
                                                                parentProductIdChildProdPartMap.put(prodPartObj.cgcloud__Parent_Product__c, new List<cgcloud__Product_Part__c>{prodPartObj});
                                                            }else{
                                                                parentProductIdChildProdPartMap.get(prodPartObj.cgcloud__Parent_Product__c).add(prodPartObj);
                                                            }

                                                        }
            
            List<ResultValueWrapper> wrapperObjLst = new List<ResultValueWrapper>();
        
            // MAIN LOGIC - Multiplying Product Part Quantity with BOM Header
            // AND Months to Day Volume Conversion
            // Iterate over Parent BOM Product Records
            for(Id parentProductId:bomProductIdExtIdMap.keySet()){
                
                // Check If Parent Product SFDC ID Present in ChildProdPartMap
                if(parentProductIdChildProdPartMap.containsKey(parentProductId)){
                    List<cgcloud__Product_Part__c> childProdPartsList = parentProductIdChildProdPartMap.get(parentProductId);
                    
                    // Get all the list of Related Product Parts for each Parent BOM Product
                    for(cgcloud__Product_Part__c  childProd : childProdPartsList){
                        ResultValueWrapper wrapperObj =  new ResultValueWrapper(); 	
                        List<Integer> parentValList = new List<Integer>();
                        
                        // Get the Parent Value List for Each Child Product Part
                        if(bomProductIdExtIdMap.containskey(childProd.cgcloud__Parent_Product__c)){
                            
                            parentValList = bomProdExtIdValListMap.get(bomProductIdExtIdMap.get(childProd.cgcloud__Parent_Product__c));
                        }
                        
                        List<Double> childValList = new List<Double>();
                        
                        // Calculate Component Volume for each BOM Product
                        // Child Product Part Quantity * BOM Product Header Volume
                        for(Integer intVal : parentValList){
                            if(intval != NULL && isPlanningMethod == TRUE){
                                intVal *= (Integer)childProd.cgcloud__Quantity__c;
                            }else{
                                intVal = 0;
                            }
                            childValList.add(intVal);
                        }
  
                        wrapperObj.childId = childProd.Id;
                        wrapperObj.childExtId = childProd.cgcloud__Child_Product__r.cgcloud__Consumer_Goods_External_Product_Id__c;
                        wrapperObj.parentId = parentProductId;
                        wrapperObj.convertedChildValList = childValList;
                        wrapperObjLst.add(wrapperObj);
                    }
                } 
            }
            
           // Call prepareTranformedValuesWrapper method
           // To Prepare Final Tranformed Wrapper Values of Product Parts Volumes to send it for the Response JSON Creation. 
           prepareTranformedValuesWrapper(wrapperObjLst, bomProdExtIdFromDateMap, bomProductIdExtIdMap, promotionRecordObj);
            
        }
      }
    
    
    /*********************************************************************************************************
    @methodname   	prepareTranformedValuesWrapper
    @createdDate  	03/18/2023
    @param			wrapperObjLst
    @param			bomProdExtIdFromDateMap
    @param			bomProductIdExtIdMap
	@param			promotionRecordObj
    @description  	Method to prepare Final Tranformed Wrapper Values of Product Parts Volumes to send it for 
					the Response JSON Creation.
    **********************************************************************************************************/
    public static void prepareTranformedValuesWrapper(List<ResultValueWrapper> wrapperObjLst, Map<String, String> bomProdExtIdFromDateMap, Map<Id, String> bomProductIdExtIdMap, cgcloud__Promotion__c promotionRecordObj ){
        
        Map<String, TransformedValuesWrapper> tranformedWrapperMap = new Map<String, TransformedValuesWrapper>();
        // Iterate over all the Resultant Values i.e Per Day Value of Each Product Parts
        // And Check If the Same Product Part Present as again Product Part of another BOM Product
        // If Yes Add all the Values
        for(ResultValueWrapper wrapObj : wrapperObjLst){
            TransformedValuesWrapper wrap2obj = new TransformedValuesWrapper();
            wrap2obj.childProductPartId = wrapObj.childId;
            wrap2obj.childProductExtId = wrapObj.childExtId;
            wrap2obj.fromYear = bomProdExtIdFromDateMap.get(bomProductIdExtIdMap.get(wrapObj.parentId)).substring(0,4);
            wrap2obj.fromMonth = bomProdExtIdFromDateMap.get(bomProductIdExtIdMap.get(wrapObj.parentId)).substring(4,6);
            if(!tranformedWrapperMap.containsKey(wrapObj.childExtId) && wrapObj.childExtId != NULL){
                wrap2obj.finalConvertedChildValList = wrapObj.convertedChildValList;
            }
            else{
                List<Double> currentIterationChildValList =  wrapObj.convertedChildValList;
                List<Double> existingChildValList =  tranformedWrapperMap.get(wrapObj.childExtId).finalConvertedChildValList;
                List<Double> doubleFinalList =  new List<Double>();
                for(Integer indexVal = 0; indexVal < Math.max(currentIterationChildValList.size(), existingChildValList.size()); indexVal++){
                    doubleFinalList.add((indexVal >= currentIterationChildValList.size() ? 0 : currentIterationChildValList[indexVal])+(indexVal >= existingChildValList.size() ? 0 : existingChildValList[indexVal]));
                }
                wrap2obj.finalConvertedChildValList = doubleFinalList;
            }
            
            tranformedWrapperMap.put(wrapObj.childExtId,wrap2obj);
        }
        
        // Call the method to prepare request JSON
        // Pass TranformedWrapper Map , Promotion Record
        createAccountProductMeasureAPIJSON(tranformedWrapperMap, promotionRecordObj);
    }
    

    
    /*********************************************************************************************************
    @methodname   	createAccountProductMeasureAPIJSON
    @createdDate  	03/18/2023
    @param			tranformedWrapperMap
    @param			promotionRecordObj
    @description  	Method to Prepare the JSON for the Table Account Product Measure API
    **********************************************************************************************************/
    public static void createAccountProductMeasureAPIJSON(Map<String,TransformedValuesWrapper> tranformedWrapperMap, cgcloud__Promotion__c promotionRecordObj){
        
        // Get the Promo Start Date and Promo End Date
        Date promoStartDate = promotionRecordObj.cgcloud__Date_From__c;
        Date promoEndDate = promotionRecordObj.cgcloud__Date_Thru__c;
        
        // Get the Number of Months for the Promotion
        Integer noOfMonths = promoStartDate.monthsBetween(promoEndDate);
        
        Map<Integer,DateWrapper> startDateEndDateWrapperMap = createDateWrapper(promoStartDate, promoEndDate, noOfMonths);
        
        // Get the Wrapper Class Instance
        TPM_AccountProductMeasureWrapper accountProductWrapperObj = new TPM_AccountProductMeasureWrapper();
        List<TPM_AccountProductMeasureWrapper.prices> priceList = new List<TPM_AccountProductMeasureWrapper.prices>();
        
        // Initialize the Account Product Measure Code
        accountProductWrapperObj.type = TPM_ConstantsUtility.ACCOUNT_PRODUCT_MEASURE_CODE;
        
        // Iterate over the List of Values for each
        // BOM Products
        for(String prdExtId : tranformedWrapperMap.keyset()){
			// For Each Product get the corresponding month wise values 
            List<Double> monthWiseValList = tranformedWrapperMap.get(prdExtId).finalConvertedChildValList;
            for(Integer monthIndex = 0; monthIndex < monthWiseValList.size(); monthIndex++){
                // Create a Record
                TPM_AccountProductMeasureWrapper.prices priceObj = new TPM_AccountProductMeasureWrapper.prices();
                priceObj.acc = promotionRecordObj.cgcloud__Anchor_Account__r.cgcloud__ExternalId__c;
                priceObj.prd = prdExtId;
                priceObj.value = monthWiseValList[monthIndex];
                DateWrapper monthWiseValObj = startDateEndDateWrapperMap.get(monthIndex);
                priceObj.datefrom = String.valueOf(monthWiseValObj.startDate);
                priceObj.datethru = String.valueOf(monthWiseValObj.endDate);
                priceList.add(priceObj);
            }
            // Add each Row into Price List
			accountProductWrapperObj.prices = priceList;         
        }
        
        // Invoke sendAccountProductMeasure to SEND the JSON
        sendAccountProductMeasure(JSON.Serialize(accountProductWrapperObj));
        
    }
    
    /*********************************************************************************************************
    @methodname   	createDateWrapper
    @createdDate  	03/18/2023
    @param			promoStartDate
	@param			promoEndDate
	@param			noOfMonths
    @return         Map<Integer,DateWrapper>
    @description  	Method to create a wrapper class that stores
					Start Date and End Date of each Month
    **********************************************************************************************************/
    public static Map<Integer,DateWrapper> createDateWrapper( Date promoStartDate, Date promoEndDate, Integer noOfMonths){
        
        Map<Integer,DateWrapper> dateWrapperMap = new Map<Integer,DateWrapper>();
        
        for(Integer startMonthIndex = 0; startMonthIndex <= noOfMonths; startMonthIndex++){
            DateWrapper wrp = new DateWrapper();
            
            // If its first Month 
            if(startMonthIndex == 0){
                // Get the Start Date 
                wrp.startDate = promoStartDate;
                Integer numberOfDays = Date.daysInMonth(promoStartDate.year(), promoStartDate.month());
                // Get the End Date
                wrp.endDate = Date.newInstance(promoStartDate.year(), promoStartDate.month(), numberOfDays);
            }
            // If its other Months apart from start month
            else{
                // Get the Start Date 
                wrp.startDate = promoStartDate.addMonths(startMonthIndex).toStartOfMonth();
                Integer numberOfDays = Date.daysInMonth(wrp.startDate.year(), wrp.startDate.month());
                // Get the End Date
                // If its last Month then End Date = Promo End Date
                // Else Monthwise End Date
                wrp.endDate = startMonthIndex == noOfMonths ? promoEndDate : Date.newInstance(wrp.startDate.year(), wrp.startDate.month(), numberOfDays);
            }
            // Add it into dateWrappers
            dateWrapperMap.put(startMonthIndex, wrp);
        }
        
        return dateWrapperMap;
    }
    
    /*******************************************************************************************************
    * @Name         : DateWrapper
    * @author       : PwC Team
    * @date         : 03/24/2023
    * @description  : DateWrapper Class to store
    * 				  startDate
    * 				  endDate                 
    *******************************************************************************************************/
    public class DateWrapper{
        public Date startDate;
        public Date endDate;
    }
    
    /*********************************************************************************************************
    @methodname   	sendPromotionTacticDailyMeasureReal
    @createdDate  	03/18/2023
    @param			jsonBody
    @description  	Method to callout Account Product Measure Table
    **********************************************************************************************************/
    public static void sendAccountProductMeasure(String jsonBody){
        
        // Calling Account Product Measure POST API
        // Set Endpoint, Header and Body 
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        String transactionId = registerTransactionId(1);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint('callOut:TPM_Hyperforce_Send_Account_Product_Measure'+'?transaction='+transactionId);
        
        // Set the Request Body
        req.setBody(jsonBody);
        
        Http https = new Http();
        HttpResponse response = https.send(req);
        
        // Check the Response
        if(response.getStatusCode() != 200) {
            List<TPM_LoggerException.LogsWrapper> exceptionWrapperList =new List<TPM_LoggerException.LogsWrapper>();
            TPM_LoggerException.LogsWrapper logsObj = new TPM_LoggerException.LogsWrapper();
            logsObj.className = TPM_ConstantsUtility.TPM_DISPLAY_SHIPPER_COMPONENT;
            logsObj.methodName = TPM_ConstantsUtility.SEND_ACCOUNT_PRODUCT_MEASURE;
            logsObj.errorMessage = TPM_ConstantsUtility.SEND_ACCOUNT_PRODUCT_MEASURE_ERROR +' '+response.getStatusCode() + ' ' +response.getStatus();
            exceptionWrapperList.add(logsObj);
            TPM_LoggerException.log(exceptionWrapperList);
        }
    }
    
    /*******************************************************************************************************
    * @Name         : ResultValueWrapper
    * @author       : PwC Team
    * @date         : 03/24/2023
    * @description  : ResultValueWrapper Class to hold Months to Day Values.
    *                 childId - Child Product SFDC ID
    *                 parentId - Parent Product SFDC ID
    *                 childExtId -Child Product External ID
    *                 convertedChildValList - List of Converted Product Parts Values
    *******************************************************************************************************/
    public class ResultValueWrapper{
        public String childId;
        public String parentId;
        public string childExtId;
        public List<Double> convertedChildValList;
    }
    
    /*******************************************************************************************************
    * @Name         : TransformedValuesWrapper
    * @author       : PwC Team
    * @date         : 03/24/2023
    * @description  : TransformedValuesWrapper Class to hold the final Tranformed Months to Day Values for 
    * 				  Child Products.
    **********************************************************************************************************/
    public class TransformedValuesWrapper{
        public string childProductPartId;
        public string childProductExtId;
        public List<Double> finalConvertedChildValList;
        public string fromYear;
        public string fromMonth;
    }
}