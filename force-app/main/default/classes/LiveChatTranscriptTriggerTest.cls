/*
	@Purpose		: Test methods for Live chat transcript trigger
	Created Date	: 05/10/2020
*/
@isTest
private class LiveChatTranscriptTriggerTest { 
    
    @isTest
    static void testTriggerFunctionality() {
        Account account = new Account(LastName = 'Test');
        insert account;
        
        LiveChatVisitor visitor = new LiveChatVisitor();

        insert visitor;
        
        Case caseRecord = new Case();
        insert caseRecord;
        
        LiveChatTranscript chatTranscript = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                                   Status = 'Missed',
                                                                   CaseId = caseRecord.Id);
        insert chatTranscript;
        
        Test.startTest();
        
        chatTranscript.AccountId = account.Id;
        update chatTranscript;
        Test.stopTest(); 
        
        chatTranscript = [SELECT ContactId FROM LiveChatTranscript WHERE Id =: chatTranscript.Id ];

        System.assert(chatTranscript.ContactId != null); 
    }
}