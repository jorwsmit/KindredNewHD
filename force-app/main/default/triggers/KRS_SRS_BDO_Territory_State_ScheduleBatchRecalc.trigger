trigger KRS_SRS_BDO_Territory_State_ScheduleBatchRecalc on KRS_SRS_BDO_Territory_State__c (after delete, after insert, after undelete, 
after update) {
  // Multiple triggers may fire to schedule this batch apex.  Ensure that it only runs once.
  if (KRS_ResetAccountSrsBdoTerritories.contextExecutionCount++ == 0 || Test.isRunningTest()) {
    KRS_ResetAccountSrsBdoTerritories batch = new KRS_ResetAccountSrsBdoTerritories();
    Database.executeBatch(batch);
  }
}