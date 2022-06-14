public class SCCCancelledOrderComponentController {
 
	/**
    * This method used to getting order informations and check the shipment status
	* @param orderId: String
    * @return Boolean.
    */
    @AuraEnabled
    public static Boolean checkOrderStatus(String orderId) {
       	SCCFileLogger logger = SCCFileLogger.getInstance();
        try {
             String query = SCCQueryUtilClass.getInstance()
										  .getQueryInstance()
										  .setObjectName('Order')
										  .setAllFields()
										  .setClause('Id', '=', '\'' + orderId + '\'')
										  .setLimit('1')
										  .getQuery();
			List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query);
            if(orderList[0].Shipment_Status__c == 'not_shipped') {
				return true;
            }
            return false;
		} catch(Exception e) {
            logger.error('SCCCancelledOrderComponentController.checkOrderStatus', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			return false;
		}finally{
			//logger.flush();
		}
    }

	/**
    * This method used to cancelled order and update order to commerce cloud and service cloud
	* @param orderId: String
    * @return Boolean.
    */
    @AuraEnabled
    public static Boolean cancelledOrder(String orderId) {
        SCCFileLogger logger = SCCFileLogger.getInstance();
		try {
           	String query = SCCQueryUtilClass.getInstance()
										  .getQueryInstance()
										  .setObjectName('Order')
										  .setAllFields()
										  .setClause('Id', '=', '\'' + orderId + '\'')
										  .setLimit('1')
										  .getQuery();
			List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query);
           	if (orderList[0].Status != 'Cancelled')
            {
           	    String responseBody = SCCCommerceCloudConnect.pushOrderDetails('{"status":"cancelled"}', orderList[0].SFCC_Order_Number__c, SCCCommerceCloudConnect.connectToCommerceCloud());
			    logger.debug('SCCCancelledOrderComponentController.cancelledOrder', 'responseBody: '+ responseBody); 
				orderList[0].Status = 'Cancelled';
            	Database.update(orderList, true);
                return true;
            }
            return false;
        }
		catch(Exception e) {
            logger.error('SCCCancelledOrderComponentController.cancelledOrder', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			return false;
		} finally{
			logger.flush();			
		}
    }
}