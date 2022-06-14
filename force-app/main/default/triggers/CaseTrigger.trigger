trigger CaseTrigger on Case (before insert, before update, after insert) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        CaseTriggerHandler.onBeforeInsert(Trigger.new);
        CaseUtils.populateCaseQueueSubtype(Trigger.new);
        CaseUtils.populateFieldsOnOfflineCase(Trigger.new);
        CaseUtils.populateTranscomOperationsEmailOnCase(Trigger.new);   
    }
    if(Trigger.isBefore && Trigger.isInsert){
        CaseTriggerHandler.handleCasePersonLink(Trigger.new[0]);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        List<Case> updatedCases = new List<Case>();
        List<Case> closedCases = new List<Case>();
        List<Case> casesRelatedToPersonAccount = new List<Case>();
        
        for(Case caseRecord : Trigger.new){
            if(caseRecord.Status != Trigger.oldMap.get(caseRecord.Id).Status && (caseRecord.Status == 'Closed' ||
                                                                                caseRecord.Status == 'Pending')){
                closedCases.add(caseRecord);
            }
            
            if(caseRecord.Disposition_1__c != Trigger.oldMap.get(caseRecord.Id).Disposition_1__c ||
               caseRecord.Disposition_2__c != Trigger.oldMap.get(caseRecord.Id).Disposition_2__c){
                updatedCases.add(caseRecord);
            }
            
            if(caseRecord.AccountId != Trigger.oldMap.get(caseRecord.Id).AccountId){
                casesRelatedToPersonAccount.add(caseRecord);
            }
        }
        
        if(!closedCases.isEmpty()){        
            CaseUtils.populateOrgWideEmailsOnCase(closedCases);
        }
        
        if(!updatedCases.isEmpty()){        
            CaseUtils.populateCaseQueueSubtype(updatedCases);
        }
        
        if(!casesRelatedToPersonAccount.isEmpty()){        
            CaseTriggerHandler.populatePersonContactOnCase(casesRelatedToPersonAccount);
        }
    }   
    
    if(Trigger.isInsert && Trigger.isAfter){
        CaseUtils.createChatterPost(Trigger.new);
    }
}