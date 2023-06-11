/******************************************************************************************************
@Name            TPM_PromotionMainCardControllerExtension
@testclass       TPM_PromotionMainCardControllerTest
@Author          PwC Team
@date            20 APR, 2023
@description     Controller method for custom tpm_promotionMainCard component 
*******************************************************************************************************
Change History Story      Modified by               Date                          Desc

*******************************************************************************************************/

@SuppressWarnings('PMD.AvoidGlobalModifier')
public inherited sharing class TPM_PromotionMainCardControllerExtension {
    
 /************************************************************************
    * @method          PushableAcocuntDetailWrapper
    * @description     Wrapper
    **************************************************************************/
    public class PushableAcocuntDetailWrapper {
        /**
         * @description account id
         */
        public String accountId {get; set;}
         /**
         * @description promotion id(if promotion has been created for this)
         */
        public String promotionId {get; set;}
        /**
         * @description name of account
         */
        public String accountName {get; set;}
        /**
         * @description external id of account
         */
        public String externalId {get; set;}
        /**
         * @description flag to check if child promotion has been created
         */
        public boolean pushedFlag {get; set;}
        /**
         * @description link to account record
         */
        public String accountLink {get; set;}
        /**
         * @description link to promotion record
         */
        public String promotionLink {get; set;}
        /**
         * @description flag to check whether child promotion record is created
         */
        public boolean childRecordCreated {get; set;}

    }
    

}