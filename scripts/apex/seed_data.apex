// Seed data for the Property Management app.
// Creates 1 owner + 5 vendor accounts, 3 properties, 4 units, and 6 assets.
// Skips if the seed properties already exist. Run cleanup-seed-data.apex first to reload.

Integer existing = [
    SELECT COUNT() FROM Property__c
    WHERE Name IN ('Maple Street House', 'Oakridge Townhome', 'Elm Avenue Duplex')
];

if (existing > 0) {
    System.debug('SEED SKIPPED: ' + existing + ' seed properties already exist. Run cleanup-seed-data.apex first.');
} else {
    // Look up record types by API name so this works in any org
    Map<String, Schema.RecordTypeInfo> accountRts =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id ownerRtId = accountRts.get('Property_Owner').getRecordTypeId();
    Id vendorRtId = accountRts.get('Vendor').getRecordTypeId();

    // ---------- 1. Accounts ----------
    Account owner = new Account(Name = 'My Properties LLC', RecordTypeId = ownerRtId,
        Phone = '(704) 555-0100');
    Account lender = new Account(Name = 'Carolina Home Lending', RecordTypeId = vendorRtId,
        Vendor_Type__c = 'Lender', Preferred_Vendor__c = true);
    Account hoa = new Account(Name = 'Oakridge Meadows HOA', RecordTypeId = vendorRtId,
        Vendor_Type__c = 'HOA');
    Account insurer = new Account(Name = 'Piedmont Mutual Insurance', RecordTypeId = vendorRtId,
        Vendor_Type__c = 'Insurance', Preferred_Vendor__c = true);
    Account plumber = new Account(Name = 'Queen City Plumbing', RecordTypeId = vendorRtId,
        Vendor_Type__c = 'Plumber', Preferred_Vendor__c = true,
        License_Number__c = 'NC-PL-20417', Insurance_Expiration__c = Date.today().addMonths(8));
    Account hvac = new Account(Name = 'Blue Ridge Heating & Air', RecordTypeId = vendorRtId,
        Vendor_Type__c = 'HVAC',
        License_Number__c = 'NC-H3-11852', Insurance_Expiration__c = Date.today().addMonths(3));
    insert new List<Account>{ owner, lender, hoa, insurer, plumber, hvac };

    // ---------- 2. Properties ----------
    Property__c maple = new Property__c(
        Name = 'Maple Street House', Street__c = '412 Maple St', City__c = 'Monroe',
        State__c = 'NC', Zip_Code__c = '28110', Property_Type__c = 'Single Family',
        Status__c = 'Active', Year_Built__c = 1998, Owner_Account__c = owner.Id,
        Purchase_Date__c = Date.newInstance(2019, 6, 15), Purchase_Price__c = 245000,
        Current_Market_Value__c = 320000, Mortgage_Lender__c = lender.Id,
        Loan_Balance__c = 188000, Interest_Rate__c = 3.875, Monthly_Mortgage__c = 1150,
        Monthly_Insurance__c = 95, Annual_Property_Tax__c = 2100);

    Property__c oak = new Property__c(
        Name = 'Oakridge Townhome', Street__c = '88 Oakridge Ct', City__c = 'Indian Trail',
        State__c = 'NC', Zip_Code__c = '28079', Property_Type__c = 'Townhouse',
        Status__c = 'Active', Year_Built__c = 2006, Owner_Account__c = owner.Id,
        Purchase_Date__c = Date.newInstance(2021, 3, 1), Purchase_Price__c = 275000,
        Current_Market_Value__c = 305000, Mortgage_Lender__c = lender.Id,
        Loan_Balance__c = 215000, Interest_Rate__c = 3.25, Monthly_Mortgage__c = 1250,
        HOA__c = hoa.Id, Monthly_HOA__c = 185,
        Monthly_Insurance__c = 70, Annual_Property_Tax__c = 2300);

    Property__c elm = new Property__c(
        Name = 'Elm Avenue Duplex', Street__c = '1520 Elm Ave', City__c = 'Charlotte',
        State__c = 'NC', Zip_Code__c = '28205', Property_Type__c = 'Duplex',
        Status__c = 'Active', Year_Built__c = 1962, Owner_Account__c = owner.Id,
        Purchase_Date__c = Date.newInstance(2023, 8, 20), Purchase_Price__c = 410000,
        Current_Market_Value__c = 430000, Mortgage_Lender__c = lender.Id,
        Loan_Balance__c = 328000, Interest_Rate__c = 6.875, Monthly_Mortgage__c = 2650,
        Monthly_Insurance__c = 160, Annual_Property_Tax__c = 3600);

    insert new List<Property__c>{ maple, oak, elm };

    // ---------- 3. Units ----------
    // Vacancy dates are relative to today so Days Vacant stays realistic whenever you reseed.
    Unit__c mapleMain = new Unit__c(Name = 'Main House', Property__c = maple.Id,
        Status__c = 'Occupied', Bedrooms__c = 3, Bathrooms__c = 2, Square_Feet__c = 1450,
        Market_Rent__c = 1950, Security_Deposit__c = 1950, Pets_Allowed__c = true);
    Unit__c oakMain = new Unit__c(Name = 'Main', Property__c = oak.Id,
        Status__c = 'Vacant', Vacant_Since__c = Date.today().addDays(-20),
        Bedrooms__c = 3, Bathrooms__c = 2.5, Square_Feet__c = 1600,
        Market_Rent__c = 2100, Security_Deposit__c = 2100);
    Unit__c elmA = new Unit__c(Name = 'Unit A', Property__c = elm.Id,
        Status__c = 'Occupied', Bedrooms__c = 2, Bathrooms__c = 1, Square_Feet__c = 950,
        Market_Rent__c = 1450, Security_Deposit__c = 1450);
    Unit__c elmB = new Unit__c(Name = 'Unit B', Property__c = elm.Id,
        Status__c = 'Listed', Vacant_Since__c = Date.today().addDays(-45),
        Bedrooms__c = 2, Bathrooms__c = 1, Square_Feet__c = 950,
        Market_Rent__c = 1475, Security_Deposit__c = 1475, Pets_Allowed__c = true);
    insert new List<Unit__c>{ mapleMain, oakMain, elmA, elmB };

    // ---------- 4. Assets ----------
    List<Asset> assets = new List<Asset>{
        new Asset(Name = 'Refrigerator', AccountId = owner.Id, Property__c = maple.Id,
            Unit__c = mapleMain.Id, Status = 'Installed', Asset_Category__c = 'Appliance',
            Manufacturer__c = 'Whirlpool', InstallDate = Date.newInstance(2022, 5, 10),
            PurchaseDate = Date.newInstance(2022, 5, 1),
            Warranty_Expiration__c = Date.newInstance(2027, 5, 10),
            Expected_Life_Years__c = 13, Price = 1299),
        new Asset(Name = 'Water Heater', AccountId = owner.Id, Property__c = maple.Id,
            Unit__c = mapleMain.Id, Status = 'Installed', Asset_Category__c = 'Water Heater',
            Manufacturer__c = 'Rheem', InstallDate = Date.newInstance(2016, 3, 1),
            PurchaseDate = Date.newInstance(2016, 2, 20),
            Warranty_Expiration__c = Date.newInstance(2022, 3, 1),
            Expected_Life_Years__c = 12, Price = 950),
        new Asset(Name = 'HVAC System', AccountId = owner.Id, Property__c = maple.Id,
            Unit__c = mapleMain.Id, Status = 'Installed', Asset_Category__c = 'HVAC',
            Manufacturer__c = 'Carrier', InstallDate = Date.newInstance(2015, 7, 15),
            PurchaseDate = Date.newInstance(2015, 7, 1),
            Warranty_Expiration__c = Date.newInstance(2025, 7, 15),
            Expected_Life_Years__c = 15, Price = 6800),
        new Asset(Name = 'Dishwasher', AccountId = owner.Id, Property__c = oak.Id,
            Unit__c = oakMain.Id, Status = 'Installed', Asset_Category__c = 'Appliance',
            Manufacturer__c = 'Bosch', InstallDate = Date.newInstance(2024, 2, 1),
            PurchaseDate = Date.newInstance(2024, 1, 25),
            Warranty_Expiration__c = Date.today().addDays(45),
            Expected_Life_Years__c = 10, Price = 749),
        new Asset(Name = 'Roof', AccountId = owner.Id, Property__c = elm.Id,
            Status = 'Installed', Asset_Category__c = 'Roof',
            InstallDate = Date.newInstance(2010, 6, 1),
            PurchaseDate = Date.newInstance(2010, 6, 1),
            Expected_Life_Years__c = 25, Price = 14500),
        new Asset(Name = 'Range', AccountId = owner.Id, Property__c = elm.Id,
            Unit__c = elmB.Id, Status = 'Installed', Asset_Category__c = 'Appliance',
            Manufacturer__c = 'GE', InstallDate = Date.newInstance(2019, 4, 20),
            PurchaseDate = Date.newInstance(2019, 4, 10),
            Warranty_Expiration__c = Date.newInstance(2020, 4, 20),
            Expected_Life_Years__c = 15, Price = 899)
    };
    insert assets;

    System.debug('SEED COMPLETE: 6 accounts, 3 properties, 4 units, ' + assets.size() + ' assets.');
}