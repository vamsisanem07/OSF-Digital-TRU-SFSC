public class SCCContactRefreshComponentController {
    
    //related contact record 
    public static Contact contactRecord;
    //related account record
    public static Account accountRecord;       
    //customer informations
    @AuraEnabled
    public static List<SCCCustomerWrapper> customerList   {get; set;}
    //json map after deserialization
    public static Map<String, Object> jsonMap           {get; set;}
    //json key - label mapping
    public static Map<String, String> jsonKeyMap = new Map<String, String>{ 'customer_id'=>'Customer Id', 
                                                                            'customer_no'=>'Customer Number', 
                                                                            'email'=>'Email', 
                                                                            'first_name'=>'First Name', 
                                                                            'last_name'=>'Last Name', 
                                                                            'c_accountid'=>'Account Id', 
                                                                            'c_accountnumber'=>'Account Number', 
                                                                            'c_sscid'=>'Contact Id', 
                                                                            'birthday'=>'BirthDay', 
                                                                            'gender'=>'Gender',
                                                                            'c_optin'=>'Email OptIn'
                                                                        };


    /**
    * This method used to synchonized with customer and contact
    * @return None.
    */
    @AuraEnabled
    public static List<SCCCustomerWrapper> getCustomers(String objectId) {
        String SFCCCustomerNo;
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try{
            if(SCCUtilityClass.isPersonAccountExist(objectId)){
                accountRecord = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id =: objectId];
                return getCustomersData(accountRecord.SFCC_Customer_Number__pc, logger);
            }else{
                contactRecord = [SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE Id =: objectId];         
                return getCustomersData(contactRecord.SFCC_Customer_Number__c, logger);
            }            
        }catch(Exception e){
            logger.error('SCCContactRefreshComponentController.getCustomers', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return new List<SCCCustomerWrapper>();
        }finally{
           logger.flush(); 
        }
    }
                                                                            
                                                                            
                                                                            
                                                                            
    /**
    * This method used to getting customer informations from commerce cloud
    * @return List<SCCCustomerWrapper>.
    */
    public static List<SCCCustomerWrapper> getCustomersData(String SFCCCustomerNo, SCCFileLogger logger) {

        try {
            customerList = new List<SCCCustomerWrapper>();
            List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>(); 
            String resBody = SCCCommerceCloudConnect.getCustomerDetails(SFCCCustomerNo, SCCCommerceCloudConnect.connectToCommerceCloud());
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            logger.debug('SCCContactRefreshComponentController.getCustomers','jsonMap: ' + jsonMap);
            for(String key : jsonMap.keySet()) {
                logger.debug('SCCContactRefreshComponentController.getCustomers','key: ' + key);
                if(jsonKeyMap.keySet().contains(key)) {
                    returnList.add(new SCCCustomerWrapper(jsonKeyMap.get(key), String.valueOf(jsonMap.get(key))));
                }
            }
            customerList.addAll(returnList); 
            logger.debug('SCCContactRefreshComponentController.getCustomers','customerList: ' + customerList);
            return returnList;
        } catch(Exception e) {
            customerList.clear();
            logger.error('SCCContactRefreshComponentController.getCustomersData', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return new List<SCCCustomerWrapper>();
        }

    }

    /**
    * This method used to synchonized with customer and contact
    * @return None.
    */
    @AuraEnabled
    public static Boolean syncCustomer(String objectId) {
        if(SCCUtilityClass.isPersonAccountExist(objectId)){
			return SCCAccountImpl.syncAccount(objectId);
        }else{
            return SCCContactImpl.syncContact(objectId);            
        }
    }
}