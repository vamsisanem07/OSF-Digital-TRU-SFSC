({
    doInit : function(component) {
        var action = component.get("c.getCountryList");
        action.setCallback(this, function(response) {
            var countryMap = response.getReturnValue();
            component.set("v.countryMap", countryMap);
        })
        $A.enqueueAction(action);
    }
})