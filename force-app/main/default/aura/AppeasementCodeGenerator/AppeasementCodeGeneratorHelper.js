({
    showToast : function(message, type) {  
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    
    showLoader: function(component) {
        component.set("v.isLoading", true);
    },
    
    hideLoader: function(component) {
        component.set("v.isLoading", false);
    }
})