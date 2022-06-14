({
    handleInit : function(component, event, helper) { 
        let prechatFields = component.find("prechatAPI").getPrechatFields();            
        let emailAddress = prechatFields[2].value;
        let language = prechatFields[3].value;
        let entrySite = prechatFields[4].value; 
        console.log('entrysite---', entrySite);
        
        if(language){
            component.set("v.language", language);
        }  
        
        if(emailAddress){
            component.set("v.isLoggedIn", true); 
            let params = [
                {
                    "label": "First Name",
                    "value": component.get("v.firstName"),
                    "name": "FirstName"
                },
                {
                    "label": "Last Name",
                    "value": component.get("v.lastName"),
                    "name": "LastName"
                },
                {
                    "label": "Email",
                    "value": emailAddress,
                    "name": "Email"
                },
                {
                    "label": "Chat Language",
                    "value": language,
                    "name": "Chat_Language__c"
                },
                {
                    "label": "Entry Site",
                    "value": entrySite,
                    "name": "Entry_Site__c"
                }
            ];
            
            let prechatApi = component.find("prechatAPI");
            let isValid = prechatApi.validateFields(params).valid; 
            if (isValid) {
                prechatApi.startChat(params);    
            }            
        }
        else{
            component.set("v.isLoggedIn", false);
        }
    },
    
    handleStartChat : function(component, event, helper) {
        let prechatFields = component.find("prechatAPI").getPrechatFields(); 
        let language = prechatFields[3].value;
        let entrySite = prechatFields[4].value;
        console.log('entrySite--', entrySite);
        let params = [
            {
                "label": "First Name",
                "value": component.get("v.firstName"),
                "name": "FirstName"
            },
            {
                "label": "Last Name",
                "value": component.get("v.lastName"),
                "name": "LastName"
            },
            {
                "label": "Email",
                "value": component.get("v.email"),
                "name": "Email"
            },
            {
                "label": "Chat Language",
                "value": language,
                "name": "Chat_Language__c"
            },
            {
                "label": "Entry Site",
                "value": entrySite,
                "name": "Entry_Site__c"
            }
        ];
        
        let prechatApi = component.find("prechatAPI");
        let isValid = prechatApi.validateFields(params).valid; 
        var mailformat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        
        if (isValid) {            
            var firstname = component.find("firstname");
            var lastname = component.find("lastname");
            var email = component.find("email");
            var validForm = true;
            
            if(!firstname.get("v.validity").valid){
                validForm = false;
                firstname.showHelpMessageIfInvalid();
            } 
            
            if(!lastname.get("v.validity").valid) {
                validForm = false;
                lastname.showHelpMessageIfInvalid();
            } 
            
            if(!email.get("v.validity").valid){
                validForm = false;
                email.showHelpMessageIfInvalid();
               }
            
            if(!email.get("v.value").match(mailformat)){
                validForm = false;
                
                email.setCustomValidity($A.get("$Label.c.Pre_Chat_Enter_Valid_Email_Message") );
                email.reportValidity();
            }else {
                validForm = true;
                email.setCustomValidity("");
                email.reportValidity();
                
            }
            
            if(validForm){
                prechatApi.startChat(params);    
            }
        }            
    }
})