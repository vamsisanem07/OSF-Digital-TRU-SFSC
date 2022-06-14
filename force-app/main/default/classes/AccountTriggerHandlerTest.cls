@isTest
private class AccountTriggerHandlerTest {

    @testSetup
    static void setup() {
        insert new ActivateDeactiveAccountOptinTrigger__c(ActivateTheTrigger__c=true);

        TRUTestDataFactory.createAndInsertAccounts(1, 'EN');
    }

    @IsTest
    private static void populateOptInDatesForAccountListTest() {
        Account a = [SELECT PersonEmail, Email_Key__c FROM Account];
        System.assertEquals(a.Email_Key__c, a.PersonEmail);
        
        List<Account> accList = new List<Account>();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        for (Integer i = 0; i < 20; ++i){
            accList.add(new Account(
                LastName = 'Test Account 11' + (i + 1),
                PersonEmail = 'testemail11' + (i + 1) + '@test.mail',
                Email_Opt_In_BRU__c = true,
                Child_Birthday_Opt_In__c = true,
                Email_Opt_In_TRU__c = true,
                Loyalty_Opt_In__c = true,
                RecordTypeId = rtId
            ));
        }        
        insert accList;
        
        List<Account> toUpdateAccList = [SELECT Id,Email_Opt_In_BRU__c,Child_Birthday_Opt_In__c,Email_Opt_In_TRU__c,Loyalty_Opt_In__c
                                         FROM Account];
        
        List<Account> accListUpdate = new List<Account>();
        for (account rec : toUpdateAccList){            
                rec.Email_Opt_In_BRU__c = false;
                rec.Child_Birthday_Opt_In__c = false;
                rec.Email_Opt_In_TRU__c = false;
                rec.Loyalty_Opt_In__c = false;
                rec.Email_Opt_In_Date_TRU__c = system.today();

                rec.RecordTypeId = rtId;
                accListUpdate.add(rec);
        }
        
        update accListUpdate;
        SchedulebatchAccountUpdateForOptIn testSchedule = new SchedulebatchAccountUpdateForOptIn();
        testSchedule.execute(null);
    }


}