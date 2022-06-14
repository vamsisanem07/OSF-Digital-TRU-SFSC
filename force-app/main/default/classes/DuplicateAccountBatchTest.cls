/**
* @Purpose     : Test class of DuplicateAccountBatch
* @CreateDate  : 08-01-2021
* 
**/
@isTest
public class DuplicateAccountBatchTest {
    private static final Integer noOfRecord = 20;
    //Create record
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
        test.startTest();
        
        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(noOfRecord, accountList.size());
        List<Child__c> childList = [SELECT Id FROM Child__c];
        System.assertEquals(2,childList.size());
        
        //Excute DuplicateAccountBatch class
        DuplicateAccountBatch obj = new DuplicateAccountBatch();
        DataBase.executeBatch(obj); 
        
        test.stopTest();
    }
    
    /*
    * @Purpose: create account records
    * @Parameters: number of Records
    * @Return: account List
    * */
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