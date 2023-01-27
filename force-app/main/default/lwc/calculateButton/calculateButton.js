import calculate from '@salesforce/apex/SegmentMemberController.calculate';
import { LightningElement, api } from 'lwc';

export default class CalculateButton extends LightningElement {
    @api recordId;


    handleClick(){
        calculate({recordId : this.recordId})
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        //this.handleIsLoading(false);
        this.dispatchEvent(event);
    }
}