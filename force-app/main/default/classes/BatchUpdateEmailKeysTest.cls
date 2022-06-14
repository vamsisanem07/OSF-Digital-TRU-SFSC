@isTest
public class BatchUpdateEmailKeysTest {
    public static testMethod void test() {
        
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];

        Account a1 = new Account(FirstName = 'Test', LastName = 'User', PersonEmail = 'TestUser@test.com', RecordTypeId = personAccountRecordType.Id);        
        insert new List<Account>{a1};
            
        Test.startTest();
        
        BatchUpdateEmailKeys bdj = new BatchUpdateEmailKeys('SELECT Id, PersonEmail FROM Account');
        Database.executeBatch(bdj);
        
        Test.stopTest();
            
        
    }
}