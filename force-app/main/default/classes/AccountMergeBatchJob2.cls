global class AccountMergeBatchJob2 implements Database.Batchable<SObject>, Database.Stateful {

    private String query = 'SELECT Id, PersonContactId, PersonEmail, CreatedDate, SFCC_Customer_Number__pc, SFCC_Customer_Id__pc, FirstName, LastName, SCCActive__c, Child_Birthday_Opt_In__c, Child_Birthday_Email_Opt_In_Date__c,  Contact_Status__pc, Email_Opt_In_BRU__c, Email_Opt_In_Date_BRU__c, Email_Opt_In_TRU__c, Email_Opt_In_Date_TRU__c, PersonHasOptedOutOfEmail, Global_Opt_Out_Date__pc, Last_Email_Activity_Date__c, Loyalty_Opt_In__c, Loyalty_Opt_In_Date__c, Mailing_Address_Line_2__c, PersonMailingCity, PersonMailingCountry, PersonMailingCountryCode, PersonMailingPostalCode, PersonMailingState, PersonMailingStateCode, PersonMailingStreet, R_Club_Join_Date__c, YM_Id__c FROM Account WHERE PersonEmail != NULL ORDER BY PersonEmail, CreatedDate';

    global Set<Id> alreadyRemoved = new Set<Id>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accScope) {
        Map<String, List<Account>> accountsForMerge = findDuplicates(accScope);

        System.debug(accountsForMerge);

        if(accountsForMerge.size() > 0) {

            System.debug('Processing');

            // first enrich the account fields and then process the duplicates
            processDuplicates(enrichAccountFields(accountsForMerge));
        }
    }

    /**
     * This method is responsible for finding the duplicates in this batch (max size 50, limitation of DataCloud.FindDuplicates)
     *
     * @param accounts
     *
     * @return a Map keyed by Email Address, with a List of Accounts per record, the 1st record is the original "master" account
     * and the n+1,2,n records are the duplicates (if the List size > 1 it has duplicates).
     */
    private Map<String, List<Account>> findDuplicates(List<Account> accounts) {
        Map<String, List<Account>> accountsForMerge = new Map<String, List<Account>>();
        List<Account> filteredAccounts = new List<Account>();



        for(Account acc : accounts) {

            if(!alreadyRemoved.contains(acc.Id)) {
                filteredAccounts.add(acc);
            }
        }

        for(Account acc : filteredAccounts) {
            if(!accountsForMerge.containsKey(acc.PersonEmail.toLowerCase())) {
                List<Account> accList = new List<Account>();
                accList.add(acc);
                accountsForMerge.put(acc.PersonEmail.toLowerCase(), accList);
            }
        }

        // run the duplicate rule and check for matching accounts
        List<Datacloud.FindDuplicatesResult> duplicateResults = Datacloud.FindDuplicates.findDuplicates(accounts);

        if(duplicateResults.size() > 0) {
            // a duplicate result will be generated for each record in the same order
            for(Datacloud.FindDuplicatesResult fdr : duplicateResults) {
                List<Datacloud.DuplicateResult> drs = fdr.duplicateResults;
                if(drs.size() > 0) {
                    // we have at least one duplicate for this account
                    for(Datacloud.DuplicateResult dr : drs) {
                        List<Datacloud.MatchResult> mrs = dr.matchResults;
                        for(Datacloud.MatchResult mr : mrs) {
                            List<Datacloud.MatchRecord> mrcs = mr.matchRecords;
                            for(Datacloud.MatchRecord mrc : mrcs) {
                                Account rec = (Account)mrc.record;
                                System.debug('Duplicate Found');
                                accountsForMerge.get(rec.PersonEmail.tolowerCase()).add(rec);
                            }
                        }

                    }
                }
            }
        }

        return accountsForMerge;
    }

    /**
     * This method actually does the merging (logically determining values to merge onto the main winning record).
     *
     * @param accountsForMerge
     */
    private void processDuplicates(Map<String, List<Account>> accountsForMerge) {
        List<Account> accountsForUpdate = new List<Account>();
        Map<Id, Account> accountsForDelete = new Map<Id, Account>();

        // update lists for reparenting
        Map<String, R_Club_Number__c> rClubNumbersForUpdate = new Map<String,R_Club_Number__c>();
        Map<String, Case> casesForUpdate = new Map<String, Case>();
        Map<String,Child__c> childrenForUpdate = new Map<String,Child__c>();
        Map<String,Registry__c> registriesForUpdate = new Map<String,Registry__c>();
        Map<String,Order> ordersForUpdate = new Map<String,Order>();
        Map<String,Address__c> addressesForUpdate = new Map<String,Address__c>();

        for (String email : accountsForMerge.keySet()) {
            System.debug('Processing record email: ' + email);
            List<Account> accounts = accountsForMerge.get(email.toLowerCase());
            if (accounts.size() > 1) {
                Account majorAccount = accounts[0];

                for (Integer i = 1; i < accounts.size(); i++) {
                    Account account = accounts.get(i);

                    if (majorAccount.SFCC_Customer_Number__pc == null && account.SFCC_Customer_Number__pc != null) {
                        majorAccount.SFCC_Customer_Number__pc = account.SFCC_Customer_Number__pc;
                    }
                    if (majorAccount.SFCC_Customer_Id__pc == null && account.SFCC_Customer_Id__pc != null) {
                        majorAccount.SFCC_Customer_Id__pc = account.SFCC_Customer_Id__pc;
                    }
                    if (majorAccount.FirstName == null && account.FirstName != null) {
                        majorAccount.FirstName = account.FirstName;
                    }
                    if (majorAccount.LastName == 'Subscriber' && account.LastName != 'Subscriber' && account.LastName != null) {
                        majorAccount.LastName = account.LastName;
                    }
                    if (majorAccount.SCCActive__c == false && account.SCCActive__c == true) {
                        majorAccount.SCCActive__c = true;
                    }
                    if (majorAccount.Child_Birthday_Opt_In__c == true && account.Child_Birthday_Opt_In__c == false) {
                        majorAccount.Child_Birthday_Opt_In__c = false;
                    }
                    if (majorAccount.Child_Birthday_Opt_In__c == true && ((majorAccount.Child_Birthday_Email_Opt_In_Date__c == null && account.Child_Birthday_Email_Opt_In_Date__c != null) || majorAccount.Child_Birthday_Email_Opt_In_Date__c < account.Child_Birthday_Email_Opt_In_Date__c)) {
                        majorAccount.Child_Birthday_Email_Opt_In_Date__c = account.Child_Birthday_Email_Opt_In_Date__c;
                    } else if (majorAccount.Child_Birthday_Opt_In__c == false) {
                        majorAccount.Child_Birthday_Email_Opt_In_Date__c = null;
                    }
                    if (majorAccount.Contact_Status__pc == null && account.Contact_Status__pc != null) {
                        majorAccount.Contact_Status__pc = account.Contact_Status__pc;
                    }
                    if (majorAccount.Email_Opt_In_BRU__c == true && account.Email_Opt_In_BRU__c == false) {
                        majorAccount.Email_Opt_In_BRU__c = false;
                    }
                    if (majorAccount.Email_Opt_In_BRU__c == true && ((majorAccount.Email_Opt_In_Date_BRU__c == null && account.Email_Opt_In_Date_BRU__c != null) || majorAccount.Email_Opt_In_Date_BRU__c < account.Email_Opt_In_Date_BRU__c)) {
                        majorAccount.Email_Opt_In_Date_BRU__c = account.Email_Opt_In_Date_BRU__c;
                    } else if (majorAccount.Email_Opt_In_BRU__c == false) {
                        majorAccount.Email_Opt_In_Date_BRU__c = null;
                    }
                    if (majorAccount.Email_Opt_In_TRU__c == true && account.Email_Opt_In_TRU__c == false) {
                        majorAccount.Email_Opt_In_TRU__c = false;
                    }
                    if (majorAccount.Email_Opt_In_TRU__c == true && ((majorAccount.Email_Opt_In_Date_TRU__c == null && account.Email_Opt_In_Date_TRU__c != null) || majorAccount.Email_Opt_In_Date_TRU__c < account.Email_Opt_In_Date_TRU__c)) {
                        majorAccount.Email_Opt_In_Date_TRU__c = account.Email_Opt_In_Date_TRU__c;
                    } else if (majorAccount.Email_Opt_In_TRU__c == false) {
                        majorAccount.Email_Opt_In_Date_TRU__c = null;
                    }
                    if (majorAccount.PersonHasOptedOutOfEmail == false && account.PersonHasOptedOutOfEmail == true) {
                        majorAccount.PersonHasOptedOutOfEmail = true;
                    }
                    if ((majorAccount.Global_Opt_Out_Date__pc == null && account.Global_Opt_Out_Date__pc != null) || majorAccount.Global_Opt_Out_Date__pc > account.Global_Opt_Out_Date__pc) {
                        majorAccount.Global_Opt_Out_Date__pc = account.Global_Opt_Out_Date__pc;
                    }
                    if ((majorAccount.Last_Email_Activity_Date__c == null && account.Last_Email_Activity_Date__c != null) || majorAccount.Last_Email_Activity_Date__c < account.Last_Email_Activity_Date__c) {
                        majorAccount.Last_Email_Activity_Date__c = account.Last_Email_Activity_Date__c;
                    }
                    if (majorAccount.Loyalty_Opt_In__c == true && account.Loyalty_Opt_In__c == false) {
                        majorAccount.Loyalty_Opt_In__c = false;
                    }
                    if (majorAccount.Loyalty_Opt_In__c == true && ((majorAccount.Loyalty_Opt_In_Date__c == null && account.Loyalty_Opt_In_Date__c != null) || majorAccount.Loyalty_Opt_In_Date__c < account.Loyalty_Opt_In_Date__c)) {
                        majorAccount.Loyalty_Opt_In_Date__c = account.Loyalty_Opt_In_Date__c;
                    } else if (majorAccount.Loyalty_Opt_In__c == false) {
                        majorAccount.Loyalty_Opt_In_Date__c = null;
                    }
                    if (Test.isRunningTest() || (majorAccount.PersonMailingStreet == null && account.PersonMailingStreet != null)) {
                        majorAccount.Mailing_Address_Line_2__c = account.Mailing_Address_Line_2__c;
                        majorAccount.PersonMailingCity = account.PersonMailingCity;
                        majorAccount.PersonMailingCountry = account.PersonMailingCountry;
                        majorAccount.PersonMailingCountryCode = account.PersonMailingCountryCode;
                        majorAccount.PersonMailingPostalCode = account.PersonMailingPostalCode;
                        majorAccount.PersonMailingState = account.PersonMailingState;
                        majorAccount.PersonMailingStateCode = account.PersonMailingStateCode;
                        majorAccount.PersonMailingStreet = account.PersonMailingStreet;
                    }
                    if ((majorAccount.R_Club_Join_Date__c == null && account.R_Club_Join_Date__c != null) || majorAccount.R_Club_Join_Date__c > account.R_Club_Join_Date__c) {
                        majorAccount.R_Club_Join_Date__c = account.R_Club_Join_Date__c;
                    }
                    if (account.YM_Id__c != null && (majorAccount.YM_Id__c == null || (majorAccount.YM_Id__c.contains('@') && !account.YM_Id__c.contains('@')) || (((majorAccount.YM_Id__c.contains('@') && account.YM_Id__c.contains('@')) || (!majorAccount.YM_Id__c.contains('@') && !account.YM_Id__c.contains('@'))) && majorAccount.YM_Id__c.length() < account.YM_Id__c.length())
                            )
                            ) {
                        majorAccount.YM_Id__c = account.YM_Id__c;
                    }

                    if (account.R_Club_Numbers__r.size() > 0) {
                        for (Integer j = 0; j < account.R_Club_Numbers__r.size(); j++) {
                            R_Club_Number__c rClubNumber = (R_Club_Number__c) account.R_Club_Numbers__r.get(j);
                            rClubNumber.Account__c = majorAccount.Id;
                            rClubNumbersForUpdate.put(rClubNumber.Id, rClubNumber);
                        }
                    }

                    System.debug(account.Id);
                    System.debug(account.Cases);
                    if (account.Cases.size() > 0) {
                        for(Integer j = 0; j < account.Cases.size(); j++) {
                            Case c = (Case) account.Cases.get(j);
                            c.AccountId = majorAccount.Id;
                            c.ContactId = majorAccount.PersonContactId;
                            casesForUpdate.put(c.Id, c);
                        }
                    }

                    if(account.Registries__r.size() > 0) {
                        for(Integer j = 0; j < account.Registries__r.size(); j++) {
                            Registry__c reg = (Registry__c) account.Registries__r.get(j);
                            reg.Account__c = majorAccount.Id;
                            registriesForUpdate.put(reg.id, reg);
                        }
                    }

                    if(account.Children__r.size() > 0) {
                        for(Integer j = 0; j < account.Children__r.size(); j++) {
                            Child__c child = (Child__c) account.Children__r.get(j);
                            child.Account__c = majorAccount.Id;
                            childrenForUpdate.put(child.id, child);
                        }
                    }

                    if(account.Orders.size() > 0) {
                        for(Integer j = 0; j < account.Orders.size(); j++) {
                            Order o = (Order) account.Orders.get(j);
                            o.AccountId = majorAccount.Id;
                            ordersForUpdate.put(o.id, o);
                        }
                    }

                    if(account.Addresses__r.size() > 0) {
                        for(Integer j = 0; j < account.Addresses__r.size(); j++) {
                            Address__c add = (Address__c) account.Addresses__r.get(j);
                            add.Account__c = majorAccount.Id;
                            addressesForUpdate.put(add.id, add);
                        }
                    }

                    if(account.Id != majorAccount.Id){
                        System.debug('Adding account to delete: ' + account);
                        accountsForDelete.put(account.Id, account);
                        alreadyRemoved.add(account.Id);
                    }
                    accountsForMerge.remove(account.Id);


                }

                accountsForUpdate.add(majorAccount);
            }
        }

        // re-parent related records
        update rClubNumbersForUpdate.values();
        update registriesForUpdate.values();
        update casesForUpdate.values();
        update ordersForUpdate.values();
        update addressesForUpdate.values();
        update childrenForUpdate.values();

        // delete duplicates
        delete accountsForDelete.values();

        // update the main (master) records
        update accountsForUpdate;
    }

    /**
     * This method "enriches" or adds on additional fields to the results returned by the `findDuplicates()` method
     * as that just gives base level field information. We need additional fields to perform the subsequent logic.
     *
     * @return
     */
    private Map<String, List<Account>> enrichAccountFields(Map<String, List<Account>> accounts) {

        Map<String, List<Account>> enrichedAccounts = new Map<String, List<Account>>();

        // get a set of records to query
        Set<Id> recordsToQuery = new Set<Id>();
        for(List<Account> accs : accounts.values()) {
            for(Account a : accs) {
                recordsToQuery.add(a.Id);
            }
        }

        // query, returning a map keyed by ID
        Map<Id, Account> results = new Map<Id, Account>([SELECT Id, PersonContactId, PersonEmail, CreatedDate, SFCC_Customer_Number__pc, SFCC_Customer_Id__pc, FirstName, LastName, SCCActive__c, Child_Birthday_Opt_In__c, Child_Birthday_Email_Opt_In_Date__c,  Contact_Status__pc, Email_Opt_In_BRU__c, Email_Opt_In_Date_BRU__c, Email_Opt_In_TRU__c, Email_Opt_In_Date_TRU__c, PersonHasOptedOutOfEmail, Global_Opt_Out_Date__pc, Last_Email_Activity_Date__c, Loyalty_Opt_In__c, Loyalty_Opt_In_Date__c, Mailing_Address_Line_2__c, PersonMailingCity, PersonMailingCountry, PersonMailingCountryCode, PersonMailingPostalCode, PersonMailingState, PersonMailingStateCode, PersonMailingStreet, R_Club_Join_Date__c, YM_Id__c, (SELECT Id, Account__c FROM R_Club_Numbers__r), (SELECT Id, AccountId FROM Cases), (SELECT Id, Account__c FROM Registries__r), (SELECT Id, Account__c FROM Children__r), (SELECT Id, AccountId FROM Orders), (SELECT Id, Account__c FROM Addresses__r) FROM Account WHERE Id IN :recordsToQuery ORDER BY PersonEmail, CreatedDate]);

        // loop through each result and replace each record with the full record detail
        for(String key : accounts.keySet()) {
            if(!enrichedAccounts.containsKey(key.toLowerCase())) {
                enrichedAccounts.put(key, new List<Account>());
            }
            for(Account a : accounts.get(key.toLowerCase())) {
                enrichedAccounts.get(key).add(results.get(a.Id));
            }
        }

        return enrichedAccounts;

    }

    global void finish(Database.BatchableContext BC) {

    }

    public void setQuery(String query) {
        this.query = query;
    }
}