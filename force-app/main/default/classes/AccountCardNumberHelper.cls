public with sharing class AccountCardNumberHelper {
    public static Rclub_Number_Settings__c settings;
    public static Date today;

    private static final String LANGUAGE_PREFERENCE_EN = 'EN';
    private static final String LANGUAGE_PREFERENCE_FR = 'FR';

    static {
        settings = Rclub_Number_Settings__c.getOrgDefaults();
        today = Date.today();
    }

    /**
    * This method used for generating single R-club number on one account.
    * @param account Account
    * @return String
    */
    public static String generateClcNumberSingleGeneral(Account account){
        String cardNumber = generateCardNumber(account);
        String cardNumberWithChecksum = cardNumber + Luhn.generateChecksum(cardNumber);

        ++settings.Number__c;
        update settings;

        return cardNumberWithChecksum;
    }

    /**
    * This method used for generating R-club numbers in account Account list.
    * @param newSObjects List<Account>
    * @return none.
    */
    public static void generateClcNumberGeneral(List<Account> newSObjects){
        generateClcNumber(newSObjects);

        update settings;
    }

    @TestVisible
    private static void generateClcNumber(List<Account> newSObjects){
        for (Account newAccount : newSObjects){
            if (newAccount.R_Club_Number__c == null || newAccount.R_Club_Number__c.isWhitespace()) {
                String cardNumber = generateCardNumber(newAccount);
                newAccount.R_Club_Number__c = cardNumber + Luhn.generateChecksum(cardNumber);
                newAccount.R_Club_Join_Date__c = today;
                ++settings.Number__c;
            }
        }
    }

    @TestVisible
    private static String generateCardNumber(Account newAccount){
        return String.valueOf(settings.IIN__c.round()) + generateCardType(newAccount) + String.valueOf(settings.Number__c.round()).leftPad(7, '0');
    }

    @TestVisible
    private static String generateCardType(Account newAccount){
        if (newAccount.Language_Preference__c == LANGUAGE_PREFERENCE_EN) {
            return String.valueOf(settings.Online_English__c.round());
        } else if (newAccount.Language_Preference__c == LANGUAGE_PREFERENCE_FR) {
            return String.valueOf(settings.Online_French__c.round());
        }

        return '0';
    }
}