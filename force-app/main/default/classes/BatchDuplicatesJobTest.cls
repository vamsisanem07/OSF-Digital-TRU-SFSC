@isTest
public class BatchDuplicatesJobTest {
    public static testMethod void testBatch() {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a1 = new Account(FirstName = 'Test', LastName = 'User', PersonEmail = 'TestUser@test.com', RecordTypeId = personAccountRecordType.Id);
        Account a2 = new Account(FirstName = 'Test', LastName = 'User2', PersonEmail = 'TestUser@test.com', RecordTypeId = personAccountRecordType.Id);
        Account a3 = new Account(FirstName = 'Test', LastName = 'User3', PersonEmail = 'TestUser3@test.com', RecordTypeId = personAccountRecordType.Id);
        Account a4 = new Account(FirstName = 'Test', LastName = 'User4', PersonEmail = '', RecordTypeId = personAccountRecordType.Id);
        Account a5 = new Account(FirstName = 'Test', LastName = 'User5', PersonEmail = '', RecordTypeId = personAccountRecordType.Id);
        
        List<Account> accounts = new List<Account>{a1,a2,a3,a4,a5};
        insert accounts;
        
        Test.startTest();
        BatchDuplicatesJob bdj = new BatchDuplicatesJob('SELECT Id, PersonEmail FROM Account');
        Database.executeBatch(bdj);
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, PersonEmail, Duplicate_BR__c FROM Account];
        List<Account> dups = new List<Account>();
        for(Account a : updatedAccounts) {
            if(a.Duplicate_BR__c) {
                dups.add(a);
            }
        }
        System.debug(updatedAccounts);
        System.assertEquals(2, dups.size());
    }
}