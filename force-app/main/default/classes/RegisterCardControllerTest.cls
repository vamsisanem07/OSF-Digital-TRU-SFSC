@isTest
private class RegisterCardControllerTest {

    @testSetup
    static void setup() {
        TRUTestDataFactory.createRclubNumberSettingsCustomSetting();

        List<Account> accountsForInsert = TRUTestDataFactory.createAccounts(2, 'EN');

        insert accountsForInsert;

        List<R_Club_Number__c> rClubNumbersForInsert = TRUTestDataFactory.createRClubNumbers(1, accountsForInsert[0].Id);

        insert rClubNumbersForInsert;
    }

    @isTest
    private static void getStatesPicklistValuesTest() {
        List<Schema.PicklistEntry> picklistEntries = new List<PicklistEntry>(Account.PersonMailingStateCode.getDescribe().getPicklistValues());

        Test.startTest();
            Map<String, String> testResponse = RegisterCardController.getStatesPicklistValues();
        Test.stopTest();

        System.assertEquals(testResponse.values().size(), picklistEntries.size(), 'Picklist sizes Should much.');
    }

    @isTest
    private static void registerUserTest() {
        String jsonString = '{"LastName":"User Name", "PersonEmail": "test@somedomain.com", "R_Club_Number__c": "0000000000003"}';

        Test.startTest();
            Account testResponse = RegisterCardController.registerUser(JSON.deserializeUntyped(jsonString), null, true);
        Test.stopTest();

        System.assertEquals(testResponse.R_Club_Number__c, null, 'R-club number should be blank.');
    }

    @isTest
    private static void registerUserNegativeTest() {
        String rClubNumber = '0000000000002';
        List<Account> account = [SELECT Id, PersonEmail FROM Account];

        insert new R_Club_Number__c(R_Club_Number__c = rClubNumber, Account__c = account[1].Id);

        String jsonString = '{"LastName":"User Name", "PersonEmail": "' + account[0].PersonEmail + '", "R_Club_Number__c": "' + rClubNumber + '"}';
        String testResponse = '';

        Test.startTest();
            try {
                RegisterCardController.registerUser(JSON.deserializeUntyped(jsonString), null, true);
            } catch(QueryException error) {
                testResponse = error.getMessage();
            }
        Test.stopTest();

        System.assertEquals(testResponse, Label.R_Club_number_registered, 'R Club number validation error message should be equal to R_Club_number_registered');
    }

    @isTest
    private static void insertNewChildsTest() {
        Account accountData = [SELECT Id, Child_Birthday_Opt_In__c FROM Account LIMIT 1];
        accountData.Child_Birthday_Opt_In__c = true;
        String jsonString = '[{"name":"Child Name", "month":"5", "year":"2019"}]';
        Map<String, Object> mapForAssertion = (Map<String, Object>) JSON.deserializeUntyped(jsonString.removeStart('[').removeEnd(']'));

        Test.startTest();
            RegisterCardController.insertNewChilds(accountData, JSON.deserializeUntyped(jsonString));
        Test.stopTest();

        List<Child__c> testResult = [SELECT Id, Account__c, Name__c, Gender__c, Birthday__c FROM Child__c];

        System.assertNotEquals(testResult[0].Account__c, null, 'Id of saved Account should be populated.');
        System.assertEquals(testResult[0].Name__c, (String) mapForAssertion.get('name'), 'Name__c should be populated from JSON string.');
        System.assertEquals(testResult[0].Birthday__c, Date.newInstance(Integer.valueOf(mapForAssertion.get('year')), Integer.valueOf(mapForAssertion.get('month')), 1), 'Birthday__c should be populated from JSON string.');
    }

    @isTest
    private static void insertNewChildsNegativeTest() {
        Account accountData = [SELECT Id, Child_Birthday_Opt_In__c FROM Account LIMIT 1];
        Child__c existingChild = new Child__c(Account__c = accountData.Id, Name__c = 'Child Saved Name', Gender__c = 'F', Birthday__c = Date.newInstance(2018, 7, 1));
        String jsonString = '[{"name":"Child Name", "gender":"M", "month":"5", "year":"2019"}]';

        insert existingChild;

        Test.startTest();
            RegisterCardController.insertNewChilds(accountData, JSON.deserializeUntyped(jsonString));
        Test.stopTest();

        List<Child__c> testResult = [SELECT Id, Account__c, Name__c, Gender__c, Birthday__c FROM Child__c];

        System.assertEquals(testResult.size(), 1, 'New child\'s should not be inserted.');
        System.assertEquals(testResult[0].Account__c, existingChild.Account__c, 'Account__c should not be changed.');
        System.assertEquals(testResult[0].Name__c, existingChild.Name__c, 'Name__c should not be changed.');
        System.assertEquals(testResult[0].Gender__c, existingChild.Gender__c, 'Gender__c should not be changed.');
        System.assertEquals(testResult[0].Birthday__c, existingChild.Birthday__c, 'Birthday__c should not be changed.');
    }

    @isTest
    private static void createNewChildsListTest() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String jsonString = '[{"name":"Child Name", "month":"5", "year":"2019"}]';
        Map<String, Object> mapForAssertion = (Map<String, Object>) JSON.deserializeUntyped(jsonString.removeStart('[').removeEnd(']'));

        Test.startTest();
            List<Child__c> testResponse = RegisterCardController.createNewChildsList(accountId, JSON.deserializeUntyped(jsonString));
        Test.stopTest();

        System.assertNotEquals(testResponse[0].Account__c, null, 'Id of saved Account should be populated.');
        System.assertEquals(testResponse[0].Name__c, (String) mapForAssertion.get('name'), 'Name__c should be populated from JSON string.');
        System.assertEquals(testResponse[0].Birthday__c, Date.newInstance(Integer.valueOf(mapForAssertion.get('year')), Integer.valueOf(mapForAssertion.get('month')), 1), 'Birthday__c should be populated from JSON string.');
    }

    @isTest
    private static void isAccountExistTest() {
        Account oldAccount = [SELECT Id FROM Account LIMIT 1];
        oldAccount.R_Club_Number__c = '6666300000090';
        oldAccount.R_Club_Join_Date__c = Date.today();
        oldAccount.PersonEmail = 'test@somedomain.com';
        update oldAccount;

        Test.startTest();
            Account testResponse = RegisterCardController.getAccount(oldAccount.PersonEmail);
        Test.stopTest();

        System.assertEquals(testResponse.Id, oldAccount.Id, 'Id of saved Account should be returned if exist. Otherwise null.');
        System.assertEquals(testResponse.R_Club_Number__c, oldAccount.R_Club_Number__c, 'R_Club_Number__c should be returned if exist.');
        System.assertEquals(testResponse.R_Club_Join_Date__c, oldAccount.R_Club_Join_Date__c, 'R_Club_Join_Date__c should be returned if R_Club_Number__c populated.');
    }

    @isTest
    private static void isAccountExistNegativeTest() {
        Test.startTest();
            Account testResponse = RegisterCardController.getAccount('test@somedomain.com');
        Test.stopTest();

        System.assertEquals(testResponse, null, 'Saved Account should be returned if exist. Otherwise null.');
    }

    @isTest
    private static void isRClubNumberExistsTest() {
        List<Account> account = [SELECT Id, PersonEmail FROM Account];
        R_Club_Number__c rClubNumberNew = new R_Club_Number__c(R_Club_Number__c = '1000000000010', Account__c = account[1].Id);

        insert rClubNumberNew;

        Test.startTest();
        Boolean testResponse = RegisterCardController.isRClubNumberExists(new Account(R_Club_Number__c = rClubNumberNew.R_Club_Number__c, PersonEmail = account[0].PersonEmail));
        Test.stopTest();

        System.assertEquals(testResponse, true, 'R Club number should exist only for current account.');
    }

    @isTest
    private static void isRClubNumberExistsNegativeTest() {
        Test.startTest();
            Boolean testResponse = RegisterCardController.isRClubNumberExists(new Account(R_Club_Number__c = ''));
        Test.stopTest();

        System.assertEquals(testResponse, false, 'If Account not exist, R Club number not exist too.');
    }

    @isTest
    private static void isRClubNumberExistsNegative2Test() {
        R_Club_Number__c rClubNumber = [SELECT Id, R_Club_Number__c, Account__r.PersonEmail FROM R_Club_Number__c LIMIT 1];

        Test.startTest();
        Boolean testResponse = RegisterCardController.isRClubNumberExists(new Account(R_Club_Number__c = rClubNumber.R_Club_Number__c, PersonEmail = rClubNumber.Account__r.PersonEmail));
        Test.stopTest();

        System.assertEquals(testResponse, false, 'R Club number should exist only for current account.');
    }

    @isTest
    private static void getRClubNumberNewCardTest() {
        Account newAccount = new Account(
                R_Club_Number__c = '0000000000002'
        );

        Test.startTest();
            R_Club_Number__c restResponse = RegisterCardController.getRClubNumber(newAccount);
        Test.stopTest();

        Date dateForAssertion = Date.today();
        System.assertEquals(restResponse.R_Club_Number__c, restResponse.R_Club_Number__c, 'R Club number should be populated from parent Account.');
        System.assertEquals(restResponse.Loyalty_Opt_In_Date__c, dateForAssertion, 'Loyalty_Opt_In_Date__c should be populated as TODAY.');
        System.assertEquals(restResponse.Loyalty_Opt_In__c, true, 'Loyalty_Opt_In__c should be equal to true.');
    }

    @isTest
    private static void getRClubNumberExistingCardTest() {
        R_Club_Number__c existingRClubNumber = [SELECT Id, R_Club_Number__c FROM R_Club_Number__c LIMIT 1];
        Account newAccount = new Account(
                R_Club_Number__c = existingRClubNumber.R_Club_Number__c
        );

        Test.startTest();
            R_Club_Number__c restResponse = RegisterCardController.getRClubNumber(newAccount);
        Test.stopTest();

        Date dateForAssertion = Date.today();
        System.assertEquals(restResponse.Id, existingRClubNumber.Id, 'R Club number record Id should be populated from existing record.');
        System.assertEquals(restResponse.R_Club_Number__c, restResponse.R_Club_Number__c, 'R Club number should be populated from parent Account.');
        System.assertEquals(restResponse.Loyalty_Opt_In_Date__c, dateForAssertion, 'Loyalty_Opt_In_Date__c should be populated as TODAY.');
        System.assertEquals(restResponse.Loyalty_Opt_In__c, true, 'Loyalty_Opt_In__c should be equal to true.');
    }

    @isTest
    private static void getRClubNumberNewTest() {
        R_Club_Number__c existingRClubNumber = [SELECT Id, R_Club_Number__c FROM R_Club_Number__c LIMIT 1];
        Account newAccount = new Account(
                R_Club_Number__c = ''
        );

        Test.startTest();
            R_Club_Number__c restResponse = RegisterCardController.getRClubNumber(newAccount);
        Test.stopTest();

        Date dateForAssertion = Date.today();
        System.assertNotEquals(restResponse.R_Club_Number__c, null, 'R Club number should be generate if not populated.');
        System.assertEquals(restResponse.R_Club_Join_Date__c, dateForAssertion, 'R_Club_Join_Date__c should be populated as TODAY.');
        System.assertEquals(restResponse.Loyalty_Opt_In_Date__c, dateForAssertion, 'Loyalty_Opt_In_Date__c should be populated as TODAY.');
        System.assertEquals(restResponse.Loyalty_Opt_In__c, true, 'Loyalty_Opt_In__c should be equal to true.');
    }

    @isTest
    private static void populateFieldsOnConvertedDataTest() {
        Account oldAccount = [SELECT Id, R_Club_Number__c, R_Club_Join_Date__c FROM Account LIMIT 1];
        Account newAccount = new Account(
                Email_Opt_In_BRU__c = true,
                Email_Opt_In_TRU__c = true,
                Child_Birthday_Opt_In__c = true,
                R_Club_Number__c = '0000000000002'
        );

        Test.startTest();
            RegisterCardController.populateFieldsOnConvertedData(newAccount, oldAccount, true);
        Test.stopTest();

        Date dateForAssertion = Date.today();
        System.assertNotEquals(newAccount.Id, null, 'Id of saved Account should be populated in new Account instance to allow upsert operation.');
        System.assertEquals(newAccount.Email_Opt_In_Date_BRU__c, dateForAssertion, 'Email_Opt_In_Date_BRU__c should be populated as TODAY if Email_Opt_In_BRU__c is true.');
        System.assertEquals(newAccount.Email_Opt_In_Date_TRU__c, dateForAssertion, 'Email_Opt_In_Date_TRU__c should be populated as TODAY if Email_Opt_In_TRU__c is true.');
        System.assertEquals(newAccount.Child_Birthday_Email_Opt_In_Date__c, dateForAssertion, 'Child_Birthday_Email_Opt_In_Date__c should be populated as TODAY if Child_Birthday_Opt_In__c is true.');
        System.assertEquals(null, newAccount.R_Club_Number__c, 'R-club number should be blank before upsert.');
    }

    @isTest
    private static void populateFieldsOnConvertedDataNegativeTest() {
        Account newAccount = new Account();

        Test.startTest();
            RegisterCardController.populateFieldsOnConvertedData(newAccount, null, true);
        Test.stopTest();

        System.assertEquals(newAccount.Id, null, 'Id of saved Account should be populated in new Account instance to allow upsert operation.');
        System.assertEquals(newAccount.Email_Opt_In_Date_BRU__c, null, 'Email_Opt_In_Date_BRU__c should not be populated as TODAY if Email_Opt_In_BRU__c is true.');
        System.assertEquals(newAccount.Email_Opt_In_Date_TRU__c, null, 'Email_Opt_In_Date_TRU__c should not be populated as TODAY if Email_Opt_In_TRU__c is true.');
        System.assertEquals(newAccount.Child_Birthday_Email_Opt_In_Date__c, null, 'Child_Birthday_Email_Opt_In_Date__c should not be populated as TODAY if Child_Birthday_Opt_In__c is true.');
    }
}