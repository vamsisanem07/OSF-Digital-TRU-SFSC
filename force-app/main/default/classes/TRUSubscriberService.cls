/**
 * Created by i.yefremov on 23.07.2019.
 */

@RestResource(urlMapping='/Contact/ImmediateRegistration')
global with sharing class TRUSubscriberService {
    private static String DEFAULT_LAST_NAME;

    /**
    * This method allows an account (subscriber) to be located or created and returned in the response.
    * This is used in downstream marketing cloud requests to obtain a subscriber key equal to the PersonContactId on the Account.
    * @return @TRUSubscriberResponse.
    */
    @HttpPost
    global static TRUSubscriberResponse findOrCreateAccount(){
        RestRequest request = RestContext.request;
        SCCFileLogger logger = SCCFileLogger.getInstance();
        TRUSubscriberResponse response;
        system.debug('RestContext.request request body'+RestContext.request.requestBody.toString()); 
        try {
            response = handleRegistrationRequest(request, logger);
        } catch(Exception e) {
            response = handleRegistrationError(e, logger);
        }
        system.debug('response ==== '+response);
        return response;
    }

    private static TRUSubscriberResponse handleRegistrationRequest(RestRequest request, SCCFileLogger logger){
        // note that we're getting the custom settings for the subscriber so we can do field mapping config without code changes.
        Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Subscriber', logger);
        // this is the incoming request JSON that contains the subscriber (see above)
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
        system.debug('RestContext.request request body .... '+request.requestBody.toString()); 
        String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Account')
                .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'LastName'})
                .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\'')
                .getQuery();
        List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
        Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
        record.From_SFCC__pc = true;
        record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
        if(!accountList.isEmpty()) {
            initializeExistingAccount(record, accountList, logger);
        }else{
            setAdditionalFieldsForNewAccount(record, logger);
        }
        Database.upsert(record, true);
        // requery updated\created record because it does not return ContactId after inserting personal Account
        record = requeryAccountWithAdditionalInfo(record.Id);
        // schedule it for future update (runs in SCCAccountImpl)
        synchronizeWithCommerceCloud(record);
        return TRUSubscriberResponse.createResponse(record);
    }

    private static void initializeExistingAccount(Account record, List<Account> accountList, SCCFileLogger logger){
        logger.debug('TRUSubscriberService.findOrCreateSubscriber', 'Updating existing account: '+accountList);
        record.Id = accountList[0].Id;
        record.Contact_Status__pc  = 'Updated';
        record.SFCC_update__c = true;
        if(String.isBlank(record.LastName)){
            record.LastName = accountList[0].LastName;
        }
    }

    private static void setAdditionalFieldsForNewAccount(Account record, SCCFileLogger logger){
        logger.debug('TRUSubscriberService.findOrCreateSubscriber', 'Creating new account');
        RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
        record.RecordTypeId = recordType.Id;
        record.Contact_Status__pc  = 'Created';
        setLastNameIfEmpty(record);
    }

    private static void setLastNameIfEmpty(Account record){
        if(String.isBlank(record.LastName)){
            record.LastName = getDefaultLastName();
        }
    }

    private static String getDefaultLastName(){
        if(String.isBlank(DEFAULT_LAST_NAME)){
            DEFAULT_LAST_NAME = TRU_Subscriber_Config__c.getInstance().Default_Last_Name__c;
        }
        return DEFAULT_LAST_NAME;
    }

    private static Account requeryAccountWithAdditionalInfo(Id accountId){
        String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Account')
                .setRelatedFields(new Set<String>{'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc', 'PersonContactId'})
                .setClause('Id = \'' + accountId + '\'')
                .getQuery();
        List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
        return accountList[0];
    }

    private static TRUSubscriberResponse handleRegistrationError(Exception e, SCCFileLogger logger){
        RestContext.response.statusCode = 500;
        logger.error('TRUSubscriberService.findOrCreateAccount', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        return TRUSubscriberResponse.createError(e);
    }

    private static void synchronizeWithCommerceCloud(Account record){
        if(record.SFCC_Customer_Id__pc != null || record.SFCC_Customer_Number__pc != null){
            SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);
        }
    }
}