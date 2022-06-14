/*
    @Purpose		: Test class for CaseUtils
    @Created Date	: 18/08/2020
*/ 
@isTest
public class CaseUtilsTest {
    public static List<Case> mainList= new List<Case>();
    
    @TestSetup
    public static void checkAppeasement(){
        
        Contact newContact = new Contact();
        newContact.LastName = 'test';
        newContact.Email = 'test@gmail.com';
        insert newContact;
        
        Case newcase = new Case();
        newcase.Type = 'Account';
        newcase.Status = 'New';
        newcase.ContactId = newContact.Id;
        newcase.Origin = 'Web';
        newcase.Main_Online_Warehouse_Email__c = 'test@gmail.com';
        mainList.add(newcase);
        
        Case chatCase = new Case();
        chatCase.Status = 'New';
        chatCase.Origin = 'Chat offline form';
        chatCase.Description = 'Chat case';
        chatCase.First_Name__c = 'Test first name';
        chatCase.Last_Name__c = 'Test last name';
        chatCase.Email__c = 'test@abc.com';
        chatCase.Phone__c = '1234567890';
        chatCase.Chat_Language__c = 'EN';
        mainList.add(chatCase);
        
        insert mainList;
        
        newcase.Status = 'Closed';
        update newcase;
    }
    
    @isTest
    static void test(){
        Test.startTest();
        CaseUtils.populateOrgWideEmailsOnCase(mainList);       
        Test.stopTest();
    }    
}