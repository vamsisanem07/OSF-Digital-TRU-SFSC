@isTest
public class SCCCustomerPlaceOrderService_Test{

    @testSetup static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();      
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();  
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});        
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'Default', false);
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'order_no'=>'SFCC_Order_Number__c', 'crmcontact_id'=>'Order_Contact__c', 'status'=>'Status', 'order_total'=>'SFCC_Order_Total__c'}, 'Order'); 
        SCCTestDataFactory.createAccount(1, 'Default', false);         
    }
    
    @isTest static void test_create_one() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"' + [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1].Id + '","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        List<Order> orders = [Select Id from order];
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse(orders[0].Id)), System.JSON.serialize(stas));
        
    }

    @isTest static void test_create_two() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '"';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.JSONException","status":"500","errorMessage":"Unexpected end-of-input: was expecting closing quote for a string value at input location [1,3]","errorLine":"11"}}', System.JSON.serialize(stas));

    }

    @isTest static void test_create_three() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"' + [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1].Id + '","order_total":5}';
        delete [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        List<Order> orders = [Select Id from order];
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse(orders[0].Id)), System.JSON.serialize(stas));
    }

    @isTest static void test_create_four() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Order LIMIT 1].Id)), System.JSON.serialize(stas));

    } 

    @isTest static void test_create_five() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.JSONException","status":"500","errorMessage":"Unexpected end-of-input: expected close marker for OBJECT (from [line:1, column:3]","errorLine":"11"}}', System.JSON.serialize(stas));

    } 

    @isTest static void test_create_six() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"asdfasdf","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.QueryException","status":"500","errorMessage":"invalid ID field: asdfasdf","errorLine":"193"}}', System.JSON.serialize(stas));

    }         


    @isTest static void test_create_seven() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"' + [SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1].Id + '","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.SObjectException","status":"500","errorMessage":"Invalid data, Is PersonAccount Enabled: true","errorLine":"55"}}', System.JSON.serialize(stas));
        
    } 


    @isTest static void test_createContactOrderRecord_one() {
        
        SCCFileLogger logger = SCCFileLogger.getInstance();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"' + [SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1].Id + '","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body); 
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.createContactOrderRecord(jsonMap, logger);
        List<Order> orders = [Select Id from order];
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse(orders[0].Id)), System.JSON.serialize(stas));
        
    } 

    @isTest static void test_createContactOrderRecord_two() {
        
        SCCFileLogger logger = SCCFileLogger.getInstance();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body); 
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.createContactOrderRecord(jsonMap, logger);
        List<Order> orders = [Select Id from order];
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse(orders[0].Id)), System.JSON.serialize(stas));
        
    }    

    @isTest static void test_createContactOrderRecord_three() {
        
        SCCFileLogger logger = SCCFileLogger.getInstance();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"asdfasdf","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body); 
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.createContactOrderRecord(jsonMap, logger);
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.QueryException","status":"500","errorMessage":"invalid ID field: asdfasdf","errorLine":"193"}}', System.JSON.serialize(stas));
        
    } 

    @isTest static void test_createContactOrderRecord_four() {
        
        SCCFileLogger logger = SCCFileLogger.getInstance();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"0010D000002P13HQAZ","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body); 
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.createContactOrderRecord(jsonMap, logger);
        List<Order> orders = [Select Id from order];
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse(orders[0].Id)), System.JSON.serialize(stas));
        
    }
    
    @isTest static void test_defaultAccountMissing_Contact() {
        
        List<Account> defaultAccs = [select Id from Account where name='Default'];
        delete defaultAccs;
        SCCFileLogger logger = SCCFileLogger.getInstance();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"0010D000002P13HQAZ","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body); 
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.createContactOrderRecord(jsonMap, logger);
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createDefaultAccountError()), System.JSON.serialize(stas));
        
    }
    
    @isTest static void test_defaultAccountMissing() {
        List<Account> defaultAccs = [select Id from Account where name='Default'];
        delete defaultAccs;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        //System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Order LIMIT 1].Id)), System.JSON.serialize(stas));
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createDefaultAccountError()), System.JSON.serialize(stas));
    }
    
    @isTest static void test_showOrder() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '{"order_no":"12345","status":"Draft","crmcontact_id":"' + [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1].Id + '","order_total":5}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerPlaceOrderService.create();
        List<Order> orders = [Select Id from order];
        body = '{}';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/Order/Placement/'+orders[0].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        List<Order> orderDetails = SCCCustomerPlaceOrderService.show();
        System.debug(orderDetails.size());
        System.assertEquals(orders[0].Id, orderDetails[0].Id);
    }
}