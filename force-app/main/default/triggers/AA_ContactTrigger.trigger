trigger AA_ContactTrigger on Contact (after delete, after insert, after update, before delete, before insert, before update) {

  TBN_ContactTriggerHandler handler = new TBN_ContactTriggerHandler();
  TBN_UpdateDMAOnAccountAndContactHandler handleDMA = new TBN_UpdateDMAOnAccountAndContactHandler();
  
  list<ID> krsProfiles = new list<ID>();
  //SRS Admin
  krsProfiles.add('00e1B000001p1wI');
  //KRS Support Admin PROD
  krsProfiles.add('00e1B000000jWQm');
  //sysAdmin
  krsProfiles.add('00e300000010RQT');
  
  list<ID> krsUsers = new list<ID>();
  //Cheryl Land
  krsUsers.add('0051B00000Cg8G4QAJ');
  //Jen Humphrey
  krsUsers.add('0051B00000CzatPQAR');
  //Brad Miner
  krsUsers.add('0051300000C4C5OAAV');
  //Jerry Novickas
  krsUsers.add('0051B00000Cg8GAQAZ');
  
  list<ID> krsNonAdmins = new list<ID>();
  //KRS Read Only
  krsNonAdmins.add('00e1B000001p1wH');
  //KRS SRS Finance
  krsNonAdmins.add('00e1B000001p1wJ');
  //KRS SRS User
  krsNonAdmins.add('00e1B000001p1wK');
  
  if(!System.isBatch() && !System.isFuture() && trigger.isInsert || trigger.isUpdate && krsProfiles.contains(userInfo.getProfileId())){
  	list<Event> events = new list<Event>();
  	list<KRS_SRS_BDO_Territory__c> bdos = new list<KRS_SRS_BDO_Territory__c>();
  	bdos = [SELECT ID, Name FROM KRS_SRS_BDO_Territory__c];
  	list<String> bNames = new list<String>();
  		for(KRS_SRS_BDO_Territory__c sbt : bdos){
  			bNames.add(sbt.Name);
    		}
    DateTime dt = DateTime.newInstance(system.today().year(), system.today().month(), (system.today().day() + 1), 13, 0, 0);	
    list<User> users = new list<User>();
    users = [SELECT Name, ID FROM User WHERE Name IN: bNames];
    map<String, ID> info = new map<string, ID>();
    for(User u : users){
    	for(string s : bNames){
    		if(s == u.Name){
    			info.put(s, u.ID);
    			}
    		}
    	}
    list<ID> accountIDs = new list<ID>();
    list<Account> accounts = new list<Account>();	
    map<ID, ID> accountAndUsers = new map<ID, ID>();
  
  	for(Contact c: trigger.new){
    		accountIDs.add(c.AccountId);
    		}
    	accounts = [SELECT ID, KRS_SRS_BDO_Territory__r.Name FROM Account WHERE ID IN: accountIDs];
    	system.debug('Accounts: ' + accounts);
    	system.debug('Info: ' + info);
    	for(Account a: accounts){
    		if(info.get(a.KRS_SRS_BDO_Territory__r.Name) != null){
    			accountAndUsers.put(a.ID, info.get(a.KRS_SRS_BDO_Territory__r.Name));
    			}
    		}
    	system.debug('AccountAndUsers: ' + accountAndUsers);		
        for(Contact c : trigger.new){
    		if(c.KRS_Marketo_Process__c == true && c.KRS_Marketo_Processed__c == false){
    			system.debug('Parent Account BDO: ' + accountAndUsers.get(c.AccountId));
    			Event e = new Event(OwnerID = accountAndUsers.get(c.AccountId),
    								StartDateTime = dt,
    								DurationInMinutes = 10,
    								Type = 'Call-Follow Up',
    								Subject = 'MARKETO: Follow-up',
    								WhoID = c.ID,
    								RecordTypeID = '0121B0000018Fz5'
    								);
    			events.add(e);					
    			c.KRS_Marketo_Processed__c = true;
    			}
    		}
    	system.debug('Events:' + events);	
    	try{	
    		insert events;
    		}
    	catch(Exception E){
    		system.debug('One or more BDO Territory names do not match with users.  Check the lists and correct the entries.');
    		}	
    }
  List<Merge__c> newMergeRows = new List<Merge__c>();
  list<ID> ids = new list<ID>();  
  Integer maxRecordsToGeocode = 10;
    //geocode Contacts
    //Future methods cannot be called from a future or batch method
    if(trigger.isAfter && !System.isBatch() && !System.isFuture() && (trigger.isInsert || trigger.isUpdate)){
        List<Id> idsToGeocode = new List<Id>();
        //Get ids for some records to geocode, up to max
        //(note due to callout and future limits this trigger may not attempt to geocode all records passed in)
          for(Contact c : Trigger.new) {
              if(Trigger.isInsert) {
                  //Want to geocode any newly created record, regardless
                  idsToGeocode.Add(c.Id);
                  if(c.RecordTypeID == '01213000001WHHR' || c.Account.RecordTypeID == '01213000001WHHO'){
                  	ids.add(c.ID);
                  	} 
                }
              else if(Trigger.isUpdate){
                  if(c.RecordTypeID == '01213000001WHHR' || c.Account.RecordTypeID == '01213000001WHHO'){
                  	ids.add(c.ID);
                  	}
                  //Only geocode an updated record if an address field has changed
                  Contact old = Trigger.oldMap.get(c.Id);
            
                  if(old.MailingStreet != c.MailingStreet || 
                      old.MailingCity != c.MailingCity ||
                      old.MailingState != c.MailingState ||
                      old.MailingPostalCode != c.MailingPostalCode ||
                      old.MailingCountry != c.MailingCountry){
                          idsToGeocode.Add(c.Id); 
                        }
                }
              //Ensure we're within our predetermined limit
              if(idsToGeocode.size()>=maxRecordsToGeocode){
                  break;
                }
            }
        ContactGeocodeCallout.doGeocodeRecords(idsToGeocode);
        AA_ContactTriggerHandler.updateTranscript(ids);
        }
  
  //Before deleting the Contact
  if(Trigger.isBefore && Trigger.isDelete){
  	for(Contact c: trigger.old){
  		if(c.RecordTypeID == '0121B0000018Fz2' && krsNonAdmins.contains(userInfo.getProfileId())){
  			if(!krsUsers.contains(userInfo.getUserId()) && c.OwnerID != userInfo.getUserId()){
  				c.addError('You are only permitted to delete Contact records that you created.  If you need this record removed please contact one of your admins.');
  				}
  			}
  		}
  	handler.onBeforeDelete(Trigger.oldMap);
    }
  
  //After deleting the Contact
  if(Trigger.isAfter){
    if(Trigger.isInsert){
      handleDMA.onAfterInsert(trigger.new);
        }
      
      if(Trigger.isUpdate){
        handleDMA.onAfterUpdate(trigger.oldMap, trigger.newMap);
        }
      
      if(Trigger.isDelete){
        handler.onAfterDelete(Trigger.oldMap);
        //After deleting the Contact during a merge operation
        for(Contact contact : trigger.old) {
            if(String.isNotBlank(contact.MasterRecordId)) { 
                newMergeRows.add(new Merge__c(LoserId__c = contact.Id, WinnerId__c = contact.MasterRecordId));  
              }         
          }
        if(newMergeRows.size() > 0) {
            insert newMergeRows;
          }
      }
    }
 
}