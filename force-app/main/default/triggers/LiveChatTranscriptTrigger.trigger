trigger LiveChatTranscriptTrigger on LiveChatTranscript (after update) { 
    
    if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> accountIdsSet = new Set<Id>();
        Set<Id> chatTranscriptIdsSet = new Set<Id>();
        Set<Id> missedChatTranscriptCaseIds = new Set<Id>();
        
        for(LiveChatTranscript script : Trigger.new){ 
            if(String.isNotBlank(script.AccountId) && script.AccountId != Trigger.oldMap.get(script.Id).AccountId){            
                accountIdsSet.add(script.AccountId);
                chatTranscriptIdsSet.add(script.Id);
            }
            
            if(script.Status == 'Missed'){
                missedChatTranscriptCaseIds.add(script.CaseId);
            }
        }
        
        if(!accountIdsSet.isEmpty()){
            LiveChatTranscriptTriggerHandler.populatePersonContactOnChatTranscript(accountIdsSet, chatTranscriptIdsSet);
        }
        
        if(!missedChatTranscriptCaseIds.isEmpty()){
            LiveChatTranscriptTriggerHandler.closeParentCases(missedChatTranscriptCaseIds);
        }
    }
}