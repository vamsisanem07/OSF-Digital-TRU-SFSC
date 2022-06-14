/*
	@Purpose	: Controller of AppeasementCodeGenerator component 
*/
public class AppeasementCodeController {
    
    /*
    	@Purpose	: Returns the Role Id of current user
    */
    @AuraEnabled
    public static String getUserRole() {
        return UserInfo.getUserRoleId();
    }
    
    /*
    	@Purpose	: Get and relate the available appeasement code record matching the Purpose_of_Appeasement__c & Discount_Type__c
					  specified on the appeasement record.
    */
    @AuraEnabled
    public static String getAvailableAppeasementCode(String appeasementId){ 
        String language = UserInfo.getLanguage();
        
        try{
            Appeasement__c appeasement = [SELECT Purpose_of_Appeasement__c, Discount_Type__c 
                                          FROM Appeasement__c WHERE Id =: appeasementId];
            
            
            Appeasement_Code__c appeasementCode = [SELECT Id, Name FROM Appeasement_Code__c 
                                                   WHERE Discount_Type__c =: appeasement.Discount_Type__c
                                                       AND Purpose_of_Appeasement__c =: appeasement.Purpose_of_Appeasement__c 
                                                       AND Status__c = 'Available' 
                                                   LIMIT 1];
            
            
            if(appeasement != null){
                if(appeasementCode != null){ 
                    appeasement.Appeasement_Code_Id__c = appeasementCode.Id;
                    update appeasement;
                    
                    appeasementCode.Status__c = 'Used';
                    update appeasementCode;
                    
                    if(language == 'fr'){
                        return 'Succès! ' + appeasementCode.Name + 'a été lié à cet enregistrement';
                    }
                    else{
                        return 'Success! ' + appeasementCode.Name + ' has been linked to this record.';
                    }
                }
            }
            
            return null;
        }
        catch(Exception e){
            System.debug('Exception in getting the Appeasement Code: ' + e.getMessage());
            if(language == 'fr'){
                return 'Erreur! Échec de l\'obtention du code d\'apaisement';
            }
            else{
                return 'Error! Failed to get the Appeasement Code.';
            }
        }
    }
}