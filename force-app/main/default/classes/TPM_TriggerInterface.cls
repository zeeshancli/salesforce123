/*******************************************************************************************************
* @Name         : TPM_TriggerInterface
* @unit Test    : 
* @author       : PwC Team
* @date         : 12/09/2022
* @description  : Trigger Interface
*******************************************************************************************************/
public Interface TPM_TriggerInterface {

    /*********************************************************************************************
    @methodname 	bulkBefore
    @description    This method is called prior to execution of a BEFORE trigger. Use this to cache
                    any data required to process the records in before context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    **********************************************************************************************/
    void bulkBefore();
    
    /*********************************************************************************************
    @methodname 	bulkBefore
    @description    This method is called prior to execution of an AFTER trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void bulkAfter();
    
    /*********************************************************************************************
    @methodname 	beforeInsert
    @param          newList
    @description    This method is called prior to execution of an BEFORE trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void beforeInsert(List<SObject> newList);

    /*********************************************************************************************
    @methodname 	afterInsert
    @param          newMap
    @description    This method is called prior to execution of an AFTER trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void afterInsert(Map<Id, SObject> newMap);
    
    /*********************************************************************************************
    @methodname 	beforeUpdate
    @param          newMap
    @param          oldMap
    @description    This method is called prior to execution of an BEFORE trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

    /*********************************************************************************************
    @methodname 	afterUpdate
    @param          newMap
    @param          oldMap
    @description    This method is called prior to execution of an AFTER trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

    /*********************************************************************************************
    @methodname 	beforeDelete
    @param          oldMap
    @description    This method is called prior to execution of an BEFORE trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void beforeDelete(Map<Id, SObject> oldMap);

    /*********************************************************************************************
    @methodname 	afterDelete
    @param          oldMap
    @description    This method is called prior to execution of an AFTER trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void afterDelete(Map<Id, SObject> oldMap);
    
    /*********************************************************************************************
    @methodname 	afterUnDelete
    @param          newList
    @description    This method is called prior to execution of an AFTER trigger. Use this to cache
                    any data required process the records in after context.
                    eg., Querying Record Type Ids, Custom Metadata, Custom Settings.
    ***********************************************************************************************/
    void afterUnDelete(List<SObject> newList);  //Added by Pwc Team for Story B-51199

   /**********************************************************************************************************
    @methodname     andFinally
    @description    This method is called once all records have been processed by the trigger. Use this 
                    method to accomplish any final operations such as creation or updates of other records.
    **********************************************************************************************************/
    void andFinally();
}