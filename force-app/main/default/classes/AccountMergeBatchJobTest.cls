@isTest
private class AccountMergeBatchJobTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Case> cases = new List<Case>();
        List<Child__c> children = new List<Child__c>();
        List<Registry__c> registries = new List<Registry__c>();
        List<R_Club_Number__c> rClubNumbers = new List<R_Club_Number__c>();

        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        for (Integer i=0;i<50;i++) {
            accounts.add(new Account(
                    LastName='Account '+i,
                    PersonEmail = 'testemail@test.mail',
                    RecordTypeId = rtId
            ));
        }

        insert accounts;

        for (Integer i=0;i<50;i++) {
            cases.add(new Case(Subject = 'test', AccountId = accounts.get(i).Id, ContactId = accounts.get(i).PersonContactId));
        }

        insert cases;

        for (Integer i=0;i<50;i++) {
            children.add(new Child__c(Account__c = accounts.get(i).Id, Name__c = 'test-child-'+i, Birthday__c = Date.today()));
        }

        insert children;
    }

    @IsTest
    static void test() {
        Test.startTest();
        AccountMergeBatchJob2 uca = new AccountMergeBatchJob2();
        Id batchId = Database.executeBatch(uca, 50);
        Test.stopTest();

        System.assertEquals(1, [select count() from Account where PersonEmail = 'testemail@test.mail']);
        System.assertEquals(50, [SELECT Id, (Select Id FROM Cases) FROM Account WHERE PersonEmail = 'testemail@test.mail'].Cases.size());
        System.assertEquals(50, [SELECT Id, (Select Id FROM Children__r) FROM Account WHERE PersonEmail = 'testemail@test.mail'].Children__r.size());
    }
}