public with sharing class AccountTriggerHandler {

    public static void setEmailKey(List<Account> newAccounts) {
        for(Account a : newAccounts) {
            if(a.PersonEmail != null && !String.isBlank(a.PersonEmail)) {
                a.Email_Key__c = a.PersonEmail;
            }
            if(a.Email_Key__c != null && !String.isBlank(a.Email_Key__c)) {
                a.PersonEmail = a.Email_Key__c;
            }
        }
    }
}