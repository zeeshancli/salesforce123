/******************************************************************************************************
* @Name         : TPM_CustomerHierarchyBatchUtils
* @Test Class   : 
* @author       : PwC Team
* @date         : Feb 6 , 2023
* @description  : Helper class for batch apex - 'TPM_CustomerHierarchyBatch'
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

public with sharing class TPM_CustomerHierarchyBatchUtils {


    /********************************************************************************************************
    * @method          fetchCustHierarchyStageDetail
    * @param           chsChildExtIdSet
    * @return          Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>>
    * @description     Method to fetch customer hierarchy staging records based on child customer ext ids.
    ********************************************************************************************************/
    public static Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>> fetchCustHierarchyStageDetail(Set<String> chsChildExtIdSet){

        Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>> childExIdToCHSIdWithCHSRecordMap = new Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>>();

        // To fetch existing customer hierarchy staging records using child customer ext ids.
        if(!chsChildExtIdSet.isEmpty()){
            for(TPM_Customer_Hierarchy_Staging__c chsObj : [SELECT  Id, 
                                                                    Name, 
                                                                    TPM_Child_Cust_ID__c, 
                                                                    TPM_Parnt_Cust_ID__c,
                                                                    TPM_Cust_Hrchy_Strt_Dt__c,
                                                                    TPM_Cust_Hrchy_End_DT__c, 
                                                                    TPM_Convert_Status__c    
                                                        FROM TPM_Customer_Hierarchy_Staging__c 
                                                        WHERE TPM_Child_Cust_ID__c IN: chsChildExtIdSet 
                                                        AND TPM_Convert_Status__c =: TPM_ConstantsUtility.CUST_HS_STATUS_NEW   
                                                        ORDER BY TPM_Child_Cust_ID__c, CreatedDate ASC]){

                String childExtString = chsObj.TPM_Child_Cust_ID__c;                                            
                if(!childExIdToCHSIdWithCHSRecordMap.containsKey(childExtString)){
                    childExIdToCHSIdWithCHSRecordMap.put(childExtString, new Map<String, TPM_Customer_Hierarchy_Staging__c>{});
                }                                            
                childExIdToCHSIdWithCHSRecordMap.get(childExtString).put(chsObj.Id, chsObj);
            }
        }    
        
        return childExIdToCHSIdWithCHSRecordMap;
    }


    /****************************************************************************************************
    * @method          fetchCTOHierarchyDetail
    * @param           chsChildExtIdSet
    * @return          Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>>
    * @description     Method to fetch CTO hierarchy records based on child customer ext ids.
    ****************************************************************************************************/
    public static Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>> fetchCTOHierarchyDetail(Set<String> chsChildExtIdSet){

        Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>> childExIdToCHSIdWithCTOMap = new Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>>();

        if(!chsChildExtIdSet.isEmpty()){
            for(cgcloud__Account_Trade_Org_Hierarchy__c ctoObj : [SELECT Id, 
                                                                         Name, 
                                                                         cgcloud__Child_Account__c, 
                                                                         cgcloud__Parent_Account__c, 
                                                                         cgcloud__Valid_From__c, 
                                                                         cgcloud__Valid_Thru__c, 
                                                                         TPM_CHSRecordId__c, 
                                                                         cgcloud__Child_Account__r.TPM_SAP_External_ID__c 
                                                                 FROM cgcloud__Account_Trade_Org_Hierarchy__c 
                                                                 WHERE cgcloud__Child_Account__r.TPM_SAP_External_ID__c IN: chsChildExtIdSet 
                                                                 AND TPM_CHSRecordId__c != NULL 
                                                                 ORDER BY cgcloud__Child_Account__r.TPM_SAP_External_ID__c, CreatedDate ASC]){

                String childExtString = ctoObj.cgcloud__Child_Account__r.TPM_SAP_External_ID__c;                                            
                if(!childExIdToCHSIdWithCTOMap.containsKey(childExtString)){
                    childExIdToCHSIdWithCTOMap.put(childExtString, new Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>{});
                }                                            
                childExIdToCHSIdWithCTOMap.get(childExtString).put(ctoObj.TPM_CHSRecordId__c, ctoObj);
            }
        }    
        
        return childExIdToCHSIdWithCTOMap;
    }


    /******************************************************************************************************
    @method          isTimeFrameOverlapAtCHS
    @return          Boolean
    @param           chsRecord
    @param           childExIdToCHSIdWithCHSRecordMap
    @description     Method to check date range overlap at CHS level
    *******************************************************************************************************/
    public static CHWrapper isTimeFrameOverlapAtCHS(TPM_Customer_Hierarchy_Staging__c chsRecord, Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>> childExIdToCHSIdWithCHSRecordMap){

        CHWrapper returnWrap = new CHWrapper();
        returnWrap.recordId = chsRecord.Id;

        if(!childExIdToCHSIdWithCHSRecordMap.isEmpty() && childExIdToCHSIdWithCHSRecordMap.containsKey(chsRecord.TPM_Child_Cust_ID__c)){

            returnWrap = timeFrameOverlapAtCHSHelper(chsRecord, childExIdToCHSIdWithCHSRecordMap);
        }

        return returnWrap;
    }
    

    /***************************************************************************************************************
    @method          timeFrameOverlapAtCHSHelper
    @return          CHWrapper
    @param           chsRecord
    @param           childExIdToCHSIdWithCHSObjMap
    @description     Helper method to check date range overlap at CHS level
    ****************************************************************************************************************/   
    public static CHWrapper timeFrameOverlapAtCHSHelper(TPM_Customer_Hierarchy_Staging__c chsRecord,  Map<String, Map<String, TPM_Customer_Hierarchy_Staging__c>> childExIdToCHSIdWithCHSObjMap){

        CHWrapper wrapObj = new CHWrapper();
        wrapObj.recordId = chsRecord.Id;

        for(String custStagingId : childExIdToCHSIdWithCHSObjMap.get(chsRecord.TPM_Child_Cust_ID__c).keySet()){
     
            TPM_Customer_Hierarchy_Staging__c existingCHSRecord = childExIdToCHSIdWithCHSObjMap.get(chsRecord.TPM_Child_Cust_ID__c).get(custStagingId);
            if(chsRecord.Id != custStagingId && chsRecord.TPM_Cust_Hrchy_Strt_Dt__c != null && chsRecord.TPM_Cust_Hrchy_End_DT__c != null){
                wrapObj.existingRecordIdSet.add(custStagingId);
                wrapObj.isOverlap = TPM_Utils.isRangeOverlap(existingCHSRecord.TPM_Cust_Hrchy_Strt_Dt__c, 
                                                                  existingCHSRecord.TPM_Cust_Hrchy_End_DT__c, 
                                                                  chsRecord.TPM_Cust_Hrchy_Strt_Dt__c, 
                                                                  chsRecord.TPM_Cust_Hrchy_End_DT__c);
                if(wrapObj.isOverlap){
                    break;
                }
            }
        }

        return wrapObj;

    }


    /**********************************************************************************************************
    @method          isTimeFrameOverlapAtCTOObj
    @return          CHWrapper
    @param           chsRecord
    @param           existingCHSSameChidlIdSet
    @param           childExIdToCHSIdWithCTOMap
    @description     Method to check date range overlap at CTO hierarchy level
    ***********************************************************************************************************/
    public static CHWrapper isTimeFrameOverlapAtCTOObj(TPM_Customer_Hierarchy_Staging__c chsRecord, Set<String> existingCHSSameChidlIdSet, Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>> childExIdToCHSIdWithCTOMap){

        CHWrapper returnWrap = new CHWrapper();
        returnWrap.recordId = chsRecord.Id;
       
        if(childExIdToCHSIdWithCTOMap.containsKey(chsRecord.TPM_Child_Cust_ID__c)){

            returnWrap = timeFrameOverlapAtCTOHelper(chsRecord, existingCHSSameChidlIdSet, childExIdToCHSIdWithCTOMap);  
        }

        return returnWrap;
    }


    /*****************************************************************************************************************
    @method          timeFrameOverlapAtCTOHelper
    @return          CHWrapper
    @param           chsRecord
    @param           existingCHSSameChidlIdSet
    @param           childExIdToCHSIdWithCTOMap
    @description     Helper method to check date range overlap at CTO hierarchy level
    ******************************************************************************************************************/   
    public static CHWrapper timeFrameOverlapAtCTOHelper(TPM_Customer_Hierarchy_Staging__c chsRecord,  Set<String> existingCHSSameChidlIdSet, Map<String, Map<String, cgcloud__Account_Trade_Org_Hierarchy__c>> childExIdToCHSIdWithCTOMap){

        CHWrapper wrapObj = new CHWrapper();
        wrapObj.recordId = chsRecord.Id;

        for(String custStagingId : childExIdToCHSIdWithCTOMap.get(chsRecord.TPM_Child_Cust_ID__c).keySet()){
     
            cgcloud__Account_Trade_Org_Hierarchy__c existingCTOecord = childExIdToCHSIdWithCTOMap.get(chsRecord.TPM_Child_Cust_ID__c).get(custStagingId);
            if(chsRecord.Id != custStagingId && !existingCHSSameChidlIdSet.contains(custStagingId) && chsRecord.TPM_Cust_Hrchy_Strt_Dt__c != null && chsRecord.TPM_Cust_Hrchy_End_DT__c != null){
                wrapObj.isOverlap = TPM_Utils.isRangeOverlap(existingCTOecord.cgcloud__Valid_From__c, 
                                                             existingCTOecord.cgcloud__Valid_Thru__c, 
                                                             chsRecord.TPM_Cust_Hrchy_Strt_Dt__c, 
                                                             chsRecord.TPM_Cust_Hrchy_End_DT__c);
                if(wrapObj.isOverlap){
                    break;
                }
            }
        }

        return wrapObj;
    }


    /******************************************************************
    * @Name            CHWrapper
    * @description     Wrapper class to store hierarchy staging data
    ******************************************************************/
    public class CHWrapper{

        public String recordId;
        public Boolean isOverlap;
        public Set<String> existingRecordIdSet;

        /**************************************************
        @method          CHWrapper
        @description     Constructor
        ***************************************************/ 
        public CHWrapper(){
            this.recordId = null;
            this.isOverlap = false;
            this.existingRecordIdSet = new Set<String>();
        }

    }

}