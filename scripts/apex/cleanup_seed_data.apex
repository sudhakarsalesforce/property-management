// Removes ONLY the records created by seed-data.apex, matched by name.
// Order matters: Assets block Property deletion, and Properties block Account deletion.

Set<String> propertyNames = new Set<String>{
    'Maple Street House', 'Oakridge Townhome', 'Elm Avenue Duplex'
};
Set<String> accountNames = new Set<String>{
    'My Properties LLC', 'Carolina Home Lending', 'Oakridge Meadows HOA',
    'Piedmont Mutual Insurance', 'Queen City Plumbing', 'Blue Ridge Heating & Air'
};

List<Asset> assets = [SELECT Id FROM Asset WHERE Property__r.Name IN :propertyNames];
delete assets;

// Deleting a Property also deletes its Units (master-detail cascade)
List<Property__c> properties = [SELECT Id FROM Property__c WHERE Name IN :propertyNames];
delete properties;

List<Account> accounts = [SELECT Id FROM Account WHERE Name IN :accountNames];
delete accounts;

System.debug('CLEANUP COMPLETE: deleted ' + assets.size() + ' assets, '
    + properties.size() + ' properties (units cascaded), ' + accounts.size() + ' accounts.');