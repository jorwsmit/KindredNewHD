public without sharing class KRS_TerritoryLookupHelper {
  private static Map<String, KRS_SRS_BDO_Territory__c> zipTerritories;
  private static Map<String, KRS_SRS_BDO_Territory__c> stateTerritories;
  private static KRS_SRS_BDO_Territory__c unkTerr = null;
	
  public static List<KRS_SRS_BDO_Territory__c> territories = [Select s.Id, (Select Lookup_Key__c From Zipcodes__r), (Select Lookup_Key__c From States__r), (Select User__c, Role__c From Territory_Members__r) From KRS_SRS_BDO_Territory__c s];
	
  static {
    populateMaps();
  }
  
  public static KRS_SRS_BDO_Territory__c getTerritory(string state, string zipCode) {
    KRS_SRS_BDO_Territory__c ret = null;
    for (integer i = zipCode == null ? 0 : zipCode.length(); i > 0; i--) {
      string key = state + '-'+ zipCode.substring(0, i);
      System.debug('key=' + key);
      if (zipTerritories.containsKey(key)) {
        ret = zipTerritories.get(key);
        break;
      }
    }
    if (ret == null) {
      if (stateTerritories.containsKey(state)) {
        ret = stateTerritories.get(state);
      } else {
        if (unkTerr == null)
        	unkTerr = [SELECT s.Id,
        					  (SELECT Lookup_Key__c FROM Zipcodes__r),
        					  (SELECT Lookup_Key__c FROM States__r),
        					  (SELECT User__c, Role__c FROM Territory_Members__r)
        					  FROM KRS_SRS_BDO_Territory__c s WHERE s.Name = 'Unknown' Limit 1];
        ret = unkTerr;
      }
    }

    return ret;
  }

  private static void populateMaps() {
    zipTerritories = new Map<String, KRS_SRS_BDO_Territory__c>();
    stateTerritories = new Map<String, KRS_SRS_BDO_Territory__c>();

    
    for (KRS_SRS_BDO_Territory__c territory : territories) {
      for (KRS_SRS_BDO_Territory_Zipcode__c zip : territory.Zipcodes__r) {
        System.debug('zip.Lookup_Key__c=' + zip.Lookup_Key__c);
        zipTerritories.put(zip.Lookup_Key__c, territory);
      }
      for (KRS_SRS_BDO_Territory_State__c state : territory.States__r) {
        if (state.Lookup_Key__c != null)
          stateTerritories.put(state.Lookup_Key__c, territory);
      }
    }
  }
  
  
}