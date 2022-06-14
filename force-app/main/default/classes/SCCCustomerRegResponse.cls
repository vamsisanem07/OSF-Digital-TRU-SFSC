/**
* response class for rest services - post methods
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-14 
*/
global with sharing class SCCCustomerRegResponse {
        private String objectType                       {get; set;}
        private String recordId                         {get; set;}
        private String SFCCCustomerId                   {get; set;}
        private String SFCCCustomerNo                   {get; set;}
        private String personContactId                  {get; set;}
        private Map<String, String> additionalFields    {get; set;}
        private SCCErrorHandlingTemplate errors         {get; set;}
        
        /**
        * This is the constructor for SCCReturnResponse class.
        * @param recordId String
        * @return None.
        */
        public SCCCustomerRegResponse() {  }
                
                /**
        * This is the constructor for SCCReturnResponse class.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerRegResponse(String recordId, String objectType, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.objectType     = objectType;
            this.errors         = errors;
        }
                
        /**
        * This is the constructor for SCCReturnResponse class.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerRegResponse(String recordId, String customerNo, String objectType, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.SFCCCustomerNo = customerNo;             
            this.objectType     = objectType;
            this.errors         = errors;
        }
    
        /**
        * This is the constructor for SCCReturnResponse class used for Account/Contact objects.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerRegResponse(String recordId, String objectType, String customerId, String customerNo, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.objectType     = objectType;
            this.SFCCCustomerId = customerId;
            this.SFCCCustomerNo = customerNo;   
            this.errors         = errors;
        }


        /**
        * This is the constructor for SCCReturnResponse class used for Account objects with PersonContactId and additional fields.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerRegResponse(String recordId, String objectType, String customerId, String customerNo, String personContactId, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.objectType     = objectType;
            this.SFCCCustomerId = customerId;
            this.SFCCCustomerNo = customerNo;
            this.personContactId = personContactId;
            this.errors         = errors;
        }

        /**
        * This is the constructor for SCCReturnResponse class used for Account objects with PersonContactId and additional fields.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerRegResponse(String recordId, String objectType, String customerId, String customerNo, String personContactId, Map<String, String> additionalFields, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.objectType     = objectType;
            this.SFCCCustomerId = customerId;
            this.SFCCCustomerNo = customerNo;
            this.personContactId = personContactId;
            this.additionalFields = additionalFields;
            this.errors         = errors;
        }

    /**
    * This method used for creating json text for response of rest services.
    * @param recordId: Id
    * @return SCCReturnResponse.
    */
        public static SCCCustomerRegResponse createResponse(Id recordId) {
            return new SCCCustomerRegResponse((String)recordId, recordId.getSObjectType().getDescribe().getLabel(), null); 
        }
                
                
        /**
        * This method used for creating json text for response of rest services.
        * @param recordId: Id
        * @return SCCReturnResponse.
        */
        public static SCCCustomerRegResponse createResponse(Sobject record) {
            String objectType = record.getSObjectType().getDescribe().getLabel();
            if(objectType.equalsIgnoreCase('Account')){
                Account obj = (Account)record;
                return new SCCCustomerRegResponse((String)obj.Id, obj.getSObjectType().getDescribe().getLabel(), obj.SFCC_Customer_Id__pc, obj.SFCC_Customer_Number__pc, obj.PersonContactId, null);
            }else if(objectType.equalsIgnoreCase('Contact')){
                Contact obj = (Contact)record;
                return new SCCCustomerRegResponse((String)obj.Id, obj.getSObjectType().getDescribe().getLabel(), obj.SFCC_Customer_Id__c, obj.SFCC_Customer_Number__c, null);            
            }else{
                return new SCCCustomerRegResponse((String)record.Id, record.getSObjectType().getDescribe().getLabel(), null);            
            } 
        }

    /**
        * This method used for creating json text for response of rest services.
        * @param recordId: Id
        * @param fieldMappings: Id
        * @return SCCReturnResponse.
        */
    public static SCCCustomerRegResponse createResponse(Sobject record, Map<String, SObject> fieldMappings) {
        String objectType = record.getSObjectType().getDescribe().getLabel();
        if(objectType.equalsIgnoreCase('Account')){
            Account obj = (Account)record;
            Map<String, String> additionalField = SCCUtilityClass.getPreparedAdditionalFields(record, fieldMappings);
            return new SCCCustomerRegResponse((String)obj.Id, obj.getSObjectType().getDescribe().getLabel(), obj.SFCC_Customer_Id__pc, obj.SFCC_Customer_Number__pc, obj.PersonContactId, additionalField, null);
        }

        return null;
    }

    /**
    * This method used for creating json text if there is error on processing.
    * @param e: Exception
    * @return SCCReturnResponse.
    */
        public static SCCCustomerRegResponse createError(Exception e) {
            return new SCCCustomerRegResponse(null, null, SCCErrorHandlingTemplate.createError(e)); 
        } 
    
        /**
        * This method used for creating json text if there is error on processing.
        * @param e: Exception
        * @return SCCReturnResponse.
        */
        public static SCCCustomerRegResponse createError(String customerNo, Exception e) {
            return new SCCCustomerRegResponse(null, customerNo, null, SCCErrorHandlingTemplate.createError(e)); 
        }    
    }