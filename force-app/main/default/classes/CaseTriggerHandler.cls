public with sharing class CaseTriggerHandler {

    private static Map<String, Id> recordTypesMap = null;
    private static Map<String, Store__c> storesMap = new Map<String, Store__c>();
    private static final String IN_STORE_REASON_FR = 'En Magasin';
    private static final String IN_STORE_RECORD_TYPE = 'In Store Case';
    private static final String IN_STORE_REASON = 'In Store';
    private static final String CONTACT_US = 'Contact Us';
    private static final String CONTACT_US_FR = 'Ramassage de commande';
    private static final String PRICE_MATCH = 'Price Adjustment';
    private static final String PRICE_MATCH_FR = 'Ajustement de prix';
    private static final String WAITING_ON_SUPPORT_KIT_STATUS = 'Waiting on Support';

    static {
        recordTypesMap = new Map<String, Id>();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        
        if(recordTypeMap.get(IN_STORE_RECORD_TYPE) != null){
            recordTypesMap.put(IN_STORE_REASON, recordTypeMap.get(IN_STORE_RECORD_TYPE).getRecordTypeId());
            recordTypesMap.put(IN_STORE_REASON_FR, recordTypeMap.get(IN_STORE_RECORD_TYPE).getRecordTypeId());
        }
        
        if(recordTypeMap.get(CONTACT_US) != null){        
            recordTypesMap.put(CONTACT_US, recordTypeMap.get(CONTACT_US).getRecordTypeId());
            recordTypesMap.put(CONTACT_US_FR, recordTypeMap.get(CONTACT_US).getRecordTypeId());
        }
        
        if(recordTypeMap.get(PRICE_MATCH) != null){  
            recordTypesMap.put(PRICE_MATCH, recordTypeMap.get(PRICE_MATCH).getRecordTypeId());
            recordTypesMap.put(PRICE_MATCH_FR, recordTypeMap.get(PRICE_MATCH).getRecordTypeId());
        }
    }

    public static void onBeforeInsert(List<Case> cases) {
        //KeyTreeNotificationsHelper.sendKeyTreeNotification(cases);
        setCaseRecordTypeAccordingToCaseReason(cases);
        
        // When the Account is populated on the case, its related Person contact also needs to get populated.
        populatePersonContactOnCase(cases);
    }
    
    /*
        @Purpose    : When the case is created through commerce cloud, 
                      Account is populated on the case, its related contact also needs to get populated.
    */
    public static void populatePersonContactOnCase(List<Case> cases) {
        Set<Id> accountIdsSet = new Set<Id>();
        List<Account> accountsList = new List<Account>();
        Map<Id, Id> accountContactIdsMap = new Map<Id, Id>();
        
        for(Case caseRecord : cases){
            accountIdsSet.add(caseRecord.AccountId);
        }
        
        try{
            accountsList = [SELECT PersonContactId FROM Account WHERE Id IN: accountIdsSet];
        }
        catch(Exception e){
            System.debug('Exception in fetching account information : ' + e.getMessage());
        }
        
        for(Account account : accountsList){
            accountContactIdsMap.put(account.Id, account.PersonContactId);
        }
        
        for(Case caseRecord : cases){
            if(accountContactIdsMap.containsKey(caseRecord.AccountId)){
                caseRecord.ContactId = accountContactIdsMap.get(caseRecord.AccountId);
            }
        }
    }
    /************************************************************************************************
     * @Name           : before trigger handler
     * @Description    : set person account on case creation
     * @Created By     : Roxana Ivan   
     * @Created Date   : Oct 10, 2021
     *************************************************************************************************/
    public static void handleCasePersonLink(Case newCase) {
        //System.debug('handleCasePersonLink');
        if (String.isNotBlank(newCase.Origin) && (newCase.Origin.toLowercase() == 'email') && newCase.SuppliedEmail != null && newCase.AccountId == null) {

            List<Account> existingAccounts = new List<Account> ();
            existingAccounts = [SELECT Id, PersonEmail, PersonContactId FROM Account WHERE IsPersonAccount = true and PersonEmail = :newCase.SuppliedEmail];
            
            if (existingAccounts.size() == 1) {
                newCase.ContactId = existingAccounts[0].PersonContactId;
                newCase.AccountId = existingAccounts[0].Id;
            }
            if (existingAccounts.size() == 0) {
                //System.debug('from case trigger');

                String lastname;
                String firstname = '';
                if (newCase.SuppliedName != null) {
                    lastname = newCase.SuppliedName;
                    if (newCase.SuppliedName.contains(' ')) {
                        lastname = newCase.SuppliedName.substring(newCase.SuppliedName.lastIndexOf(' '));
                        firstname = newCase.SuppliedName.left(newCase.SuppliedName.lastIndexOf(' '));
                    }
                } else {
                    lastname = newCase.SuppliedEmail;
                }
                    Account acc = new Account(Lastname = lastname,
                                              FirstName = firstname,
                                              PersonEmail = newCase.SuppliedEmail,
                                              Phone = newCase.SuppliedPhone
                                              );

                    insert acc;
                    Id accId = acc.Id;
                    acc = [SELECT ID, PersonContactId FROM Account WHERE Id = :accId];
                    newCase.ContactId = acc.PersonContactId;
                    newCase.AccountId = acc.Id;
            }
            
        }
    }
    /**
    * This method set Case RecordType according to Case Reason.
    * @param cases: List<Case>
    * @return None.
    */
    private static void setCaseRecordTypeAccordingToCaseReason(List<Case> cases) {
        Set<String> keyTreeStoreIds = new Set<String>();

        for (Case caseRecord : cases) {
            if (String.isNotBlank(caseRecord.Store_ID__c)) {
                keyTreeStoreIds.add(caseRecord.Store_ID__c);
            }
        }

        List<Store__c> stores = [SELECT ID, Keytree_ID__c, Store_Hours__c from Store__c WHERE Keytree_ID__c IN :keyTreeStoreIds];

        if (!stores.isEmpty()) {
            for (Store__c store : stores) {
                storesMap.put(store.Keytree_ID__c, store);
            }
        }
        
        for (Case caseRecord : cases) {
            if (String.isNotBlank(caseRecord.Reason)) {
                if(recordTypesMap.get(caseRecord.Reason) != null) {
                    caseRecord.RecordTypeId = recordTypesMap.get(caseRecord.Reason);
                } else {
                    caseRecord.RecordTypeId = recordTypesMap.get(CONTACT_US);
                }
            }

            if (caseRecord.Reason == IN_STORE_REASON) {
                setStoreInfo(caseRecord);
            }
        }
    }

    /**
    * This method set Case Store lookup field according to Case StoreId field.
    * If Store with such Keytree Id is not present then Case KIT_Status__c field value set to 'Waiting on Support'
    * @param cases: List<Case>
    * @return None.
    */
    private static void setStoreInfo(Case caseRecord) {
        if (!storesMap.isEmpty() && String.isNotBlank(caseRecord.Store_ID__c) && storesMap.get(caseRecord.Store_ID__c) != null) {
            Store__c store = storesMap.get(caseRecord.Store_ID__c);
            caseRecord.Store__c = store.Id;
            caseRecord.BusinessHoursId = store.Store_Hours__c;
        } else {
            caseRecord.KIT_Status__c = WAITING_ON_SUPPORT_KIT_STATUS;
        }
    }
}