public with sharing class CriteriaController {
    public CriteriaController() {

        
    }

    @AuraEnabled(cacheable=true)
    public static List<Criteria__c> getCriterias(String segmentId) {
        List<Criteria__c> criterias = [SELECT Id, FieldName__c, Operation__c, Value__c FROM Criteria__c WHERE Segment__c =: segmentId];
        System.debug(criterias);
        return criterias;
    }
}
