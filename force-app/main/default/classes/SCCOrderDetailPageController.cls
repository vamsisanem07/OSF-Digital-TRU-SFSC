public class SCCOrderDetailPageController  {

    public Order record                         {get; set;}
    public String orderNumber                   {get; set;}
    public String orderId                       {get; set;}
    public String errorMessage                  {get; set;}
    public List<OrderWrapper> orderList         {get; set;}
    public List<ShippingWrapper> shippingList   {get; set;}
    public Map<String, Object> jsonMap          {get; set;}
    public List<String> fieldsList = new List<String>{'SFCC_Order_Number__c', 'Order_Contact__c', 'Status', 'OrderNumber', 'SFCC_Order_Total__c', 'Order_SCCSync_Status__c', 'CreatedBy', 'CreatedDate', 'LastModifiedBy', 'LastModifiedDate'};
    public Map<String, String> jsonKeyMap = new Map<String, String>{    'shipping_status'=>'Shipping Status', 
                                                                        'export_status'=>'Export Status', 
                                                                        'confirmation_status'=>'Confirmation Status', 
                                                                        'status'=>'Order Status'
                                                                    };

    public SCCOrderDetailPageController(ApexPages.StandardController std) {

        if(!Test.isRunningTest()) {
            std.addFields(fieldsList);
        }
        this.record = (Order)std.getRecord();
        orderId = this.record.Id;
        if(!String.isBlank(this.record.SFCC_Order_Number__c)) {
            orderNumber = this.record.SFCC_Order_Number__c;
        } else {
            orderNumber = '';
        }
        errorMessage = '';
        orderList = new List<OrderWrapper>();
        shippingList = new List<ShippingWrapper>();
        jsonMap = new Map<String, Object>();

    }

    public List<OrderWrapper> getOrders() {
        
        try {
            List<OrderWrapper> returnList = new List<OrderWrapper>();
            String resBody = SCCCommerceCloudConnect.getOrderDetails(orderNumber, SCCCommerceCloudConnect.connectToCommerceCloud());
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            for(String key : jsonMap.keySet()) {
                if(jsonKeyMap.keySet().contains(key) && key.contains('status')) {
                    returnList.add(new OrderWrapper(jsonKeyMap.get(key), ((String)jsonMap.get(key)).replace('_', ' ')));
                }
            }
            orderList.addAll(returnList);
            shippingList.addAll(getShippings(jsonMap));
            return returnList;
        } catch(Exception e) {
            errorMessage = e.getMessage();
            orderList.clear();
            System.debug('errorMessage ==>> ' + e.getMessage());
            System.debug('stack_trace ==>> ' + e.getStackTraceString());
            return new List<OrderWrapper>();
        }

    }

    public List<ShippingWrapper> getShippings(Map<String, Object> jsonMap) {

        List<ShippingWrapper> returnList = new List<ShippingWrapper>();
        List<Object> shipmentList = (List<Object>)jsonMap.get('shipments');
        List<Object> productList = (List<Object>)jsonMap.get('product_items');
        for(Object shipmentObj : shipmentList) {
            Map<String, Object> shipmentMap = (Map<String, Object>)shipmentObj;
            List<ProductWrapper> productWrapperList = new List<ProductWrapper>();
            for(Object productObj : productList) {
                Map<String, Object> productMap = (Map<String, Object>)productObj;
                if((String)shipmentMap.get('shipment_id') == (String)productMap.get('shipment_id')) {
                    Decimal taxRate = (Decimal)productMap.get('tax_rate') * 100;
                    productWrapperList.add(new ProductWrapper(String.valueOf(productMap.get('quantity')), String.valueOf(productMap.get('product_id')), String.valueOf(productMap.get('item_text')), String.valueOf(taxRate), String.valueOf(productMap.get('price')), String.valueOf(productMap.get('tax_basis')), String.valueOf(productMap.get('price'))));
                }
            }
            returnList.add(new ShippingWrapper(String.valueOf(shipmentMap.get('shipment_no')), String.valueOf(shipmentMap.get('shipping_total')), String.valueOf(shipmentMap.get('shipping_total')), String.valueOf(shipmentMap.get('shipping_total')), String.valueOf(shipmentMap.get('tax_total')), String.valueOf(shipmentMap.get('shipment_total')), productWrapperList));
        }
        return returnList;

    }

    public class OrderWrapper {
        
        public String name          {get; set;}
        public String value         {get; set;}
        
        public OrderWrapper(String name, String value) {

            this.name       = name;
            this.value      = value;

        }

    }

    public class ShippingWrapper {

        public String shippingNo                {get; Set;}
        public String shippingCost              {get; set;}
        public String shippingCostTotal         {get; set;}
        public String shippingTotal             {get; set;}
        public String taxTotal                  {get; set;}
        public String total                     {get; set;}
        public List<ProductWrapper> products    {get; set;}

        public ShippingWrapper(String shippingNo, String shippingCost, String shippingCostTotal, String shippingTotal, String taxTotal, String total, List<ProductWrapper> products) {
            
            this.shippingNo         = shippingNo;
            this.shippingCost       = shippingCost;
            this.shippingCostTotal  = shippingCostTotal;
            this.shippingTotal      = shippingTotal;
            this.taxTotal           = taxTotal;
            this.total              = total;
            this.products           = products;

        }

    }

    public class ProductWrapper {

        public String quantity          {get; set;}
        public String productId         {get; set;}
        public String productName       {get; set;}
        public String taxRate           {get; set;}
        public String unitSalesPrice    {get; set;}
        public String taxBasis          {get; set;}
        public String itemTotal         {get; set;}

        public ProductWrapper(String quantity, String productId, String productName, String taxRate, String unitSalesPrice, String taxBasis, String itemTotal) {

            this.quantity       = quantity;
            this.productId      = productId;
            this.productName    = productName;
            this.taxRate        = taxRate;
            this.unitSalesPrice = unitSalesPrice;
            this.taxBasis       = taxBasis;
            this.itemTotal      = itemTotal;

        }

    }

}