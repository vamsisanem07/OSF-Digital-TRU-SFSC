/**
* Rest Service class for post contact informations' details => Customer Registration
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02 
*/
@RestResource(urlMapping='/Contact/Registration/*')
global with sharing class SCCCustomerRegistrationService {

    /**
    * This is the method using on "GET" requests.
    * @return List<Account>.
    */
    @HttpGet
    global static List<Account> show() {
        Id recordId = RestContext.request.requestURI.replace('/Contact/Registration/', '');
        List<Account> returnList = new List<Account>();
        String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Account')
                .setAllFields()
                .setClause('Id = \'' + recordId + '\'')
                .getQuery();
        returnList = (List<Account>)SCCQueryUtilClass.getRecords(query);
        return returnList;
    }

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */
    @HttpPost
    global static SCCCustomerRegResponse create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCustomerRegResponse response;
        try{
            if(SCCUtilityClass.isPersonAccountEnabled()){
                response = createAccountRecord(RestContext.request, logger);
            }else{
                response = createContactRecord(RestContext.request, logger);
            }            
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        }finally{
            logger.flush();
        }
        return response;
    }
    
    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */    
    static SCCCustomerRegResponse createAccountRecord(RestRequest request, SCCFileLogger logger){
        try {
            SCCCommerceCloudConnect.logger = logger;
            Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
			String query = SCCQueryUtilClass.getInstance()
									      .getQueryInstance()
										  .setObjectName('Account')
										  .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'LastName', 'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc'})
                                          .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\' OR (SFCC_Customer_Id__pc = \'' + (String)jsonMap.get('customer_id') + '\' AND SFCC_Customer_Number__pc = \'' + (String)jsonMap.get('customer_no') + '\')')
										  .getQuery();
			List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
            Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
            record.From_SFCC__pc = true;
            record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
            if(!accountList.isEmpty()) {
                logger.debug('SCCCustomerRegistrationService.createAccountRecord', 'Updating existing account: '+accountList);
                record.Id = accountList[0].Id;
                record.Contact_Status__pc  = 'Updated';
                record.SFCC_update__c = true;
            }else{
                logger.debug('SCCCustomerRegistrationService.createAccountRecord', 'Creating new account');
                RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account'); 
                record.RecordTypeId = recordType.Id;
                record.Contact_Status__pc  = 'Created';
            }
            Database.upsert(record, true);
            //SCCCommerceCloudConnect.scheduleIt(record.Id);
            SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);

            String requery = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Account')
                    .setRelatedFields(SCCUtilityClass.getFieldsForQueryFromCustomSetting(fieldMappings))
                    .setClause('Id = \'' + record.Id + '\'')
                    .getQuery();
            List<Account> accList = (List<Account>)SCCQueryUtilClass.getRecords(requery);

            record = accList[0];

            return SCCCustomerRegResponse.createResponse(record, fieldMappings);
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationService.createAccountRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return SCCCustomerRegResponse.createError(e);
        }    	
    }
    
    public static SCCCustomerRegResponse createContactRecord(RestRequest request, SCCFileLogger logger){
        try {
            SCCCommerceCloudConnect.logger = logger;
            Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Contact', logger); 
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
			String query = SCCQueryUtilClass.getInstance()
									      .getQueryInstance()
										  .setObjectName('Contact')
										  .setRelatedFields(new Set<String>{'Id', 'Email'})
										  .setClause('Email = \'' + (String)jsonMap.get('email') + '\'')
										  .getQuery();
			List<Contact> contactList = (List<Contact>)SCCQueryUtilClass.getRecords(query);
            Contact record = (Contact)SCCUtilityClass.initializeObject(jsonMap, 'Contact', fieldMappings, logger);
            record.From_SFCC__c = true;
            record = SCCUtilityClass.additionalFieldsforContact(record, jsonMap);
            if(!contactList.isEmpty()) {
                logger.debug('SCCCustomerRegistrationService.createContactRecord', 'Updating existing contact: '+contactList);
                record.Id = contactList[0].Id;
                record.Contact_Status__c  = 'Updated';
            }else{
                logger.debug('SCCCustomerRegistrationService.createContactRecord', 'Creating new contact');
                record.Contact_Status__c  = 'Created';
            }
            Database.upsert(record, true);
            SCCCommerceCloudConnect.scheduleIt(record.Id);
            return SCCCustomerRegResponse.createResponse(record);
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationService.createContactRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return SCCCustomerRegResponse.createError(e);
        }
    }
}