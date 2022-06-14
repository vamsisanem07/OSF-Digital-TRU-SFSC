@isTest
public class OrderExtractBatchTest { 
    
    @testSetup
    private static void createData(){ 
        Document document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'text/csv';
        document.DeveloperName = 'Order_Extract2';
        document.IsPublic = true;
        document.Name = 'Order Extract';
        document.FolderId = [select id from folder where name = 'Shared Documents'].id;
        insert document;
        
        Account account = new Account();
        account.Salutation ='Mr.';
        account.FirstName ='Test FirstName';
        account.MiddleName ='Test MidleName';
        account.LastName ='Test LastName';
        account.IsUpdate__c = false;
        
        INSERT account;
        List<Order> orderList = new List<Order>();
        
        for(Integer count = 0; count < 1001; count++){
            Order order = new Order();
            order.AccountId = account.Id;
            order.EffectiveDate = Date.today();
            order.Status = 'New';
            order.Order_SCCSync_Status__c = 'Created';
            order.SFCC_Order_Number__c = '08903428802193029' + count;
            order.SFCC_Order_Total__c = 1234;
            orderList.add(order);
        } 
        
        INSERT orderList;    
    }  
    
    @isTest
    private static void accountTest(){
        Test.startTest(); 
        
        OrderExtractBatch obj = new OrderExtractBatch();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
    
}