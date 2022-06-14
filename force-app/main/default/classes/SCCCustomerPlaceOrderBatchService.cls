/**
* Rest Service class for post order informations' details => Customer Place Order
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02 
*/
@RestResource(urlMapping='/Order/Placement/Batch/*')
global with sharing class SCCCustomerPlaceOrderBatchService {

    /**
    * This is the method using on "POST" requests.
    * @return SCCCustomerOrderResponse.
    */
    @HttpPost
    global static List<SCCCustomerOrderResponse> create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerOrderResponse> response;
        Sobject sobj;
        try{
            system.debug('RestContext.request.requestBody.toString() === '+RestContext.request.requestBody.toString());
            List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());
			Map<String, Object> jsonMap = (Map<String, Object>)jsonDataList[0];
          
            if(!String.isEmpty((String)jsonMap.get('crmcontact_id'))){
 				sobj = SCCUtilityClass.getSojectByRefId((String)jsonMap.get('crmcontact_id'));     
            }
            system.debug('sobj === '+sobj);
            system.debug('sobj Person Account=== '+SCCUtilityClass.isPersonAccountEnabled());
            if(SCCUtilityClass.isPersonAccountEnabled()
               && (sobj instanceof Account || sobj == null)){
                logger.debug('SCCCustomerPlaceOrderService.create', 'Person account enabled. Creating account order: '+sobj);
                response = createAccountOrderRecord(RestContext.request, logger);
            }else if(!SCCUtilityClass.isPersonAccountEnabled() 
               && (sobj instanceof Contact || sobj == null)){
                logger.debug('SCCCustomerPlaceOrderService.create', 'Person account disabled. Creating contact order: '+sobj);
                response = createContactOrderRecord(RestContext.request, logger);
        	}else{
                logger.debug('SCCCustomerPlaceOrderService.create', 'Supplied data in incorrect. Doesnt support move contact to person account or vice versa');                
                throw new SObjectException('Invalid data, Is PersonAccount Enabled: '+ SCCUtilityClass.isPersonAccountEnabled());
            }            
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			response = new List<SCCCustomerOrderResponse>();
            response.add(SCCCustomerOrderResponse.createError(e));
            return response;
        }finally{
            logger.flush();
        }
        return response;
    }
    
    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerOrderResponse.
    */    
    static List<SCCCustomerOrderResponse> createAccountOrderRecord(RestRequest request, SCCFileLogger logger){
        SCCCommerceCloudConnect.logger = logger;
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();              
        Account defaultAccount = SCCUtilityClass.getDefaultAccount();
        system.debug('Default Account'+defaultAccount);
        if(defaultAccount == NULL){
	        	respList.add(SCCCustomerOrderResponse.createDefaultAccountError());
	        	logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', Label.SCC_Missing_Default_Account);
	        	return respList;
	    }
        Map<String, SObject> orderfieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);  
        List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
        
        for (Object jsonData : jsonDataList){
            Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
            try	{
                if(jsonMap.containsKey('order_no')) {
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Order')
                        .setRelatedFields(new Set<String>{'Id', 'AccountId', 'Name', 'OrderNumber', 'SFCC_Order_Number__c'})
                        .setClause('SFCC_Order_Number__c = \'' + (String)jsonMap.get('order_no') + '\'')
                        .getQuery();
                    List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query); 
                    Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, 'Order', orderfieldMappings, logger);  
                    if(!orderList.isEmpty()) {
                        //Existing order processing.
                        record = orderList.get(0);
                        record.Email__c = jsonMap.containsKey('email') ? string.valueOf(jsonMap.get('email')) : '';
                        record.Order_SCCSync_Status__c = 'Updated'; 
                        Database.update(record, true);
                        SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);
                        respList.add(SCCCustomerOrderResponse.createResponse(record));
                    }else{
                        if(jsonMap.containsKey('email')  || jsonMap.containsKey('crmcontact_id') ) {
                            
                            if(jsonMap.containsKey('crmcontact_id')){
                                query = SCCQueryUtilClass.getInstance()
                                    .getQueryInstance()
                                    .setObjectName('Account')
                                    .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                                    .setClause('Id = \'' + (String)jsonMap.get('crmcontact_id') + '\'')
                                    .setOrderBy('CreatedDate DESC')
                                    .getQuery();
                            }else if(jsonMap.containsKey('email')){
                                query = SCCQueryUtilClass.getInstance()
                                    .getQueryInstance()
                                    .setObjectName('Account')
                                    .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                                    .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\'')
                                    .setOrderBy('CreatedDate DESC')
                                    .getQuery();
                            }
                           	 
                            
                            system.debug('query ::: '+query);
                            List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                            if(!accountList.isEmpty()) {
                                record = additionalFieldsforNewOrder(record); 
                                record.Email__c = jsonMap.containsKey('email') ? string.valueOf(jsonMap.get('email')) : '';
                                record.isContactIdExist__c = true;
                                record.Order_Contact__c = accountList[0].PersonContactId;
                               // record.AccountId = defaultAccount.Id;
                                record.AccountId = accountList[0].Id;                    
                                Database.insert(record, true);
                                SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);                    
                            } else {
                                record = additionalFieldsforNewOrder(record);
                                record.Email__c = jsonMap.containsKey('email') ? string.valueOf(jsonMap.get('email')) : '';
                                record.Order_Contact__c = null;
                                record.AccountId = defaultAccount.Id;
                                Database.insert(record, true);
                                SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);
                            }
                        } else {
                            record = additionalFieldsforNewOrder(record);
                            record.AccountId = defaultAccount.Id;
                            Database.insert(record, true);
                            SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);
                        }
                        respList.add(SCCCustomerOrderResponse.createResponse(record));                         
                    }
                }                       
            } catch(Exception e) {
                logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                             + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                respList.add(SCCCustomerOrderResponse.createError(e, (String)jsonMap.get('order_no')));                 
            }                    
        }
        return respList;    
    }
    
    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerOrderResponse.
    */    
    public static List<SCCCustomerOrderResponse> createContactOrderRecord(RestRequest request, SCCFileLogger logger){
        SCCCommerceCloudConnect.logger = logger;
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>(); 
        Account defaultAccount = SCCUtilityClass.getDefaultAccount();
        if(defaultAccount == NULL){
	        	respList.add(SCCCustomerOrderResponse.createDefaultAccountError());
	        	logger.error('SCCCustomerRegistrationBatchService.createContactOrderRecord', Label.SCC_Missing_Default_Account);
	        	return respList;
	    }
        Map<String, SObject> orderfieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);  
        List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
        for (Object jsonData : jsonDataList){
            try	{
                Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
                Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, 'Order', orderfieldMappings, logger);
                Account acc = SCCUtilityClass.getDefaultAccount();
                if(acc == NULL){
	        		respList.add(SCCCustomerOrderResponse.createDefaultAccountError());
	        		logger.error('SCCCustomerRegistrationBatchService.createContactOrderRecord', Label.SCC_Missing_Default_Account);
	        		break;
	        	}
              
                record.AccountId = acc.Id;            
                if(jsonMap.containsKey('crmcontact_id')) {
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Contact')
                        .setRelatedFields(new Set<String>{'Id', 'Email'})
                        .setClause('Id = \'' + (String)jsonMap.get('crmcontact_id') + '\'')
                        .getQuery();    
                    List<Contact> contactList = (List<Contact>)SCCQueryUtilClass.getRecords(query);
                    if(!contactList.isEmpty()) {
                        record = additionalFieldsforNewOrder(record);
                        record.isContactIdExist__c = true;
                        record.Order_Contact__c = contactList[0].Id;                    
                        record.AccountId = defaultAccount.Id;                    
                        Database.insert(record, true);
                        SCCCommerceCloudConnect.scheduleIt(record.Id);                    
                    } else {
                        record = additionalFieldsforNewOrder(record);
                        record.Order_Contact__c = null;
                        record.AccountId = defaultAccount.Id; 
                        Database.insert(record, true);
                        SCCCommerceCloudConnect.scheduleIt(record.Id);
                    }
                } else {
                    record = additionalFieldsforNewOrder(record);
                    record.AccountId = defaultAccount.Id;
                    Database.insert(record, true);
                    SCCCommerceCloudConnect.scheduleIt(record.Id); 
                }
                respList.add(SCCCustomerOrderResponse.createResponse(record));      
            } catch(Exception e) {
        		logger.error('SCCCustomerPlaceOrderService.createContactOrderRecord', 'Exception message : '
                     + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                respList.add(SCCCustomerOrderResponse.createError(e));                      
            }
        }                    
        return respList;                   
    }    

    /**
    * This method used for populating additional and required fields for order object
    * @param record: Order
    * @return Order.
    */
    public static Order additionalFieldsforNewOrder(Order record) {
        record.EffectiveDate = System.today();
        record.from_SFCC__c = true;
        record.Order_SCCSync_Status__c = 'Created';
        record.Status = 'Draft';
        return record;
    }
}