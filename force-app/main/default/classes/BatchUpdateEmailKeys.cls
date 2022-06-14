global class BatchUpdateEmailKeys implements Database.Batchable<sObject> {
    global final String Query;
    
    global BatchUpdateEmailKeys(String q){
        Query=q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Account> accountsForUpdate = new List<Account>();
        for(Sobject sObj : scope) {
            Account a = (Account)sObj;
            if(a.PersonEmail != null && !String.isBlank(a.PersonEmail)) {
	            a.Email_Key__c = a.PersonEmail;	                
                a.SFCC_update__c = TRUE;  // be sure to set the From_SFCC__c field so it doesn't perform callouts to SFCC    
                accountsForUpdate.add(a);
            }
        }
        
        update accountsForUpdate;
        
    }
    
    global void finish(Database.BatchableContext BC){
    }

}