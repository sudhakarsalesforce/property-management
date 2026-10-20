// Removes ONLY the records created by seed-data.apex, matched by name.
// Delete in dependency order: anything that points at a record must go before that record.

Set<String> propertyNames = new Set<String>{
    'Maple Street House', 'Oakridge Townhome', 'Elm Avenue Duplex'
};
Set<String> accountNames = new Set<String>{
    'My Properties LLC', 'Carolina Home Lending', 'Oakridge Meadows HOA',
    'Piedmont Mutual Insurance', 'Queen City Plumbing', 'Blue Ridge Heating & Air'
};

// 1. Channel campaigns point at vacancy campaigns, so they go first.
List<Campaign> channelCampaigns = [
    SELECT Id FROM Campaign WHERE Parent.Unit__r.Property__r.Name IN :propertyNames
];
delete channelCampaigns;

// 2. Vacancy campaigns point at Units with a restrict lookup.
List<Campaign> vacancyCampaigns = [
    SELECT Id FROM Campaign WHERE Unit__r.Property__r.Name IN :propertyNames
];
delete vacancyCampaigns;

// 3. Assets point at Properties with a restrict lookup.
List<Asset> assets = [SELECT Id FROM Asset WHERE Property__r.Name IN :propertyNames];
delete assets;

// 4. Deleting a Property also deletes its Units (master-detail cascade).
List<Property__c> properties = [SELECT Id FROM Property__c WHERE Name IN :propertyNames];
delete properties;

// 5. Accounts are referenced by Properties (Owner, Lender, HOA), so they go last.
List<Account> accounts = [SELECT Id FROM Account WHERE Name IN :accountNames];
delete accounts;

System.debug('CLEANUP COMPLETE: deleted ' + (channelCampaigns.size() + vacancyCampaigns.size())
    + ' campaigns, ' + assets.size() + ' assets, ' + properties.size()
    + ' properties (units cascaded), ' + accounts.size() + ' accounts.');