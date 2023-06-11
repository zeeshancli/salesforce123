/*******************************************************************************************************
    * @Name         : TPM_Wrapper_OverLapCheck_Ext
    * @Unit Test    : TPM_Wrapper_OverLapCheckTest
    * @Author       : PwC Team
    * @Date         : March 23, 2023
    * @description  : Wrapper class for OverlapCheck.
    *******************************************************************************************************
    Change History Story      Modified by               Date                          Desc

    *******************************************************************************************************/
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public with sharing class TPM_Wrapper_OverLapCheck_Ext {
    
    
  
    /*********************************************************************************
      * @method         : ProdCustomLabelData
      * @description    : Constructor
    *********************************************************************************/ 
      public class ProdCustomLabelData {

        public List<cgcloud__Promotion__c>  promotionData ;
        public Map<String,String>  label;
      }  

       /*********************************************************************************
      * @method         : ProdCustomLabelDataPushPromo
      * @description    : Constructor
    *********************************************************************************/ 
    public class ProdCustomLabelDataPushPromo {

      public List<cgcloud__Promotion__c>  promotionData ;
      public Map<String,String>  label;
      public List<String>  parentPromotionTemplates;
    }  

    /*********************************************************************************
    * @method         : ProdResponseData
    * @description    : Constructor
    *********************************************************************************/ 
    public class ProdResponseData {
      public Set<String> productData ;
      public  Map<String,Object>  responseBodyValue;
    }  

    /*********************************************************************************
    * @method         : ResponseBody
    * @description    : Constructor
    *********************************************************************************/ 
    public class ResponseBody {
      public String promotionId;
      public String tacticId;
      public String promotionName;
      public String tacticName;
      public String product;
      public Date shipmentDateFrom;
      public Date shipmentDateThrough;
      public Boolean isOverlap;
      
    }

     /*********************************************************************************
    * @method         : ResponseBodyNew
    * @description    : Constructor
    *********************************************************************************/ 
    public class ResponseBodyNew {
      public String accountId;
      public String promotionId;
      public String tacticId;
      public String promotionName;
      public String tacticName;
      public String product;
      public Date shipmentDateFrom;
      public Date shipmentDateThrough;
      public Boolean isOverlap;
      
    }


    /*********************************************************************************
    * @method         : ResponseBodyNew
    * @description    : Constructor
    *********************************************************************************/ 
    public class ParentChildWrapper {
      public Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew> childPromotions;
      public Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> parentPromotions;
    
      
    }

    /*********************************************************************************
    * @method         : overLapMetaDataWrapper
    * @description    : Constructor
    *********************************************************************************/ 
    public class OverLapMetaDataWrapper {
      public Map<String,List<String>> childPromotionTemplates;
      public List<String> templateForOverLapChecks;
    
      
    }


}