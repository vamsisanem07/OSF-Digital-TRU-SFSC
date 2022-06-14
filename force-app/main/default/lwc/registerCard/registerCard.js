import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getStatesPicklistValues from '@salesforce/apex/RegisterCardController.getStatesPicklistValues';
import registerUser from '@salesforce/apex/RegisterCardController.registerUser';
import registerCardLibrary from './registerCardLibrary';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import STATE_FIELD from '@salesforce/schema/Account.PersonMailingStateCode';

export default class RegisterCard extends NavigationMixin(LightningElement) {
    @api newCard = false;
    @track loading = false;
    @track states = [];
    @track account = {
        'Email_Opt_In_BRU__c': false,
        'Email_Opt_In_TRU__c': false,
        'Child_Birthday_Opt_In__c': false,
        'Email_Opt_In_RLE__c': false,
        'PersonMailingCountryCode': 'CA'
    };
    @track childs = [{key: 0}];

    @wire(getStatesPicklistValues)
    fetchStatesPicklist({ error, data }) {
        if(data) {
            let options = [];

            for (var element in data) {
                 options.push({ label: element, value: data[element] });
            }

            this.states = options;
        } else if (error) {
            console.log(error);
        }
    }

    label = registerCardLibrary();

    handleSaveAccount(event) {
        event.preventDefault();
        event.stopPropagation();

        this.loading = true;
        if (this.validateFields()){
            registerUser({userData: this.account, childData: this.childs, newCard: this.newCard})
                .then(result => {
                    if(result['Id']) {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                pageName: 'success'
                            }
                        });
                    }
                })
                .catch(error => {
                    this.loading = false;
                    this.showToast(error);
                });
        } else {
            this.loading = false;
        }
    }

    handleAcceptTerms() {
        this.acceptTerms = !this.acceptTerms;
    }

    handleAddAnotherChild(event) {
        let key = this.childs.length != 0 ? (this.childs[this.childs.length - 1].key + 1) : 1;

        this.childs.push({
            key: key,
        });
    }

    handleRemoveChild(event) {
        let index = event.target.dataset.index;

        this.childs.splice(index, 1);
    }

    handleRemoveAll(event) {
        this.childs = [];
    }

    handleValueChange(event) {
        const type = event.target.type;
        const datatype = event.target.dataset.type;
        const dataindex = event.target.dataset.index;
        const name = event.target.name;
        const value = event.target.value;

        if(datatype == 'child') {
            this.childs[dataindex][name] = type == "checkbox" ? !this.childs[dataindex][name] : value;
        } else {
            this.account[name] = type == "checkbox" ? !this.account[name] : value;
        }
    }

    validateFields() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        return allValid;
    }

    showToast(error) {
        const event = new ShowToastEvent({
            title: 'Error: ' + error.body.message,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    get language() {
        return [
            { label: 'English', value: 'EN' },
            { label: 'Français', value: 'FR' }
        ];
    }

    get month() {
        let months = [];
        let monthNames = this.label.R_club_Months.split(',');

        for(let i = 0; i < monthNames.length; i++){
            months.push({ label: monthNames[i], value: (i + 1).toString() });
        }

        return months;
    }

    get year() {
        let years = [];
        let currentYear = new Date().getFullYear();

        for(let i = currentYear; i >= currentYear - 18; i--){
            years.push({ label: i.toString(), value: i.toString() });
        }

        return years;
    }
}