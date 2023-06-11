/*******************************************************************************************************
* @Name         : TPMInitialDataLoadWrapper
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : Wrapper class for TPM_InitialDataLoad.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPMInitialDataLoadWrapper {
    
    public  Set<String> salesOrgval;
    public  Boolean isAll;
    public  Boolean isSalesOrg;
    public  Boolean isweekDay;
    public  Boolean isProductTemp;
    public  Boolean isCustomerTemp;
    public  Boolean isBusYear;
    public  Boolean isCustCale;
    public  Boolean isCustPeriod;
    public  Boolean isMetDataWizard;
    public  Boolean isProductAssortTemp;
    public  Boolean isKpiSet;

/*********************************************************************************
     *  @Name         : TPMInitialDataLoadWrapper1
     *  @Author       : PwC Team
     *  @Date         : December 22, 2022
     *  @description  : Wrapper class for TPM_InitialDataLoad for customer Template.
    **********************************************************************************/
public class TPMInitialDataLoadWrapper1 {

      public Map<String,TPM_Initial_Data_Load__mdt> metaDataRecordMap;
      public Map<String,String> salesOrgPlanningModeMap;
      public Map<Map<String,String>,String> salesOrgPlanningModeProductLevelMap;
      public Map<Map<String,String>,String> salesOrgInitialRoleMap;
      
    
    /*********************************************************************************
    * @method         : tpmInitialDataLoadWrapper1
    * @param            salesOrgMap
    * @param            productLevelMap
      * @param          productLevelValMap
    * @param            initialRoleMap
    * @description    : Constructor
    *********************************************************************************/ 
    public tpmInitialDataLoadWrapper1 (Map<String,TPM_Initial_Data_Load__mdt> salesOrgMap, Map<String,String> productLevelMap,Map<Map<String,String>,String> productLevelValMap,Map<Map<String,String>,String> initialRoleMap){

        this.metaDataRecordMap =salesOrgMap;
        this.salesOrgPlanningModeMap = productLevelMap;
        this.salesOrgPlanningModeProductLevelMap = productLevelValMap;
        this.salesOrgInitialRoleMap = initialRoleMap;
    }

}

  
}