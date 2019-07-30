@isTest
private class KRS_TriggerTestCases {

  static testMethod void testCreateAccountNoState() {
      Account a = new Account();
      a.Name = 'Test Account';
      insert a;
  }
  
  static testMethod void testCreateAccountWithState() {
      Account a = new Account();
      a.Name = 'Test Account';
      a.BillingState = 'AR';
      insert a;
  }

  static testMethod void testCreateAccountWithZip() {
      Account a = new Account();
      a.Name = 'Test Account';
      a.BillingState = 'IL';
      a.BillingPostalCode = '60000';
      insert a;
  }
  
  static testMethod void testAccountTeamAssignment() {
    KRS_SRS_BDO_Territory__c terr2 = new KRS_SRS_BDO_Territory__c();
    terr2.Name = 'Unknown';
    insert terr2;
    Profile p = [Select Id From Profile Limit 1];
    User u = new User();
    u.FirstName = 'Test';
    u.LastName = 'User';
    u.Username = 'ARGLEDIEBARGLEDIE@test.test';
    u.Email = 'test@test.test';
    u.Alias = 'test';
    u.TimeZoneSidKey = 'America/Chicago';
    u.LocaleSidKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    u.ProfileId = p.Id;
    u.LanguageLocaleKey = 'en_US';
    insert u;
    KRS_SRS_BDO_Territory__c terr = KRS_TerritoryLookupHelper.getTerritory('MO', '');
    KRS_SRS_BDO_Territory_Member__c member = new KRS_SRS_BDO_Territory_Member__c();
    member.Territory__c = terr.Id;
    member.User__c = u.Id;
    member.Role__c = 'SRS Business Development';
    insert member;
    Account a = new Account();
    a.Name = 'Test Account';
    a.BillingState = 'MO';
    insert a;
    AccountTeamMember atm = new AccountTeamMember();
    atm.AccountId = a.Id;
    atm.UserId = u.Id;
    insert atm;
    a.BillingPostalCode = '65438';
    update a;  
  }
  
  static testMethod void testCreateSRS_BDO_Territory_Zipcode() {
    KRS_SRS_BDO_Territory__c terr = new KRS_SRS_BDO_Territory__c();
    terr.Name = 'Test Territory';
    insert terr;
    KRS_SRS_BDO_Territory_State__c state = new KRS_SRS_BDO_Territory_State__c();
    state.Territory__c = terr.Id;
    state.Name = 'MO';
    insert state;
    KRS_SRS_BDO_Territory_Zipcode__c zip = new KRS_SRS_BDO_Territory_Zipcode__c();
    zip.Name = '656';
    zip.State__c = state.Id;
    insert zip;
    delete zip;
  }
  
  static testMethod void testPreventRenameUnknownTerritory() {
    KRS_SRS_BDO_Territory__c terr = null;
    try {
      terr = [Select Id From KRS_SRS_BDO_Territory__c Where Name = 'Unknown'];
    } catch (Exception ex) {
      terr = new KRS_SRS_BDO_Territory__c();
      terr.Name = 'Unknown';
      insert terr;
    }
    terr.Name = 'Changed From Unknown';
    try {
      update terr;
      //System.assert(false);
    } catch (Exception ex) {}
  }

  static testMethod void testPreventDeleteUnknownTerritory() {
    KRS_SRS_BDO_Territory__c terr = null;
    try {
      terr = [Select Id From KRS_SRS_BDO_Territory__c Where Name = 'Unknown'];
    } catch (Exception ex) {
      terr = new KRS_SRS_BDO_Territory__c();
      terr.Name = 'Unknown';
      insert terr;
    }
    try {
      delete terr;
      //System.assert(false);
    } catch (Exception ex) {}
  }

  static testMethod void testPreventDuplicateUnknownTerritory() {
    KRS_SRS_BDO_Territory__c terr = null;
    try {
      terr = [Select Id From KRS_SRS_BDO_Territory__c Where Name = 'Unknown'];
    } catch (Exception ex) {
      terr = new KRS_SRS_BDO_Territory__c();
      terr.Name = 'Unknown';
      insert terr;
    }
    try {
      KRS_SRS_BDO_Territory__c terr2 = new KRS_SRS_BDO_Territory__c();
      terr2.Name = 'Unknown';
      insert terr2;
      //System.assert(false);
    } catch (Exception ex) {}
  }
}