public with sharing class AccountTriggerHandler {
    public static void handleBeforeDelete(List<Account> oldAccounts) {
        // High-Value Criteria thresholds
        Decimal revenueThreshold = 15000000; // $15,000,000
        Decimal oppCountThreshold = 5;

        Map<Id, Account> accountsToCheckMap = new Map<Id, Account>();
        for (Account acc : oldAccounts) {
            if (acc.AnnualRevenue > revenueThreshold) {
                acc.addError('Deletion failed: This is a high-value account exceeding $' + revenueThreshold.format());
            } else {
                accountsToCheckMap.put(acc.Id, acc);
            }
        }

        if (!accountsToCheckMap.isEmpty()) {
            for (AggregateResult ar : [
                SELECT AccountId, COUNT(Id) oppCount 
                FROM Opportunity 
                WHERE AccountId IN :accountsToCheckMap.keySet() AND IsClosed = false 
                GROUP BY AccountId
            ]) {
                Id accId = (Id)ar.get('AccountId');
                Integer oppCount = (Integer)ar.get('oppCount');

                if (oppCount > oppCountThreshold) {
                    Account targetAcc = accountsToCheckMap.get(accId);
                    targetAcc.addError('Deletion failed: This account has ' + oppCount + ' open opportunities.');
                }
            }
        }
    }
}
