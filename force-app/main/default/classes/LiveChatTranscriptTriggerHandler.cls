/*
    @Purpose		: Handler class of Chat Transcript trigger
    @Created Date 	: 09/10/2020
*/
public with sharing class LiveChatTranscriptTriggerHandler {
    
    /*
		@Purpose	: After Account Id is populated on a live chat transcript record, 
					  populates its related Person Contact Id on the transcript
	*/
    public static void populatePersonContactOnChatTranscript(Set<Id> accountIdsSet, Set<Id> chatTranscriptIdsSet){        
        List<Account> accountsList = new List<Account>();
        Map<Id, Id> accountContactIdsMap = new Map<Id, Id>();            
        List<LiveChatTranscript> chatTranscriptList = new List<LiveChatTranscript>();
        
        try{
            accountsList = [SELECT PersonContactId FROM Account WHERE Id IN: accountIdsSet];
            chatTranscriptList = [SELECT ContactId, AccountId FROM LiveChatTranscript WHERE Id IN: chatTranscriptIdsSet];
        }
        catch(Exception e){
            System.debug('Exception in fetching account information : ' + e.getMessage());
        } 
        
        for(Account account : accountsList){
            accountContactIdsMap.put(account.Id, account.PersonContactId);
        } 
        
        for(LiveChatTranscript script : chatTranscriptList){
            if(accountContactIdsMap.containsKey(script.AccountId)){
                script.ContactId = accountContactIdsMap.get(script.AccountId);
            }
        } 
        
        try{
            update chatTranscriptList;
        }
        catch(Exception e){
            System.debug('Exception in updating live chat transcript : ' + e.getMessage());
        }
    }
    
    /*
		@Purpose	: Closes the parent cases when Chat transcript status changes to "Missed"
					  Sets Type and Subject = Unidentified & Level1 and Description = Chat terminated 
	*/
    public static void closeParentCases(Set<Id> caseIds){
        List<Case> parentCasesList = new List<Case>();
        
        try{
            parentCasesList = [SELECT Status, Subject, Description, Disposition_1__c, Type FROM Case WHERE Id IN: caseIds AND Status <> 'Closed'];
        }
        catch(Exception e){
            System.debug('Exception in fetching the parent cases of the missed Chat Transcripts : ' + e.getMessage());
        }
        
        for(Case caseRecord : parentCasesList){
            caseRecord.Status = 'Closed';
            caseRecord.Type = 'Unidentified';
            caseRecord.Subject = 'Unidentified';
            caseRecord.Disposition_1__c = 'Chat terminated';
            caseRecord.Description = 'Chat terminated';
        }
        
        try{
            if(!parentCasesList.isEmpty()){
                update parentCasesList;
            }
        }
        catch(Exception e){
            System.debug('Exception in upading the parent cases of the missed Chat Transcripts : ' + e.getMessage());
        }
    }
}