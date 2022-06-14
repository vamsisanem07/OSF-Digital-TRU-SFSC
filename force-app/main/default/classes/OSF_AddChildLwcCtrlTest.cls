/**
* @author: Mubeen Akbar
* @description: This class is used to test the Add Child LWC functionality
*/
@isTest
public class OSF_AddChildLwcCtrlTest {
    
    @TestSetup
    static void makeData(){
        
        //create test data for Account
        
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account ac = new Account();
        ac.FirstName = 'Fred';
        ac.LastName = 'Smith';
        ac.RecordTypeId = personAccountRecordTypeId;
        insert ac;
        
        //create test data for Contact
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        
        //create test data for Child__c
        Child__c child = new Child__c();
        child.Name__c = 'Test Child';
        child.Account__c = ac.Id;
        child.Birthday__c = Date.Today();
        insert child;
    }
    
    @isTest
    public static void testUpsertChildLwcCtrl() {
        List<Child__c> childList = [SELECT Name__c, Account__c, Birthday__c FROM Child__c WHERE Name__c = 'Test Child'];
        system.assertEquals(1, childList.size());
        Child__c child = childList[0];
        //create test data for Child__c
        Child__c child2 = new Child__c();
        child2.Name__c = 'Child Input';
        child2.Account__c = child.Account__c;
        child2.Birthday__c = Date.Today();
        insert child2;    
        system.assertEquals('Test Child', child.Name__c);
        OSF_AddChildLwcCtrl.upsertChilds(json.serialize(child2),child.Account__c);
    }
    
    //create test method for deletechild
    @isTest
    public static void testDeleteChildLwcCtrl() {
        List<Child__c> childList = [SELECT Name__c, Account__c, Birthday__c FROM Child__c WHERE Name__c = 'Test Child'];
        system.assertEquals(1, childList.size());
        Child__c child = childList[0];
        
        OSF_AddChildLwcCtrl.deleteChild(json.serialize(child));
        List<Child__c> childList2 = [SELECT Name__c, Account__c, Birthday__c FROM Child__c WHERE Name__c = 'Test Child'];
        system.assertEquals(0, childList2.size());
    }

    //create test method for getChildsfromAccount(String acId)
    @isTest
    public static void testGetChildsfromAccount() {
        List<Child__c> childList = [SELECT Name__c, Account__c, Birthday__c FROM Child__c WHERE Name__c = 'Test Child'];
        system.assertEquals(1, childList.size());
        Child__c child = childList[0];
        List<Child__c> childList2 = OSF_AddChildLwcCtrl.getChildsfromAccount(child.Account__c);
        Account ac = OSF_AddChildLwcCtrl.getPersonAccount(child.Account__c);
        OSF_AddChildLwcCtrl.updatePersonAccount(json.serialize(ac));
        system.assertEquals(1, childList2.size());
    }
}