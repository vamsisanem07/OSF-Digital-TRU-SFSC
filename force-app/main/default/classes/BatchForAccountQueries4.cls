global class BatchForAccountQueries4 implements Database.Batchable<sObject>,Database.Stateful {
    
    public integer count = 0;
    public List<String> accountListCase3 = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  ' SELECT Id, R_Club_Number__c ';
               query += ' FROM Account WHERE R_Club_Number__c != NULL';

        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
       
       // Map<String, List<R_Club_Number__c>> accountIdRClubMap = new Map<String, R_Club_Number__c>();
        
       /* List<R_Club_Number__c> RClubList = [SELECT Id, R_Club_Number__c, Account__c 
                                            FROM R_Club_Number__c 
                                            WHERE Account__c IN: accountList];
        for(R_Club_Number__c RClubRec : RClubList){
            accountIdRClubMap.put(RClubRec.Account__c, RClubRec);
        }*/
        
        List<Account> accountNewList = [SELECT Id, R_Club_Number__c, (SELECT Id, R_Club_Number__c, Account__c FROM R_Club_Numbers__r  WHERE Primary__c 
                                                                      != true)
                                        FROM Account
                                        WHERE Id IN: accountList];
        
        for(Account accountRecord : accountNewList){
            if(accountRecord.R_Club_Numbers__r.size() == 1){
                if(accountRecord.R_Club_Numbers__r[0].R_Club_Number__c == accountRecord.R_Club_Number__c){
                    accountListCase3.add(accountRecord.Id);
                    count++;
                }
            }
         }
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug(count);
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'nikita@dreamwares.com', 'annemarie@majente.com' };
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job is done for RClub number on the account is not null and one RClub exists for the account with same RClube on that account');
        mail.setPlainTextBody(' Count '+ count + '  Total AccountIds == ' +'  '+ JSON.serialize(accountListCase3));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}