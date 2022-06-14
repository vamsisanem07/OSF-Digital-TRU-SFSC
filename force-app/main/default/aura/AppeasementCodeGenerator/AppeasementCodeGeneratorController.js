({
    doInit : function(component, event, helper) {
        if($A.get("$Locale.language") == 'fr'){
            component.set("v.buttonTitle", 'Obtenir le code d\'apaisement');
        }
        else{
            component.set("v.buttonTitle", 'Get Appeasement Code');
        }
        
        helper.showLoader(component);
        var action = component.get("c.getUserRole");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentUserRoleId", result);
                helper.hideLoader(component);
            }
            else{
                helper.hideLoader(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCode : function(component, event, helper) {
        var action = component.get("c.getAvailableAppeasementCode");
        helper.showLoader(component);
        action.setParams({ appeasementId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var messageStr = response.getReturnValue();
                
                if(messageStr && (messageStr.includes("Success") || messageStr.includes("Succès"))){
                    helper.hideLoader(component);
                    helper.showToast(messageStr, "success"); 
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    helper.showToast(messageStr, "error"); 
                    helper.hideLoader(component);
                }
            }
            else{
                helper.showToast("Error! Failed to get the Appeasement Code.", "error"); 
                helper.hideLoader(component);
            }
        });
        
        $A.enqueueAction(action);
    }
})