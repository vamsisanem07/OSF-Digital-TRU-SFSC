import { LightningElement, api, track } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor'

import updateAccount from '@salesforce/apex/OSF_AddChildLwcCtrl.updatePersonAccount';
import getAccount from '@salesforce/apex/OSF_AddChildLwcCtrl.getPersonAccount';

export default class Osf_SubscriptionCenter extends LightningElement {

    @api accountId;
    @api accountFirstName;
    @api accountLastName;
    @api accountEmail;
    @track labelEmail;
    @track labelFName;
    @track labelLName;
    @api lan;
    connectedCallback() {
        console.log('Lan is +++> ' + this.lan);
        this.labelFName = this.lan == 'fr-ch' ? 'Prénom:' : 'First Name:';
        this.labelLName = this.lan == 'fr-ch' ? "Nom de famille:" : "Last Name:";
        this.labelEmail = this.lan == 'fr-ch' ? "Adresse courriel:" : "Email Address:";


        this.getAccountDetail();
        if (formFactorPropertyName == 'Small') {
            this.devicesize = 'label-stacked';
        } else {
            this.devicesize = 'label-inline';
        }


    }
    handleFirstName(event) {
        this.accountFirstName = event.target.value;
        this.UpdateAccount();
    }
    handleLastName(event) {
        this.accountLastName = event.target.value;
        this.UpdateAccount();
    }
    handleEmail(event) {
        this.accountEmail = event.target.value;
        this.validateEmail(event);
        this.UpdateAccount();
    }
    getAccountDetail() {
        getAccount({ acId: this.accountId })
            .then(result => {
                console.log('result', result);
                this.accountFirstName = result.FirstName;
                this.accountLastName = result.LastName;
                this.accountEmail = result.PersonEmail;
            })
            .catch(error => {
                console.log(error);
            });
    }

    validateEmail(event) {
        console.log('validateEmail');
        var email = event.target.value;
        console.log('email', email);
        var re = /\S+@\S+\.\S+/;
        console.log('re', re.test(email));
        if (!re.test(email)) {
            var msg = this.lan == 'fr-ch' ? 'Vous avez saisi un format invalide.' : 'You have entered an invalid format.';
            event.target.setCustomValidity(msg);
        } else {
            event.target.setCustomValidity("");
        } 
    }

    UpdateAccount() {

        console.log('Update:>' + this.accountFirstName + ' : ' + this.accountLastName);

        var acc = new Object();
        acc.Id = this.accountId;
        acc.FirstName = this.accountFirstName;
        acc.LastName = this.accountLastName;
        acc.PersonEmail = this.accountEmail;
        console.log('account detail', JSON.stringify(acc));
        updateAccount({ acJson: JSON.stringify(acc) })
            .then(() => {
                console.log('Updated');
            })
            .catch(error => {
                console.log(error);
            });
    }

}