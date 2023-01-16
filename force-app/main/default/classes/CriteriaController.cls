public with sharing class CriteriaController {
    public CriteriaController() {

        
    }

    @AuraEnabled(cacheable=true)
    public static List<Criteria__c> getCriterias(String segmentId) {
        List<Criteria__c> criterias = [SELECT Id, Name, FieldName__c, Operation__c, Value__c FROM Criteria__c WHERE Segment__c =: segmentId];
        //System.debug(criterias);
        return criterias;
    }

    @AuraEnabled(cacheable=true)
    public static String getAllAccountFieldsLabels(){
        try {
            SObjectType accountType = Schema.getGlobalDescribe().get('Account');
            Map<String, Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            //System.debug('MAP ---> : ' + mfields);
            Map<String, String> labelAndApiName = new Map<String,String>();
            for (Schema.SObjectField field : mfields.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                labelAndApiName.put(fieldDescribe.getLabel(), fieldDescribe.getName());
            }
            String jason = JSON.serialize(labelAndApiName);
/*             List<String> accountFieldsLabels = new List<String>();
            for (Schema.SObjectField field : mfields.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                accountFieldsLabels.add(fieldDescribe.getLabel()); */
                //accountFields.add(''+field);
            //}
            //System.debug('ACOUNTFIELDS ---> : ' + accountFields);
            return jason;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    @AuraEnabled
    public static string dmlOnCriteria(Object data, String removeCriteriaIds) {
        List<Criteria__c> updateCriteria = (List<Criteria__c>) JSON.deserialize(JSON.serialize(data), List<Criteria__c>.class);
        List<Criteria__c> deleteCriteria = new List<Criteria__c>();
 
        if(String.isNotBlank(removeCriteriaIds)){
            List<Id> criteriaIds = removeCriteriaIds.split(',');
            deleteCriteria = [SELECT Id FROM Criteria__c WHERE Id IN :criteriaIds];
        }
 
        try {
            if(updateCriteria != null && !updateCriteria.isEmpty()){
                upsert updateCriteria;
            }
 
            if(deleteCriteria != null && !deleteCriteria.isEmpty()){    
                delete deleteCriteria;
            }
            return 'Success: Criteria(s) upsert/delete successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
       // return '';
    }
}
