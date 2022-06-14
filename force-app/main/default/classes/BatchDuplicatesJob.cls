global class BatchDuplicatesJob implements Database.Batchable<sObject>, Database.Stateful{
    global final String Query;
    
    global integer Duplicates = 0; 
    
    global BatchDuplicatesJob(String q){
        Query=q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //for a given context query all the email addresses in the set
        Set<String> emailsToQuery = new Set<String>();
        List<Account> duplicatesToUpdate = new List<Account>();
        
        for(sObject sobj : scope) {
            Account a = (Account)sobj;
            emailsToQuery.add(a.PersonEmail);
        }
        Map<Id,Account> matches = new Map<Id,Account>([SELECT Id, Email_Key__c, PersonEmail FROM Account WHERE PersonEmail IN :emailsToQuery]);
        // create a set that is keyed by email address
        Map<String,Account> matchesByEmail = new Map<String,Account>();
        for(Account a: matches.values()) {
            matchesByEmail.put(a.PersonEmail, a);
        }
        
        // in the set, if there are multiple emails we need to know
        Map<String,List<Account>> dups = new Map<String,List<Account>>();
        for(Account a: matches.values()) {
            if(!String.isBlank(a.PersonEmail)) {
                if(dups.containsKey(a.PersonEmail)) {
                    // this is duplicate, add it and update both records
                    a.Duplicate_BR__c = TRUE;
                    dups.get(a.PersonEmail).add(a);
                    duplicatesToUpdate.addAll(dups.get(a.PersonEmail));
                    Duplicates = Duplicates + 1;
                }
                else {
                    a.Duplicate_BR__c = TRUE; // marking this but it wont be added to update set unless meets above criteria
                    dups.put(a.PersonEmail, new List<Account>{a});
                } 
            }
        }
        
        update duplicatesToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('There were ' + Duplicates + ' duplicates found.');
    }

}