@isTest
private class TBN_TestAssociateDataManagement {

    static testMethod void TBN_AssociateData() { 
    	
    	User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
    	System.runAs ( thisUser ) {
    		
	    	TBN_AssociateDataManagementController objDataManagement = new TBN_AssociateDataManagementController();
	    	String PARENT_ROLE = 'SVP - KAH';
	    	UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
	    	UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
	    	UserRole objUserRole2 = [select id from UserRole where Name =:'HD Central Region' Limit 1];
			//TargetAssessment.strSelectedDivision = objUserRole.Id;
			User objUser = new User(
									FirstName = 'testFirst',
									LastName = 'TestUser' + String.valueOf(Date.today()), 
									Email = 'TestUser' + String.valueOf(Date.today()) + '_' + '@gmail.com',
									Username = 'TestUser_Test' + String.valueOf(Date.today()) + '_' +  '@gmail.com',
									isActive = true,
									Alias = 'tu',
									TimeZoneSidKey = 'America/New_York',
									LocaleSidKey = 'en_US',
									EmailEncodingKey = 'ISO-8859-1', 
									LanguageLocaleKey = 'en_US',
									ProfileId =  Userinfo.getProfileId(),
									CommunityNickname = 'TestCommunity1' + String.valueOf(Date.today()) + '_', 
									Title = 'Title11',
									City = 'testCity',
									Country = 'testCountry',
									Street = 'testStreet',
									CompanyName = 'testCompanyName',
									Phone = 'testPhone',
									Extension = 'testExtension',
									PostalCode = '2345',
									UserRoleid= objUserRole.id
								);
	    	insert objUser;
	    	
	    	User objUser2 = new User(
	    							
					                username = 'newUserDataManagement'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
					                email = 'pb@ff.com', 
					                emailencodingkey = 'UTF-8', 
					                localesidkey = 'en_US', 
					                languagelocalekey = 'en_US', 
					                timezonesidkey = 'America/Los_Angeles', 
					                alias='nuser', 
					                lastname='lastname', 
					                ProfileId =  Userinfo.getProfileId(),
					                managerId= objUser.id,
					                Perner__c = '546437576' 
					                
	        ); 
	        insert objUser2;
	        
	        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='PF_Chain' Limit 1];
	        RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='General_Contact' Limit 1];
	        
	        
	        
	        Account objParentAccount = new Account (Name ='Kindred Healthcare Inc');
	        insert objParentAccount;
	        
	        Account objAccount = new Account(name = 'Test AccountTest AccountTest Account', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
	 		insert objAccount;
	 		
	 		Account objA = new Account(name = 'Unassigned Account - Admin Maintenance');
	 		insert objA;
	 		
	 		Contact objContact = new Contact(LastName = 'Test Contact,', FirstName ='TestCont,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10 );
	 		insert objContact;
	 		
	 		Account objAccount1 = new Account(name = 'Test ,Account1,', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 33.49,Shipping_Geolocation__Latitude__s = 64.66, KAH_HH_Referrals_YTD__c = 10);
	 		insert objAccount1;
	 		
	 		/*Account objAccount3 = new Account(name = 'Test Account', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66);
	 		insert objAccount3;*/
	 		
	 		Contact objContact1 = new Contact(LastName = 'Test Contact1,', FirstName='Contact,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10);
	 		insert objContact1;
	 		
	    	Home_Facility__c objHomeFacility = new Home_Facility__c (User__c = objUser.id, Account__c = objAccount.Id);
	    	insert objHomeFacility;
	    	
	    	Home_Facility__c objHomeFacility1 = new Home_Facility__c (User__c = UserInfo.getUserId(), Account__c = objAccount.Id);
	    	insert objHomeFacility1;
	    	
			AccountTeamMember objATM =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount.Id);
			insert objATM;
			 
			AccountTeamMember objATM1 =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount1.Id);
			insert objATM1;
			 
			Contact_Team__c objCTM = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact.Id );
			insert objCTM;
			 
			Contact_Team__c objCTM1 = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact1.Id);
			insert objCTM1;
			
			Test.startTest();
			
	    	String strtest=objDataManagement.strSelectedUser;
	    	string strFromUser = objUser2.id;
	    	string strtestRole = objUserRole.Id;
	    	string TDid = 'Name';
	    	string TDidReassign = 'ReassignName';
	    	string strAriaSort = 'ascending';
	    	string strSpecilaityFilterValue = '';
	    	string whereQueryAccount = '';
	    	string whereQueryContact = '';
	    	string onTableLoad = 'false';
	    	string isTypeFilter = '';
	    	String strTest2 = 'AllAccountsAndContacs';
	    	String strTest02 = 'AllAccandCont';
	    	String strTestcustomer = 'Customer';
	    	String strTestProspect = 'Prospect';
	    	String strUserRole = objUserRole.Id;
	    	String strSourceFilter = 'Horizon';
	    	objDataManagement.strSelectedUser = objUser.Id;
	    	objDataManagement.strSelectedState = 'FA';
	    	objDataManagement.fetchUserData();
	    	
	    	objUser.UserRoleid = objUserRole1.Id;
	    	objDataManagement.updateUserRole();
	    	system.assertEquals(objUser.UserRoleid, objUserRole1.Id);
	    	
	    	objUser.lastname = 'lastnameUser';
	    	objDataManagement.saveUser();
	    	system.assertEquals(objUser.lastname, 'lastnameUser');
	    	
	       	
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTest02);
	       	TDid = 'ShippingPostalCode';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTest02);
	       	TDid ='strSpecialties';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTest02);
	       	strAriaSort = '';
	       	strSpecilaityFilterValue = 'Pulmonary';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTest02);
	       	TBN_AssociateDataManagementController.fetchReassignReferralSourcesTableSorter(TDidReassign, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, isTypeFilter, strtest);
	       	
	       	isTypeFilter = 'ContactFilter';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTest02);
	       	
	       	whereQueryAccount = 'AND Account.ShippingState = u2019AKu2019  AND Account.Name like u2019%te%u2019  AND Account.ShippingPostalCode like u2019%12%u2019 '; 
	       	whereQueryContact = 'AND Account.ShippingState = u2019AKu2019  AND Account.Name like u2019%te%u2019  AND Account.ShippingPostalCode like u2019%12%u2019 ';
	       	strSpecilaityFilterValue = 'ot';
	       	isTypeFilter = '';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTest02);
	       	
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTestcustomer);
	       	
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest2, strSourceFilter, strTestProspect);
	       	
	       	String strTest3 = 'CurrentlyAssigned';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strTest3, strSourceFilter, strTest02);
	       	
	       	strSpecilaityFilterValue = '';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strTest3, strSourceFilter, strTest02);
	       	
	       	strSpecilaityFilterValue = 'ot';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strTest3, strSourceFilter, strTestcustomer);
	       	
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strTest3, strSourceFilter, strTestProspect);
	       	
	      	String strTest6 = '50';
	      	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strtest6, strSourceFilter, strTest02);
	       	
	       	String strTestUser = objUser2.Id;
	      	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strTestUser, strtest6, strSourceFilter, strTest02);
	       	
	       	
	       	String strTest8 = '100';
	       	TBN_AssociateDataManagementController.fetchReferralSourcesTableSorter(TDid, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, onTableLoad, isTypeFilter, strtest, strTest8, strSourceFilter, strTest02);
	       	
	       	TBN_AssociateDataManagementController.fetchParentRoles(strtest, '');
	       	TBN_AssociateDataManagementController.fetchParentRoles(UserInfo.getUserId(), objUserRole2.Id);
	       	
	       	String strTest4 = '[{"strReferralId":"'+objContact1.Id+'","strType":"Contact","strOperation":"Insert"}]';
	       	TBN_AssociateDataManagementController.assignReferralSources(strTest,strTest4);
	       	
	      	String strTest5 = '[{"strReferralId":"'+objAccount1.Id+'","strType":"Account","strOperation":"Insert"}]';
	       	TBN_AssociateDataManagementController.assignReferralSources(strTest,strTest5);
	       	
	       	String strTest04 = '[{"strReferralId":"'+objContact1.Id+'","strType":"Contact","strOperation":"Delete"}]';
	       	TBN_AssociateDataManagementController.assignReferralSources(strTest,strTest04);
	       	
	      	String strTest05 = '[{"strReferralId":"'+objAccount1.Id+'","strType":"Account","strOperation":"Delete"}]';
	       	TBN_AssociateDataManagementController.assignReferralSources(strTest,strTest05);
	       	
	       	string referralidString =objAccount1.id+'#'+objContact.id;
	       	TBN_AssociateDataManagementController.reAssignReferralSources(strFromUser, strTest, referralidString);
	       	
	       	//String strReassignUser = objUser.Id;
	       	string strAccid = objAccount1.Id; 
	       	string strContId = objContact1.id;
	       	
	       	String strTestAccID = objAccount.Id;  
	       	//TBN_AssociateDataManagementController.fetchTeamMembers(strTestAccID);
	       	TBN_AssociateDataManagementController.fetchAutocompleteDetails(strtest);
	       	
	      
	    	Test.stopTest();
    	}
    }
    
    static testMethod void TBN_AssociateData2() { 
        
        User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
      System.runAs ( thisUser ) {
          TBN_AssociateDataManagementController objDataManagement = new TBN_AssociateDataManagementController();
          String PARENT_ROLE = 'SVP - KAH';
        UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
        UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
          
          User objUser = new User(
                  FirstName = 'testFirst',
                  LastName = 'TestUser' + String.valueOf(Date.today()), 
                  Email = 'TestUser' + String.valueOf(Date.today()) + '_' + '@gmail.com',
                  Username = 'TestUser_Test' + String.valueOf(Date.today()) + '_' +  '@gmail.com',
                  isActive = true,
                  Alias = 'tu',
                  TimeZoneSidKey = 'America/New_York',
                  LocaleSidKey = 'en_US',
                  EmailEncodingKey = 'ISO-8859-1', 
                  LanguageLocaleKey = 'en_US',
                  ProfileId =  Userinfo.getProfileId(),
                  CommunityNickname = 'TestCommunity1' + String.valueOf(Date.today()) + '_', 
                  Title = 'Title11',
                  City = 'testCity',
                  Country = 'testCountry',
                  Street = 'testStreet',
                  CompanyName = 'testCompanyName',
                  Phone = 'testPhone',
                  Extension = 'testExtension',
                  PostalCode = '2345',
                  UserRoleid= objUserRole.id
                );
        insert objUser;
        User objUser2 = new User(
                    
                          username = 'newUserDataManagement1'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
                          email = 'pb@ff.com', 
                          emailencodingkey = 'UTF-8', 
                          localesidkey = 'en_US', 
                          languagelocalekey = 'en_US', 
                          timezonesidkey = 'America/Los_Angeles', 
                          alias='nuser', 
                          lastname='lastname', 
                          ProfileId =  Userinfo.getProfileId(),
                          managerId= objUser.id,
                          Perner__c = '546437576' 
                          
          ); 
          
          User objUser3 = new User(
                    FirstName = 'testFirsttestFirsttestsss',
                          username = 'newUser3'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
                          email = 'pb@ff.com', 
                          emailencodingkey = 'UTF-8', 
                          localesidkey = 'en_US', 
                          languagelocalekey = 'en_US', 
                          timezonesidkey = 'America/Los_Angeles', 
                          alias='nuser', 
                          lastname='lastname', 
                          ProfileId =  Userinfo.getProfileId(),
                          managerId= objUser.id,
                          Perner__c = '54642576' 
                          
          ); 
          insert objUser3;
          
          insert objUser2;
          RecordType rt = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='PF_Chain' Limit 1];
          RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='General_Contact' Limit 1];
          
          Account objParentAccount = new Account (Name ='Kindred Healthcare Inc');
          insert objParentAccount;
          
          Account objAccount = new Account(name = 'Test AccountTest AccountTest Account', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount;
       
       Contact objContact = new Contact(LastName = 'Test Contact,', FirstName ='TestCont,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10 );
       insert objContact;
       
        Test.startTest();
        
        String strUserRole = objUserRole.Id;
        TBN_AssociateDataManagementController.fetchUserRoles(strUserRole);
           TBN_AssociateDataManagementController.fetchUserRoles('test');
            
           String strtest=objDataManagement.strSelectedUser;
        string strFromUser = objUser2.id;
        string strtestRole = objUserRole.Id;
        string TDid = 'Name';
        string TDidReassign = 'ReassignName';
        string strAriaSort = 'ascending';
        string strSpecilaityFilterValue = '';
        string whereQueryAccount = '';
        string whereQueryContact = '';
        string onTableLoad = 'false';
        string isTypeFilter = '';
        String strTest2 = 'AllAccountsAndContacs';
        String strTest02 = 'AllAccandCont';
        String strTestcustomer = 'Customer';
        String strTestProspect = 'Prospect';
        
        TBN_AssociateDataManagementController.fetchAutocompleteDetails(objUser3.id);
        
        TBN_AssociateDataManagementController.fetchReassignReferralSourcesTableSorter(TDidReassign, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, isTypeFilter, strtest);
           
           TDidReassign = 'ReassingShippingPostalCode';
           TBN_AssociateDataManagementController.fetchReassignReferralSourcesTableSorter(TDidReassign, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, isTypeFilter, strtest);
           TDidReassign = 'ReassingstrSpecialties';
           TBN_AssociateDataManagementController.fetchReassignReferralSourcesTableSorter(TDidReassign, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, isTypeFilter, strtest);
           isTypeFilter = 'ContactFilter';
        TBN_AssociateDataManagementController.fetchReassignReferralSourcesTableSorter(TDidReassign, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, isTypeFilter, strtest);
         isTypeFilter = 'AccountFilter';
        TBN_AssociateDataManagementController.fetchReassignReferralSourcesTableSorter(TDidReassign, strAriaSort, strSpecilaityFilterValue, whereQueryAccount, whereQueryContact, isTypeFilter, strtest);
         
        TBN_AssociateDataManagementController.fetchAutocompleteDetails(objUser2.id);
           TBN_AssociateDataManagementController.fetchAutocompleteDetails(objAccount.id);
           TBN_AssociateDataManagementController.fetchTeamMembers(objAccount.id);
           TBN_AssociateDataManagementController.fetchTeamMembers(objContact.id);
        
          objDataManagement.fetchReferralSourceCount();
        objDataManagement.fetchReferralsCountonReassignment();
        test.stopTest();
      }
    } 
    
    private static testMethod void testWork2(){
   	
   	TBN_AssociateDataManagementController controller = new TBN_AssociateDataManagementController();
   	
   	User u = new User(username = 'a@a324234463634643623423532534534.com', 
                             email = 'pb@ff.com', 
                             emailencodingkey = 'UTF-8', 
                             localesidkey = 'en_US', 
                             languagelocalekey = 'en_US', 
                             timezonesidkey = 'America/Los_Angeles', 
                             alias='nuser', 
                             lastname='aaahjgkgjhghjgkjgkjgkjgkjgk', 
                             firstname = '',
                             Line_of_Business__c = 'Bus',
                             Perner__c = '24234234234223',
                             ProfileId =  Userinfo.getProfileId()
                             ); 
            insert u;
   	
   	User u2 = new User(username = 'a@a32423446361122131114643623423532534534.com', 
                             email = 'pb@ff.com', 
                             emailencodingkey = 'UTF-8', 
                             localesidkey = 'en_US', 
                             languagelocalekey = 'en_US', 
                             timezonesidkey = 'America/Los_Angeles', 
                             alias='nuser', 
                             lastname='kjgkjgk', 
                             firstname = 'hola',
                             Line_of_Business__c = 'Big mac imports',
                             Perner__c = '24232',
                             ProfileId =  Userinfo.getProfileId()
                             ); 
            insert u2;
   			
   	
   	system.runAs(u){
   		controller.init();
   		controller.fetchUserData();
   		controller.saveUser();
   		controller.fetchReferralSourceCount();
   		controller.fetchReferralsCountonReassignment();
   		}
   	system.runAs(u2){
   		controller.init();
   		}	
   			
   	//controller.upsertSalesPerformances();
   	
   	} 
    
    static testMethod void TBN_AssociateData3() { 
    	
    	User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
    	System.runAs (thisUser) {
    		
	    	TBN_AssociateDataManagementController objDataManagement = new TBN_AssociateDataManagementController();
	    	String PARENT_ROLE = 'SVP - KAH';
	    	UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
	    	UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
	    	UserRole objUserRole2 = [select id from UserRole where Name =:'HD Central Region' Limit 1];
			//TargetAssessment.strSelectedDivision = objUserRole.Id;
			User objUser = new User(
									FirstName = 'testFirst',
									LastName = 'TestUser' + String.valueOf(Date.today()), 
									Email = 'TestUser' + String.valueOf(Date.today()) + '_' + '@gmail.com',
									Username = 'TestUser_Test' + String.valueOf(Date.today()) + '_' +  '@gmail.com',
									isActive = true,
									Alias = 'tu',
									TimeZoneSidKey = 'America/New_York',
									LocaleSidKey = 'en_US',
									EmailEncodingKey = 'ISO-8859-1', 
									LanguageLocaleKey = 'en_US',
									ProfileId =  Userinfo.getProfileId(),
									CommunityNickname = 'TestCommunity1' + String.valueOf(Date.today()) + '_', 
									Title = 'Title11',
									City = 'testCity',
									Country = 'testCountry',
									Street = 'testStreet',
									CompanyName = 'testCompanyName',
									Phone = 'testPhone',
									Extension = 'testExtension',
									PostalCode = '2345',
									UserRoleid= objUserRole.id
								);
	    	insert objUser;
	    	
	    	User objUser2 = new User(
	    							
					                username = 'newUserDataManagement'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
					                email = 'pb@ff.com', 
					                emailencodingkey = 'UTF-8', 
					                localesidkey = 'en_US', 
					                languagelocalekey = 'en_US', 
					                timezonesidkey = 'America/Los_Angeles', 
					                alias='nuser', 
					                lastname='lastname', 
					                ProfileId =  Userinfo.getProfileId(),
					                managerId= objUser.id,
					                Perner__c = '546437576' 
					                
	        ); 
	        insert objUser2;
	        
	        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='PF_Chain' Limit 1];
	        RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='General_Contact' Limit 1];
	        
	        
	        
	        Account objParentAccount = new Account (Name ='Kindred Healthcare Inc');
	        insert objParentAccount;
	        
	        Account objAccount = new Account(name = 'Test AccountTest AccountTest Account', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
	 		insert objAccount;
	 		
	 		Account objA = new Account(name = 'Unassigned Account - Admin Maintenance');
	 		insert objA;
	 		
	 		Contact objContact = new Contact(LastName = 'Test Contact,', FirstName ='TestCont,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10 );
	 		insert objContact;
	 		
	 		Account objAccount1 = new Account(name = 'Test ,Account1,', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 33.49,Shipping_Geolocation__Latitude__s = 64.66, KAH_HH_Referrals_YTD__c = 10);
	 		insert objAccount1;
	 		
	 		/*Account objAccount3 = new Account(name = 'Test Account', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66);
	 		insert objAccount3;*/
	 		
	 		Contact objContact1 = new Contact(LastName = 'Test Contact1,', FirstName='Contact,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10);
	 		insert objContact1;
	 		
	    	Home_Facility__c objHomeFacility = new Home_Facility__c (User__c = objUser.id, Account__c = objAccount.Id);
	    	insert objHomeFacility;
	    	
	    	Home_Facility__c objHomeFacility1 = new Home_Facility__c (User__c = UserInfo.getUserId(), Account__c = objAccount.Id);
	    	insert objHomeFacility1;
	    	
			AccountTeamMember objATM =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount.Id);
			insert objATM;
			 
			AccountTeamMember objATM1 =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount1.Id);
			insert objATM1;
			 
			Contact_Team__c objCTM = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact.Id );
			insert objCTM;
			 
			Contact_Team__c objCTM1 = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact1.Id);
			insert objCTM1;
			
			Test.startTest();
			
	    	String strtest=objDataManagement.strSelectedUser;
	    	string strFromUser = objUser2.id;
	    	string strtestRole = objUserRole.Id;
	    	string TDid = 'Name';
	    	string TDidReassign = 'ReassignName';
	    	string strAriaSort = 'ascending';
	    	string strSpecilaityFilterValue = '';
	    	string whereQueryAccount = '';
	    	string whereQueryContact = '';
	    	string onTableLoad = 'false';
	    	string isTypeFilter = '';
	    	String strTest2 = 'AllAccountsAndContacs';
	    	String strTest02 = 'AllAccandCont';
	    	String strTestcustomer = 'Customer';
	    	String strTestProspect = 'Prospect';
	    	String strUserRole = objUserRole.Id;
	    	String strSourceFilter = 'Horizon';
	    	objDataManagement.strSelectedUser = objUser.Id;
	    	objDataManagement.strSelectedState = 'FA';
	    	objDataManagement.fetchUserData();
	    	
	    	objUser.UserRoleid = objUserRole1.Id;
	    	objDataManagement.updateUserRole();
	    	system.assertEquals(objUser.UserRoleid, objUserRole1.Id);
	    	
	    	objUser.lastname = 'lastnameUser';
	    	objDataManagement.saveUser();
	    	system.assertEquals(objUser.lastname, 'lastnameUser');
	    	
	       	//String strReassignUser = objUser.Id;
	       	string strAccid = objAccount1.Id; 
	       	string strContId = objContact1.id;
	       	
	       	String strTestAccID = objAccount.Id;  
	       	TBN_AssociateDataManagementController.fetchTeamMembers(strTestAccID);
	       	TBN_AssociateDataManagementController.fetchAutocompleteDetails(strtest);
	       	
	      
	    	Test.stopTest();
    	}
    }
     
}