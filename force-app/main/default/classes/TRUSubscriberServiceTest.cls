/**
 * Created by i.yefremov on 23.07.2019.
 */

@IsTest
private class TRUSubscriberServiceTest {

    @testSetup
    static void setup() {
        TRUTestDataFactory.createTruSubscriberCustomSetting();
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'customer_id'=>'SFCC_Customer_Id__pc ', 'customer_no'=>'SFCC_Customer_Number__pc ', 'email'=>'personEmail', 'first_name'=>'FirstName', 'last_name'=>'LastName'}, 'Account');
    }

    @IsTest
    static void newCustomerCreationTest() {
        String firstName = 'FirstNameTest';
        String lastName = 'LastNameTest';
        String email = 'testemail@email.com';
        String customerId = 'customerIdTest';
        String customerNo = 'customerNoTest';
        initializeRequest(firstName, lastName, email, customerId, customerNo);

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        List<Account> accounts = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId, PersonEmail, FirstName, LastName FROM Account];

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertEquals(null, response.errors, 'Response should not contain errors.');
        System.assertEquals('Account', response.objectType, 'Account object type should be set.');
        System.assertEquals(1, accounts.size(), '1 Account record should be created');
        System.assertEquals(firstName, accounts[0].FirstName, 'Account first name field was not populated correct.');
        System.assertEquals(lastName, accounts[0].LastName, 'Account first name field was not populated correct.');
        System.assertEquals(email, accounts[0].PersonEmail, 'Account last name field was not populated correct.');
        System.assertEquals(customerId, accounts[0].SFCC_Customer_Id__pc, 'Account customer id field was not populated correct.');
        System.assertEquals(customerNo, accounts[0].SFCC_Customer_Number__pc, 'Account customer number field was not populated correct.');
        System.assertEquals(accounts[0].Id, response.recordId, 'Id of created Account should be returned as recordId property in response.');
        System.assertEquals(accounts[0].SFCC_Customer_Id__pc, response.SFCCCustomerId, 'Customer Id of created Account should be returned as SFCCCustomerId property in response.');
        System.assertEquals(accounts[0].SFCC_Customer_Number__pc, response.SFCCCustomerNo, 'Customer number of created Account should be returned as SFCCCustomerNo property in response.');
        System.assertEquals(accounts[0].PersonContactId, response.personContactId, 'Contact Id of created Account should be returned as personContactId property in response.');
    }

    @IsTest
    static void newCustomerCreationWithoutOptionalFieldsTest() {
        String firstName = 'FirstNameTest';
        String lastName = 'LastNameTest';
        String email = 'testemail@email.com';
        initializeRequest(firstName, lastName, email, null, null);

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        List<Account> accounts = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId, PersonEmail, FirstName, LastName FROM Account];

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertEquals(null, response.errors, 'Response should not contain errors.');
        System.assertEquals('Account', response.objectType, 'Account object type should be set.');
        System.assertEquals(1, accounts.size(), '1 Account record should be created');
        System.assertEquals(firstName, accounts[0].FirstName, 'Account first name field was not populated correct.');
        System.assertEquals(lastName, accounts[0].LastName, 'Account first name field was not populated correct.');
        System.assertEquals(email, accounts[0].PersonEmail, 'Account last name field was not populated correct.');
        System.assertEquals(null, accounts[0].SFCC_Customer_Id__pc, 'Account customer id field should not be populated.');
        System.assertEquals(null, accounts[0].SFCC_Customer_Number__pc, 'Account customer number field should not be populated.');
        System.assertEquals(accounts[0].Id, response.recordId, 'Id of created Account should be returned as recordId property in response.');
        System.assertEquals(accounts[0].PersonContactId, response.personContactId, 'Contact Id of created Account should be returned as personContactId property in response.');
    }

    @IsTest
    static void newCustomerCreationWithoutLastNameTest() {
        String firstName = 'FirstNameTest';
        String email = 'testemail@email.com';
        initializeRequest(firstName, null, email, null, null);

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        List<Account> accounts = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId, PersonEmail, FirstName, LastName FROM Account];
        String defaultLastName = TRU_Subscriber_Config__c.getInstance().Default_Last_Name__c;

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertEquals(null, response.errors, 'Response should not contain errors.');
        System.assertEquals('Account', response.objectType, 'Account object type should be set.');
        System.assertEquals(1, accounts.size(), '1 Account record should be created');
        System.assertEquals(firstName, accounts[0].FirstName, 'Account first name field was not populated correct.');
        System.assertEquals(defaultLastName, accounts[0].LastName, 'Account first name field was not populated correct.');
        System.assertEquals(email, accounts[0].PersonEmail, 'Account last name field was not populated correct.');
        System.assertEquals(null, accounts[0].SFCC_Customer_Id__pc, 'Account customer id field should not be populated.');
        System.assertEquals(null, accounts[0].SFCC_Customer_Number__pc, 'Account customer number field should not be populated.');
        System.assertEquals(accounts[0].Id, response.recordId, 'Id of created Account should be returned as recordId property in response.');
        System.assertEquals(accounts[0].PersonContactId, response.personContactId, 'Contact Id of created Account should be returned as personContactId property in response.');
    }

    @IsTest
    static void newCustomerCreationWithEmptyLastNameTest() {
        String firstName = 'FirstNameTest';
        String email = 'testemail@email.com';
        String lastName = '';
        initializeRequest(firstName, lastName, email, null, null);

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        List<Account> accounts = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId, PersonEmail, FirstName, LastName FROM Account];
        String defaultLastName = TRU_Subscriber_Config__c.getInstance().Default_Last_Name__c;

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertEquals(null, response.errors, 'Response should not contain errors.');
        System.assertEquals('Account', response.objectType, 'Account object type should be set.');
        System.assertEquals(1, accounts.size(), '1 Account record should be created');
        System.assertEquals(firstName, accounts[0].FirstName, 'Account first name field was not populated correct.');
        System.assertEquals(defaultLastName, accounts[0].LastName, 'Account first name field was not populated correct.');
        System.assertEquals(email, accounts[0].PersonEmail, 'Account last name field was not populated correct.');
        System.assertEquals(null, accounts[0].SFCC_Customer_Id__pc, 'Account customer id field should not be populated.');
        System.assertEquals(null, accounts[0].SFCC_Customer_Number__pc, 'Account customer number field should not be populated.');
        System.assertEquals(accounts[0].Id, response.recordId, 'Id of created Account should be returned as recordId property in response.');
        System.assertEquals(accounts[0].PersonContactId, response.personContactId, 'Contact Id of created Account should be returned as personContactId property in response.');
    }

    @IsTest
    static void oldCustomerUpdateTest() {
        String firstName = 'FirstNameTest';
        String lastName = 'LastNameTest';
        String email = 'testemail@email.com';
        String customerId = 'customerIdTest';
        String customerNo = 'customerNoTest';

        RecordType personAccountRT = SCCUtilityClass.getPersonAccountRecordType('Person Account');
        Account account = new Account(FirstName = 'OldCustomer', LastName = 'OldCustomerLN', PersonEmail = email, RecordTypeId = personAccountRT.Id);
        insert account;
        initializeRequest(firstName, lastName, email, customerId, customerNo);

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        Account updatedAccount = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId, PersonEmail, FirstName, LastName FROM Account WHERE Id = :account.Id];

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertEquals(null, response.errors, 'Response should not contain errors.');
        System.assertEquals('Account', response.objectType, 'Account object type should be set.');
        System.assertEquals(firstName, updatedAccount.FirstName, 'Account first name field was not populated correct.');
        System.assertEquals(lastName, updatedAccount.LastName, 'Account first name field was not populated correct.');
        System.assertEquals(email, updatedAccount.PersonEmail, 'Account last name field was not populated correct.');
        System.assertEquals(customerId, updatedAccount.SFCC_Customer_Id__pc, 'Account customer id field was not populated correct.');
        System.assertEquals(customerNo, updatedAccount.SFCC_Customer_Number__pc, 'Account customer number field was not populated correct.');
        System.assertEquals(updatedAccount.Id, response.recordId, 'Id of created Account should be returned as recordId property in response.');
        System.assertEquals(updatedAccount.SFCC_Customer_Id__pc, response.SFCCCustomerId, 'Customer Id of updated Account should be returned as SFCCCustomerId property in response.');
        System.assertEquals(updatedAccount.SFCC_Customer_Number__pc, response.SFCCCustomerNo, 'Customer number of updated Account should be returned as SFCCCustomerNo property in response.');
        System.assertEquals(updatedAccount.PersonContactId, response.personContactId, 'Contact Id of updated Account should be returned as personContactId property in response.');
    }

    @IsTest
    static void oldCustomerUpdateWithBlankLastNameTest() {
        String firstName = 'FirstNameTest';
        String lastName = '';
        String email = 'testemail@email.com';
        String customerId = 'customerIdTest';
        String customerNo = 'customerNoTest';

        RecordType personAccountRT = SCCUtilityClass.getPersonAccountRecordType('Person Account');
        Account account = new Account(FirstName = 'OldCustomer', LastName = 'OldCustomerLN', PersonEmail = email, RecordTypeId = personAccountRT.Id);
        insert account;
        initializeRequest(firstName, lastName, email, customerId, customerNo);

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        Account updatedAccount = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc, PersonContactId, PersonEmail, FirstName, LastName FROM Account WHERE Id = :account.Id];

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertEquals(null, response.errors, 'Response should not contain errors.');
        System.assertEquals('Account', response.objectType, 'Account object type should be set.');
        System.assertEquals(firstName, updatedAccount.FirstName, 'Account first name field was not populated correct.');
        System.assertEquals(account.LastName, updatedAccount.LastName, 'Account first name field was not populated correct.');
        System.assertEquals(email, updatedAccount.PersonEmail, 'Account last name field was not populated correct.');
        System.assertEquals(customerId, updatedAccount.SFCC_Customer_Id__pc, 'Account customer id field was not populated correct.');
        System.assertEquals(customerNo, updatedAccount.SFCC_Customer_Number__pc, 'Account customer number field was not populated correct.');
        System.assertEquals(updatedAccount.Id, response.recordId, 'Id of created Account should be returned as recordId property in response.');
        System.assertEquals(updatedAccount.SFCC_Customer_Id__pc, response.SFCCCustomerId, 'Customer Id of updated Account should be returned as SFCCCustomerId property in response.');
        System.assertEquals(updatedAccount.SFCC_Customer_Number__pc, response.SFCCCustomerNo, 'Customer number of updated Account should be returned as SFCCCustomerNo property in response.');
        System.assertEquals(updatedAccount.PersonContactId, response.personContactId, 'Contact Id of updated Account should be returned as personContactId property in response.');
    }

    @IsTest
    static void newCustomerErrorTest() {
        initializeRequest('FirstNameTest', 'LastNameTest', 'SPOILTEMAILFORERROR', 'customerIdTest', 'customerNoTest');

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberService.findOrCreateAccount();
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response object should be provided.');
        System.assertNotEquals(null, response.errors, 'Response should return errors.');
        System.assertEquals(null, response.recordId, 'There should be no additional data except error info in response object.');
        System.assertEquals(null, response.SFCCCustomerId, 'There should be no additional data except error info in response object.');
        System.assertEquals(null, response.SFCCCustomerNo, 'There should be no additional data except error info in response object.');
        System.assertEquals(null, response.personContactId, 'There should be no additional data except error info in response object.');
    }

    private static void initializeRequest(String first_name, String last_name, String email, String customer_id, String customer_no){
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(generateRequestBody(first_name, last_name, email, customer_id, customer_no));
        RestContext.request = request;
        RestContext.response = new RestResponse();
    }

    private static String generateRequestBody(String first_name, String last_name, String email, String customer_id, String customer_no){
        String requestBody = '{"first_name": "' + first_name + '"';
        requestBody += ',"email": "' + email + '"';
        if(last_name != null) {
            requestBody += ',"last_name": "' + last_name + '"';
        }
        if(customer_id != null) {
            requestBody += ',"customer_id": "' + customer_id + '"';
        }
        if(customer_no != null) {
            requestBody += ',"customer_no": "' + customer_no + '"';
        }
        requestBody += '}';
        return requestBody;
    }
}