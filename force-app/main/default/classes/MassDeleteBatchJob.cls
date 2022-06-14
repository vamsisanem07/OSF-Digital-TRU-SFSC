global class MassDeleteBatchJob implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id FROM ConversationContextEntry';/* where createddate < 2021-01-01T23:01:01+01:00';*/
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<ConversationContextEntry> scope) {

		delete scope;       
                 
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}