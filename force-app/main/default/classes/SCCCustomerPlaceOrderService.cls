/**
* Rest Service class for post order informations' details => Customer Place Order
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02 
*/
@RestResource(urlMapping='/Order/Placement/*')
global with sharing class SCCCustomerPlaceOrderService {

    /**
    * This is the method using on "GET" requests.
    * @return List<Order>.
    */
    @HttpGet
    global static List<Order> show() {
        Id recordId = RestContext.request.requestURI.replace('/Order/Placement/', '');
        List<Order> returnList = new List<Order>();
        String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Order')
                .setAllFields()
                .setClause('Id = \'' + recordId + '\'')
                .getQuery();
        returnList = (List<Order>)SCCQueryUtilClass.getRecords(query);
        return returnList;
    }

    /**
    * This is the method using on "POST" requests.
    * @return SCCReturnResponse.
    */
    @HttpPost
    global static SCCReturnResponse create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCReturnResponse response;
        Sobject sobj;
        try{
        	Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString()); 
            if(!String.isEmpty((String)jsonMap.get('crmcontact_id'))){
 				sobj = SCCUtilityClass.getSojectByRefId((String)jsonMap.get('crmcontact_id'));            
            }
                       
            if(SCCUtilityClass.isPersonAccountEnabled()
               && (sobj instanceof Account || sobj == null)){
                logger.debug('SCCCustomerPlaceOrderService.create', 'Person account enabled. Creating account order: '+sobj);
                response = createAccountOrderRecord(jsonMap, logger);
            }else if(!SCCUtilityClass.isPersonAccountEnabled() 
               && (sobj instanceof Contact || sobj == null)){
                logger.debug('SCCCustomerPlaceOrderService.create', 'Person account disabled. Creating contact order: '+sobj);
                response = createContactOrderRecord(jsonMap, logger);
        	}else{
                logger.debug('SCCCustomerPlaceOrderService.create', 'Supplied data in incorrect. Doesnt support move contact to person account or vice versa');                
                throw new SObjectException('Invalid data, Is PersonAccount Enabled: '+ SCCUtilityClass.isPersonAccountEnabled());
            }            
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            response = SCCReturnResponse.createError(e);
        }finally{
            logger.flush();
        }
        return response;
    }
    
    /**
    * This is the method using on "POST" requests
    * @return SCCReturnResponse.
    */    
    static SCCReturnResponse createAccountOrderRecord(Map<String, Object> jsonMap, SCCFileLogger logger){
        try{
	        Account defaultAccount = SCCUtilityClass.getDefaultAccount();
	        if(defaultAccount == NULL){
	        	logger.error('SCCCustomerPlaceOrderService.createAccountOrderRecord', Label.SCC_Missing_Default_Account);
                return SCCReturnResponse.createDefaultAccountError();
	        }	
			if(jsonMap.containsKey('order_no')) {
                String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Order')
                    .setRelatedFields(new Set<String>{'Id', 'AccountId', 'Name', 'OrderNumber', 'SFCC_Order_Number__c'})
                    .setClause('SFCC_Order_Number__c = \'' + (String)jsonMap.get('order_no') + '\'')
                    .getQuery();
                List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query); 
            	Map<String, SObject> orderfieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);  
            	Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, 'Order', orderfieldMappings, logger);  
                if(!orderList.isEmpty()) {
                    //Existing order processing.
                    record = orderList.get(0);
                    record.Order_SCCSync_Status__c = 'Updated'; 
                    Database.update(record, true);
                    SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);
                    return SCCReturnResponse.createResponse(record.Id); 
                }else{
                    //New Order processing.
                    if(jsonMap.containsKey('crmcontact_id')) {
                        query = SCCQueryUtilClass.getInstance()
                            .getQueryInstance()
                            .setObjectName('Account')
                            .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                            .setClause('Id = \'' + (String)jsonMap.get('crmcontact_id') + '\'')
                            .getQuery();    
                        List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                        if(!accountList.isEmpty()) {
                            record = additionalFieldsforNewOrder(record); 
                            record.isContactIdExist__c = true;
                            record.Order_Contact__c = accountList[0].PersonContactId;                      
                            record.AccountId = accountList[0].Id;                    
                            Database.insert(record, true);
                            SCCCommerceCloudConnect.synchroniseObjectFuture(record.Id);                    
                        } else {
                            record = additionalFieldsforNewOrder(record);
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
                    return SCCReturnResponse.createResponse(record.Id); 
                }
            }else{
				logger.error('SCCCustomerPlaceOrderService.createAccountOrderRecord', Label.SCC_Missing_Default_Account);
				return SCCReturnResponse.createDefaultAccountError();
            }           
        } catch(Exception e) {
            logger.error('SCCCustomerPlaceOrderService.createAccountOrderRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            RestContext.response.statusCode = 500;
            return SCCReturnResponse.createError(e);
        }         
    }
    
    /**
    * This is the method using on "POST" requests
    * @return SCCReturnResponse.
    */    
    public static SCCReturnResponse createContactOrderRecord(Map<String, Object> jsonMap, SCCFileLogger logger){
        try{
	        Account defaultAccount = SCCUtilityClass.getDefaultAccount();
	        if(defaultAccount == NULL){
	        	logger.error('SCCCustomerPlaceOrderService.createContactOrderRecord', Label.SCC_Missing_Default_Account);
	        	return SCCReturnResponse.createDefaultAccountError();
	        }	
            Map<String, SObject> orderfieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);  
            Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, 'Order', orderfieldMappings, logger);
            Account acc = SCCUtilityClass.getDefaultAccount();
            if(acc == NULL){
            	logger.error('SCCCustomerPlaceOrderService.createContactOrderRecord', Label.SCC_Missing_Default_Account);
	        	return SCCReturnResponse.createDefaultAccountError();
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
                    System.debug(record);
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
            return SCCReturnResponse.createResponse(record.Id);            
        } catch(Exception e) {
            logger.error('SCCCustomerPlaceOrderService.createContactOrderRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            RestContext.response.statusCode = 500;
            return SCCReturnResponse.createError(e);
        }        
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