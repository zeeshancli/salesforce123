/*******************************************************************************************************
    * @Name         : TPM_Wrapper_OverLapCheck
    * @Unit Test    : TPM_Wrapper_OverLapCheckTest
    * @Author       : PwC Team
    * @Date         : March 23, 2023
    * @description  : Wrapper class for OverlapCheck.
    *******************************************************************************************************
    Change History Story      Modified by               Date                          Desc

    *******************************************************************************************************/
    public with sharing class TPM_Wrapper_OverLapCheck {
      /*********************************************************************************
       *  @Name         : TPMInitialDataLoadWrapper1
       *  @Author       : PwC Team
       *  @Date         : December 22, 2022
       *  @description  : Wrapper class for OverlapCheck.
      **********************************************************************************/
      public class TPMOverLapMetadataWrapper {

        public List<String> prodTemplate;
        public List<String> tacticType;
        public List<String> phase;
        public List<String> promotionFieldsToHide;
        public List<String> tacticFieldsToHide;
      

    /*********************************************************************************
    * @method         : TPMOverLapMetadataWrapper
    * @param            prodTemplateSet
    * @param            tacticTypeSet
    * @param            phaseSet
    * @param            promotionFieldsList
    * @param            tacticFieldsList
    * @description    : Constructor
    *********************************************************************************/ 
    public TPMOverLapMetadataWrapper (List<String> prodTemplateSet,List<String> tacticTypeSet,List<String> phaseSet,List<String> promotionFieldsList,List<String> tacticFieldsList){

      this.prodTemplate =prodTemplateSet;
      this.tacticType = tacticTypeSet;
      this.phase = phaseSet;
      this.promotionFieldsToHide = promotionFieldsList;
      this.tacticFieldsToHide = tacticFieldsList;
    }

  }

    
    /*********************************************************************************
    * @method         : TPMOverLapCheckWrapper
    * @description    : Constructor
    *********************************************************************************/ 
    public class TPMOverLapCheckWrapper {

      public  Set<String> accId;
      public  Set<String> promoTemp;
      public  Map<String,String> promoSalesOrgMap;
      public  Map<String,String> promoTemplateMap;
      public  Map<String,cgcloud__Promotion__c> promoRecIdRecordMap;

    /*********************************************************************************
    * @method         : TPMOverLapCheckWrapper
    * @param            accIdSet
    * @param            promoTempSet
    * @param            promSalesOrgMap
    * @param            promTemplateMap
    * @param            promRecIdRecordMap
    * @description    : Constructor
    *********************************************************************************/ 
    public TPMOverLapCheckWrapper (Set<String> accIdSet,Set<String> promoTempSet,Map<String,String> promSalesOrgMap,Map<String,String> promTemplateMap, Map<String,cgcloud__Promotion__c> promRecIdRecordMap){
      this.accId =accIdSet;
      this.promoTemp = promoTempSet;
      this.promoSalesOrgMap = promSalesOrgMap;
      this.promoTemplateMap = promTemplateMap;
      this.promoRecIdRecordMap = promRecIdRecordMap;
      }
    }

      
    }