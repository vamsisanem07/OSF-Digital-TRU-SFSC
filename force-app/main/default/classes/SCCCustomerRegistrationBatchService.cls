/**
* Rest Service class for post contact informations' details => Customer Registration
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02 
*/
@RestResource(urlMapping='/Contact/Registration/Batch/*')
global with sharing class SCCCustomerRegistrationBatchService {

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */
    @HttpPost
    global static List<SCCCustomerRegResponse> create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerRegResponse> response;
        try{
            if(SCCUtilityClass.isPersonAccountEnabled()){
                response = createAccountRecord(RestContext.request, logger);
            }else{
                response = createContactRecord(RestContext.request, logger);
            }            
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationBatchService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			response = new List<SCCCustomerRegResponse>();
            response.add(SCCCustomerRegResponse.createError(e));
            return response;            
        }finally{
            logger.flush();
        }
        return response;
    }
    
    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */    
    static List<SCCCustomerRegResponse> createAccountRecord(RestRequest request, SCCFileLogger logger){
        SCCCommerceCloudConnect.logger = logger;
        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>();  
        List<Id> recordIds = new List<Id>();
        Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);
        try {
            List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
            for (Object jsonData : jsonDataList)
            {
                Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
                try	{
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
                        logger.debug('SCCCustomerRegistrationBatchService.createAccountRecord', 'Updating existing account: '+record);
                        record.Id = accountList[0].Id;
                        record.Contact_Status__pc  = 'Updated';
                        record.SFCC_update__c = true;
                    }else{
                        logger.debug('SCCCustomerRegistrationBatchService.createAccountRecord', 'Creating new account: '+ record);
                        RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account'); 
                        record.RecordTypeId = recordType.Id;
                        record.Contact_Status__pc  = 'Created';
                    }
                    Database.upsert(record, true);

                    recordIds.add(record.Id);
                    //respList.add(SCCCustomerRegResponse.createResponse(record));
                } catch(Exception e) {
                    logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    respList.add(SCCCustomerRegResponse.createError((String)jsonMap.get('customer_no'), e));               
                }
           	}

            if (recordIds.size() > 0) {
                String requery = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Account')
                        .setRelatedFields(SCCUtilityClass.getFieldsForQueryFromCustomSetting(fieldMappings))
                        .setClause('Id IN (\'' + String.join(recordIds, '\',\'') + '\')')
                        .getQuery();
                for (Account acc : (List<Account>)SCCQueryUtilClass.getRecords(requery)) {
                    respList.add(SCCCustomerRegResponse.createResponse(acc, fieldMappings));
                }
            }

            SCCCommerceCloudConnect.synchroniseObjectFutureBatch(recordIds);
            return respList;
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            respList.add(SCCCustomerRegResponse.createError(e));
            return respList;
        }    	
    }
    
    public static List<SCCCustomerRegResponse> createContactRecord(RestRequest request, SCCFileLogger logger){
        SCCCommerceCloudConnect.logger = logger;
        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>(); 
        Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Contact', logger);
        try {
            List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
            for (Object jsonData : jsonDataList)
            {
                try {
                    Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
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
                        logger.debug('SCCCustomerRegistrationBatchService.createContactRecord', 'Updating existing contact: '+contactList);
                        record.Id = contactList[0].Id;
                        record.Contact_Status__c  = 'Updated';
                    }else{
                        logger.debug('SCCCustomerRegistrationBatchService.createContactRecord', 'Creating new contact');
                        record.Contact_Status__c  = 'Created';
                    }
                    Database.upsert(record, true);
                    SCCCommerceCloudConnect.scheduleIt(record.Id);
                    respList.add(SCCCustomerRegResponse.createResponse(record));
                } catch(Exception e) {
                    logger.error('SCCCustomerRegistrationBatchService.createContactRecord', 'Exception message : '
                                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    respList.add(SCCCustomerRegResponse.createError(e));               
                }
            }
            return respList;
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationBatchService.createContactRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            respList.add(SCCCustomerRegResponse.createError(e));
            return respList;
        }
    }
}