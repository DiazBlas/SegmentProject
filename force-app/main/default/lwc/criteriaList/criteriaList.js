import { LightningElement,api ,wire } from 'lwc';
import getCriterias from '@salesforce/apex/CriteriaController.getCriterias'

const columns = [
    { label: 'Field Name', fieldName: 'FieldName__c', type: 'text', editable: true },
    { label: 'Operation', fieldName: 'Operation__c', type: 'text', editable: true },
    { label: 'Value', fieldName: 'Value__c', type: 'text', editable: true },
];



export default class CriteriaList extends LightningElement {
    @api recordId;
    error;
    columns = columns;
    criterias = [];

    @wire(getCriterias,{segmentId: "$recordId"})
    criterias;


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