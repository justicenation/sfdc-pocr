trigger OpportunityContactRole on OpportunityContactRole (
    before insert,
    before update
) {
    for (OpportunityContactRole eachRole : Trigger.new) {
        eachRole.IsPrimaryContact__c = eachRole.IsPrimary;
    }
}