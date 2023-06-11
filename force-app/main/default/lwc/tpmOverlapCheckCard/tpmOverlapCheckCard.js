import { LightningElement, track, api } from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import {
    CGCloudNamespaceWithUnderscore,
    apexCacheable,
    apex,
    getResponse,
    refreshApex
} from 'cgcloud/tpmGenericUtils';

const columns = [
    {
        label: 'Promotion Name', fieldName: 'PromotionLink', type: 'url', wrapText: true, hideDefaultActions: true, typeAttributes: {
            label: {
                fieldName: 'promotionName'
            }
        },

    },
    { label: 'Tactic Name', hideDefaultActions: true, fieldName: 'tacticName', wrapText: true },
    { label: 'Product', hideDefaultActions: true, fieldName: 'product', type: 'text', wrapText: true },
    {
        label: 'Shipment Date From', fieldName: 'shipmentDateFrom', type: 'date-local', wrapText: true, hideDefaultActions: true, typeAttributes: {
            month: '2-digit',
            day: '2-digit'
        },
    },
    {
        label: 'Shipment Date Thru', fieldName: 'shipmentDateThrough', type: 'date-local', wrapText: true, hideDefaultActions: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
];

export default class TpmOverlapCheckCard extends LightningElement {

    @api recordId;
    accountURL;
    url;
    columns = columns;
    open = true;
    @track promoPhaseOld;
    timeSpan = 2000;
    error;
    @track productData = [];
    @track products = [];
    phaseFromUi;
    @track promoParentTemplate = [];
    isloading = false;
    areDetailsVisible = false;
    @track labels;
    productResponseBody = [];
    successMessage;
    ProductsMessage;
    @track promoData = [];
    oldPhase;
    @track promoPhase;
    @api overlapCheckTitle = 'Overlap Checks';
    requestParams = {
        objId: ''
    };
    paramsOverlapCheck = {
        objId: '',
        response: ''
    };

    connectedCallback() {

        if (this.recordId) {
            this.requestParams = {
                objId: this.recordId
            };

            this.imperativeApex();
        }
    }

    // Imperative Apex to get the overlap details for promotion and Custom Error Message Label
    imperativeApex() {
        this.isloading = true;
        //get overlap promotions and display on the table
        apex({
            descriptor: {
                className: 'TPM_OverLapCheckControllerExtension',
                method: 'fetchProductData'
            },
            params: this.requestParams
        })
            .then(getResponse) // use getResponse to extract data
            .then((data) => {
                //Check If JSON has rows
                if (data) {
                    let prodData = JSON.parse(data);
                    if (prodData.length != 0) {
                        this.productData = prodData.promotionData[0];
                        this.labels = prodData.label;
                        this.promoParentTemplate = prodData.parentPromotionTemplates;
                        this.parentPromo = this.productData.cgcloud__Promotion_Template__r.Name;
                        this.promoPhase = this.productData.TPM_Phase__c;
                        this.promoPhaseOld = this.productData.TPM_Phase__c;
                        if (this.productData.TPM_Overlap_Details__c) {
                            this.areDetailsVisible = true;
                            this.promoData = JSON.parse(this.productData.TPM_Overlap_Details__c);
                            this.promoData.forEach(promo => {
                                if (promo.promotionName) promo.PromotionLink = '/' + promo.promotionId;
                            });
                        }
                    }
                }
                this.isloading = false;
            }).catch((error) => {

                this.showToast('JS Error', 'Please Contact System Administrator', 'Error');

            });


    }

    // Listen for promotion change events
    onPromotionChange(event) {

        this.phaseFromUi = event.detail.value['TPM_Phase__c'];
    }

    // Listen for Promotion Page Edit Mode Change
    handleEditModeChange(event) {

    }

    //get product details to check if atleast one product should be there before moving phase to planning
    getOverlapDetails() {
        this.isloading = true;
        apex({
            descriptor: {
                className: 'TPM_OverLapCheckControllerExtension',
                method: 'getProductDetails'
            },
            params: this.requestParams

        })
            .then(getResponse) // use getResponse to extract data
            .then((data) => {
                if (data) {

                    let prodResponseData = JSON.parse(data);
                    if (prodResponseData) {
                        this.products = prodResponseData.productData[0];
                        this.productResponseBody = prodResponseData.responseBodyValue;
                    }
                    if (!this.products) {
                        //If no data then products are not there and throw the error
                        this.promoData = '';
                        this.areDetailsVisible = false;
                        this.showToast(this.labels.NoProducts, this.labels.Products, 'Error');
                        const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
                        promotionComponent.setPromotionField('TPM_Phase__c', 'Draft');
                        promotionComponent.setPromotionField('TPM_Overlap_Check__c', ' ');
                        promotionComponent.setPromotionField('cgcloud__Active__c', false);
                        this.isloading = false;
                    }
                    else if (this.products && (this.phaseFromUi === 'Planning' || (this.productData.TPM_Phase__c === 'Planning' && this.phaseFromUi === 'Submitted For Approval') || (this.oldPhase === 'Planning' && this.phaseFromUi === 'Submitted For Approval'))) {
                        //If data is there atleast one product is there and proceed with overlap check
                        this.isloading = true;
                        this.paramsOverlapCheck = {
                            objId: this.recordId,
                            response: this.productResponseBody
                        }
                        this.getOverlapCheckDetails();
                    }
                }
            }).catch((error) => {

                this.showToast('JS Error', 'Please Contact System Administrator', 'Error');

            });
    }

    //To get overlap details for promotion
    getOverlapCheckDetails() {
        apex({
            descriptor: {
                className: 'TPM_OverLapCheckController',
                method: 'getPromotions'
            },
            params: this.paramsOverlapCheck

        })
            .then(getResponse) // use getResponse to extract data
            .then((data) => {
                if (data) {
                    this.promoData = JSON.parse(data);
                    if (this.promoData.length != 0) {
                        //If records are there for either promotion and tactic then 
                        //that promotion is overlapped
                        const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
                        promotionComponent.setPromotionField('TPM_Overlap_Check__c', 'Overlap Found');
                        promotionComponent.setPromotionField('TPM_Phase__c', 'Draft');
                        promotionComponent.setPromotionField('cgcloud__Active__c', false);
                        this.promoData.forEach(acc => {
                            //Create link for promotion
                            if (acc.promotionName) acc.PromotionLink = '/' + acc.promotionId;
                        });
                        this.areDetailsVisible = true;
                        window.location.reload();
                    }
                    else {
                        //If records are not there for either promotion and tactic then 
                        //that promotion is not overlapped
                        this.showToast(this.labels.NoOverlap, this.labels.Success, 'success');
                        this.areDetailsVisible = false;
                        this.oldPhase = 'Planning';
                        const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
                        promotionComponent.setPromotionField('TPM_Overlap_Check__c', 'No Overlap Found');
                        promotionComponent.setPromotionField('cgcloud__Active__c', true);
                        let isMethodInvoked = false;
                        apex({
                            descriptor: {
                                className: 'TPM_ComponentVolumePlanController',
                                method: 'executeComponentVolumeDisplayShipper'
                            },
                            params: this.requestParams
                        }).then(getResponse) // to extract data
                            .then((data) => {
                                isMethodInvoked = data;
                            });

                        setTimeout(() => { window.location.reload(); }, this.timeSpan);
                    }
                    this.error = undefined;
                    this.isloading = false;
                }
            }).catch((error) => {

                this.showToast('JS Error', 'Please Contact System Administrator', 'Error');

            });
    }


    //redenredCallback to handle field Validations
    renderedCallback() {

        const component = this.template.querySelector('cgcloud-tpm-promotion');
        component.setCallback('onAfterSync', this.onAfterSyncCallback);
        component.setCallback('onBeforeSave', this.onBeforeSaveCallback);
        component.setCallback('onAfterSave', this.onAfterSaveCallback);
    }


    /* ------------------------------------------------------------------------------------- 
    @name        : onBeforeSaveCallback
    @description : To handle onbeforesave from tpm to check field validations.
    --------------------------------------------------------------------------------------- */
    onBeforeSaveCallback = (data) => {
        if(this.promoPhase!=this.phaseFromUi){
            if ((this.promoPhase === 'Draft' && !(this.phaseFromUi === 'Planning' || this.phaseFromUi === 'Cancelled' || this.phaseFromUi === 'Draft')) 
            || (this.promoPhase === 'Planning' && !(this.phaseFromUi === 'Draft' || this.phaseFromUi === 'Cancelled' || this.phaseFromUi === 'Planning' || this.phaseFromUi === 'Submitted For Approval'))
            || (this.promoPhase === 'Cancelled')) {
                return new Promise((resolve, reject) => {
                    window.setTimeout(() => {
                        reject(new Error(this.labels.NoPhaseChange));
                    }, 2000);
                });
            }
           
            this.promoPhase = this.phaseFromUi;
        }

 
        if (this.phaseFromUi === 'Planning' && this.promoPhaseOld === 'Draft') {
            //if phase is planning set active field to true
            const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
            promotionComponent.setPromotionField('cgcloud__Active__c', true);
            promotionComponent.setPromotionField('TPM_Push_Failed__c', false);
            promotionComponent.setPromotionField('TPM_Overlap_Check__c', ' ');

        }
        else if(this.phaseFromUi === 'Planning'){
            const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
            promotionComponent.setPromotionField('cgcloud__Active__c', true);
            promotionComponent.setPromotionField('TPM_Push_Failed__c', false);
            
           

        }
        else if (this.phaseFromUi === 'Draft') {
            const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
            promotionComponent.setPromotionField('cgcloud__Active__c', false);
            promotionComponent.setPromotionField('TPM_Overlap_Check__c', ' ');
            promotionComponent.setPromotionField('TPM_Push_Failed__c', false);
        }
    };

    /* ------------------------------------------------------------------------------------- 
    @name        : onAfterSaveCallback
    @description : To handle onAftersave from tpm to load Spinner
    --------------------------------------------------------------------------------------- */
    onAfterSaveCallback = () => {

    };


    /* ------------------------------------------------------------------------------------- 
    @name        : onAfterSyncCallback
    @description : To handle onaftersync from tpm to check overlaps.
    --------------------------------------------------------------------------------------- */
    onAfterSyncCallback = () => {
        //set spinner to true anc check for overlaps
        if (!this.promoParentTemplate.includes(this.parentPromo) && (this.phaseFromUi === 'Planning' || (this.productData.TPM_Phase__c === 'Planning' && this.phaseFromUi === 'Submitted For Approval') || (this.oldPhase === 'Planning' && this.phaseFromUi === 'Submitted For Approval'))) {
            this.getOverlapDetails();
        }
    };


    /*---------------------------------------------------------------------------- 
        @name        : handleSwitchClick
        @description : This event is triggered to handle accordian toggle.
     ----------------------------------------------------------------------------- */
    handleSwitchClick(event) {
        this.open = !this.open;
    }


    /*---------------------------------------------------------------------------- 
    @name        : sectionClass
    @description : To control accordian toggle css classes mutation.
    ----------------------------------------------------------------------------- */
    get sectionClass() {

        return this.open ? 'slds-section slds-is-open' : 'slds-section';
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