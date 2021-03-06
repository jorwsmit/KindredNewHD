@isTest(seeAllData=false)
public class SalesHD_TestReporting {

@testSetup static void setup(){
	RecordType accountRecordType = [select Id from RecordType where name = 'HD Accounts'];
	Account acct = new Account(Name='Test Account', Status__c='Active', RecordtypeId=accountRecordType.Id);
	insert acct;

	RecordType mcAccountRecordType = [select Id from RecordType where name = 'HD Managed Care Accounts'];
	Account mcAcct = new Account(Name='Test Managed Care Account', Status__c='Active', RecordtypeId=mcAccountRecordType.Id, ShippingState='KY');
	insert mcAcct;

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

		List<SalesHD_KPI__c> kpis = new List<SalesHD_KPI__c>();
		SalesHD_KPI__c kpi = new SalesHD_KPI__c(CL__c=usr.Id,Admit_Lag_Time__c=null,
		Admits_Per_Day__c=1, Batting_Average__c=2, CMI__c=1, Conversion_Percentage__c=4, Encounters_Per_Day_Quarter__c=1,
		Encounters_Per_Day_Month__c=1.25, ICU_Referral_Percentage__c=null,  Referral_Lag_Time__c=3,
		Referrals_Per_Day__c=1, KPI_Date__c=Date.ValueOf(System.now()));
		kpis.add(kpi);

		List<RecordType> kpiRecordType = [select Id from RecordType where name = 'KPI High Baseline' or
		name = 'KPI Middle Baseline' or name = 'KPI Low Baseline' order by name];

		kpi = new SalesHD_KPI__c(Admit_Lag_Time__c=2,
		Admits_Per_Day__c=2, Batting_Average__c=2, CMI__c=2, Conversion_Percentage__c=2, Encounters_Per_Day_Quarter__c=2,
		Encounters_Per_Day_Month__c=2, ICU_Referral_Percentage__c=2,  Referral_Lag_Time__c=2,
		Referrals_Per_Day__c=2, KPI_Date__c=Date.ValueOf(System.now()), RecordTypeId=kpiRecordType[0].Id);
		kpis.add(kpi);

		kpi = new SalesHD_KPI__c(Admit_Lag_Time__c=1.5,
		Admits_Per_Day__c=1.5, Batting_Average__c=1.5, CMI__c=1.5, Conversion_Percentage__c=1.5, Encounters_Per_Day_Quarter__c=1.5,
		Encounters_Per_Day_Month__c=1.5, ICU_Referral_Percentage__c=1.5,  Referral_Lag_Time__c=1.5,
		Referrals_Per_Day__c=1.5, KPI_Date__c=Date.ValueOf(System.now()), RecordTypeId=kpiRecordType[2].Id);
		kpis.add(kpi);
		
		kpi = new SalesHD_KPI__c(Admit_Lag_Time__c=1,
		Admits_Per_Day__c=1, Batting_Average__c=1, CMI__c=1, Conversion_Percentage__c=1, Encounters_Per_Day_Quarter__c=1,
		Encounters_Per_Day_Month__c=1, ICU_Referral_Percentage__c=1,  Referral_Lag_Time__c=1,
		Referrals_Per_Day__c=1, KPI_Date__c=Date.ValueOf(System.now()), RecordTypeId=kpiRecordType[1].Id);
		kpis.add(kpi);

		insert kpis;
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
	controller.dateOption = 'Previous Week';
	controller.eLastWeek();
	controller.dateOption = 'This Week';
	controller.eLastWeek();
	controller.dateOption = 'Month to Date';
	controller.eLastWeek();
	controller.dateOption = 'Previous Month';
	controller.eLastWeek();
	controller.dateOption = 'Current Quarter';
	controller.eLastWeek();
	controller.dateOption = 'Previous Quarter';
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

@isTest static void Reporting_getKpi() {
	User u = [select id from user where username='testhduser2@kndcrm.com'];
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
    Test.startTest();
    SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.getKpi(u.Id);
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
	picklist = controller.getDateOptionPicklist();
	Test.stopTest();
}

@isTest static void Reporting_Selectors() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.selectDistrict();
	controller.selectArea();
	controller.selectDateOption();

	Test.stopTest();
}

@isTest static void Reporting_ChangingDateRange() {
	PageReference pageRef = Page.SalesHD_DashboardManager;
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.dateOption = 'Previous Week';
	pageRef.getParameters().put('date_option', String.valueOf(controller.dateOption));
	Test.setCurrentPage(pageRef);
	controller.eLastWeek();
	controller.dateOption = 'This Week';
	pageRef.getParameters().put('date_option', String.valueOf(controller.dateOption));
	Test.setCurrentPage(pageRef);
	controller.eLastWeek();
	controller.dateOption = 'Month to Date';
	pageRef.getParameters().put('date_option', String.valueOf(controller.dateOption));
	Test.setCurrentPage(pageRef);
	controller.eLastWeek();
	controller.dateOption = 'Previous Month';
	pageRef.getParameters().put('date_option', String.valueOf(controller.dateOption));
	Test.setCurrentPage(pageRef);
	controller.eLastWeek();
	controller.dateOption = 'Current Quarter';
	pageRef.getParameters().put('date_option', String.valueOf(controller.dateOption));
	Test.setCurrentPage(pageRef);
	controller.eLastWeek();
	controller.dateOption = 'Previous Quarter';
	pageRef.getParameters().put('date_option', String.valueOf(controller.dateOption));
	Test.setCurrentPage(pageRef);
	controller.eLastWeek();
	Test.stopTest();
}

//----------- Managed Care Tests
@isTest static void Reporting_MCFilters() {
	PageReference pageRef = Page.SalesHD_ManagedCareLeaderDashboard;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();

	List<SelectOption> picklist = controller.getMCOStatePicklist();
	picklist = controller.getEmployeeTypePicklist();

	controller.selectedMCOState = 'KY';
	controller.selectMCOState();

	controller.userType = 'Test';
	controller.selectUserType();

	Test.stopTest();

}

@isTest static void Reporting_MCReports() {
	PageReference pageRef = Page.SalesHD_ManagedCareLeaderDashboard;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.eLastWeekPurpose();
	controller.eLastWeekType();
	// controller.eLastWeekPayorType();
	controller.eLastWeekUsers();
	// controller.eLastWeekAccounts20();
	// controller.eLastWeekPayorParent10();
	controller.eByAccount();
	controller.eUpcomingAccounts();
	// controller.eUpcomingPayorParent();
	Test.stopTest();

}

@isTest static void Reporting_MCTypes() {
	PageReference pageRef = Page.SalesHD_ManagedCareLeaderDashboard;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_ReportingClass controller = new SalesHD_ReportingClass();
	controller.getTotalEncounters();
	controller.getTotalJQC();
	controller.getTotalPresentation();
	controller.getTotalSmallGroup();
	controller.getTotalCareCoor();
	controller.getTotalTour();
	Test.stopTest();
}

}