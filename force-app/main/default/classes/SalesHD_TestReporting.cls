@isTest(seeAllData=false)
public class SalesHD_TestReporting {

@testSetup static void setup(){
	RecordType accountRecordType = [select Id from RecordType where name = 'HD Accounts'];
	Account acct = new Account(Name='Test Account', Status__c='Active', RecordtypeId=accountRecordType.Id);
	insert acct;

	AccountTeamMember atm = new AccountTeamMember(AccountId=acct.Id, UserId=UserInfo.getUserId());
	insert atm;

	Unit__c u1 = new Unit__c(Name='Administrative', Active__c=True);
	insert u1;

	Unit__c u2 = new Unit__c(Name='ICU - CARDIAC', Active__c=True);
	insert u2;

	Account_unit__c au1 = new Account_unit__c(Unit__c=u1.Id, Account__c=acct.Id, Active__c=True);
	insert au1;

	Account_unit__c au2 = new Account_unit__c(Unit__c=u2.Id, Account__c=acct.Id, Active__c=True);
	insert au2;

	Contact con = new Contact(FirstName='Test', LastName = 'Contact', Status__c='Active', Title__c='ICU Director');
	insert con;

	Contact con2 = new Contact(FirstName='Test', LastName = 'Contact2', Status__c='Active', Title__c='Nurse Manager');
	insert con2;

	Contact_Team__c ct = new Contact_Team__c(Contact__c=con.Id, User__c=UserInfo.getUserId());
	insert ct;

	Contact csuiteCon = new Contact(FirstName='Test', LastName = 'Contact2', Title__c='CEO');
	insert csuiteCon;

	Account_unit_contact__c auc = new Account_unit_contact__c(Account_Unit__c=au1.Id, Contact__c=con.Id);
	insert auc;
	auc = new Account_unit_contact__c(Account_Unit__c=au1.Id, Contact__c=csuiteCon.Id);
	insert auc;
	auc = new Account_unit_contact__c(Account_Unit__c=au2.Id, Contact__c=con.Id);
	insert auc;

	Sales_Performance__c sp = new Sales_Performance__c(Month__c=Date.newInstance(System.now().year(), System.now().month(), 1));
	insert sp;

	sp = new Sales_Performance__c(Month__c=Date.newInstance(System.now().addMonths(-1).year(),
	                                                        System.now().addMonths(-1).month(), 1), Actual_Revenue__c=1, Targeted_Revenue__c=1);
	insert sp;

	Event e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now(),
	                    EndDateTime=system.now()+5, Type='Follow-up', whoId=con.Id);
	insert e;

	e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now().addDays(-1),
	              EndDateTime=system.now()+5, Type='Follow-up', whoId=con.Id);
	insert e;

	e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now().addDays(1),
	              EndDateTime=system.now()+5, Type='Follow-up', whoId=con.Id);
	insert e;


	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		User usr = new User(Alias = 'newUser2', Email='testhduser2@kndcrm.com',
		                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                    LocaleSidKey='en_US', ProfileId = '00e1B000000jWdg',
		                    TimeZoneSidKey='America/Los_Angeles', UserName='testhduser2@kndcrm.com', UserRoleId='00E130000020vp7');
		insert usr;

		Alert_and_Comment__c ac = new Alert_and_Comment__c(Datetime__c=System.now(), Comment_By__c=thisUser.Id,
		                                                   Type__c='HD Corporate Message', Comment__c='Test');
		insert ac;
	}
}




//--------------------- SalesHD_ReportingClass Tests-------------
@isTest static void Reporting_eLastWeek() {
	// Account acct = [select Id from account where name='Test Account' limit 1];
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	// pageRef.getParameters().put('id',acct.id);
	// ApexPages.StandardController sc = new ApexPages.standardController(acct);
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.eLastWeek();
	Test.stopTest();
}

@isTest static void Reporting_eLastWeekContact() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
    controller.eLastWeekContact();
    controller.selectedCL = UserInfo.getUserId();
    controller.selectCL();
    controller.eLastWeekContact();
    Account a = [select id from account where name='Test Account'];
    controller.selectedAccount = a.Id;
    controller.selectAccount();
    controller.eLastWeekContact();
	Test.stopTest();
}

@isTest static void Reporting_eLastWeekMedium() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.eLastWeekMedium();
	Test.stopTest();
}

@isTest static void Reporting_eLastWeekObjective() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.eLastWeekObjective();
	Test.stopTest();
}

@isTest static void Reporting_eLastWeekAccounts() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
    controller.eLastWeekAccounts();
    controller.nextWeek();
    controller.eLastWeekAccounts();
    controller.previousWeek(); controller.previousWeek();
    controller.eLastWeekAccounts();
	Test.stopTest();
}

@isTest static void Reporting_eUpcoming() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.eUpcoming();
	Test.stopTest();
}

@isTest static void Reporting_spTrend() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
    SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
    controller.admitsRevenue = 'Revenue';
	controller.spTrend();
	Test.stopTest();
}

@isTest static void Reporting_spTrendCL() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
    Test.startTest();
    pageRef.getParameters().put('cl',UserInfo.getUserId());
    SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
    controller.admitsRevenue = 'Admissions';
	controller.spTrend();
	Test.stopTest();
}

@isTest static void Reporting_eLastWeekUnit() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.eLastWeekUnit();
	Test.stopTest();
}

@isTest static void Reporting_picklists() {
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	Test.startTest();
	List<SelectOption> picklist = controller.getAdmitsRevenuePicklist();
    picklist = controller.getAccountPicklist();
    picklist = controller.getCLPicklist();
	Test.stopTest();
}

}