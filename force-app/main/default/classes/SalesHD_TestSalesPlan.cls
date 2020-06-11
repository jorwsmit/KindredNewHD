@isTest(seeAllData=false)
public class SalesHD_TestSalesPlan {

@testSetup static void setup(){
	RecordType accountRecordType = [select Id from RecordType where name = 'HD Accounts'];
	Account acct = new Account(Name='Test Account', Status__c='Active', RecordtypeId=accountRecordType.Id);
	insert acct;

	AccountTeamMember atm = new AccountTeamMember(AccountId=acct.Id, UserId=UserInfo.getUserId());
	insert atm;

	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		User usr = new User(Alias = 'newUser2', Email='testhduser2@kndcrm.com',
		                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                    LocaleSidKey='en_US', ProfileId = '00e1B000000jWdg',
		                    TimeZoneSidKey='America/Los_Angeles', UserName='testhduser2@kndcrm.com', UserRoleId='00E130000020vp7');
		insert usr;

		Sales_Plans__c sp = new Sales_Plans__c();
		sp.ownerId = usr.id;
		sp.SalesHD_Plan_date__c = Date.newInstance(System.now().year(),
		                                           System.now().month(), 1);
		insert sp;
	}

}




//--------------------- SalesHD_ReportingClass Tests-------------
@isTest static void CreateSalesPlan() {
	PageReference pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
	//save for current month
	controller.saveNewPlan();
	//try to save for current month again
	controller.saveNewPlan();
	//save for previous year
	controller.newPlanYear--;
	controller.saveNewPlan();
	Test.stopTest();
}

@isTest static void SalesPlanAddingDeletingAccountPlans() {
	PageReference pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
	//save for current month
	Test.setCurrentPage(controller.saveNewPlan());
	Account acct = [select id from account where name='Test Account'];
	controller.selectedAccount = acct.Id;
	controller.addAccountPlan();
	//try adding the same account plan again
	controller.addAccountPlan();
	Account_Sales_Plan__c asp = [select id from Account_Sales_Plan__c where Account__c=:acct.Id];
	controller.accountPlanId = asp.id;
	controller.deleteAccountPlan();
	Test.stopTest();
}

@isTest static void SalesPlanAddingDeleteStrategies() {
	PageReference pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
	//save for current month
	Test.setCurrentPage(controller.saveNewPlan());
	Account acct = [select id from account where name='Test Account'];
	controller.selectedAccount = acct.Id;
	controller.addAccountPlan();
	Account_Sales_Plan__c asp = [select id from Account_Sales_Plan__c where Account__c=:acct.Id];
	controller.accountPlanId = asp.id;
	controller.addStrategy();
	Account_Strategy__c aStrat = [select id from Account_Strategy__c where Account_Sales_Plan__c=:asp.Id];
	controller.strategyId = aStrat.id;
	controller.deleteStrategy();
	Test.stopTest();
}

@isTest static void SalesPlanSaving() {
	PageReference pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
	//save for current month
	pageRef = controller.saveNewPlan();
	Test.setCurrentPage(pageRef);
	Account acct = [select id from account where name='Test Account'];
	controller.selectedAccount = acct.Id;
	controller.addAccountPlan();
	Account_Sales_Plan__c asp = [select id from Account_Sales_Plan__c where Account__c=:acct.Id];
	controller.accountPlanId = asp.id;
	controller.addStrategy();
	sp = [select id from Sales_Plans__c where id=:ApexPages.currentPage().getParameters().get('id')];
	controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.saveAccountPlans();
	Test.stopTest();
}

@isTest static void ManagerList() {
	PageReference pageRef = Page.SalesHD_SalesPlansManager;
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	Test.startTest();
	//by month
	controller.selectedMonth = String.valueOf(System.now().month());
	controller.getMyTeamsPlans();
	User cl = [select id from user where alias='newUser2'];
	controller.selectedCL = cl.Id;
	controller.getMyTeamsPlans();
	Test.stopTest();
}

@isTest static void SalesPlanReports() {

	PageReference pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
	//save for current month
	Test.setCurrentPage(controller.saveNewPlan());
	Account acct = [select id from account where name='Test Account'];
	controller.selectedAccount = acct.Id;
	controller.addAccountPlan();
	Account_Sales_Plan__c asp = [select id from Account_Sales_Plan__c where Account__c=:acct.Id];
	controller.accountPlanId = asp.id;
	controller.addStrategy();
	Account_Strategy__c aStrat = [select id from Account_Strategy__c where Account_Sales_Plan__c=:asp.Id];

	Contact con = new Contact(FirstName='Test', LastName = 'Contact', Status__c='Active', Title__c='ICU Director');
	insert con;
	Event e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now(),
	                    EndDateTime=system.now()+5, Type='Follow-up', whoId=con.Id, SalesHD_Account_Strategy__c=aStrat.Id);
	insert e;
	e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now(), SalesHD_Complete__c=true, 
	                    EndDateTime=system.now()+5, Type='Follow-up', whoId=con.Id, SalesHD_Account_Strategy__c=aStrat.Id);
	insert e;

	pageRef = Page.SalesHD_SalesPlanReports;
	Test.setCurrentPage(pageRef);

	controller.selectedMonth=String.valueOf(System.now().month());
	
	Test.startTest();

	controller.getMonthlySalesPlanReport();

	Test.stopTest();
}

@isTest static void PicklistPopulationAndSelections() {
	PageReference pageRef = Page.SalesHD_SalesPlansManager;
	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	Test.startTest();
	controller.getMonthPicklist();
	controller.getYearPicklist();
	controller.getCLPicklist();
    controller.getAccountPicklist();
    User cl = [select id from user where alias='newUser2'];
	controller.selectedCL = cl.Id;
    controller.selectCL();
    controller.selectedMonth = String.valueOf(System.now().month());
    controller.selectMonth();
    controller.selectedMonth = String.valueOf(System.now().year());
    controller.selectYear();
	Test.stopTest();
}

@isTest static void CopyStrategies() {
	PageReference pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);

	Sales_Plans__c sp = new Sales_Plans__c();
	SalesHD_SalesPlan controller =
		new SalesHD_SalesPlan(new ApexPages.StandardController(sp));
	controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
    pageRef = controller.saveNewPlan();
    Test.setCurrentPage(pageRef);
	sp = [select id, SalesHD_Plan_Date__c from Sales_Plans__c where id=:ApexPages.currentPage().getParameters().get('id')];
	sp.SalesHD_Plan_Date__c = sp.SalesHD_Plan_Date__c.addMonths(-1);
	update sp;
	controller = new SalesHD_SalesPlan(new ApexPages.StandardController(sp));

	Account acct = [select id from account where name='Test Account'];
	controller.selectedAccount = acct.Id;
	controller.addAccountPlan();
	Account_Sales_Plan__c asp = [select id from Account_Sales_Plan__c where Account__c=:acct.Id];
	controller.accountPlanId = asp.id;
    controller.addStrategy();
    pageRef = Page.SalesHD_SalesPlans;
	Test.setCurrentPage(pageRef);
	Test.startTest();
    controller.newPlanYear=System.now().year();
	controller.newPlanMonth=System.now().month();
	pageRef = controller.saveNewPlan();
    Test.setCurrentPage(pageRef);
    controller.copySelectedStrategies();
	Test.stopTest();
}

}