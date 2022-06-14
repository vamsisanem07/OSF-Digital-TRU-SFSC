trigger AccountTrigger on Account (before insert, before update) {
    try{
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        AccountTriggerHandler.setEmailKey(Trigger.new);
        //Last Modified Date - 1-04-2020.
        if(Trigger.isUpdate && ActivateDeactiveAccountOptinTrigger__c.getInstance().ActivateTheTrigger__c)
            AccountTriggerHandlerForOptIn.SetOptInDates(Trigger.newMap, Trigger.oldMap);
      	    AccountTriggerHandlerForOptIn.registryInactiveFlagUpdate(Trigger.newMap);
         if(Trigger.isInsert && ActivateDeactiveAccountOptinTrigger__c.getInstance().ActivateTheTrigger__c)
            AccountTriggerHandlerForOptIn.SetOptInDates(Trigger.new);
    }
        
    }
    catch(Exception e){
        system.debug('AccounTriggerLog :> '+json.serialize(e));
    }
}