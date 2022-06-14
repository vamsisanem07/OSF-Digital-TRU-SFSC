@isTest
public class SCCContactRefreshCompController_Test {

    @testSetup 
    static void setup() {
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();    	
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();  
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'}); 
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'personEmail', 'birthday'=>'personBirthDate', 'customer_no'=>'SFCC_Customer_Number__pc', 'customer_id'=>'SFCC_Customer_Id__pc'}, 'Account');    
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'Email', 'birthday'=>'BirthDate', 'customer_no'=>'SFCC_Customer_Number__c', 'customer_id'=>'SFCC_Customer_Id__c'}, 'Contact'); 
        SCCTestDataFactory.createAccountCase(1, [select Id from Account Limit 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
        SCCTestDataFactory.createCase(1, [select Id from Contact Limit 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');    
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);   
        SCCTestDataFactory.createAccount(1, 'Default', false);        
    }

	@isTest
    static void testGetCustomers_One(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Account acc = [Select Id from Account limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.getCustomers(acc.Id);
        Test.stopTest();
    }  
    
	@isTest
    static void testGetCustomers_Two(){
        SCCContactRefreshComponentController.getCustomers('fakeId');
    } 
    
	@isTest
    static void testGetCustomers_Three(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Contact contact = [Select Id from Contact limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.getCustomers(contact.Id);
        Test.stopTest();
    }     
    
	@isTest
    static void testGetCustomers_Four(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetailsNotFound'));
        Contact contact = [Select Id from Contact limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.getCustomers(contact.Id);
        Test.stopTest();
    }   

	@isTest
    static void testGetCustomersData_One(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Contact contact = [Select Id, SFCC_Customer_Number__c from Contact limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.getCustomersData(contact.SFCC_Customer_Number__c, logger); 
        Test.stopTest();
    }
    
	@isTest
    static void testGetCustomersData_Two(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetailsNotFound'));
        Contact contact = [Select Id, SFCC_Customer_Number__c from Contact limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.getCustomersData(contact.SFCC_Customer_Number__c, logger); 
        Test.stopTest();
    } 

	@isTest
    static void testGetCustomersData_Three(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetailsNotFound'));
        Contact contact = [Select Id, SFCC_Customer_Number__c from Contact limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.getCustomersData(null, logger); 
        Test.stopTest();
    } 

	@isTest
    static void testGetCustomersData_Four(){
       	SCCFileLogger logger = SCCFileLogger.getInstance();       
        Test.startTest();
        SCCContactRefreshComponentController.getCustomersData(null, logger); 
        Test.stopTest();
    }   
    
    @isTest
    static void testSyncCustomer_One(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Account acc = [Select Id from Account limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.syncCustomer(acc.Id);
        Test.stopTest();        
    }

    @isTest
    static void testSyncCustomer_Two(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Contact contact = [Select Id from Contact limit 1];
        Test.startTest();
        SCCContactRefreshComponentController.syncCustomer(contact.Id);
        Test.stopTest();        
    }
}