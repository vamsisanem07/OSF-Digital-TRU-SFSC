@isTest
public class AccountDeduplicationBatchATest {
	@isTest
    private static void testPositiveCase() {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account masterAccount = new Account();
        masterAccount.LastName = 'Test Account 1';
        masterAccount.PersonEmail = 'test@abc.com';
        masterAccount.RecordTypeId = personAccountRTId;
        insert masterAccount;
        
        Account account = new Account();
        account.LastName = 'Test Account 2';
        account.Email_Key__c = 'test@abc.com';
        account.RecordTypeId = personAccountRTId;
        insert account;
        
        Account account2 = new Account();
        account2.LastName = 'Test Account 2';
        account2.Email_Key__c = 'test2@abc.com';
        account2.RecordTypeId = personAccountRTId;
        insert account2;
        
        Test.startTest();
        Database.executeBatch(new AccountDeduplicationBatchA());
        Test.stopTest();
    }
}