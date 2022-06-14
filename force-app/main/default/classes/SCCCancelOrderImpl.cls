/**
 * This Implementation is implement to handle case management through Trigger. 
 * This is not fully implemented but left code for future references. 
 * 
 * 
 */

public class SCCCancelOrderImpl implements SCCTriggerHandlerInterface {
    

    public void onBeforeInsert(List<SObject> newList) {

        //checkCancelCaseNumber(newList);
        //checkOrderStatus(newList);
    
	}

    public void onAfterInsert(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
		//updateOrderStatus(newMap.values());
    
	}

    /* Commented unused section
    public void checkCancelCaseNumber(List<SObject> newList) {
        
        List<Case> caseList = (List<Case>)newList;
        Map<Id, Id> contactIdMap = new Map<Id, Id>();
        Map<Id, Id> orderIdMap = new Map<Id, Id>();
        for(Case c : caseList) {
            contactIdMap.put(c.Id, c.ContactId);
            orderIdMap.put(c.Id, c.Order__c);
        }
        String query = SCCQueryUtilClass.getInstance()
                                      .getQueryInstance()
                                      .setObjectName('Case')
                                      .setAllFields()
                                      .setClause('ContactId', 'IN', '(\'' + String.join(contactIdMap.values(), '\',\'') + '\') AND ')
									  .setClause('Order__c', 'IN', '(\'' + String.join(orderIdMap.values(), '\',\'') + '\') AND ')
									  .setClause('RecordType.Name', '=', '\'Cancel Order\'')
                                      .getQuery();
        List<Case> cancelCaseList = (List<Case>)SCCQueryUtilClass.getRecords(query);
        Map<Id, List<Case>> contactMap = new Map<Id, List<Case>>();
        for(Case cs_c : cancelCaseList) {
            if(contactMap.containsKey(cs_c.ContactId)) {
                List<Case> tempList = contactMap.get(cs_c.ContactId);
                tempList.add(cs_c);
                contactMap.put(cs_c.ContactId, tempList);
            } else {
                contactMap.put(cs_c.ContactId, new List<Case>{cs_c});
            }
        }
        Map<Id, List<Case>> orderMap = new Map<Id, List<Case>>();
        for(Case cs_o : cancelCaseList) {
            if(orderMap.containsKey(cs_o.Order__c)) {
                List<Case> tempList = orderMap.get(cs_o.Order__c);
                tempList.add(cs_o);
                orderMap.put(cs_o.Order__c, tempList);
            } else {
                orderMap.put(cs_o.Order__c, new List<Case>{cs_o});
            }
        }
        for(Case rec : caseList) {
            if(contactMap.containsKey(rec.ContactId) && orderMap.containsKey(rec.Order__c)) {
                rec.addError('There is already case with Cancel Order type!!!');
            }
        }

    }

    public void updateOrderStatus(List<Case> newList) {

        Set<Id> orderIdSet = new Set<Id>();
        for(Case c : newList) {
            if(null != c.Order__c) {
                orderIdSet.add(c.Order__c);
            }
        }
        List<Id> orderIdList = new List<Id>();
        orderIdList.addAll(orderIdSet);
        String query = SCCQueryUtilClass.getInstance()
                                      .getQueryInstance()
                                      .setObjectName('Order')
                                      .setAllFields()
                                      .setClause('Id', 'IN', '(\'' + String.join(orderIdList, '\',\'') + '\')')
                                      .getQuery();
        Map<Id, Order> orderMap = new Map<Id, Order>((List<Order>)SCCQueryUtilClass.getRecords(query));
        List<Order> updatedOrderList = new List<Order>();
        for(Id key : orderMap.keySet()) {
            orderMap.get(key).Status = 'Cancelled';
            updatedOrderList.add(orderMap.get(key));
        }
        if(!updatedOrderList.isEmpty()) {
            Database.update(updatedOrderList, true);
        }

    }

    
    public void checkOrderStatus(List<SObject> newList) {
        
        List<Case> caseList = (List<Case>)newList;
        Set<Id> orderIdSet = new Set<Id>();
        for(Case c : caseList) {
            if(null != c.Order__c) {
                orderIdSet.add(c.Order__c);
            }
        }
        List<Id> orderIdList = new List<Id>();
        orderIdList.addAll(orderIdSet);
        String query = SCCQueryUtilClass.getInstance()
                                      .getQueryInstance()
                                      .setObjectName('Order')
                                      .setAllFields()
                                      .setClause('Id', 'IN', '(\'' + String.join(orderIdList, '\',\'') + '\')')
                                      .getQuery();
        Map<Id, Order> orderMap = new Map<Id, Order>((List<Order>)SCCQueryUtilClass.getRecords(query));
        for(Case cs : caseList) {
            if(orderMap.containsKey(cs.Order__c)) {
                if(orderMap.get(cs.Order__c).Status == 'Cancelled') {
                    cs.addError('Order status is already cancelled!!!');
                }
            }
        }
    
    } 
	*/
}