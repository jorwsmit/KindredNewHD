global without sharing class SalesHD_SalesPlan {

public Integer newPlanMonth {get; set;}
public Integer newPlanYear {get; set;}

public Sales_Plans__c salesPlan {get; set;}
public Date spDate {get; set;}
public Id spOwner {get; set;}

public String planDate {get; set;}
public String planDateLastMonth {get; set;}
public String planDateLastYear {get; set;}

public List<Account_Sales_Plan__c> accountPlans {get; set;}
public Id accountPlanId {get; set;}
public Id strategyId {get; set;}
public Id selectedAccount {get; set;}

// public Map<Id, Event> accountsEvents {get; set;}

// public List<Sales_Account_Metrics__c> accountMetrics {get; set;}

public String accountMetrics {get; set;}

public Integer referrals {get; set;}
public Integer admits {get; set;}
public Integer nonconverted {get; set;}
public Integer pending {get; set;}

public list<accountsPlans> aPlans {get; set;}

public class accountMetric {
String accountName;
Integer cyMtdAdmit, pyMtdAdmit, mtdVariance;
Integer cyYtdAdmit, pyYtdAdmit, YtdVariance;
}

public class accountsPlans
{
public Account_Sales_Plan__c aPlan {get; set;}
public list<Event> aEvents {get; set;}
public list<Account_Strategy__c> strategies {get; set;}
public list<accountStrategy> strats {get; set;}

public accountsPlans(Account_Sales_Plan__c p)
{
	aPlan = p;
	aEvents = new list<Event>();
	strategies = new list<Account_Strategy__c>();
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


private List<String> months = new List<String> {'January', 'February', 'March', 'April',
	                                        'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};

public SalesHD_SalesPlan(ApexPages.StandardController stdController) {
	salesPlan = (Sales_Plans__c)stdController.getRecord();
	planDate = '';  planDateLastYear = '';
	for(Sales_Plans__c sp : [select Id, SalesHD_Plan_date__c, OwnerId from Sales_Plans__c where Id=
					 :ApexPages.currentPage().getParameters().get('id')]) {
		// salesPlan = sp;
		spDate = sp.SalesHD_Plan_Date__c;
		spOwner = sp.OwnerId;
		planDate = months[sp.SalesHD_Plan_Date__c.month()-1] + ' ' + sp.SalesHD_Plan_Date__c.year();
		planDateLastMonth = months[sp.SalesHD_Plan_Date__c.addMonths(-1).month()-1] + ' ' + sp.SalesHD_Plan_Date__c.addMonths(-1).year();
		planDateLastYear = months[sp.SalesHD_Plan_Date__c.addMonths(-1).month()-1] + ' ' + (sp.SalesHD_Plan_Date__c.addMonths(-1).year()-1);
	}

	accountPlans = new List<Account_Sales_Plan__c>();
	for(Account_Sales_Plan__c acp : [select Account__r.Name, Challenges_Critical_Issues__c,
	                                 Due_Date__c, Goal__c, Parent_Sales_Plan__c, Strategy__c from Account_Sales_Plan__c where
	                                 Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id')]) {
		accountPlans.add(acp);
	}


	getAccountPlansEvents();

	if(ApexPages.currentPage().getParameters().get('id')!=null) accountMetrics = getAccountMetrics();

	newPlanMonth = System.now().month();
	newPlanYear = System.now().year();
}

public List<Sales_Plans__c> getMyPlans(){
	// myPlans = new List<Sales_Plans__c>
	return [select Id, SalesHD_Plan_Date__c from Sales_Plans__c where OwnerId=: UserInfo.getUserId()];
}

public void getAccountPlansEvents(){
	aPlans = new List<accountsPlans>();
	// Map<Id, List<Event> > accountsEvents = new Map<Id, List<Event> >();
	// for(Event e : [select Id, accountId, Who.Name, SalesHD_Complete__c,
	// SalesHD_Call_Objective__c, StartDateTime from event where
	// SalesHD_Sales_Plans__c=:ApexPages.currentPage().getParameters().get('id')
	// and accountId in (Select Account__c from Account_Sales_Plan__c
	// where Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id'))]) {
	// 	if(accountsEvents.containsKey(e.accountId)) {
	// 		accountsEvents.get(e.accountId).add(e);
	// 	} else{
	// 		accountsEvents.put(e.accountId, new List<Event> {e});
	// 	}
	// }

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
		if(accountsStrategies.containsKey(strategy.Account_Sales_Plan__r.Account__c)) {
			accountsStrategies.get(strategy.Account_Sales_Plan__r.Account__c).add(strategy);
		} else{
			accountsStrategies.put(strategy.Account_Sales_Plan__r.Account__c, new List<Account_Strategy__c> {strategy});
		}
	}


	for(Account_Sales_Plan__c acp : [select Account__c, Account__r.Name, Challenges_Critical_Issues__c,
	                                 Due_Date__c, Goal__c, Parent_Sales_Plan__c, Strategy__c from Account_Sales_Plan__c where
	                                 Parent_Sales_Plan__c=:ApexPages.currentPage().getParameters().get('id')]) {
		accountsPlans aps = new accountsPlans(acp);

		// if(accountsEvents.containsKey(acp.Account__c)){
		//     aps.aEvents.addAll(accountsEvents.get(acp.Account__c));
		// }

		if(accountsStrategies.containsKey(acp.Account__c)) {
			// aps.strategies.addAll(accountsStrategies.get(acp.Account__c));
			for(Account_Strategy__c accs : accountsStrategies.get(acp.Account__c)) {
				// aps.strategies.add(accs);
				accountStrategy aStrat = new accountStrategy(accs);
				if(strategyEvents.containsKey(accs.Id)) {
                    aStrat.stratEncounters.addAll(strategyEvents.get(accs.Id));
				}
                // aps.strats.add()
                aps.strats.add(aStrat);
			}
		}

		aPlans.add(aps);
	}


}

public String getAccountMetrics(){
	Date spDate = spDate;
	Date lowDate = Date.newInstance(spDate.Year(), spDate.Month(), 1);
	Date highDate = Date.newInstance(spDate.Year(), spDate.Month(), Date.daysInMonth(spDate.year(), spDate.month()));
	Map<Id, accountMetric> metrics = new Map<Id, accountMetric>();

	for(AccountTeamMember atm : [select AccountId from AccountTeamMember where userId=:spOwner]) {
		metrics.put(atm.AccountId, new accountMetric());
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

	accountMetric totals = new accountMetric();
	totals.accountName = 'Totals';
	totals.cyMtdAdmit = 0;
	totals.pyMtdAdmit = 0;
	for(accountMetric am : metrics.values()) {
		if(am.cyMtdAdmit!=null) totals.cyMtdAdmit += am.cyMtdAdmit;
		if(am.pyMtdAdmit!=null) totals.pyMtdAdmit += am.pyMtdAdmit;

		if(am.cyMtdAdmit!=null && am.pyMtdAdmit!=null) {
			am.mtdVariance = am.cyMtdAdmit-am.pyMtdAdmit;
		}
	}
	totals.mtdVariance = totals.cyMtdAdmit-totals.pyMtdAdmit;

	List<accountMetric> accountMetricList = new List<accountMetric>();
	accountMetricList = metrics.values();
	accountMetricList.add(totals);
	return JSON.serialize(accountMetricList);
	// return JSON.serialize(metrics.values());
}

public PageReference saveAccountPlans(){
	try{
		saveAll();
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+salesPlan.Id);
	// page.setRedirect(true);
	return page;
}

private void saveAll(){
	update salesPlan;
	List<Account_Sales_Plan__c> updateAccountPlans = new List<Account_Sales_Plan__c>();
	List<Account_Strategy__c> updateAccountStrategies = new List<Account_Strategy__c>();
	for(accountsPlans aps : aPlans) {
		updateAccountPlans.add(aps.aPlan);
        // updateAccountStrategies.addAll(aps.strategies);
        for(accountStrategy accs : aps.strats){
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
	// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'message.'));
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

Map<String, String> monthMap = new Map<String, String>{
	'1'=>'January', '2'=>'February', '3'=>'March', '4'=>'April',
	'5'=>'May', '6'=>'June', '7'=>'July', '8'=>'August', '9'=>'September',
	'10'=>'October', '11'=>'November', '12'=>'December'};

public List<Selectoption> getMonthPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select a Month -'));
	for(String monthNum : monthMap.keyset()){
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
	if(newPlanYear!=null && newPlanMonth!=null){
		Date lowPlanDate = Date.newInstance(newPlanYear,newPlanMonth,1);
		Integer numberOfDays = Date.daysInMonth(lowPlanDate.year(), lowPlanDate.month());
		Date highPlanDate = Date.newInstance(newPlanYear,newPlanMonth,numberOfDays);
		List<Sales_Plans__c> plans = [select Id from Sales_Plans__c where OwnerId=:UserInfo.getUserId() and
		SalesHD_Plan_date__c>=:lowPlanDate and SalesHD_Plan_date__c<=:highPlanDate];
		if(plans.isEmpty()){
			Sales_Plans__c sp = new Sales_Plans__c(SalesHD_Plan_Date__c=lowPlanDate);
			insert sp;
			PageReference page = new PageReference('/apex/SalesHD_SalesPlan?id='+sp.Id);
			page.setRedirect(true);
			return page;
		} else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You already have a sales plan saved for '+
			+monthMap.get(String.valueOf(newPlanMonth))+' '+newPlanYear+'.'));
		}
	}
	return null;
}

}


