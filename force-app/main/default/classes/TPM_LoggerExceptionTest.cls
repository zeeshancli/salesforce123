/******************************************************************************************************
* @Name         : TPM_LoggerExceptionTest
* @Author       : PwC Team
* @date         : December 23, 2022
* @description  : TPM_LoggerException class Test class
******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@isTest
public class TPM_LoggerExceptionTest {
    public static final string EXP_MSG = 'Records found';
    
    /******************************************************************************************
    * @method			: exceptionErrorTest
    * @ param     		  none
    * @description    	: Method to test normal exceptions
    * 					  
    ******************************************************************************************/
    @isTest
    public static void exceptionErrorTest() {
        
        //Insert Accounts without required fields
        try {
            Account acc = new Account();
            insert acc;
        } catch (Exception exp) {
            TPM_LoggerException.LogsWrapper wrap = new TPM_LoggerException.LogsWrapper();
            wrap.exceptionObj = exp;
            wrap.logLevel = 'Error';
            
            //Call the TPM_LoggerException class log method
            TPM_LoggerException.log(new List<TPM_LoggerException.LogsWrapper>{wrap});
        }
        List<TPM_Logger__c> loggerObjList = [SELECT	Id, 
                                             		Name,
                                             		TPM_LogLevel__c,
                                             		TPM_StackTrace__c
                                             FROM	TPM_Logger__c
                                             WHERE	TPM_LogLevel__c ='Error'];
        System.assertEquals(false, loggerObjList.isEmpty(),EXP_MSG);
    }
    
   /******************************************************************************************
    * @method			: databaseDMLErrorTest
    * @ param     		  none
    * @description    	: Method to test Database DML Exceptions  				  
    ******************************************************************************************/
    @isTest
    public static void databaseDMLErrorTest(){
        
        List<Account> accToCreateList = new List<Account>();
        TPM_LoggerException.LogsWrapper wrap = new TPM_LoggerException.LogsWrapper();
        
        //Insert Bulk Accounts without required fields
        for(Integer cnt = 1;cnt <= 200;cnt++){
            Account acc = new Account();
            accToCreateList.add(acc);
        }
        
        //Insert Bulk Accounts without required fields
        Database.SaveResult[] insertAccSRList = Database.insert(accToCreateList,false);
        
        //Iterate over the inserted records
        for(Database.SaveResult result : insertAccSRList) {
            if(!result.isSuccess()) {
                wrap.logLevel = 'Error';
                wrap.className = 'TestClass';
                wrap.methodName = 'testMethod';
                wrap.errors = result.getErrors();
            }
        }
        
        //Call the TPM_LoggerException class log method
        TPM_LoggerException.log(new List<TPM_LoggerException.LogsWrapper>{wrap});
        List<TPM_Logger__c> loggerObjList = [SELECT	Id, 
                                             		Name,
                                             		TPM_LogLevel__c,
                                             		TPM_StackTrace__c
                                             FROM	TPM_Logger__c
                                             WHERE	TPM_ClassName__c ='TestClass'
                                             AND 	TPM_MethodName__c ='testMethod'];
        System.assertEquals(false, loggerObjList.isEmpty(),EXP_MSG);
    }
    
    /******************************************************************************************
    * @method			: logErrorTest
    * @ param     		  none
    * @description    	: Method to test log run once method in loggerclass  				  
    ******************************************************************************************/
    @isTest
    public static void logErrorTest(){
        
         //Call the TPM_LoggerException class log method
        TPM_LoggerException.log(new List<TPM_LoggerException.LogsWrapper>{null});
        List<TPM_Logger__c> loggerObjList = [SELECT	Id, 
                                             		Name,
                                             		TPM_LogLevel__c,
                                             		TPM_FlowName__c,
                                             		TPM_StackTrace__c
                                             FROM	TPM_Logger__c
                                             WHERE	TPM_FlowName__c ='Logger Module'];
        System.assertEquals(false, loggerObjList.isEmpty(),EXP_MSG);
        
    }
    
	/******************************************************************************************
    * @method			: customErrorTest
    * @ param     		  none
    * @description    	: Method to test custom errors				  
    ******************************************************************************************/
    @isTest
    public static void customErrorTest(){
        List<Product2> createProdList = new List<Product2>();
        for(Integer cnt=1;cnt<=200;cnt++){
            Product2 prodObj = new Product2();
            prodObj.Name = 'Test Product'+' '+cnt;
            prodObj.TPM_SAP_Sales_Org__c = 'US09';
            prodObj.cgcloud__Consumer_Goods_External_Product_Id__c = 'CGPRID'+cnt;
            prodObj.cgcloud__Consumer_Goods_Product_Code__c = 'CGPRC'+cnt;
            prodObj.cgcloud__Description_1_Language_1__c = 'Test Product'+' '+cnt;
            prodObj.cgcloud__Product_Level__c = 'Product';
            prodObj.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
            createProdList.add(prodObj);
        }
        
        //Insert the test data list of Product Records
        if(!createProdList.isEmpty()){
            Database.insert(createProdList,false);
        }
        
        TPM_LoggerException.LogsWrapper wrap = new TPM_LoggerException.LogsWrapper();
        wrap.logLevel = 'Error';
        wrap.errorMessage ='Custom Error Log Test';
        
        //Call the TPM_LoggerException class log method
        TPM_LoggerException.log(new List<TPM_LoggerException.LogsWrapper>{wrap});
        List<TPM_Logger__c> loggerObjList = [SELECT	Id, 
                                             		Name,
                                             		TPM_LogLevel__c,
                                             		TPM_FlowName__c,
                                             		TPM_ExceptionMessage__c,
                                             		TPM_StackTrace__c
                                             FROM	TPM_Logger__c
                                             WHERE	TPM_LogLevel__c ='Error'
                                             LIMIT 	1];
        System.assertEquals('Custom Error Log Test',loggerObjList[0].TPM_ExceptionMessage__c,'Exception Message'); 
    }
}