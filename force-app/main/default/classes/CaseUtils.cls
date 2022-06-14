/*
    @Purpose    	: Populate the org wide email addresses on case record when status is updated to Closed
    			  	  These emails will be used to send the email alerts to various recipients    
    @Created Date  : 04/08/2020
*/
public class CaseUtils {
    
    /*
    	@Purpose	: Populate Transcom Operations org wide addresses on a new case
    */
    public static void populateTranscomOperationsEmailOnCase(List<Case> newCases){
        OrgWideEmailAddress transcomOperationsEmail = new OrgWideEmailAddress();  
        
        try{
            transcomOperationsEmail = [SELECT Id, Address, DisplayName 
                                       FROM OrgWideEmailAddress 
                                       WHERE DisplayName = 'Transcom Operations'];
        }
        catch(Exception e){
            System.debug('Exception in fetching org wide email addresses : ' + e.getMessage());
        }
        
        if(transcomOperationsEmail != null){
            for(Case caseRecord : newCases){
                caseRecord.Transcom_Operations__c = transcomOperationsEmail.Address;
        	}
		} 
    }
    
    /*
    	@Purpose	: Populate org wide addresses on a new case
    */
    public static void populateOrgWideEmailsOnCase(List<Case> updatedCases){
        List<OrgWideEmailAddress> orgWideAddresses = new List<OrgWideEmailAddress>();
        Map<String, String> displayNameAddressMap = new Map<String, String>();
        
        Set<String> displayNamesSet = new Set<String>{'Main Online Warehouse Email', 'ECR Email', 'Fulfillment Team Email', 
                                                      'OMS PM Email', 'ECR Manager Email', 'Finance Email', 'Legal Email',
                                                      'Product Safety Email', 'Director of Field Operations', 'Transcom Operations'};
        
        try{
            orgWideAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress];
        }
        catch(Exception e){
            System.debug('Exception in fetching org wide email addresses : ' + e.getMessage());
        }
        
        for(OrgWideEmailAddress owe : orgWideAddresses){
            displayNameAddressMap.put(owe.DisplayName, owe.Address);
        }
        
        for(Case caseRecord : updatedCases){
             
            if(displayNameAddressMap.containsKey('Main Online Warehouse Email')){
                caseRecord.Main_Online_Warehouse_Email__c = displayNameAddressMap.get('Main Online Warehouse Email');
            }
            
            if(displayNameAddressMap.containsKey('ECR Email')){
                caseRecord.ECR_Email__c = displayNameAddressMap.get('ECR Email');
            }
            
            if(displayNameAddressMap.containsKey('Fulfillment Team Email')){
                caseRecord.Fulfillment_Team_Email__c = displayNameAddressMap.get('Fulfillment Team Email');
            }
            
            if(displayNameAddressMap.containsKey('OMS PM Email')){
                caseRecord.OMS_PM_Email__c = displayNameAddressMap.get('OMS PM Email');
            }
            
            if(displayNameAddressMap.containsKey('ECR Manager Email')){
                caseRecord.ECR_Manager_Email__c = displayNameAddressMap.get('ECR Manager Email');
            }
            
            if(displayNameAddressMap.containsKey('Finance Email')){
                caseRecord.Finance_Email__c = displayNameAddressMap.get('Finance Email');
            }
            
            if(displayNameAddressMap.containsKey('Legal Email')){
                caseRecord.Legal_Email__c = displayNameAddressMap.get('Legal Email');
            }
            
            if(displayNameAddressMap.containsKey('Product Safety Email')){
                caseRecord.Product_Safety_Email__c = displayNameAddressMap.get('Product Safety Email');
            }
            
            if(displayNameAddressMap.containsKey('Director of Field Operations')){
                caseRecord.Director_of_Field_Operations__c = displayNameAddressMap.get('Director of Field Operations');
            }
            
            if(displayNameAddressMap.containsKey('Transcom Operations')){
                caseRecord.Transcom_Operations__c = displayNameAddressMap.get('Transcom Operations');
            }
        }
    }
    
    /*
    	@Purpose	: Populate Queue Sub Type on Case based on the Disposition 1 and 2 combinations
    */
    public static void populateCaseQueueSubtype(List<Case> caseRecords){
        List<Queue_Sub_Type_w_Disposition__mdt> queueSubtypesList = new List<Queue_Sub_Type_w_Disposition__mdt>();
        Map<String, String> queueSubtypeMap = new Map<String, String>();
            
        try{
            queueSubtypesList = [SELECT Disposition_1__c, Disposition_2__c, Queue_Sub_Type__c 
                                 FROM Queue_Sub_Type_w_Disposition__mdt];
        }
        catch(Exception e){
            System.debug('Exception in fetting Queue Subtype from Metadata : ' + e.getMessage());
        }
        
        String mapKey;
        
        for(Queue_Sub_Type_w_Disposition__mdt queueSubtype : queueSubtypesList){
            mapKey = queueSubtype.Disposition_1__c;
            
            if(String.isNotBlank(queueSubtype.Disposition_2__c)){
                mapKey += queueSubtype.Disposition_2__c;
            } 
            queueSubtypeMap.put(mapKey, queueSubtype.Queue_Sub_Type__c);
        }        
         
        mapKey = '';
        for(Case caseRecord : caseRecords){
             
            mapKey = caseRecord.Disposition_1__c;
             
            if(String.isNotBlank(caseRecord.Disposition_2__c)){
                mapKey += caseRecord.Disposition_2__c;
            }             
            
            if(queueSubtypeMap.containsKey(mapKey)){
                caseRecord.Queue_Sub_type__c = queueSubtypeMap.get(mapKey);
            }
            else{
                caseRecord.Queue_Sub_type__c = null;
            }
        }
    }
    
    /*
    	@Purpose	: Create a chatter post when the case origin in Chat/Social/Web
    */
    public static void createChatterPost(List<Case> newCases){
        List<FeedItem> feedItemList = new List<FeedItem>();
        Set<String> caseOrigins = new Set<String>{'Chat', 'Social', 'Web'};
            
        for(Case caseRecord : newCases){
            if(caseOrigins.contains(caseRecord.Origin) && String.isNotBlank(caseRecord.Description)){
                FeedItem post = new FeedItem();
                post.ParentId = caseRecord.Id;  
                post.Body = caseRecord.Description;
                post.Title = caseRecord.Subject;
                feedItemList.add(post);
            }
        }
        
        try{
            insert feedItemList;
        }
        catch(Exception e){
            System.debug('Exception in creating chatter posts : ' + e.getMessage());
        }
    }
    
    /*
    	@Purpose	: Populate Web Email/Phone fields on Case from custom Email/Phone fields
    */
    public static void populateFieldsOnOfflineCase(List<Case> newCases){
        Set<String> emailKeySet = new Set<String>();
        List<Case> chatCases = new List<Case>();        
        
        for(Case caseRecord : newCases){
            if(caseRecord.Origin == 'Chat offline form') {
                // Email__c is populate which means the record is created from offline form
                if(String.isNotBlank(caseRecord.Email__c) && String.isNotBlank(caseRecord.Last_Name__c)){
                    emailKeySet.add(caseRecord.Email__c);
                }
                
                if(String.isNotBlank(caseRecord.Email__c)){
                    caseRecord.SuppliedEmail = caseRecord.Email__c;
                }
                
                if(String.isNotBlank(caseRecord.Phone__c)){
                    caseRecord.SuppliedPhone = caseRecord.Phone__c;
                }
                
                if(String.isNotBlank(caseRecord.Description__c)){
                    caseRecord.Description = caseRecord.Description__c;
                }
                
                if(String.isNotBlank(caseRecord.Chat_Language__c)){
                    caseRecord.Web_Language__c = caseRecord.Chat_Language__c;
                }
                
                caseRecord.SuppliedName = '';
                if(String.isNotBlank(caseRecord.First_Name__c)){
                    caseRecord.SuppliedName = caseRecord.First_Name__c + ' ';
                }
                
                if(String.isNotBlank(caseRecord.Last_Name__c)){
                    caseRecord.SuppliedName += caseRecord.Last_Name__c;
                }
                
                chatCases.add(caseRecord);
            }
        }
        
        if(!chatCases.isEmpty() && !emailKeySet.isEmpty()){
            findOrCreatePersonAccountForOfflineCase(chatCases, emailKeySet);
		}
    }
    
    /*
    	@Purpose	: Find or create a Person Account for a case created from offline chat 
    */
    public static void findOrCreatePersonAccountForOfflineCase(List<Case> newCases, Set<String> emailKeySet){
        List<Account> existingPersonAccountList = new List<Account>();
        Map<String, Account> existingPersonAccountIdMap = new Map<String, Account>();
        Map<String, Account> newPersonAccountMap = new Map<String, Account>();
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		List<Case> casesWithoutParentAccount = new List<Case>();
		Map<String, String> languageToQueueIdMap = getEmailQueueIds();
            
        try{
			existingPersonAccountList = [SELECT Id, Language_Preference__c, Email_Key__c, PersonContactId FROM Account 
                                         WHERE Email_Key__c IN: emailKeySet OR PersonEmail IN: emailKeySet];
        }
        catch(Exception e){
            System.debug('Exception in fetching person accounts : ' + e.getMessage());
        }
        
        for(Account personAccount : existingPersonAccountList){
            existingPersonAccountIdMap.put(personAccount.Email_Key__c, personAccount);
        }
        
        for(Case caseRecord : newCases){
            if(String.isNotBlank(caseRecord.Last_Name__c)){
                // Existing account is found with matching email, relate the case to it
                if(existingPersonAccountIdMap.containsKey(caseRecord.Email__c)){
                    Account personAccount = existingPersonAccountIdMap.get(caseRecord.Email__c);
                    caseRecord.AccountId = personAccount.Id;
                    caseRecord.ContactId = personAccount.PersonContactId;
                    
                    // Set the owner Id to English Email/French Emails based on the language preference on the existing parent account
                    caseRecord.OwnerId = languageToQueueIdMap.containsKey(personAccount.Language_Preference__c) ? languageToQueueIdMap.get(personAccount.Language_Preference__c) : languageToQueueIdMap.get('EN');
                }
                // Existing account is not found with matching email, create a new person account
                else{
                    Account newPersonAccount = new Account();
                    newPersonAccount.FirstName = caseRecord.First_Name__c;
                    newPersonAccount.LastName = caseRecord.Last_Name__c;
                    newPersonAccount.PersonEmail = caseRecord.Email__c;
                    newPersonAccount.Phone = caseRecord.Phone__c;
                    newPersonAccount.RecordTypeId = personAccountRecordTypeId;
                    newPersonAccount.Language_Preference__c = caseRecord.Chat_Language__c;
                    newPersonAccountMap.put(caseRecord.Email__c, newPersonAccount);
                    casesWithoutParentAccount.add(caseRecord);
                    
                    // Set the owner Id to English Email queue
                    caseRecord.OwnerId = languageToQueueIdMap.get('EN');
                }
            }
		}
        
        if(!newPersonAccountMap.isEmpty()){
            try{
                // Insert the new person accounts
            	insert newPersonAccountMap.values();
                
                Map<Id, Account> newlyInsertedAccounts = new Map<Id, Account>([SELECT PersonContactId FROM Account WHERE Id IN: newPersonAccountMap.values()]);
                String accountId;
                
                // Relate the case records with newly created person accounts
                for(Case caseRecord : casesWithoutParentAccount){
                    if(newPersonAccountMap.containsKey(caseRecord.Email__c)){
                        accountId = newPersonAccountMap.get(caseRecord.Email__c).Id;
                        caseRecord.AccountId = accountId;
                        
                        if(newlyInsertedAccounts.containsKey(accountId)){
                            caseRecord.ContactId = newlyInsertedAccounts.get(accountId).PersonContactId;
                        }
                    }
                }
            }
            catch(Exception e){
                System.debug('Exception in creating new person accounts : ' + e.getMessage());
            }
        }
    }
    
    /*
    	@Purpose	: Get English/French Email queue Ids
    */
    public static Map<String, String> getEmailQueueIds(){
        Group englishEmails, frenchEmails = new Group();
        Map<String, String> languageToQueueIdMap = new Map<String, String>();
            
        try{
            englishEmails = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Email_English'];
            frenchEmails = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Email_French'];
        }
        catch(Exception e){
            System.debug('Exception in fetching queue records : ' + e.getMessage());
        }
        
        if(englishEmails != null && englishEmails.Id != null){
            languageToQueueIdMap.put('EN', englishEmails.Id);
        }
        
        if(frenchEmails != null && frenchEmails.Id != null){
            languageToQueueIdMap.put('FR', frenchEmails.Id);
        }
        
        return languageToQueueIdMap;
    }
}