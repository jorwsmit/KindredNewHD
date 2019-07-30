@isTest(seeAllData=false)
private class Sales_TestExpansionMarketBatch {

	@testSetup static void setup(){
		User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
		System.runAs ( thisUser ) {
			User saUsr1 = new User(Alias = 'sa1', Email='KAHSalesAssociateHH1@testorg.com',
			EmailEncodingKey='UTF-8', FirstName='Test', LastName='SA1', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', Line_of_Business__c='HH', ProfileId = '00e1300000225C9', KAH_Growth__c = true,
			TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociateHH1@testorg.com', UserRoleId='00E13000002ACwO');

			insert saUsr1;

			Sales_Performance__c sp1 = new Sales_Performance__c(KAH_HH_Admit_Target__c=10, Month__c=Date.newInstance(System.now().year(),01,01),
			KAH_HH_PPS_Qualified_Admits__c=10, OwnerId=saUsr1.Id);

			insert sp1;

			Sales_Performance__c sp2 = new Sales_Performance__c(KAH_HH_Admit_Target__c=10, Month__c=Date.newInstance(System.now().year(),02,01),
			KAH_HH_PPS_Qualified_Admits__c=10, OwnerId=saUsr1.Id);

			insert sp2;

			Account a1 = new Account(Name='test1');
			insert a1;

			Account a2 = new Account(Name='test2');
			insert a2;

			AccountTeamMember atm = new AccountTeamMember(UserId=saUsr1.Id, AccountId=a1.Id);
			insert atm;

			atm = new AccountTeamMember(UserId=saUsr1.Id, AccountId=a2.Id);
			insert atm;

			Sales_Account_Metrics__c am = new Sales_Account_Metrics__c(Account__c=a1.Id, KAH_HH_Admits__c=1.0, Month__c=Date.newInstance(System.now().year(),01,01));
			insert am;

			am = new Sales_Account_Metrics__c(Account__c=a1.Id, KAH_HP_Admits__c=2.0, Month__c=Date.newInstance(System.now().year(),02,01));
			insert am;

			Contact c1 = new Contact(FirstName='test', LastName='test');
			insert c1;

			Contact c2 = new Contact(FirstName='test', LastName='test');
			insert c2;

			Contact_Team__c ct = new Contact_Team__c(User__c=saUsr1.Id, Contact__c=c1.Id);
			insert ct;

			ct = new Contact_Team__c(User__c=saUsr1.Id, Contact__c=c2.Id);
			insert ct;

			Sales_Contact_Metrics__c cm = new Sales_Contact_Metrics__c(Contact__c=c1.Id, KAH_HH_Admits__c=1.0, Month__c=Date.newInstance(System.now().year(),01,01));
			insert cm;

			cm = new Sales_Contact_Metrics__c(Contact__c=c1.Id, KAH_HP_Admits__c=2.0, Month__c=Date.newInstance(System.now().year(),02,01));
			insert cm;
		}
	}

	@isTest static void runBatchDefaultYear(){
		Sales_ExpansionMarketBatch batch = new Sales_ExpansionMarketBatch();
		Test.StartTest();
		Database.executeBatch(batch);
		Test.StopTest();
	}

	@isTest static void runBatchSetYear(){
		Sales_ExpansionMarketBatch batch = new Sales_ExpansionMarketBatch();
		batch.year = System.now().year();
		Test.StartTest();
		Database.executeBatch(batch);
		Test.StopTest();
	}

}