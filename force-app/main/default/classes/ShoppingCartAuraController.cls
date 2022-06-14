public with sharing class ShoppingCartAuraController {
    
    static SCCFileLogger logger = SCCFileLogger.getInstance();
    
	@AuraEnabled
	public static String getAccessToken(String recordId, String objectName) {
        SCCCommerceCloudConnect.logger = logger;
        String customerAuthToken = null;
        try{
            String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud();
            logger.debug('ShoppingCartAuraController', 'getAccessToken : '+ agentAccessToken); 
            if(agentAccessToken!=null && agentAccessToken!='' ){
                customerAuthToken = SCCCommerceCloudConnect.getCustomerAuthToken(agentAccessToken, getSFCCCustomerIdById(recordId, objectName, logger)); 
            }
            logger.debug('ShoppingCartAuraController', 'getAccessToken-customerAuthToken : '+ customerAuthToken);     
            return customerAuthToken;
        }catch(Exception e){
            logger.error('ShoppingCartAuraController.getAccessToken', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());  
            return customerAuthToken;
        }finally{
            logger.flush();
        }
	}

	@AuraEnabled
	public static String getStoreSessionURL() {
        String storeSessionURL = null;
        storeSessionURL = SCCCommerceCloudConnect.siteBaseUrl+'/s/'+SCCCommerceCloudConnect.siteId+'/dw/shop/v17_4/sessions';
        return storeSessionURL;
	}

	@AuraEnabled
	public static String getStoreFrontURL() {
        String storeFrontURL = null;
        storeFrontURL = SCCCommerceCloudConnect.siteBaseUrl+'/on/demandware.store/Sites-'+SCCCommerceCloudConnect.siteId+'-Site/en_CA/Cart-Show';
        
        return storeFrontURL;
	}
    
	private static String getSFCCCustomerIdById(Id recordId, String objectName, SCCFileLogger logger) {

	String result = null;
	Case[] records;
	Account account;
	if(SCCUtilityClass.isPersonAccountEnabled()){
            logger.debug('ShoppingCartAuraController.getSFCCCustomerIdById', 'Person accoun enabled. getting SFCC Customer id from person account');
            if(objectName == 'Account'){
                account = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id = :recordId]; 
                if(account != null) {
                    result = account.SFCC_Customer_Id__pc;
                }
            }else if(objectName == 'Case'){
                records = [SELECT Id, Account.Id, Account.SFCC_Customer_Id__pc, Account.SFCC_Customer_Number__pc, ContactEmail FROM Case WHERE Id = :recordId]; 
                if(!records.isEmpty()) {
                    result = records[0].Account.SFCC_Customer_Id__pc;
                }
            }           
        }else{
            //Person account is not enabled, Service connector code for OOBO is not supported for these orgs
	    logger.debug('ShoppingCartAuraController.getSFCCCustomerIdById', 'Person account in not enabled. getting SFCC Customer id from person account');
            records = [SELECT Id, Contact.Id, Contact.SFCC_Customer_Id__c, Contact.SFCC_Customer_Number__c, ContactEmail FROM Case WHERE Id = :recordId];
            if (!records.isEmpty()) {
                result = records[0].Contact.SFCC_Customer_Id__c;
            }            
        }
        logger.debug('ShoppingCartAuraController.getSFCCCustomerIdById','Returning SFCC Customer ID: '+result);
		return result;
	}

}