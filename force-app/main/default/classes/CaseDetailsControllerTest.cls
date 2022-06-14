/*
	@Purpose     : Test class for 'CaseDetailsController'
	@CreatedDate : 19th August 2020
*/

@isTest
public class CaseDetailsControllerTest {
    
    @testSetup
    private static void createData(){
        List<Account> accounts = createAccounts(3);
        INSERT accounts;
        System.assertEquals(3, accounts.size());
        
        List<Contact> contacts = createContacts(accounts[0].Id, 200);
        INSERT contacts;
        System.assertEquals(200, contacts.size());
        
        List<Case> cases = createCases(accounts[0].Id, contacts[0].Id, 200);
        INSERT cases;
        System.assertEquals(200, cases.size()); 
        
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
        
        LiveChatTranscript chatTranscript = new LiveChatTranscript();
        chatTranscript.CaseId = cases[0].Id;
        chatTranscript.LiveChatVisitorId = chatVisitor.Id;
        insert chatTranscript;
        
        SocialPost post = new SocialPost();
        post.name = 'test';
        Post.Posted = system.now();
        post.ParentId = cases[0].Id;
		Insert post;     
    }
    
    /*
    	@Purpose	: Positive test method for caseDetails
	*/
    @isTest
    private static void testCaseDetails(){
        List<Case> cases = [SELECT Id, AccountId, ContactId FROM Case];
        Test.startTest();        
        
        ContentNote note = new ContentNote(Title = 'Test',
                                           Content = Blob.valueOf('content'));
        insert note;
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = cases[0].Id;
        contentDocumentLink.ContentDocumentId = note.Id;
        contentDocumentLink.ShareType = 'I'; 
        insert contentDocumentLink;
        
        FeedItem feedItem = new FeedItem();
        feedItem.parentid = cases[0].Id;
        feedItem.Body = 'test chatter';
        insert feedItem;
        
        CaseDetailsController caseDetails = new CaseDetailsController();
        caseDetails.caseId = cases[0].Id;
        caseDetails.getActionFormat(new CaseHistory(CaseId = cases[0].Id, Field = 'Status'));
        caseDetails.getActionFormat(new CaseHistory(CaseId = cases[0].Id, Field = 'ownerAssignment'));
        
        CaseDetailsController.CaseHistoryWrapper wrapper = new CaseDetailsController.CaseHistoryWrapper();
        wrapper.action = 'Test';
        wrapper.historyDate = 'Test';
        wrapper.userName = 'Test';
        Test.stopTest();
    }
    
    /*
    	@Purpose : Negative test method for caseDetails
	*/
    @isTest
    private static void testNegativeCaseDetails(){
        List<Case> cases = [SELECT Id, AccountId, ContactId FROM Case];
        CaseDetailsController caseDetails = new CaseDetailsController();
        
        Test.startTest();        
        boolean caught = false;
        try{
            caseDetails.caseId = '';
        }
        catch(Exception e){
            //System.assertEquals('Exception in fetching case details', e.getMessage(), 'Caught the right exception');
            caught = true;
        }
        Test.stopTest();
        //System.assert(!caught, ' caught the expected exception');
    }
    
    // Create account records
    private static List<Account> createAccounts(Integer noOfRecords){
        List<Account> accounts = new List<Account>();
        Account account;
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        
        for(Integer count = 1; count <= noOfRecords; count++){
            account = new Account();
            account.Name = 'Test';
            account.RecordTypeId = businessAccountRecordTypeId;
            accounts.add(account);
        }
        return accounts;
    }
    
    // Create contact records
    private static List<Contact> createContacts(String accountId, Integer noOfRecords){
        List<Contact> contacts = new List<Contact>();
        Contact contact;
        
        for(Integer count = 1; count <= noOfRecords; count++){
            contact = new Contact();
            contact.AccountId = accountId;
            contact.LastName = 'Test Contact';
            contacts.add(contact);
        }
        return contacts;
    }
    
    // Create case records
    private static List<Case> createCases(String accountId, String contactId, Integer noOfRecords){
        List<Case> cases = new List<Case>();
        Case caseObj;
        
        for(Integer count = 1; count<= noOfRecords; count++){
            caseObj = new Case();
            caseObj.AccountId = accountId;
            caseObj.ContactId = contactId;
            caseObj.Legal_Threat__c = true;
            caseObj.Customer_Alerting_Media__c = true;
            cases.add(caseObj);
        }
        return cases;
    }
}