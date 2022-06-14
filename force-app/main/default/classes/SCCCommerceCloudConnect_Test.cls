@isTest
public class SCCCommerceCloudConnect_Test {

    @testSetup
    static void setup() {

        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
    }

    @isTest
    static void testScheduleIt_One() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Id recordId = [SELECT Id FROM Order LIMIT 1].Id;
        SCCCommerceCloudConnect.scheduleIt(recordId);
        String listId = SCCCommerceCloudConnect.listId;
        String siteBaseUrl = SCCCommerceCloudConnect.siteBaseUrl;
        Integer scheduleTime = SCCCommerceCloudConnect.scheduleTime;
        String sfccClientSecret = SCCCommerceCloudConnect.sfccClientSecret;
		String sfccClientId = SCCCommerceCloudConnect.sfccClientId;
	}

    @isTest
    static void testScheduleIt_Two() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Id recordId = [SELECT Id FROM Contact LIMIT 1].Id;
        SCCCommerceCloudConnect.scheduleIt(recordId);
        String listId = SCCCommerceCloudConnect.listId;
        String siteBaseUrl = SCCCommerceCloudConnect.siteBaseUrl;
        Integer scheduleTime = SCCCommerceCloudConnect.scheduleTime;
    }

    @isTest
    static void testScheduleIt_Three() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Id recordId = [SELECT Id FROM Order LIMIT 1].Id;
        SCCCommerceCloudConnect.listId = 'SiteGenesis';
        SCCCommerceCloudConnect.siteBaseUrl = 'https://xxxx-dw.demandware.net';
        SCCCommerceCloudConnect.scheduleTime = 1;
        SCCCommerceCloudConnect.scheduleIt(recordId);
	}

    @isTest
    static void testScheduleIt_Four() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetailsWithoutContact'));
        Id recordId = [SELECT Id FROM Order LIMIT 1].Id;
        SCCCommerceCloudConnect.listId = 'SiteGenesis';
        SCCCommerceCloudConnect.siteBaseUrl = 'https://xxxx-dw.demandware.net';
        SCCCommerceCloudConnect.scheduleTime = 1;
        SCCCommerceCloudConnect.scheduleIt(recordId);
	}

    @isTest
    static void testSearchCustomerByEmail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        SCCCommerceCloudConnect.searchCustomerByEmail('test@hotmail.com', 'abcedfghij');
        Test.stopTest();
	}

    @isTest
    static void testConnectToCommerceCloud2ProfileOperations() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations();
        Test.stopTest();
	}

    @isTest
    static void testGetCustomerAuthToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        SCCCommerceCloudConnect.getCustomerAuthToken('2016f5bd-59bd-4c06-9233-8d807c8dc613', '2016f5bd59bd4c06');
        Test.stopTest();
	}

    @isTest
    static void testConnectToCommerceCloud(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.startTest();
        SCCCommerceCloudConnect.connectToCommerceCloud();
        Test.stopTest();
    }

    @isTest
    static void testGetOrderDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Test.startTest();
        SCCCommerceCloudConnect.getOrderDetails('00001603', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @isTest
    static void testGetCustomerDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Test.startTest();
        SCCCommerceCloudConnect.getCustomerDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@isTest
    static void testGetAddressDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddresses'));
        Test.startTest();
        SCCCommerceCloudConnect.getAddressDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@isTest
    static void testPostAddressDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddress'));
        String reqBody = '{"address_id":"my_home_address""salutation":"","title":"","company_name":"",';
        reqBody += '"first_name":"","second_name":"","last_name":"","postal_code":"","address1":"",';
        reqBody += '"address2":"","city":"","post_box":"","country_code":"","state_code":"","phone":"","suffix":""}';
        Test.startTest();
        SCCCommerceCloudConnect.postAddressDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@isTest
    static void testUpdateCCCustomerProfile_One(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        String reqBody = '{"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5",';
        reqBody += '"_delete":["fax","phone_mobile"],"birthday":"2011-05-06","email":"dude@demandware.com"}';
        Test.startTest();
        SCCCommerceCloudConnect.updateCCCustomerProfile(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @isTest
    static void testPushOrderDetails(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        String reqBody = '{"_resource_state" : "847f9c3c5867f641470b3046aeec31f07757991b792d722e10079926f7a289fb","status" : "replaced"}';
        Test.startTest();
        SCCCommerceCloudConnect.pushOrderDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@isTest
    static void testSynchroniseObjectFuture(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCommerceCloudConnect.logger = logger;
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
		Order order = [Select Id from Order limit 1];
        Test.startTest();
        SCCCommerceCloudConnect.synchroniseObjectFuture(order.Id);
        Test.stopTest();
    }

}