@isTest
private class AccountTriggerHandlerTest {
    @isTest
    static void testSafeAccountDeletionSuccess() {
        Account safeAcc = new Account(Name = 'Safe StartUp Inc', AnnualRevenue = 500000);
        insert safeAcc;
        Test.startTest();
        Database.DeleteResult result = Database.delete(safeAcc, false);
        Test.stopTest();
        System.assert(result.isSuccess(), 'Should delete safely.');
    }

    @isTest
    static void testHighRevenueDeletionFails() {
        Account richAcc = new Account(Name = 'Mega Corp', AnnualRevenue = 15000000); 
        insert richAcc;
        Test.startTest();
        Database.DeleteResult result = Database.delete(richAcc, false);
        Test.stopTest();
        System.assert(!result.isSuccess(), 'Deletion should be blocked.');
    }
}
