/*
    @Purpose        : Scheduled process for case reassignment owned by Tier 1 agents to the queues
    @Created Date   : 7/8/2020
*/
public class CaseReassignmentBatch implements Database.Batchable<sObject>, schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Account.Language_Preference__c, AccountId FROM Case WHERE Owner.UserRole.Name = \'Tier 1\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> caseList) { 
        Group englishEmails, frenchEmails = new Group();
        
        try{
            englishEmails = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Email_English'];
            frenchEmails = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Email_French'];
        }
        catch(Exception e){
            System.debug('Exception in fetching queue records : ' + e.getMessage());
        }
        
        
        for(Case caseRecord : caseList){            
            if((caseRecord.AccountId == null ||
                caseRecord.Account.Language_Preference__c == null || 
                caseRecord.Account.Language_Preference__c.equalsIgnoreCase('EN')) && englishEmails != null && englishEmails.Id != null){
                    
                caseRecord.OwnerId = englishEmails.Id;
                
                // Set the DML options to prevent the case assignment rules from firing
                Database.DMLOptions options = new Database.DMLOptions();
                options.assignmentRuleHeader.useDefaultRule = false;
                caseRecord.setOptions(options);
            }
            else if(caseRecord.Account.Language_Preference__c.equalsIgnoreCase('FR') && frenchEmails != null && frenchEmails.Id != null){
                caseRecord.OwnerId = frenchEmails.Id;
                
                // Set the DML options to prevent the case assignment rules from firing
                Database.DMLOptions options = new Database.DMLOptions();
                options.assignmentRuleHeader.useDefaultRule = false;
                caseRecord.setOptions(options);
            }
        }
        
                  
        Database.update(caseList);
    }   
    
    
    public void finish(Database.BatchableContext BC) {}
    
    public void execute(SchedulableContext SC) {
        Database.executebatch(new CaseReassignmentBatch());
    }
}