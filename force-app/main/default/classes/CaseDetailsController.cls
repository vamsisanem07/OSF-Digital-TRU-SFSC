public class CaseDetailsController {
    private DescribeSObjectResult caseSchema = Schema.SObjectType.Case;
    private Map<string, Schema.SObjectField> mapFields = caseSchema.fields.getMap();  
    Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    Schema.DescribeFieldResult caseHistoryFieldResult = mySObjectTypeMap.get('CaseHistory').getDescribe().fields.getMap().get('Field').getDescribe();
    List<Schema.PicklistEntry> historyFieldPicklistValues = caseHistoryFieldResult.getPickListValues();
     
    public transient Case caseRecord {get; set;}
    public transient List<NotesWrapper> notes {get; set;}
    public transient List<CaseHistoryWrapper> caseHistories {get; set;}
    public transient List<FeedItemWrapper> feedItems {get;set;}
    public transient List<ChatTranscriptWrapper> chatTranscripts {get;set;}
    public transient List<SocialPostsWrapper> socialposts {get;set;}
    
    public String caseThreadId {get;set;}
    
    public String caseId {get; set{
        try{
            caseRecord = [SELECT Id, Account.Name, Contact.Name, CaseNumber, Disposition_1__c, Disposition_2__c,
                              Legal_Threat__c, Customer_Alerting_Media__c, Call_Back_Expected__c, Order__r.Name, Manufacturer__r.Name,
                              OnContact_External_ID__c, Order_Line_Item__c, Queue_Sub_type__c, Case_Number__c, Item_Number__c,
                              Gift_Card_Number__c, Did_Injury_Occur__c, Manufacturer__c, Address_for_Address_Correction__c,
                              Owner.Name, Type, SFCC_Order_No__c, Order_Number_DEPR__c, Status, Description, KIT_Status__c, Subject,
                              Store__r.Name, Store_ID__c, Store_Email__c, Store_Manager_Email__c, Store_Director_Email__c, BusinessHoursId,
                              District_Manager_Email__c, CreatedById, LastModifiedById, ClosedDate, RecordType.Name, Origin, SuppliedEmail,
                              Priority, SuppliedPhone,
                              (SELECT Subject, MessageDate, Status, ToAddress, TextBody, HasAttachment FROM EmailMessages ORDER BY Subject)
                          FROM Case
                          WHERE Id =: value];
        }
        catch(Exception e){
            System.debug('Exception in fetching case details: ' + e.getMessage());
        }
        
        caseHistories = getCaseHistory(value);
        notes = getContentNotes(value);
        feedItems = getFeedItems(value);  
        chatTranscripts = getChatTranscripts(value);
        socialposts = getSocialPost(value);
        
        try{
            List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, value, new List<String>{'{!Case.Thread_Id}'});        
            caseThreadId = renderResults[0].getMergedBody();
        }
        catch(Exception e){
        	System.debug('Exception in rendering the case thread id : ' + e.getMessage());
        }
    }}  
     
    private List<CaseHistoryWrapper> getCaseHistory(Id caseId) {
        List<CaseHistoryWrapper> listCaseHistory = new List<CaseHistoryWrapper>();
        Map<String, List<CaseHistory>> caseHistoryDateMap = new Map<String, List<CaseHistory>>();
        
        if(caseId != null) {            
            List<CaseHistory> caseHistoryList = new List<CaseHistory>();            
            try{
                caseHistoryList = [SELECT Id, Field, NewValue, OldValue, CreatedDate, CreatedById, CreatedBy.Name 
                                   FROM CaseHistory 
                                   WHERE CaseId =: caseId AND DataType != 'EntityId'
                                   ORDER BY CreatedDate DESC, Field LIMIT 50];
            }
            catch(Exception e){
                System.debug('Exception in fetching case history : ' + e.getMessage());
            }
            
            String mapKey;
            
            for(CaseHistory history : caseHistoryList) {
                mapKey = history.CreatedDate.format() + '@' + history.CreatedBy.Name;
                if(caseHistoryDateMap.containsKey(mapKey)){
                    caseHistoryDateMap.get(mapKey).add(history);
                }
                else{
                    caseHistoryDateMap.put(mapKey, new List<CaseHistory>{history});
                } 
            }
            
            String action = '';
            
            for(String mapKeyLocal : caseHistoryDateMap.keySet()){              
                List<CaseHistory> caseHistoryListLocal = caseHistoryDateMap.get(mapKeyLocal);
                CaseHistoryWrapper wrapper = new CaseHistoryWrapper(); 
                List<String> keyTokens = mapKeyLocal.split('@');
                String createdDateStr = keyTokens[0].remove('@');
                wrapper.historyDate = createdDateStr;
                wrapper.userName = keyTokens[1];
                
                action = '';
                for(CaseHistory historyRecord : caseHistoryListLocal){
                    action += getActionFormat(historyRecord);
                }
                
                wrapper.action = action;
                
                listCaseHistory.add(wrapper);
            } 
        }
        
        return listCaseHistory;
    } 
    
    @TestVisible
    private string getActionFormat(CaseHistory history) {
        String actionFormat, fieldLabel, newVal, oldVal;
        
        if (history != null) { 
            fieldLabel = getFieldLabel(history.Field);             
                
            if (history.newValue != null && history.oldValue == null) {
                actionFormat = 'Changed ' + fieldLabel + ' to ' + history.newValue + '. ';    
            }
            else if (history.newValue != null && history.oldValue != null) {
                actionFormat = 'Changed ' + fieldLabel + ' from ' + history.oldValue + ' to ' + history.newValue + '. ';   
            }
            else if (history.Field != null && history.Field.equalsIgnoreCase('created')) {
                actionFormat = 'Created. ';
            }
            else if (history.Field != null && history.newValue == null && history.oldValue == null) {
                actionFormat = 'Changed ' + fieldLabel + '. ';
            }
            else if (history.oldValue != null && history.newValue == null){
                actionFormat = 'Deleted ' + history.oldValue + ' in ' + fieldLabel + '. ';
            }
        }
        
        return actionFormat;
    }
        
    public String getFieldLabel(String fieldName){
        if (mapFields.containsKey(fieldName)){
            return mapFields.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
                else{
                    return fieldName;
                }
            }
        } 
        return '';
    }
    
    public List<NotesWrapper> getContentNotes(Id caseId){
        List<NotesWrapper> notesList = new List<NotesWrapper>();
        try{
            List<ContentDocumentLink> contentDocuments = [SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId 
                                                          FROM ContentDocumentLink 
                                                          WHERE LinkedEntityId =: caseId];
            
            
            if(contentDocuments != null){
                Set<Id> contentDocumentIdSet = new Set<Id>();
                for(ContentDocumentLink documentLink : contentDocuments){
                    contentDocumentIdSet.add(documentLink.ContentDocumentId);
                }
                
                if(!contentDocumentIdSet.isEmpty()){
                    List<ContentNote> contentNotes = [SELECT Id, TextPreview, Title, Owner.Name, LastModifiedDate, Content 
                                                      FROM ContentNote WHERE Id IN: contentDocumentIdSet];
                    
                    if(contentNotes != null){
                        for(ContentNote note : contentNotes){
                            notesList.add(new NotesWrapper(note.Title, 
                                                           note.LastModifiedDate, 
                                                           note.Owner.Name, 
                                                           note.TextPreview));
                        }
                    }
                }
            }
            
        }
        catch(Exception e){
            System.debug('Exception in fetching case notes : ' + e.getMessage());
        }
        
        return notesList;
    }
    
    public List<ChatTranscriptWrapper> getChatTranscripts(Id caseId){
        List<ChatTranscriptWrapper> chatTranscriptWrapperList = new List<ChatTranscriptWrapper>();
        List<LiveChatTranscript> liveChatTranscripts = new List<LiveChatTranscript>();
        
        try{
            liveChatTranscripts = [SELECT Body, Name, ContactId, Contact.Name, AccountId, Account.Name, Case.CaseNumber, Status 
                                   FROM LiveChatTranscript 
                                   WHERE CaseId =: caseId];
        }
        catch(Exception e){
            System.debug('Exception in fetching live chat transcripts : ' + e.getMessage());
        }
            
        for(LiveChatTranscript liveChat : liveChatTranscripts){
            ChatTranscriptWrapper chatWrapper = new ChatTranscriptWrapper();
            chatWrapper.name = liveChat.Name;
            chatWrapper.body = liveChat.Body;
            chatWrapper.contactName = liveChat.ContactId != null ? liveChat.Contact.Name : '';
            chatWrapper.accountName = liveChat.AccountId != null ? liveChat.Account.Name : '';
            chatWrapper.caseNumber = liveChat.Case.CaseNumber;
            chatWrapper.status = liveChat.Status;
            chatTranscriptWrapperList.add(chatWrapper);
        }
        
        return chatTranscriptWrapperList;
    }
    
    public List<FeedItemWrapper> getFeedItems(String caseId){
        List<FeedItem> feedItemList = new List<FeedItem>();
        List<FeedItemWrapper> feedItemWrapperList = new List<FeedItemWrapper>();
        
        try{
            feedItemList = [SELECT Body, CreatedBy.Name, LastModifiedDate 
                            FROM FeedItem 
                            WHERE ParentId =: caseId AND Type = 'TextPost'];
        }
        catch(Exception e){
            System.debug('Exception in fetching feed items : ' + e.getMessage());
        }
        
        for(FeedItem feedItem : feedItemList){
            FeedItemWrapper wrapper = new FeedItemWrapper();
            wrapper.body = feedItem.Body;
            wrapper.owner = feedItem.CreatedBy.Name;
            wrapper.lastModified = feedItem.LastModifiedDate.format();
            feedItemWrapperList.add(wrapper);
        }
        
        return feedItemWrapperList;
    }
    
    public static List<SocialPostsWrapper> getSocialPost(String caseId){
        List<SocialPostsWrapper> socialposts = new List<SocialPostsWrapper>();
        List<SocialPost> soqlsocialPost = new List<SocialPost>();
        
        try{
            soqlsocialPost = [SELECT Id, ParentId, PersonaId, WhoId, Who.Name, ReplyToId, Headline, Content, PostUrl, LikedBy, Posted
                            FROM SocialPost
                            WHERE ParentId =: caseId order By CreatedDate DESC limit 10];
        }
        catch(Exception e){
            System.debug('Exception in fetching Social Posts : ' + e.getMessage());
        }
        
        for(SocialPost post : soqlsocialPost){
            SocialPostsWrapper postWrapper = new SocialPostsWrapper();
            postWrapper.name = 'test';
            postWrapper.headline = post.Headline;
            postWrapper.message = post.Content;
            postWrapper.posteddate = string.valueOf(post.Posted);
            postWrapper.whoname = post.Who.Name;
            socialposts.add(postWrapper);
        }
        system.debug('socialposts'+socialposts);
        return socialposts;
    }
    
    public class CaseHistoryWrapper {
        public String historyDate {get;set;}
        public String userName {get;set;}
        public String action {get;set;}
    }
    
    public class NotesWrapper {
        public String title {get;set;}
        public String lastModified {get;set;}
        public String owner {get;set;}
        public String textPreview {get;set;}
        
        public NotesWrapper(String title, DateTime lastModified, String owner, String textPreview){
            this.title = title;
            this.lastModified = lastModified.format();
            this.owner = owner;
            this.textPreview = textPreview;
        }
    }
    
    public class FeedItemWrapper{
        public String body {get;set;}
        public String lastModified {get;set;}
        public String owner {get;set;}
    }
    
    public class ChatTranscriptWrapper{
        public String name {get;set;}
        public String body {get;set;}
        public String caseNumber {get;set;}
        public String contactName {get;set;}
        public String accountName {get;set;}
        public String status {get;set;}
    }
    
    public class SocialPostsWrapper{
        public String name {get;set;}
        public String whoname {get;set;}
        public String headline {get;set;}
        public String message {get;set;}
        public string posteddate {get;set;}
    }
    
}