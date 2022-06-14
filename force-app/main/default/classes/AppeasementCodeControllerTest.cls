/*
    @Purpose        : Test class for AppeasementCodeController
    @Created Date   : 18/08/2020
*/ 
@isTest
public class AppeasementCodeControllerTest { 
    
    @TestSetup
    public static void checkAppeasement(){
        Contact newContact = new Contact();
        newContact.LastName = 'test';
        newContact.Email = 'test@abc.com';
        insert newContact;
       
        Case newcase = new Case();
        newcase.Type = 'Account';
        newcase.Status = 'New';
        newcase.ContactId = newContact.Id;
        insert newcase;
         
        Appeasement__c appeasement = new Appeasement__c();
        appeasement.Purpose_of_Appeasement__c = 'Baby Registry';
        appeasement.Case__c = newcase.Id;
        appeasement.Contact__c = newContact.id;
        appeasement.Discount_Type__c = 'Checklist - 8 mth - Online';
        insert appeasement;  
        
        Appeasement_Code__c appeasementCode = new Appeasement_Code__c();
        appeasementCode.Status__c = 'Available';
        appeasementCode.Discount_Type__c = appeasement.Discount_Type__c;
        appeasementCode.Purpose_of_Appeasement__c = appeasement.Purpose_of_Appeasement__c;
        insert appeasementCode;
     
    }
    
    @isTest
    static void test(){
        Test.startTest();
        Appeasement__c appeasement = [SELECT Purpose_of_Appeasement__c, Discount_Type__c 
                                      FROM Appeasement__c WHERE Purpose_of_Appeasement__c = 'Baby Registry' limit 1];
        
        String response = AppeasementCodeController.getAvailableAppeasementCode(appeasement.Id); 
        
        Test.stopTest();
        
        System.assert(response.contains('Success!'));
        
        response = AppeasementCodeController.getAvailableAppeasementCode(null);
        
        System.assert(response == 'Error! Failed to get the Appeasement Code.');
    }
}