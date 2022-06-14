@IsTest
private class AccountCardNumberHelperTest {
    @testSetup
    static void setupData() {
        TRUTestDataFactory.createRclubNumberSettingsCustomSetting();
    }

    @IsTest
    static void generateClcNumberGeneralEnglishTest() {
        List<Account> accList = createAccounts(1, 'EN');

        Test.startTest();
        AccountCardNumberHelper.generateClcNumberGeneral(accList);
        Test.stopTest();

        assertAccountResult(accList[0], '6666300000090');
        System.assertEquals(10, Rclub_Number_Settings__c.getOrgDefaults().Number__c);
    }

    @IsTest
    static void generateClcNumberGeneralFrenchTest() {
        List<Account> accList = createAccounts(1, 'FR');

        Test.startTest();
        AccountCardNumberHelper.generateClcNumberGeneral(accList);
        Test.stopTest();

        assertAccountResult(accList[0], '6666400000099');
        System.assertEquals(10, Rclub_Number_Settings__c.getOrgDefaults().Number__c);
    }

    @IsTest
    static void generateClcNumberGeneralEmptyLanguageTest() {
        List<Account> accList = createAccounts(1, '');

        Test.startTest();
        AccountCardNumberHelper.generateClcNumberGeneral(accList);
        Test.stopTest();

        assertAccountResult(accList[0], '6666000000093');
        System.assertEquals(10, Rclub_Number_Settings__c.getOrgDefaults().Number__c);
    }

    @IsTest
    static void generateClcNumberTest() {
        List<Account> accList = createAccounts(1, 'EN');

        Test.startTest();
        AccountCardNumberHelper.generateClcNumber(accList);
        Test.stopTest();

        assertAccountResult(accList[0], '6666300000090');
        System.assertEquals(9, Rclub_Number_Settings__c.getOrgDefaults().Number__c);
    }

    @IsTest
    static void generateClcNumberNegativeTest() {
        List<Account> accList = createAccounts(1, 'EN');
        accList[0].R_Club_Number__c = '0003333';

        Test.startTest();
        AccountCardNumberHelper.generateClcNumber(accList);
        Test.stopTest();

        assertAccountResult(accList[0], '0003333');
        System.assertEquals(9, Rclub_Number_Settings__c.getOrgDefaults().Number__c);
    }

    @IsTest
    static void generateClcNumberMassTest() {
        List<Account> accList = createAccounts(300, 'EN');

        Test.startTest();
        AccountCardNumberHelper.generateClcNumber(accList);
        Test.stopTest();

        assertAccountResult(accList[0], '6666300000090');
        assertAccountResult(accList[accList.size() - 1], '6666300003086');
        System.assertEquals(300, accList.size());
        System.assertEquals(9, Rclub_Number_Settings__c.getOrgDefaults().Number__c);
    }

    private static void assertAccountResult(Account accResult, String rclubNumber){
        System.assertEquals(rclubNumber, accResult.R_Club_Number__c);
    }

    private static List<Account> createAccounts(Integer length, String language){
        List<Account> accList = new List<Account>();

        for (Integer i = 0; i < length; ++i){
            accList.add(new Account(Name = 'Test Account ' + (i + 1), Language_Preference__c = language));
        }

        return accList;
    }
}