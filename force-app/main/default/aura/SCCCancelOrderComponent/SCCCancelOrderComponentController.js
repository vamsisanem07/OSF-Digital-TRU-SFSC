({
   afterScriptsLoaded : function(component, event, helper) {
        var action = component.get('c.checkOrderStatus');
		var recordId = component.get('v.recordId');
		action.setParams({orderId: recordId});
        action.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                component.set("v.checkRecords", response.getReturnValue());
            }
            else {
                console.error(response);
            }
        });
        $A.enqueueAction(action);     
    },
 
    openCancelOrder : function(component, event, helper) {
        var spinner = component.find("spnr");
		//$A.util.toggleClass(spinner, "slds-show");
        var action = component.get('c.cancelledOrder');
        //var recordId = component.get('v.recordId');
        var orderID = component.get('v.orderNumber');
		//action.setParams({orderId: recordId});
        action.setParams({orderId: orderID});
        action.setCallback(this, function (response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
				if(response.getReturnValue() == true) {
                    //component.set("v.popupMessage", "Order has been successfully cancelled on Commerce Cloud only!!!");
                    helper.toastToDisplay("Success","Order has been successfully cancelled!!");
                    //$A.util.removeClass(spinner, "slds-show");
                } else {
                    //component.set("v.popupMessage", "Unexpected error. Please contact system administrative!!!");
                    helper.toastToDisplay("Warning","Order has been already cancelled!!");
                    //$A.util.removeClass(spinner, "slds-show");
                }
            }
            else {
                console.error(response);
                helper.toastToDisplay("Error","Unexpected error. Please contact system administrative!!!");
                //component.set("v.popupMessage", "Unexpected error. Please contact system administrative!!!");
                //$A.util.removeClass(spinner, "slds-show");
            }
        });
        $A.enqueueAction(action);
    },
    
    hidePopup: function(component, event, helper){
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
        $A.get('e.force:refreshView').fire();
    },
    
    openPopup :  function(component, event, helper){
        //called on clicking your button
        //run your form render code after that, run the following lines
        helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.showPopupHelper(component,'backdrop','slds-backdrop--');
    }
})