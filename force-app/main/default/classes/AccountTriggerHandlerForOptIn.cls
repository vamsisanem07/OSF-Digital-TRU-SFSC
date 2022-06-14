/*
* @Purpose- Handler used from trigger to Update the Opt In Dates base on its respective Opt In checkBoxes
*/
public class AccountTriggerHandlerForOptIn {
    /*
* @Purpose - Method invoke on After update.
*/
    public static void SetOptInDates(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap) {
        try{
            List<Account> toUpdateAccountList = new List<Account>();
            System.debug('newAccountMap '+ newAccountMap);
            for(String accRecId : newAccountMap.keySet()) {
                Account oldAcc = oldAccountMap.get(accRecId);
                Account newAcc = newAccountMap.get(accRecId);
                
                if(newAcc.Email_Opt_In_BRU__c && oldAcc.Email_Opt_In_BRU__c != newAcc.Email_Opt_In_BRU__c){
                    newAcc.Email_Opt_In_Date_BRU__c = System.today();
                }else if(oldAcc.Email_Opt_In_BRU__c != newAcc.Email_Opt_In_BRU__c && !newAcc.Email_Opt_In_BRU__c){
                    //  newAcc.Email_Opt_In_Date_BRU__c = NULL;
                }
                
                if(newAcc.Child_Birthday_Opt_In__c && oldAcc.Child_Birthday_Opt_In__c != newAcc.Child_Birthday_Opt_In__c){
                    newAcc.Child_Birthday_Email_Opt_In_Date__c = System.today();
                }else if(oldAcc.Child_Birthday_Opt_In__c != newAcc.Child_Birthday_Opt_In__c && !newAcc.Child_Birthday_Opt_In__c){
                    // newAcc.Child_Birthday_Email_Opt_In_Date__c = NULL;
                }
                
                if(newAcc.Email_Opt_In_TRU__c && oldAcc.Email_Opt_In_TRU__c != newAcc.Email_Opt_In_TRU__c){
                    newAcc.Email_Opt_In_Date_TRU__c = System.today();
                }else if(oldAcc.Email_Opt_In_TRU__c != newAcc.Email_Opt_In_TRU__c && !newAcc.Email_Opt_In_TRU__c){
                    // newAcc.Email_Opt_In_Date_TRU__c = NULL;
                }
                
                //LastModifedDate - 26-02-2021
                if(newAcc.Email_Opt_In_RLE__c && oldAcc.Email_Opt_In_RLE__c != newAcc.Email_Opt_In_RLE__c){
                    newAcc.Email_Opt_In_Date_RLE__c = System.today();
                }else if(oldAcc.Email_Opt_In_TRU__c != newAcc.Email_Opt_In_TRU__c && !newAcc.Email_Opt_In_TRU__c){
                    // newAcc.Email_Opt_In_Date_TRU__c = NULL;
                }
                
                if(oldAcc.Loyalty_Opt_In__c != newAcc.Loyalty_Opt_In__c && newAcc.Loyalty_Opt_In__c){
                    newAcc.Loyalty_Opt_In_Date__c = System.today();
                }       
            }}
        catch(exception e){
            system.debug('AccoungTRH :> '+json.serialize(e));
        }
    }
    
    /*
* @Purpose - Method invoke on After insert.
*/
    public static void SetOptInDates(List<Account> newAccountList) {
        try{
            List<Account> toUpdateAccountList = new List<Account>();
            System.debug('newAccountMap '+ newAccountList);
            for(Account newAcc : newAccountList) {
                
                if(newAcc.Email_Opt_In_BRU__c){
                    newAcc.Email_Opt_In_Date_BRU__c = System.today();
                }
                if(newAcc.Child_Birthday_Opt_In__c){
                    newAcc.Child_Birthday_Email_Opt_In_Date__c = System.today();
                }
                
                if(newAcc.Email_Opt_In_TRU__c){
                    newAcc.Email_Opt_In_Date_TRU__c = System.today();
                }
                
                //LastModifedDate - 26-02-2021
                if(newAcc.Email_Opt_In_RLE__c){
                    newAcc.Email_Opt_In_Date_RLE__c = System.today();
                }
                
                /*if(newAcc.Loyalty_Opt_In__c){
newAcc.Loyalty_Opt_In_Date__c = System.today();
} */   
            }
        }
        catch(exception e){
            system.debug('AccoungTRH :> '+json.serialize(e));
        }
    }
    
    public static void registryInactiveFlagUpdate(Map<Id, Account> newAccountMap){
        if(newAccountMap != null){
            if(!newAccountMap.isEmpty()){
                try{
                    List<Registry__c> listregistry = [Select Id, Name, Account__c, Inactive_Flag__c, Account_Email_Opt_Out__c, Account__r.PersonHasOptedOutOfEmail
                                                      FROM Registry__c
                                                      Where Account__c IN : newAccountMap.keyset() AND Account__r.PersonHasOptedOutOfEmail = true];
                    
                    if(listregistry != null){
                        for(Registry__c registry : listregistry){
                            registry.Inactive_Flag__c = true;
                        }
                        
                        update listregistry;
                    }
                    
                }
                catch(Exception e){
                    
                }
            }
        }
    }
}