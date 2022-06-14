({
	afterScriptsLoaded : function(component, event, helper) {
        console.warn('loaded');
        var action = component.get('c.getCustomers');
        var recordId = component.get('v.recordId');
        console.log(recordId);
        action.setParams({objectId: recordId});
        action.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                component.set("v.customerDetails", response.getReturnValue());   
                console.log(response.getReturnValue().length);
                if(response.getReturnValue().length != 0) {
                    component.set("v.checkRecords", true);
                }
                console.log(component.get("v.checkRecords"));
            }
            else {
                console.error(response);
            }
        });
        $A.enqueueAction(action);     
    },
    
    openSyncCust : function(component, event, helper) {
        component.set("v.syncstatus", "Processing...");
        var spinner = component.find("spnr");
        $A.util.toggleClass(spinner, "slds-show");
        var action = component.get('c.syncCustomer');
        var recordId = component.get('v.recordId');
        action.setParams({objectId: recordId});
        action.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                if(response.getReturnValue() == true) {
                    $A.util.removeClass(spinner, "slds-show");
                    $A.get('e.force:refreshView').fire(); 
                    component.set("v.syncstatus", "Synchronised");
                }else{
                    component.set("v.syncstatus", "No remote data");
                }
            }
            else {
                console.error(response);
                $A.util.removeClass(spinner, "slds-show");
                component.set("v.syncstatus", "Failed");
            }
        });
        $A.enqueueAction(action);  
	}
})