public class OrderExtractBatch implements Database.Batchable<Sobject> {
	String query = 'Select Id From Account';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> scope){
        try{ 
            
            for(sObject sobj : scope){ 
                List<String> csvRowValues = new List<String>();
                Account account = (Account)sobj;
                List<Order> orderRecords = [SELECT Id, Name, OrderNumber, Email__c, AccountId, CreatedDate FROM Order 
                                            WHERE AccountId =: account.Id ORDER By AccountId, Email__c 
                                            LIMIT 1000]; 
                
                if(orderRecords.size() == 1000){
                    for(Order order : orderRecords){ 
                        String rowStr = account.Id + ',' + order.Id + ',' + order.Name + ',' + order.OrderNumber + ',' + order.Email__c + ','+ order.CreatedDate ;
                        csvRowValues.add(rowStr);
                	}
                    
                    List<Document> doclist  = [SELECT Id, Name, DeveloperName, Body FROM Document Where Name = 'Order Extract'];
                
                    if(doclist != null && !doclist.isEmpty()){
                        document doc = doclist[0];
                        string strbody = doc.Body.toString();
                        strbody = strbody + '\n' + String.join(csvRowValues,'\n');
                        doc.Body = Blob.valueOf(strbody);
                        update doc;
                    }
                }
            } 
            
        }catch(Exception e){
            system.debug('Exception in processing orders:' + e);
        } 
        
    }
    
    public void finish(Database.BatchableContext BC){ 
    }
}