/*******************************************************************************************************
* @Name         : TPM_AccountTeamHelper
* @Unit Test    : TPM_AccountTeamTriggerTest
* @Author       : PwC Team
* @Date         : 01/24/2023
* @description  : Helper class for performing all business logics/ helper methods for account team
*******************************************************************************************************/

public inherited sharing  class TPM_AccountTeamHelper {

    /***************************************************************************************************
    @methodname 	TPM_AccountTeamHelper
    @createdDate 	01/24/2023
    @description	default private constructor
    ****************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_AccountTeamHelper(){

    }


    /*********************************************************************************************************
    @methodname   	createChildParentMapForManagedAccount
    @createdDate  	01/19/2023
    @param     	  	managedAccountIdSet
	* @return         : WrapAccountData
    @description  	collecting all the related account data for managedaccounts 
    *********************************************************************************************************/

    public static WrapAccountData createChildParentMapForManagedAccount(Set<Id> managedAccountIdSet){
        wrapAccountData wrapperObj =  new wrapAccountData();
        wrapperObj.parentSet = new Set<Id>();
        wrapperObj.allRelatedSet= new Set<Id>();
        wrapperObj.managedAccountAndChildMap= new Map<Id,Set<Id>>();
        wrapperObj.managedAccountAndParentMap= new Map<Id,Set<Id>>();
        wrapperObj.managedAccountAndRelatedMap= new Map<Id,Set<Id>>();
        
        for(Account relatedAccObj : [SELECT
                                     ID,
                                     NAME,
                                     PARENTID,
                                     PARENT.ID,
                                     PARENT.PARENT.ID,
                                     TPM_Hierarchy_Level__c
                                     FROM Account
                                     WHERE ParentId IN: managedAccountIdSet
                                     OR ID IN: managedAccountIdSet]){

                                         //fetching all the sold-tos for the retrieved managed accounts:
                                         //also retrieving all the related ids(soldtos,groups,super groups of managed account in allRelatedIdSet)
                                         
                                         if(relatedAccObj.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.ACT_HIERARCHY_SOLDTO_ACCOUNT){
                                             
                                             wrapperObj=createSoldToForManagedAccount(wrapperObj,relatedAccObj);
                                         }

                                         //fetching all the id of the parent accounts in the hierarchy of the retrieved managed accounts:
                                         //also retrieving all the related ids(soldtos,groups,super groups of managed account in allRelatedIdSet)
                                         //also retrieving the parent ids(groups and super groups in parentIdSet)
                                         
                                         else if(relatedAccObj.TPM_Hierarchy_Level__c == TPM_ConstantsUtility.ACT_HIERARCHY_MANAGED_ACCOUNT){
                                             wrapperObj=createParentForManagedAccount(wrapperObj,relatedAccObj);
                                         }
                                    }
        
      return wrapperObj;
    }
    

    /*********************************************************************************************************
    @methodname   	createSoldToForManagedAccount
    @createdDate  	01/24/2023
    @param     	  	wrapperObj
    @param     	  	relatedAcc
	* @return         : WrapAccountData
    @description  	collecting all the related sold to account data for managedaccounts 
    *********************************************************************************************************/

    public static WrapAccountData createSoldToForManagedAccount(wrapAccountData wrapperObj, Account relatedAcc){
        
                                             
        if(!wrapperObj.managedAccountAndChildMap.containskey(relatedAcc.PARENTID)){ 
            if(relatedAcc.ID != null){
                wrapperObj.managedAccountAndChildMap.put(relatedAcc.PARENTID, new Set<Id>());
            }
        }
        
        if(wrapperObj.managedAccountAndChildMap.containskey(relatedAcc.PARENTID)){
           wrapperObj.managedAccountAndChildMap.get(relatedAcc.PARENTID).add(relatedAcc.ID);
         }
        wrapperObj.allRelatedSet.add(relatedAcc.ID);
        
        if(!wrapperObj.managedAccountAndRelatedMap.containskey(relatedAcc.PARENTID)){
            if(relatedAcc.ID != null){
                wrapperObj.managedAccountAndRelatedMap.put(relatedAcc.PARENTID, new Set<Id>());
            }
        }
        if(wrapperObj.managedAccountAndRelatedMap.containskey(relatedAcc.PARENTID)){
            wrapperObj.managedAccountAndRelatedMap.get(relatedAcc.PARENTID).add(relatedAcc.ID);
        }
        
        return wrapperObj;
     }


    /*********************************************************************************************************
    @methodname   	createParentForManagedAccount
    @createdDate  	01/24/2023
    @param     	  	wrapperObj
    @param     	  	relatedAcc
	* @return         : WrapAccountData
    @description  	collecting all the related parent account data for managedaccounts 
    *********************************************************************************************************/

    public static WrapAccountData createParentForManagedAccount(wrapAccountData wrapperObj, Account relatedAcc){
       
        if(!wrapperObj.managedAccountAndParentMap.containskey(relatedAcc.ID)){
            if(relatedAcc.PARENT.ID != null || relatedAcc.PARENT.PARENT.ID != null){
                wrapperObj.managedAccountAndParentMap.put(relatedAcc.ID, new Set<Id>());

          }
        }
        if(wrapperObj.managedAccountAndParentMap.containskey(relatedAcc.ID)){
            wrapperObj.managedAccountAndParentMap.get(relatedAcc.ID).add(relatedAcc.PARENT.ID);
            wrapperObj.managedAccountAndParentMap.get(relatedAcc.ID).add(relatedAcc.PARENT.PARENT.ID);
       }
        wrapperObj.allRelatedSet.add(relatedAcc.PARENT.ID);//group id
        wrapperObj.allRelatedSet.add(relatedAcc.PARENT.PARENT.ID);//super group id
        wrapperObj.parentSet.add(relatedAcc.PARENT.ID);
        wrapperObj.parentSet.add(relatedAcc.PARENT.PARENT.ID);
        
        
        if(!wrapperObj.managedAccountAndRelatedMap.containskey(relatedAcc.ID)){
            if(relatedAcc.PARENT.ID != null || relatedAcc.PARENT.PARENT.ID != null){
            wrapperObj.managedAccountAndRelatedMap.put(relatedAcc.ID, new Set<Id>());
            }
        }
        
        if(wrapperObj.managedAccountAndRelatedMap.containskey(relatedAcc.ID)){
            wrapperObj.managedAccountAndRelatedMap.get(relatedAcc.ID).add(relatedAcc.PARENT.ID);
            wrapperObj.managedAccountAndRelatedMap.get(relatedAcc.ID).add(relatedAcc.PARENT.PARENT.ID);
        }
        
        return wrapperObj;
        
    }


    /*********************************************************************************************************
    @methodname   	wrapAccountData
    @createdDate  	01/24/2023
    @param     	  	
    @description  	wrapper class to collect all accounts details for main method. 
    *********************************************************************************************************/ 

    public class WrapAccountData{
        
        /**
     * @description parentSet  : to store all parentid(s): super-group/group 
     */

    public Set<Id> parentSet;
    /**
     * @description allRelatedSet : to store all ids in a hierarchy for a managed account(Supergroup,group,soldto(s)) 
     */
    public Set<Id> allRelatedSet;
    /**
     * @description managedAccountAndChildMap : to store all child sold to accounts for a particular managed account 
     */
    public Map<Id,Set<Id>> managedAccountAndChildMap;
    /**
     * @description managedAccountAndParentMap : to store all parent group and super group accounts for a particular managed account
     */
    public Map<Id,Set<Id>> managedAccountAndParentMap;
    /**
     * @description managedAccountAndRelatedMap : to store all related group,supergroup,soldtos for a particualr managed account.
     */
    public Map<Id,Set<Id>> managedAccountAndRelatedMap;
        
    }

}