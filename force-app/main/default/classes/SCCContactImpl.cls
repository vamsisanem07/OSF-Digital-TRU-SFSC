/**
* Impl class of contact that implements interface
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2018-01-15 
*/
public class SCCContactImpl implements SCCSynchronisedInterface {
 
    //related contact record
    public static Contact contactRecord;   
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
    public void continueWithObject(SObject contactObj) {
        
        syncContact(contactObj.Id);
    }

    public static Boolean syncContact(String contactId){    
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try {
            Map<String, SObject> contactFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Contact', logger);  
            contactRecord = [SELECT Id, FirstName, LastName, Email, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE Id =: contactId];
            customerNo = contactRecord.SFCC_Customer_Number__c;
            customerId = contactRecord.SFCC_Customer_Id__c;            
            //List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>();
            String resBody = SCCCommerceCloudConnect.getCustomerDetails(customerNo, SCCCommerceCloudConnect.connectToCommerceCloud());
            String addressBody = SCCCommerceCloudConnect.getAddressDetails(customerNo, SCCCommerceCloudConnect.connectToCommerceCloud());
            logger.debug('SCCContactImpl.syncContact','resBody: ' + resBody + ' addressBody: '+addressBody);            
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            Map<String, Object> addressJsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(addressBody);
            Contact updatedContact = (Contact)SCCUtilityClass.initializeObject(jsonMap, 'Contact', contactFieldMappings, logger);
            updatedContact.Contact_Status__c = 'Synchronised';
            updatedContact.from_SFCC__c = true;
            updatedContact.Id = contactRecord.Id;
            Database.update(updatedContact, true);
            if(addressJsonMap.containsKey('data') &&
               !((List<Object>)addressJsonMap.get('data')).isEmpty()){
                upsertAddressBook(updatedContact.Id, (List<Object>)addressJsonMap.get('data'));                     
            }
            return true;
        } catch(Exception e) {
            logger.error('SCCContactRefreshComponentController.syncContact', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());            
            return false;
        }finally{
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
				Address__c address = SCCUtilityClass.getAddressByName(String.valueOf(tempMap.get('address_id')));
                if(address != null && address.Id != null){
                    record.Id = address.Id;                   
                }
                record.Contact__c = recordId;
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

}