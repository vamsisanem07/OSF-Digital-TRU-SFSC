@isTest
public class SCCCustomerRegistrationService_Test  {

    @testSetup 
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();    	
    	SCCTestDataFactory.createSFCCLogDefaultCustomSetting();  
        SCCTestDataFactory.createAccount(1, 'Default', false);
        //SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'testa@hotmail.com', 2=>'testa@yahoo.com', 3=>'testa@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});         
        //SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fnamea', 2=>'fnameb', 3=>'fnamec'}, new Map<Integer, String>{1=>'lnamea', 2=>'lnameb', 3=>'lnamec'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'customer_id'=>'SFCC_Customer_Id__c ', 'customer_no'=>'SFCC_Customer_Number__c ', 'email'=>'Email', 'first_name'=>'FirstName', 'last_name'=>'LastName'}, 'Contact');          
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'customer_id'=>'SFCC_Customer_Id__pc ', 'customer_no'=>'SFCC_Customer_Number__pc ', 'email'=>'personEmail', 'first_name'=>'FirstName', 'last_name'=>'LastName'}, 'Account');        
    }
    
    @isTest 
    static void test_create_one() {     
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"test_fname","last_name":"test_lname","email":"test@gmail.com","customer_no":"12345","customer_id":"1245"}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.create();
        System.assertEquals(System.JSON.serialize(SCCCustomerRegResponse.createResponse([SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId FROM Account WHERE personEmail = 'test@gmail.com'])).replace('"additionalFields":null', '"additionalFields":{}'), System.JSON.serialize(stas));
    }

    @isTest 
    static void test_create_two() { 
		SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'testa@yahoo.com', 3=>'testa@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});                 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"test_fname","last_name":"test_lname","email":"test@hotmail.com","customer_no":"12345","customer_id":"1245"}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.create();
        System.assertEquals(System.JSON.serialize(SCCCustomerRegResponse.createResponse([SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId FROM Account WHERE personEmail = 'test@hotmail.com'])).replace('"additionalFields":null', '"additionalFields":{}'), System.JSON.serialize(stas));
    }

    /*@isTest
    static void test_create_three() {       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('test');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.create();
        System.assertEquals('{"SFCCCustomerNo":null,"SFCCCustomerId":null,"recordId":null,"objectType":null,"errors":{"typeOfError":"System.JSONException","status":"500","errorMessage":"Unrecognized token \'test\': was expecting  at input location [1,9]","errorLine":"11"}}', System.JSON.serialize(stas));
    }*/

    @isTest 
    static void test_create_four() { 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"customer_name":"test fname","email":"test@gmail.com","customer_no":"12345","customer_id":"1245"}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.create();
        System.assertEquals(System.JSON.serialize(SCCCustomerRegResponse.createResponse([SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId FROM Account WHERE personEmail = 'test@gmail.com'])).replace('"additionalFields":null', '"additionalFields":{}'), System.JSON.serialize(stas));
    }
    
    @isTest 
    static void test_createContactRecord_one() { 
        SCCFileLogger logger = SCCFileLogger.getInstance();        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"customer_name":"test fname","email":"test@gmail.com","customer_no":"12345","customer_id":"1245"}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.createContactRecord(req, logger);
        System.assertEquals(System.JSON.serialize(SCCCustomerRegResponse.createResponse([SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE Email = 'test@gmail.com'])), System.JSON.serialize(stas));
    } 
    
    @isTest 
    static void test_createContactRecord_two() { 
        SCCFileLogger logger = SCCFileLogger.getInstance();  
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fnamea', 2=>'fnameb', 3=>'fnamec'}, new Map<Integer, String>{1=>'lnamea', 2=>'lnameb', 3=>'lnamec'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"customer_name":"test fname","email":"test@hotmail.com","customer_no":"12345","customer_id":"1245"}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.createContactRecord(req, logger);
        System.assertEquals(System.JSON.serialize(SCCCustomerRegResponse.createResponse([SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE Email = 'test@hotmail.com'])), System.JSON.serialize(stas));
    } 

    @isTest 
    static void test_createContactRecord_three() { 
        SCCFileLogger logger = SCCFileLogger.getInstance(); 
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fnamea', 2=>'fnameb', 3=>'fnamec'}, new Map<Integer, String>{1=>'lnamea', 2=>'lnameb', 3=>'lnamec'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});         
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.createContactRecord(req, logger);
        System.assertNotEquals(System.JSON.serialize(SCCCustomerRegResponse.createResponse([SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE Email = 'test@hotmail.com'])), System.JSON.serialize(stas));
    }     
    
    @isTest static void test_showOrder() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"test_fname","last_name":"test_lname","email":"test@gmail.com","customer_no":"12345","customer_id":"1245"}');
        req.requestURI = '/services/apexrest/Contact/Registration';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SCCCustomerRegResponse stas = SCCCustomerRegistrationService.create();
        System.debug('System.JSON.serialize(stas): ' + System.JSON.serialize(stas));
        String output = System.JSON.serialize(stas);
        Map<String, Object> deOutput = (Map<String, Object>)System.JSON.deserializeUntyped(output);
        String accountId = (String)deOutput.get('recordId');
        String body = '{}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/Contact/Registration/'+accountId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        List<Account> accountDetails = SCCCustomerRegistrationService.show();
        System.assertEquals(accountId, accountDetails[0].Id);
    }
}