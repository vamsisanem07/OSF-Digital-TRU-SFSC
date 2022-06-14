/**
* Rest Service class for get/post case informations' details(Contact us/Service Request)
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-03
*/
@RestResource(urlMapping='/Case/*')
global with sharing class SCCCustomerCaseMgmtService  {

    /**
    * This is the method using on "GET" requests.
    * @return List<Case>.
    */
    @HttpGet
    global static List<Case> show() {
        Id recordId = RestContext.request.requestURI.replace('/Case/', '');
        String objectName = recordId.getSobjectType().getDescribe().getName();
        List<Case> returnList = new List<Case>();
        if(objectName == 'Contact') {
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Case')
                    .setRelatedFields(new Set<String>{'Id', 'Subject', 'Status', 'LastModifiedDate'})
                    .setClause('ContactId = \'' + recordId + '\'')
                    .getQuery();
            returnList = (List<Case>)SCCQueryUtilClass.getRecords(query);
        } else if(objectName == 'Account') {
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Case')
                    .setAllFields()
                    .setClause('AccountId = \'' + recordId + '\'')
                    .getQuery();
            returnList = (List<Case>) SCCQueryUtilClass.getRecords(query);
        } else if(objectName == 'Case') {
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Case')
                    .setAllFields()
                    .setClause('Id = \'' + recordId + '\'')
                    .getQuery();
            returnList = (List<Case>)SCCQueryUtilClass.getRecords(query);
        }
        return returnList;
    }

    /**
    * This is the method using on "POST" requests.
    * @return SCCReturnResponse.
    */
    @HttpPost
    global static SCCReturnResponse create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        logger.debug('SCCCustomerCaseMgmtService.create', 'calling create()');
        try {
            Map<String, SObject> caseFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Case', logger);
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            Case record = (Case)SCCUtilityClass.initializeObject(jsonMap, 'Case', caseFieldMappings, logger);
            record.Not_Manual__c = true;
            record.SuppliedName = '';
            
            // This will populate SuppliedName with the first_name from the website
            if(jsonMap.containsKey('first_name') && jsonMap.get('first_name') != null && jsonMap.get('first_name') instanceOf String){
                record.SuppliedName = (String)jsonMap.get('first_name') + ' ';
            }
            
            // This will populate SuppliedName with the last_name from the website
            if(jsonMap.containsKey('last_name') && jsonMap.get('last_name') != null && jsonMap.get('last_name') instanceOf String){
                record.SuppliedName += (String)jsonMap.get('last_name');
            }
            
            if(jsonMap.containsKey('contact_id') && String.isNotBlank((String)jsonMap.get('contact_id'))) {
                logger.debug('SCCCustomerCaseMgmtService.create', 'Registered customer case');
                String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Account')
                    .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                    .setClause('Id = \'' + (String)jsonMap.get('contact_id') + '\'')
                    .getQuery();
                List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                if(!accountList.isEmpty()) {
                    record.AccountId = accountList[0].Id;
                    Database.insert(record, true);
                    return SCCReturnResponse.createResponse(record.Id);
                } else {
                    logger.debug('SCCCustomerCaseMgmtService.create', 'Provided contact_id is invalid: '+jsonMap.containsKey('contact_id'));
                    if(jsonMap.containsKey('email')) {
                        query = SCCQueryUtilClass.getInstance()
                            .getQueryInstance()
                            .setObjectName('Account')
                            .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                            .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\'')
                            .getQuery();
                        accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                        if(!accountList.isEmpty()) {
                            record.AccountId = accountList[0].Id;
                            Database.insert(record, true);
                            return SCCReturnResponse.createResponse(record.Id);
                        }else{
                            Account acc = createAccount(jsonMap);
                            record.AccountId = acc.Id;
                            Database.insert(record, true);
                            return SCCReturnResponse.createResponse(record.Id);
                        }
                    }else{
                        throw new SObjectException('Mandatory field email is missing and provided salesforce contact_id is invalid');
                    }
                }
            }else{
                logger.debug('SCCCustomerCaseMgmtService.create', 'Guest customer case');
                if(jsonMap.containsKey('email')) {
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Account')
                        .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                        .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\'')
                        .getQuery();
                    List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                    if(!accountList.isEmpty()) {
                        record.AccountId = accountList[0].Id;
                        Database.insert(record, true);
                        return SCCReturnResponse.createResponse(record.Id);
                    }else{
                        Account acc = createAccount(jsonMap);                        
                        record.AccountId = acc.Id;
                        Database.insert(record, true);
                        return SCCReturnResponse.createResponse(record.Id);
                    }
                }else{
                    throw new SObjectException('Mandatory field email is missing');
                }
            }
        } catch(Exception e) {
            logger.error('SCCCustomerCaseMgmtService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            RestContext.response.statusCode = 500;
            return SCCReturnResponse.createError(e);
        }finally{
            logger.flush();
        }

    }

    /**
    * This method creates new Account usign provided email id.
    * @return Account.
    */
    static Account createAccount(Map<String, Object> jsonMap){
        Account record = New Account();
        record.PersonEmail = (String)jsonMap.get('email');
        record.Language_Preference__c = (String)jsonMap.get('language');
        RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
        record.RecordTypeId = recordType.Id;
        record.FirstName = (String)jsonMap.get('first_name');
        String lastName = (String)jsonMap.get('last_name');
        if(String.isEmpty(lastName)){
            lastName = (String)jsonMap.get('first_name');
        }
        record.LastName = lastName;
        record.Contact_Status__pc  = 'Created';
        Database.insert(record, true);
        return record;
    }
}