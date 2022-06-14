public without sharing class OSF_AddChildLwcCtrl {
    
    @auraEnabled (cacheable=true)
    public static list<Child__c> getChildsfromAccount(String acId){
        return [select Name__c,Duplicate_Group__c,Birthday__c from Child__c where Account__c =: acId];
    }
    
    @auraEnabled (cacheable=true)
    public static Account getPersonAccount(String acId){
        return [select FirstName,LastName,PersonEmail from Account where Id =: acId Limit 1];
    }
    @auraEnabled 
    public static void updatePersonAccount(String acJson){
        update (Account) json.deserialize(acJson, Account.class);
    }
    
    @auraEnabled 
    public static void deleteChild(String paramstr){
        Child__c c = (Child__c)json.deserialize(paramstr, Child__c.class);
        list<Child__c> cList = [select id from Child__c where Name__c=:c.Name__c And Birthday__c=:c.Birthday__c];
        system.debug('Clist:> ++> '+cList);
        Database.Delete(cList);
    }
    
    @auraEnabled
    public static void upsertChilds(String paramstr,String acId){
        
        Child__c child = (Child__c)json.deserialize(paramstr, Child__c.class);
        list<child__c> exChilds = [select Name__c, Birthday__c, Duplicate_Group__c
                                   from Child__c
                                   where Account__c = :acId and ( Key__c = :child.key__c OR Key__c=:child.Duplicate_Group__c) limit 1];
        if(exChilds.size()>0){
        
            for(Child__c c:exChilds){
            c.Name__c = c.Name__c!=child.Name__c ? child.Name__c : c.Name__c;
            c.Birthday__c = c.Birthday__c!=child.Birthday__c ? child.Birthday__c : c.Birthday__c;
            c.Account__c = acId;
        }
            
        update exChilds;
    } else {
        
        child.Account__c = acId;
        insert child;
    
    }
    }
    
}