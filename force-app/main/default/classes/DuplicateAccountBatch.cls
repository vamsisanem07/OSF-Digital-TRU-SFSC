public class DuplicateAccountBatch implements Database.Batchable<Sobject>{ 
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id From Account Where Children_Count__c != 0 ';// AND Id IN : acclist LIMIT '+limistr; 
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> scope){
        try{ 
            for(sObject sobj : scope){
                Map<string, List<Child__c>> dupChilds = new Map<string, List<Child__c>>();
            	Map<account,List<string>> accUniqyuechildrens = new Map<account,List<string>>(); 
                List<String> csvRowValues = new List<String>();
                Account acc = (Account)sobj;
                List<Child__c> childRecordsToUpdate = new List<Child__c>();
                List<Child__c> childRecords = [SELECT Id, Duplicate_Record__c, Name, Account__c, Account__r.FirstName,Name__c, Account__r.LastName,  
                                               Birthday__c, Duplicate_Group__c, CreatedDate 
                                               FROM Child__c 
                                               WHERE Account__c =: acc.Id
                                               ORDER By Duplicate_Group__c];
                accUniqyuechildrens.put(acc, new List<string>());
                for(Child__c child : childRecords){
                    
                    if(dupChilds.containsKey(child.Duplicate_Group__c)){
                        child.Duplicate_Record__c = true;
                        childRecordsToUpdate.add(child);
                        dupChilds.get(child.Duplicate_Group__c).add(child);
                    }else{
                        dupChilds.put(child.Duplicate_Group__c, new List<Child__c>{child});
                        accUniqyuechildrens.get(acc).add(child.Duplicate_Group__c);
                    }
                } 
                
                for(String val : accUniqyuechildrens.get(acc)){
                    if(dupChilds.get(val).size() > 1){
                        for(Child__c child : dupChilds.get(val)){
                            string accId = child.Account__c;
                            string accName =  child.Account__r.FirstName + ' ' + child.Account__r.LastName;
                            string childName = child.Name__c;
                            string Birthdate = string.valueOf(child.Birthday__c);
                            string createdDate = child.CreatedDate.format('M/d/yyyy h:mm:ss a z'); 
                            
                            String rowStr = accId + ',' + accName + ',' + child.Duplicate_Group__c + ',' + child.Id + ',' + child.Name__c + ',' + Birthdate + ','+ createdDate ;
                            csvRowValues.add(rowStr);
                        }
                    } 
                } 
                
                /*String documentName = Label.Document_Name; 
                List<Document> doclist  = [SELECT Id, Name, DeveloperName, Body FROM Document Where Name =: documentName];
                
                if(doclist != null && !doclist.isEmpty()){
                    document doc = doclist[0];
                    string strbody = doc.Body.toString();
                    strbody = strbody + '\n' + String.join(csvRowValues,'\n');
                    doc.Body = Blob.valueOf(strbody);
                    update doc;
                }*/
                
                update childRecordsToUpdate;
            } 
            
        }catch(Exception e){
            system.debug('Exception Occured ==== '+ e);
        } 
        
    }
    
    public void finish(Database.BatchableContext BC){ 
    }
    
}