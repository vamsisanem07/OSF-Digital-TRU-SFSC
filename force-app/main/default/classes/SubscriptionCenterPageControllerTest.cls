@isTest
public class SubscriptionCenterPageControllerTest {
    
    public static testmethod void SubscriptionCenterPageControllerTest(){
        
        Account accountRec = new Account();
        //accountRec.IsPersonAccount = true;
        accountRec.FirstName = 'Test';
        accountRec.LastName = 'Test';
        accountRec.Language_Preference__c = 'EN';
        accountRec.Email_Opt_In_TRU__c = true;
        accountRec.Email_Opt_In_BRU__c = true;
        accountRec.PersonHasOptedOutOfEmail = true;
        accountRec.Toys_Toys_Items__c = 'Active Play & Outdoor;Books;Collectors - Grownups;Collectors - Kids;Education & Learning Toys Games;Preschool Playtime';
        accountRec.Baby_Baby_Items__c ='Baby Gear & Essentials;Nursury & Feeding;Pregnancy & Parenting;Safety, Health & Wellness;Toys & Activities';    
       
 
            
        Insert accountRec;
        
        Test.setCurrentPageReference(new PageReference('Page.SubscriptionCenterPage')); 
        System.currentPageReference().getParameters().put('id', accountRec.Id);
        System.currentPageReference().getParameters().put('unsub', 'true');
        
        SubscriptionCenterPageController testAccPlan = new SubscriptionCenterPageController();
       // testAccPlan.updateAccount();
               testAccPlan.toys = true;
               testAccPlan.activePlayOutdoor = true;
               testAccPlan.books = true;
               testAccPlan.collectorsGrownups = true;
               testAccPlan.collectorsKids = true;
               testAccPlan.educationLearningToysGames = true;
               testAccPlan.preschoolPlaytime = true;
               testAccPlan.baby = true;
               testAccPlan.babyGearEssentials = true;
			   testAccPlan.nurseryFeeding = true;          
               testAccPlan.pregnancyParenting = true;
               testAccPlan.safetyHealthWellness = true;
               testAccPlan.toysActivities = true;
               testAccPlan.clothing = true;
               testAccPlan.eventsAndActivities = true;
               testAccPlan.partyAndGiftGiving = true;
                   
                   
                   
        testAccPlan.updateOut();
        testAccPlan.accountunsub();
        testAccPlan.accountUpdate();
        testAccPlan.changeLanguage();
    }
    
    
}