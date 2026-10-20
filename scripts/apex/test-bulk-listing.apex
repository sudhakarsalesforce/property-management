List<Unit__c> units = [
    Select Id, Name from Unit__c where name IN ('Main House', 'Unit A')
];
for (Unit__c unit: units){
    unit.Status__c = 'Listed';
    unit.Vacant_Since__c = Date.today();
}

update units;
System.debug('Updated units'+ units.size()+' to listed status');