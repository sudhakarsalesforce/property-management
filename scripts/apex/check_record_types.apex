// Shows which Campaign record types the current user is allowed to use.
for (Schema.RecordTypeInfo rt : Schema.SObjectType.Campaign.getRecordTypeInfos()) {
    System.debug(rt.getDeveloperName()
        + ' | available: ' + rt.isAvailable()
        + ' | default: ' + rt.isDefaultRecordTypeMapping()
        + ' | active: ' + rt.isActive());
}