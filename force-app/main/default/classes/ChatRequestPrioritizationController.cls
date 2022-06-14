/*
    @Purpose        : Handler class to sort/prioritize the French chat requests over English
    @Created Date   : 21/01/2021
*/
public class ChatRequestPrioritizationController {
    public static void handleAfterInsert(){
        String englishSkillId, englishTier2SkillId, frenchTier2SkillId, frenchSkillId; 
        
        // Fetch the skill ids
        try{
            List<Skill> skillsList = [SELECT Id, MasterLabel FROM Skill 
                                      WHERE MasterLabel = 'English' OR MasterLabel = 'French' 
                                      OR MasterLabel = 'English - Tier 2' OR MasterLabel = 'French - Tier 2'];
        
            if(skillsList != null && !skillsList.isEmpty()){
                for(Skill skill : skillsList){
                    if(skill.MasterLabel == 'English'){
                        englishSkillId = skill.Id;
                    }
                    else if(skill.MasterLabel == 'French'){
                        frenchSkillId = skill.Id;
                    }
                    else if(skill.MasterLabel == 'English - Tier 2'){
                        englishTier2SkillId = skill.Id;
                    }
                    else if(skill.MasterLabel == 'French - Tier 2'){
                        frenchTier2SkillId = skill.Id;
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Exception in fetching skills records : ' + e.getMessage());
        }
        
        Map<String, List<PendingServiceRouting>> skillToRoutingListMap = new Map<String, List<PendingServiceRouting>>();
        List<PendingServiceRouting> pendingServiceRoutingList = new List<PendingServiceRouting>();
        List<PendingServiceRouting> recordsToUpdate = new List<PendingServiceRouting>();
        
        try{
            pendingServiceRoutingList = [SELECT Id, WorkItemId, RoutingModel, RoutingPriority, LastModifiedDate, 
                                         IsReadyForRouting, SecondaryRoutingPriority, 
                                            (SELECT Id, SkillId FROM SkillRequirements)
                                         FROM PendingServiceRouting
                                         WHERE IsPushed = false AND RoutingType = 'SkillsBased' 
                                         ORDER BY LastModifiedDate
                                         LIMIT 10000];
        }
        catch(Exception e){
            System.debug('Exception in fetching PendingServiceRouting list: ' + e.getMessage());
        }
        
        skillToRoutingListMap.put(englishSkillId, new List<PendingServiceRouting>());
        skillToRoutingListMap.put(englishTier2SkillId, new List<PendingServiceRouting>());
        skillToRoutingListMap.put(frenchTier2SkillId, new List<PendingServiceRouting>());
        skillToRoutingListMap.put(frenchSkillId, new List<PendingServiceRouting>()); 
        
        for(PendingServiceRouting routing: pendingServiceRoutingList){ 
            
            if(routing.SkillRequirements != null && !routing.SkillRequirements.isEmpty()){
                if(routing.SkillRequirements[0].SkillId == englishSkillId){
                    skillToRoutingListMap.get(englishSkillId).add(routing);
                }
                else if(routing.SkillRequirements[0].SkillId == frenchSkillId){
                    skillToRoutingListMap.get(frenchSkillId).add(routing);
                }
                else if(routing.SkillRequirements[0].SkillId == englishTier2SkillId){
                    skillToRoutingListMap.get(englishTier2SkillId).add(routing);
                }
                else if(routing.SkillRequirements[0].SkillId == frenchTier2SkillId){
                    skillToRoutingListMap.get(frenchTier2SkillId).add(routing);
                }
            }
        }
         
        
        Integer priority = 1;
        
        if(!skillToRoutingListMap.get(frenchTier2SkillId).isEmpty()){
            for(PendingServiceRouting routing: skillToRoutingListMap.get(frenchTier2SkillId)){
                routing.SecondaryRoutingPriority = priority;
                priority++;
            }
        }
        
        if(!skillToRoutingListMap.get(englishTier2SkillId).isEmpty()){
            for(PendingServiceRouting routing: skillToRoutingListMap.get(englishTier2SkillId)){
                routing.SecondaryRoutingPriority = priority;
                priority++;
            }
        }
        
        if(!skillToRoutingListMap.get(frenchSkillId).isEmpty()){
            for(PendingServiceRouting routing: skillToRoutingListMap.get(frenchSkillId)){
                routing.SecondaryRoutingPriority = priority;
                priority++;
            }
        }
        
        if(!skillToRoutingListMap.get(englishSkillId).isEmpty()){
            for(PendingServiceRouting routing: skillToRoutingListMap.get(englishSkillId)){
                routing.SecondaryRoutingPriority = priority;
                priority++;
            }
        }
        
        try{
            recordsToUpdate.addAll(skillToRoutingListMap.get(englishSkillId));
            recordsToUpdate.addAll(skillToRoutingListMap.get(frenchSkillId));
            recordsToUpdate.addAll(skillToRoutingListMap.get(englishTier2SkillId));
            recordsToUpdate.addAll(skillToRoutingListMap.get(frenchTier2SkillId));
            
            update recordsToUpdate;
        }
        catch(Exception e){
            System.debug('Exception in updating PendingServiceRouting list: ' + e.getMessage());
        }
    }
}