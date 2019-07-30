trigger AA_AccountTrigger on Account (after delete, after insert, after update, before delete, before insert, before update) {
  
  TBN_AccountTriggerHandler handler = new TBN_AccountTriggerHandler();
  TBN_UpdateDMAOnAccountAndContactHandler handleDMA = new TBN_UpdateDMAOnAccountAndContactHandler();
  List<Merge__c> newMergeRows = new List<Merge__c>();
  
  KRS_SRS_BDO_Territory__c unknownTerritory;
  Boolean unknownTerritoryQueried = false;  
  Integer maxRecordsToGeocode = 10; 
  
  List<String> HospitalCoLOB = new List<String>();
  Schema.DescribeFieldResult fieldResult = IPathConfig__c.HospitalCoLOB__c.getDescribe();
  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for(Schema.PicklistEntry pickListVal : ple){
      HospitalCoLOB.add(pickListVal.getLabel());
    }
    
   if(trigger.isBefore && trigger.isDelete){
    handler.onBeforeDelete(Trigger.oldMap);
    }
   
   public list<Unit__c> activeUnits = [SELECT ID, Name FROM Unit__c WHERE Active__c = true];
   
   public list<KRS_SRS_BDO_Territory__c> bdos = [SELECT ID, Name FROM KRS_SRS_BDO_Territory__c];
   public list<String> bNames = new list<String>();
				for(KRS_SRS_BDO_Territory__c sbt : bdos){
					bNames.add(sbt.Name);
					}
	public list<User> users = [SELECT Name, ID FROM User WHERE Name IN: bNames];
	public list<ID> accountIDs = new list<ID>();
	
	public list<Account> accounts = new list<Account>();
   
  //KRS Assignations
  if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
  	  	
    for(Account a : Trigger.new){
		if(a.Historic_ID__c != a.ID){
			a.Historic_ID__c = a.ID;
			}
        
        if(HospitalCoLOB.contains(a.Type) && a.RecordTypeID == '01230000000YKF4'){
            a.HospitalCoLOB__c = true;
            }
        else{
            a.HospitalCoLOB__c = false;
            }  
        if(a.RecordTypeID == '0121B0000018Fz1' || a.RecordTypeID == '012210000008p7d'){
			accountIDs.add(a.Id);
			}
		}
		accounts = [SELECT ID, KRS_SRS_BDO_Territory__r.Name FROM Account WHERE ID IN: accountIDs];
        Boolean territoryKnown = false;
          if(userInfo.getUserId() != '00530000003TUiB' && userInfo.getUserId() != '0051300000CXZHu'){
          	for(Account a: trigger.new){
          if(!system.isBatch() && a.BillingState != null && (a.RecordTypeID == '0121B0000018Fz1' || a.RecordTypeID == '012210000008p7d' && userInfo.getProfileId() != '00e300000010RQT')) {
				list<Task> tasks = new list<Task>();
				Date dt = Date.newInstance(system.today().year(), system.today().month(), (system.today().day() + 60));	
				map<String, ID> info = new map<string, ID>();
				for(User u : users){
					for(string s : bNames){
						if(s == u.Name){
						info.put(s, u.ID);
						}
    		}
    	}
    	map<ID, ID> accountAndUsers = new map<ID, ID>();
        
    	system.debug('Accounts: ' + accounts);
    	system.debug('Info: ' + info);
    	for(Account a3: accounts){
    		if(info.get(a3.KRS_SRS_BDO_Territory__r.Name) != null){
    			accountAndUsers.put(a3.ID, info.get(a3.KRS_SRS_BDO_Territory__r.Name));
    			}
    		}
    	system.debug('AccountAndUsers: ' + accountAndUsers);		
        for(Account a4 : trigger.new){
    		if(a4.KRS_New_Construction__c == true && a4.KRS_New_Construction_Processed__c == false && a4.KRS_SRS_BDO_Territory__c != null){
    			system.debug('Parent Account BDO: ' + accountAndUsers.get(a4.Id));
    			Task t = new Task(OwnerID = accountAndUsers.get(a4.Id),
    								ActivityDate = dt,
    								Type = 'Call-Follow Up',
    								Subject = 'Find CMS Provider ID and Enter on Record',
    								WhatID = a.ID,
    								RecordTypeID = '0121B0000018FzC'
    								);
    			tasks.add(t);					
    			a4.KRS_New_Construction_Processed__c = true;
    			}
    		}
    		insert tasks;
          // Find the correct territory based on BillingState and PostalCode
          KRS_SRS_BDO_Territory__c territory = KRS_TerritoryLookupHelper.getTerritory(a.BillingState, a.BillingPostalCode == null ? '' : a.BillingPostalCode);
          territoryKnown = (territory != null);
          if(territory != null && a.KRS_SRS_BDO_Territory__c != territory.Id)
              a.KRS_SRS_BDO_Territory__c = territory.Id;
            }
          // If the territory could not be determined by BillingState and BillingPostalCode
          // assign the 'Unknown' territory.
        if(!territoryKnown && (a.RecordTypeID == '0121B0000018Fz1' || a.RecordTypeID == '012210000008p7d')) {
          if(unknownTerritory == null && !unknownTerritoryQueried) {
              unknownTerritory = [Select Id From KRS_SRS_BDO_Territory__c Where Name = 'Unknown' Limit 1];
              unknownTerritoryQueried = true;
              }
            // Just in case the 'Unknown' territory doesn't exist.
          a.KRS_SRS_BDO_Territory__c = unknownTerritory == null ? null : unknownTerritory.Id;
          }
          }
          }
      }
   
  if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
  	if(trigger.isInsert){
  		list<Account_Unit__c> newAccUnits = new list<Account_Unit__c>();
  	  	for(Account ac: trigger.new){
  	  		list<ID> accIDs = new list<ID>(); 
  	  		if(ac.RecordTypeID == '012c000000024p6'){
  	  			accIDs.add(ac.ID);
  	  			}
  	  		for(ID i: accIDs){
  	  			for(Unit__c u: activeUnits){
  	  				Account_Unit__c au = new Account_Unit__c();
  	  				au.Account__c = i;
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
  	  		}
  	  		if(newAccUnits.size() > 0){
  	  			insert newAccUnits;
  	  			}
  	  	}
  	
    // Find Team Members that are configured on the SRS_BDO_Territory and ensure
    // they are set up as AccountTeamMembers
    List<AccountTeamMember> newMembers = new List<AccountTeamMember>();
    Set<Id> ids = new Set<Id>();
      for (Account a : Trigger.new){
        ids.add(a.Id);
        }
    // Query for all of the AccountTeamMembers for each account being updated.
  Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, 
                          (SELECT UserId FROM AccountTeamMembers)
                          FROM Account a 
                          WHERE a.Id In :ids]);

  for(Account a : Trigger.new){
    if(a.BillingState != null && (a.RecordTypeID == '0121B0000018Fz1' || a.RecordTypeID == '012210000008p7d')){
      KRS_SRS_BDO_Territory__c territory = KRS_TerritoryLookupHelper.getTerritory(a.BillingState, a.BillingPostalCode == null ? '' : a.BillingPostalCode);
    if (territory != null) {
        // If the territory is found, get a list of all configured territory
        // members and add them to the account team if they are not already there.
        for(KRS_SRS_BDO_Territory_Member__c member : territory.Territory_Members__r){
      boolean exists = false;
      Account acct = accounts.get(a.Id);
      for(AccountTeamMember m : acct.AccountTeamMembers){
        if(m.UserId == member.User__c){
          exists = true;
          break;
          }
        }
          if(!exists){
      AccountTeamMember newMember = new AccountTeamMember();
            newMember.AccountId = a.Id;
            newMember.UserId = member.User__c;
            newMember.TeamMemberRole = member.Role__c;
            newMembers.Add(newMember);
      }
        }
      }
    }
  }
  if(!newMembers.isEmpty()){
    insert newMembers;
  }
  }
   
   //Geocode Accounts
   //Future methods cannot be called from a future or batch method
   if(trigger.isAfter && !System.isBatch() && !System.isFuture() && (trigger.isInsert || trigger.isUpdate)){
       List<Id> idsToGeocode = new List<Id>();
      //Get ids for some records to geocode, up to max
      //(note due to callout and future limits this trigger may not attempt to geocode all records passed in)
      for(Account a : Trigger.new) {
        if(Trigger.isInsert) {
          //Want to geocode any newly created record, regardless
          idsToGeocode.Add(a.Id);  
          }
        if(Trigger.isUpdate) {
          //Only geocode an updated record if an address field has changed
              Account old = Trigger.oldMap.get(a.Id);
          
              if(old.ShippingStreet != a.ShippingStreet || 
                  old.ShippingCity != a.ShippingCity ||
                  old.ShippingState != a.ShippingState ||
                  old.ShippingPostalCode != a.ShippingPostalCode ||
                  old.ShippingCountry != a.ShippingCountry){
                      idsToGeocode.Add(a.Id);  
                   }
          }
        
        //Ensure we're within our predetermined limit
        if(idsToGeocode.size()>=maxRecordsToGeocode){
          break;
          }
        }
      AccountGeocodeCallout.doGeocodeRecords(idsToGeocode);
      }
    if(trigger.isAfter && trigger.isUpdate){
      handleDMA.onAfterUpdate(trigger.oldMap, trigger.newMap);
      }
    if(trigger.isAfter && trigger.isInsert){
      handleDMA.onAfterInsert(trigger.new);
      }
    //After delete of an Account during a merge operation
    if(trigger.isAfter && trigger.isDelete){
      handler.onAfterDelete(Trigger.oldMap);
      for(Account acct : trigger.old) {
          if(String.isNotBlank(acct.MasterRecordId)) { 
              newMergeRows.add(new Merge__c(LoserId__c = acct.Id, WinnerId__c = acct.MasterRecordId));  
            }         
        }
      if(newMergeRows.size() > 0) {
          insert newMergeRows;
        }
    }
}