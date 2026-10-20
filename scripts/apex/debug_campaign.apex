// Adds the Flow's fields one at a time to find which one triggers the error. Rolls back.
Savepoint sp = Database.setSavepoint();

Id rtId = '012fj000008SA6HAAW';
Id unitId = 'a01fj000021iAQOAA2';

List<Campaign> tests = new List<Campaign>{
    new Campaign(Name = 'Debug 1 - IDs only', RecordTypeId = rtId, Unit__c = unitId),
    new Campaign(Name = 'Debug 2 - plus Status', RecordTypeId = rtId, Unit__c = unitId,
        Status = 'In Progress'),
    new Campaign(Name = 'Debug 3 - plus Active', RecordTypeId = rtId, Unit__c = unitId,
        IsActive = true),
    new Campaign(Name = 'Debug 4 - plus Start Date', RecordTypeId = rtId, Unit__c = unitId,
        StartDate = Date.today()),
    new Campaign(Name = 'Debug 5 - plus Listed Rent', RecordTypeId = rtId, Unit__c = unitId,
        Listed_Rent__c = 2100),
    new Campaign(Name = 'Debug 6 - everything', RecordTypeId = rtId, Unit__c = unitId,
        Status = 'In Progress', IsActive = true, StartDate = Date.today(), Listed_Rent__c = 2100)
};

List<Database.SaveResult> results = Database.insert(tests, false);
for (Integer i = 0; i < tests.size(); i++) {
    System.debug(tests[i].Name + ' -> ' + (results[i].isSuccess()
        ? 'OK'
        : 'FAILED: ' + results[i].getErrors()[0].getStatusCode() + ' ' + results[i].getErrors()[0].getMessage()));
}

Database.rollback(sp);