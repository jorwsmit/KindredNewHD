global class KRS_ResetAccountSrsBdoTerritories implements Database.Batchable<sObject> {
  
  global static Integer contextExecutionCount = 0;
  global final String query;
  global static string recordType = '0121B0000018Fz1';
  
  global KRS_ResetAccountSrsBdoTerritories() {
    this.query = 'Select Id, KRS_SRS_BDO_Territory__c, BillingState, BillingPostalCode From Account WHERE RecordTypeID =: recordType';
  }
  
  global KRS_ResetAccountSrsBdoTerritories(String query) {
    this.query = query;
    cancelRunningBatches();
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    System.debug('bc.getJobID()=' + bc.getJobID());
    // If the user edits multiple records within a short period of time
    // there may already be a job running.  Cancel it.
    // Want to iterate over all accounts and update
    return Database.getQueryLocator(this.query);
  }

  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    List<Account> accountsToUpdate = new List<Account>();
    
    for (sObject o : scope) {
      Account a = (Account)o;
      KRS_SRS_BDO_Territory__c terr = KRS_TerritoryLookupHelper.getTerritory(a.BillingState, a.BillingPostalCode);
      if (a.KRS_SRS_BDO_Territory__c != terr.Id) {
        // Calling update without modifying any fields will cause the BeforeUpdate
        // trigger to fire.  This will cause the Territory to be set if necessary.
        // Only update records that have territory incorrectly set.
        accountsToUpdate.add(a);
      }
    }
    
    if (!accountsToUpdate.isEmpty())
      update accountsToUpdate;
  }
  
  global void finish(Database.BatchableContext bc) {
  }
  
  global void cancelRunningBatches() {
    List<AsyncApexJob> existingJobs = [Select Id, Status From AsyncApexJob
        Where ApexClass.Name = 'ResetAccountSrsBdoTerritories'
        And Status Not In ('Aborted', 'Completed', 'Failed')];
    System.debug('existingJobs.size()=' + existingJobs.size());
    for (AsyncApexJob job : existingJobs) {
      System.debug('Aborting job.Id=' + job.Id);
      System.abortJob(job.Id);
    }
  }

}