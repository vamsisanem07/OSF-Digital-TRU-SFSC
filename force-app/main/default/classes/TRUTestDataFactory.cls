/**
 * Created by i.yefremov on 25.07.2019.
 */

@isTest
public class  TRUTestDataFactory {

    public static void createTruSubscriberCustomSetting(){
        TRU_Subscriber_Config__c configRecord = new TRU_Subscriber_Config__c();
        configRecord.Default_Last_Name__c = 'Customer';
        insert configRecord;
    }

    public static List<Account> createAndInsertAccounts(Integer length, String language){
        List<Account> accList = createAccounts(length, language);

        insert accList;

        return accList;
    }

    public static List<Account> createAccounts(Integer length, String language){
        List<Account> accList = new List<Account>();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        for (Integer i = 0; i < length; ++i){
            accList.add(new Account(
                    LastName = 'Test Account ' + (i + 1),
                    PersonEmail = 'testemail' + (i + 1) + '@test.mail',
                    Language_Preference__c = language,
                    RecordTypeId = rtId
            ));
        }

        return accList;
    }

    public static List<R_Club_Number__c> createRClubNumbers(Integer length, Id accountId){
        List<R_Club_Number__c> rClubNumberList = new List<R_Club_Number__c>();

        for (Integer i = 0; i < length; ++i){
            String rClubNumber = String.valueOf(length).leftPad(13, '0');

            rClubNumberList.add(new R_Club_Number__c(
                    R_Club_Number__c = rClubNumber,
                    Account__c = accountId
            ));
        }

        return rClubNumberList;
    }

    public static void createRclubNumberSettingsCustomSetting(){
        Rclub_Number_Settings__c setting = Rclub_Number_Settings__c.getOrgDefaults();
        setting.Number__c = 9;
        setting.Online_English__c = 3.0;
        setting.Online_French__c = 4.0;
        setting.IIN__c = 6666;
        insert setting;
    }


    public static void createOptInDatesMappingCustomSetting(){
        List<TRU_Opt_In_Dates_Mapping__c> setting = new List<TRU_Opt_In_Dates_Mapping__c>();
        setting.add(new TRU_Opt_In_Dates_Mapping__c(Name = 'Email_Opt_In_BRU__c', Opt_In_Date_field__c = 'Email_Opt_In_Date_BRU__c'));
        setting.add(new TRU_Opt_In_Dates_Mapping__c(Name = 'Email_Opt_In_TRU__c', Opt_In_Date_field__c = 'Email_Opt_In_Date_TRU__c'));
        setting.add(new TRU_Opt_In_Dates_Mapping__c(Name = 'Loyalty_Opt_In__c', Opt_In_Date_field__c = 'Loyalty_Opt_In_Date__c'));
        setting.add(new TRU_Opt_In_Dates_Mapping__c(Name = 'Child_Birthday_Opt_In__c', Opt_In_Date_field__c = 'Child_Birthday_Email_Opt_In_Date__c'));
        insert setting;
    }
}