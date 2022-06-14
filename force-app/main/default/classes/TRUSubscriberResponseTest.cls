/**
 * Created by i.yefremov on 23.07.2019.
 */

@IsTest
private class TRUSubscriberResponseTest {

    @IsTest
    static void responseConstructorTest() {
        Test.startTest();
        TRUSubscriberResponse instance = new TRUSubscriberResponse();
        Test.stopTest();

        System.assertNotEquals(null, instance, 'New instance of TRUSubscriberResponse should be created.');
    }

    @IsTest
    static void responseConstructorWithRecordDataTest() {
        String objectType = 'Account';
        String recordId = 'fakeAccId';
        String SFCCCustomerId = 'testCustomerId';
        String SFCCCustomerNo = 'testCustomerNo';
        String personContactId = 'fakeContactId';

        Test.startTest();
        TRUSubscriberResponse response = new TRUSubscriberResponse(objectType, recordId, SFCCCustomerId, SFCCCustomerNo, personContactId, null);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Instance for response should be created.');
        System.assertEquals(response.objectType, objectType, 'objectType property was not set correct.');
        System.assertEquals(response.recordId, recordId, 'recordId property was not set correct.');
        System.assertEquals(response.SFCCCustomerId, SFCCCustomerId, 'SFCCCustomerId property was not set correct.');
        System.assertEquals(response.SFCCCustomerNo, SFCCCustomerNo, 'SFCCCustomerNo property was not set correct.');
        System.assertEquals(response.personContactId, personContactId, 'personContactId property was not set correct.');
        System.assertEquals(response.errors, null, 'Response should not contain errors/');
    }

    @IsTest
    static void responseWithRecordTest() {
        Account account = new Account(SFCC_Customer_Id__pc = 'testCustomerId', SFCC_Customer_Number__pc = 'testCustomerNo');

        Test.startTest();
        TRUSubscriberResponse response = TRUSubscriberResponse.createResponse(account);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Instance for response should be created.');
        System.assertEquals(response.objectType, 'Account', 'objectType property was not set correct.');
        System.assertEquals(response.recordId, account.Id, 'recordId property was not set correct.');
        System.assertEquals(response.SFCCCustomerId, account.SFCC_Customer_Id__pc, 'SFCCCustomerId property was not set correct.');
        System.assertEquals(response.SFCCCustomerNo, account.SFCC_Customer_Number__pc, 'SFCCCustomerNo property was not set correct.');
        System.assertEquals(response.personContactId, account.PersonContactId, 'personContactId property was not set correct.');
        System.assertEquals(response.errors, null, 'Response should not contain errors.');
    }

    @IsTest
    static void generateResponseWithErrorsTest() {
        TRUSubscriberResponse response;

        Test.startTest();
        try{
            Integer errorProvider = 100/0;
        } catch(Exception e) {
            response = TRUSubscriberResponse.createError(e);
        }
        Test.stopTest();

        System.assertNotEquals(null, response, 'Instance for response should be created.');
        System.assertNotEquals(null, response.errors, 'Response should contain error info');
    }
}