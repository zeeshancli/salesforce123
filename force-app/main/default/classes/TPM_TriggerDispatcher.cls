/*******************************************************************************************************
* @Name         : TPM_TriggerDispatcher
* @unit Test    : 
* @author       : PwC Team
* @date         : 12/09/2022
* @description  : Class for Handling Trigger Events
*******************************************************************************************************/

public inherited sharing class TPM_TriggerDispatcher {

    /****************************************************************************************************
    @methodname 	TPM_TriggerDispatcher
    @createdDate 	12/09/2022
    @description	default private constructor
    *****************************************************************************************************/

    @SuppressWarnings('PMD.EmptyStatementBlock')
    private TPM_TriggerDispatcher(){

    }
    
    /****************************************************************************************************
    @methodname 	createHandler
    @createdDate 	12/09/2022
    @param          handlerClass
    @description	created the instance of the handler class received from the object trigger
    *****************************************************************************************************/  

    public static void createHandler(Type handlerClass){
        
        TPM_TriggerInterface handler = getHandler(handlerClass);
        if (handler == null){
            throw new TPM_TriggerException(TPM_ConstantsUtility.TRIGGER_EXCEPTION);
        }
        dispatch(handler);
    }
    
    /************************************************************************************************************
    @methodname 	dispatch
    @createdDate 	12/09/2022
    @param          handler
    @description	handle different trigger events methods.
    ***************************************************************************************************************/ 

    private static void dispatch(TPM_TriggerInterface handler){
        
        if(Trigger.isBefore){
            handler.bulkBefore();
        }
        
        if(Trigger.isAfter){
            handler.bulkAfter();
        }
        
        switch on Trigger.operationType{
            
            when BEFORE_INSERT{
                handler.beforeInsert(Trigger.new);
            }
            when AFTER_INSERT{
                handler.afterInsert(Trigger.newMap);
            }
            when BEFORE_UPDATE{
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_UPDATE{
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when BEFORE_DELETE{
                handler.beforeDelete(Trigger.oldMap);
            }
            when AFTER_DELETE{
                handler.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE{
                //call undelete after implemetation.
                handler.afterUnDelete(Trigger.new); 
            }
        }
        
        handler.andFinally();
        
    }

    /************************************************************************************************** 
    @methodname 	getHandler
    @createdDate 	12/09/2022
    @return         TPM_TriggerInterface
    @param          type
    @description	return instance of TPM_TriggerInterface while creating handler for object trigger.
    ****************************************************************************************************/  
      
    private static TPM_TriggerInterface getHandler(Type type){
        Object handler = type.newInstance();
        return handler instanceof TPM_TriggerInterface ? (TPM_TriggerInterface) handler : null;
    }
}