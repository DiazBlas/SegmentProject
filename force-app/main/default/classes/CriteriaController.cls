public with sharing class CriteriaController {
    public CriteriaController() {

        
    }

    //this method return a map with all criteria's name as a key and a boolean as a value, where the value as a true 
    //  indicates that the field is accesible and de false value indicates it is not
/*     @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> allCriteriaFieldsAccess () {
        SObjectType criteria = Schema.getGlobalDescribe().get('Criteria__c');
        Map<String, Schema.SObjectField> mfields = criteria.getDescribe().fields.getMap();
        Map<String,Boolean> fieldAccess = new Map<String,Boolean>();
        for (Schema.SObjectField field : mfields.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.isAccessible()){
                fieldAccess.put(fieldDescribe.getName(), true);
            }
            else {
                fieldAccess.put(fieldDescribe.getName(),false);
            }
        }
        return fieldAccess;
    } */

    //this method return a boolean if the current user has access to all of criteria's field
/*     @AuraEnabled(cacheable=true)
    public static Boolean accessTotalCriteriaFields (){
        Map<String,Boolean> criteriaFields = allCriteriaFieldsAccess();
            for (String key : criteriaFields.keySet()) {
                if (criteriaFields.get(key)){
                    return false;
                }
            }
        return true;
    } */

    //this method get a List with all the fields with access
/*     public static List<String> criteriaFieldsWithAccess () {
        Map<String,Boolean> fields = allCriteriaFieldsAccess();
        List<String> fieldsWithAccess = new List<String>();
        for (String key : fields.keySet()){
            if (fields.get(key)){
                fieldsWithAccess.add(key);
            }
        }
        return fieldsWithAccess;
    } */

    //this method return a boolean value if the current user has access to the criteria object and if the user has 
    //  access to all the criteria's fields
    @AuraEnabled(cacheable=true)
    public static Boolean hasAccess(){
        try {
            Boolean access = false;
            if (Schema.SObjectType.Criteria__c.isAccessible()){
                access = true;
            }
            return access;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

/*     @AuraEnabled(cacheable=true)
    public static Boolean hasAccess(){
        try {
            Boolean access = false;
            if ((Schema.SObjectType.Criteria__c.isAccessible() && accessTotalCriteriaFields()) || (Schema.SObjectType.Criteria__c.isAccessible() && criteriaFieldsWithAccess().size() > 0)){
                access = true;
            }
            return access;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */

    //PREGUNTA QUE PASARIA SI TENGO ACCESO AL OBJETO PERO NO A TODOS SUS CAMPOS?
    //  SE PUEDE PONER UNA LISTA EN EL SELECT? [SELECT MILISTA FROM OBJETO]
    //  COMO SE UTILIZA EL FIELDS(ALL)?
    @AuraEnabled(cacheable=true)
    public  static List<Criteria__c> getCriterias(String segmentId) {
        List<Criteria__c> criterias = new List<Criteria__c>();
        if (hasAccess()){
            //List<String> fields = criteriaFieldsWithAccess(); 
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, 
                            [SELECT Id, Name, FieldName__c, Operation__c, Value__c FROM Criteria__c WHERE Segment__c =: segmentId WITH SECURITY_ENFORCED]);
            criterias = securityDecision.getRecords();
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
            Map<String, String> labelAndApiName = new Map<String,String>();
            for (Schema.SObjectField field : mfields.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    if ( (fieldDescribe.getType() == Schema.DisplayType.Currency) || (fieldDescribe.getType() == Schema.DisplayType.String) || (fieldDescribe.getType() == Schema.DisplayType.Integer) || (fieldDescribe.getType() == Schema.DisplayType.TextArea)){
                        labelAndApiName.put(fieldDescribe.getLabel(), fieldDescribe.getName());
                    }
            }   
            String jason = JSON.serialize(labelAndApiName);
            return jason;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getOperation () {
        Schema.DescribeFieldResult F = Criteria__c.Operation__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        List<String> values = new List<String>();
        for (Schema.PicklistEntry pick : P) {
            values.add(pick.getValue());
        }
        system.debug(values);
        return values;
    }

    @AuraEnabled
    public static string dmlOnCriteria(Object data, List<String> removeCriteriasIds) {
        List<Criteria__c> updateCriterias = (List<Criteria__c>) JSON.deserialize(JSON.serialize(data), List<Criteria__c>.class);
        List<Criteria__c> deleteCriterias = new List<Criteria__c>();
        deleteCriterias = [SELECT Id FROM Criteria__c WHERE Id IN :removeCriteriasIds];
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
    }
}
