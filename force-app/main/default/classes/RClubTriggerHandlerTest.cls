/**
 * Created by mike on 1/22/20.
 */

@isTest
private with sharing class RClubTriggerHandlerTest {

    @testSetup
    static void setup() {

        List<Account> testAccounts =  TRUTestDataFactory.createAccounts(1, 'EN');
        insert testAccounts;

    }


    /**
     * This method tests that 2 R-Club Numbers, inserted without Opt-in or Join Dates should result in the
     * latest inserted (highest ID) record becoming the primary value. The other Number should not be marked as
     * Primary.
     */
    @isTest
    private static void testInsertOfNewRClubNumbers_NoDates() {

        Account ac = [SELECT Id FROM Account LIMIT 1];

        R_Club_Number__c rc1 = new R_Club_Number__c(R_Club_Number__c = '11111', Account__c = ac.Id);
        R_Club_Number__c rc2 = new R_Club_Number__c(R_Club_Number__c = '22222', Account__c = ac.Id);

        List<R_Club_Number__c> rClubForInsert = new List<R_Club_Number__c>{rc1, rc2};

        Test.startTest();
        insert rClubForInsert;
        Test.stopTest();

        List<R_Club_Number__c> allRClubs = [SELECT Id, Primary__c FROM R_Club_Number__c];

        System.assertEquals(2, allRClubs.size());
        System.assertEquals(true, allRClubs.get(1).Primary__c);
        System.assertEquals(false, allRClubs.get(0).Primary__c);
    }

    /**
     * This method Tests a comparison of 2 records that have Loyalty Opt in and Join Dates set.
     * The record with the more recent date should win as primary.
     */
    @isTest
    private static void testInsertOfNewRClubNumbers_AllDates() {

        Account ac = [SELECT Id FROM Account LIMIT 1];

        R_Club_Number__c rc1 = new R_Club_Number__c(R_Club_Number__c = '11111', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2020'), R_Club_Join_Date__c = Date.parse('01/01/2020'));
        R_Club_Number__c rc2 = new R_Club_Number__c(R_Club_Number__c = '22222', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2019'), R_Club_Join_Date__c = Date.parse('01/01/2019'));
        R_Club_Number__c rc3 = new R_Club_Number__c(R_Club_Number__c = '33333', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2018'), R_Club_Join_Date__c = Date.parse('01/01/2018'));


        List<R_Club_Number__c> rClubForInsert = new List<R_Club_Number__c>{rc1, rc2, rc3};

        Test.startTest();
        insert rClubForInsert;
        Test.stopTest();

        List<R_Club_Number__c> allRClubs = [SELECT Id, Primary__c FROM R_Club_Number__c];

        System.assertEquals(3, allRClubs.size());
        System.assertEquals(true, allRClubs.get(0).Primary__c);
        System.assertEquals(false, allRClubs.get(1).Primary__c);
        System.assertEquals(false, allRClubs.get(2).Primary__c);
    }

    @isTest
    private static void testUpdateOfNewRClubNumbers_AllDates() {

        Account ac = [SELECT Id FROM Account LIMIT 1];

        R_Club_Number__c rc1 = new R_Club_Number__c(R_Club_Number__c = '11111', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2020'), R_Club_Join_Date__c = Date.parse('01/01/2020'));
        R_Club_Number__c rc2 = new R_Club_Number__c(R_Club_Number__c = '22222', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2019'), R_Club_Join_Date__c = Date.parse('01/01/2019'));
        R_Club_Number__c rc3 = new R_Club_Number__c(R_Club_Number__c = '33333', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2018'), R_Club_Join_Date__c = Date.parse('01/01/2018'));


        List<R_Club_Number__c> rClubForInsert = new List<R_Club_Number__c>{rc1, rc2, rc3};

        insert rClubForInsert;

        Test.startTest();
        rc2.Loyalty_Opt_In_Date__c = Date.parse('01/01/2021');
        RClubTriggerHandler.alreadyProcessedAccounts.clear(); // clear so we can recurse and re-execute the logic
        update rc2;
        Test.stopTest();

        List<R_Club_Number__c> allRClubs = [SELECT Id, Primary__c, R_Club_Number__c FROM R_Club_Number__c];

        System.assertEquals(3, allRClubs.size());
        System.assertEquals(false, allRClubs.get(0).Primary__c);
        System.assertEquals(true, allRClubs.get(1).Primary__c);
        System.assertEquals(false, allRClubs.get(2).Primary__c);
    }

    @isTest
    private static void testDeleteOfNewRClubNumbers_AllDates() {
        Account ac = [SELECT Id FROM Account LIMIT 1];

        R_Club_Number__c rc1 = new R_Club_Number__c(R_Club_Number__c = '11111', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2020'), R_Club_Join_Date__c = Date.parse('01/01/2020'));
        R_Club_Number__c rc2 = new R_Club_Number__c(R_Club_Number__c = '22222', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2019'), R_Club_Join_Date__c = Date.parse('01/01/2019'));
        R_Club_Number__c rc3 = new R_Club_Number__c(R_Club_Number__c = '33333', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2018'), R_Club_Join_Date__c = Date.parse('01/01/2018'));


        List<R_Club_Number__c> rClubForInsert = new List<R_Club_Number__c>{rc1, rc2, rc3};

        insert rClubForInsert;

        List<R_Club_Number__c> allRClubs = [SELECT Id, Primary__c, R_Club_Number__c FROM R_Club_Number__c];
        System.assertEquals(3, allRClubs.size());
        System.assertEquals(true, allRClubs.get(0).Primary__c);
        System.assertEquals(false, allRClubs.get(1).Primary__c);
        System.assertEquals(false, allRClubs.get(2).Primary__c);

        RClubTriggerHandler.alreadyProcessedAccounts.clear(); // clear so we can recurse and re-execute the logic
        delete rc1;

        allRClubs = [SELECT Id, Primary__c, R_Club_Number__c FROM R_Club_Number__c];
        System.assertEquals(2, allRClubs.size());
        System.assertEquals(true, allRClubs.get(0).Primary__c);
        System.assertEquals(false, allRClubs.get(1).Primary__c);
    }

    @isTest
    private static void testDeleteOfNewRClubNumbers_NODates() {
        Account ac = [SELECT Id FROM Account LIMIT 1];

        R_Club_Number__c rc1 = new R_Club_Number__c(R_Club_Number__c = '11111', Account__c = ac.Id);
        R_Club_Number__c rc2 = new R_Club_Number__c(R_Club_Number__c = '22222', Account__c = ac.Id);
        R_Club_Number__c rc3 = new R_Club_Number__c(R_Club_Number__c = '33333', Account__c = ac.Id);


        List<R_Club_Number__c> rClubForInsert = new List<R_Club_Number__c>{rc1, rc2, rc3};

        insert rClubForInsert;

        List<R_Club_Number__c> allRClubs = [SELECT Id, Primary__c, R_Club_Number__c FROM R_Club_Number__c];
        System.assertEquals(3, allRClubs.size());
        System.assertEquals(false, allRClubs.get(0).Primary__c);
        System.assertEquals(false, allRClubs.get(1).Primary__c);
        System.assertEquals(true, allRClubs.get(2).Primary__c);

    }

    @isTest
    private static void testRollups() {
        Account ac = [SELECT Id FROM Account LIMIT 1];

        R_Club_Number__c rc1 = new R_Club_Number__c(R_Club_Number__c = '11111', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2020'), R_Club_Join_Date__c = Date.parse('01/01/2020'));
        R_Club_Number__c rc2 = new R_Club_Number__c(R_Club_Number__c = '22222', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2019'), R_Club_Join_Date__c = Date.parse('01/01/2019'));
        R_Club_Number__c rc3 = new R_Club_Number__c(R_Club_Number__c = '33333', Account__c = ac.Id, Loyalty_Opt_In_Date__c = Date.parse('01/01/2018'), R_Club_Join_Date__c = Date.parse('01/01/2018'));


        List<R_Club_Number__c> rClubForInsert = new List<R_Club_Number__c>{rc1, rc2, rc3};

        insert rClubForInsert;

        ac = [SELECT Id, Loyalty_Opt_In__c, Loyalty_Opt_In_Date__c, R_Club_Number__c, R_Club_Join_Date__c, Primary_R_Club_Number__c, SFCC_update__c FROM Account];

        System.assertEquals(false, ac.Loyalty_Opt_In__c);
        System.assertEquals(Date.parse('01/01/2020'), ac.Loyalty_Opt_In_Date__c);
        System.assertEquals(Date.parse('01/01/2020'), ac.R_Club_Join_Date__c);
        System.assertEquals('11111', ac.R_Club_Number__c);
        // make sure the SFCC_update__c flag is reset back to false after update
        //System.assertEquals(false, ac.SFCC_update__c);
    }

}