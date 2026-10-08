# Property Management on Salesforce

A property management app built on Sales Cloud, Service Cloud, and the Salesforce Platform.

## Loading sample data

Seed the org with 3 properties, 4 units, 6 assets, and owner/vendor accounts:

    sf apex run --file scripts/apex/seed-data.apex

To reset the data, run the cleanup first, then the seed:

    sf apex run --file scripts/apex/cleanup-seed-data.apex
    sf apex run --file scripts/apex/seed-data.apex

The seed is skipped if the sample properties already exist.