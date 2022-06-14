import { LightningElement } from 'lwc';
import Rclub_Join from '@salesforce/label/c.Rclub_Join';
import Rclub_subtitle_benefits from '@salesforce/label/c.Rclub_subtitle_benefits';
import Rclub_benefit1 from '@salesforce/label/c.Rclub_benefit1';
import Rclub_benefit2 from '@salesforce/label/c.Rclub_benefit2';
import Rclub_benefit3 from '@salesforce/label/c.Rclub_benefit3';
import Rclub_benefit4 from '@salesforce/label/c.Rclub_benefit4';
import Rclub_benefit5 from '@salesforce/label/c.Rclub_benefit5';
import Rclub_benefit6 from '@salesforce/label/c.Rclub_benefit6';
import Rclub_Signed_up_in_store from '@salesforce/label/c.Rclub_Signed_up_in_store';
import Rclub_I_HAVE_CARD from '@salesforce/label/c.Rclub_I_HAVE_CARD';
import Rclub_SignUpOnline from '@salesforce/label/c.Rclub_SignUpOnline';
import Rclub_RegisterCard from '@salesforce/label/c.Rclub_RegisterCard';

export default class JoinRClub extends LightningElement {
    label = {
        Rclub_Join,
        Rclub_subtitle_benefits,
        Rclub_benefit1,
        Rclub_benefit2,
        Rclub_benefit3,
        Rclub_benefit4,
        Rclub_benefit5,
        Rclub_benefit6,
        Rclub_Signed_up_in_store,
        Rclub_I_HAVE_CARD,
        Rclub_RegisterCard,
        Rclub_SignUpOnline
    };
}