public with sharing class CriteriaController {
    public CriteriaController() {

        
    }


    @AuraEnabled(cacheable=true)
    public static Boolean hasAccess(){
        try {
            Boolean access = false;
            if (Schema.SObjectType.Criteria__c.isAccessible()){
                access = true;
            }
            //System.debug(access);
            return access;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public  static List<Criteria__c> getCriterias(String segmentId) {
        List<Criteria__c> criterias = new List<Criteria__c>();
        if (hasAccess()){
            criterias = [SELECT Id, Name, FieldName__c, Operation__c, Value__c FROM Criteria__c WHERE Segment__c =: segmentId WITH SECURITY_ENFORCED];
            return criterias;
        } else {
            throw new AuraHandledException('No tienes acceso a los criterios');
        }
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
    public static string dmlOnCriteria(Object data, List<String> removeCriteriasIds) {
        List<Criteria__c> updateCriterias = (List<Criteria__c>) JSON.deserialize(JSON.serialize(data), List<Criteria__c>.class);
        List<Criteria__c> deleteCriterias = new List<Criteria__c>();
 
        //if(String.isNotBlank(removeCriteriasIds)){
            //List<Id> criteriaIds = removeCriteriaIds.split(',');
        deleteCriterias = [SELECT Id FROM Criteria__c WHERE Id IN :removeCriteriasIds];
        //}
        // Convert List<String> to List<Id>
        //List<String> stringList = removeCriteriasIds;
/*         List<Id> idListToDelete = new List<Id>();
        if (!removeCriteriasIds.isEmpty()) {
            for (String id : removeCriteriasIds) {
                idListToDelete.add(id);
            }
        } */
        try {
            if(updateCriterias != null && !updateCriterias.isEmpty()){
                upsert updateCriterias;
            }
 
            if(!deleteCriterias.isEmpty()){    
                delete deleteCriterias;
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
