@isTest
public class EmailMessageHandlerTest {
    @testSetup
    static void setup() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        //Create test Account
        Account newAccount = new Account();
        newAccount.LastName = 'Test Account';
        newAccount.RecordTypeId = recordTypeId;
        insert newAccount;
        
        //Create test Case
        Case newCase = new Case();
        newCase.AccountId = newAccount.Id;
        insert newCase;
        
        //Create new EmailMessage
        EmailMessage newEmailMessage = new EmailMessage();
        newEmailMessage.ParentId = newCase.Id;
        newEmailMessage.Incoming = true;
        newEmailMessage.TextBody = 'Test message Body';
        insert newEmailMessage;
    }

    @IsTest
    static void caseCommentShouldBeGenerated(){
        //Get CaseComment, which should created during trigger execution
        CaseComment comment = [SELECT Id, ParentId, CommentBody FROM CaseComment LIMIT 1];
        
        //Get EmailMessage for verification CaseComment fields
        EmailMessage msg = [SELECT Id, ParentId, TextBody FROM EmailMessage LIMIT 1];
        
        System.assertNotEquals(null, comment);       
        System.assertEquals(msg.TextBody, comment.CommentBody);
        System.assertEquals(msg.ParentId, comment.ParentId);
    }

    
    static testmethod void handleThrowError(){
        EmailMessageHandler.sendExceptionCauseEmail('Email Sent during testing');
    }
}