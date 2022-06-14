/*
 * @Purpose: Test class for ChatRequestPrioritizationTrigger and ChatRequestPrioritizationController
 * @CreatedDate: 29 January 2021
 * */
@isTest
public class ChatRequestPrioritizationTriggerTest {
    
    /*
     * @Purpose: test setup method to create account, case records
     * @Parameters: none
     * @Return: void
     * */
    
    @testSetup
    static void createData(){
        List<Account> accountList = new List<Account>();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        for (Integer i = 0; i < 1; ++i){
            accountList.add(new Account(
                LastName = 'Test Account ' + (i + 1),
                PersonEmail = 'testemail' + (i + 1) + '@test.mail',
                Language_Preference__c = 'EN',
                RecordTypeId = rtId
            ));
        }
        
        INSERT accountList;
        
        Case caseRecord = new Case();
        caseRecord.AccountId = accountList[0].Id;
      
        INSERT caseRecord;
        
        PendingServiceRouting pendingServiceRouting = createPendingServiceRecord(caseRecord.Id);
        INSERT pendingServiceRouting;
    }
    
    /*
     * @Purpose: test method to cover englishSkillId data
     * @Parameters: none
     * @Return: void
     * */
    @isTest
    static void testMethod1(){
        Test.startTest();
                
        List<Account> accountList = [SELECT Id, Name FROM Account];
        
        Case caseRecord = [SELECT Id, accountId FROM Case LIMIT 1];
        
        
        PendingServiceRouting pendingServiceRouting = [SELECT Id, WorkItemId, RoutingModel, RoutingPriority, LastModifiedDate, 
                                                       IsReadyForRouting, SecondaryRoutingPriority
                                                       FROM PendingServiceRouting
                                                       LIMIT 1];
        
        
        List<Skill> skillsList = [SELECT Id, MasterLabel FROM Skill 
                                  WHERE MasterLabel = 'English' OR MasterLabel = 'French' 
                                  OR MasterLabel = 'English - Tier 2' OR MasterLabel = 'French - Tier 2'];
        
        List<SkillRequirement> skillRequirementList = new List<SkillRequirement>();
        
        for(Skill skillRecord : skillsList){
            SkillRequirement skillRequirement = new SkillRequirement (RelatedRecordId = pendingServiceRouting.Id, SkillId = skillRecord.Id);
            skillRequirementList.add(skillRequirement);
        }
        
        INSERT skillRequirementList;
        
        System.assertEquals(4, skillRequirementList.size());
        
        Test.stopTest();
    }
    
    
    /*
     * @Purpose: test method to cover frenchSkillId data
     * @Parameters: none
     * @Return: void
     * */
    @isTest
    static void testMethod2(){
        Test.startTest();
        
        List<Account> accountList = [SELECT Id, Name 
                                     FROM Account];
        
        Case caseRecord = [SELECT Id, accountId 
                           FROM Case LIMIT 1];
        
        PendingServiceRouting pendingServiceRouting = [SELECT Id, WorkItemId, RoutingModel, RoutingPriority, LastModifiedDate, 
                                                       IsReadyForRouting, SecondaryRoutingPriority
                                                       FROM PendingServiceRouting
                                                       LIMIT 1];
        
        List<Skill> skillsList = [SELECT Id, MasterLabel FROM Skill 
                                  WHERE MasterLabel = 'French' 
                                  OR MasterLabel = 'English - Tier 2' 
                                  OR MasterLabel = 'French - Tier 2'];
        
        List<SkillRequirement> skillRequirementList = new List<SkillRequirement>();
        
        for(Skill skillRecord : skillsList){
            SkillRequirement skillRequirement = new SkillRequirement (RelatedRecordId = pendingServiceRouting.Id, SkillId = skillRecord.Id);
            skillRequirementList.add(skillRequirement);
        }
        
        INSERT skillRequirementList;
        
        System.assertEquals(3, skillRequirementList.size());
        
        Test.stopTest();
    }
    
    
    /*
     * @Purpose: test method to cover englishTier2SkillId data 
     * @Parameters: none
     * @Return: void
     * */
    @isTest
    static void testMethod3(){
        Test.startTest();
        
        List<Account> accountList = [SELECT Id, Name 
                                     FROM Account];
        
        Case caseRecord = [SELECT Id, accountId 
                           FROM Case LIMIT 1];
        
        PendingServiceRouting pendingServiceRouting = [SELECT Id, WorkItemId, RoutingModel, RoutingPriority, LastModifiedDate, 
                                                       IsReadyForRouting, SecondaryRoutingPriority
                                                       FROM PendingServiceRouting
                                                       LIMIT 1];
        
        List<Skill> skillsList = [SELECT Id, MasterLabel FROM Skill 
                                  WHERE MasterLabel = 'English - Tier 2'];
        
        List<SkillRequirement> skillRequirementList = new List<SkillRequirement>();
        
        for(Skill skillRecord : skillsList){
            SkillRequirement skillRequirement = new SkillRequirement (RelatedRecordId = pendingServiceRouting.Id, SkillId = skillRecord.Id);
            skillRequirementList.add(skillRequirement);
        }
        
        INSERT skillRequirementList;
        
        System.assertEquals(1, skillRequirementList.size());
        
        Test.stopTest();
    }
    
    /*
     * @Purpose: test method to cover frenchTier2SkillId data 
     * @Parameters: none
     * @Return: void
     * */
    @isTest
    static void testMethod4(){
        Test.startTest();
        
        List<Account> accountList = [SELECT Id, Name 
                                     FROM Account];
        
        Case caseRecord = [SELECT Id, accountId 
                           FROM Case LIMIT 1];
        
        PendingServiceRouting pendingServiceRouting = [SELECT Id, WorkItemId, RoutingModel, RoutingPriority, LastModifiedDate, 
                                                       IsReadyForRouting, SecondaryRoutingPriority
                                                       FROM PendingServiceRouting
                                                       LIMIT 1];
        
        List<Skill> skillsList = [SELECT Id, MasterLabel FROM Skill 
                                  WHERE MasterLabel = 'French - Tier 2'];
        
        List<SkillRequirement> skillRequirementList = new List<SkillRequirement>();
        
        for(Skill skillRecord : skillsList){
            SkillRequirement skillRequirement = new SkillRequirement (RelatedRecordId = pendingServiceRouting.Id, SkillId = skillRecord.Id);
            skillRequirementList.add(skillRequirement);
        }
        
        INSERT skillRequirementList;
        
        System.assertEquals(1, skillRequirementList.size());
        
        Test.stopTest();
    }
    
    
    
    /*
     * @Purpose: method to create PendingServiceRouting records
     * @Parameters: workItemId
     * @Return: void
     * */
    public static PendingServiceRouting createPendingServiceRecord(String workItemId){
        ServiceChannel serviceChannel = [SELECT Id
                                         FROM ServiceChannel WHERE DeveloperName = 'Custom_Chat'
                                         LIMIT 1];
        
        PendingServiceRouting pendingServiceRouting = new PendingServiceRouting();
        pendingServiceRouting.RoutingModel = 'MostAvailable';
        pendingServiceRouting.WorkItemId = workItemId;
        pendingServiceRouting.RoutingPriority = 1;
        pendingServiceRouting.ServiceChannelId = serviceChannel.Id;
        pendingServiceRouting.RoutingType = 'SkillsBased';
        pendingServiceRouting.IsReadyForRouting = False;
        pendingServiceRouting.SecondaryRoutingPriority = 2;
        pendingServiceRouting.PushTimeout = 0;
        pendingServiceRouting.CapacityWeight = 2;

        return pendingServiceRouting;
    }
}