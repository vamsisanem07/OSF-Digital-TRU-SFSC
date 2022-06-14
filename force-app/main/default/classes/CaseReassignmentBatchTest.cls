/*
    @Purpose        : Test process for CaseReassignmentBatch
    @Created Date   : 20/09/2020
*/
@isTest
private class CaseReassignmentBatchTest {
    private static testmethod void testBatchExecution(){
        UserRole role = [SELECT Id FROM UserRole WHERE DeveloperName = 'Tier_1' LIMIT 1];
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userRecord = new User(Alias = 'trusu', 
                                   Email = 'trustandarduser@testorg.com', 
                                   EmailEncodingKey = 'UTF-8', 
                                   LastName = 'Testing TRU', 
                                   LanguageLocaleKey = 'en_US', 
                                   LocaleSidKey = 'en_US', 
                                   ProfileId = profile.Id, 
                                   TimeZoneSidKey = 'America/Los_Angeles', 
                                   UserName = 'trustandarduser@testorg.com',
                                   UserRoleId = role.Id);
        
        System.runAs(userRecord){
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            Account accountRecord = new Account(LastName = 'Test Account',
                                                Language_Preference__c = 'EN',
                                                RecordTypeId = personAccountRecordTypeId);
            insert accountRecord;
            
            Case caseRecord = new Case(AccountId = accountRecord.Id);
            insert caseRecord;
            
            Account accountRecordFR = new Account(LastName = 'Test Account',
                                                Language_Preference__c = 'FR',
                                                RecordTypeId = personAccountRecordTypeId);
            insert accountRecordFR;
            
            Case caseRecordFR = new Case(AccountId = accountRecordFR.Id);
            insert caseRecordFR;
            
            Database.executebatch(new CaseReassignmentBatch());
        }
    }
}