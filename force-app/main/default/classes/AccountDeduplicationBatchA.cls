public class AccountDeduplicationBatchA implements Database.Batchable<Sobject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(Test.isRunningTest()){
            query = 'SELECT Id, PersonEmail, Email_Key__c FROM Account';
        }
        else{
            query = 'SELECT Id, PersonEmail, Email_Key__c FROM Account WHERE PersonEmail = null AND Email_Key__c != null AND CreatedBy.Name = \'Automated Process\''; 
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Map<String, Id> emailKeyAccountIdMap = new Map<String, Id>();
        List<Account> existingMatchingAccounts = new List<Account>(); 
        Map<String, Account> emailKeyExistingAccountMap = new Map<String, Account>();
        
        for(Account account : scope){
            emailKeyAccountIdMap.put(account.Email_Key__c, account.Id);
        }  
        
        try{             
            existingMatchingAccounts = [SELECT Id, PersonEmail, Email_Key__c FROM Account WHERE PersonEmail IN: emailKeyAccountIdMap.keyset()];
        }
        catch(Exception e){
            System.debug('Exception in fetching accounts from database: ' + e.getMessage());
        }
        
        for(Account existingAccount : existingMatchingAccounts){
            emailKeyExistingAccountMap.put(existingAccount.PersonEmail, existingAccount);
        } 
        
        for(Account newAccount : scope){ 
            if(emailKeyExistingAccountMap.containsKey(newAccount.Email_Key__c)){
                newAccount.Master_Account__c = emailKeyExistingAccountMap.get(newAccount.Email_Key__c).Id;
            }
            else{
                newAccount.PersonEmail = newAccount.Email_Key__c;
            }
        }
        
        List<Database.SaveResult> results = Database.update(scope, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()){
                System.debug('Failure Record Ids While Updating' + result.Id);
                for(Database.Error err : result.getErrors()){
                    System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){ 
    } 
}