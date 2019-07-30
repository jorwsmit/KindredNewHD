@isTest
private class Test_TBN_CaseEntry {

    static testMethod void caseEntryPage(){
    	
    	User objUser = new User(
								FirstName = 'testFirst',
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
    	Case objCase = new Case(Type='Referral', Web_Last_Name__c = 'Test Web Case'); 
    	insert objCase;
    	test.startTest();
        //Definig Standarnd controller for the TBN_LogHeaderController and creating instances
        ApexPages.StandardController sc = new ApexPages.StandardController(objCase);
    	TBN_CaseEntry objCaseEntry = new TBN_CaseEntry(sc);
    	
    	TBN_CaseEntry.filterArticles('test','Referral', 0, 'Kindred__c');
    	TBN_CaseEntry.filterArticles('','Referral', 0, 'Kindred__c');
    	TBN_CaseEntry.filterArticles('','Referral', 0, '');
    	TBN_CaseEntry.getNearByAccounts('louisville', 'KY', '40202', Double.valueOf('38.25569280000001'),Double.valueOf('-85.751283')); 
    	TBN_CaseEntry.getNearByAccounts( '','KY', '',Double.valueOf('38.25569280000001'),Double.valueOf('-85.751283')); 
    	TBN_CaseEntry.searchContacts('test');
    	TBN_CaseEntry.searchPatients('test');
    	TBN_CaseEntry.retreiveFacilityContent('0912381923');
    	
    	Case_Entry_Map_Color_Codes__c objMapColor = new Case_Entry_Map_Color_Codes__c(Name='ALF',Color_Code__c='00CCCC', Type__c='ALF');
    	insert objMapColor;
    	TBN_CaseEntry.getColorCodesFromCS();
    	
    	Google_API_Key__c objGoogleAPIkey = new Google_API_Key__c(name = 'GoogleAPIKey', value__c = '3423472348');
    	insert objGoogleAPIkey;
    	
    	//For createing a case, contact, account, patient, Assessment, Additional contact
    	
    	objCaseEntry.objContact.LastName = 'LastName__Test';
    	
    	
    	objCaseEntry.createCaseNRedirectToDetail();
    	objCaseEntry = new TBN_CaseEntry(sc);
    	
    	//Case with close status
    	objCaseEntry.objContact.LastName = 'LastName__Test';
    	
    	objCaseEntry.createCaseWithCloseNRedirectToDetail();
    	objCaseEntry = new TBN_CaseEntry(sc);
    	
    	//Phone type is other than Phone
    	objCaseEntry.strphoneType = 'MobilePhone';
    	objCaseEntry.objContact.LastName = 'LastName__Test';
    	
    	objCaseEntry.createCaseNRedirectToDetail();
    	test.stopTest();
    }
    
    static testMethod void caseEntryPage1() {
       
        User objUser = new User(
								FirstName = 'testFirst',
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
    	test.startTest();
    	RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Individual' Limit 1];
    	Case objCase = new Case(Type='Referral', Web_Last_Name__c = 'Test Web Case'); 
    	insert objCase;
        //Definig Standarnd controller for the TBN_LogHeaderController and creating instances
        ApexPages.StandardController sc = new ApexPages.StandardController(objCase);
    	TBN_CaseEntry objCaseEntry = new TBN_CaseEntry(sc);
    	
    	LiveChatVisitor objvisitor = new LiveChatVisitor();
		insert objvisitor;
		update objvisitor; 
		
		Contact objContact = new Contact(lastName = 'testLName', phone = '7787676677',HomePhone= '7787676677', MobilePhone= '7787676677', OtherPhone= '7787676677', recordTypeId = rt.Id);
		insert objContact;
		LiveChatTranscript objTrans = new LiveChatTranscript(
															LiveChatVisitorId = objvisitor.Id,
															Email__c = 'test@test.com',
															First_Name__c = 'TestFirstName',
															Last_Name__c = 'TestLastName',
															Phone__c = '7787676677');
		insert objTrans;
    	ApexPages.currentPage().getParameters().put('transcriptId',objTrans.Id);
		
		ApexPages.currentPage().getParameters().put('phone','7787676677');
    	Apexpages.currentPage().getParameters().put('caseOrigin','KCC-Care');
    	objCaseEntry.createCaseNRedirectToDetail();
    	objCaseEntry = new TBN_CaseEntry(sc);
  		test.stopTest();  	
    }
    
    static testMethod void caseEntryPage2() {
       
        User objUser = new User(
								FirstName = 'testFirst',
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
    	test.startTest();
    	RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Individual' Limit 1];
    	Contact objContact = new Contact(lastName = 'testLName', phone = '7787676677',HomePhone= '7787676677', MobilePhone= '7787676677', OtherPhone= '7787676677', recordTypeId = rt.Id);
		insert objContact;
    	Patient_NEW__c objPatient = new Patient_NEW__c(Last_Name__c = 'Test Patient',Name = 'Test name', Status__c = 'Lead', Status_Detail__c = 'In Progress');
		insert objPatient;
        Case objCase = new Case(Type='Referral', Web_Last_Name__c = 'Test Web Case', Patient_New__c = objPatient.Id, Contact = objContact); 
    	insert objCase;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=objCase.id;
        insert attach;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objCase);
        TBN_CaseEntry ce = new TBN_CaseEntry(sc);
        Apexpages.currentPage().getParameters().put('attachmentId', attach.ID);
        Apexpages.currentPage().getParameters().put('callerId', '7787676677');
    	ApexPages.currentPage().getParameters().put('id',objCase.ID);
    	TBN_CaseEntry objCaseEntry = new TBN_CaseEntry(sc);
    	objCaseEntry.contactId = objContact.Id;
    	objCaseEntry.patientId = objPatient.Id; 
    	objCaseEntry.createCaseNRedirectToDetail();
    	
    	test.stopTest();  	
    }
    
    static testMethod void caseEntryPage3(){
    	
    	User objUser = new User(
								FirstName = 'testFirst',
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
    	Case objCase = new Case(Type='Referral', Web_Last_Name__c = 'Test Web Case'); 
    	insert objCase;
    	
        //Definig Standarnd controller for the TBN_LogHeaderController and creating instances
        ApexPages.StandardController sc = new ApexPages.StandardController(objCase);
    	TBN_CaseEntry objCaseEntry = new TBN_CaseEntry(sc);
    	//For creating a case, contact, account, patient, Assessment, Additional contact
    	
    	objCaseEntry = new TBN_CaseEntry(sc);
    	//Referral type case entry
    	objCaseEntry.objCase.Type = 'Referral';
    	objCaseEntry.objContact.LastName = 'LastName__Test';
    	objCaseEntry.objPatient.Last_Name__c = 'Test--Patient Name';
    	
    	Id ACCOUNT_RT_CENTER = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Account' AND DeveloperName = 'Center'].Id;
    	Account objFacility = new Account(Name = 'TestAccountFacility', Central_Intake_Email__c = 'test.kindred@gmail.com',RecordTypeId = ACCOUNT_RT_CENTER, Status__c = 'Active');
    	insert objFacility;
    	
    	Contact objContact1 = new Contact(AccountId = objFacility.Id, LastName= 'Test new Contact', Title = 'CM');
		insert objContact1;
		
		AccountTeamMember objATM1 = new AccountTeamMember(AccountId = objFacility.Id, TeamMemberRole = 'DDSM', UserId = objUser.Id);
		insert objATM1;
		
		AccountTeamMember objATM2 = new AccountTeamMember(AccountId = objFacility.Id, TeamMemberRole = 'VP', UserId = objUser.Id);
		insert objATM2; 
		test.startTest();
		Patient_NEW__c objPatient = new Patient_NEW__c(Last_Name__c = 'Test Patient',Name = 'Test name', Status__c = 'Lead', Status_Detail__c = 'In Progress');
		insert objPatient;
		
		Assessment__c objAssessment = new Assessment__c(Patient__c = objPatient.Id,Preferred_Facility__c = objFacility.id);
		insert objAssessment;
		
		Attachment attach1=new Attachment();   	
    	attach1.Name='Unit Test Attachment';
    	Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
    	attach1.body=bodyBlob1;
        attach1.parentId=objAssessment.id;
        insert attach1;
		
    	objCaseEntry.objAssessment.Preferred_Facility__c = objFacility.Id;
 		
 		Case objCaseDummay = new Case(Subject = 'Test$$$Patient$$$$$'+UserInfo.getName());
		insert objCaseDummay;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=objCaseDummay.id;
        insert attach;
        LiveChatVisitor objvisitor = new LiveChatVisitor();
		insert objvisitor;
		update objvisitor; 
		
		LiveChatTranscript objTrans = new LiveChatTranscript(
															LiveChatVisitorId = objvisitor.Id,
															Email__c = 'test@test.com',
															First_Name__c = 'TestFirstName',
															Last_Name__c = 'TestLastName');
		insert objTrans;
		ApexPages.currentPage().getParameters().put('attachmentId',attach.Id);

    	AccountTeamMember objATM = new AccountTeamMember(AccountId = objFacility.Id, TeamMemberRole = 'VP', UserId = objUser.Id);
    	insert objATM;
    	
    	objCaseEntry.createCaseNRedirectToDetail();
    	objCaseEntry = new TBN_CaseEntry(sc);
    	objCaseEntry.objPatient.Last_Name__c = 'test patient';
    	//autocomplete type contact/account
    	Contact objContact = [select id,AccountId, Name from Contact limit 1];
    	objCaseEntry.contactId = objContact.Id;
    	objCaseEntry.accountId = objContact.AccountId;
    	objCaseEntry.createCaseNRedirectToDetail();
    	
    	Case_Origin_for_IVR__c objCaseOrigin = new Case_Origin_for_IVR__c(Name ='KCC-Care', Case_Origin__c='Tele - KCC Care', Case_Origin_Code__c = '337433');
    	insert objCaseOrigin;
    	
    	ApexPages.currentPage().getParameters().put('transcriptId',objTrans.Id);
		
		ApexPages.currentPage().getParameters().put('phone','7787676677');
    	Apexpages.currentPage().getParameters().put('caseOrigin','KCC-Care');
    	Apexpages.currentPage().getParameters().put('id',objCase.Id);
    	objCaseEntry.createCaseNRedirectToDetail();
    	test.stopTest();
    }
}