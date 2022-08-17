global class OSF_AccountOrderMappingBatchJobClass implements Database.Stateful,Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Email__c,AccountId FROM Order WHERE Email != NULL');
    }  
    global void execute (Database.BatchableContext BC, List<Order> scope){
        Set<String> emailIdSet = new Set<String>(); 
        Map<String, Id> emailAccountIdMap = new Map<String,Id>();
        List<Order> updateOrderList = new List<Order>();

        for(Order odr :scope){        
            emailIdSet.add(odr.Email__c);
        }     
        for(Account ac: [SELECT Id,PersonEmail FROM Account WHERE PersonEmail IN:emailIdSet AND isPersonAccount = TRUE]){
            emailAccountIdMap.put(ac.PersonEmail,ac.Id);
        }
        if(emailAccountIdMap != NULL && emailAccountIdMap.size()>0){
          //List<Account> accountList = new List<Account>();
           // Set<String> orderEmailSet = new Set<String>();
            for(Order odr :scope){
                if( emailAccountIdMap.containsKey( odr.Email__c)){
                    odr.AccountId = emailAccountIdMap.get(odr.Email__c);
                    updateOrderList.add(odr);
                }
            
            }
            //if(accountList != NULL && accountList.size()>0){
              //  insert accountList;
          //  }
            if(updateOrderList != NULL && updateOrderList.size()>0){
                Database.update(updateOrderList);
            }
        }        
    }
    
    global void finish (Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
      // Send an email to the Apex job's submitter notifying of job completion.
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {'vamsi.sanem@osf.digital'};
      mail.setToAddresses(toAddresses);
      mail.setSubject('Error in Account Order Mapping Batch Job');
      mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}