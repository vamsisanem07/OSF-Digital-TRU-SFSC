/**
* Lightning component controller for refreshing order with sfcc
* 
*
* @author  Neeraj Yadav
* @version 1.0
*/
public class SCCOrderRefreshPageController  {

    //related order record
    public static Order record;
    //order number for commerce cloud
    public static String orderNo                       {get; set;}
    //user friendly message of error
    public static String errorMessage                  {get; set;}
    //order informations
    public static List<SCCOrderWrapper> orderList        {get; set;}
    //json map after deserialization
    public static Map<String, Object> jsonMap          {get; set;}
    //json key - label mapping
    public static Map<String, String> jsonKeyMap = new Map<String, String>{		'c_sscid'=>'Contact Id', 
																				'order_no'=>'Order Number', 
																				'order_total'=>'Order Total', 
																				'status'=>'Status', 
																				'currency'=>'Currency', 
																				'customer_name'=>'Customer Name', 
																				'taxation'=>'Taxation'
																		  };


    /**
    * This method used to getting order informations from commerce cloud
    * @return List<kOrderWrapper>.
    */
    @AuraEnabled
    public static List<SCCOrderWrapper> getOrders(String orderId) {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        orderList = new List<SCCOrderWrapper>();
        jsonMap = new Map<String, Object>();
        try {
            
            Order order = [SELECT Id, Name, SFCC_Order_Total__c, SFCC_Order_Number__c FROM Order WHERE Id =: orderId];
            orderNo = order.SFCC_Order_Number__c;
            List<SCCOrderWrapper> returnList = new List<SCCOrderWrapper>();
            String resBody = SCCCommerceCloudConnect.getOrderDetails(orderNo, SCCCommerceCloudConnect.connectToCommerceCloud());
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            for(String key : jsonMap.keySet()) {
                if(jsonKeyMap.keySet().contains(key)) {
                    returnList.add(new SCCOrderWrapper(jsonKeyMap.get(key), String.valueOf(jsonMap.get(key))));
                }
            }
            orderList.addAll(returnList);
            return returnList;
        } catch(Exception e) {
            orderList.clear();
            errorMessage = e.getMessage();
            logger.error('SCCOrderRefreshPageController.getOrders', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());   
            return new List<SCCOrderWrapper>();
        }finally{
            logger.flush();
        }
    }

    /**
    * This method used to synchonized with order(sfcc) and order(sfsc)
    * @return None.
    */
    @AuraEnabled
    public static Boolean syncOrder(String orderId) { 
		return SCCOrderImpl.syncOrder(orderId);
    }

}