import { LightningElement,api ,wire } from 'lwc';
import getCriterias from '@salesforce/apex/CriteriaController.getCriterias'
import getAllAccountFieldsLabels from '@salesforce/apex/CriteriaController.getAllAccountFieldsLabels';

const columns = [
    { label: 'Criteria Name', fieldName: 'Name', type: 'text', hideDefaultActions: 'true', wrapText: true },
    { label: 'Operation', fieldName: 'Operation__c', type: 'text', hideDefaultActions: 'true', wrapText: true },
    { label: 'Value', fieldName: 'Value__c', type: 'text',hideDefaultActions: 'true', wrapText: true },
];



export default class CriteriaList extends LightningElement {
    @api recordId;
    error;
    columns = columns;
    @api criterias = [];
    wiredAccFieldsLabels = [];


    @wire(getCriterias,{segmentId: "$recordId"})
    criterias;
    
}