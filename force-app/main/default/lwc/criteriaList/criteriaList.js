import { LightningElement,api ,wire } from 'lwc';
import getCriterias from '@salesforce/apex/CriteriaController.getCriterias'
import getAllAccountFieldsLabels from '@salesforce/apex/CriteriaController.getAllAccountFieldsLabels';

const columns = [
/*     { label: 'Id', fieldName: 'Id', type: 'text' },
    { label: 'Criteria Name', fieldName: 'Name', type: 'text' }, */
    { label: 'Criteria Name', fieldName: 'Name', type: 'text', hideDefaultActions: 'true', wrapText: true },
    { label: 'Operation', fieldName: 'Operation__c', type: 'text', hideDefaultActions: 'true', wrapText: true },
    { label: 'Value', fieldName: 'Value__c', type: 'text',hideDefaultActions: 'true', wrapText: true },
];



export default class CriteriaList extends LightningElement {
    @api recordId;
    error;
    columns = columns;
    criterias = [];
    wiredAccFieldsLabels = [];


    @wire(getCriterias,{segmentId: "$recordId"})
    criterias;


/*     @wire(getAllAccountFieldsLabels)
    wiredAccountFields(result){
        const {data , error} = result;
        if (data) {
            console.log('DATA ---> : ', data)
            data.forEach(function(field){
                this.wiredAccFieldsLabels.labels({ label: `${field}`, value: `${field}`})
            })
            //this.wiredAccFields = labels;
            console.log('FIELDSHOWLIST ---> : ', this.wiredAccFieldsLabels)
        }
    } */

/*     @api columns = columns;
    @api recordId;
    criterias;
    

    @wire(getCriterias,{segmentId: "$recordId"})
    allCriterias(result, error){
        console.log(criterias);
        if (result) {
            console.log(criterias, 'HOLA!!!--->2')
            this.criterias = result;
        } else if (error) {
            console.log('no hay criterios')
            this.criterias = undefined;
        }
    } */
    
}