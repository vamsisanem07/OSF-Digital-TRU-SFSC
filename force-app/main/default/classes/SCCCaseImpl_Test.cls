/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCCCaseImpl_Test {

    @testSetup 
    static void setup() {
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();    	
    	SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'}, new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'}); 
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'personEmail', 'birthday'=>'personBirthDate'}, 'Account');    
        SCCTestDataFactory.createAccountCase(1, [select Id from Account Limit 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
		SCCTestDataFactory.createCase(1, [select Id from Contact Limit 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');        
    }
    
    @isTest
    static void testContinueWithObject_One() {        
        Case cs = [select Id, AccountId, SFCC_Customer_Number__c FROM Case LIMIT 1];
        Test.startTest();
		(new SCCCaseImpl()).continueWithObject(cs);   
        Test.stopTest();             
    }
    
    @isTest
    static void testContinueWithObject_Two() {
        Test.startTest();
		(new SCCCaseImpl()).continueWithObject(null);   
        Test.stopTest();              
    } 

    @isTest
    static void testSyncContactCase_One() {
    	SCCFileLogger logger = SCCFileLogger.getInstance();  
        Test.startTest();
        List<Case> cs = [select Id, ContactId, SFCC_Customer_Number__c FROM Case];
        SCCCaseImpl.syncContactCase(cs[0], logger);   
        Test.stopTest();             
    }
    
    @isTest
    static void testSyncContactCase_Two() {
        try{
            SCCFileLogger logger = SCCFileLogger.getInstance();        
            Test.startTest();
            SCCCaseImpl.syncContactCase(null, logger);   
            Test.stopTest();            
        }catch(Exception e){
            
        }
    }      
}