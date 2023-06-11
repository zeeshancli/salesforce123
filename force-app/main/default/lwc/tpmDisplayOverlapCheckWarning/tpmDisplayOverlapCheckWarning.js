import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    CGCloudNamespaceWithUnderscore,
    apexCacheable,
    apex,
    getResponse,
    refreshApex
} from 'cgcloud/tpmGenericUtils';



export default class tpmDisplayOverlapCheckWarning extends LightningElement {

    @track overLapCheck;
    @api recordId;
    @track overLapcheckFlag = false;
    @track overLapcheckFlagComplete = false;
    @track overLapcheckFlagProgress = false;
    timeSpan = 2000;
    phaseFromUi;
    @track pushFail;
    @track overlapStatus;
    @track overLapFail = 'Push Failed';
    overLapcheckFlagParentPush = false;
    @track overLapChecknew;
    @track eventRecordId;
    overlapMessage;
    @track overLapcheckFlagParentPushFail = false;
    overLapStatus;
    @track productData = [];
    @track promoParentTemplate = [];
    overlapMessageProgress;
    overLapPush;
    isEditable;
    parentPromo;
    subscription = {};
    @track labels;
    requestParams = {
        objId: ''
    };

    @api channelName = '/event/TPM_Overlap_Event__e';

    /*------------------------------------------------------------------------------------- 
    @name        : connectedCallback
    @description : Triggered on load of a page.
    ---------------------------------------------------------------------------------------*/
    connectedCallback() {
        if (this.recordId) {
            this.requestParams = {
                objId: this.recordId
            };
            this.imperativeApex();
            this.registerErrorListener();
            this.handleSubscribe();
        }
    }

    /*------------------------------------------------------------------------------------- 
    @name        : imperativeApex
    @description : Call method to get Custom Label
    --------------------------------------------------------------------------------------- */
    // Imperative Apex to get Custom Error Message Label
    imperativeApex() {
        //get labels to be displayed to users
        apex({
            descriptor: {
                className: 'TPM_OverLapCheckControllerExtension',
                method: 'fetchProductData'
            },
            params: this.requestParams
        })
            .then(getResponse) // use getResponse to extract data
            .then((data) => {
                let prodData = JSON.parse(data);
                if (prodData.length != 0) {
                    this.productData = prodData.promotionData[0];
                    this.labels = prodData.label;
                    this.overLapPush = this.labels.PushMessage;
                    this.overLapStatus = this.productData.TPM_Overlap_Check_In_Progress__c;
                    this.pushFail = this.productData.TPM_Push_Failed__c;
                    this.overLapFail = this.labels.PushFail;
                    this.overlapMessageProgress = this.labels.PushProgress;
                    this.promoParentTemplate = prodData.parentPromotionTemplates;
                    this.parentPromo = this.productData.cgcloud__Promotion_Template__r.Name;
                    this.overlapMessage = this.labels.Overlap;
                }
            })

    }

    /*------------------------------------------------------------------------------------- 
    @name        : onPromotionChange
    @description : This event is triggered any time any of the promotion attributes change.
    ---------------------------------------------------------------------------------------*/
    onPromotionChange(event) {
        this.phaseFromUi = event.detail.value['TPM_Phase__c'];
        this.overLapCheck = event.detail.value['TPM_Overlap_Check__c'];
        if (!this.promoParentTemplate.includes(this.parentPromo) && this.overLapCheck === 'Overlap Found') {
            this.overLapcheckFlag = true;
        }
        else{

            this.overLapcheckFlag = false;
        }

        if (this.promoParentTemplate.includes(this.parentPromo) && (this.overLapStatus === true || this.overLapCheck === 'OverLap Check In Progress')) {
            this.overLapcheckFlagProgress = true;
        }
        else {
            this.overLapcheckFlagProgress = false;
        }

        if (this.promoParentTemplate.includes(this.parentPromo) && this.overLapCheck === 'Overlap Found' && this.overLapcheckFlagProgress === false) {
            this.overLapcheckFlagParentPush = true;

        }
        else {
            this.overLapcheckFlagParentPush = false;

        }

        if (this.promoParentTemplate.includes(this.parentPromo) && this.pushFail === true && this.overLapCheck === 'Push Failed') {

            this.overLapcheckFlagParentPushFail = true;
        }
        else {

            this.overLapcheckFlagParentPushFail = false;
        }
    }


    /*------------------------------------------------------------------------------------- 
    @name        : renderedCallback
    @description : This event is triggered any time any of the promotion attributes change.
    ---------------------------------------------------------------------------------------*/
    // redenredCallback to handle field Validations
    renderedCallback() {

        const component = this.template.querySelector('cgcloud-tpm-promotion');
        component.setCallback('onAfterSync', this.onAfterSyncCallback);

    }

      /*------------------------------------------------------------------------------------- 
    @name        : onPromotionChange
    @description : This event is triggered any time any of the promotion attributes change.
    ---------------------------------------------------------------------------------------*/
    onStatuschange(event) {
        this.statusVal = event.detail.value;
       
        
    }


    /*------------------------------------------------------------------------------------- 
    @name        : handleEditModeChange
    @description : // Listen for Promotion Page Edit Mode Change
    ---------------------------------------------------------------------------------------*/

    handleEditModeChange(event) {

        this.isEditable = event.detail.value;

    }

      /* ------------------------------------------------------------------------------------- 
    @name        : onAfterSyncCallback
    @description : To handle onaftersync from tpm to check overlaps.
    --------------------------------------------------------------------------------------- */
    onAfterSyncCallback = () => {
        //set spinner to true anc check for overlaps
     
        //Call Queable class to run overlap checks
        if(this.statusVal === 'VALID' && this.promoParentTemplate.includes(this.parentPromo)  && (this.phaseFromUi === 'Planning' ||  this.phaseFromUi === 'Submitted For Approval')){
            const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
            promotionComponent.push();
        }
    };

    /*------------------------------------------------------------------------------------- 
    @name        : handleEditModeChange
    @description : // Listen for Promotion Page Edit Mode Change
    ---------------------------------------------------------------------------------------*/
    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {

            var obj = JSON.parse(JSON.stringify(response));
            let objData = obj.data.payload;
            self.overLapChecknew = objData.TPM_Ovrelap_Check__c;
            self.eventRecordId = objData.TPM_RecordId__c;
            if (self.eventRecordId == self.recordId && self.overLapChecknew === 'Overlap Found') {
                self.overLapcheckFlagParentPush = true;
                self.overLapcheckFlagProgress = false;
                setTimeout(() => { window.location.reload(); }, self.timeSpan);
               
            }


            else if (self.eventRecordId == self.recordId && self.overLapChecknew === 'No Overlap Found') {
                self.overLapcheckFlagProgress = false;
                self.showToast(self.labels.NoOverlap, self.labels.Success, 'success');
                setTimeout(() => { window.location.reload(); }, self.timeSpan);


            }

            else if (self.eventRecordId == self.recordId && self.overLapChecknew === 'No Products Found') {
                self.overLapcheckFlagProgress = false;
                self.showToast(self.labels.NoProducts, self.labels.Products, 'Error');
                setTimeout(() => { window.location.reload(); }, self.timeSpan);
            }

            else if (self.eventRecordId == self.recordId && self.overLapChecknew === 'Connection Failure') {
                self.overLapcheckFlagProgress = false;
                self.showToast('Connection Failure', 'Please contact your system Administrator', 'Error');
                setTimeout(() => { window.location.reload(); }, self.timeSpan);
            }
            else if (self.eventRecordId == self.recordId && self.overLapChecknew === 'Push Failed') {

                self.overLapcheckFlagProgress = false;
                self.overLapcheckFlagParentPushFail = true;
                setTimeout(() => { window.location.reload(); }, self.timeSpan);
            }

            
        };


        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            this.subscription = response;
        });
    }

    //handle Error
    registerErrorListener() {
        onError(error => {
        });
    }

    /*------------------------------------------------------------------------------------- 
           @name        : showToast
           @description : To display messages 
       --------------------------------------------------------------------------------------- */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }


}