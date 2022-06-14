@isTest
public class ChildDeletionBatchTest {
    private static final Integer noOfRecord = 20;
    
	@testSetup
    private static void createData(){
        //Create Account records
        List<Account> accountList = createAccounts(noOfRecord);
        INSERT accountList;
        
        //Create first child record
        Child__c childFirstRecord = new Child__c();
        childFirstRecord.Name__c = 'test';
        childFirstRecord.Birthday__c = System.today().addYears(-10);
        childFirstRecord.Account__c = accountList[0].id;
        childFirstRecord.Duplicate_Record__c = true;
        INSERT childFirstRecord;
        
        //Create second child record
        Child__c childSecondRecord = new Child__c();
        childSecondRecord.Name__c = 'test';
        childSecondRecord.Birthday__c = System.today().addYears(-10);
        childSecondRecord.Account__c = accountList[0].id;
        childSecondRecord.Duplicate_Record__c = false;
        INSERT childSecondRecord;        
    }
    
    @isTest
    private static void accountTest(){
        Test.startTest(); 
        
        ChildDeletionBatch obj = new ChildDeletionBatch();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
        system.assert([select id from Child__c].size() == 1);
    }
    
    private static List<Account> createAccounts(Integer noOfRecords){
        List<Account> accountList = new List<Account>();
        
        for(Integer count = 1; count <= noOfRecords; count++){
            Account account = new Account();
            account.Salutation ='Mr.';
            account.FirstName ='Test FirstName'+count;
            account.MiddleName ='Test MidleName'+count;
            account.LastName ='Test LastName'+count;
            account.IsUpdate__c = false;
           
            accountList.add(account);            
        }
        return accountList;
    }
}