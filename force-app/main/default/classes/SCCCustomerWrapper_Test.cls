@isTest
public class SCCCustomerWrapper_Test {
    
    @testSetup
    static void setup(){
        
    } 
    
    @isTest
    static void testSCCCustomerWrapper(){
        SCCCustomerWrapper customerWrapper = new SCCCustomerWrapper('Gender', '1');
        customerWrapper = new SCCCustomerWrapper('Gender', 'SheMale');
        customerWrapper = new SCCCustomerWrapper('myGender', 'Male');
    }

}