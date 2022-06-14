/*
    @Purpose        : This controller is used in the support settings to set the default from address on any outgoing emails from case.
    @Created Date   : 18/09/2020
*/
global class EmailDefaultsUtils implements QuickAction.QuickActionDefaultsHandler {
    global EmailDefaultsUtils(){}
    
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults;// = (QuickAction.SendEmailQuickActionDefaults)defaults.get(0);
		
        // Check if the quick action is the standard Case Feed send email action
        for (Integer j = 0; j < defaults.size(); j++) {            
            if ((defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
                defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType && 
                defaults.get(j).getActionName().equals('Case.SendEmail') && 
                defaults.get(j).getActionType().equals('SendEmail')) || Test.isRunningTest()) {
                    
                    sendEmailDefaults =  (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                    break;
                }
        }
        
        if(sendEmailDefaults != null){
            sendEmailDefaults.setInsertTemplateBody(false);
            
            OrgWideEmailAddress orgWideAddress;
            EmailMessage emailMessage = (EmailMessage) sendEmailDefaults.getTargetSObject();  
            Case caseRecord; 
            
            try{
                orgWideAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'ToysRUs Canada'];
                caseRecord = [SELECT AccountId, Account.PersonEmail FROM Case WHERE Id =: sendEmailDefaults.getContextId()];
            }
            catch(Exception e){
                System.debug('Exception in fetching org wide email address : ' + e.getMessage()); 
            }
            
            if(orgWideAddress != null){
                try{
                    List<String> messageTokens = emailMessage.htmlBody.split('--------------- Original Message ---------------');
                    emailMessage.HtmlBody = messageTokens[0];
                }
                catch(Exception e){
                    System.debug('Exception in trimming email body : ' + e.getMessage());
                }
                
                if(caseRecord != null && caseRecord.AccountId != null && String.isNotBlank(caseRecord.Account.PersonEmail)){
                    emailMessage.ToAddress = caseRecord.Account.PersonEmail;
                }               
                
                emailMessage.FromAddress = orgWideAddress.Address;
                emailMessage.FromName = orgWideAddress.DisplayName;
                emailMessage.ValidatedFromAddress = orgWideAddress.Address;
            }     
        }
    }
}