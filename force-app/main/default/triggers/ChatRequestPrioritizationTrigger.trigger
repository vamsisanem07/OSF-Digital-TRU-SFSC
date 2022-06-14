/*
	@Purpose		: Trigger on Skill Requirement to sort/prioritize the French chat requests
	@Created Date	: 21/01/2021
*/
trigger ChatRequestPrioritizationTrigger on SkillRequirement (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        ChatRequestPrioritizationController.handleAfterInsert();
	}
}