trigger SCCSyncCustomerAddressTrigger on Address__c (before insert, before update) {
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result;
    try {
        if (trigger.IsInsert) {

        }
        if (trigger.IsUpdate) {
            List<Address__c> newAddresses = trigger.new;
            List<Address__c> oldAdresses = trigger.old;
            Map<String, Object> patchDataMap = new Map<String, Object>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address__c.fields.getMap();
            for (Integer i = 0; i < newAddresses.size(); i++) {
                Address__c newAddr = newAddresses.get(i);
                Address__c oldAddr = oldAdresses.get(i);
                // this is avoid calling future method when object updated by webservice from CC.
                newAddr.Name = oldAddr.Name;
                if (!newAddr.from_SFCC__c) {
                    for (String str : fieldMap.keyset()) {
                        logger.debug('SCCSyncCustomerAddressTrigger.IsUpdate', 'Field name: ' + str + '. New value: ' + newAddr.get(str) + '. Old value: ' + oldAddr.get(str));
                        //if (newAddr.get(str) != oldAddr.get(str)) {
                            logger.debug('SCCSyncCustomerAddressTrigger.IsUpdate', 'Patching commerce cloud for field ' + str);
                            patchDataMap.put(str, newAddr.get(str) != null ? newAddr.get(str) : '');
                        //}
                    }
                    if (!patchDataMap.isEmpty()) {
                        //Call Commerce Cloud patch
                        result = SCCAccountImpl.patchCustAddress(patchDataMap, newAddr);
                    }
                }
                newAddr.from_SFCC__c = false;
            }
        }
    } catch (Exception e) {
        logger.error('SCCSyncCustomerAddressTrigger', 'Exception message : '
                + e.getMessage() + ' StackTrack ' + e.getStackTraceString());
    } finally {
        logger.flush();
    }

}