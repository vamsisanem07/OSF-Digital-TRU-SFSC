/*
    @Purpose        : Test method for CloseOrphanChatCasesBatch
    @Created Date   : 29/10/2020
*/
@isTest
public class CloseOrphanChatCasesBatchTest {
    private static testmethod void testBatchExecution(){
        List<Case> caseRecordsList = new List<Case>();
        
        for(Integer count = 0; count < 200; count++){
            Case caseRecord = new Case(Status = 'New',
                                       Origin = 'Chat');
            caseRecordsList.add(caseRecord);
        }
        
        insert caseRecordsList;
        
        Test.startTest();
        Database.executebatch(new CloseOrphanChatCasesBatch());
        Test.stopTest();
        
        caseRecordsList = [SELECT Status, Type, Subject, Disposition_1__c, Description FROM Case];
        
        for(Case caseRecord : caseRecordsList){
            System.assertEquals('Closed', caseRecord.Status);
            System.assertEquals('Unidentified', caseRecord.Type);
            System.assertEquals('Unidentified', caseRecord.Subject);
            System.assertEquals('Chat terminated', caseRecord.Disposition_1__c);
            System.assertEquals('Chat terminated', caseRecord.Description);
        }
    }
}