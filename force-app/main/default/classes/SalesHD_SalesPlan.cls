global without sharing class SalesHD_SalesPlan {

public Integer newPlanMonth {get; set;}
public Integer newPlanYear {get; set;}

public Boolean canDelete {get; set;}

public Boolean canCopyStrategies {get; set;}
public Id previousPlanId {get; set;}

public Sales_Plans__c salesPlan {get; set;}
public Date spDate {get; set;}
public Id spOwner {get; set;}
public String spOwnerName {get; set;}

public String planDate {get; set;}
public String planDateLastMonth {get; set;}
public String planDateLastYear {get; set;}

public List<Account_Sales_Plan__c> accountPlans {get; set;}
public Id accountPlanId {get; set;}
public Id strategyId {get; set;}
public Id selectedAccount {get; set;}

public String accountMetrics {get; set;}
public list<accountsPlans> aPlans {get; set;}

public List<Non_Conversion__c> nonConversion {get; set;}

// public class accountMetric {
// String accountName;
// Integer cyMtdAdmit, pyMtdAdmit, mtdVariance;
// Integer cyYtdAdmit, pyYtdAdmit, ytdVariance;
// }

public class accountMetric {
public String accountName {get; set;}

public Integer cyMtdAdmit {get; set;}
public Integer pyMtdAdmit {get; set;}
public Integer mtdVariance {get; set;}

public Integer cyYtdAdmit {get; set;}
public Integer pyYtdAdmit {get; set;}
public Integer ytdVariance {get; set;}
}

public class salesPlans
{
public Sales_Plans__c sPlan {get; set;}
public list<accountsPlans> acctPlans {get; set;}

public salesPlans(Sales_Plans__c s){
	sPlan = s;
	acctPlans = new list<accountsPlans>();
}
}

public class accountsPlans
{
public Account_Sales_Plan__c aPlan {get; set;}
public list<accountStrategy> strats {get; set;}

public accountsPlans(Account_Sales_Plan__c p)
{
	aPlan = p;
	strats = new list<accountStrategy>();
}

}

public class accountStrategy {
public Account_Strategy__c strat {get; set;}
public list<Event> stratEncounters {get; set;}


public accountStrategy(Account_Strategy__c accs)
{
	strat = accs;
	stratEncounters = new list<Event>();
}

}

public string selectedCL {get; set;}

public User usr {get; set;}
// public string district {get; set;}
// public string market {get; set;}

private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public List<Selectoption> getCLPicklist(){

	// allSubRoleIds.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Employee -'));
	for(User u : [select id, name from user where userRoleId in :allSubRoleIds or Id=:UserInfo.getUserId() order by name]) {
		picklist.add(new selectOption(u.id, u.name));
	}
	return picklist;
}

public string selectedMonth {get; set;}
public string selectedYear {get; set;}

private static set<Id> getSubRoleIds(set<Id> roleIds) {
	set<Id> returnRoleIds = new set<Id>();
	for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
		returnRoleIds.add(r.Id);
	}
	if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
	return returnRoleIds;
}

public PageReference selectCL(){
	PageReference page = ApexPages.currentPage();
	page.getParameters().put('cl', String.valueOf(selectedCL));
	page.setRedirect(true);
	return page;
}

public PageReference selectMonth(){
	PageReference page = ApexPages.currentPage();
	page.getParameters().put('m', String.valueOf(selectedMonth));
	page.setRedirect(true);
	return page;
}

public PageReference selectYear(){
	PageReference page = ApexPages.currentPage();
	page.getParameters().put('y', String.valueOf(selectedYear));
	page.setRedirect(true);
	return page;
}


private List<String> months = new List<String> {'January', 'February', 'March', 'April',
	                                        'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};

public SalesHD_SalesPlan(ApexPages.StandardController stdController) {
	usr = new User();
	usr.Region__c='HD';

	if(ApexPages.currentPage().getParameters().get('dst')!=null)
		usr.District__c=String.valueOf(ApexPages.currentPage().getParameters().get('dst'));

	if(ApexPages.currentPage().getParameters().get('mkt')!=null)
		usr.Area__c=String.valueOf(ApexPages.currentPage().getParameters().get('mkt'));

	canDelete = true;
	if(selectedYear==null && ApexPages.currentPage().getParameters().get('y')!=null) {
		selectedYear=ApexPages.currentPage().getParameters().get('y');
	}else if(selectedYear==null) {
		selectedYear=String.valueOf(Date.valueOf(system.now()).year());
	}
	if(selectedMonth==null && ApexPages.currentPage().getParameters().get('m')!=null) {
		selectedMonth=ApexPages.currentPage().getParameters().get('m');
	} else if(selectedMonth==null && Apexpages.currentPage().getUrl()!=null && Apexpages.currentPage().getUrl().toLowerCase().contains('/apex/saleshd_salesplanreports')) {
		selectedMonth=String.valueOf(Date.valueOf(system.now()).month());
	}



	if(selectedCL==null && ApexPages.currentPage().getParameters().get('cl')!=null) {
		selectedCL=ApexPages.currentPage().getParameters().get('cl');
	}
	salesPlan = (Sales_Plans__c)stdController.getRecord();
	planDate = '';  planDateLastYear = '';
	for(Sales_Plans__c sp : [select Id, SalesHD_Plan_date__c, OwnerId, Owner.Name from Sales_Plans__c where Id=
					 :ApexPages.currentPage().getParameters().get('id')]) {
		spDate = sp.SalesHD_Plan_Date__c;
		spOwner = sp.OwnerId;
		spOwnerName = sp.Owner.Name;
		planDate = months[sp.SalesHD_Plan_Date__c.month()-1] + ' ' + sp.SalesHD_Plan_Date__c.year();
		planDateLastMonth = months[sp.SalesHD_Plan_Date__c.addMonths(-1).month()-1] + ' ' + sp.SalesHD_Plan_Date__c.addMonths(-1).year();
		planDateLastYear = months[sp.SalesHD_Plan_Date__c.addMonths(-1).month()-1] + ' ' + (sp.SalesHD_Plan_Date__c.addMonths(-1).year()-1);

		if(spDate.toStartOfMonth().addMonths(1).addDays(7)<=System.now()) {
			canDelete = false;
		}
	}

	canCopyStrategies = false;
	previousPlanId = null;
	if(spOwner!=null && spOwner==UserInfo.getUserId() && spDate!=null) {
		List<Sales_Plans__c> previousPlan = [select Id from Sales_Plans__c where OwnerId=:UserInfo.getUserId()
		                                                                                  and SalesHD_Plan_date__c<:spDate
		                                                                                  order by SalesHD_Plan_date__c desc limit 1];
		if(!previousPlan.isEmpty() &&
		   ![select Id from Account_Strategy__c where
		     Account_Sales_Plan__r.Parent_Sales_Plan__c=: previousPlan[0].Id and Complete__c=false].isEmpty()) {
			canCopyStrategies = true;
			previousPlanId = previousPlan[0].Id;
		}

	}

	accountPlans = new List<Account_Sales_Plan__c>();
	for(Account_Sales_Plan__c acp : [select Account__r.Name, Challenges_Critical_Issues__c,
	                                 Goal__c, Parent_Sales_Plan__c from Account_Sales_Plan__c where
	                                 Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id')]) {
		accountPlans.add(acp);
	}


	getAccountPlansEvents();

	nonConversion = new List<Non_Conversion__c>();
	if(ApexPages.currentPage().getParameters().get('id')!=null) {
		accountMetrics = getAccountMetrics();
		nonConversion = getNonConversion();
	}

	newPlanMonth = System.now().month();
	newPlanYear = System.now().year();
}

public List<Sales_Plans__c> getMyPlans(){
	return [select Id, SalesHD_Plan_Date__c from Sales_Plans__c where OwnerId=: UserInfo.getUserId() order by SalesHD_Plan_Date__c desc];
}

public List<Sales_Plans__c> getMyTeamsPlans(){
	Date lowDate = Date.newInstance(Integer.valueOf(selectedYear), 1, 1);
	Date highDate = Date.newInstance(Integer.valueOf(selectedYear), 12, 31);
	if(selectedMonth!=null) {
		lowDate=Date.newInstance(Integer.valueOf(selectedYear), Integer.valueOf(selectedMonth), 1);
		Integer numberOfDays = Date.daysInMonth(lowDate.year(), lowDate.month());
		highDate=lowDate.addDays(numberOfDays-1);
	}

	// allSubRoleIds.add(UserInfo.getUserRoleId());
	if(selectedCL!=null) {
		return [select Id, SalesHD_Plan_Date__c, Owner.Name from Sales_Plans__c where
		                ((Owner.UserRoleId in: allSubRoleIds and OwnerId=: selectedCL)or (OwnerId=: UserInfo.getUserId())) and
		        SalesHD_Plan_Date__c>=: lowDate and SalesHD_Plan_Date__c<=: highDate
		        order by SalesHD_Plan_Date__c desc];
	} else {
		return [select Id, SalesHD_Plan_Date__c, Owner.Name from Sales_Plans__c where
		                (Owner.UserRoleId in: allSubRoleIds or OwnerId=: UserInfo.getUserId()) and
		        SalesHD_Plan_Date__c>=: lowDate and SalesHD_Plan_Date__c<=: highDate
		        order by SalesHD_Plan_Date__c desc];
	}

}

public boolean getIsManager(){
	for(Sales_Plans__c sp : [select Id from Sales_Plans__c where 
	Owner.UserRoleId in: allSubRoleIds and Id=:salesPlan.Id]){
		return true;
	}
	return false;
}

public List<monthlyCreated> monthlyCreated {get; set;}
public class monthlyCreated
{
public String cl {get; set;}
public Boolean created {get; set;}
public Boolean completed {get; set;}
public Boolean completedLate {get; set;}
public Date completedDate {get; set;}

public monthlyCreated(String cl, Boolean created, Boolean completed, Date completedDate, Boolean completedLate)
{
	this.cl = cl;
	this.created = created;
	this.completed = completed;
	this.completedDate = completedDate;
	this.completedLate = completedLate;
}

}


public class monthlyReportDistrict
{
public String district {get; set;}
public List<Integer> districtTotal {get; set;}
public Map<String, monthlyReportMarket> monthlyMarket {get; set;}

public monthlyReportDistrict(String district)
{
	this.district = district;
	districtTotal = new List<integer>{0,0,0,0};
	monthlyMarket = new Map<String, monthlyReportMarket>();
}

}


public List<monthlyReportMarket> monthlyReport {get; set;}
public class monthlyReportMarket
{
public String market {get; set;}
public List<integer> marketTotal {get; set;}
public list<monthlyReportCL> monthlyCL {get; set;}

public monthlyReportMarket(String market)
{
	this.market = market;
	marketTotal = new List<integer>{0,0,0,0};
	monthlyCL = new list<monthlyReportCL>();
}

}

public class monthlyReportCL
{
public String cl {get; set;}
public list<monthlyReportAccount> monthlyAccount {get; set;}

public monthlyReportCL(String clName)
{
	cl = clName;
	monthlyAccount = new list<monthlyReportAccount>();
}

}

public class monthlyReportAccount
{
public String accountName {get; set;}
public List<Integer> stratEncounterTotals {get; set;}

public monthlyReportAccount(String aName)
{
	accountName = aName;
	stratEncounterTotals = new List<Integer>();
}
}


public List<monthlyReportDistrict> getMonthlySalesPlanReport(){
	Date lowDate = Date.newInstance(Integer.valueOf(selectedYear), 1, 1);
	Date highDate = Date.newInstance(Integer.valueOf(selectedYear), 12, 31);
	if(selectedMonth!=null) {
		lowDate=Date.newInstance(Integer.valueOf(selectedYear), Integer.valueOf(selectedMonth), 1);
		Integer numberOfDays = Date.daysInMonth(lowDate.year(), lowDate.month());
		highDate=lowDate.addDays(numberOfDays-1);
	}

	Map<Id, User> clMarket = new Map<Id, User>();

	for(User u : [select id, area__c, district__c, Name from user where UserRoleId in : allSubRoleIds or Id = :UserInfo.getUserId()]) {
		clMarket.put(u.Id, u);
	}


	Map<Id, monthlyReportCL> dataByCl = new Map<Id, monthlyReportCL>();

	Map<Id, String> accountNames = new Map<Id, String>();
	for(AggregateResult ar : [select Account__c accountId, Account__r.Name accountName from Account_Sales_Plan__c
	                          where Parent_Sales_Plan__r.OwnerId in :clMarket.keySet() and
	                          Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                          Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate group by
	                          Account__c, Account__r.Name]) {
		Id accountId = String.valueOf(ar.get('accountId'));
		if(!accountNames.containsKey(accountId)) accountNames.put(
				String.valueOf(ar.get('accountId')), String.valueOf(ar.get('accountName')));

	}

	Map<Id, Map<Id, List<Integer> > > clToAccountData = new Map<Id, Map<Id, List<Integer> > >();

	Map<String, List<Integer> > clAccountData = new Map<String, List<Integer> >();

	for(AggregateResult ar : [select count(id) totalStrategies,
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId clId, Account_Sales_Plan__r.Account__c accountId from Account_Strategy__c
	                          where Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId in :clMarket.keySet() and
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate group by
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId, Account_Sales_Plan__r.Account__c]) {
		String clId = String.valueOf(ar.get('clId'));
		String accountId = String.valueOf(ar.get('accountId'));
		String clAccountId = clId + accountId;
		Integer totalStrategies = Integer.valueOf(ar.get('totalStrategies'));

		if(clAccountData.containsKey(clAccountId)) {
			clAccountData.get(clAccountId)[0] = totalStrategies;
		} else {
			clAccountData.put(clAccountId, new List<Integer> {totalStrategies, 0, 0, 0});
		}
	}

	for(AggregateResult ar : [select count(id) totalCompleteStrategies,
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId clId, Account_Sales_Plan__r.Account__c accountId from Account_Strategy__c
	                          where Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId in :clMarket.keySet() and
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                          Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate and Complete__c=true group by
	                                                                                                                       Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId, Account_Sales_Plan__r.Account__c]) {
		String clId = String.valueOf(ar.get('clId'));
		String accountId = String.valueOf(ar.get('accountId'));
		String clAccountId = clId + accountId;
		Integer totalCompleteStrategies = Integer.valueOf(ar.get('totalCompleteStrategies'));
		if(clAccountData.containsKey(clAccountId)) {
			clAccountData.get(clAccountId)[1] = totalCompleteStrategies;
		} else {
			clAccountData.put(clAccountId, new List<Integer> {0, totalCompleteStrategies, 0, 0});
		}


	}

	for(AggregateResult ar : [select count(id) totalAssociatedEncounters, OwnerId clId, WhatId accountId
	                          from event where SalesHD_Account_Strategy__c in (select id from Account_Strategy__c
	                                                                           where Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId in :clMarket.keySet() and
	                                                                           Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                                                                           Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate) group by OwnerId, WhatId]) {
		String clId = String.valueOf(ar.get('clId'));
		String accountId = String.valueOf(ar.get('accountId'));
		String clAccountId = clId + accountId;
		Integer totalAssociatedEncounters = Integer.valueOf(ar.get('totalAssociatedEncounters'));
		if(clAccountData.containsKey(clAccountId)) {
			clAccountData.get(clAccountId)[2] = totalAssociatedEncounters;
		} else {
			clAccountData.put(clAccountId, new List<Integer> {0, 0, totalAssociatedEncounters, 0});
		}
	}

	for(AggregateResult ar : [select count(id) totalAssociatedEncountersComplete, OwnerId clId, WhatId accountId
	                          from event where SalesHD_Complete__c=true and SalesHD_Account_Strategy__c in (select id from Account_Strategy__c
	                                                                                                        where Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId in :clMarket.keySet() and
	                                                                                                        Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                                                                                                        Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate) group by OwnerId, WhatId]) {
		String clId = String.valueOf(ar.get('clId'));
		String accountId = String.valueOf(ar.get('accountId'));
		String clAccountId = clId + accountId;
		Integer totalAssociatedEncountersComplete = Integer.valueOf(ar.get('totalAssociatedEncountersComplete'));
		if(clAccountData.containsKey(clAccountId)) {
			clAccountData.get(clAccountId)[3] = totalAssociatedEncountersComplete;
		} else {
			clAccountData.put(clAccountId, new List<Integer> {0, 0, 0, totalAssociatedEncountersComplete});
		}
	}

	Map<String, List<Integer>> districtTotalsData = new Map<String, List<Integer>>();
	Map<String, List<Integer>> marketTotalsData = new Map<String, List<Integer>>();

	for(AggregateResult ar : [select
	                          Parent_Sales_Plan__r.OwnerId clId, Account__c accountId from Account_Sales_Plan__c
	                          where Parent_Sales_Plan__r.OwnerId in :clMarket.keySet() and
	                          Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                          Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate group by
	                          Parent_Sales_Plan__r.OwnerId, Account__c]) {

		String clId = String.valueOf(ar.get('clId'));
		String accountId = String.valueOf(ar.get('accountId'));
		String clAccountId = clId + accountId;


		monthlyReportAccount mAccount = new monthlyReportAccount(accountNames.get(accountId));

		if(clAccountData.containsKey(clAccountId)) {
			mAccount.stratEncounterTotals = clAccountData.get(clAccountId);

			String market = '-';
			String district = '-';

			if(clMarket.get(clId).district__c!=null) district = clMarket.get(clId).district__c;
			if(clMarket.get(clId).area__c!=null) market = clMarket.get(clId).area__c;
			
			if(districtTotalsData.containsKey(district)){
				for(integer i=0; i< districtTotalsData.get(district).size(); i++){
					districtTotalsData.get(district)[i] += mAccount.stratEncounterTotals[i];
				}
			} else{
				districtTotalsData.put(district, mAccount.stratEncounterTotals);
			}
			if(marketTotalsData.containsKey(market)){
				for(integer i=0; i< marketTotalsData.get(market).size(); i++){
					marketTotalsData.get(market)[i] += mAccount.stratEncounterTotals[i];
				}
			} else{
				marketTotalsData.put(market, mAccount.stratEncounterTotals);
			}
			
		} else{
			mAccount.stratEncounterTotals = new List<Integer> {0,0,0,0};
		}

		monthlyReportCL mCl = new monthlyReportCL(clMarket.get(clId).Name);
		mCl.monthlyAccount.add(mAccount);

		if(dataByCl.containsKey(clId)) {
			dataByCl.get(clId).monthlyAccount.add(mAccount);
		} else {
			dataByCl.put(clId, mCl);
		}

	}

	Map<String, monthlyReportDistrict> reportData = new Map<String, monthlyReportDistrict>();
	// Map<String, monthlyReportMarket> reportData = new Map<String, monthlyReportMarket>();
	for(Id clId : dataByCl.keySet()) {
		String market = '-';
		String district = '-';

		if(clMarket.get(clId).district__c!=null) district = clMarket.get(clId).district__c;
		if(clMarket.get(clId).area__c!=null) market = clMarket.get(clId).area__c;
		if(reportData.containsKey(district)){
			// if(districtTotalsData.containsKey(district)){
			// 	reportData.get(district).districtTotal = districtTotalsData.get(district);
			// }
			reportData.get(district).districtTotal = new List<Integer>{2,5,3,8};
			if(reportData.get(district).monthlyMarket.containsKey(market)){
				reportData.get(district).monthlyMarket.get(market).monthlyCL.add(dataByCl.get(clId));

				if(marketTotalsData.containsKey(market)){
					reportData.get(district).monthlyMarket.get(market).marketTotal = marketTotalsData.get(market);
				}
			} else{
				monthlyReportMarket mrm = new monthlyReportMarket(market);
				mrm.monthlyCL.add(dataByCl.get(clId));
				reportData.get(district).monthlyMarket.put(district, mrm);
			}
		} else{
			monthlyReportDistrict mrd = new monthlyReportDistrict(district);
			if(districtTotalsData.containsKey(district)){
				mrd.districtTotal = districtTotalsData.get(district);
			}
			monthlyReportMarket mrm = new monthlyReportMarket(market);
			if(marketTotalsData.containsKey(market)){
				mrm.marketTotal = marketTotalsData.get(market);
			}
			mrm.monthlyCL.add(dataByCl.get(clId));
			mrd.monthlyMarket = new Map<String, monthlyReportMarket>{market => mrm};
			reportData.put(district, mrd);
		}


		// List<Integer> clData = new List<Integer>();
		// clData = dataByCl.get(clId);
		// for(integer i=0; i< reportData.get(district).districtTotal.size(); i++){
		// 	reportData.get(district).districtTotal[i] += clData[i];
		// }
		// for(integer i=0; i< reportData.get(district).monthlyMarket.get(market).marketTotal.size(); i++){
		// 	reportData.get(district).monthlyMarket.get(market).marketTotal[i] += clData.[i];
		// }

		// if(reportData.containsKey(market)) {
		// 	reportData.get(market).monthlyCL.add(dataByCl.get(clId));
		// } else{
		// 	monthlyReportMarket mrm = new monthlyReportMarket(market);
		// 	mrm.monthlyCL.add(dataByCl.get(clId));
		// 	reportData.put(market, mrm);
		// }

	}

	return reportData.values();
	// return reportDat.values();



}

public PageReference changeMarket(){
	PageReference page = new Pagereference('/apex/SalesHD_SalesPlanCreatedReport');
	if(usr.District__c==null) usr.Area__c=null;
	page.getParameters().put('dst', String.valueOf(usr.District__c));
	page.getParameters().put('mkt', String.valueOf(usr.Area__c));
	page.getParameters().put('m', String.valueOf(selectedMonth));
	page.getParameters().put('y', String.valueOf(selectedYear));
	// if(usr.Area__c!=null) page.getParameters().put('m', String.valueOf(usr.Area__c));
	page.setRedirect(true);
	return page;
}

public createdReportChart crp {get; set;}
public class createdReportChart {
public integer completedTotal {get; set;}
public integer incompletedTotal {get; set;}
public integer completedOnTimeTotal {get; set;}
public integer completedLateTotal {get; set;}
public createdReportChart(){
	completedTotal = 0;
	incompletedTotal = 0;
	completedOnTimeTotal = 0;
	completedLateTotal = 0;
}
}

public List<monthlyCreated> getCreatedReport(){
	crp = new createdReportChart();
	if(selectedMonth==null) selectedMonth = String.valueOf(System.now().month());
	Date lowDate = Date.newInstance(Integer.valueOf(selectedYear), 1, 1);
	Date highDate = Date.newInstance(Integer.valueOf(selectedYear), 12, 31);
	if(selectedMonth!=null) {
		lowDate=Date.newInstance(Integer.valueOf(selectedYear), Integer.valueOf(selectedMonth), 1);
		Integer numberOfDays = Date.daysInMonth(lowDate.year(), lowDate.month());
		highDate=lowDate.addDays(numberOfDays-1);
	}

	Map<Id, User> cls = new Map<Id, User>();

	Id currentUserId = UserInfo.getUserId();
	String query = 'select id, area__c, Name from user where (UserRoleId in : allSubRoleIds or Id =: currentUserId)';
	if(usr!=null) {
		if(usr.area__c!=null) query += ' and area__c=\''+usr.area__c+'\'';
		if(usr.district__c!=null) query += ' and district__c=\''+usr.district__c+'\'';
	}


	for(User u : database.query(query)) {
		cls.put(u.Id, u);
	}


	query = 'select SalesHD_Plan_Date__c, CreatedById, Plan_Filled_Out_Date__c from Sales_Plans__c where'+
	        'CreatedById in :cls.keyset() and SalesHD_Plan_Date__c>=: lowDate and SalesHD_Plan_Date__c<=: highDate';



	List<monthlyCreated> reportData = new List<monthlyCreated>();

	for(Sales_Plans__c sp : [select SalesHD_Plan_Date__c, CreatedById, Plan_Filled_Out_Date__c from Sales_Plans__c where
	                         CreatedById in :cls.keyset() and SalesHD_Plan_Date__c>=: lowDate and SalesHD_Plan_Date__c<=: highDate]) {
		String clId = sp.CreatedById;
		Boolean created = true;
		Boolean completed = false;
		Date completedDate = null;
		Boolean completedLate = null;

		if(sp.Plan_Filled_Out_Date__c!=null) {
			completed = true;
			crp.completedTotal++;
			completedDate = Date.valueOf(sp.Plan_Filled_Out_Date__c);
			if( sp.Plan_Filled_Out_Date__c > sp.SalesHD_Plan_Date__c &&
			    Date.valueOf(sp.SalesHD_Plan_Date__c).daysBetween(Date.valueOf(sp.Plan_Filled_Out_Date__c))>4) {
				crp.completedLateTotal++;
				completedLate = true;
			} else{
				crp.completedOnTimeTotal++;
			}

		}

		String clName = '';
		if(cls.containsKey(clId) && cls.get(clId).name!=null) clName = cls.get(clId).name;
		reportData.add(new monthlyCreated(clName, created, completed, completedDate, completedLate));
		cls.remove(clId);
	}

	for(User u : cls.values()) {
		reportData.add(new monthlyCreated(u.name, false, null, null, null));
		crp.incompletedTotal++;
	}


	return reportData;



}

public void getAccountPlansEvents(){
	aPlans = new List<accountsPlans>();
	Sales_Plans__c previousPlan = new Sales_Plans__c();
	for(Sales_Plans__c sp : [select Id from Sales_Plans__c
	                         where ownerId =:spOwner and SalesHD_Plan_Date__c<:spDate
	                                         and Id!=:ApexPages.currentPage().getParameters().get('id')
	                                         order by SalesHD_Plan_Date__c desc limit 1]) {
		previousPlan = sp;
	}

	Map<Id, List<Event> > strategyEvents = new Map<Id, List<Event> >();
	for(Event e : [select Id, accountId, Who.Name, SalesHD_Complete__c,
	               SalesHD_Call_Objective__c, StartDateTime, SalesHD_Account_Strategy__c from event where
	               SalesHD_Account_Strategy__c in (Select Id from Account_Strategy__c
	                                               where Account_Sales_Plan__r.Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id'))]) {
		if(strategyEvents.containsKey(e.SalesHD_Account_Strategy__c)) {
			strategyEvents.get(e.SalesHD_Account_Strategy__c).add(e);
		} else{
			strategyEvents.put(e.SalesHD_Account_Strategy__c, new List<Event> {e});
		}
	}

	Map<Id, List<Account_Strategy__c> > accountsStrategies = new Map<Id, List<Account_Strategy__c> >();
	for(Account_Strategy__c strategy : [select Due_Date__c,Complete__c, Account_Sales_Plan__r.Account__c, Strategy__c from Account_Strategy__c where Account_Sales_Plan__c in
	                                            (Select Id from Account_Sales_Plan__c where Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id')) order by createdDate asc]) {
		if(!ApexPages.currentPage().getUrl().contains('SalesHD_CopyStrategies')) {
			if(accountsStrategies.containsKey(strategy.Account_Sales_Plan__r.Account__c)) {
				accountsStrategies.get(strategy.Account_Sales_Plan__r.Account__c).add(strategy);
			} else{
				accountsStrategies.put(strategy.Account_Sales_Plan__r.Account__c, new List<Account_Strategy__c> {strategy});
			}
		} else if(!strategy.Complete__c) {
			if(accountsStrategies.containsKey(strategy.Account_Sales_Plan__r.Account__c)) {
				accountsStrategies.get(strategy.Account_Sales_Plan__r.Account__c).add(strategy);
			} else{
				accountsStrategies.put(strategy.Account_Sales_Plan__r.Account__c, new List<Account_Strategy__c> {strategy});
			}
		}
	}


	for(Account_Sales_Plan__c acp : [select Account__c, Account__r.Name, Challenges_Critical_Issues__c,
	                                 Goal__c, Parent_Sales_Plan__c from Account_Sales_Plan__c where
	                                 Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id')]) {
		accountsPlans aps = new accountsPlans(acp);
		if(accountsStrategies.containsKey(acp.Account__c)) {
			for(Account_Strategy__c accs : accountsStrategies.get(acp.Account__c)) {
				accountStrategy aStrat = new accountStrategy(accs);
				if(strategyEvents.containsKey(accs.Id)) {
					aStrat.stratEncounters.addAll(strategyEvents.get(accs.Id));
				}
				aps.strats.add(aStrat);
			}
		}

		aPlans.add(aps);
	}


}

public List<Non_Conversion__c> getNonConversion(){
	Date spDate = spDate;
	Date lowDate = Date.newInstance(spDate.Year(), spDate.Month(), 1).addMonths(-1);
	Date highDate = Date.newInstance(spDate.Year(), spDate.Month(), Date.daysInMonth(spDate.year(), spDate.month())).addMonths(-1);
	return [select Total_Referrals__c, Total_Admits__c, Non_Converted_Referrals__c, Conversion_Rate__c, Percent_Non_Converted__c,
	        Insurance_Denials__c, Lost_to_Lower_Level_of_Care__c, Med_Necessity__c, Financial_Denial__c, Lost_to_Competitor__c,
	        Lost_to_Kindred_LTAC__c, Family_Decision__c, Expired__c, Pending__c, Percent_Viable__c,
	        Percent_Insurance_Denials__c, Percent_Lost_to_Lower_Level_of_Care__c, Percent_Med_Necessity__c, Percent_Financial_Denial__c,
	        Percent_Lost_to_Competitor__c, Percent_Lost_to_Kindred_LTAC__c, Percent_Family_Decision__c, Percent_Expired__c, Percent_Pending__c
	        from Non_Conversion__c where (Date__c>=: lowDate and Date__c<=: highDate) and CL__c=: spOwner order by lastModifiedDate limit 1];
}

public String getAccountMetrics(){
	Date spDate = spDate;
	Date lowDate = Date.newInstance(spDate.Year(), spDate.Month(), 1).addMonths(-1);
	Date highDate = Date.newInstance(spDate.Year(), spDate.Month(), Date.daysInMonth(spDate.year(), spDate.month())).addMonths(-1);

	Map<Id, accountMetric> metrics = new Map<Id, accountMetric>();

	for(AccountTeamMember atm : [select AccountId, Account.Name from AccountTeamMember where userId=:spOwner]) {
		accountMetric am = new accountMetric();
		am.accountName = atm.Account.Name;
		metrics.put(atm.AccountId, am);
	}


	for(Sales_Account_Metrics__c am : [select Account__r.Name, Account__c, Sales_HD_Admits__c,
	                                   SalesHD_Referrals__c, Month__c from Sales_Account_Metrics__c
	                                   where Account__c in :metrics.keyset() and ((Month__c>=:lowDate and Month__c<=:highDate)or
	                                                                                      (Month__c>=:lowDate.addYears(-1) and Month__c<=:highDate.addYears(-1)))]) {
		if(metrics.containsKey(am.Account__c)) {
			accountMetric nam = metrics.get(am.Account__c);
			nam.accountName = am.Account__r.Name;
			if(am.Month__c < lowDate) nam.pyMtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
			else nam.cyMtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
		}
	}


	Date previousMonth = spDate.addMonths(-1);
	lowDate = Date.newInstance(previousMonth.Year(), 1, 1);
	highDate = Date.newInstance(previousMonth.Year(), previousMonth.Month(), Date.daysInMonth(previousMonth.year(), previousMonth.month()));

	for(Sales_Account_Metrics__c am : [select Account__r.Name, Account__c, Sales_HD_Admits__c,
	                                   SalesHD_Referrals__c, Month__c from Sales_Account_Metrics__c
	                                   where Account__c in :metrics.keyset() and ((Month__c>=:lowDate and Month__c<=:highDate)or
	                                                                                      (Month__c>=:lowDate.addYears(-1) and Month__c<=:highDate.addYears(-1)))]) {
		if(metrics.containsKey(am.Account__c)) {
			accountMetric nam = metrics.get(am.Account__c);
			nam.accountName = am.Account__r.Name;
			if(am.Month__c < lowDate) {
				if(nam.pyYtdAdmit==null) nam.pyYtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
				else nam.pyYtdAdmit += Integer.valueOf(am.Sales_HD_Admits__c);
			}
			else{
				if(nam.cyYtdAdmit==null) nam.cyYtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
				else nam.cyYtdAdmit += Integer.valueOf(am.Sales_HD_Admits__c);
			}
		}
	}

	accountMetric totals = new accountMetric();
	totals.accountName = 'Totals';
	totals.cyMtdAdmit = 0;
	totals.pyMtdAdmit = 0;
	totals.cyYtdAdmit = 0;
	totals.pyYtdAdmit = 0;
	for(accountMetric am : metrics.values()) {
		if(am.cyMtdAdmit!=null) totals.cyMtdAdmit += am.cyMtdAdmit;
		if(am.pyMtdAdmit!=null) totals.pyMtdAdmit += am.pyMtdAdmit;

		if(am.cyMtdAdmit!=null && am.pyMtdAdmit!=null) {
			am.mtdVariance = am.cyMtdAdmit-am.pyMtdAdmit;
		}

		if(am.cyYtdAdmit!=null) totals.cyYtdAdmit += am.cyYtdAdmit;
		if(am.pyYtdAdmit!=null) totals.pyYtdAdmit += am.pyYtdAdmit;

		if(am.cyYtdAdmit!=null && am.pyYtdAdmit!=null) {
			am.ytdVariance = am.cyYtdAdmit-am.pyYtdAdmit;
		}

	}
	totals.mtdVariance = totals.cyMtdAdmit-totals.pyMtdAdmit;
	totals.ytdVariance = totals.cyYtdAdmit-totals.pyYtdAdmit;

	List<accountMetric> accountMetricList = new List<accountMetric>();
	accountMetricList = metrics.values();
	accountMetricList.add(totals);
	return JSON.serialize(accountMetricList);
}

public List<AccountMetric> getAccountMetricsPdf(){
	Date spDate = spDate;
	Date lowDate = Date.newInstance(spDate.Year(), spDate.Month(), 1).addMonths(-1);
	Date highDate = Date.newInstance(spDate.Year(), spDate.Month(), Date.daysInMonth(spDate.year(), spDate.month())).addMonths(-1);

	Map<Id, accountMetric> metrics = new Map<Id, accountMetric>();

	for(AccountTeamMember atm : [select AccountId, Account.Name from AccountTeamMember where userId=:spOwner]) {
		accountMetric am = new accountMetric();
		am.accountName = atm.Account.Name;
		metrics.put(atm.AccountId, am);
	}


	for(Sales_Account_Metrics__c am : [select Account__r.Name, Account__c, Sales_HD_Admits__c,
	                                   SalesHD_Referrals__c, Month__c from Sales_Account_Metrics__c
	                                   where Account__c in :metrics.keyset() and ((Month__c>=:lowDate and Month__c<=:highDate)or
	                                                                                      (Month__c>=:lowDate.addYears(-1) and Month__c<=:highDate.addYears(-1)))]) {
		if(metrics.containsKey(am.Account__c)) {
			accountMetric nam = metrics.get(am.Account__c);
			nam.accountName = am.Account__r.Name;
			if(am.Month__c < lowDate) nam.pyMtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
			else nam.cyMtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
		}
	}


	Date previousMonth = spDate.addMonths(-1);
	lowDate = Date.newInstance(previousMonth.Year(), 1, 1);
	highDate = Date.newInstance(previousMonth.Year(), previousMonth.Month(), Date.daysInMonth(previousMonth.year(), previousMonth.month()));

	for(Sales_Account_Metrics__c am : [select Account__r.Name, Account__c, Sales_HD_Admits__c,
	                                   SalesHD_Referrals__c, Month__c from Sales_Account_Metrics__c
	                                   where Account__c in :metrics.keyset() and ((Month__c>=:lowDate and Month__c<=:highDate)or
	                                                                                      (Month__c>=:lowDate.addYears(-1) and Month__c<=:highDate.addYears(-1)))]) {
		if(metrics.containsKey(am.Account__c)) {
			accountMetric nam = metrics.get(am.Account__c);
			nam.accountName = am.Account__r.Name;
			if(am.Month__c < lowDate) {
				if(nam.pyYtdAdmit==null) nam.pyYtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
				else nam.pyYtdAdmit += Integer.valueOf(am.Sales_HD_Admits__c);
			}
			else{
				if(nam.cyYtdAdmit==null) nam.cyYtdAdmit = Integer.valueOf(am.Sales_HD_Admits__c);
				else nam.cyYtdAdmit += Integer.valueOf(am.Sales_HD_Admits__c);
			}
		}
	}

	accountMetric totals = new accountMetric();
	totals.accountName = 'Totals';
	totals.cyMtdAdmit = 0;
	totals.pyMtdAdmit = 0;
	totals.cyYtdAdmit = 0;
	totals.pyYtdAdmit = 0;
	for(accountMetric am : metrics.values()) {
		if(am.cyMtdAdmit!=null) totals.cyMtdAdmit += am.cyMtdAdmit;
		if(am.pyMtdAdmit!=null) totals.pyMtdAdmit += am.pyMtdAdmit;

		if(am.cyMtdAdmit!=null && am.pyMtdAdmit!=null) {
			am.mtdVariance = am.cyMtdAdmit-am.pyMtdAdmit;
		}

		if(am.cyYtdAdmit!=null) totals.cyYtdAdmit += am.cyYtdAdmit;
		if(am.pyYtdAdmit!=null) totals.pyYtdAdmit += am.pyYtdAdmit;

		if(am.cyYtdAdmit!=null && am.pyYtdAdmit!=null) {
			am.ytdVariance = am.cyYtdAdmit-am.pyYtdAdmit;
		}

	}
	totals.mtdVariance = totals.cyMtdAdmit-totals.pyMtdAdmit;
	totals.ytdVariance = totals.cyYtdAdmit-totals.pyYtdAdmit;

	List<accountMetric> accountMetricList = new List<accountMetric>();
	accountMetricList = metrics.values();
	accountMetricList.add(totals);
	// return JSON.serialize(accountMetricList);
	return accountMetricList;
}

public PageReference saveAccountPlans(){
	try{
		saveAll();
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	return page;
}

public PageReference planFilledOut(){
	try{
		salesPlan.Plan_Filled_Out_Date__c = System.now();
		saveAll();
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	return page;
}

public PageReference saveComment(){
	try{
		update salesPlan;
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	return page;
}

private void saveAll(){
	update salesPlan;
	List<Account_Sales_Plan__c> updateAccountPlans = new List<Account_Sales_Plan__c>();
	List<Account_Strategy__c> updateAccountStrategies = new List<Account_Strategy__c>();
	for(accountsPlans aps : aPlans) {
		updateAccountPlans.add(aps.aPlan);
		for(accountStrategy accs : aps.strats) {
			updateAccountStrategies.add(accs.strat);
		}
	}

	if(updateAccountPlans.size()>0) update updateAccountPlans;
	if(updateAccountStrategies.size()>0) update updateAccountStrategies;
}

public PageReference deleteAccountPlan(){
	try{
		List<Account_Sales_Plan__c> asp = [select Id from Account_Sales_Plan__c where Id=:accountPlanId];
		delete asp;
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	page.setRedirect(true);
	return page;
}

public PageReference deleteStrategy(){
	try{
		saveAll();
		List<Account_Strategy__c> aStrat = [select Id from Account_Strategy__c where Id=:strategyId];
		delete aStrat;
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	page.setRedirect(true);
	return page;
}

public PageReference addStrategy(){
	try{
		insert new Account_Strategy__c(Account_Sales_Plan__c=accountPlanId);
		saveAll();
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	page.setRedirect(true);
	return page;
}

public PageReference addAccountPlan(){
	try{
		List<Account_Sales_Plan__c> asp = [select Id from Account_Sales_Plan__c where
		                                   Account__c=:selectedAccount and Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id')];
		if(asp.size() == 0) {
			insert new Account_Sales_Plan__c(Account__c=selectedAccount,
			                                 Parent_Sales_Plan__c=ApexPages.currentPage().getParameters().get('id'));
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
			                                           'The selected account already has an account plan for this sales plan.'));
		}
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	page.setRedirect(true);
	return page;
}

public List<Selectoption> getAccountPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select a Favorited Account -'));
	for(AccountTeamMember atm : [select AccountId, Account.Name from AccountTeamMember
	                             where Account.Status__c='Active' and UserId =: UserInfo.getUserId() and Account.RecordType.Name='HD Accounts'
	                                                                                                                              and AccountId not in (Select Account__c from Account_Sales_Plan__c
	                                                                                                                                                    where Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id'))]) {
		picklist.add(new selectOption(atm.Account.Id, atm.Account.Name));
	}
	return picklist;
}

Map<String, String> monthMap = new Map<String, String> {
	'1'=>'January', '2'=>'February', '3'=>'March', '4'=>'April',
	'5'=>'May', '6'=>'June', '7'=>'July', '8'=>'August', '9'=>'September',
	'10'=>'October', '11'=>'November', '12'=>'December'
};

public List<Selectoption> getMonthPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select a Month -'));
	for(String monthNum : monthMap.keyset()) {
		picklist.add(new selectOption(monthNum, monthMap.get(monthNum)));
	}
	return picklist;
}

public List<Selectoption> getYearPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	Integer currentYear = System.now().year();
	picklist.add(new selectOption('', '- Select a Year -'));
	picklist.add(new selectOption(String.valueOf(currentYear-1), String.valueOf(currentYear-1)));
	picklist.add(new selectOption(String.valueOf(currentYear), String.valueOf(currentYear)));
	picklist.add(new selectOption(String.valueOf(currentYear+1), String.valueOf(currentYear+1)));
	return picklist;
}

public PageReference saveNewPlan(){
	if(newPlanYear!=null && newPlanMonth!=null) {
		Date lowPlanDate = Date.newInstance(newPlanYear,newPlanMonth,1);
		Integer numberOfDays = Date.daysInMonth(lowPlanDate.year(), lowPlanDate.month());
		Date highPlanDate = Date.newInstance(newPlanYear,newPlanMonth,numberOfDays);
		List<Sales_Plans__c> plans = [select Id from Sales_Plans__c where OwnerId=:UserInfo.getUserId() and
		                                                                           SalesHD_Plan_date__c>=:lowPlanDate and SalesHD_Plan_date__c<=:highPlanDate];

		Date canCreate = lowPlanDate;
		canCreate = canCreate.addMonths(1);
		if(plans.isEmpty()) {
			if(canCreate>=System.now()) {
				Sales_Plans__c sp = new Sales_Plans__c(SalesHD_Plan_Date__c=lowPlanDate);
				insert sp;

				List<Sales_Plans__c> previousPlans = [select Id from Sales_Plans__c where
				                                      OwnerId=:UserInfo.getUserId() and SalesHD_Plan_date__c<:lowPlanDate
				                                               order by SalesHD_Plan_date__c desc limit 1];

				List<Account_Strategy__c> acctStrat = [select Id from Account_Strategy__c where
				                                       Account_Sales_Plan__r.Parent_Sales_Plan__c in :previousPlans and
				                                       Complete__c=false];

				PageReference page = null;

				if(!acctStrat.isEmpty()) {
					page = new PageReference('/apex/SalesHD_CopyStrategies?id='+previousPlans[0].Id+'&newId='+sp.Id);
					page.setRedirect(true);
				} else {
					page = new PageReference('/apex/SalesHD_SalesPlan?id='+sp.Id);
					page.setRedirect(true);
				}
				return page;
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot create a sales plan for past months.'));
			}

		} else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You already have a sales plan saved for '+
			                                           +monthMap.get(String.valueOf(newPlanMonth))+' '+newPlanYear+'.'));
		}
	}
	return null;
}

public PageReference copySelectedStrategies(){
	try{

		Sales_Plans__c newSalesPlan = [select Id from Sales_Plans__c where
		                               Id=:ApexPages.currentPage().getParameters().get('newId')];

		Map<Id, Id> AccountIdToPlanId = new Map<Id, Id>();
		for(Account_Sales_Plan__c asp : [select Account__c from Account_Sales_Plan__c
		                                 where Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('newId')]) {
			AccountIdToPlanId.put(asp.Account__c, asp.Id);
		}

		Map<Id, List<Account_Strategy__c> > accountIdStrategies = new Map<Id, List<Account_Strategy__c> >();
		List<Account_Sales_Plan__c> insertAccountPlans = new List<Account_Sales_Plan__c>();
		List<Account_Strategy__c> insertAccountStrategies = new List<Account_Strategy__c>();

		for(accountsPlans aps : aPlans) {
			for(accountStrategy accs : aps.strats) {
				if(accs.strat.Complete__c) {
					if(accountIdStrategies.containsKey(aps.aPlan.Account__c)) {
						accountIdStrategies.get(aps.aPlan.Account__c).add(new Account_Strategy__c(Strategy__c=accs.strat.Strategy__c));
					} else {
						accountIdStrategies.put(aps.aPlan.Account__c, new List<Account_Strategy__c> {new Account_Strategy__c(Strategy__c=accs.strat.Strategy__c)});
						if(!AccountIdToPlanId.containsKey(aps.aPlan.Account__c)) insertAccountPlans.add(new Account_Sales_Plan__c(Account__c=aps.aPlan.Account__c, Parent_Sales_Plan__c=newSalesPlan.Id));
					}
				}
			}
		}

		insert insertAccountPlans;

		for(Account_Sales_Plan__c asp : insertAccountPlans) {
			AccountIdToPlanId.put(asp.Account__c, asp.Id);
		}

		for(Id accountId : AccountIdToPlanId.keyset()) {
			if(accountIdStrategies.containsKey(accountId)) {
				for (Account_Strategy__c aStrat : accountIdStrategies.get(accountId)) {
					aStrat.Account_Sales_Plan__c = AccountIdToPlanId.get(accountId);
					insertAccountStrategies.add(aStrat);
				}
			}
		}

		insert insertAccountStrategies;

	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}

	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+ApexPages.currentPage().getParameters().get('newId'));
	page.setRedirect(true);
	return page;
}

public list<salesPlans> getPlanRelateList(){
	list<salesPlans> salesPlanList = new list<salesPlans>();

	Date lowDate = Date.newInstance(System.now().year(), System.now().month(), 1);
	Date highDate = Date.newInstance(System.now().year(), System.now().month(), date.daysInMonth(System.now().year(), System.now().month()));
	if(ApexPages.currentPage().getParameters().get('eId')!=null) {
		for(Event e : [select startDateTime from event where id=:ApexPages.currentPage().getParameters().get('eId')]) {
			lowDate = Date.newInstance(e.startDateTime.year(), e.startDateTime.month(), 1);
			highDate = Date.newInstance(e.startDateTime.year(), e.startDateTime.month(), date.daysInMonth(e.startDateTime.year(), e.startDateTime.month()));
		}
	}
	lowDate = lowDate.addMonths(-1);
	highDate = highDate.addMonths(1);

	// Map<Id, List<Account_Strategy__c> > accountsStrategies = new Map<Id, List<Account_Strategy__c> >();
	Map<Id, Map<Id, List<Account_Strategy__c> > > planAccountsStrategies = new Map<Id, Map<Id, List<Account_Strategy__c> > >();
	for(Account_Strategy__c strategy : [select Complete__c, Account_Sales_Plan__r.Account__c, Strategy__c,
	                                    Account_Sales_Plan__r.Parent_Sales_Plan__c from Account_Strategy__c where
	                                    Account_Sales_Plan__r.Parent_Sales_Plan__r.OwnerId =: UserInfo.getUserId() and
	                                                                                         Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                                                                                         Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate order by createdDate asc]) {
		strategy.Complete__c = false;
		if(planAccountsStrategies.containsKey(strategy.Account_Sales_Plan__r.Parent_Sales_Plan__c)) {
			Map<Id, List<Account_Strategy__c> > accountStrat =
				planAccountsStrategies.remove(strategy.Account_Sales_Plan__r.Parent_Sales_Plan__c);
			if(accountStrat.containsKey(strategy.Account_Sales_Plan__r.Account__c)) {
				accountStrat.get(strategy.Account_Sales_Plan__r.Account__c).add(strategy);
			} else {
				accountStrat.put(strategy.Account_Sales_Plan__r.Account__c, new List<Account_Strategy__c> {strategy});
			}
			planAccountsStrategies.put(strategy.Account_Sales_Plan__r.Parent_Sales_Plan__c, accountStrat);
		} else{
			planAccountsStrategies.put(strategy.Account_Sales_Plan__r.Parent_Sales_Plan__c,
			                           new Map<Id, List<Account_Strategy__c> > {strategy.Account_Sales_Plan__r.Account__c =>
			                                                                                                                new List<Account_Strategy__c> {strategy} });
		}

		// accountsStrategies.put(strategy.Account_Sales_Plan__r.Account__c, new List<Account_Strategy__c> {strategy});
	}

	Map<Id, List<accountsPlans> > salesPlansMap = new Map<Id, List<accountsPlans> >();
	for(Account_Sales_Plan__c acp : [select Account__c, Account__r.Name, Challenges_Critical_Issues__c,
	                                 Goal__c, Parent_Sales_Plan__c from Account_Sales_Plan__c where
	                                 Parent_Sales_Plan__r.OwnerId =: UserInfo.getUserId() and
	                                                                Parent_Sales_Plan__r.SalesHD_Plan_Date__c>=: lowDate and
	                                                                Parent_Sales_Plan__r.SalesHD_Plan_Date__c<=: highDate]) {

		accountsPlans aps = new accountsPlans(acp);
		if(planAccountsStrategies.containsKey(acp.Parent_Sales_Plan__c)) {
			if(planAccountsStrategies.get(acp.Parent_Sales_Plan__c).containsKey(acp.Account__c)) {
				for(Account_Strategy__c accs : planAccountsStrategies.get(acp.Parent_Sales_Plan__c).get(acp.Account__c)) {
					accountStrategy aStrat = new accountStrategy(accs);
					aps.strats.add(aStrat);
				}
			}
		}


		if(salesPlansMap.containsKey(acp.Parent_Sales_Plan__c)) {
			salesPlansMap.get(acp.Parent_Sales_Plan__c).add(aps);
		} else{
			salesPlansMap.put(acp.Parent_Sales_Plan__c, new List<accountsPlans> {aps});
		}
	}

	for(Sales_Plans__c sps : [select Id, SalesHD_Plan_Date__c from Sales_Plans__c
	                          where OwnerId =: UserInfo.getUserId() and
	                                          SalesHD_Plan_Date__c>=: lowDate and SalesHD_Plan_Date__c<=: highDate
	                                          order by SalesHD_Plan_Date__c desc]) {
		salesPlans sp = new salesPlans(sps);
		sp.acctPlans = salesPlansMap.remove(sps.Id);
		salesPlanList.add(sp);
	}

	return salesPlanList;
}
public String selectedRelatedStrategy {get; set;}
public PageReference relateEncounterPlan(){
	Event this_e = null;
	Account_Strategy__c this_strat = null;
	try{
		for(Event e : [select Id, SalesHD_Account_Strategy__c from event where id=:ApexPages.currentPage().getParameters().get('eId')]) {
			this_e = e;
		}
		for(Account_Strategy__c strat : [select Id from Account_Strategy__c where Id =: selectedRelatedStrategy]) {
			this_strat = strat;
		}

		if(this_e!=null) {
			this_e.SalesHD_Account_Strategy__c = null;
			if(this_strat!=null) {
				this_e.SalesHD_Account_Strategy__c = this_strat.Id;
			}
			update this_e;
		}
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_Encounters');
	if(this_e != null) {
		page = new PageReference('/apex/SalesHD_Encounter?id='+this_e.Id);
	}


	return page;
}


}
