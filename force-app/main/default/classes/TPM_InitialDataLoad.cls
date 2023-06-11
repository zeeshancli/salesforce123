/*******************************************************************************************************
* @Name         : TPM_InitialDataLoad
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : This Apex is used for automating data load in salesforce TPM.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

    public with sharing class TPM_InitialDataLoad {

    /*********************************************************************************
    * @method         : TPM_InitialDataLoad
    * @description    : Constructor
    **********************************************************************************/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_InitialDataLoad(){


    }
        
    /*********************************************************************************
    * @method         : tpmInitialDataLoadCall
    * @param            orgList
    * @param            valFromUi
    * @description    : Main class which calls corresponding methods to create records based on objects passed as
    *                   parameter by admin. If parameter for object passed as all then records for all object
    *                   will be created
    **********************************************************************************/
        public static void tpmInitialDataLoadCall(Set<String> orgList , List<string> valFromUi){
       //Checks which method is called for inserting records
        TPMInitialDataLoadWrapper wrapperToHoldWhichObjectPassed = new TPMInitialDataLoadWrapper();
        // Get list of objects and salesorg to be inserted from UI 
         for(String valuePassed:valFromUi ){
            switch on valuePassed {
                when 'All' {	
                    //When all break the loop	
                    wrapperToHoldWhichObjectPassed.isAll = true;
                    break;
                }
                when 'weekday' {	
                    //make weekday as true	
                    wrapperToHoldWhichObjectPassed.isweekDay = true;
                continue;
                }
                when 'salesorg' {	
                    //make salesorg as true	
                    wrapperToHoldWhichObjectPassed.isSalesOrg = true;
                    continue;
                }
                when 'ProductTemplate' {	
                    //make ProductTemplate as true		
                    wrapperToHoldWhichObjectPassed.isProductTemp = true;
                    continue;
                }
                when 'CustomerTemplate' {	
                    //make CustomerTemplate as true	
                    wrapperToHoldWhichObjectPassed.isCustomerTemp = true;
                continue;
                }
                when 'CustomPeriod'{	
                    //make CustomPeriod as true	
                    wrapperToHoldWhichObjectPassed.isCustPeriod = true;
                continue;
                }
                when 'CustomCalendar' {	
                    //make CustomCalendar as true	
                    wrapperToHoldWhichObjectPassed.isCustCale = true;
                    continue;
                }
                when 'BusinessYear' {	
                    //make BusinessYear as true	
                    wrapperToHoldWhichObjectPassed.isBusYear = true;
                    continue;
                }
                when 'Metadatawizard' {	
                    //make Metadatawizard as true	
                    wrapperToHoldWhichObjectPassed.isMetDataWizard = true;
                    continue;
                }
                when 'Productassortmenttemplate' {	
                    //make Productassortmenttemplate as true	
                    wrapperToHoldWhichObjectPassed.isProductAssortTemp = true;
                continue;
                }
                when 'KPISet' {		
                    //make KPISet as true
                    wrapperToHoldWhichObjectPassed.isKpiSet = true;
                    continue;
                }
            }
        }
               TPM_InitialDataLoad.callMethods(wrapperToHoldWhichObjectPassed,orgList);
               TPM_InitialDataLoad.callMethodsNext(wrapperToHoldWhichObjectPassed,orgList);
        }
        
    /*********************************************************************************
    * @method         : callMethods
    * @param            wrapperToHoldWhichObjectPassed
    * @param            orgList
    * @description    : Based on objects and sales org passed as parameter by admin call
    *                   corresponding methods to create records 
    **********************************************************************************/
        public static void callMethods(TPMInitialDataLoadWrapper wrapperToHoldWhichObjectPassed,set<string> orgList){
        
         try{   
        if(wrapperToHoldWhichObjectPassed.isweekDay == true){
            //works for weekday profile
            TPM_InitialDataLoadWeekday.weekDayProfileLoad(orgList);
        }
        if(wrapperToHoldWhichObjectPassed.isMetDataWizard == true){
            //works for meta data wizard
            TPM_InitialDataLoadWizardAssort.metaWizardLoad(orgList);
        }
        if(wrapperToHoldWhichObjectPassed.isSalesOrg == true){
            //works for salesorg load
            TPM_InitialDataLoadsalesOrg.salesOrgLoad(orgList);
        }
        if(wrapperToHoldWhichObjectPassed.isBusYear == true){
            //works for business year
            TPM_InitialDataLoadBYearCustomCal.businessYearLoad(orgList);
        }
        if(wrapperToHoldWhichObjectPassed.isCustCale == true){
            //works for custom calendar
            TPM_InitialDataLoadBYearCustomCal.customCalendarLoad(orgList);
        }
     

    }

    catch(Exception exp) {
        //error logging operations
        TPM_InitialDataLoad.catchExcep(exp);
    }
       
    }
    /*********************************************************************************
    * @method         : callMethodsNext
    * @param            wrapperToHoldWhichObjectPassed
    * @param            orgList
    * @description    : Based on objects and sales org passed as parameter by admin call
    *                   corresponding methods to create records 
    **********************************************************************************/
        public static void callMethodsNext(TPMInitialDataLoadWrapper wrapperToHoldWhichObjectPassed,Set<String> orgList){
            
            
            try{
            
            if(wrapperToHoldWhichObjectPassed.isProductTemp == true){
                    //works for Product Template
                    TPM_InitialDataLoadCustomerProductTemp.productTemplateLoad(orgList);
                }
            if(wrapperToHoldWhichObjectPassed.isCustPeriod == true){
                //works for custom period
                TPM_InitialDataLoadCustomPeriod.customPeriodUpload(orgList);
            }
            if(wrapperToHoldWhichObjectPassed.isCustomerTemp == true){
                //works for custom period
                TPM_InitialDataLoadCustomerProductTemp.customerTemplateLoad(orgList);
            }
            
            if(wrapperToHoldWhichObjectPassed.isProductAssortTemp == true){
                //works for Product Assortment Template
                TPM_InitialDataLoadWizardAssort.productAssortmentLoad(orgList);
            }
            if(wrapperToHoldWhichObjectPassed.isKpiSet == true){
                //works for KPI set
                TPM_InitialDataLoadKPISet.kpiSetLoad(orgList);
            }
            if (wrapperToHoldWhichObjectPassed.isAll == true){
                //inserts records for all objects
                TPM_InitialDataLoadWeekday.weekDayProfileLoad(orgList);
                TPM_InitialDataLoadWizardAssort.metaWizardLoad(orgList);
                TPM_InitialDataLoadsalesOrg.salesOrgLoad(orgList);
                TPM_InitialDataLoadKPISet.kpiSetLoad(orgList);
                TPM_InitialDataLoadBYearCustomCal.businessYearLoad(orgList);
                TPM_InitialDataLoadCustomerProductTemp.productTemplateLoad(orgList);
                TPM_InitialDataLoadBYearCustomCal.customCalendarLoad(orgList);
                TPM_InitialDataLoadCustomPeriod.customPeriodUpload(orgList);
                TPM_InitialDataLoadCustomerProductTemp.customerTemplateLoad(orgList);
                TPM_InitialDataLoadWizardAssort.productAssortmentLoad(orgList);
            }
        }
        catch(Exception exp) {
            //error logging operations
            TPM_InitialDataLoad.catchExcep(exp);
        }
        }

        /*********************************************************************************
    * @method         : catchExcep
    * @param            exp
    * @description    : Based on objects and sales org passed as parameter by admin call
    *                   corresponding methods to create records 
    **********************************************************************************/

    public static void catchExcep(Exception exp){
    
    TPM_Utils.createException(exp,TPM_ConstantsUtility.ERROR,TPM_AutomationConstantUtilityClass.TPMINITIALDATALOAD);
    }   
}