global class OSF_AccountOrderMappingBatchJobClass implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Email__c,AccountId FROM Order WHERE Email != NULL');
    }  
    global void execute (Database.BatchableContext BC, List<Order> scope){
        Set<String> emailIdSet = new Set<String>();  
        for(Order odr :scope){        
            emailIdSet.add(odr.Email__c);
        }
        Map<String, Id> emailAccountIdMap = new Map<String,Id>();
        for(Account ac: [SELECT Id,PersonEmail FROM Account WHERE PersonEmail IN:emailIdSet AND isPersonAccount = TRUE]){
            emailAccountIdMap.put(ac.PersonEmail,ac.Id);
        }
        if(emailAccountIdMap != NULL && emailAccountIdMap.size()>0){
            List<Account> accountList = new List<Account>();
            List<Order> updateOrderList = new List<Order>();
            Set<String> orderEmailSet = new Set<String>();
            for(Order odr :scope){
                if( emailAccountIdMap.containsKey( odr.Email__c)){
                    odr.AccountId =emailAccountIdMap.get(odr.Email__c);
                    updateOrderList.add(odr);
                }
                
                else{
                    if(!orderEmailSet.contains(odr.Email__c)){
                    Account ac = new Account();
                    ac.PersonEmail = odr.Email__c;
                    accountList.add(ac);
                    orderEmailSet.add(odr.Email__c);
                    }
                }
            }
            if(accountList != NULL && accountList.size()>0){
                insert accountList;
            }
            if(updateOrderList != NULL && updateOrderList.size()>0){
                update updateOrderList;
            }
        }        
    }
    
    global void finish (Database.BatchableContext BC){
    }
}