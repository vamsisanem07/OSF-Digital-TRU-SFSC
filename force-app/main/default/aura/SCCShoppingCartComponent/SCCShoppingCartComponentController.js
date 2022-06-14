({
    
    afterScriptsLoaded : function(component, event, helper) {
       console.warn('loaded');         
       var actionGetSession = component.get("c.getStoreSessionURL");
       actionGetSession.setCallback(this, function (response) {
           if(component.isValid() && response.getState() === 'SUCCESS') {
               component.set("v.storeSessionURL", response.getReturnValue());
           }
       });
       $A.enqueueAction(actionGetSession);
       
       var actionGetStorefront = component.get("c.getStoreFrontURL");
       actionGetStorefront.setCallback(this, function (response) {
           if(component.isValid() && response.getState() === 'SUCCESS') {
               component.set("v.storeFrontURL", response.getReturnValue());
           }
       });
       $A.enqueueAction(actionGetStorefront);        
    },

    openShoppingCart : function(component, event, helper) {
        component.set("v.Spinner", true); 
        var sessionURL;
        var storefrontURL;
        var recordId = component.get('v.recordId');  
	var objectName = component.get('v.sObjectName');
        var sessionURL = component.get("v.storeSessionURL");
        var storefrontURL = component.get("v.storeFrontURL");
        console.warn('recordId '+ recordId);

        var action = component.get('c.getAccessToken');
	action.setParams({recordId: recordId, objectName: objectName});
        action.setCallback(this, function (response) {
            var token = response.getReturnValue();
            if (component.isValid() && response.getState() === 'SUCCESS' && sessionURL && storefrontURL) {
				console.warn('Token Value ' + token);
                var $j = jQuery.noConflict();
                $j.ajax({
                    type: 'POST',
                    url: sessionURL,
                    headers: {
                        'Authorization': token,
                    },
                    dataType: 'json',
                    data: {},
                    xhrFields: {
                        withCredentials: true
                    },
                    success: function(responseData, status, xhr) {
                        // Open the storefront URL in a new window
                        component.set("v.Spinner", false);
                        window.open(storefrontURL); 
                    },
                    error: function(request, status, error) {
                        component.set("v.Spinner", false);
                        alert('Cannot Load Storefront, Please Contact Administrator');
                    }
                });                    
      		}else {
                component.set("v.Spinner", false);
                console.error(response);
            }
        });
        $A.enqueueAction(action);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       	// make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     	// make Spinner attribute to false for hide loading spinner    
       	component.set("v.Spinner", false);
    }    
})