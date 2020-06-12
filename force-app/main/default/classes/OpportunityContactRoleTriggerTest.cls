@IsTest
private class OpportunityContactRoleTriggerTest {

    @TestSetup
    private static void setup() {

        // Create accounts
        Account patriots = new Account(
            Name = 'New England Patriots'
        );

        insert new List<Account> { patriots };

        // Create contacts
        Contact belichick = new Contact(
            AccountId = patriots.Id,
            Email = 'bill@patriots.com',
            FirstName = 'Bill',
            LastName = 'Belichick'
        );

        insert new List<Contact> { belichick };

        // Create opportunities
        Opportunity patriotsFirst = new Opportunity(
            AccountId = patriots.Id,
            Amount = 0,
            CloseDate = Date.today().addMonths(4),
            Name = 'Patriots First Down',
            StageName = 'Discovery'
        );

        Opportunity patriotsSecond = new Opportunity(
            AccountId = patriots.Id,
            Amount = 0,
            CloseDate = Date.today().addMonths(3),
            Name = 'Patriots Second Down',
            StageName = 'Discovery'
        );

        insert new List<Opportunity> {
            patriotsFirst,
            patriotsSecond
        };

        // Create opportunity contact roles
        insert new List<OpportunityContactRole> {
            new OpportunityContactRole(
                ContactId = belichick.Id,
                IsPrimary = true,
                OpportunityId = patriotsSecond.Id
            )
        };
    }

    /**
     * Given an opportunity without any contact roles,
     * when a contact role is added as a non-primary contact role,
     * then the **Primary Contact** checkbox should be cleared.
     */
    @IsTest
    private static void createNonprimaryOpportunityContactRole() {

        // Given
        Contact belichick = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'Belichick'
        ];

        Opportunity patriotsFirst = [
            SELECT Id,
                (
                    SELECT Id, IsPrimary, IsPrimaryContact__c
                    FROM OpportunityContactRoles
                )
            FROM Opportunity
            WHERE Name = 'Patriots First Down'
        ];

        System.assertEquals(
            0, patriotsFirst.OpportunityContactRoles.size(),
            'no opportunity contact roles should exist yet'
        );

        // When
        Test.startTest();

        OpportunityContactRole role = new OpportunityContactRole(
            ContactId = belichick.Id,
            IsPrimary = false,
            OpportunityId = patriotsFirst.Id
        );

        insert role;

        // Then
        Test.stopTest();

        role = [
            SELECT Id, IsPrimary, IsPrimaryContact__c
            FROM OpportunityContactRole
            WHERE Id = :role.Id
        ];

        System.assertEquals(
            false, role.IsPrimary,
            OpportunityContactRole.IsPrimary.getDescribe().label
        );

        System.assertEquals(
            false, role.IsPrimaryContact__c,
            OpportunityContactRole.IsPrimaryContact__c.getDescribe().label
        );
    }

    /**
     * Given an opportunity that already has a primary contact role,
     * when that contact role's **Primary** checkbox is cleared,
     * then the **Primary Contact** checkbox should also be cleared.
     */
    @IsTest
    private static void clearPrimaryCheckbox() {

        // Given
        Opportunity patriotsSecond = [
            SELECT Id,
                (
                    SELECT Id, IsPrimary, IsPrimaryContact__c
                    FROM OpportunityContactRoles
                )
            FROM Opportunity
            WHERE Name = 'Patriots Second Down'
        ];

        System.assertEquals(
            1, patriotsSecond.OpportunityContactRoles.size(),
            'one opportunity contact roles should exist'
        );

        OpportunityContactRole role =
                patriotsSecond.OpportunityContactRoles.get(0);

        System.assertEquals(
            true, role.IsPrimary,
            OpportunityContactRole.IsPrimary.getDescribe().label
        );

        System.assertEquals(
            true, role.IsPrimaryContact__c,
            OpportunityContactRole.IsPrimaryContact__c.getDescribe().label
        );

        // When
        Test.startTest();

        update new OpportunityContactRole(
            Id = role.Id,
            IsPrimary = false
        );

        // Then
        Test.stopTest();

        role = [
            SELECT Id, IsPrimary, IsPrimaryContact__c
            FROM OpportunityContactRole
            WHERE Id = :role.Id
        ];

        System.assertEquals(
            false, role.IsPrimary,
            OpportunityContactRole.IsPrimary.getDescribe().label
        );

        System.assertEquals(
            false, role.IsPrimaryContact__c,
            OpportunityContactRole.IsPrimaryContact__c.getDescribe().label
        );
    }
}