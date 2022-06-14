/*
    @Purpose        : Test class of EmailDefaultsUtils
    @Created Date   : 19/09/2020
*/
@isTest
public class EmailDefaultsUtilsTest {    
    
    static testmethod void testEmailDefaultsHandler(){
        
        Case newCase = new Case();
        insert newCase;
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = Test.newSendEmailQuickActionDefaults(newCase.Id, null);
        List<QuickAction.SendEmailQuickActionDefaults> defaults = new List<QuickAction.SendEmailQuickActionDefaults>();
        defaults.add(sendEmailDefaults);
        
        Test.startTest();
        EmailDefaultsUtils controller = new EmailDefaultsUtils();
        controller.onInitDefaults(defaults);
        Test.stopTest();
        EmailMessage emailMessage = (EmailMessage) sendEmailDefaults.getTargetSObject();
        //System.assertNotEquals(null, emailMessage.FromAddress);
    }
}