trigger AA_KRS_TerritoryZipcode on KRS_SRS_BDO_Territory_Zipcode__c (after delete, after insert, after undelete, 
after update, before insert, before update) {
    
    if(trigger.isAfter){
        if(trigger.isDelete || trigger.isUpdate){
            // Multiple triggers may fire to schedule this batch apex.  Ensure that it only runs once.
        if(KRS_ResetAccountSrsBdoTerritories.contextExecutionCount++ == 0 || Test.isRunningTest()) {
            KRS_ResetAccountSrsBdoTerritories batch = new KRS_ResetAccountSrsBdoTerritories();
            Database.executeBatch(batch);
            }
            }   
        }
        
      if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        List<Id> stateIds = new List<Id>();
        for (KRS_SRS_BDO_Territory_Zipcode__c zc : Trigger.new){
                stateIds.add(zc.State__c);
                }
            Map<Id, KRS_SRS_BDO_Territory_State__c> states = new Map<Id, KRS_SRS_BDO_Territory_State__c>([Select Id, Territory__c From KRS_SRS_BDO_Territory_State__c Where Id In :stateIds]);
        for (KRS_SRS_BDO_Territory_Zipcode__c zc : Trigger.new){
            zc.Territory__c = states.get(zc.State__c).Territory__c;
            }
        }
      
}