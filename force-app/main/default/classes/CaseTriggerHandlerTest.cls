@isTest
public class CaseTriggerHandlerTest {
    static testmethod void caseCommentShouldBeGenerated(){
        Test.startTest();
        
        Store__c store = new Store__c();
        store.Manager_Email__c = 'test@test.com';
        store.Director_Email__c = 'test@test.com';
        store.District_Manager_Email__c = 'test@test.com';
        store.Keytree_ID__c = '123456';
        
        insert store;
        
        Case inStoreCaseWithStore = new Case();
        inStoreCaseWithStore.Reason = 'In Store';
        inStoreCaseWithStore.Store_ID__c = '123456';
        insert inStoreCaseWithStore;
        
        Case inStoreSaved = [SELECT Id, recordType.Name, Store__r.Id FROM Case WHERE ID = : inStoreCaseWithStore.Id];
        System.assertEquals(inStoreSaved.Store__r.Id, store.Id);
        System.assertEquals(inStoreSaved.recordType.Name, 'In Store Case');
        
        Case inStoreCaseWithOutStore = new Case();
        inStoreCaseWithOutStore.Reason = 'In Store';
        insert inStoreCaseWithOutStore;
                
        Case inStoreWOStoreSaved = [SELECT Id, recordType.Name, KIT_Status__c FROM Case WHERE ID = : inStoreCaseWithOutStore.Id];
        System.assertEquals(inStoreWOStoreSaved.KIT_Status__c, 'Waiting on Support');
        
        Case priceMatchCase = new Case();
        priceMatchCase.Reason = 'Price Adjustment';
        insert priceMatchCase;
        
        Case priceMatchSaved = [SELECT Id, recordType.Name FROM Case WHERE ID = : priceMatchCase.Id];
        System.assertEquals(priceMatchSaved.recordType.Name, 'Price Adjustment');
        
        
        Case contactUsCase = new Case();
        contactUsCase.Reason = 'Promotion General';
        insert contactUsCase;
        
        Case contactUsSaved = [SELECT Id, recordType.Name FROM Case WHERE ID = : contactUsCase.Id];
        System.assertEquals(contactUsSaved.recordType.Name, 'Contact Us');
        
        Test.stopTest();
        
        Case contactUsFRCase = new Case();
        contactUsFRCase.Reason = 'Ramassage de commande';
        insert contactUsFRCase;
        
        Case instoreFRCase = new Case();
        instoreFRCase.Reason = 'En Magasin';
        insert instoreFRCase;
        
        Case pricematchFRCase = new Case();
        pricematchFRCase.Reason = 'Ajustement de prix';
        insert pricematchFRCase;
        
        Account account = new Account(LastName = 'Test');
        insert account;
        
        contactUsSaved.AccountId = account.Id;
        contactUsSaved.Status = 'Closed';
        update contactUsSaved;
        
        contactUsSaved.Status = 'Pending';
        update contactUsSaved;
        
        contactUsSaved.Type = 'Payment';
        contactUsSaved.Disposition_1__c = 'Follow Up';
        update contactUsSaved;
        
        Case emailCase= new Case();
        emailCase.Origin= 'email';
        emailCase.SuppliedEmail= 'test@a.com';
        emailCase.SuppliedName ='Case Email';
        emailCase.SuppliedPhone = '76763536383';
        insert emailCase;
   }

}