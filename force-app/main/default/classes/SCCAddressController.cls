public class SCCAddressController {

    @AuraEnabled        
    public static Map<String, String> getCountryList(){
        Map<String, String> countryMap = new Map<String, String>();
		countryMap.put('GB', 'United Kingdom');
        return countryMap;
    }

}