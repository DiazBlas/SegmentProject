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
            if (cs.size() > 0){
                myMap.put(seg.Id,cs);
            }
        }
        //System.debug(myMap);
        return myMap;
    }

    @AuraEnabled
    public static Boolean getCheckAListOfCriteriasOfASegment ( List<Criteria__c> criterias, Account acc){
        //System.debug('ENTRE AL CHECK');
        for (Criteria__c criteria : criterias) {
            //System.debug('ENTRE AL FOR DEL CHECK');
            String value = criteria.Value__c;
            String field = criteria.FieldName__c;
            String operation = criteria.Operation__c;
            if(value.isNumeric()){
                Integer valueNumCri = Integer.valueOf(value);
                if (Integer.valueOf(acc.get(field)) != null ){
                    Integer valueFieldObj = Integer.valueOf(acc.get(field));
                    if(operation == 'Equal' && valueFieldObj != valueNumCri){
                            return false;
                    }
                    if(operation == 'Greater Than' && valueNumCri > valueFieldObj){
                            return false;
                    }
                    if(operation == 'Less Than' && valueNumCri < valueFieldObj){
                            System.debug('LESS THAN');
                            return false;
                    }
                }
            } else {
                String valueFieldObj = String.valueOf(acc.get(field));
                if(operation == 'Equal' && value != valueFieldObj){
                        return false;
                }
                if(operation == 'Contain' && !valueFieldObj.contains(value)){
                        return false;
                }
            }
        }
        //System.debug('ESTOY POR SALIR DEL CHECK');
        return true;
    }

    @AuraEnabled
    public static List<SegmentMember__c> getAssignSegments (Account account){
        Map<Id,List<Criteria__c>> criterias = criteriasById();
        List<SegmentMember__c> segmentMembers = new List<SegmentMember__c>();
        for(List<Criteria__c> lis : criterias.values()){
            if(getCheckAListOfCriteriasOfASegment(lis, account)){
                SegmentMember__c sm = new SegmentMember__c(
                    Account__c = account.Id,
                    Segment__c = lis[0].Segment__c
                );
                segmentMembers.add(sm);
            }
        }
        return segmentMembers;
    }

    public static List<SegmentMember__c> getSegmentMembersToUpsert (Account account) {
        List<SegmentMember__c> mySegmentMembers = getAssignSegments(account);
        List<SegmentMember__c> allSegmentMembers = [SELECT Account__c, Segment__c FROM SegmentMember__c];
        List<Integer> collIndex = new List<Integer>();
        for (SegmentMember__c mySm : mySegmentMembers) {
            for (Integer i = 0; i < allSegmentMembers.size(); i++) {
                if (mySm.Account__c == allSegmentMembers[i].Account__c && mySm.Segment__c == allSegmentMembers[i].Segment__c){
                    collIndex.add(i);
                }
            }
        }
        for (Integer i : collIndex) {
            mySegmentMembers.remove(i);
        }
        return mySegmentMembers;
    }

    @AuraEnabled
    public static void calculate (Id recordId){
        Account account = [SELECT FIELDS(STANDARD) FROM Account WHERE id =: recordId];
        List<SegmentMember__c> segMenToUpsert = getSegmentMembersToUpsert (account);
        System.debug('Hola' + segMenToUpsert);
        if(segMenToUpsert.size() > 0){
            upsert segMenToUpsert;
        }
        //return 'SegmentMembers creation SUCCSESS';
    }
}