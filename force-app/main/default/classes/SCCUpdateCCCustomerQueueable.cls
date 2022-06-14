global class SCCUpdateCCCustomerQueueable implements Queueable, Database.AllowsCallouts {
    
    private Id recordId;
    private String customerNo;
    private String accessToken;
    
    public SCCUpdateCCCustomerQueueable(Id recordId, String customerNo, String accessToken){
        this.recordId = recordId; 
        this.customerNo = customerNo;
        this.accessToken = accessToken;
        System.debug('SCCUpdateCCCustomerQueueable' + 'inputs: '+this.recordId+' : ' + this.customerNo);
    }
    
    global void execute(QueueableContext context){
        System.debug('SCCUpdateCCCustomerQueueable.execute');
        updateCCCustomerProfile(recordId, customerNo, accessToken);
    }
    
    @future(callout=true)
    private static void updateCCCustomerProfile(Id recordId, String customerNo, String accessToken){
        System.debug('SCCUpdateCCCustomerQueueable:updateCCCustomerProfile' + ' recordId: ' + recordId + ' customerNo: ' + customerNo);
        HttpResponse resp = SCCCommerceCloudConnect.updateCCCustomerProfile('{"c_sscid":"' + recordId + '"}', customerNo, accessToken);         
    }
}