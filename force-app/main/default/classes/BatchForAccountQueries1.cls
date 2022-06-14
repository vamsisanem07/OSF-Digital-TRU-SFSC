global class BatchForAccountQueries1 implements Database.Batchable<sObject>,Database.Stateful {
    
    public integer countCase1 = 0;
    public integer countCase3 = 0;
    public List<Account> accountListCase1 = new List<Account>();
    public List<String> accountListCase3 = new List<String>();


    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  ' SELECT Id, R_Club_Number__c ';
               query += ' FROM Account WHERE R_Club_Number__c != NULL';

        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        //List<Account> toUpdateAccountList = new List<Account>();
        List<Account> toUpdateAccountList =  [SELECT Id, PersonEmail, R_Club_Number__c, R_Club_Join_Date__c,
                                              (SELECT R_Club_Number__c FROM R_Club_Numbers__r WHERE Primary__c = true LIMIT 1)
                                              FROM Account WHERE R_Club_Number__c != NULL AND id IN: accountList];
        
        for(Account accountRecord : toUpdateAccountList){
            /* if(accountRecord.R_Club_Numbers__r.size() == 0){
                accountListCase3.add(accountRecord.Id);
                countCase3++;
            }*/
            for(R_Club_Number__c rClubeNumberRec : accountRecord.R_Club_Numbers__r){
                if(accountRecord.R_Club_Number__c != rClubeNumberRec.R_Club_Number__c ){
                    accountListCase1.add(accountRecord);
                    countCase1++;
                }
            }
         }
    }   
    
    global void finish(Database.BatchableContext BC) {
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'nikita@dreamwares.com', 'annemarie@majente.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job is done for Rlub object exists for the account and the account RClub number does not = Primary Rclub number ');
        mail.setPlainTextBody(' Count '+ countCase1+'  Total AccountList  ' +'  '+ JSON.serialize(accountListCase1));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}