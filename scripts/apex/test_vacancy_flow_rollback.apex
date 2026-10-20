// Lists Oakridge Main, reports what the flow created, then undoes everything.
Savepoint sp = Database.setSavepoint();

Unit__c u = [SELECT Id FROM Unit__c WHERE Name = 'Main' AND Property__r.Name = 'Oakridge Townhome' LIMIT 1];
u.Status__c = 'Listed';
u.Vacant_Since__c = Date.today().addDays(-5);
update u;

List<Campaign> created = [
    SELECT Name, RecordType.DeveloperName, Channel__c,
           (SELECT Label, IsDefault FROM CampaignMemberStatuses ORDER BY SortOrder)
    FROM Campaign
    WHERE Unit__c = :u.Id OR Parent.Unit__c = :u.Id
];
for (Campaign c : created) {
    List<String> labels = new List<String>();
    for (CampaignMemberStatus s : c.CampaignMemberStatuses) {
        labels.add(s.Label + (s.IsDefault ? ' (default)' : ''));
    }
    System.debug(c.RecordType.DeveloperName + ' | ' + c.Name + ' | statuses: ' + String.join(labels, ', '));
}

Database.rollback(sp);
System.debug('Rolled back. Nothing was saved.');