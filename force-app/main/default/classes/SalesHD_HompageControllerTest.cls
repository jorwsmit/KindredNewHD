@isTest
private class SalesHD_HompageControllerTest
{

	@testSetup static void setup(){
		User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
		System.runAs ( thisUser ) {
			User u = new User(Alias = 'CL', Email='KindredTestCL@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', Line_of_Business__c='HD', ProfileId = '00ea0000001serv',
			TimeZoneSidKey='America/Los_Angeles', UserName='KindredTestCL@testorg.com', UserRoleId='00E3000000128M5');

			insert u;

			Event e = new Event(OwnerId=u.Id, Type='Test',
			StartDateTime=Datetime.newInstance(System.now().year(), System.now().month(), 1),
			EndDateTime=Datetime.newInstance(System.now().year(), System.now().month(), 1));
			insert e;

			e = new Event(OwnerId=u.Id, Type='Test',
			StartDateTime=Datetime.newInstance(System.now().year(), System.now().month(), 1),
			EndDateTime=Datetime.newInstance(System.now().year(), System.now().month(), 1));
			insert e;
		}
	}

	@isTest
	static void getCorporateMessages()
	{
		// Given
		List<String> testList;

		// When
		testList = SalesHD_HompageController.getCorporateMessages();

		// Then
		System.assert(testList.size()==3);

	}

	@isTest
	static void getCalendar()
	{
		// Given
		String testString;

		// When

		User u = [select id from user where username='KindredTestCL@testorg.com'];
		System.runAs ( u ) {
			testString = SalesHD_HompageController.getCalendar(0);
		}

		// Then
		System.assert(testString!=null);

	}
}