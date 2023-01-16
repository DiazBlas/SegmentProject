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
    @track deleteCriteriasIds = '';
    wiredRecords;
    wiredAccFieldsAndLabels = [];
    aux = [];

    get operationOptions(){
        return [
            { label: 'Equals', value: 'equals'},
            { label: 'Greater Than', value: 'greater than'},
            { label: 'Less Than', value: 'less than'},
            { label: 'Contains', value: 'contains'},
        ]
    }





    //to close quick action
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    addCriteria() {
        let newCriteria = {FieldName__c: "", Operation__c: "", Value__c: "", Segment__c: this.recordId};
        this.records = [...this.records, newCriteria];
    }
    
/*     Error updating or refreshing records
    The following exception has occurred: Upsert failed. First exception on row 4; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Segment, Value, FieldName, Operation]: [Segment, Value, FieldName, Operation] */

    get isDisable(){
        return (this.isLoading || (this.wiredRecords.data.length == 0 && this.records.length == 0));
    }

    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
    
    //update table row values in list
    updateValues(event){
        let foundElement = this.records.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name === 'Criteria Name'){
            foundElement.Name = event.target.value;
        } else if(event.target.name === 'Operation'){
            foundElement.Operation__c = event.target.value;
        } else if(event.target.name === 'Value'){
            foundElement.Value__c = event.target.value;
        }
    }

    
    //remove records from table
    handleDeleteAction(event){
        let aux;
        if(isNaN(event.target.dataset.id)){
            this.deleteCriteriasIds = this.deleteCriteriasIds + ',' + event.target.dataset.id;
        }
        this.records.splice(this.records.findIndex(row => row.Id === event.target.dataset.id), 1);
/*         aux = this.records;
        console.log("RECORDS ---->: ", aux) */
    }

     //get Segment's criteria records
    @wire(getCriterias, {segmentId : '$recordId'})  
    wiredCriterias(result) {
        this.wiredRecords = result; // track the provisioned value
        const { data, error } = result;
        //console.log(result.data)
        if(data) {
            this.records = JSON.parse(JSON.stringify(data));
            this.error = undefined;
            this.handleIsLoading(false);
        } else if(error) {
            this.error = error;
            this.records = undefined;
            this.handleIsLoading(false);
        }
    }

    @wire(getAllAccountFieldsLabels)
    wiredAccountFieldsLabels(result){
        const {data , error} = result;
        if (data) {
            console.log('DATA ---> : ', data)
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
 
        if(this.deleteCriteriasIds !== ''){
            this.deleteCriteriasIds = this.deleteCriteriasIds.substring(1);
        }
 
        this.records.forEach(res =>{
            if(!isNaN(res.Id)){
                res.Id = null;
            }
        });
         
        dmlOnCriteria({data: this.records, removeContactIds : this.deleteCriteriasIds})
        .then( result => {
            this.handleIsLoading(false);
            refreshApex(this.wiredRecords);
            this.updateRecordView(this.recordId);
            this.closeAction();
            this.showToast('Success', result, 'Success', 'dismissable');
        }).catch( error => {
            this.handleIsLoading(false);
            console.log(error);
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
        this.dispatchEvent(event);
    }

    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 3000); 
     }
}



