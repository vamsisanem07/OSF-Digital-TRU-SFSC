public without sharing class SubscriptionCenterPageController {
    public Account account{get; set;}  
    public string  language{get;set;}
    public boolean showUnSub{get;set;}
    public boolean isFrench {get;set;}
    public string  lang{get;set;}
    public boolean accountfound{get;set;}  
    public boolean outemail{get;set;}
    public boolean showThankMsg{get;set;}
    public boolean toys{get;set;}
    public boolean activePlayOutdoor{get;set;}
    public boolean books{get;set;}
    public boolean collectorsGrownups{get;set;}
    public boolean collectorsKids{get;set;}
    public boolean educationLearningToysGames{get;set;}
    public boolean preschoolPlaytime{get;set;}
    public boolean baby{get;set;}
    public boolean babyGearEssentials{get;set;}
    public boolean nurseryFeeding{get;set;}
    public boolean pregnancyParenting{get;set;}
    public boolean safetyHealthWellness{get;set;}
    public boolean toysActivities{get;set;}
    public boolean clothing{get;set;}
    public boolean eventsAndActivities{get;set;}
    public boolean partyAndGiftGiving{get;set;}
   
    public SubscriptionCenterPageController(){
        account= new Account();    
        String accountId = System.currentPageReference().getParameters().get('id');
        try{
            account = [SELECT Language_Preference__c,Postal_Code__c, Email_Opt_In_TRU__c, Email_Opt_In_BRU__c, Email_Opt_In_RLE__c,                      
                       Email_Opt_In_Date_TRU__c,Email_Opt_In_Date_BRU__c,Email_Opt_In_Date_RLE__c,
                       PersonHasOptedOutOfEmail, IsPersonAccount,Party_Gift_giving__c,
                       Events_Activities__c,
                       Baby_Baby_Items__c,Toys_Toys_Items__c
                       FROM Account
                       Where Id =: accountId];
 
   String babyOptions = account.Baby_Baby_Items__c;
   String toyOptions = account.Toys_Toys_Items__c;
  
   baby = account.Email_Opt_In_BRU__c;
   toys = account.Email_Opt_In_TRU__c;
   clothing = account.Email_Opt_In_RLE__c;
   eventsAndActivities = account.Events_Activities__c;
   partyAndGiftGiving = account.Party_Gift_giving__c;

if( account.Baby_Baby_Items__c != NULL ) {             
for( String bChoice : account.Baby_Baby_Items__c.split(';')){

 if( bChoice == 'Baby Gear & Essentials'){
babyGearEssentials = true;
}if( bChoice == 'Nursury & Feeding'){
nurseryFeeding = true;
}if( bChoice == 'Pregnancy & Parenting'){
pregnancyParenting = true;
}if( bChoice == 'Safety, Health & Wellness'){
safetyHealthWellness = true;
}if( bChoice == 'Toys & Activities'){
preschoolPlaytime = true;
}
}
}
if( account.Toys_Toys_Items__c != NULL ) {          
for( String tChoice : account.Toys_Toys_Items__c.split(';')){
 if( tChoice == 'Active Play & Outdoor'){
activePlayOutdoor = true;
}if( tChoice == 'Books'){
books = true;
}if( tChoice == 'Collectors - Grownups'){
collectorsGrownups = true;
}if( tChoice == 'Collectors - Kids'){
collectorsKids = true;
}if( tChoice == 'Education & Learning Toys Games'){
educationLearningToysGames = true;
}if( tChoice == 'Preschool Playtime'){
toysActivities = true;
}
}
}
                   
            if(account.Language_Preference__c == null || account.Language_Preference__c == 'EN'){
                lang = 'en_US';
                isFrench=false;
                account.Language_Preference__c = 'EN';
            }else if(account.Language_Preference__c == 'FR'){
                isFrench=true;
                lang = 'fr-ch';
            }
           
             showThankMsg = false;            
              if(account!=null){
                language = account.Language_Preference__c;
                accountfound = true;
               
            }else{
                accountfound=false;
            }
            outemail = account.PersonHasOptedOutOfEmail;
         }catch(exception e){
            accountfound=false;
            system.debug('Exception Account1 '+e.getLineNumber()); 
            system.debug('Exception Occured While Faching Account'+e.getMessage());
        }
    }
     
    public PageReference updateOut(){
        if(account != null){
            System.debug('updateOut');
            account.Global_Opt_Out_Date__pc = System.today();
            account.Global_Email_Opt_In_Date__c = NULL;
            account.Global_Email_Opt_In__c = false;
            account.Global_Email_Opt_In_Source__c = Null;
            account.Email_Opt_In_BRU__c = false;
            account.Email_Opt_In_TRU__c = false;
            account.Email_Opt_In_RLE__c = false;
            account.Events_Activities__c = false;
            account.Party_Gift_giving__c = false;
            account.Baby_Baby_Items__c = NULL;
            account.Toys_Toys_Items__c = NULL;
            account.PersonHasOptedOutOfEmail = true;
            account.Language_Preference__c = lang == 'en_US'? 'EN' : 'FR';

            account.Email_Opt_In_Date_TRU__c = Null;
            account.Email_Opt_In_TRU_Source__c = Null;
            account.Email_Opt_In_Date_BRU__c = Null;
            account.Email_Opt_In_BRU_Source__c = Null;
            account.Email_Opt_In_Date_RLE__c = Null;
            account.Email_Opt_in_RLE_Source__c = Null;
           
            system.debug('updateOut'+account);
          update account;
        }
        else{
            system.debug('Account Is Null');
        }
        return null;
    }
   
    public PageReference accountunsub(){
        try{
            System.debug('accountunsub');
            update account;
           
        }catch(exception e){
            system.debug('Exception Occured'+e);
        }
        return null;
    }
    public void syncchilds(){
        List<child__c> childsfromAc = [select Key__c,Duplicate_Group__c from child__c where Account__c=:System.currentPageReference().getParameters().get('id')];
        for(child__c c:childsfromAc){
            c.Key__c = c.Duplicate_Group__c;
        }
        update childsfromAc;
    }
   
    public PageReference accountUpdate(){  
        syncchilds();
        babyChoice();
        toyChoice();
       
        
        account.Email_Opt_In_RLE__c = clothing == True? True : False;

        if(account.Email_Opt_In_RLE__c == true){
        account.Email_Opt_In_Date_RLE__c = System.today();
        account.Email_Opt_in_RLE_Source__c = 'Preference Centre';
        }


        
        account.Events_Activities__c = eventsAndActivities == True? True : False;
        account.Party_Gift_giving__c = partyAndGiftGiving == True? True : False;
        account.Global_Email_Opt_In_Date__c = System.today();
        account.Global_Opt_Out_Date__pc = NULL;
        account.PersonHasOptedOutOfEmail = false;
        account.Global_Email_Opt_In__c = true;
        account.Global_Email_Opt_In_Source__c = 'Preference Centre';
        account.Language_Preference__c = language;
        account.Language_Preference__c = lang == 'en_US'? 'EN' : 'FR';

       
        update account;
        system.debug('Account:'+account);
        return null;
    }
   
    public PageReference changeLanguage(){      
       lang =Apexpages.currentPage().getParameters().get('languagePref');
       if(lang=='en_US'){
        isFrench=false;
       }else if(lang=='fr-ch'){
        isFrench=true;
       }
       system.debug('lang'+lang);
       return null;
    }
    public void babyChoice(){

        account.Baby_Baby_Items__c = null;
        Set<String> multiBabyChoiceSet = new Set<String>();
       
         account.Email_Opt_In_BRU__c = baby;
        
        if(babyGearEssentials){
            multiBabyChoiceSet.add('Baby Gear & Essentials');
        }if(nurseryFeeding){
            multiBabyChoiceSet.add('Nursury & Feeding');
        }if(pregnancyParenting){
            multiBabyChoiceSet.add('Pregnancy & Parenting');
        }if(safetyHealthWellness){
            multiBabyChoiceSet.add('Safety, Health & Wellness');
        }if(toysActivities){
            multiBabyChoiceSet.add('Toys & Activities');
        }

        Boolean babyStart = true;
        String babyChoices = '';
            if(multiBabyChoiceSet != null && multiBabyChoiceSet.size()>0){
                for(String bchoice : multiBabyChoiceSet) {
                    if(babyStart) {
                        babyChoices = bchoice;
                        babyStart = false;
                    } else {              
                        babyChoices = babyChoices + ';' + bchoice;
                    }
                }

            }

        account.Baby_Baby_Items__c = babyChoices;
        account.Email_Opt_In_Date_BRU__c = System.today();
        account.Email_Opt_In_BRU_Source__c = 'Preference Centre';
    }

    public void toyChoice(){

        account.Toys_Toys_Items__c = null;
        Set<String> multiToyChoiceSet = new Set<String>();
   
        account.Email_Opt_In_TRU__c = toys;
         
        if(activePlayOutdoor){
            multiToyChoiceSet.add('Active Play & Outdoor');
        }if(books){
            multiToyChoiceSet.add('Books');
        }if(collectorsGrownups){
            multiToyChoiceSet.add('Collectors - Grownups');
        }if(collectorsKids){
            multiToyChoiceSet.add('Collectors - Kids');
        }if(educationLearningToysGames){
            multiToyChoiceSet.add('Education & Learning Toys Games');
        }if(preschoolPlaytime){
            multiToyChoiceSet.add('Preschool Playtime');
        }
        Boolean toyStart = true;
        String toyChoices = '';
            if(multiToyChoiceSet != null && multiToyChoiceSet.size()>0){
                for(String tchoice : multiToyChoiceSet) {
                    if(toyStart) {
                        toyChoices = tchoice;
                        toyStart = false;
                    } else {              
                        toyChoices = toyChoices + ';' + tchoice;
                    }
                }

            }
        account.Toys_Toys_Items__c = toyChoices;
        account.Email_Opt_In_Date_TRU__c = System.today();
        account.Email_Opt_In_TRU_Source__c = 'Preference Centre';
}
}