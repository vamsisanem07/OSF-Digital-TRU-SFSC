@isTest
public class SCCCancelOrderImpl_Test {

    @testSetup
    static void setup(){
        
    }
    
    @isTest
    private static void testOnBeforeInsert(){
        List<SObject> newList = new List<SObject>();
        (new SCCCancelOrderImpl()).onBeforeInsert(newList);
    }
    
    @isTest
    private static void testOnAfterInsert(){
        Map<Id, SObject> newMap = new Map<Id, SObject>();
        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        (new SCCCancelOrderImpl()).onAfterInsert(newMap, oldMap);
    }
}