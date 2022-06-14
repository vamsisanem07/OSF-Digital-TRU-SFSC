import { LightningElement, api, track } from 'lwc';
import getChildDetails from '@salesforce/apex/OSF_AddChildLwcCtrl.getChildsfromAccount';
import { loadStyle } from 'lightning/platformResourceLoader';
import myStaticStyles from '@salesforce/resourceUrl/SubscriptionCenterPageStyleSheet';
import addchild from '@salesforce/label/c.SB_AddAnotherChild';

export default class OsfAddChildContainer extends LightningElement {
    
    label = {
        addchild
    }
    @api accountId;
    @api lan;
    @track labelAddChild;
    childIndex = 0;
    @track childList = [];
    @track childsListfromAccount = [];
    connectedCallback() {
        loadStyle(this, myStaticStyles);
        this.labelAddChild = this.lan == 'fr-ch' ? 'Ajouter un autre enfant' : 'Add another child';

        this.langcmp = this.lan;
        var acIdParam = new URL(window.location.href).searchParams.get("id");
        getChildDetails({ acId: acIdParam })
            .then(result => {
                for (var c in result) {

                    let person = { Name__c: result[c].Name__c, Birthday__c: result[c].Birthday__c, Account__c: this.accountId, key__c:result[c].key__c , Duplicate_Group__c: result[c].Duplicate_Group__c };
                    this.childList.push(person);

                    this.childIndex++;

                }
                this.childsListfromAccount = Object.assign({}, result);

            })
            .catch(error => {
                console.log('Error' + error);
            });
    }

    handleButtonClick(event) {
        let person = { Name__c: "", Birthday__c: new Date(12, 12, 2012), Account__c: this.accountId, key__c: 'child' + this.childIndex, Duplicate_Group__c: null };
        this.childList.push(person);
        this.childIndex++;

    }
/*
    deletechild(event) {
        for (var k in this.childList) {
            if (this.childList[k].key__c == event.detail.key__c) {
              //remove element from index k in childList
                this.childList.splice(k, 1);
            }
        }
    }*/
}