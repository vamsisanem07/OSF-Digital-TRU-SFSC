trigger SCCSyncCustomerAccountTrigger on Account (before insert, before update) {

    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result;
    try {
        if (trigger.IsInsert) {
            for (Account newAcc : trigger.new) {
                if ((newAcc.LastName == null || newAcc.LastName.isWhitespace()) && newAcc.From_SFCC__pc == true) {
                    SCCUtilityClass.setLastNameIfEmpty(newAcc);
                }
            }
        }
        if (trigger.IsUpdate && ActivateDeactiveAccountOptinTrigger__c.getInstance().ActivateTheTrigger__c) {
            List<Account> newAccounts = trigger.new;
            List<Account> oldAccounts = trigger.old;
            Map<String, Object> patchDataMap = new Map<String, Object>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
            for (Integer i = 0; i < newAccounts.size(); i++) {
                Account newAcc = newAccounts.get(i);
                Account oldAcc = oldAccounts.get(i);
                // this is avoid calling future method when object updated by webservice from CC.
                if (!newAcc.SFCC_update__c) {
                    for (String str : fieldMap.keyset()) {
                        logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Field name: ' + str + '. New value: ' + newAcc.get(str) + '. Old value: ' + oldAcc.get(str));
                        if (newAcc.get(str) != oldAcc.get(str)) {
                            logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Patching commerce cloud for field ' + str);
                            patchDataMap.put(str, newAcc.get(str));
                        }
                    }
                    if (!patchDataMap.isEmpty()) {
                        //Call Commerce Cloud patch
                        result = SCCAccountImpl.patchCustProfile(patchDataMap, newAcc);
                    }
                }
                newAcc.SFCC_update__c = false;
            }
        }
    } catch (Exception e) {
        logger.error('SCCSyncCustomerAccountTrigger', 'Exception message : '
                + e.getMessage() + ' StackTrack ' + e.getStackTraceString());
    } finally {
        logger.flush();
    }

}