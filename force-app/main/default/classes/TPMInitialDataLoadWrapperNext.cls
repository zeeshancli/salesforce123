/*******************************************************************************************************
* @Name         : TPMInitialDataLoadWrapperNext
* @Unit Test    : TPM_InitialDataLoadTest
* @Author       : PwC Team
* @Date         : December 22, 2022
* @description  : Wrapper class for TPM_InitialDataLoad.
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
public with sharing class TPMInitialDataLoadWrapperNext {
    /*********************************************************************************
     *  @Name         : TPMInitialDataLoadWrapperKpi
     *  @Author       : PwC Team
     *  @Date         : December 22, 2022
     *  @description  : Wrapper class for TPM_InitialDataLoad for KPI set.
    **********************************************************************************/
public class TPMInitialDataLoadWrapperKpi {

    public Map<String,String> kpiRecNameIdMap;
    public Map<String,String> kpiRecNameSalesOrgMap;
    public Map<Map<String,String>,String> kpiRecNameSalesOrgAsKeyNameAsValueMap;
    
    /*********************************************************************************
    * @method         : tpmInitialDataLoadWrapperKpi
    * @param            recNameIdMap
    * @param            recNameSalesOrgMap
    * @param            recNameSalesOrgAsKeyNameAsValueMap
    * @description    : Constructor
    **********************************************************************************/
    public tpmInitialDataLoadWrapperKpi (Map<String,String> recNameIdMap, Map<String,String> recNameSalesOrgMap, Map<Map<String,String>,String> recNameSalesOrgAsKeyNameAsValueMap){

        this.kpiRecNameIdMap = recNameIdMap;
        this.kpiRecNameSalesOrgMap = recNameSalesOrgMap;
        this.kpiRecNameSalesOrgAsKeyNameAsValueMap = recNameSalesOrgAsKeyNameAsValueMap;
    }

}

/*********************************************************************************
     *  @Name         : TPMInitialDataKpi
     *  @Author       : PwC Team
     *  @Date         : December 22, 2022
     *  @description  : Wrapper class for TPM_InitialDataLoad for KPI Set assignment to customer template.
    **********************************************************************************/
public class TPMInitialDataKpi {

    public Map<Map<String,String>,String> kpiRecAssignedCustomerTempIdMap;
    public Map<Map<String,String>,String> kpiIdMap;
    
    /*********************************************************************************
    * @method         : TPMInitialDataKpi
    * @param            recAssignedCustomerTempIdMap
    * @param            recAssignedCustomerTempMap
    * @description    : Constructor
    **********************************************************************************/
    public tpmInitialDataKpi (Map<Map<String,String>,String> recAssignedCustomerTempIdMap, Map<Map<String,String>,String> recAssignedCustomerTempMap){

        this.kpiRecAssignedCustomerTempIdMap =recAssignedCustomerTempIdMap;
        this.kpiIdMap = recAssignedCustomerTempMap;
    }

}

}