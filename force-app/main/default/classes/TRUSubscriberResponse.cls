/**
 * Created by i.yefremov on 23.07.2019.
 */

global with sharing class TRUSubscriberResponse {

    /** response should be in this form:
    {
        "objectType": "PersonAccount",
        "recordId": "18-digit Account ID",
        "SFCCCustomerId": "Equal to above provided customer_id if provided",
        "SFCCCustomerNo": "Equal to above provided customer_no if provided",
        "personContactId": "18-digit PersonAccount (Contact) ID"
    }
    **/

    @TestVisible
    private String objectType {get;set;}
    @TestVisible
    private String recordId {get;set;}
    @TestVisible
    private String SFCCCustomerId {get;set;}
    @TestVisible
    private String SFCCCustomerNo {get;set;}
    @TestVisible
    private String personContactId {get;set;}
    @TestVisible
    private SCCErrorHandlingTemplate errors {get; set;}

    /**
    * This is the constructor for TRUSubscriberResponse class.
    * @param recordId String
    * @return None.
    */
    public TRUSubscriberResponse() {  }

    /**
    * This is the constructor for TRUSubscriberResponse class.
    * @param recordId String
    * @param objectType String
    * @param errors SCCErrorHandlingTemplate
    * @return None.
    */
    public TRUSubscriberResponse(String objectType, String recordId, String SFCCCustomerId, String SFCCCustomerNo, String personContactId, SCCErrorHandlingTemplate errors) {
        this.objectType = objectType;
        this.recordId = recordId;
        this.SFCCCustomerId = SFCCCustomerId;
        this.SFCCCustomerNo = SFCCCustomerNo;
        this.personContactId = personContactId;
        this.errors = errors;
    }

    /**
    * This is the constructor for TRUSubscriberResponse class with error.
    * @param errors: SCCErrorHandlingTemplate
    * @return TRUSubscriberResponse.
    */

    public TRUSubscriberResponse(SCCErrorHandlingTemplate errors) {
        this.errors = errors;
    }

    /**
    * This method used for creating json text for response of rest services.
    * @param recordId: Id
    * @return TRUSubscriberResponse.
    */
    public static TRUSubscriberResponse createResponse(Account record) {
        return new TRUSubscriberResponse('Account', record.Id, record.SFCC_Customer_Id__pc, record.SFCC_Customer_Number__pc, record.PersonContactId, null);
    }

    /**
    * This method used for creating json text if there is error on processing.
    * @param e: Exception
    * @return TRUSubscriberResponse.
    */
    public static TRUSubscriberResponse createError(Exception e) {
        return new TRUSubscriberResponse(SCCErrorHandlingTemplate.createError(e));
    }

}