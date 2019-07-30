@isTest 
private class AA_RHCReportControllerTest {

    static testMethod void myUnitTest() {
        User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser){
        Account objAccount = new Account(Name='TestAccount', RecordTypeId = '01213000001WHKX', NPI__c = '12');
		insert objAccount;
		
		ID profileID = userinfo.getProfileId();
		list<User> toInsert = new list<User>();
		
		User u = new User(ProfileId = profileID, 
	    				  FirstName = 'Test',
	    				  LastName = 'User',
	    				  userName = 'test234242423@usertest.none',
	    				  UserRoleId = '00E130000020y7y',
	    				  Alias = 'te9000', Email ='testContactTeam10998098@testorg.com', 
            			  EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', 
            			  LocaleSidKey ='en_US', TimeZoneSidKey ='America/Los_Angeles');
            			  
        toInsert.add(u);
         
        User u2 = new User(ProfileId = profileID, 
	    				  FirstName = 'Test2',
	    				  LastName = 'User2',
	    				  userName = 'test223@usernonetest.none',
	    				  UserRoleId = '00E130000020yys',
	    				  Alias = 'te90', Email ='testContactTeam10998098@testorg.com', 
            			  EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', 
            			  LocaleSidKey ='en_US', TimeZoneSidKey ='America/Los_Angeles');
            			  
        toInsert.add(u2);
         
         
        User u3 = new User(ProfileId = profileID, 
	    				  FirstName = 'Test3',
	    				  LastName = 'User3',
	    				  userName = 'test2333@user3nonetest.none',
	    				  UserRoleId = '00E130000020yyx',
	    				  Alias = 'te30', Email ='testContactTeam10998098@testorg.com', 
            			  EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', 
            			  LocaleSidKey ='en_US', TimeZoneSidKey ='America/Los_Angeles');
            			  
        toInsert.add(u3);
         
        insert toInsert;
        
        AccountTeamMember atm = new AccountTeamMember(AccountId = objAccount.ID,
													  TeamMemberRole = 'ADO (Partner First)',
													  UserId = u3.Id);
		insert atm;													     			  
        
        list<Contact>lstContact = new list<Contact>();
		Contact objContact = new Contact(LastName='TestContact', RecordTypeId = '01213000001WHKZ', NPI__c = '1263', AccountID = objAccount.ID);
		lstContact.add(objContact);
		
		Contact objContact2 = new Contact(LastName='TestContact2', RecordTypeId = '01213000001WHKZ', NPI__c = '5123', AccountID = objAccount.ID);
		lstContact.add(objContact2);
		
		Contact objContact3 = new Contact(LastName='TestContact3', RecordTypeId = '01213000001WHKZ', NPI__c = '7123', AccountID = objAccount.ID);
		lstContact.add(objContact3);
		insert lstContact;
		
		Contact_Team__c ctm = new Contact_Team__c(Contact__c = objContact.ID,
												  User__c = u2.ID
												  );
		insert ctm;
		
		Contact_Team__c ctm2 = new Contact_Team__c(Contact__c = objContact2.ID,
												  User__c = u3.ID
												  );
		insert ctm2;
		
		string letterStart = 't';
		string letterEnd = 'u';
		list<string> ADO_Filter = new list<string>();
		list<string> RVP_Filter = new list<string>();
		
        AA_RHCReportController.getReportNames();
        AA_RHCReportController.getAccounts();
        AA_RHCReportController.getContacts('TestAccount');
        AA_RHCReportController.getDVPTeams('TestAccount');
        AA_RHCReportController.getRVPTeams('TestAccount');
        AA_RHCReportController.getADOTeams('TestAccount');
        AA_RHCReportController.getFacility('TestAccount');
        AA_RHCReportController.getDVPActivities('TestAccount');
        AA_RHCReportController.getRVPActivities('TestAccount');
        AA_RHCReportController.getADOActivities('TestAccount');
        AA_RHCReportController.getReportTable('Contacts Reporting', 'TestAccount');
        AA_RHCReportController.getAllRHBActive(letterStart, letterEnd, ADO_Filter, RVP_Filter);
        AA_RHCReportController.getAllRHBActiveNoLimit(ADO_Filter, RVP_Filter);
        AA_RHCReportController.getADOs();
        AA_RHCReportController.getRVPs();
        ADO_Filter.add('Lynn Reach King');
        AA_RHCReportController.getAllRHBActive(letterStart, letterEnd, ADO_Filter, RVP_Filter);
        test.startTest();
        Task t = new Task(Subject = 'NPS Survey Follow-up', OwnerID = u3.Id, ActivityDate = system.today(), WhoID = objContact3.ID, WhatID = objAccount.ID);
        insert t;
        AA_RHCReportController.getNPSTasks(ADO_Filter, RVP_Filter);
        ADO_Filter.clear();
        RVP_Filter.clear();
        AA_RHCReportController.getNPSTasks(ADO_Filter, RVP_Filter);
        test.stopTest();
        }
    	}
}