/**
* Connection class to SFCC(Salesforce Commerce Cloud) and pull related informations
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-06 
*/
public with sharing class SCCCommerceCloudConnect { 

    /* specified site id on commerce cloud */
    public static SCCFileLogger logger {
        get { 
            return logger;            
        }
        set {
        	logger = value;
        }
    }	


    /* specified site id on commerce cloud */
    public static String siteId {
        get { 
            if(String.isBlank(siteId)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCCConfiguration__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Site_Id__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Site_Id__c;
            }
            return siteId;            
        }
        set;
    }
    
    /* specified customer list id on commerce cloud */
    public static String listId {
        get {           
            if(String.isBlank(listId)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCCConfiguration__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Customer_List_Id__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Customer_List_Id__c;
            }           
            return listId;
        }
        set;
    }
    
    /* specified base url for commerce cloud platform to connect */
    public static String siteBaseUrl {
        get {           
            if(String.isBlank(siteBaseUrl)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCCConfiguration__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'SFCC_Site_URL__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].SFCC_Site_URL__c;
            }
            return siteBaseUrl;
        }
        set;
    }

    /* specified triggered schedule time for connect and pull from commerce cloud */
    public static Integer scheduleTime {
        get {           
            if(null == scheduleTime) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCCConfiguration__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Time__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query); 
                return Integer.valueOf(objList[0].Time__c);
            }            
            return scheduleTime;
        }
        set;
    }
    
    /* specified client_id for doing connection with sfcc */
    public static String sfccClientId {
        get {
            if(String.isBlank(sfccClientId)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Integration_Creds__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Client_Id__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Integration_Creds__c> objList = (List<SFCC_Integration_Creds__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Client_Id__c;
            }
            return sfccClientId;
        }
        set;
    }
    
    /* specified client_id for doing connection with sfcc */
    public static String sfccClientSecret {
        get {           
            if(String.isBlank(sfccClientSecret)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Integration_Creds__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Client_Secret__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Integration_Creds__c> objList = (List<SFCC_Integration_Creds__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Client_Secret__c;
            }           
            return sfccClientSecret;
        }
        set;
    }
    
    
    /* specified product image for listview */
    /* This is kept for future correction. Image implementation is not appropriate. 
    public static String imageListview {
        get {
            if(String.isBlank(imageListview)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Product_Image_Group_Listview__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCCConfiguration__c > objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Product_Image_Group_Listview__c;
            }
            return imageListview;
        }
        set;
    }
    
    public static String imageDetailview {
        get {
            if(String.isBlank(imageDetailview)) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__c')
                                          .setRelatedFields(new Set<String>{'Id', 'Name', 'Product_Image_Group_Detailview__c'})
                                          .setLimit('1')
                                          .getQuery();
                List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Product_Image_Group_Detailview__c;
            }
            return imageDetailview;
        }
        set;
    }
*/
    /**
    * This method used for set connection to commerce cloud and return the access_token.
    * @return String.
    */
    public static String connectToCommerceCloud() {       
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFCCUserCreds/dw/oauth2/access_token?client_id=' + sfccClientId);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:demandware:params:oauth:grant-type:client-id:dwsid:dwsecuretoken');
        Http https = new Http();
        HTTPResponse res = https.send(req);
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
        if(jsonMap.containsKey('access_token')) {
            String token = (String)jsonMap.get('access_token');
            if(logger!=null){
				logger.trace('SCCCommerceCloudConnect.connectToCommerceCloud', 'connectToCommerceCloud-access_token : '+ token);   
            }
            return token;
        }
        return '';

    }

    /**
    * This method used for set connection to commerce cloud and return the access_token.
    * @return String.
    */
    public static String connectToCommerceCloud2ProfileOperations() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFCCClientCreds/dw/oauth2/access_token');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueof(sfccClientId + ':' + sfccClientSecret)));
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials');
        Http https = new Http();
        HTTPResponse res = https.send(req);
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
        if(jsonMap.containsKey('access_token')) {
            if(logger!=null){
            	logger.trace('SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations', 'connectToCommerceCloud-connectToCommerceCloud2ProfileOperations : '+ (String)jsonMap.get('access_token'));
            }
            return (String)jsonMap.get('access_token');
        }
        return '';
        
    }    
  
    public static String getCustomerAuthToken(String agentToken, String scccustomerid){
		if(logger!=null){
        	logger.debug('SCCCommerceCloudConnect.getCustomerAuthToken', 'getCustomerAuthToken agentToken: '+ agentToken + ' scccustomerid: ' + scccustomerid);
        }    	
        String customerAuthToken = null;
        String relUrl = '/s/'+ siteId +'/dw/shop/v17_4/customers/'+scccustomerid+'/auth';
        HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:SFCCClientCredsBearer'+relUrl);
		req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Length', '0');
        req.setHeader('Authorization', 'Bearer '+agentToken);
        req.setBody('{}');
		Http https = new Http();
		HTTPResponse res = https.send(req);
        customerAuthToken = res.getHeader('Authorization');
		if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect', 'connectToCommerceCloud-getCustomerAuthToken: res.getBody() '+res.getBody() + 'customerAuthToken '+ customerAuthToken);
        }
		return customerAuthToken;
    }
    
    /**
    * This method used for pulling selected order details from commerce cloud.
    * @param orderNumber: String
    * @param accessToken: String
    * @return String.
    */
    public static String getOrderDetails(String orderNumber, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndPoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v17_8/orders/' + orderNumber);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
		if(logger!=null){
	        logger.trace('SCCCommerceCloudConnect', 'connectToCommerceCloud-getOrderDetails: res '+ res.getBody());    
        }
        return res.getBody();
        
    }    
    
    /**
    * This method used for pulling selected customer details from commerce cloud using customer no.
    * @param customerNumber: String
    * @param accessToken: String
    * @return String.
    */
    public static String getCustomerDetails(String customerNumber, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
		if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect', 'connectToCommerceCloud-getCustomerDetails: res '+ res.getBody());
        }
        return res.getBody();

    }
    
    /**
     * Unued method hence commented
    * This method used for pulling selected customer details from commerce cloud using customer ID.
    * @param customerNumber: String
    * @param accessToken: String
    * @return String.
    */
    public static String getCustomerDetailsById(String customerId, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v18_3/customers/' + customerId +'?expand=addresses,paymentinstruments');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
		if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect.getCustomerDetailsById', 'connectToCommerceCloud-getCustomerDetails: res '+ res.getBody());
        }
        return res.getBody();

    }

    
    public static String getAddressDetails(String customerNumber, String accessToken) { 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber + '/addresses');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }

	public static String postAddressDetails(String body, String customerNumber, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber + '/addresses');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }

    public static String patchAddressDetails(String body, String customerNumber, String addressName, String accessToken) {

        if(String.isEmpty(body) || String.isEmpty(customerNumber)){
            throw new CalloutException('Empty mandatory parameters');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber + '/addresses/' + addressName);
        req.setMethod('POST');
        req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(logger!=null){
            logger.trace('SCCCommerceCloudConnect.updateCCCustomerProfile', 'Req: '+req.getBody() +' Res: '+ res.getBody());
        }
        return res.getBody();
    }
    
    /**
    * This method used for pulling selected customer profile details from commerce cloud.
    * @param email: String
    * @param accessToken: String
    * @return String.
    */
    public static String searchCustomerByEmail(String email, String accessToken) {
        
        if(String.isEmpty(email)){
            throw new CalloutException('Empty mandatory parameters');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customer_search');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        String body = '{"query":{"text_query":{"fields":["email", "phone_home", "phone_business", "phone_mobile"],"search_phrase":"' + email + '"}}}';
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect.searchCustomerByEmail', 'connectToCommerceCloud-searchCustomerByEmail: res '+ res.getBody());
        }
        return res.getBody();

    }
    
    /**
    * This method used for pushing selected customer profile to update to commerce cloud.
    * @param body: String
    * @param customerNo: String
    * @param accessToken: String
    * @return String.
    */
    public static HttpResponse updateCCCustomerProfile(String body, String customerNo, String accessToken) {
        
        if(String.isEmpty(body) || String.isEmpty(customerNo)){
            throw new CalloutException('Empty mandatory parameters');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNo);
        req.setMethod('POST');
	    req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect.updateCCCustomerProfile', 'Req: '+req.getBody() +' Res: '+ res.getBody());
        }        
        return res;

    }    
    

	/**
    * This method used for pushing selected order to update to commerce cloud.
    * @param body: String
    * @param orderNo: String
    * @param accessToken: String
    * @return String.
    */
    public static String pushOrderDetails(String body, String orderNo, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v18_3/orders/' + orderNo);
        req.setMethod('POST');
        req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        //String body = '{"c_crmid":"' + contactId + '"}';
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }


    
    /**
    * This method used for scheduled the class to pull datas from commerce cloud.
    * @param recordId: Id
    * @return None.
    */
    public static void scheduleIt(Id recordId) {
		if(logger!=null){
	        logger.debug('SCCCommerceCloudConnect.scheduleIt', 'Scheduling job');    
        } 
        Integer i = null != scheduleTime ? scheduleTime : 1;
        Datetime systime = System.now();
        systime = systime.addMinutes(i);
        String chron_exp = ' '+ sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String name = String.valueOf(math.random() + ' - SCCScheduleClassforPullDetails_:');
        SCCScheduleClassforPullDetails sch = new SCCScheduleClassforPullDetails(recordId);
        String jobId = System.Schedule(name, chron_exp, sch); 
		if(logger!=null){
	        logger.trace('SCCCommerceCloudConnect.scheduleIt', 'connectToCommerceCloud-scheduleIt: jobId'+ jobId);    
        }        

    }


/* 
 * This is kept for future to correct this implementation.
 *      
    @future(callout=true)
    public static void getImages(Id objectId) {

        try {
            Order_Line_Item__c orderLineItem = [SELECT Id, Detailview_Image_Link__c, Listview_Image_Link__c, Product_Id__c FROM Order_Line_Item__c WHERE Id =: objectId];
            HttpRequest req = new HttpRequest();
            req.setEndpoint(siteBaseUrl + '/s/' + listId + '/dw/shop/v18_2/products/' + orderLineItem.Product_Id__c + '/images?client_id=' + sfccClientId);
            req.setMethod('GET');
            Http h = new Http();
            HttpResponse res = h.send(req);
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
    		if(logger!=null){
	            logger.debug('SCCCommerceCloudConnect.getImages','response body: ' + res.getBody());    			
    		}
            List<Object> imageGroupList = (List<Object>)jsonMap.get('image_groups');
            for(Object o : imageGroupList) {
                Map<String, Object> tempMap = (Map<String, Object>)o;
                if((String)tempMap.get('view_type') == imageListview) {
                    List<Object> imagesList = (List<Object>)tempMap.get('images');
                    Map<String, Object> imageMap = (Map<String, Object>)imagesList[0];
                    orderLineItem.Listview_Image_Link__c = (String)imageMap.get('link');
                }
                if((String)tempMap.get('view_type') == imageDetailview) {
                    List<Object> imagesList = (List<Object>)tempMap.get('images');
                    Map<String, Object> imageMap = (Map<String, Object>)imagesList[0];
                    orderLineItem.Detailview_Image_Link__c = (String)imageMap.get('link');
                }
            }
            Database.update(orderLineItem, true);
        } catch(Exception e) {
        	if(logger!=null){
            	logger.error('SCCCommerceCloudConnect.getImages', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());  			
    		}

        }

    }
 */ 

    /**
    * future wrapper on synchronizeObject method 
    * This method used for pulling the object details from commerce cloud and update object.
    * @param objectIds: List<Id>
    * @return None.
    */    
    @future(callout=true)
    public static void synchroniseObjectFutureBatch(List<Id> objectIds) {
        for (Id objectId : objectIds){
    		synchronizeObject(objectId);    
        }
    }
    
    /**
    * future wrapper on synchronizeObject method
    * This method used for pulling the object details from commerce cloud and update object.
    * @param objectId: Id
    * @return None.
    */    
    @future(callout=true)
    public static void synchroniseObjectFuture(Id objectId) {
    	synchronizeObject(objectId);
    }
    
    /**
    * This method used for pulling the object details from commerce cloud and update object.
    * @param objectId: Id
    * @return None.
    */
    public static void synchronizeObject(Id objectId) {
		SCCFileLogger logger = SCCFileLogger.getInstance();
        try {
            String objectName = objectId.getSobjectType().getDescribe().getName();
            String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName(objectName)
                                          .setAllFields()
                                          .setClause('Id', '=', '\'' + objectId + '\'')
                                          .getQuery();
            List<SObject> objList = SCCQueryUtilClass.getRecords(query);
            if(!objList.isEmpty()) {
            	if(logger!=null){
                	logger.debug('SCCCommerceCloudConnect.synchronizeObject', 'objectName: ' + 'SCC' + objectName + 'Impl');             	        		
            	}
 
                SCCSynchronisedInterface handler = (SCCSynchronisedInterface)Type.forName('SCC' + objectName + 'Impl').newInstance();
                handler.continueWithObject(objList[0]);
            }
        } catch(Exception e) {
        	if(logger!=null){
            	logger.error('SCCCommerceCloudConnect.synchronizeObject', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());   
            }          
            SCCReturnResponse errorValue = SCCReturnResponse.createError(e);
        }finally{
        	if(logger!=null){
            	logger.flush();        	        		
        	}

        }
    }
    
}