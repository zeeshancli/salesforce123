import { LightningElement, api } from 'lwc';

export default class TpmDynamicCardLayout extends LightningElement {

    @api isEditable;
    @api objApiName;
    @api isAddTactic;
    @api objectDataList;
    @api objectRecordId;
    @api objRecordTypeId;


    /* --------------------------------------------------------------------------- 
    @name        : handleOnChangeField
    @description : To handle input field onchange and check field validity.
    ------------------------------------------------------------------------------*/
    handleOnChangeField(event) {

        let inputFields = this.template.querySelectorAll('.true');
        if (inputFields) {
            inputFields.forEach(inputField => {
                inputField.reportValidity();
            })
        }
    }


    /* --------------------------------------------------------------------------- 
    @name        : handleOnFocusOut
    @description : To set updated field value for managed tpm component.
    ------------------------------------------------------------------------------*/
    handleOnFocusOut(event) {

        // fire an event to the parent to let it know about the field update. 
        const tacticFieldUpdate = new CustomEvent('tacticfieldupdate', {
            detail: {
                fieldName: event.target.fieldName,
                fieldValue: event.target.value
            }
        });
        this.dispatchEvent(tacticFieldUpdate);
    }


    /* --------------------------------------------------------------------------- 
    @name        : fetchMandatoryFields
    @description : Public method to check the mandatory fields validity.
    ------------------------------------------------------------------------------*/
    @api fetchMandatoryFields() {

        let isValid = true;
        let inputFields = this.template.querySelectorAll('.true');

        if (inputFields) {
            inputFields.forEach(inputField => {
                inputField.reportValidity();
                if (!inputField.reportValidity()) {
                    isValid = false;
                }
            })
        }
        return isValid;
    }

}