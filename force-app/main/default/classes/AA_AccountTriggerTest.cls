@isTest 
private class AA_AccountTriggerTest {

    private static testMethod void TBN_TestAccountTrigger(){
	    
	    list<User> lstUserToInsert = new list<User>();
	    ID profileID = userinfo.getProfileId();
	    
	    User u = new User(ProfileId = profileID, 
	    				  FirstName = 'Test',
	    				  LastName = 'User',
	    				  userName = 'test234242423@usertest.none',
	    				  Alias = 'te9000', Email ='testContactTeam10998098@testorg.com', 
            			  EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', 
            			  LocaleSidKey ='en_US', TimeZoneSidKey ='America/Los_Angeles');
	    				  
	    insert u;				  
        
        KRS_SRS_BDO_Territory__c nT = new KRS_SRS_BDO_Territory__c(Name='Unknown');
        insert nT;
        
        KRS_SRS_BDO_Territory__c nT2 = new KRS_SRS_BDO_Territory__c(Name = 'KY');
        insert nT2;
        
        KRS_SRS_BDO_Territory_Member__c tM = new KRS_SRS_BDO_Territory_Member__c(Territory__c = nt2.ID, 
        																		 User__c = u.ID, 
        																		 Role__c = 'CT BDO');
        insert tM;
        																		 
        KRS_SRS_BDO_Territory_State__c tS = new KRS_SRS_BDO_Territory_State__c(Name = 'KY', 
        																	   Territory__c = nT2.ID);
        insert tS;
        
        KRS_SRS_BDO_Territory_Zipcode__c tZ = new KRS_SRS_BDO_Territory_Zipcode__c(Name = '40202', 
        																		   State__c = tS.ID,
        																		   Territory__c = nT2.ID);
        insert tZ;
                
        for(Integer i=0; i<=14; i++){
            lstUserToInsert.add(new User(Alias = 'teCon'+i, Email ='testContactTeam'+i+'@testorg.com', 
            EmailEncodingKey ='UTF-8', LastName ='testContactTeam'+i, LanguageLocaleKey ='en_US', 
            LocaleSidKey ='en_US', ProfileId = profileID, TimeZoneSidKey ='America/Los_Angeles', UserName ='testContactTeam'+i+'@testorg.com'));
        	}
        insert lstUserToInsert;
        
	    list<Account>lstAccount = new list<Account>();
        
        List<RecordType> lstRecTypesAcc = [Select Name, Id From RecordType where sObjectType='Account' AND isActive = true];
        List<RecordType> lstRecTypesCon = [Select Name, Id From RecordType where sObjectType='Contact' AND isActive = true];
        
        Account objAccount = new Account(Name='TestAccount', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '12');
		lstAccount.add(objAccount);
		
		Account objAccount2 = new Account(Name='TestAccount2', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '123');
		lstAccount.add(objAccount2);
		
		Account objAccount5 = new Account(Name='TestAccount5');
		lstAccount.add(objAccount5);
		
		Account objAccount6 = new Account(Name='TestAccount6');
		lstAccount.add(objAccount6);
		
		Account objAccount7 = new Account(Name='TestAccount7');
		lstAccount.add(objAccount7);
		
		Account objAccount8 = new Account(Name='TestAccount8');
		lstAccount.add(objAccount8);
		
		Account objAccount9 = new Account(Name='TestAccount9');
		lstAccount.add(objAccount9);
		
		Account objAccount10 = new Account(Name='TestAccount10');
		lstAccount.add(objAccount10);
		
		Account objAccount11 = new Account(Name='TestAccount11');
		lstAccount.add(objAccount11);
		
		Account objAccount12 = new Account(Name='TestAccount12');
		lstAccount.add(objAccount12);
		
		Account objAccount13 = new Account(Name='TestAccount13');
		lstAccount.add(objAccount13);
		
		insert lstAccount;
		
		Sales_Account_Metrics__c objAccountMetric = new Sales_Account_Metrics__c(name='test AM' , Account__c=objAccount2.id, Month__c=date.today());
		insert objAccountMetric;
		
		Restrict_Deletion__c objRestrictDel = new Restrict_Deletion__c(Name = profileId, Account_RT__c = lstRecTypesAcc[0].Id, Contact_RT__c = lstRecTypesCon[0].Id, Profile_Name__c = 'KAH Liason');
		insert objRestrictDel;
	    
	    Account objAccount3 = new Account(Name='TestAccount3', Merge_Master__c = true);
		insert objAccount3;
		
		Account objAccount4 = new Account(Name='TestAccount4');
		insert objAccount4;
		
		merge objAccount3 objAccount4; 
	
		objAccount11.ShippingStreet = '680 S 4th St';
		objAccount11.ShippingCity = 'Louisville';
		objAccount11.ShippingState = 'KY';
		objAccount11.ShippingPostalCode = '40202';
		update objAccount11;
		merge objAccount13 objAccount11;
		
        Account objAccount14 = new Account(Name='TestAccount2', RecordTypeId = '0121B0000018Fz1', NPI__c = '129');
		insert objAccount14;
		objAccount14.BillingState = 'KY';
		objAccount14.BillingPostalCode = '40202';
		update objAccount14;
		
		Date dt = date.newInstance(system.today().Year(), system.today().month()-21, system.today().day());
		Opportunity opp = new Opportunity(Name = objAccount14.Name + ' OpportunityTest', StageName='Closed Lost',
                                      	  CloseDate = dt, KRS_Future_Task__c = true
                                      	  );
        insert opp;
        
        Opportunity opp2 = new Opportunity(Name = objAccount14.Name + ' OpportunityTest', StageName='Closed Won',
                                      	  CloseDate = dt, KRS_Future_Task__c = true
                                      	  );
        insert opp2;
        String CRON_EXP = '0 0 * * * ?';
		AA_KRSFutureTaskProcessScheduler sch = new AA_KRSFutureTaskProcessScheduler();
		system.schedule('KRSFutureTaskSchedulerTest', CRON_EXP, sch);
		}
    
    private static testMethod void method2(){
    	Account objAccount = new Account(Name='TestAccount');
		insert objAccount;
		
		Account objAccount2 = new Account(Name='TestAccount2');
		insert objAccount2;
        
        objAccount2.Merge_Requested_With_ID__c = objAccount.ID;
        objAccount2.Merge_Request_With_Name__c = objAccount.Name;
        objAccount2.Merge_Approved__c = true;
        
        update objAccount2;
        
    	}
	
}