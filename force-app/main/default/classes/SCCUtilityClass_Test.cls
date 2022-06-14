@isTest
public class SCCUtilityClass_Test  {

    @testSetup
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
    	SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'Default', false);
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'});
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'status'=>'status', 'order_no'=>'SFCC_Orde_Number__c', 'order_total'=>'SFCC_Order_Total__c', 'customer_info'=>'Contact__c'}, 'Order');
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);

    }

    @isTest
    static void test_method_one() {
        Map<String, Schema.SObjectField> obf = SCCUtilityClass.getFields('Order');
        System.assert(!obf.isEmpty());
    }

    @isTest
    static void test_method_two() {
        List<String> obf = SCCUtilityClass.getAllFields('Order');
        System.assert(!obf.isEmpty());
    }

    @isTest
    static void test_method_three() {
        Set<String> fieldApis = new Set<String>{'OrderNumber'};
        List<String> obf = SCCUtilityClass.getWantedFields('Order', fieldApis);
        System.assert(!obf.isEmpty());
    }

    @isTest
    static void test_method_four() {
        Set<String> fieldApis = new Set<String>{'OrderNumber'};
        List<String> obf = SCCUtilityClass.getWantedFields('Order', fieldApis);
        System.assert(!obf.isEmpty());
    }

    @isTest
    static void testIsPersonAccountExist(){
        Boolean resp = SCCUtilityClass.isPersonAccountExist([SELECT Id FROM Account WHERE isPersonAccount=True Limit 1].Id);
        System.assert(resp);
    }

    @isTest
    static void testPersonAccountNotExist(){
        Account acc = SCCUtilityClass.getPersonAccount([SELECT Id FROM Account WHERE isPersonAccount=True Limit 1].Id);
        System.assertNotEquals(null, acc);
    }

    @isTest
    static void testGetPersonAccount(){
        Account acc = SCCUtilityClass.getPersonAccount('123');
        System.assertEquals(null, acc);
    }

    @isTest
    static void testErrorGetPersonAccount(){
        Boolean resp = SCCUtilityClass.isPersonAccountExist('123');
        System.assert(!resp);
    }


    @isTest
    static void testGetAddressByNameAndAccount_One(){
        Account acc = [SELECT Id FROM Account WHERE isPersonAccount=True Limit 1];
        Address__c address = SCCUtilityClass.getAddressByNameAndAccount('home', acc.Id);
        System.assertEquals(null, address);
    }

    @isTest
    static void testGetAddressByNameAndAccount_Two (){
        Account acc = [SELECT Id FROM Account WHERE isPersonAccount=True Limit 1];
        Address__c address = SCCUtilityClass.getAddressByNameAndAccount('', null);
        System.assertEquals(null, address);
    }

    @isTest
    static void testGetAddressByName_One(){
        Address__c address = SCCUtilityClass.getAddressByName('home');
        System.assertEquals(null, address);
    }

    @isTest
    static void testGetAddressByName_Two(){
        Address__c address = SCCUtilityClass.getAddressByName('');
        System.assertEquals(null, address);
    }

    @isTest
    static void testIsPersonAccountEnabled(){
        Boolean resp = SCCUtilityClass.isPersonAccountEnabled();
        System.assert(resp);
    }

    @isTest
    static void testGetPersonAccountRecordType(){
        RecordType resp = SCCUtilityClass.getPersonAccountRecordType('testAccount');
		System.assertEquals(null, resp);
    }

    @isTest
    static void testGetSojectByRefId_One(){
    	Sobject obj = SCCUtilityClass.getSojectByRefId([SELECT Id FROM Account WHERE isPersonAccount=True Limit 1].Id);
        System.assertNotEquals(null, obj);
    }

    @isTest
    static void testGetSojectByRefId_Two(){
    	Sobject obj = SCCUtilityClass.getSojectByRefId([SELECT Id FROM Contact Limit 1].Id);
        System.assertNotEquals(null, obj);
    }

    @isTest
    static void testGetSojectByRefId_Three(){
    	Sobject obj = SCCUtilityClass.getSojectByRefId('fakeId');
        System.assertEquals(null, obj);
    }

    @isTest
    static void testGetDefaultAccount(){
    	Sobject obj = SCCUtilityClass.getDefaultAccount();
        System.assertNotEquals(null, obj);
    }

    @isTest
    static void testGetAllCustomSettingValues(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
    	Map<String, SObject> respMap = SCCUtilityClass.getAllCustomSettingValues('Order', logger);
        System.assertNotEquals(null, respMap);
    }

    @isTest
    static void testGetSyncCustomSettingValues_One(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
    	Map<String, SObject> respMap = SCCUtilityClass.getSyncCustomSettingValues('Order', true, logger);
        System.assertEquals(0, respMap.size());
    }

    @isTest
    static void testGetSyncCustomSettingValues_Two(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
    	Map<String, SObject> respMap = SCCUtilityClass.getSyncCustomSettingValues('Order', false, logger);
        System.assertNotEquals(0, respMap.size());
    }

    @isTest
    static void testGetPatchCustomSettingValues_One(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
    	Map<String, SObject> respMap = SCCUtilityClass.getPatchCustomSettingValues('Order', true, logger);
        System.assertEquals(0, respMap.size());
    }

    @isTest
    static void testGetPatchCustomSettingValues_Two(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
    	Map<String, SObject> respMap = SCCUtilityClass.getPatchCustomSettingValues('Order', false, logger);
        System.assertNotEquals(0, respMap.size());
    }

    @isTest
    static void testInitializeObject(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"vinnie.jones@xaebo.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/SiteGenesis/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"SiteGenesis","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
       	Map<String, SObject> orderFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);
     	SObject obj = SCCUtilityClass.initializeObject(jsonMap, 'Order', orderFieldMappings, logger);
        System.assertNotEquals(null, obj);
    }

    @isTest
    static void testAdditionalFieldsforContact(){
    	Map<String, Object> jsonMap = new Map<String, Object>{'customer_name'=>'first last'};
        Contact contact = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
     	contact = SCCUtilityClass.additionalFieldsforContact(contact, jsonMap);
        System.assertNotEquals(null, contact);
    }

    @isTest
    static void testAdditionalFieldsforAccount(){
    	Map<String, Object> jsonMap = new Map<String, Object>{'customer_name'=>'first last'};
        Account acc = [SELECT Id, FirstName, LastName FROM Account LIMIT 1];
     	acc = SCCUtilityClass.additionalFieldsforAccount(acc, jsonMap);
        System.assertNotEquals(null, acc);
    }
}