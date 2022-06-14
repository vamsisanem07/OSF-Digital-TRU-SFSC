/**
* Impl class of Account that implements interface
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2018-01-15 
*/
public class SCCAccountImpl implements SCCSynchronisedInterface {

    //related account record
    public static Account accountRecord                 {get; set;}    
    //customer number for commerce cloud
    public static String customerNo                     {get; set;}
    //customer number for commerce cloud
    public static String customerId                     {get; set;}    
    //json map after deserialization
    public static Map<String, Object> jsonMap           {get; set;}
    
    /**
    * This method used for implementing related operations and update object status as Synchronised for contact records
    * @param contactObj: SObject
    * @return None.
    */
    public void continueWithObject(SObject accountObj) {
        
        syncAccount(accountObj.Id);
    
    }
 
    public static Boolean syncAccount(String accountId){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try {
            Map<String, SObject> accountFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger); 
            String query = SCCQueryUtilClass.getInstance()
                          .getQueryInstance()
                          .setObjectName('Account')
                          .setRelatedFields(new Set<String>{'Id', 'FirstName', 'LastName', 'PersonEmail', 'PersonContactId', 'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc'})
                          .setClause('Id', '=', '\'' + accountId + '\'')
                          .setLimit('1')
                          .getQuery(); 
            List<Account> accountRecords = (List<Account>)SCCQueryUtilClass.getRecords(query);
            accountRecord = accountRecords.get(0);
            customerNo = accountRecord.SFCC_Customer_Number__pc;
            customerId = accountRecord.SFCC_Customer_Id__pc;
            //List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>();
            String resBody = SCCCommerceCloudConnect.getCustomerDetails(customerNo, SCCCommerceCloudConnect.connectToCommerceCloud());
            //String addressBody = SCCCommerceCloudConnect.getAddressDetails(customerNo, SCCCommerceCloudConnect.connectToCommerceCloud());
            String addressBody = SCCCommerceCloudConnect.getCustomerDetailsById(customerId, SCCCommerceCloudConnect.connectToCommerceCloud());            
            logger.debug('SCCAccountImpl.syncAccount','resBody: ' + resBody + ' addressBody: '+addressBody);
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            Map<String, Object> addressJsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(addressBody);
            jsonMap.put('auth_type', addressJsonMap.get('auth_type'));
            jsonMap.put('addresses', addressJsonMap.get('addresses'));
            logger.debug('SCCAccountImpl.syncAccount','after adding address jsonMap: ' + System.JSON.serialize(jsonMap));            
            Account updatedAccount = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', accountFieldMappings, logger);
            updatedAccount.Contact_Status__pc = 'Synchronised';
            updatedAccount.from_SFCC__pc = true;
            updatedAccount.Id = accountRecord.Id;
            Database.update(updatedAccount, true);
            if(addressJsonMap.containsKey('addresses') &&
               !((List<Object>)addressJsonMap.get('addresses')).isEmpty()){
                   upsertAddressBook(updatedAccount.Id, (List<Object>)addressJsonMap.get('addresses'));  
            }
            //This is add any client specific customization. 
            updateAdditionalAttributes(updatedAccount, jsonMap, logger);
            return true;                        
        } catch(Exception e) {
            logger.error('SCCAccountImpl.syncAccount', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());               
            return false;
        } finally{
            logger.flush();            
        }
    }    
    

    public static void upsertAddressBook(Id recordId, List<Object> addressJsonMap) {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try {
            logger.debug('SCCAccountImpl.upsertAddressBook',' recordId: ' + recordId + ' addressJsonMap: ' + addressJsonMap);
            Map<String, SObject> addressFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Address', logger); 
            List<Address__c> contactAddressList = new List<Address__c>();
            for(Object obj : addressJsonMap) {
                Map<String, Object> tempMap = (Map<String, Object>)obj;
                Address__c record = (Address__c)SCCUtilityClass.initializeObject(tempMap, 'Address__c', addressFieldMappings, logger);
                Address__c address = SCCUtilityClass.getAddressByNameAndAccount(String.valueOf(tempMap.get('address_id')), recordId);
                if(address != null && address.Id != null){
                    record.Id = address.Id;                   
                }
                Account personAccount = SCCUtilityClass.getPersonAccount(recordId);
                if(personAccount != null){
                    record.Contact__c =  personAccount.PersonContactId;                 
                }
                record.Account__c = recordId;
                record.from_SFCC__c = true;
                contactAddressList.add(record);
            }
            Database.upsert(contactAddressList);
        } catch(Exception e) {
            logger.error('SCCAccountImpl.upsertAddressBook', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString()); 
        } finally{
            logger.flush(); 
        }
    }  
    
    /**
    * This method patch customer profile in commerce cloud. This is called usually by triggers 
    * in service cloud when contact or account is updated in service cloud.
    * @param patchDataMap: Map<String, Object>
    * @return Boolean.
    */ 
    public static Boolean patchCustProfile(Map<String, Object> patchDataMap, Account acc){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        Map<String, Object> jsonObjMap;
        Boolean result = false;
        try{
            jsonObjMap = SCCJsonUtil.initializeJsonObject(patchDataMap, 'Account', logger);
            String body = (String)System.JSON.serialize(jsonObjMap);
            logger.debug('SCCAccountImpl.patchCustProfile','Profile Patch request body: '+ body); 
            patchCustProfileCallOut(body, acc.SFCC_Customer_Number__pc);    
            result = true;                      
        }catch(Exception e){
            logger.error('SCCAccountImpl.patchCustProfile', 'Exception message : '
                     + e.getMessage() + ' StackTrack '+ e.getStackTraceString());                               
        }finally{
            logger.flush();         
        }
        return result;
    }


    /**
    * This method patch customer address in commerce cloud. This is called usually by triggers
    * in service cloud when address is updated in service cloud.
    * @param patchDataMap: Map<String, Object>
    * @return Boolean.
    */
    public static Boolean patchCustAddress(Map<String, Object> patchDataMap, Address__c addr){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        Map<String, Object> jsonObjMap;
        Boolean result = false;
        try{
            jsonObjMap = SCCJsonUtil.initializeJsonObject(patchDataMap, 'Address__c', logger);
            jsonObjMap.put('address_id', addr.Name);
            String body = (String)System.JSON.serialize(jsonObjMap);
            logger.debug('SCCAccountImpl.patchCustAddress','Profile Patch request body: '+ body);
            patchCustAddressCallOut(body, addr.Account__c, addr.Name);
            result = true;
        }catch(Exception e){
            logger.error('SCCAccountImpl.patchCustAddress', 'Exception message : '
                    + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        }finally{
            logger.flush();
        }
        return result;
    }

    /**
    * This method is wrapper method to call webservice asynchronously. 
    * @param patchDataMap: Map<String, Object>
    * @return Boolean.
    */     
    @future (callout=true)
    static void patchCustProfileCallOut(String body, String customerNo){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try{
            SCCCommerceCloudConnect.logger = logger;
            HttpResponse resp = SCCCommerceCloudConnect.updateCCCustomerProfile(body, customerNo, SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations());
        }catch(Exception e){
            logger.error('SCCAccountImpl.patchCustProfileCallOut', 'Exception message : '
                     + e.getMessage() + ' StackTrack '+ e.getStackTraceString());           
        }finally{
            logger.flush();             
        }   
    }


    /**
    * This method is wrapper method to call webservice asynchronously.
    * @param patchDataMap: Map<String, Object>
    * @return Boolean.
    */
    @future (callout=true)
    static void patchCustAddressCallOut(String body, String customerId, String addressName){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try{
            Account customer = [SELECT Id, SFCC_Customer_Number__pc FROM Account WHERE Id = :customerId];
            SCCCommerceCloudConnect.logger = logger;
            String resp = SCCCommerceCloudConnect.patchAddressDetails(body, customer.SFCC_Customer_Number__pc, addressName, SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations());
        }catch(Exception e){
            logger.error('SCCAccountImpl.patchCustAddressCallOut', 'Exception message : '
                    + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        }finally{
            logger.flush();
        }
    }
    /**
    * This method is to implement client specific customizations
    * @param updatedAccount: Account
    * @param jsonMap: Map<String, Object>
    * @param logger: SCCFileLogger        
    * @return None.
    */ 
    public static void updateAdditionalAttributes(Account updatedAccount, Map<String, Object> jsonMap, SCCFileLogger logger){
    }
}