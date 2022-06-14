/**
* Impl class of case that implements interface
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2018-01-15 
*/
public class SCCCaseImpl implements SCCSynchronisedInterface {

	/**
	* This method used for implementing related operations and update object status as Synchronised for case records
	* @param caseObj: SObject
	* @return None.
	*/
	public void continueWithObject(SObject caseObj) {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        try{
            Case record = (Case)caseObj;
            if(SCCUtilityClass.isPersonAccountEnabled()){
                syncAccountCase(record, logger);
            }else{
                syncContactCase(record, logger);
            }            
        }catch(Exception e){
            logger.error('SCCCaseImpl.continueWithObject', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());            
        }finally{
			logger.flush();            
        }
	}
    

	/**
	* This method process case synchronisation belonging to Contacts. 
	* This is used when person account is not enabled. 
	* @param record: Case
	* @return None.
	*/    
    public static void syncContactCase(Case record, SCCFileLogger logger){
        if(record==null){
            throw new SObjectException('null object passed');
        }        
		//SCCCommerceCloudConnect.updateCCCustomerProfile('{"c_sscid":"' + record.ContactId + '"}', record.SFCC_Customer_Number__c, SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations());
		String query = SCCQueryUtilClass.getInstance()
									  .getQueryInstance()
                                      .setObjectName('Contact')
                                      .setAllFields()
                                      .setClause('Id', '=', '\'' + record.ContactId + '\'')
									  .setLimit('1')
                                      .getQuery();
        List<Contact> contactList = (List<Contact>)SCCQueryUtilClass.getRecords(query);
		contactList[0].Contact_Status__c = 'Synchronised';
		Database.update(contactList[0], true);
		record.Case_SCC_Sync_Status__c = 'Synchronised';
		Database.update(record, true);        
    }

    /**
	* This method process case synchronisation belonging to Account. 
	* This is used when person account is enabled. 
	* @param record: Case
	* @return None.
	*/
    public static void syncAccountCase(Case record, SCCFileLogger logger){
        if(record==null){
            throw new SObjectException('null object passed');
        }
		//SCCCommerceCloudConnect.updateCCCustomerProfile('{"c_sscid":"' + record.ContactId + '"}', record.SFCC_Customer_Number__c, SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations());
		String query = SCCQueryUtilClass.getInstance()
									  .getQueryInstance()
                                      .setObjectName('Account')
                                      .setAllFields()
                                      .setClause('Id', '=', '\'' + record.AccountId + '\'')
									  .setLimit('1')
                                      .getQuery();
        List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
		accountList[0].Contact_Status__pc = 'Synchronised';
		Database.update(accountList[0], true);
		record.Case_SCC_Sync_Status__c = 'Synchronised';
		Database.update(record, true);        
    }    
}