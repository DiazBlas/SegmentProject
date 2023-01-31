
global with sharing class ScheduleBatchCalculate implements Schedulable {
    global ScheduleBatchCalculate() {

    }

    global void execute(SchedulableContext sc) {
        List<SegmentMember__c> segMembers = new List<SegmentMember__c>();
        delete segMembers;
        SegmentMemberUpdateBatchJob b = new SegmentMemberUpdateBatchJob(); 
        Database.executeBatch(b);
     }

}