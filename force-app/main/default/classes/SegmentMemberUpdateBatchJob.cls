global with sharing class SegmentMemberUpdateBatchJob implements Database.Batchable<sObject> {
    global SegmentMemberUpdateBatchJob() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id FROM Account';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        for(Account a : scope)
        {
            SegmentMemberController.calculate(a.Id);
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}