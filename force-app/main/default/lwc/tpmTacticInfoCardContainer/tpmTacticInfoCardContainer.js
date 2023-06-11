import { LightningElement, api, track } from 'lwc';
import { apex, getResponse } from 'cgcloud/tpmGenericUtils';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'

export default class TpmTacticInfoCardContainer extends LightningElement {

    @api recordId;
    @api open;
    @api objectRecordId;
    @api accordianTitle = 'Tactic Information';
    @api objApiName = 'cgcloud__Tactic__c';
    oldphase;
    @track columnsList = [];
    @track dataList = [];
    @track tacticsArray = [];
    @track selectedTactic = [];
    @track jsonFields = {};
    isAddTactic = false;
    isEditable;
    isJSONAvailable = false;
    isSpinner = true;
    objRecordTypeId;
    phaseFromUi;
    OverlapCheckVal;


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

        const childDynamicComponent = this.template.querySelector('c-tpm-dynamic-card-layout');
        if (typeof childDynamicComponent !== 'undefined' && childDynamicComponent !== null) {
            let isValid = childDynamicComponent.fetchMandatoryFields();
            if (!isValid) {
                return new Promise((resolve, reject) => {
                    window.setTimeout(() => {
                        reject(new Error(this.label.TPM_RequiredFieldMissingMsg));
                    }, 2000);
                });
            }
        }
    };

    onAfterSaveCallback = () => {
        if( this.phaseFromUi=='Draft' && this.oldphase=='Planning'){
        this.fetchUIDefinitionData(true);
        }

    };
    
    /* ------------------------------------------------------------------------------------- 
    @name        : handleOnTacticsChange
    @description : This event is triggered any time any of the Tactic attributes change.
    --------------------------------------------------------------------------------------- */
    handleOnTacticsChange(event) {

        let tacticArrayFromTPM = event.detail;
        this.tacticsArray = [];
        tacticArrayFromTPM.value.forEach(tactic => {
            this.tacticsArray.push(tactic);

        });
    }

   /* ------------------------------------------------------------------------------------- 
    @name        : onPromotionChange
    @description : This event is triggered any time any of the promotion attributes change.
    --------------------------------------------------------------------------------------- */
    onPromotionChange(event) {
        
        this.phaseFromUi = event.detail.value['TPM_Phase__c'];
        this.OverlapCheckVal = event.detail.value['TPM_Overlap_Check__c'];
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


    /* ---------------------------------------------------------------------------- 
    @name        : onTacticSelectionChange
    @description : This event is triggered every time the focused tactic changes.
    ----------------------------------------------------------------------------- */
    onTacticSelectionChange(event) {

        this.isJSONAvailable = false;
        this.isSpinner = true;

        window.setTimeout(() => {
            if (event.detail.property === 'selectedTacticId' && event.detail.value !== null) {
                this.objectRecordId = event.detail.value;
                this.tacticsArray.forEach(tactic => {
                    if (tactic.Id === this.objectRecordId) {
                        let selTactic = [];
                        selTactic.push(tactic);
                        this.selectedTactic = [...selTactic];
                    }
                });

                if (this.selectedTactic.length > 0) {
                    this.requestParams = {
                        objId: this.selectedTactic[0].cgcloud__Tactic_Template__c
                    };
                    if (this.selectedTactic[0].IsNew) {
                        this.fetchUIDefinitionData(true);
                    } else {
                        this.fetchUIDefinitionData(false);
                    }
                    this.objRecordTypeId = this.selectedTactic[0].RecordTypeId;
                }
            }
        }, 2000);
    }


    /* ---------------------------------------------------------------------------- 
    @name        : fetchUIDefinitionData
    @description : to fetch UI Definition record for new tactic.
    ----------------------------------------------------------------------------- */
    fetchUIDefinitionData(isNewTactic) {

        // Query the Standard TPM Component
        const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');
        apex({
            descriptor: {
                className: 'TPM_TacticCardContainerController',
                method: 'fetchUIComponentData'
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
                    let tacticFieldsToHide = result.tacticFieldsHide;
                    this.columnsList = [];
                    this.dataList = [];
                    this.jsonFields = {};
                    this.oldphase =  this.phaseFromUi;
                    if (uiDefData === null) {
                        return;
                    }

                    uiDefData.Columns.forEach(col => {
                        this.columnsList.push(col);
                    });
                //If phase is planning and no overlap found then hide shipment start and end date fields
                    if( this.phaseFromUi === 'Planning' && this.OverlapCheckVal === 'No Overlap Found'){
                        if (this.columnsList.length > 0) {
                            this.dataList = [...this.columnsList];
                            this.dataList.forEach(section => {
                                section.CRows.forEach(row => {
                                    row.RColumns.forEach(column => {
                                        this.jsonFields[column.Name] = column.Type;
                                        if (this.selectedTactic.length > 0) {
                                        //Get fields from metadata and check if column name is there in metadata
                                            if (tacticFieldsToHide.includes(column.Name)) {
                                            if (this.selectedTactic[0].hasOwnProperty(column.Name)) {
                                                column['Value'] = this.selectedTactic[0][column.Name];
                                            }
                                            // Add default value from the JSON
                                            else if(column.DefaultValue != undefined || column.DefaultValue != null){
                                                column['Value'] = column.DefaultValue;
                                                // Once default value updated.
                                                // Update it with setTacticField to make save it on the DB
                                                promotionComponent.setTacticField(this.objectRecordId, column.Name, column.DefaultValue);
                                            }
                                            else {
                                                column['Value'] = null;
                                            }
                                            //Making field as read only for Shipment and Instore start and end dates
                                            column['ReadOnly']=true;
                                        }                                     
                                    }
                                    else{ 
                                        if (this.selectedTactic.length > 0) {
                                            if (this.selectedTactic[0].hasOwnProperty(column.Name)) {
                                                column['Value'] = this.selectedTactic[0][column.Name];
                                            }
                                            // Add default value from the JSON
                                            else if(column.DefaultValue != undefined || column.DefaultValue != null){
                                                column['Value'] = column.DefaultValue;
                                                // Once default value updated
                                                // Update it with setTacticField to make save it on the DB
                                                promotionComponent.setTacticField(this.objectRecordId, column.Name, column.DefaultValue);
                                            }
                                            else {
                                                column['Value'] = null;
                                            }
                                        }
                                    }
                                    });
                                });
                            });
                        }

                    }
                    else{

                        if (this.columnsList.length > 0) {
                            this.dataList = [...this.columnsList];
                            this.dataList.forEach(section => {
                                section.CRows.forEach(row => {
                                    row.RColumns.forEach(column => {
                                        this.jsonFields[column.Name] = column.Type;
                                        if (this.selectedTactic.length > 0) {
                                            
                                            if (this.selectedTactic[0].hasOwnProperty(column.Name)) {
                                                column['Value'] = this.selectedTactic[0][column.Name];
                                            }
                                            // Added as part of Story No: 2973
                                            else if(column.DefaultValue != undefined || column.DefaultValue != null){
                                                column['Value'] = column.DefaultValue;
                                                // Once default value updated
                                                // Update it with setTacticField to make save it on the DB
                                                promotionComponent.setTacticField(this.objectRecordId, column.Name, column.DefaultValue);
                                            }
                                            else {
                                                column['Value'] = null;
                                            }
                                        }
                                    });
                                });
                            });
                        }
                    }
                    this.isAddTactic = isNewTactic;
                    this.isJSONAvailable = true;
                }
            }).catch((error)=>{
                
                this.showToast('JS Error','Please Contact System Administrator', 'Error');

            });
        this.isSpinner = false;
    }


    /* ---------------------------------------------------------------------------- 
    @name        : handleTacticFieldUpdate
    @description : to set updated field value for managed component.
    ----------------------------------------------------------------------------- */
    handleTacticFieldUpdate(event) {

        let changedFieldAPI = event.detail.fieldName;
        let eventValue = event.detail.fieldValue;
        const promotionComponent = this.template.querySelector('cgcloud-tpm-promotion');

        if (typeof changedFieldAPI !== 'undefined') {
            if (this.jsonFields.hasOwnProperty(changedFieldAPI)
                && (this.jsonFields[changedFieldAPI] === 'Percent'
                    || this.jsonFields[changedFieldAPI] === 'Currency')) {
                        if(!eventValue){
                            eventValue = Number(eventValue);
                            eventValue = null;    
                        }else{
                            eventValue = Number(eventValue);    
                        }   
            }
            promotionComponent.setTacticField(this.objectRecordId, changedFieldAPI, eventValue);
        }
    }


    /* -----------------------------------------------------------------------------------
    @name        : handleEditModeChange
    @description : This event is triggered every time the edit mode changes for the page.
    ------------------------------------------------------------------------------------- */
    handleEditModeChange(event) {

        this.isEditable = event.detail.value;
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