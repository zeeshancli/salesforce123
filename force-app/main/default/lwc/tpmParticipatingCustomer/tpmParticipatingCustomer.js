import { LightningElement,track,api } from 'lwc';
//import domainName from '@salesforce/label/c.TPM_Domain_Name';

import {
    CGCloudNamespaceWithUnderscore,
    apexCacheable,
    apex,
    domainName,
    getResponse,
    refreshApex
} from 'cgcloud/tpmGenericUtils';


export default class TpmParticipatingCustomer extends LightningElement {
    activeSections = [ 'parCustomers' ];
    @api open;
    @api recordId;
    @api objectRecordId;
    @api objectAPIName = 'cgcloud__Promotion__c';
    @track isloadCmp = false;
     @track accLst=[];
    @track totalCustomers;
    @track totalCustomerLabel;

    // Invoke the Imperative Apex on the Component load
    connectedCallback() {
        
        if (typeof this.recordId !== 'undefined') {
            this.requestParams = {
                objId: this.recordId 
            };
            this.imperativeApex();
        }  
    }

    
    

    // Imperative Apex to get the UI JSON and Custom Error Message Label
    imperativeApex() {
        
        apex({ 
                descriptor: {
                    className: 'TPM_PromotionMainCardController',
                    method: 'fetchParticipatingCustomerDetails'
                },
                params: this.requestParams
            })
                .then(getResponse) // use getResponse to extract data
                .then((data) => {
                    //Check If JSON has rows
                    console.log('data',data);
                    if (data !=null) {
                        let result = JSON.parse(data);
                        this.isloadCmp = result.loadCmpFlag;
                       this.totalCustomers = result.totalActiveChildPromo;
                       this.totalCustomerLabel = 'Participating Customers ('+this.totalCustomers+')';
                      
                       this.accLst = result.childAccountLst;
                       
                    }
                })
    
                
        }
}