@isTest
private class AA_AssociateDataManagementControllerTest {

    static testMethod void myUnitTest(){
          User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser){
        
        AA_AssociateDataManagementController objDataManagement = new AA_AssociateDataManagementController();
        String PARENT_ROLE = 'SVP - KAH';
        UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
        UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
        UserRole objUserRole2 = [select id from UserRole where Name =:'HD Central Region' Limit 1];
      
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
                    FirstName = 'testChump',
                  LastName = 'superChump',
                          username = 'newUserDataManagement'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
                          email = 'pb@ff.com', 
                          emailencodingkey = 'UTF-8', 
                          localesidkey = 'en_US', 
                          languagelocalekey = 'en_US', 
                          timezonesidkey = 'America/Los_Angeles', 
                          alias='nuser', 
                          ProfileId =  Userinfo.getProfileId(),
                          managerId= objUser.id,
                          Perner__c = '546437576',
                          Line_of_Business__c = 'HP' 
                          
          ); 
          insert objUser2;
          
          RecordType rt = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Referring_Facility_Child' Limit 1];
          RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='General_Contact' Limit 1];
          
          
          
          Account objParentAccount = new Account (Name ='Kindred Healthcare Inc');
          insert objParentAccount;
          
          Account objAccount = new Account(name = 'Test AccountTest AccountTest Account', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount;
       
       Account objAccount2 = new Account(name = 'Test Account2', Facility_Number__c = '5081', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount2;
       
       Home_Facility__c hf = new Home_Facility__c(Account__c = objAccount2.ID, User__c = objUser2.Id);
          insert hf;
       
       Account objA = new Account(name = 'Unassigned Account - Admin Maintenance');
       insert objA;
       
       Contact objContact = new Contact(LastName = 'Test Contact,', FirstName ='TestCont,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10 );
       insert objContact;
       
       Account objAccount1 = new Account(name = 'Test ,Account1,', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 33.49,Shipping_Geolocation__Latitude__s = 64.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount1;
       
       Contact objContact1 = new Contact(LastName = 'Test Contact1,', FirstName='Contact,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10);
       insert objContact1;
       
       Contact objContact2 = new Contact(LastName = 'Test Contact2,', FirstName='Contact2,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 14);
       insert objContact2;
       
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
        
        
        
        string newAcc = 'Test Account2 - 5081 - HH';
        string selectedUser = 'superChump, testChump - HP - 546437576';
        string lob = 'HP';
        string sortField = 'Name';
        string distanceFilter = 'Currently Assigned';
        string distanceFilter2 = 'All';
        string typeFilter = 'All';
        string isAsc = 'Asc';
        string location = '';
        string strSelectedUserRole = '00E13000001RF95';
        string reqType = 'Referral';
        string title = 'testTitle';
        string phone = '555-555-5555';
        string idList = '';
        idList = objAccount1.Id;
        list<string> filters = new list<string>();
        filters.add('sourceFilter: HPAS');
      filters.add('activeFilter: Customer');
      filters.add('stateFilter: KY' ); 
      filters.add('nameFilter: Kindred Healthcare' );
      filters.add('npiFilter: 34533' );
      filters.add('hmsFilter: 35345' );
      filters.add('sfIDFilter: 345434' );
      filters.add('addressFilter: 480 S 4th St' );
      filters.add('cityFilter: Louisville');
      filters.add('stFilter: KY');
      filters.add('zipFilter: 40202');
      filters.add('specialtyFilter: Rehab');
      filters.add('hhYTDAdmitFilter: '  + 1);
      filters.add('hhPYAdmitFilter: '  + 1);
      filters.add('hpYTDAdmitFilter: '  + 1);
      filters.add('hpPYAdmitFilter: '  + 1);
      filters.add('hdYTDAdmitFilter: '  + 1);
      filters.add('hdPYAdmitFilter: '  + 1);
      filters.add('hhPPSYTDAdmitFilter: '  + 1);
      filters.add('hhPPSPYAdmitFilter: '  + 1);
      filters.add('hhYTDReferralFilter: '  + 1);
      filters.add('hhDiscQualAdmitYTDFilter: '  + 1);
      filters.add('hpQualifiedYTDAdmitFilter: '  + 1);
      filters.add('hpQualifiedPYAdmitFilter: '  + 1);
      filters.add('hpYTDReferralFilter: '  + 1);
      filters.add('hpLengthFilter: '  + 1);
        AA_AssociateDataManagementController.getLoggedInUser();
        AA_AssociateDataManagementController.getSourceList();
        AA_AssociateDataManagementController.getDistanceList();
        AA_AssociateDataManagementController.getStatusList();
        AA_AssociateDataManagementController.getStateList();
        AA_AssociateDataManagementController.getAccountList();
        AA_AssociateDataManagementController.getBusinessList();
        test.startTest();
        AA_AssociateDataManagementController.getTypeList();
        AA_AssociateDataManagementController.getUsersList();
        AA_AssociateDataManagementController.getTeamAssigned(objAccount.ID);
        AA_AssociateDataManagementController.getUpdatedInfo(objUser, newAcc, lob, title, phone);
        AA_AssociateDataManagementController.getSelectedUser(selectedUser, true);
        AA_AssociateDataManagementController.getReferralSourceCount(objUser);
        AA_AssociateDataManagementController.getReferralList(objUser, filters, sortField, distanceFilter, typefilter, isAsc, location, reqType);
        filters.clear();
        
        AA_AssociateDataManagementController.getReferralList(thisUser, filters, sortField, distanceFilter2, typefilter, isAsc, location, reqType);
        AA_AssociateDataManagementController.fetchParentRoles(selectedUser, strSelectedUserRole);
        AA_AssociateDataManagementController.fetchNewRoles(selectedUser, 'SVP - KAH');
        AA_AssociateDataManagementController.setNewRole('SVP - KAH', objUser);
        AA_AssociateDataManagementController.getProcessAssignReferralSources(objUser, idList);
        AA_AssociateDataManagementController.getProcessAssignReferralSources(objUser, idList);
        AA_AssociateDataManagementController.getProcessReassignReferralSources(objUser, objUser2, idList);
        
        test.stopTest();
        }
    }
    
    static testMethod void myUnitTest2() {
        String PARENT_ROLE = 'SVP - KAH';
        UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
        UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
        UserRole objUserRole2 = [select id from UserRole where Name =:'HD Central Region' Limit 1];
      test.startTest();
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
                  ProfileId =  '00e1300000225C9',
                  CommunityNickname = 'TestCommunity1' + String.valueOf(Date.today()) + '_', 
                  Title = 'Title11',
                  City = 'testCity',
                  Country = 'testCountry',
                  Street = 'testStreet',
                  CompanyName = 'testCompanyName',
                  Phone = 'testPhone',
                  Extension = 'testExtension',
                  PostalCode = '2345',
                  UserRoleid= objUserRole2.id
                );
        insert objUser;
        
        System.runAs(objUser){
          S2_custom_permissions__c S2 = new S2_custom_permissions__c(Name = '00e1300000225C9');
          insert S2;
          AA_AssociateDataManagementController.getPermissions();
          
          }
        test.stopTest();
      }
      
    static testMethod void myUnitTest3() {
        User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser){
        
        AA_AssociateDataManagementController objDataManagement = new AA_AssociateDataManagementController();
        String PARENT_ROLE = 'SVP - KAH';
        UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
        UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
        UserRole objUserRole2 = [select id from UserRole where Name =:'HD Central Region' Limit 1];
      
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
                    FirstName = 'testChump',
                  LastName = 'superChump',
                          username = 'newUserDataManagement'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
                          email = 'pb@ff.com', 
                          emailencodingkey = 'UTF-8', 
                          localesidkey = 'en_US', 
                          languagelocalekey = 'en_US', 
                          timezonesidkey = 'America/Los_Angeles', 
                          alias='nuser', 
                          ProfileId =  Userinfo.getProfileId(),
                          managerId= objUser.id,
                          Perner__c = '546437576',
                          Line_of_Business__c = 'HP' 
                          
          ); 
          insert objUser2;
          
          RecordType rt = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Referring_Facility_Child' Limit 1];
          RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='General_Contact' Limit 1];
          
          
          
          Account objParentAccount = new Account (Name ='Kindred Healthcare Inc');
          insert objParentAccount;
          
          Account objAccount = new Account(name = 'Test AccountTest AccountTest Account', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount;
       
       Account objAccount2 = new Account(name = 'Test Account2', Facility_Number__c = '5081', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount2;
       
       Account objA = new Account(name = 'Unassigned Account - Admin Maintenance');
       insert objA;
       
       Contact objContact = new Contact(LastName = 'Test Contact,', FirstName ='TestCont,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10 );
       insert objContact;
       
       Account objAccount1 = new Account(name = 'Test ,Account1,', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 33.49,Shipping_Geolocation__Latitude__s = 64.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount1;
       
       Contact objContact1 = new Contact(LastName = 'Test Contact1,', FirstName='Contact,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10);
       insert objContact1;
       
       Contact objContact2 = new Contact(LastName = 'Test Contact2,', FirstName='Contact2,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 14);
       insert objContact2;
       
        AccountTeamMember objATM =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount.Id);
      insert objATM;
       
      AccountTeamMember objATM1 =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount1.Id);
      insert objATM1;
       
      Contact_Team__c objCTM = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact.Id );
      insert objCTM;
       
      Contact_Team__c objCTM1 = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact1.Id);
      insert objCTM1;
        
        
        test.startTest();
        string newAcc = 'Test Account2 - 5081 - HH';
        string selectedUser = 'superChump, testChump - HP - 546437576';
        string lob = 'HP';
        string sortField = 'Name';
        string distanceFilter = 'Currently Assigned';
        string distanceFilter2 = 'All';
        string typeFilter = 'All';
        string isAsc = 'Asc';
        string location = '';
        string strSelectedUserRole = '00E13000001RF95';
        string reqType = 'Referral';
        string title = 'testTitle';
        string phone = '555-555-5555';
        list<string> idList = new list <string>();
        idList.add(objAccount1.Id);
        idList.add(objAccount2.Id);
        idList.add(objContact1.ID);
        idList.add(objContact.ID);
        list<string> filters = new list<string>();
        filters.add('sourceFilter: HPAS');
      filters.add('activeFilter: Customer');
      filters.add('stateFilter: KY' ); 
      filters.add('nameFilter: Kindred Healthcare' );
      filters.add('npiFilter: 34533' );
      filters.add('sfIDFilter: 345434' );
      filters.add('addressFilter: 480 S 4th St' );
      filters.add('cityFilter: Louisville');
      filters.add('stFilter: KY');
      filters.add('zipFilter: 40202');
      filters.add('specialtyFilter: Rehab');
      filters.add('hhYTDAdmitFilter: '  + 1);
      filters.add('hhPYAdmitFilter: '  + 1);
      filters.add('hpYTDAdmitFilter: '  + 1);
      filters.add('hpPYAdmitFilter: '  + 1);
      filters.add('hdYTDAdmitFilter: '  + 1);
      filters.add('hdPYAdmitFilter: '  + 1);
      filters.add('hhPPSYTDAdmitFilter: '  + 1);
      filters.add('hhPPSPYAdmitFilter: '  + 1);
      filters.add('hhYTDReferralFilter: '  + 1);
      filters.add('hhDiscQualAdmitYTDFilter: '  + 1);
      filters.add('hpQualifiedYTDAdmitFilter: '  + 1);
      filters.add('hpQualifiedPYAdmitFilter: '  + 1);
      filters.add('hpYTDReferralFilter: '  + 1);
      filters.add('hpLengthFilter: '  + 1);
        AA_AssociateDataManagementController.getLoggedInUser();
        AA_AssociateDataManagementController.getSourceList();
        AA_AssociateDataManagementController.getDistanceList();
        AA_AssociateDataManagementController.getStatusList();
        AA_AssociateDataManagementController.getStateList();
        AA_AssociateDataManagementController.getAccountList();
        AA_AssociateDataManagementController.getBusinessList();
        AA_AssociateDataManagementController.getTypeList();
        AA_AssociateDataManagementController.getUsersList();
        AA_AssociateDataManagementController.getTeamAssigned(objAccount.ID);
        AA_AssociateDataManagementController.getUpdatedInfo(objUser, newAcc, lob, title, phone);
        AA_AssociateDataManagementController.getSelectedUser(selectedUser, true);
        test.stopTest();
        }
      }
      
	static testMethod void myUnitTest4() {
        User thisUser = [ select Id,UserRoleId, FirstName from User where Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser){
        
        AA_AssociateDataManagementController objDataManagement = new AA_AssociateDataManagementController();
        String PARENT_ROLE = 'SVP - KAH';
        UserRole objUserRole = [select id from UserRole where Name =:PARENT_ROLE Limit 1];
        UserRole objUserRole1 = [select id from UserRole where ParentRoleId =:objUserRole.Id Limit 1];
        UserRole objUserRole2 = [select id from UserRole where Name =:'HD Central Region' Limit 1];
      
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
                    FirstName = 'testChump',
                  LastName = 'superChump',
                          username = 'newUserDataManagement'+ String.valueOf(Date.today()) + '_' +'@yahoo.com', 
                          email = 'pb@ff.com', 
                          emailencodingkey = 'UTF-8', 
                          localesidkey = 'en_US', 
                          languagelocalekey = 'en_US', 
                          timezonesidkey = 'America/Los_Angeles', 
                          alias='nuser', 
                          ProfileId =  Userinfo.getProfileId(),
                          managerId= objUser.id,
                          Perner__c = '546437576',
                          Line_of_Business__c = 'HP' 
                          
          ); 
          insert objUser2;
          
          RecordType rt = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Referring_Facility_Child' Limit 1];
          RecordType rtContact = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='General_Contact' Limit 1];
          
          
          
          Account objParentAccount = new Account (Name ='Kindred Healthcare Inc');
          insert objParentAccount;
          
          Account objAccount = new Account(name = 'Test AccountTest AccountTest Account', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount;
       
       Account objAccount2 = new Account(name = 'Test Account2', Facility_Number__c = '5081', Status__c ='Active', parentId = objParentAccount.id, shippingstate = 'FA', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 13.49,Shipping_Geolocation__Latitude__s = 84.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount2;
       
       Account objA = new Account(name = 'Unassigned Account - Admin Maintenance');
       insert objA;
       
       Contact objContact = new Contact(LastName = 'Test Contact,', FirstName ='TestCont,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10 );
       insert objContact;
       
       Account objAccount1 = new Account(name = 'Test ,Account1,', recordTypeId = rt.Id, Shipping_Geolocation__Longitude__s = 33.49,Shipping_Geolocation__Latitude__s = 64.66, KAH_HH_Referrals_YTD__c = 10);
       insert objAccount1;
       
       Contact objContact1 = new Contact(LastName = 'Test Contact1,', FirstName='Contact,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 10);
       insert objContact1;
       
       Contact objContact2 = new Contact(LastName = 'Test Contact2,', FirstName='Contact2,', recordTypeId = rtContact.Id, Geolocation__Longitude__s=86.1 ,Geolocation__Latitude__s =33.1, KAH_HH_Referrals_YTD__c = 14);
       insert objContact2;
       
        AccountTeamMember objATM =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount.Id);
      insert objATM;
       
      AccountTeamMember objATM1 =  new  AccountTeamMember(UserId =UserInfo.getUserId(), TeamMemberRole='Clinical Liason', AccountId =objAccount1.Id);
      insert objATM1;
       
      Contact_Team__c objCTM = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact.Id );
      insert objCTM;
       
      Contact_Team__c objCTM1 = new Contact_Team__c(User__c = UserInfo.getUserId(), Contact__c =objContact1.Id);
      insert objCTM1;
        
        
        test.startTest();
        string newAcc = 'Test Account2 - 5081 - HH';
        string selectedUser = 'superChump, testChump - HP - 546437576';
        string lob = 'HP';
        string sortField = 'Name';
        string distanceFilter = 'Currently Assigned';
        string distanceFilter2 = 'All';
        string typeFilter = 'All';
        string isAsc = 'Asc';
        string location = '';
        string strSelectedUserRole = '00E13000001RF95';
        string reqType = 'Referral';
        string title = 'testTitle';
        string phone = '555-555-5555';
        string facilityListFilter = 'Kindred';
        string nameListFilter = 'chump';
        string nameListFilter2 = ' testChump';
        list<string> idList = new list <string>();
        idList.add(objAccount1.Id);
        idList.add(objAccount2.Id);
        idList.add(objContact1.ID);
        idList.add(objContact.ID);
        list<string> filters = new list<string>();
        AA_AssociateDataManagementController.getUsersList2();
        AA_AssociateDataManagementController.filterAccountList(facilityListFilter);
        AA_AssociateDataManagementController.filterUserList(nameListFilter);
        AA_AssociateDataManagementController.filterUserList2(nameListFilter2);
        AA_AssociateDataManagementController.removeAllUserAssignments(objUser);
        test.stopTest();
        }
      }      
    
}