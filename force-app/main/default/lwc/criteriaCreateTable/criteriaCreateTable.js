import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getCriterias from '@salesforce/apex/CriteriaController.getCriterias';
import dmlOnCriteria from '@salesforce/apex/CriteriaController.dmlOnCriteria';
import { refreshApex } from '@salesforce/apex';
import getAllAccountFieldsLabels from '@salesforce/apex/CriteriaController.getAllAccountFieldsLabels';


export default class CriteriaCreateTable extends LightningElement {
    @api recordId;
    @track records;
    error;
    @track isLoading = true;
    //@track deleteCriteriasIds = '';
    @track deleteCriteriasIds = [];
    wiredRecords;
    @track wiredAccFieldsAndLabels = [];
    aux = [];
    //@track isDisable = false;

    get operationOptions(){
        return [
            { label: 'Equals', value: 'Equals'},
            { label: 'Greater Than', value: 'Greater Than'},
            { label: 'Less Than', value: 'Less Than'},
            { label: 'Contains', value: 'Contains'},
        ]
    }





    //to close quick action
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    addCriteria() {
        let newCriteria = {Name: "", FieldName__c: "", Operation__c: "", Value__c: "", Segment__c: this.recordId};
        this.records = [...this.records, newCriteria];
    }
    
/*     Error updating or refreshing records
    The following exception has occurred: Upsert failed. First exception on row 4; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Segment, Value, FieldName, Operation]: [Segment, Value, FieldName, Operation] */

/*     get isDisable(){
        console.log('Aca estoy dentro del isDisable --isLoading--: ', this.isLoading);
        console.log('Aca estoy dentro del isDisable --this.wiredRecords.length--: ', this.wiredRecords);
        console.log('Aca estoy dentro del isDisable --this.records.length--: ', this.records);
        //return false;
        if (this.isLoading){
            console.log('aca estoy dentro del if')
            return true;
        }
        else if (!this.records) {
            console.log('aca estoy dentro del else')
            return false;
        } */
        //return (this.isLoading || ( !this.records == undefined));
    //}
    get isDisable(){
        return !(this.records && this.records.data && this.records.data.length);
    }

    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
    
    //update table row values in list
    updateValues(event){
        let foundElement = this.records.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name === 'Field Name'){
            foundElement.FieldName__c = event.target.value;
            console.log('FOUNDELEMENT--->: ', foundElement.FieldName__c)
            let label = this.wiredAccFieldsAndLabels.find(opt => opt.value === event.target.value).label;
            foundElement.Name = label;
            console.log(label);
        } else if(event.target.name === 'Operation'){
            foundElement.Operation__c = event.target.value;
        } else if(event.target.name === 'Value'){
            foundElement.Value__c = event.target.value;
        }
    }
    
    //remove records from table
    handleDeleteAction(event){
        this.deleteCriteriasIds.push(event.target.dataset.id);
        this.records.splice(this.records.findIndex(row => row.Id === event.target.dataset.id), 1);
    }

     //get Segment's criteria records
    @wire(getCriterias, {segmentId : '$recordId'})  
    wiredCriterias(result) {
        //this.wiredRecords = result; // track the provisioned value
        const { data, error } = result;
        console.log('DATA', result.data)
        if(data) {
            this.records = JSON.parse(JSON.stringify(data));
            this.error = undefined;
            this.handleIsLoading(false);
        } else if(error) {
            console.log('isLoading1 ---->: ',this.isLoading);
            this.error = error;
            console.log('ERROR--->: ', this.error.body.message);
            this.records = undefined;
            this.showToast('Error de permiso', error.body.message, 'Error', 'dismissable');
            this.handleIsLoading(false);
            console.log('isLoading2 ---->: ',this.isLoading);
        }
    }

    @wire(getAllAccountFieldsLabels)
    wiredAccountFieldsLabels(result){
        const {data , error} = result;
        if (data) {
            //console.log('DATA ---> : ', data)
            let labelsAndApiNames = JSON.parse(data);
            for (const key in labelsAndApiNames) {
                //console.log('Llave : ', key, 'Valor : ', labelsAndApiNames[key]);
                this.wiredAccFieldsAndLabels.push({ label: `${key}`, value: `${labelsAndApiNames[key]}`})
            }
            //console.log('labelsAndApiNames ---> : ', labelsAndApiNames)
        }
    }



    //handle save and process dml 
    handleSaveAction(){
        this.handleIsLoading(true);

        dmlOnCriteria({data: this.records, removeCriteriasIds : this.deleteCriteriasIds})
        .then( result => {
            console.log('ACA estoy dentro de dmlOnCriteria THEN')
            this.handleIsLoading(false);
            refreshApex(this.wiredRecords);
            this.updateRecordView(this.recordId);
            this.closeAction();
            this.showToast('Success', result, 'Success', 'dismissable');
        }).catch( error => {
            this.handleIsLoading(false);
            //console.log(error);
            this.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
        });
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

    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 3000); 
     }
}



