@isTest
public class KRS_ResetAccountSrsBdoTerritoriesTest{

    public static testMethod void unitTest(){
        
        KRS_SRS_BDO_Territory__c nt = new KRS_SRS_BDO_Territory__c();
        nt.name = 'Unknown';
        insert nt; 
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.BillingState = 'IL';
        a.BillingPostalCode = '99999';
        a.recordTypeID = '0121B0000018Fz1';
        insert a;
    
        KRS_SRS_BDO_Territory__c terr = new KRS_SRS_BDO_Territory__c();
        terr.Name = 'Test Territory';
        insert terr;

        User u = [
          Select Id
          From User
          Where IsActive = true
          Limit 1
            ];
        KRS_SRS_BDO_Territory_Member__c tm = new KRS_SRS_BDO_Territory_Member__c();
        tm.Territory__c = terr.Id;
        tm.User__c = u.Id;
        tm.Role__c = 'SRS Business Development';
        insert tm;

        KRS_SRS_BDO_Territory_State__c ts = new KRS_SRS_BDO_Territory_State__c();
        ts.Territory__c = terr.Id;
        ts.Name = 'PR';
        insert ts;

        KRS_SRS_BDO_Territory_Zipcode__c tz = new KRS_SRS_BDO_Territory_Zipcode__c();
        tz.State__c = ts.Id;
        tz.Name = '99999';
        insert tz;
    
        KRS_ResetAccountSrsBdoTerritories batch = new KRS_ResetAccountSrsBdoTerritories(
          'Select Id, KRS_SRS_BDO_Territory__c, BillingState, BillingPostalCode From Account Limit 200'
        );
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}