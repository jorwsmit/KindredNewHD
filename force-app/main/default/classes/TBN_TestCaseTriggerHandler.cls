@isTest
private class TBN_TestCaseTriggerHandler {
    
    static testMethod void caseTriggerOriginUpdates() {
        
        /* Insert the records required for trigger on case */
        User objUser = new User(FirstName = 'testFirst',
								LastName = 'TestUser' + String.valueOf(Date.today()), 
								Email = 'TestUser' + String.valueOf(Date.today()) + '_' + '@gmail.com',
								Username = 'TestUser_Test_TBN_CaseEntry' + String.valueOf(Date.today()) + '_' +  '@gmail.com',
								isActive = true,
								Alias = 'tu',
								TimeZoneSidKey = 'America/New_York',
								LocaleSidKey = 'en_US',
								EmailEncodingKey = 'ISO-8859-1', 
								LanguageLocaleKey = 'en_US',
								ProfileId =  Userinfo.getProfileId(),
								CommunityNickname = 'TestCommunity' + String.valueOf(Date.today()) + '_', 
								Title = 'Title11',
								City = 'testCity',
								Country = 'testCountry',
								Street = 'testStreet',
								CompanyName = 'testCompanyName',
								Phone = 'testPhone',
								Extension = 'testExtension',
								PostalCode = '2345'
							    );
    	insert objUser;
    	
    	Id ACCOUNT_RT_CENTER = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Account' AND DeveloperName = 'Center'].Id;
    	Account objFacility = new Account(Name = 'TestAccountFacility', Central_Intake_Email__c = 'test.kindred@gmail.com',RecordTypeId = ACCOUNT_RT_CENTER);
    	insert objFacility;
    	
    	Contact objContact1 = new Contact(AccountId = objFacility.Id, LastName= 'Test new Contact', Title = 'CM');
		insert objContact1;
		
		AccountTeamMember objATM1 = new AccountTeamMember(AccountId = objFacility.Id, TeamMemberRole = 'DDSM', UserId = objUser.Id);
		insert objATM1;
		
		AccountTeamMember objATM2 = new AccountTeamMember(AccountId = objFacility.Id, TeamMemberRole = 'VP', UserId = objUser.Id);
		insert objATM2; 
		
		Patient_NEW__c objPatient = new Patient_NEW__c(Last_Name__c = 'Test Patient',Name = 'Test name', Status__c = 'Lead', Status_Detail__c = 'In Progress');
		insert objPatient;
		
		Assessment__c objAssessment = new Assessment__c(Patient__c = objPatient.Id,Preferred_Facility__c = objFacility.id);
		insert objAssessment;
		
		Test.startTest();
		
        	Case objCase = new Case(AccountId = objFacility.Id,
        	                        ContactId = objContact1.Id,
        	                        Patient_New__c = objPatient.Id,
        	                        Assessment__c = objAssessment.Id,
        	                        Origin = 'System Review',
        	                        Subject = 'Test$$$Patient$$$$$'+UserInfo.getName() );
    		insert objCase;
    		
    		// Confirm that with Case inserted, Contact's Case Origin is updated
    		List<Contact> lstContacts = [Select Id, Case_Origin__c From Contact Where Id = :objContact1.Id];
    	    system.assertEquals('System Review', lstContacts[0].Case_Origin__c);
    		
    		Case objCase1 = new Case(AccountId = objFacility.Id,
        	                        ContactId = objContact1.Id,
        	                        Patient_New__c = objPatient.Id,
        	                        Assessment__c = objAssessment.Id,
        	                        Origin = 'Telephone Call - Hospice of Charleston',
        	                        Subject = 'Test$$$Patient$$$$$'+UserInfo.getName() );
    		insert objCase1;
    		
    		// Confirm that with new Case created for the same Contact, Contact's Case Origin is updated
    		lstContacts = [Select Id, Case_Origin__c From Contact Where Id = :objContact1.Id];
    	    system.assertEquals('Telephone Call - Hospice of Charleston', lstContacts[0].Case_Origin__c);
    		
    		objCase.Origin = 'Telephone Call';
    	    update objCase;
    	    
    	    // Confirm that with Case updated, Contact's Case Origin is updated
    	    lstContacts = [Select Id, Case_Origin__c From Contact Where Id = :objContact1.Id];
    	    //system.assertEquals('Telephone Call', lstContacts[0].Case_Origin__c);
    	    
    	    delete objCase;
    	    
    	    // Confirm that with Case deleted, Contact's Case Origin is reverted to last Case record (based on last modified date)
    	    lstContacts = [Select Id, Case_Origin__c From Contact Where Id = :objContact1.Id];
    	    system.assertEquals('Telephone Call - Hospice of Charleston', lstContacts[0].Case_Origin__c);
    	    
    	Test.stopTest();
    }
    
     static testMethod void caseTriggerWebtoCase() {
        
        RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Individual' Limit 1];
        
        Account objAcc =  new Account(Name = 'TestAccount');
        insert objAcc;
        
        Contact objContact1 = new Contact(AccountId = objAcc.Id, LastName= 'Test new Contact', Title = 'CM', Email = 'Test@test.com', recordTypeId = rtContact.Id);
		insert objContact1;
		
		Case objCase = new Case(Subject = 'Test$$$Patient$$$$$'+UserInfo.getName(), 
        	                        SuppliedEmail = 'Test@test.com', Web_Last_Name__c='Test Web1');
        insert objCase;
    		
    	Case objCase1 = new Case(Subject = 'Test$$$Patient$$$$$'+UserInfo.getName(), SuppliedEmail = 'abc@abc.com', Web_Last_Name__c='Test Web', Web_First_Name__c='Test Web First Name',
    	                        Web_City__c = 'testCity', Web_State__c = 'AL', Web_Zip_Code__c = '12343', SuppliedPhone = '1234567899', Web_Street_Address__c ='test street' );
    	insert objCase1;
    	
    	Case objCase2 = new Case(Subject = 'Test$$$Patient$$$$$'+UserInfo.getName(), SuppliedEmail = 'abc123@abc.com', Web_Last_Name__c='Test Web',
    	                        Web_City__c = 'testCity', Web_State__c = 'AL', Web_Zip_Code__c = '12343', SuppliedPhone = '1234567899', Web_Street_Address__c ='test street' );
    	insert objCase2;
    		
    }
}