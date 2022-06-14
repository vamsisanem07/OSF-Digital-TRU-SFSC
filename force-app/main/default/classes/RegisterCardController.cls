public without sharing class RegisterCardController {

    private static Id personAccountRecordTypeId;

    private static final String PERSON_ACCOUNT_RECORD_TYPE = 'Person Account';

    static {
        personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PERSON_ACCOUNT_RECORD_TYPE).getRecordTypeId();
    }

    /**
    * This method used for quering State picklist values.
    * @return Map<String, String>.
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getStatesPicklistValues() {
        Map<String, String> options = new Map<String, String>();

        Schema.DescribeFieldResult fieldResult = Account.PersonMailingStateCode.getDescribe();

        for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            options.put(f.getLabel(), f.getValue());
        }

        return options;
    }

    /**
    * This method used for upserting Account with related records(Child__c) if needed. Upsert based on email address.
    * @param userData Object
    * @param childData Object
    * @param newCard Boolean
    * @return Account.
    */
    @AuraEnabled
    public static Account registerUser(Object userData, Object childData, Boolean newCard) {
        Account convertedUserData = (Account) JSON.deserialize(JSON.serialize(userData), Account.class);
        Account account = getAccount((String) convertedUserData.PersonEmail);
        system.debug('convertedUserData'+convertedUserData);
        system.debug('account'+account);

        if (!isRClubNumberExists(convertedUserData)) {
            R_Club_Number__c rClubNumber = getRClubNumber(convertedUserData);

            populateFieldsOnConvertedData(convertedUserData, account, newCard);

            upsert convertedUserData;

            insertNewRClubNumber(convertedUserData, rClubNumber);
            insertNewChilds(convertedUserData, childData);

            return convertedUserData;
        } else {

            System.debug(account);
            System.debug(convertedUserData.R_Club_Number__c);

            QueryException qe = new QueryException();
            qe.setMessage(Label.R_Club_number_registered);
            throw qe;
        }
    }

    @TestVisible
    private static void insertNewRClubNumber(Account account, R_Club_Number__c rClubNumber) {
        if (account.Id != null) {
            rClubNumber.Account__c = account.Id;

            upsert rClubNumber;
        }
    }

    @TestVisible
    private static void insertNewChilds(Account account, Object child) {
        if (account.Child_Birthday_Opt_In__c) {
            delete [SELECT Id FROM Child__c WHERE Account__c = :account.Id];

            insert createNewChildsList(account.Id, child);
        }
    }

    @TestVisible
    private static List<Child__c> createNewChildsList(Id accountId, Object childData) {
        List<Child__c> childsForInsert = new List<Child__c>();

        for (Object child : (List<Object>) JSON.deserializeUntyped(JSON.serialize(childData))) {
            Map<String, Object> convertedChild = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(child));

            childsForInsert.add(new Child__c(
                    Account__c = accountId,
                    Name__c = (String) convertedChild.get('name'),
                    Birthday__c = Date.newInstance(Integer.valueOf(convertedChild.get('year')), Integer.valueOf(convertedChild.get('month')), 1)
            ));
        }

        return childsForInsert;
    }

    @TestVisible
    private static Account getAccount(String email) {
        List<Account> accountList = [SELECT Id, R_Club_Number__c, R_Club_Join_Date__c FROM Account WHERE PersonEmail = :email AND IsPersonAccount = true LIMIT 1];

        if (accountList.size() > 0) {
            return accountList[0];
        }

        return null;
    }

    @TestVisible
    private static Boolean isRClubNumberExists(Account account) {
        if (account.R_Club_Number__c != null && !account.R_Club_Number__c.isWhitespace()) {
            List<R_Club_Number__c> rClubNumberList = [SELECT Id, R_Club_Number__c, Account__c FROM R_Club_Number__c WHERE R_Club_Number__c = :account.R_Club_Number__c AND Account__r.PersonEmail != :account.PersonEmail LIMIT 1];

            if (rClubNumberList.size() > 0) {
                return true;
            }
        }

        return false;
    }

    @TestVisible
    private static R_Club_Number__c getRClubNumber(Account account) {
        Date today = Date.today();
        R_Club_Number__c newCard = new R_Club_Number__c();

        if (account.R_Club_Number__c != null && !account.R_Club_Number__c.isWhitespace()) {
            List<R_Club_Number__c> rClubNumberList = [SELECT Id, R_Club_Join_Date__c FROM R_Club_Number__c WHERE R_Club_Number__c = :account.R_Club_Number__c LIMIT 1];

            if (rClubNumberList.size() > 0) {
                newCard = rClubNumberList[0];
            }

            newCard.R_Club_Number__c = account.R_Club_Number__c;
        } else {
            newCard.R_Club_Number__c = AccountCardNumberHelper.generateClcNumberSingleGeneral(account);
        }

        if (newCard.R_Club_Join_Date__c == null) {
            newCard.R_Club_Join_Date__c = today;
        }
        newCard.Loyalty_Opt_In__c = true;
        newCard.Loyalty_Opt_In_Date__c = today;

        return newCard;
    }

    @TestVisible
    private static void populateFieldsOnConvertedData(Account newAccount, Account oldAccount, Boolean newCard) {
        Date today = Date.today();
        newAccount.Loyalty_Opt_In__c = true;
        newAccount.R_Club_Number__c = null;

        if (oldAccount != null) {
            newAccount.Id = oldAccount.Id;
        }
        if (newAccount.RecordTypeId == null) {
            newAccount.RecordTypeId = personAccountRecordTypeId;
        }
        if (newAccount.Child_Birthday_Opt_In__c) {
            newAccount.Child_Birthday_Email_Opt_In_Date__c = today;
        }
        if (newAccount.Email_Opt_In_BRU__c) {
            newAccount.Email_Opt_In_Date_BRU__c = today;
            if(newCard){
                newAccount.Email_Opt_In_BRU_Source__c = 'R Club - In-Store Signup';  
            }else{
                newAccount.Email_Opt_In_BRU_Source__c = 'R Club - Online Registration';
            }
        }
        if (newAccount.Email_Opt_In_TRU__c) {
            newAccount.Email_Opt_In_Date_TRU__c = today;
            if(newCard){
                newAccount.Email_Opt_In_TRU_Source__c = 'R Club - In-Store Signup';  
            }else{
                newAccount.Email_Opt_In_TRU_Source__c = 'R Club - Online Registration';
            }
        }
        if (newAccount.Email_Opt_In_RLE__c) {
            newAccount.Email_Opt_In_Date_RLE__c = today;
            if(newCard){
                newAccount.Email_Opt_in_RLE_Source__c = 'R Club - In-Store Signup';  
            }else{
               newAccount.Email_Opt_in_RLE_Source__c = 'R Club - Online Registration';
            }
        }
    }
}