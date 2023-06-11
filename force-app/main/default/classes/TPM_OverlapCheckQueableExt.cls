/******************************************************************************************************
@Name            TPM_OverlapCheckQueableExt
@testclass       TPM_OverlapCheckQueableExt
@Author          PwC Team
@date            April 28, 2023
@description     Perform Overlap check for Push Promotion
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class TPM_OverlapCheckQueableExt {
   

    /******************************************************************************************************** 
    @methodname 	getExternalId
	@param          targetAccountRecord
    @return         List<String>
    @description	method to fetch account ids od child promotions for overlap checks
    *********************************************************************************************************/ 
    public static List<String> getExternalId(String targetAccountRecord) {
        Set<String> externalIdSet = new Set<String>();
        List<String> childAccIdListTemp = new List<String>();
        //Get the child proomtions accounts which are considered for push
        for(String eachMAAcc  : targetAccountRecord.replaceAll('^\\[|\\]$', '').replaceAll('^\\{|\\}$', '').split('\\}\\,\\{')){
     
                if(eachMAAcc.contains('true')){
                    externalIdSet.add(eachMAAcc.substring(30,eachMAAcc.length()-1));
                }
        }
        
        //get id of accounst based on external id
        for(Account acc : [SELECT 
                                Id, 
                                Name, 
                                TPM_Hierarchy_Level__c,
                                cgcloud__ExternalId__c
                                FROM Account 
                                WHERE 
                                cgcloud__ExternalId__c IN : externalIdSet]){

                childAccIdListTemp.add(acc.Id);
            }
        return childAccIdListTemp;
    }

  
  

 /******************************************************************************************************** 
    @methodname 	getProductsOfParentPromo
	@param          resultMap
    @return         Set<String>
    @description	method to fetch products of parent promotion.
    *********************************************************************************************************/ 
    public static Set<String> getProductsOfParentPromo(Map<String,Object> resultMap) {

        Set<String> productSetTemp = new Set<String>();
            
             //Based on response collect prodycts in a set
             for(Object obj : ( List< Object > )resultMap.get( 'measures' )){
                     Map < String, Object > keyValPairMap = ( Map < String, Object > )obj;
                     if(string.isNotBlank(((String)keyValPairMap.get('prd')))){
                        productSetTemp.add((String)keyValPairMap.get('prd'));
                        }
                 }
            
             return productSetTemp;
        }



    /********************************************************************************************************   
    @methodname 	getChildOverlapDetails
	@param          overlapPromoListTemp
    @param          childPromoAccountIdMap
    @return         List<cgcloud__Promotion__c>
    @description	method to update child and parent promotions with overlap details
    *********************************************************************************************************/ 
    public static List<cgcloud__Promotion__c> getChildOverlapDetails(Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew> overlapPromoListTemp,Map<String,String> childPromoAccountIdMap) {
        
        Map<String,Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew>> childOverlapDetailsListTemp = new Map<String,Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew>>();
        List<cgcloud__Promotion__c> finalChildPromoListTemp = new List<cgcloud__Promotion__c>();
        //Loop overlapped promotion details and create a map of account id and overllaped record
        for(TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew overlapRec : overlapPromoListTemp){
                if(!childOverlapDetailsListTemp.containsKey(childPromoAccountIdMap.get(overlapRec.accountId))){
                    // If product and tactic combination doesnot exist create a new record
                    childOverlapDetailsListTemp.put(childPromoAccountIdMap.get(overlapRec.accountId),new Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew>{(overlapRec)});
                        }
                    else{
                    // If product and tactic combination already exist update with new products
                    childOverlapDetailsListTemp.get(childPromoAccountIdMap.get(overlapRec.accountId)).add(overlapRec);
                }

        }
        
        //Loop all child promotions and update overlap details
        for(Id key: childOverlapDetailsListTemp.keySet()){
            cgcloud__Promotion__c chilsdPromoUpdate = new cgcloud__Promotion__c();
            chilsdPromoUpdate.id = key;
            chilsdPromoUpdate.TPM_Overlap_Details__c = JSON.serialize(childOverlapDetailsListTemp.get(key));
            chilsdPromoUpdate.cgcloud__Skip_Version_Update__c = true;
            chilsdPromoUpdate.TPM_Overlap_Check_In_Progress__c = false;
            chilsdPromoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.OVERLAPFOUND;
            chilsdPromoUpdate.TPM_OverLap_Check_Status__c = TPM_ConstantsUtility.OVERLAPFOUND;
            chilsdPromoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
            chilsdPromoUpdate.cgcloud__Active__c = false;
            finalChildPromoListTemp.add(chilsdPromoUpdate);
            }

            for(Id key: childPromoAccountIdMap.keySet()){
                if(!childOverlapDetailsListTemp.containsKey(childPromoAccountIdMap.get(key))){
                cgcloud__Promotion__c chilsdPromoUpdate = new cgcloud__Promotion__c();
                chilsdPromoUpdate.id = childPromoAccountIdMap.get(key);
                chilsdPromoUpdate.cgcloud__Skip_Version_Update__c = true;
                chilsdPromoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                chilsdPromoUpdate.cgcloud__Active__c = false;
                chilsdPromoUpdate.TPM_Push_Failed__c = false;
                chilsdPromoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                chilsdPromoUpdate.TPM_OverLap_Check_Status__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                chilsdPromoUpdate.TPM_Overlap_Details__c = null;
                chilsdPromoUpdate.TPM_Overlap_Check_In_Progress__c = false;
                finalChildPromoListTemp.add(chilsdPromoUpdate);
                }
            }

        return finalChildPromoListTemp;
    }

    /********************************************************************************************************   
    @methodname 	updateParentPromotion
	@param          overlapTacticPromoList
    @param          recordIdPromo
    @description	method to update parent promotion details.
    *********************************************************************************************************/ 
    public static void updateParentPromotion(Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticPromoList,String recordIdPromo) {
                   
        //Update parent promotion with overlap details
                    if(!overlapTacticPromoList.isEmpty()){
                    //If overlap found update active as false and status as overlap found
                    //and status as draft
                        cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                        promoUpdate.id = recordIdPromo;
                        promoUpdate.cgcloud__Skip_Version_Update__c = true;
                        promoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.OVERLAPFOUND;
                        promoUpdate.TPM_OverLap_Check_Status__c = TPM_ConstantsUtility.OVERLAPFOUND;
                        promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                        promoUpdate.cgcloud__Active__c = false;
                        promoUpdate.TPM_Push_Failed__c = false;
                        promoUpdate.TPM_Overlap_Check_In_Progress__c =false;
                        promoUpdate.TPM_Overlap_Details__c = JSON.serialize(overlapTacticPromoList);
                        Database.SaveResult saveResultVar = Database.update(promoUpdate);
                        //Publish event and receive on record page
                        publishEvent('Overlap Found',recordIdPromo);
                      }
                    else { 
                            //If no overlap found update active as true and status as No Overlap found and 
                            //status as planning
                            cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
                            promoUpdate.id = recordIdPromo;
                            promoUpdate.cgcloud__Skip_Version_Update__c = true;
                            promoUpdate.TPM_Overlap_Details__c = null;
                            promoUpdate.cgcloud__Active__c = true;
                            promoUpdate.TPM_Push_Failed__c = false;
                            promoUpdate.TPM_Overlap_Check_In_Progress__c =false;
                            promoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                            promoUpdate.TPM_OverLap_Check_Status__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                            Database.SaveResult saveResultVar = Database.update(promoUpdate);
                            //Publish event and receive on record page
                            publishEvent('No Overlap Found',recordIdPromo);
                        }

            }
    
    /********************************************************************************************************   
    @methodname 	updateParentChildPromotion
    @param          overlapTacticPromoList
    @param          recordIdPromo
    @param          childPromoAccountIdMap
    @param          overlapPromoListTemp
    @description	method to update child promotiondetails.
    *********************************************************************************************************/ 
    public static void updateParentChildPromotion(Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBody> overlapTacticPromoList,String recordIdPromo,Map<String,String> childPromoAccountIdMap,Set<TPM_Wrapper_OverLapCheck_Ext.ResponseBodyNew> overlapPromoListTemp) {
        List<cgcloud__Promotion__c> finalChildPromoList = new List<cgcloud__Promotion__c>();    
        //if overlap found update child with overlap details and phase as draft
        if(!overlapPromoListTemp.isEmpty()){
                finalChildPromoList = TPM_OverlapCheckQueableExt.getChildOverlapDetails(overlapPromoListTemp,childPromoAccountIdMap);
            }
            //If tactic overlap found te update child details with draft
        else if(!overlapTacticPromoList.isEmpty()){
              
                for(Id key: childPromoAccountIdMap.keySet()){
                    cgcloud__Promotion__c chilsdPromoUpdate = new cgcloud__Promotion__c();
                    chilsdPromoUpdate.id = childPromoAccountIdMap.get(key);
                    chilsdPromoUpdate.cgcloud__Skip_Version_Update__c = true;
                    chilsdPromoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                    chilsdPromoUpdate.cgcloud__Active__c = false;
                    chilsdPromoUpdate.TPM_Push_Failed__c = false;
                    chilsdPromoUpdate.TPM_Overlap_Details__c = null;
                    chilsdPromoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.OVERLAPFOUND;
                    chilsdPromoUpdate.TPM_OverLap_Check_Status__c = TPM_ConstantsUtility.OVERLAPFOUND;
                    chilsdPromoUpdate.TPM_Overlap_Check_In_Progress__c = false;
                    finalChildPromoList.add(chilsdPromoUpdate);
                }
            }
        //If no overlap found the update child with pahse as planning
        else{
                      
                    for(Id key: childPromoAccountIdMap.keySet()){
                        cgcloud__Promotion__c chilsdPromoUpdate = new cgcloud__Promotion__c();
                        chilsdPromoUpdate.id = childPromoAccountIdMap.get(key);
                        chilsdPromoUpdate.cgcloud__Skip_Version_Update__c = true;
                        chilsdPromoUpdate.cgcloud__Active__c = true;
                        chilsdPromoUpdate.TPM_Push_Failed__c = false;
                        chilsdPromoUpdate.TPM_Overlap_Details__c = null;
                        chilsdPromoUpdate.TPM_Overlap_Check__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                        chilsdPromoUpdate.TPM_OverLap_Check_Status__c = TPM_ConstantsUtility.NOOVERLAPFOUND;
                        chilsdPromoUpdate.TPM_Overlap_Check_In_Progress__c = false;
                        finalChildPromoList.add(chilsdPromoUpdate);

                }

            }
                
           
            //Update child list
            if(!finalChildPromoList.isEmpty()){
    
                List<Database.SaveResult> saveResultVar = Database.update(finalChildPromoList);
            }
    
            TPM_OverlapCheckQueableExt.updateParentPromotion(overlapTacticPromoList,recordIdPromo);  
        }

    /********************************************************************************************************   
    @methodname 	publishEvent
    @param          message
    @param          recordId
    @description	method to publish event to overlap check display warning.
    *********************************************************************************************************/ 
    public static void publishEvent(String message,String recordId) {
            TPM_Overlap_Event__e event = new TPM_Overlap_Event__e();
            event.TPM_Ovrelap_Check__c = message;
            event.TPM_RecordId__c = recordId;
            EventBus.publish(event);
    }


    /********************************************************************************************************   
    @methodname 	updateParentChildPromotions
    @param          recordId
    @param         childPromoAccountIdMap
    @param         message
    @description	method to update parent and child promotions back to draft in case of connectivity issue
    *********************************************************************************************************/ 
    public static void updateParentChildPromotions(String recordId,Map<String,String> childPromoAccountIdMap,String message) {

            List<cgcloud__Promotion__c> parentChildPromo = new List<cgcloud__Promotion__c>();
            cgcloud__Promotion__c promoUpdate = new cgcloud__Promotion__c();
            promoUpdate.id = recordId;
            promoUpdate.cgcloud__Skip_Version_Update__c = true;
            promoUpdate.TPM_Overlap_Check__c = message;
            promoUpdate.TPM_OverLap_Check_Status__c = message;
            promoUpdate.TPM_Push_Failed__c = false;
            promoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
            promoUpdate.TPM_Overlap_Check_In_Progress__c = false;
            promoUpdate.cgcloud__Active__c = false;
            promoUpdate.TPM_Overlap_Details__c = ' ';
            parentChildPromo.add(promoUpdate);
            for(Id key:  childPromoAccountIdMap.keySet()){
                cgcloud__Promotion__c chilsdPromoUpdate = new cgcloud__Promotion__c();
                chilsdPromoUpdate.id = childPromoAccountIdMap.get(key);
                chilsdPromoUpdate.cgcloud__Skip_Version_Update__c = true;
                chilsdPromoUpdate.TPM_Phase__c = TPM_ConstantsUtility.PHASE_DRAFT;
                chilsdPromoUpdate.cgcloud__Active__c = false;
                chilsdPromoUpdate.TPM_Push_Failed__c = false;
                chilsdPromoUpdate.TPM_Overlap_Check_In_Progress__c = false;
                chilsdPromoUpdate.TPM_Overlap_Check__c = message;
                chilsdPromoUpdate.TPM_OverLap_Check_Status__c = message;
                chilsdPromoUpdate.TPM_Overlap_Details__c = ' ';
                parentChildPromo.add(chilsdPromoUpdate);
            }


            List<Database.SaveResult> saveResultVar = Database.update(parentChildPromo);
            publishEvent(message,recordId);
        }

    
    }