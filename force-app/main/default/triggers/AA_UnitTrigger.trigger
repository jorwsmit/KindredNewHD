trigger AA_UnitTrigger on Unit__c (after insert, after update){

	if(trigger.isAfter && trigger.isInsert){
		list<Account> hdAccounts = new list<Account>();
		list<Account_Unit__c> newAccUnits = new list<Account_Unit__c>();
		
		hdAccounts = [SELECT ID FROM Account WHERE RecordTypeID =: '012c000000024p6'];
		for(Unit__c u: trigger.new){
			for(Account a : hdAccounts){
				Account_Unit__c au = new Account_Unit__c();
  	  				au.Account__c = a.Id;
  	  				au.Unit__c = u.Id;
  	  				if(u.Name == 'Administrative'){
  	  					au.Active__c = true;
  	  					}
  	  				else{
  	  					au.Active__c = false;
  	  					}	
  	  				newAccUnits.add(au);
				}
			}
			if(newAccUnits.size() > 0){
  	  			insert newAccUnits;
  	  			}
		}
		
		
		if(trigger.isAfter && trigger.isUpdate){
			list<ID> unitIds = new list<ID>();
			for(Unit__c u : trigger.new){
				if(u.Active__c == false){
					unitIds.add(u.Id);
					}
				}
				list<Account_Unit__c> toUpdate = new list<Account_Unit__c>();
				toUpdate = [SELECT ID, Unit__c, Active__c FROM Account_Unit__c WHERE Unit__c IN: unitIds AND Active__c = true];
				
				for(Account_Unit__c au: toUpdate){
					au.Active__c = false;
				}
			update toUpdate;
		}
    
}