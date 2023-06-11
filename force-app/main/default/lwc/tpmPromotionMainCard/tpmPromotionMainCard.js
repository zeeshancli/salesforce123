import { LightningElement, api, track } from 'lwc';
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

export default class TpmPromotionMainCard extends LightningElement {

    @api recordId;
    @api open;
    @api objectRecordId;
    @api objectAPIName = 'cgcloud__Promotion__c';
    @api accordianTitle = 'Main Information';
    @track columnsList = [];
    @track promoDataList = [];
    @track jsonPromoFields = {};
    @track selectedPromotion = {};
    promo;
    @track promotionErrorMessage;
    @track promotionHideFields;
    @track error;
    isSpinner = false;
    isEditable;
    component;
    isJSONAvailable = false;
    preventSubmitForApproval;
    phaseFromUi;
    isInactiveCustomer;

    requestParams = {
        objId: ''
    };

    label = {};


    /* ------------------------------------------------------------------------------------- 
    @name        : connectedCallback
    @description : To perform initialization tasks.
    --------------------------------------------------------------------------------------- */
    connectedCallback() {

        if (typeof this.open === 'undefined') {
            this.open = true;
        }

        if (typeof this.recordId !== 'undefined') {
            this.requestParams = {
                objId: this.recordId
            };
            this.fetchUIDefinitionData();
        }
        // Invoke checkValidCustomer Method 
        this.checkValidCustomer();
    }

    /* ---------------------------------------------------------------------------- 
    @name        : checkValidCustomer
    @description : Method to check If the Customer is Valid or not based on the 
                   Value returned from checkIfActiveCustomer method.
    ----------------------------------------------------------------------------- */
    checkValidCustomer(){
        apex({
            descriptor: {
            className: 'TPM_PromotionMainCardController',
            method: 'checkIfActiveCustomer'
            },
            params: this.requestParams
            }).then(getResponse) // Get the value of the Customer whether Active or Not
            .then((data) => {
                this.isInactiveCustomer = data;
            });
    }


    /* ---------------------------------------------------------------------------- 
    @name        : handleSwitchClick
    @description : This event is triggered to handle accordian toggle.
    ----------------------------------------------------------------------------- */
    handleSwitchClick(event) {

        this.open = !this.open;
    }


    /* ---------------------------------------------------------------------------- 
    @name        : sectionClass
    @description : To control accordian toggle css classes mutation.
    ----------------------------------------------------------------------------- */
    get sectionClass() {

        return this.open ? 'slds-section slds-is-open' : 'slds-section';
    }


    /* ------------------------------------------------------------------------------------- 
    @name        : onPromotionChange
    @description : This event is triggered any time any of the promotion attributes change.
    --------------------------------------------------------------------------------------- */
    onPromotionChange(event) {
        
        this.phaseFromUi = event.detail.value['TPM_Phase__c'];
        this.preventSubmitForApproval = false;
        let selPromotion = {};
        selPromotion = event.detail.value;
        if ( selPromotion.hasOwnProperty('IsNew')) {
            this.selectedPromotion = selPromotion;
            this.promoDataList.forEach(section => {
                section.CRows.forEach(row => {
                    row.RColumns.forEach(column => {
                        if (this.selectedPromotion !== undefined && this.selectedPromotion !== null) {
                            if (this.selectedPromotion.hasOwnProperty(column.Name)) {
                                column['Value'] = this.selectedPromotion[column.Name];
                                if(this.label.TPM_Promotion_IsActivePreventForApproval.toLowerCase() === 'true' && column.Name === 'TPM_Phase__c' && this.selectedPromotion[column.Name] === 'Submitted For Approval'){
                                    this.preventSubmitForApproval = true;
                                } 
                            } else {
                                column['Value'] = null;
                            }
                        }
                    });
                });
            });
        }
    }


    /* ---------------------------------------------------------------------------- 
    @name        : fetchUIDefinitionData
    @description : to fetch UI Definition record for promotion.
    ----------------------------------------------------------------------------- */
    fetchUIDefinitionData() {

        this.isSpinner = true;

        apex({
            descriptor: {
                className: 'TPM_PromotionMainCardController',
                method: 'fetchPromoUIComponentData'
            },
            params: this.requestParams
        })
            .then(getResponse) // to extract data
            .then((data) => {

                if (data !== null) {

                    let result = JSON.parse(data[0]);
                    this.label = result.customLabelApiToValueMap;
                    let objUIDef = result.uiDefinitionJSON;
                    let uiDefData = JSON.parse(objUIDef);
                    this.promo = result.promotionData[0];
                    this.promotionHideFields = result.promotionFieldsHide;
                    this.columnsList = [];
                    this.promoDataList = [];
                    this.jsonPromoFields = {};
                    if (uiDefData === null) {
                        return;
                    }

                    uiDefData.Columns.forEach(col => {
                        this.columnsList.push(col);
                    });
                     //If phase is planning and no overlap found then hide shipment start and end date fields
                    if( this.promo.TPM_Phase__c === 'Planning' && this.promo.TPM_Overlap_Check__c === 'No Overlap Found'){
                    if (this.columnsList.length > 0) {
                        this.promoDataList = [...this.columnsList];
                        this.promoDataList.forEach(section => {
                            section.CRows.forEach(row => {
                                row.RColumns.forEach(column => {
                                    this.jsonPromoFields[column.Name] = column.Type;
                                    //Get fields from metadata and check if column name is there in metadata
                                        if (this.selectedPromotion !== undefined && this.selectedPromotion !== null && this.promotionHideFields.includes(column.Name)) {
                                        if (this.selectedPromotion.hasOwnProperty(column.Name)) {
                                            column['Value'] = this.selectedPromotion[column.Name];
                                        } else {
                                            column['Value'] = null;
                                        }
                                        //Making field as read only for Shipment and Instore start and end dates
                                        column.ReadOnly=true;
                                    }
                                    else if(this.selectedPromotion !== undefined && this.selectedPromotion !== null) {
                                        if (this.selectedPromotion.hasOwnProperty(column.Name)) {
                                            column['Value'] = this.selectedPromotion[column.Name];
                                        } else {
                                            column['Value'] = null;
                                        }
                                    }
                                });
                            });
                        });
                    }
                }
                else{
                    if (this.columnsList.length > 0) {
                        this.promoDataList = [...this.columnsList];
                        this.promoDataList.forEach(section => {
                            section.CRows.forEach(row => {
                                row.RColumns.forEach(column => {
                                    this.jsonPromoFields[column.Name] = column.Type;
                                    if (this.selectedPromotion !== undefined && this.selectedPromotion !== null) {
                                        if (this.selectedPromotion.hasOwnProperty(column.Name)) {
                                            column['Value'] = this.selectedPromotion[column.Name];
                                        } else {
                                            column['Value'] = null;
                                        }
                                    }
                                });
                            });
                        });
                    }
                }
                    this.isJSONAvailable = true;
                }
            }).catch((error)=>{
               
                this.showToast('JS Error','Please Contact System Administrator', 'Error');

            });
        this.isSpinner = false;
    }


    /* --------------------------------------------------------------------------- 
    @name        : handleOnFocusOut
    @description : To set updated field value for managed tpm component.
    ------------------------------------------------------------------------------*/
    handleOnFocusOut(event) {

        let changedFieldAPI = event.target.fieldName;
        let eventValue = event.target.value;
        const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');

        if (typeof changedFieldAPI !== 'undefined') {
            promotionComponent.setPromotionField(changedFieldAPI, eventValue);
        }

    }


    /* -----------------------------------------------------------------------------------
    @name        : handleEditModeChange
    @description : This event is triggered every time the edit mode changes for the page.
    ------------------------------------------------------------------------------------- */
    handleEditModeChange(event) {

        this.isEditable = event.detail.value;
    }


    /* ------------------------------------------------------------------------------------- 
    @name        : renderedCallback
    @description : To listen to onbeforesave from tpm to check field validations.
    --------------------------------------------------------------------------------------- */
    renderedCallback() {

        const component = this.template.querySelector('cgcloud-tpm-promotion');
        component.setCallback('onBeforeSave', this.onBeforeSaveCallback);
        component.setCallback('onAfterSave', this.onAfterSaveCallback);
    }


    /* ------------------------------------------------------------------------------------- 
    @name        : onBeforeSaveCallback
    @description : To handle onbeforesave from tpm to check field validations.
    --------------------------------------------------------------------------------------- */
    onBeforeSaveCallback = () => {

        let isValid = true;
        let inputFields = this.template.querySelectorAll('.true');
        inputFields.forEach(inputField => {
            inputField.reportValidity();
            if (!inputField.reportValidity()) {
                isValid = false;
            }
        })
        // Check if Customer is Inactive
        if(this.isInactiveCustomer){
            // Check If the Promotion Status is Changed from
            // Draft to Planning or Planning to Submitted for Approval when customer is inactive
            if( (this.promo.TPM_Phase__c == 'Draft' && this.phaseFromUi == 'Planning') 
            || (this.promo.TPM_Phase__c == 'Planning' && this.phaseFromUi == 'Submitted For Approval') ){
                return new Promise((resolve, reject) => {
                    window.setTimeout(() => {
                        reject(new Error(this.label.TPM_IsActiveCustomerValidationMessage));
                    }, 2000);
                });
                
            }
        }

        if (!isValid) {
            return new Promise((resolve, reject) => {
                window.setTimeout(() => {
                    reject(new Error(this.label.TPM_Promotion_Custom_Error_Message));
                }, 2000);
            });
        }
        
        if (this.preventSubmitForApproval) {
            return new Promise((resolve, reject) => {
                window.setTimeout(() => {
                    reject(new Error(this.label.TPM_Promotion_PreventSubmissionForApproval));
                }, 2000);
            });
        }
    };

    /* ----------------------------------------------------------------------------------------------------- 
    @name        : onAfterSaveCallback
    @description : To handle onAfteresave to update the Account checkbox to invoke tpmCalculationChain Batch
    --------------------------------------------------------------------------------------------------------- */
    onAfterSaveCallback = () => {
        //If phase is changed from draft to planning then remove non editablity
        //for instore and shipment dates
        if( this.phaseFromUi==='Draft' && this.promo.TPM_Phase__c === 'Planning'){
                    this.promoDataList.forEach(section => {
                    section.CRows.forEach(row => {
                        row.RColumns.forEach(column => {      
                                    if (this.selectedPromotion !== undefined && this.selectedPromotion !== null && this.promotionHideFields.includes(column.Name)) {
                                         if (this.selectedPromotion.hasOwnProperty(column.Name)) {
                                                column['Value'] = this.selectedPromotion[column.Name];
                                            } else {
                                                column['Value'] = null;
                                            }
                                            column['ReadOnly'] = false;
                                        }
                                        else{
                                          if (this.selectedPromotion !== undefined && this.selectedPromotion !== null) {
                                                if (this.selectedPromotion.hasOwnProperty(column.Name)) {
                                                        column['Value'] = this.selectedPromotion[column.Name];
                                                    } else {
                                                        column['Value'] = null;
                                                    }
                                            }
                                        }
                                    });
                                });
                            });
                      }
                
                    let isMethodInvoked = false;
                    apex({
                        descriptor: {
                        className: 'TPM_PromotionMainCardController',
                        method: 'executeTPMCalculationChainBatch'
                        },
                        params: this.requestParams
                        }).then(getResponse) // to extract data
                        .then((data) => {
                        isMethodInvoked = data;
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