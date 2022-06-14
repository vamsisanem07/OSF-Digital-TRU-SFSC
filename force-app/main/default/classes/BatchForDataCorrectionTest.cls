@isTest
private with sharing class BatchForDataCorrectionTest {

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
        ac.R_Club_Number__c = '56565';
        update ac;
        System.assertEquals(2, allRClubs.size());
        System.assertEquals(true, allRClubs.get(1).Primary__c);
        System.assertEquals(false, allRClubs.get(0).Primary__c);
        
        BatchForAccountQueries3 bc = new BatchForAccountQueries3();
        Database.executeBatch(bc);
        
        BatchForAccountQueries1 bc1 = new BatchForAccountQueries1();
        Database.executeBatch(bc1);
        
        BatchForAccountQueries4 bc2 = new BatchForAccountQueries4();
        Database.executeBatch(bc2);
        
        String sch = '0 0 0 3 9 ? 2022';
        
        ScheduleBatchForAccountQueries1 sbc1 = new ScheduleBatchForAccountQueries1();
        System.schedule('Batch Schedule 1', sch , sbc1);  
        
        ScheduleBatchForAccountQueries3 sbc3 = new ScheduleBatchForAccountQueries3();
        System.schedule('Batch Schedule 3', sch , sbc3); 
    }
}