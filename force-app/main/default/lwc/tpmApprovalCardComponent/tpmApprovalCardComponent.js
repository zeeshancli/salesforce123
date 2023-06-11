import { LightningElement,api,track,wire } from 'lwc';
import getPromotionRelatedApprovals from '@salesforce/apex/TPM_ApprovalComponentController.getPromotionRelatedApprovals';
import Id from '@salesforce/user/Id';
import Approval from '@salesforce/label/c.TPM_Approval';
import ApprovalCreatedDate from '@salesforce/label/c.TPM_Approval_Created_Date';
import PromotionSubmitter from '@salesforce/label/c.TPM_Promotion_Submitter';
import Approver from '@salesforce/label/c.TPM_Approver';
import ApprovalStatus from '@salesforce/label/c.TPM_Approval_Status';

export default class tpmApprovalCardComponent extends  LightningElement  {
    
    @api recordId;
    @track noOfRecords = 0;
    @track isRecordsFound = false;
    @track promotionRelatedApprovals = [];
    currenLoggedInUserId = Id;
    labels = {
        Approval,
        Approver,
        ApprovalStatus,
        ApprovalCreatedDate,
        PromotionSubmitter,
    }
        
        /* ------------------------------------------------------------------------------
        @name        : wire
        @description : To get the list of Related Approval Records based on Promotion Id
        --------------------------------------------------------------------------------- */
        @wire(getPromotionRelatedApprovals,{promotionId : '$recordId',currentUserId : '$currenLoggedInUserId'})
        wiredCasesAndRelatedTasks({error,data}){
            // If records found successfully
            if(data){
                this.noOfRecords = Object.keys(data).length;
                // If Record Count is more than 0
                if(this.noOfRecords > 0){
                    this.isRecordsFound = true;
                }
                this.promotionRelatedApprovals = data;
            }
        }
        
        /* ------------------------------------------------------------------------------
        @name        : tableScrollBarClass
        @description : To set the Table Scroll bar if number of records > 5
        --------------------------------------------------------------------------------- */
        get tableScrollBarClass(){
            return this.noOfRecords >5 ? 'slds-scrollable_y scrollBarHeightWidth' :'';
        }

        /* ------------------------------------------------------------------------------
        @name        : tableRowMarginLeftXSmall
        @description : To set the Table Row Margin Adjustment if number of records > 5
        --------------------------------------------------------------------------------- */
        get tableRowMarginLeftXSmall(){
            return this.noOfRecords > 5 ? ' slds-truncate slds-m-left_x-small' : 'slds-truncate';
        }

        /* ------------------------------------------------------------------------------
        @name        : tableRowMarginLeftSmall
        @description : To set the Table Row Margin Adjustment if number of records > 5
        --------------------------------------------------------------------------------- */
        get tableRowMarginLeftSmall(){
            return this.noOfRecords > 5 ? ' slds-truncate slds-m-left_small' : 'slds-truncate';
        }

}