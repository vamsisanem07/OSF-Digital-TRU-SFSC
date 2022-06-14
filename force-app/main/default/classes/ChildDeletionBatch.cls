public class ChildDeletionBatch implements Database.Batchable<Sobject>{
	public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id from child__c where duplicate_record__c = true '; 
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> scope){
        delete scope; 
    }
    
    public void finish(Database.BatchableContext BC){ 
    }
}