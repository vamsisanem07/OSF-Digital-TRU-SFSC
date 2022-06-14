/*
    @Purpose        : Scheduled process for closing Open cases with chat origin and 
					  NOT having any Live Chat Transcripts associated with them
    @Created Date   : 29/10/2020
*/
public class CloseOrphanChatCasesBatch implements Database.Batchable<sObject>, schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        
        if(Test.isRunningTest()){
            query = 'SELECT Id, (SELECT Id FROM LiveChatTranscripts) FROM Case WHERE Origin = \'Chat\' AND Status = \'New\'';
        }
        else{
            query = 'SELECT Id, (SELECT Id FROM LiveChatTranscripts) FROM Case WHERE Owner.Name = \'Automated Process\' AND Origin = \'Chat\' AND Status = \'New\'';
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> caseList) { 
        Store__c onlineStore;
        Id contactusRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contact Us').getRecordTypeId(); 

        try{
            onlineStore = [SELECT Id FROM Store__c WHERE Keytree_ID__c = '3580' LIMIT 1];
        }
        catch(Exception e){
            System.debug('Exception in fetching online store: ' + e.getMessage());
        }
        
 
        for(Case caseRecord : caseList){   
            if(caseRecord.LiveChatTranscripts.isEmpty()){
                caseRecord.Status = 'Closed';
                caseRecord.Type = 'Unidentified';
                caseRecord.Subject = 'Unidentified';
                caseRecord.Disposition_1__c = 'Chat terminated';
                caseRecord.Description = 'Chat terminated';
                caseRecord.RecordTypeId = contactusRecordTypeId;
                
                if(onlineStore != null && onlineStore.Id != null){
                    caseRecord.Store__c = onlineStore.Id;
				}
            }
        }
                  
        Database.update(caseList);
    }   
    
    
    public void finish(Database.BatchableContext BC) {}
    
    public void execute(SchedulableContext SC) {
        Database.executebatch(new CloseOrphanChatCasesBatch());
    }
}