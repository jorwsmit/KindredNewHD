@isTest
public class KRS_TerritoryHelperTest{

static testMethod void testGetTerrotory() {
    KRS_SRS_BDO_Territory__c nT = new KRS_SRS_BDO_Territory__c();
        nt.Name = 'Unknown';
        insert nt; 
    KRS_TerritoryLookupHelper.getTerritory('MO', '');
    KRS_TerritoryLookupHelper.getTerritory('IL', '60200');
  }

}