@isTest
public class SCCConnectorPostInstallScript_Test  {
    @testSetup static void setup() {
        SCCConnectorPostInstallScript.insertCustomSettingsData();
    }
    
    @isTest
    static void test_method_one() {
        List<ContactFieldMapping__c> contactFieldMappings = ContactFieldMapping__c.getAll().values();
        System.assert(!contactFieldMappings.isEmpty());
    }
}