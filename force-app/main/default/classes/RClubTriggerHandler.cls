/**
 * Created by mike on 1/22/20.
 */

public without sharing class RClubTriggerHandler {

    public static Set<Id> alreadyProcessedAccounts = new Set<Id>();

    public static void selectRClubPrimary(Map<Id, R_Club_Number__c> newOrUpdatedOrDeletedRClubNumbers) {
        // list of new or updated r-club numbers comes in as map
        // for each one, get the parent account (number.Account__r) - add new parent id's to SET to to not run duplicates below
        // for each parent, query all of the associate R-Club Numbers - put them in map keyed by Account ID
        Set<Id> accountsToRecalculate = new Set<Id>();
        // keep track of a set of newly minted "primary" R-Club Numbers so we can roll up their values to their parent account
        Map<Id, R_Club_Number__c> rClubNumbersForRollup = new Map<Id, R_Club_Number__c>();

        for(R_Club_Number__c rc : newOrUpdatedOrDeletedRClubNumbers.values()) {
            if(!alreadyProcessedAccounts.contains(rc.Account__c)) {
                accountsToRecalculate.add(rc.Account__c);
                alreadyProcessedAccounts.add(rc.Account__c);
            }
        }

        // order by Loyalty_Join_Date__c, Loyalty_Opt_In_Date__c, DESC
        // make sure it has a R_Club_Number__c
        List<Account> accountsWithRClubNumbers = [SELECT Id, PersonEmail, (SELECT R_Club_Number__c, Primary__c, Loyalty_Opt_In__c, Loyalty_Opt_In_Date__c, R_Club_Join_Date__c, Account__c FROM R_Club_Numbers__r ORDER BY Id ASC) FROM Account WHERE Id IN :accountsToRecalculate];
        Map<Id, R_Club_Number__c> rClubNumbersToUpdate = new Map<Id, R_Club_Number__c>();

        for(Account ac : accountsWithRClubNumbers) {
            R_Club_Number__c primary;
            Date latestDate = null;
            for(R_Club_Number__c rc : ac.R_Club_Numbers__r) {
                System.debug(rc);

                // this logic evaluates the highest date against the currently stored highest date (latestDate)
                if(latestDate == null || rc.R_Club_Join_Date__c >= latestDate ) {
                    latestDate = rc.R_Club_Join_Date__c;
                    primary = rc;
                }
                if(latestDate == null || rc.Loyalty_Opt_In_Date__c >= latestDate) {
                    latestDate = rc.Loyalty_Opt_In_Date__c;
                    primary = rc;
                }
            }

            for(R_Club_Number__c rc : ac.R_Club_Numbers__r) {
                rc.Primary__c = false;
                rClubNumbersToUpdate.put(rc.Id, rc);
            }
            if(primary != null) {
                primary.Primary__c = true;
                rClubNumbersToUpdate.put(primary.Id, primary);
                rClubNumbersForRollup.put(primary.Account__c, primary);
            }
        }

        // update all the r-club numbers
        update rClubNumbersToUpdate.values();

        // execute rollups
        rollUpPrimaryToAccount(rClubNumbersForRollup);

    }

    /**
     * This method handles the rollup of specified (mapped) values from the primary R-Club Number to the parent
     * account. This method should only execute on "primary" R-Club Number records for efficiency, however they will
     * be checked for primary = true just in case.
     *
     * @param newRClubNumbers - Map keyed by Account ID to "Primary" R-Club Number Record
     */
    public static void rollUpPrimaryToAccount(Map<Id, R_Club_Number__c> rClubRollupMap) {

        List<Account> accountsForUpdate = new List<Account>();

        // check and make sure primary = true
        for(Id accountId : rClubRollupMap.keySet()) {
            R_Club_Number__c rClubNumber = rClubRollupMap.get(accountId);
            if(rClubNumber.Primary__c) {
                Account ac = new Account(Id = accountId);

                // set values here
                ac.R_Club_Number__c = rClubNumber.R_Club_Number__c;
                ac.Loyalty_Opt_in_Date__c = rClubNumber.Loyalty_Opt_In_Date__c;
                ac.R_Club_Join_Date__c = rClubNumber.R_Club_Join_Date__c;
                ac.Primary_R_Club_Number__c = rClubNumber.Id;
                ac.Loyalty_Opt_In__c = rClubNumber.Loyalty_Opt_In__c;
                ac.SFCC_update__c = true; // only enable this if doing large batch dataloads and don't want to write to sfcc

                // add to list for update
                accountsForUpdate.add(ac);
            }
        }

        update accountsForUpdate;

    }
}