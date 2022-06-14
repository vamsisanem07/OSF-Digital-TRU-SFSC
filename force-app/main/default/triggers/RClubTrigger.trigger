/**
 * Created by mike on 1/22/20.
 */

trigger RClubTrigger on R_Club_Number__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        RClubTriggerHandler.selectRClubPrimary(Trigger.newMap);
    }
    else if(Trigger.isAfter && Trigger.isDelete) {
        RClubTriggerHandler.selectRClubPrimary(Trigger.oldMap);
    }
}