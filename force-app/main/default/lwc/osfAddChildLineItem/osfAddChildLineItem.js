import { api, LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import myStaticStyles from '@salesforce/resourceUrl/SubscriptionCenterPageStyleSheet';
import formFactorPropertyName from '@salesforce/client/formFactor'
import { NavigationMixin } from 'lightning/navigation';
import name from '@salesforce/label/c.SB_ChildName';
import dob from '@salesforce/label/c.SB_ChildDOB';
import removechild from '@salesforce/label/c.SB_RemoveThisChild';
import updateChildDetails from '@salesforce/apex/OSF_AddChildLwcCtrl.upsertChilds';
import deleteChild from '@salesforce/apex/OSF_AddChildLwcCtrl.deleteChild';



export default class OsfAddChildLineItem extends NavigationMixin(LightningElement) {
    @api childDetail;
    @api allChilds;
    @track devicesize;
    @api Mymap;
    @api lan;
    @api minDate;
    @api maxDate;
    childDisplay = true;
    label = {
        name,
        dob,
        removechild
    };

    labeRemoveChild;
    labelChName;
    labelChDob;
    labelUnderflow;
    labelOverflow;
    labelBadInput;
    connectedCallback() {
        //  console.log(Date.now());
        let today = new Date().toISOString().slice(0, 10);
        this.maxDate = today;
        const aYearFromNow = new Date();
        aYearFromNow.setFullYear(aYearFromNow.getFullYear() - 13);
        this.minDate = aYearFromNow.toISOString().slice(0, 10);
        const month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul","Aug", "Sep", "Oct", "Nov", "Dec"];
        
        const index =this.minDate.split('-');
        var indexVal = parseInt(index[1]);
        var minError = month[indexVal-1] + ' '+index[2]+', '+index[0];
        
        
        const index1 =this.maxDate.split('-');
        var indexVal1 = parseInt(index1[1]);
        var maxError = month[indexVal1-1] + ' '+index1[2]+', '+index1[0];
        
        if (formFactorPropertyName == 'Small') {
            this.devicesize = 'label-stacked';
        } else {
            this.devicesize = 'label-inline';
        }
        this.labeRemoveChild = this.lan == 'fr-ch' ? 'Supprimer cet enfant' : 'Remove this child';
        this.labelChName = this.lan == 'fr-ch' ? "Prénom de l'enfant" : "Child's name";
        this.labelChDob = this.lan == 'fr-ch' ? "Date de naissance:" : "Child's date of birth:";
        this.labelDupeChild = this.lan == 'fr-ch' ? "Ce nom et cette date de naissance ont déjà été soumis. Veuillez vérifier ces renseignements."
            : "Please review: this Name and Date of Birth have already been submitted.";
        this.labelBadInput = this.lan == 'fr-ch' ? "Votre entrée ne correspond pas au format autorisé MMM J AAAA." : "Your entry does not match the allowed format MMM d, yyyy."
        
        this.labelOverflow = this.lan == 'fr-ch' ? 'La date doit être le '+maxError+' ou avant.' : 'Value must be ' + maxError + ' or earlier.'
        this.labelUnderflow = this.lan == 'fr-ch' ? 'La date doit être le '+minError+' ou après.' : 'Value must be ' + minError + ' or later.'

        loadStyle(this, myStaticStyles);

        this.childDetail = Object.assign({}, this.childDetail);
    }

    removeChild(event) {

        deleteChild({ paramstr: JSON.stringify(this.childDetail) })
            .then(() => {
                this.childDisplay = false;
               /* console.log('Delete called');
                const selectedEvent = new CustomEvent("removechild", {
                    detail: this.childDetail,
                    listdetail: this.allChilds
                });

                this.dispatchEvent(selectedEvent);*/

            })
            .catch(error => {
                console.log(error);
            });
    }

    handleName(event) {
        //  this.template.querySelector(".inputName").setCustomValidity("").reportValidity();

        this.childDetail['Name__c'] = event.target.value;
        this.handleonblur();

        this.dupecheck('name');

    }

    updateparent(event) {
        const selectedEvent = new CustomEvent("updatecall", {
            detail: {
                cdata: this.childDetail,
                listdetail: this.allChilds
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleonblur(value) {
        const url = new URL(window.location.href);

        this.childDetail['Account__c'] = url.searchParams.get('id');
        updateChildDetails({ paramstr: JSON.stringify(this.childDetail), acId: url.searchParams.get('id') })
            .then(() => {
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleDOB(event) {
        this.childDetail['Birthday__c'] = event.target.value;
        if (event.target.value >= this.minDate && event.target.value <= this.maxDate) {

            this.handleonblur();
            this.dupecheck('dob');
        }
    }

    dupecheck(param) {
        for (var k in this.allChilds) {
            if (this.allChilds[k].key__c != this.childDetail.key__c
                && this.childDetail.Name__c == this.allChilds[k].Name__c
                && this.childDetail.Birthday__c == this.allChilds[k].Birthday__c) {
                if (param == 'dob') {
                    this.template.querySelector(".inputDate").setCustomValidity(this.labelDupeChild).reportValidity();
                } else {
                    this.template.querySelector(".inputName").setCustomValidity(this.labelDupeChild).reportValidity();
                }

                break;
            }

        }
      /*  if (param == "name") {
            this.template.querySelector(".inputName").setCustomValidity("").reportValidity();

        }
        else {
            this.template.querySelector(".inputDate").setCustomValidity("").reportValidity();
        } */

    }


}