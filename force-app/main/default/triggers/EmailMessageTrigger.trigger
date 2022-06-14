trigger EmailMessageTrigger on EmailMessage (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        EmailMessageHandler.onAfterInsert(Trigger.new);
    }
}