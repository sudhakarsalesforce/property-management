// =====================================================================
// cleanup-seed-data.apex
// Removes ONLY the sample data created by seed-data.apex, plus test leads.
// Matches records by name (and test leads by example.com email), so real
// records you created yourself are left alone.
//
// Run:  sf apex run --file scripts/apex/cleanup-seed-data.apex | grep USER_DEBUG
// Then: sf apex run --file scripts/apex/seed-data.apex | grep USER_DEBUG
//
// Delete order matters: anything that points at a record must be deleted
// before that record, because several lookups block deletion ("restrict").
//
//   Leads ............ point at Units (Unit of Interest) and join Campaigns
//   Channel campaigns  point at Vacancy campaigns (Parent)
//   Vacancy campaigns  point at Units (restrict)
//   Assets ........... point at Properties (restrict)
//   Properties ....... own Units (master-detail: Units and their Tasks cascade)
//   Accounts ......... are referenced by Properties (Owner, Lender, HOA)
//
// Anonymous Apex is all-or-nothing: if any delete fails, nothing is deleted.
// =====================================================================

// Change this if your Property Owner account has a different name.
final String OWNER_ACCOUNT_NAME = 'My Properties LLC';

Set<String> propertyNames = new Set<String>{
    'Maple Street House', 'Oakridge Townhome', 'Elm Avenue Duplex'
};
Set<String> accountNames = new Set<String>{
    OWNER_ACCOUNT_NAME, 'Carolina Home Lending', 'Oakridge Meadows HOA',
    'Piedmont Mutual Insurance', 'Queen City Plumbing', 'Blue Ridge Heating & Air'
};

// ---------------------------------------------------------------------
// 1. Leads: test inquiries tied to the seed units or seed campaigns,
//    plus any lead with an @example.com email (form tests without a campaign).
//    Collected before campaigns are deleted, since campaign membership
//    is one of the ways we find them.
// ---------------------------------------------------------------------
Set<Id> leadIds = new Set<Id>();

for (Lead l : [
    SELECT Id FROM Lead
    WHERE IsConverted = false
      AND (Unit_of_Interest__r.Property__r.Name IN :propertyNames
           OR Email LIKE '%@example.com')
]) {
    leadIds.add(l.Id);
}

for (CampaignMember cm : [
    SELECT LeadId FROM CampaignMember
    WHERE LeadId != null
      AND Lead.IsConverted = false
      AND (Campaign.Unit__r.Property__r.Name IN :propertyNames
           OR Campaign.Parent.Unit__r.Property__r.Name IN :propertyNames)
]) {
    leadIds.add(cm.LeadId);
}

List<Lead> leads = [SELECT Id FROM Lead WHERE Id IN :leadIds];
delete leads;

// ---------------------------------------------------------------------
// 2. Channel campaigns point at their Vacancy parent, so they go first.
//    Their campaign members and member statuses are deleted with them.
// ---------------------------------------------------------------------
List<Campaign> channelCampaigns = [
    SELECT Id FROM Campaign
    WHERE Parent.Unit__r.Property__r.Name IN :propertyNames
];
delete channelCampaigns;

// ---------------------------------------------------------------------
// 3. Vacancy campaigns point at Units with a restrict lookup.
// ---------------------------------------------------------------------
List<Campaign> vacancyCampaigns = [
    SELECT Id FROM Campaign
    WHERE Unit__r.Property__r.Name IN :propertyNames
];
delete vacancyCampaigns;

// ---------------------------------------------------------------------
// 4. Assets point at Properties with a restrict lookup.
// ---------------------------------------------------------------------
List<Asset> assets = [
    SELECT Id FROM Asset
    WHERE Property__r.Name IN :propertyNames
];
delete assets;

// ---------------------------------------------------------------------
// 5. Properties. Deleting a Property also deletes its Units (master-detail),
//    and deleting a Unit deletes its Tasks (make-ready tasks from PM-11).
//    Counted first so the summary can report them.
// ---------------------------------------------------------------------
Integer unitCount = [
    SELECT COUNT() FROM Unit__c
    WHERE Property__r.Name IN :propertyNames
];
Integer taskCount = [
    SELECT COUNT() FROM Task
    WHERE WhatId IN (SELECT Id FROM Unit__c WHERE Property__r.Name IN :propertyNames)
];

List<Property__c> properties = [
    SELECT Id FROM Property__c
    WHERE Name IN :propertyNames
];
delete properties;

// ---------------------------------------------------------------------
// 6. Accounts last: Properties referenced them as Owner, Lender, and HOA.
// ---------------------------------------------------------------------
List<Account> accounts = [
    SELECT Id FROM Account
    WHERE Name IN :accountNames
];
delete accounts;

System.debug('CLEANUP COMPLETE: deleted '
    + leads.size() + ' leads, '
    + (channelCampaigns.size() + vacancyCampaigns.size()) + ' campaigns ('
    + channelCampaigns.size() + ' channel, ' + vacancyCampaigns.size() + ' vacancy), '
    + assets.size() + ' assets, '
    + properties.size() + ' properties (with ' + unitCount + ' units and '
    + taskCount + ' tasks), '
    + accounts.size() + ' accounts.');
