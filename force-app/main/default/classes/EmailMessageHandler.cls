public with sharing class EmailMessageHandler {
    
    private static final String EMAIL_ADDRESS = 'annemarie@majente.com';
    private static final String EMAIL_SUBJECT = 'Error has occurred during EmailMessages converting';
    private static final String EMAIL_BODY = 'Error has occurred during Email Message to Case Comment conversion';
    
    public static void onAfterInsert(List<EmailMessage> messages){
        createCaseComment(messages);
        
        markParentCaseNotManual(messages);
    }
    
    /**
    * This method create CaseComent records according to incoming EmailMessages list.
    * @param messages: List<EmailMessage>
    * @return @List<CaseComment>.
    */    
    private static List<CaseComment> createCaseComment(List<EmailMessage> messages){
        List<CaseComment> results = new List<CaseComment>();
        
        for(EmailMessage message : messages){
            if(message.Incoming && String.isNotBlank(message.TextBody)){
                CaseComment comment = new CaseComment();
                comment.ParentId = message.ParentId;
                comment.CommentBody = message.TextBody;

                results.add(comment);
            }
        }
            
        if(!results.isEmpty()){
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.allowFieldTruncation = true;
            
            Database.SaveResult[] saveResultList = Database.insert(results, dmlOptions);
            //email was already sent marker
            boolean isMailSent = false;
            
            for(Database.SaveResult sr : saveResultList){
                if(!isMailSent && !sr.isSuccess()){
                    String errorString = '\n\n';
                    for(Database.Error err : sr.getErrors()) {
                        errorString += err.getStatusCode() + ' ' + err.getMessage() + ' ' + err.getFields() + '\n';
                    }
                    
                    sendExceptionCauseEmail(EMAIL_BODY + errorString);
                    isMailSent = true;
                }
            }
        }
        
        return results;
    }
    
    /**
    * This method send email to predifiner email address if some errors are occurred during EmailMessages converting.
    * @param emailBody: String
    * @return None.
    */    
    public static void sendExceptionCauseEmail(String emailBody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String> {EMAIL_ADDRESS};
        mail.setToAddresses(toAddresses);
        mail.setSubject(EMAIL_SUBJECT);
        mail.setPlainTextBody(emailBody);
        
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
        }       
        catch(Exception e){
            System.debug('Exception in sending exception email notifications : ' + e.getMessage());    
        }
    }
    
    public static void markParentCaseNotManual(List<EmailMessage> messages){
        List<Case> caseList = new List<Case>();
        Set<Id> caseIdsSet = new Set<Id>();
        
        for(EmailMessage emailMsg : messages){
            // This is to filter only then incoming emails
            if(emailMsg.Incoming){
                caseIdsSet.add(emailMsg.ParentId);
            }
        }
        
        try{
            // Fetch only the parent cases which are not processed yet. This will prevent updation of cases again n again
            caseList = [SELECT Not_Manual__c FROM Case WHERE Id IN: caseIdsSet AND Not_Manual__c = false];
            
            // Update the flag to indicate the case is not manually created
            for(Case caseRecord : caseList){
                caseRecord.Not_Manual__c = true;
            }
            
            update caseList;
        }
        catch(Exception e){
            System.debug('Exception in updating parent cases : ' + e.getMessage());
        }
    }
}