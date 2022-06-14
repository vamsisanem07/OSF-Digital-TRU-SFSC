/*
 * @Purpose : This is data correction batch class to correct the Opt In dates for its repective Opt In values.
*/
global class batchAccountUpdate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id, Email_Opt_In_TRU__c, Email_Opt_In_BRU__c, Child_Birthday_Opt_In__c, Loyalty_Opt_In__c, ';
               query += ' Email_Opt_In_Date_TRU__c, Email_Opt_In_Date_BRU__c, Child_Birthday_Email_Opt_In_Date__c, Loyalty_Opt_In_Date__c FROM Account';
        	   query += ' WHERE (Email_Opt_In_TRU__c = false AND Email_Opt_In_Date_TRU__c != NULL) OR (Email_Opt_In_BRU__c = false AND Email_Opt_In_Date_BRU__c != NULL) OR (Child_Birthday_Opt_In__c = false AND Child_Birthday_Email_Opt_In_Date__c != NULL) OR (Loyalty_Opt_In__c = false AND Loyalty_Opt_In_Date__c != NULL)';

        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        List<Account> toUpdateAccountList = new List<Account>();
        for(Account accountRecord : accountList){
            if(accountRecord.Email_Opt_In_TRU__c == false && accountRecord.Email_Opt_In_Date_TRU__c != NULL)
                 accountRecord.Email_Opt_In_Date_TRU__c = NULL;
            
            if(accountRecord.Email_Opt_In_BRU__c == false && accountRecord.Email_Opt_In_Date_BRU__c != NULL)
                 accountRecord.Email_Opt_In_Date_BRU__c = NULL;
            
            if(accountRecord.Child_Birthday_Opt_In__c == false && accountRecord.Child_Birthday_Email_Opt_In_Date__c != NULL)
                 accountRecord.Child_Birthday_Email_Opt_In_Date__c = NULL;
            
            if(accountRecord.Loyalty_Opt_In__c == false && accountRecord.Loyalty_Opt_In_Date__c != NULL)
                 accountRecord.Loyalty_Opt_In_Date__c = NULL;
            
            toUpdateAccountList.add(accountRecord);
         }
         
        update toUpdateAccountList;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}