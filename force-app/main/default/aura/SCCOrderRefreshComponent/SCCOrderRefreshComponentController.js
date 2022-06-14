({
    afterScriptsLoaded : function(component, event, helper) {
        var action = component.get("c.getOrders");
		action.setParams({ orderId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") { 
                if(response.getReturnValue().length != 0) {
                    component.set("v.checkRecords", true);
                }
                component.set("v.orders",response.getReturnValue());
            }
        });
    	$A.enqueueAction(action);    
    },
    
	handleClick : function(component, event, helper) {
        var spinner = component.find("spnr");
        $A.util.toggleClass(spinner, "slds-show");
        var action = component.get('c.syncOrder');
        action.setParams({ orderId : component.get("v.recordId") });
        action.setCallback(this, function (response) {
            debugger;
            if(component.isValid() && response.getState() === 'SUCCESS') {
                if(response.getReturnValue() == true) {
                    $A.util.removeClass(spinner, "slds-show");
                    $A.get('e.force:refreshView').fire();     
                }
            } else {
                console.error(response);
                $A.util.removeClass(spinner, "slds-show");
            }
        });
        $A.enqueueAction(action);  
	}
    
})