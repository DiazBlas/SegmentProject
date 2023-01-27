public with sharing class SegmentMemberController {
    public SegmentMemberController() {

    }

    //this method return a Map with the Id of de Segment and a List of criterias for each SegmentId
    @AuraEnabled
    public static Map<Id,List<Criteria__c>> criteriasById (){
        List<Segment__c> segmentsId = [SELECT Id FROM Segment__c];
        List<Criteria__c> criterias = [SELECT Id, FieldName__c, Operation__c, Value__c, Segment__c FROM Criteria__C];
        //[select id, (select id from criterias__r ) from segment__c ]
        //for(criteria__c crit: segment.criterias__r){}
        //list<criteria__c>
        Map<Id,List<Criteria__c>> myMap = new Map<Id,List<Criteria__c>>();
        //here i do a map with the Id of the segment as a key and as a value the list of the own criterias
        for (Segment__c seg : segmentsId) {
            List<Criteria__c> cs = new List<Criteria__c>();
            for (Integer i = 0; i < criterias.size(); i++) {
                if (seg.Id == criterias[i].Segment__c){
                    cs.add(criterias[i]);
                    criterias.remove(i);
                }
            }
            myMap.put(seg.Id,cs);
        }
        return myMap;
    }


    @AuraEnabled
    public static Boolean getCheckAListOfCriteriasOfASegment ( List<Criteria__c> criterias, Account acc){
        //List<Id> segments = new List<Id>();
        Boolean cumple = false; 
            for (Criteria__c criteria : criterias) {
                String value = criteria.Value__c;
                String accField = String.valueOf(acc.getSObject(criteria.FieldName__c));
                if(criteria.Value__c.isNumeric()){
                    Integer valueNum = Integer.valueOf(value);

                    if(criteria.Operation__c == 'Equal'){
                        if(accField == value){
                            cumple = true;
                        }
                        else {
                            cumple = false;
                            break;
                        }
                    }
                    if(criteria.Operation__c == 'Greater Than'){
                        if(accField < value){
                            cumple = true;
                        }
                        else {
                            cumple = false;
                            break;
                        }
                    }
                    if(criteria.Operation__c == 'Less Than'){
                        if(accField > value){
                            cumple = true;
                        }
                        else {
                            cumple = false;
                            break;
                        }
                    }
                } else {
                    if(criteria.Operation__c == 'Equal'){
                        if(accField == value){
                            cumple = true;
                        }
                        else {
                            cumple = false;
                            break;
                        }
                    }
                    if(criteria.Operation__c == 'Contain'){

                        if(accField.contains(value)){
                            cumple = true;
                        }
                        else {
                            cumple = false;
                            break;
                        }
                    }
                }


            }
            return cumple;
    }


    @AuraEnabled
    public static String calculate (Id recordId){
        Account account = [SELECT FIELDS(STANDARD) FROM Account WHERE id =: recordId];
        Map<Id,List<Criteria__c>> criterias = criteriasById();
        List<SegmentMember__c> segmentMembers = new List<SegmentMember__c>();
        SegmentMember__c sm = new segmentMember__c();
        for(List<Criteria__c> lis : criterias.values()){
            if(getCheckAListOfCriteriasOfASegment(lis, account)){
                sm.Account__c = account.Id;
                sm.Segment__c = lis[0].Segment__c;
                segmentMembers.add(sm);
            }
        }
        System.debug('Hola' + segmentMembers);
        if(segmentMembers.size() > 0){
            upsert segmentMembers;
        }
        return 'SegmentMember creation SUCCSESS';
    }


}