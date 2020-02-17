public without sharing class SalesHD_ReportingClass {


private static Integer targetEncountersPerDay = 2;

private static Id dashboardRunningUserRoleId = null;

private static Set<String> csuiteTitles = new Set<String> {'CCO', 'CEO', 'CFO', 'CMO', 'COO', 'CNO'};

private static Map<String, String> contactTitleBuckets = new Map<String, String> {'Fellow'=>'Physician', 'Hospitalist'=>'Physician',
	                                                                          'Intensivist'=>'Physician', 'Palliative Care Physician'=>'Physician', 'Physician'=>'Physician',
	                                                                          'Physician Assistant'=>'Physician',

	                                                                          'Nurse Practitioner'=>'Nurse Practitioner',

	                                                                          'Case Manager'=>'Case Manager', 'Case Management Manager'=>'Case Management Manager',

	                                                                          'Medical Director of Facility'=>'Director', 'Medical Director of UR'=>'Director', 'Unit Medical Director'=>'Director',
	                                                                          'Director of Business Development'=>'Director', 'Director of Case management'=>'Director', 'Director of Nursing'=>'Director',
	                                                                          'Director of Quality'=>'Director', 'Director of Rehab'=>'Director', 'Director of Respiratory Work'=>'Director', 'Director of Social Work'=>'Director',
	                                                                          'Director of Staff Development'=>'Director', 'Director of Utilization Management'=>'Director', 'Director of Nursing'=>'Director'};


public String encountersLastWeek {get; set;}
public String encountersLastWeekAdmin {get; set;}

public String encounterSummary {get; set;}
public String encounterSummaryAdmin {get; set;}


public String encountersByContact {get; set;}
public String encountersByMedium {get; set;}
public String encountersByObjective {get; set;}
public String encountersByUnit {get; set;}
public String encountersByAccount {get; set;}
public String upcomingEncounters {get; set;}

public String clPerformanceTrend {get; set;}

public string admitsRevenue {get; set;}

public string selectedCL {get; set;}
public string clName {get; set;}


public String debugstr {get; set;}
public String data {get; set;}

public String dateRange {get; set;}
public static Datetime lowDate, highDate;

public class encounterSummary {
public String clName = '';
public String clMarket = '';
public Integer totalEncounters = 0;
public Integer physicianEncounters = 0;
public Integer npEncounters = 0;
public Integer cmEncounters = 0;
public Integer directorEncounters = 0;
public Integer otherEncounters = 0;
}

public class encounterLastWeek {
public String market;
public Integer encounterTotal;
public Integer encounterTarget;
}

private static Set<Id> allSubRoleIds2 = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public SalesHD_ReportingClass() {
	setWeeks();
	dateRange = lowDate.format() + ' - ' + highDate.format();

	encountersLastWeek = '[]';
	encountersLastWeekAdmin = '';

	clName = UserInfo.getName();

	if(ApexPages.currentPage().getParameters().get('cl')!=null) {
		// set<Id> allSubRoleIds;
		// allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});
		// allSubRoleIds.add(UserInfo.getUserRoleId());
		for(User u : [select id, name, userRoleId from User where id=:ApexPages.currentPage().getParameters().get('cl')]) {
			if(allSubRoleIds2.contains(u.userRoleId)){
				selectedCL = u.id;
				clName = u.Name;
			}
		}
	}

}

public List<Selectoption> getAdmitsRevenuePicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- None -'));
	picklist.add(new selectOption('Admissions', 'Admissions'));
	picklist.add(new selectOption('Revenue', 'Revenue'));
	return picklist;
}

public List<Selectoption> getCLPicklist(){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});
	// allSubRoleIds.add(UserInfo.getUserRoleId());

	allSubRoleIds2.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- None -'));
	for(User u : [select id, name from user where userRoleId in :allSubRoleIds2 order by name]) {
		picklist.add(new selectOption(u.id, u.name));
	}
	return picklist;
}

public static void setWeeks(){
	Integer weekOffset = 0;
	if(ApexPages.currentPage().getParameters().get('w')!=null) {
		weekOffset=Integer.valueOf(ApexPages.currentPage().getParameters().get('w'));
	}

	lowDate = Datetime.newInstance(Date.today().toStartOfWeek().addDays(7*weekOffset), Time.newInstance(0, 0, 0, 0));
	highDate = Datetime.newInstance(Date.valueOf(lowDate).addDays(7-1), Time.newInstance(23, 59, 59, 99));
}

// public void eLastWeek(){
// 	encountersLastWeek = JSON.serializePretty(getEncountersLastWeek(UserInfo.getUserRoleId()));
// }

public void eLastWeek(){
	encountersLastWeek = JSON.serializePretty(getEncountersWeek(UserInfo.getUserRoleId()));
}

public void eLastWeekContact(){
	encountersByContact = JSON.serializePretty(getEncountersContact(UserInfo.getUserRoleId(), selectedCL));
}

public void eLastWeekMedium(){
	encountersByMedium = JSON.serializePretty(getEncountersMedium(UserInfo.getUserRoleId(), selectedCL));
}

public void eLastWeekObjective(){
	encountersByObjective = JSON.serializePretty(getEncountersObjective(UserInfo.getUserRoleId(), selectedCL));
}

public void eLastWeekAccounts(){
	encountersByAccount = JSON.serializePretty(getEncountersAccount(UserInfo.getUserRoleId(), selectedCL));
}

public void eUpcoming(){
	upcomingEncounters = JSON.serializePretty(getUpcomingEncounters(UserInfo.getUserRoleId(), selectedCL));
}

public void eLastWeekUnit(){
	encountersByUnit = JSON.serializePretty(getEncountersUnit(UserInfo.getUserRoleId(), selectedCL));
}

public void spTrend(){
	if(admitsRevenue!=null) clPerformanceTrend = getPerformanceTrend(UserInfo.getUserRoleId(), admitsRevenue, selectedCL);
}

public static String getEncountersContact(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	Map<String, String> contacts = new Map<String, String>();

	List<id> contactIds = new List<id>();
	setWeeks();
	for(event e : [select whoId from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate]) {
		contactIds.add(e.whoId);
	}

	for(contact c : [select id, title__c from contact where id in :contactIds]) {
		if(c.title__c!=null) contacts.put(c.id, c.title__c);
		else contacts.put(c.id, '-');
	}

	Integer physicianEncounters=0, npEncounters=0, cmEncounters=0, directorEncounters=0, otherEncounters=0;




	Map<String, Integer> contactTitleTotals = new Map<String, Integer>();
	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select count(id) totalByContact, whoId
		 from event where ownerId=:cl
		 and startDateTime>=:lowDate and startDateTime<=:highDate group by whoId];
	} else{
		ars = [select count(id) totalByContact, whoId
		 from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId())
		 and startDateTime>=:lowDate and startDateTime<=:highDate group by whoId];
	}

		for(AggregateResult ar : ars) {

			Integer totalByContact = Integer.valueOf(ar.get('totalByContact'));
			String contactId = String.valueOf(ar.get('whoId'));

			if(contactTitleTotals.containsKey(contacts.get(contactId))) {
				contactTitleTotals.put(contacts.get(contactId),
				                       contactTitleTotals.get(contacts.get(contactId)) + totalByContact);
			} else {
				contactTitleTotals.put(contacts.get(contactId), totalByContact);
			}

		}

	String res = '{ "cols" : [{"id":"","label":"Contact Title","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	for(String contactTitle : contactTitleTotals.keySet()) {
		res += '{"c":[{"v":"'+contactTitle+'","f":null},{"v":'+contactTitleTotals.get(contactTitle)+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersWeek(Id rId){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// allSubRoleIds.add(rId);
	allSubRoleIds2.add(rId);

	String res = '{ "cols" : [{"id":"","label":"CL","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Complete Encounters","pattern":"","type":"number"}, ' +
	             '{"id":"","label":"Incomplete Encounters","pattern":"","type":"number"}],'+
	             '"rows": [';
	setWeeks();

	//Maps userIds to a list containing complete encounter totals at index 0 and incomplete at index 1
	Map<Id, List<Integer> > usersEncounters = new Map<Id, List<Integer> >();
	Map<Id, String> usernames = new Map<Id, String>();
	for(User u : [select Id, Name from user where UserRoleId in :allSubRoleIds2 or Id=:UserInfo.getUserId() order by Name]) {
		usersEncounters.put(u.Id, new List<Integer> {0,0});
		usernames.put(u.Id, u.Name);
	}

	for(Event e : [select OwnerId, SalesHD_Complete__c
	               from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and
	               startDateTime>=:lowDate and startDateTime<=:highDate]) {
		if(usersEncounters.containsKey(e.OwnerId)) {
			List<Integer> encounterTotals = usersEncounters.get(e.OwnerId);
			if(e.SalesHD_Complete__c==true) encounterTotals[0]++;
			else encounterTotals[1]++;
			usersEncounters.put(e.OwnerId, encounterTotals);
		}
	}

	for(Id userId : usersEncounters.keySet()) {
		res += '{"c":[{"v":"'+usernames.get(userId)+'","f":null},{"v":'+usersEncounters.get(userId)[0]+',"f":null},{"v":'+usersEncounters.get(userId)[1]+',"f":null}] },';
	}

	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersMedium(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);
	

	String res = '{ "cols" : [{"id":"","label":"Contact Title","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();


	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select count(id) totalByMedium, SalesHD_Contact_Method__c
		from event where ownerId=:cl
		and startDateTime>=:lowDate and startDateTime<=:highDate group by SalesHD_Contact_Method__c];
	} else{
		ars = [select count(id) totalByMedium, SalesHD_Contact_Method__c
		from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId())
		and startDateTime>=:lowDate and startDateTime<=:highDate group by SalesHD_Contact_Method__c];
	}

	for(AggregateResult ar : ars) {
		Integer totalByMedium = Integer.valueOf(ar.get('totalByMedium'));
		String medium = '-';
		if(ar.get('SalesHD_Contact_Method__c')!=null) medium = String.valueOf(ar.get('SalesHD_Contact_Method__c'));
		res += '{"c":[{"v":"'+medium+'","f":null},{"v":'+totalByMedium+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersObjective(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Objective","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select count(id) totalByObjective, SalesHD_Call_Objective__c
		from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		group by SalesHD_Call_Objective__c];
	} else{
		ars = [select count(id) totalByObjective, SalesHD_Call_Objective__c
		from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate
		group by SalesHD_Call_Objective__c];
	}

	for(AggregateResult ar : ars) {
		Integer totalByObjective = Integer.valueOf(ar.get('totalByObjective'));
		String objective = '-';
		if(ar.get('SalesHD_Call_Objective__c')!=null) objective = String.valueOf(ar.get('SalesHD_Call_Objective__c'));
		res += '{"c":[{"v":"'+objective+'","f":null},{"v":'+totalByObjective+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getPerformanceTrend(Id rId, String admitsRevenue, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Month","pattern":"","type":"date"}, ' +
	             '{"id":"","label":"Actual","pattern":"","type":"number"}, ' +
	             '{"id":"","label":"Target","pattern":"","type":"number"}],'+
	             '"rows": [';
	setWeeks();

	List<Sales_Performance__c> sps = new List<Sales_Performance__c>();
	if(cl!=null){
		sps = [select Month__c, Actual_Admissions__c, Targeted_Admissions__c,
		Actual_Revenue__c, Targeted_Revenue__c from Sales_Performance__c where ownerId=:cl
		and Month__c=Last_N_Months:12 order by Month__c];
	}
	else{
		sps = [select Month__c, Actual_Admissions__c, Targeted_Admissions__c,
		Actual_Revenue__c, Targeted_Revenue__c from Sales_Performance__c where ownerId=:UserInfo.getUserId()
		and Month__c=Last_N_Months:12 order by Month__c];
	}

	for(Sales_Performance__c sp : sps) {
		Integer admitActual=0, admitTarget=0, revenueActual=0, revenueTarget=0;
		if(sp.Actual_Admissions__c!=null) admitActual=Integer.valueOf(sp.Actual_Admissions__c);
		if(sp.Targeted_Admissions__c!=null) admitTarget=Integer.valueOf(sp.Targeted_Admissions__c);
		if(sp.Actual_Revenue__c!=null) revenueActual=Integer.valueOf(sp.Actual_Revenue__c);
		if(sp.Targeted_Revenue__c!=null) revenueTarget=Integer.valueOf(sp.Targeted_Revenue__c);
		String month = '';
		if(sp.Month__c!=null) {
			month = 'Date('+sp.Month__c.year()+
			        ', '+sp.Month__c.month()+')';
		}
		if(admitsRevenue=='Admissions') res += '{"c":[{"v":"'+month+'","f":null},{"v":'+admitActual+',"f":null},{"v":'+admitTarget+',"f":null}] },';
		if(admitsRevenue=='Revenue') res += '{"c":[{"v":"'+month+'","f":null},{"v":'+revenueActual+',"f":null},{"v":'+revenueTarget+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersAccount(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Account","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select count(id) totalEncounters, Account.Name accountName
		from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		group by Account.Name];
	} else{
		ars = [select count(id) totalEncounters, Account.Name accountName
		from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate
		group by Account.Name];
	}

	for(AggregateResult ar : ars) {
		Integer totalEncounters = Integer.valueOf(ar.get('totalEncounters'));
		String accountName = '-';
		if(ar.get('accountName')!=null) accountName = String.valueOf(ar.get('accountName'));
		res += '{"c":[{"v":"'+accountName+'","f":null},{"v":'+totalEncounters+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getUpcomingEncounters(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"CL","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();

	lowDate = Date.valueOf(System.now());
	highDate = Date.valueOf(lowDate).addDays(30);
	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select count(id) totalEncounters, Owner.Name ownerName
		from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		group by Owner.Name];
	} else{
		ars = [select count(id) totalEncounters, Owner.Name ownerName
		from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate
		group by Owner.Name];
	}

	for(AggregateResult ar : ars) {
		Integer totalEncounters = Integer.valueOf(ar.get('totalEncounters'));
		String ownerName = '-';
		if(ar.get('ownerName')!=null) ownerName = String.valueOf(ar.get('ownerName'));
		res += '{"c":[{"v":"'+ownerName+'","f":null},{"v":'+totalEncounters+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}


public static String getEncountersUnit(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Unit","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';

	List<Id> accountUnitIds = new List<Id>();
	setWeeks();
	for(Event e : [select SalesHD_Account_Unit__c from event
	               where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate]) {
		accountUnitIds.add(e.SalesHD_Account_Unit__c);
	}

	Map<Id, String> unitNames = new Map<Id, String>();
	for(Account_Unit__c au : [select Id, Unit__r.Name, Account__r.Name from Account_Unit__c where Id in :accountUnitIds]) {
		if(au.Unit__r.Name!='Administrative') unitNames.put(au.Id, au.Account__r.Name+' - '+au.Unit__r.Name);
		else unitNames.put(au.Id, au.Account__r.Name+' - Global / Director');
	}
	// setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select count(id) totalByUnit, SalesHD_Account_Unit__c
		from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		group by SalesHD_Account_Unit__c];
	} else{
		ars = [select count(id) totalByUnit, SalesHD_Account_Unit__c
		from event where (owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate
		group by SalesHD_Account_Unit__c];
	}

	for(AggregateResult ar : ars) {
		Integer totalByUnit = Integer.valueOf(ar.get('totalByUnit'));
		String unit = '-';
		if(ar.get('SalesHD_Account_Unit__c')!=null &&
		   unitNames.containsKey(String.valueOf(ar.get('SalesHD_Account_Unit__c'))))
			unit = String.valueOf(unitNames.get(String.valueOf(ar.get('SalesHD_Account_Unit__c'))));

		res += '{"c":[{"v":"'+unit+'","f":null},{"v":'+totalByUnit+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersLastWeek(Id rId, Id cl){
	// set<Id> allSubRoleIds;
	// allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	// // allSubRoleIds.add(rId);

	Map<Id, String> roleIdArea = new Map<Id, String>();
	Map<Id, Integer> roleIdUserTotal = new Map<Id, Integer>();
	for(User u : [select area__c, userRoleId from user where area__c!=null and userRoleId in :allSubRoleIds2 and isActive=true]) {
		if(!roleIdArea.containsKey(u.userRoleId)) {
			roleIdArea.put(u.userRoleId, u.area__c);
			roleIdUserTotal.put(u.userRoleId, 1);
		} else{
			roleIdUserTotal.put(u.userRoleId, roleIdUserTotal.get(u.userRoleId)+1);
		}
	}

	List<encounterLastWeek> result = new List<encounterLastWeek>();
	List<List<String> > result2 = new List<List<String> >();
	result2.add(new List<String> {'Market', 'Total Encounters', 'Targeted Encounters'});
	String res = '{ "cols" : [{"id":"","label":"Market","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}, ' +
	             '{"id":"","label":"Targeted Encounters","pattern":"","type":"number"}],'+
	             '"rows": [';

	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null){
		ars = [select owner.userRoleId roleId, count(Id) total from event where
		startDateTime>=:lowDate and startDateTime<=:highDate and SalesHD_Account_Unit__c!=null and SalesHD_Complete__c=true
		and ownerId in (select id from user where isActive=true and area__c!=null) and
		ownerId=:cl group by owner.userRoleId order by count(Id) desc];
	} else{
		ars = [select owner.userRoleId roleId, count(Id) total from event where
		startDateTime>=:lowDate and startDateTime<=:highDate and SalesHD_Account_Unit__c!=null and SalesHD_Complete__c=true
		and ownerId in (select id from user where isActive=true and area__c!=null) and
		(owner.userRoleId in :allSubRoleIds2 or ownerId=:UserInfo.getUserId()) group by owner.userRoleId order by count(Id) desc];
	}

	for(AggregateResult ar : ars) {
		encounterLastWeek temp = new encounterLastWeek();
		String market = '';
		Id roleId = String.valueOf(ar.get('roleId'));
		if(roleIdArea.containsKey(roleId)) market = roleIdArea.get(roleId);
		Integer target;
		if(roleIdUserTotal.containsKey(roleId)) target = roleIdUserTotal.get(roleId) * 5 * targetEncountersPerDay;
		temp.market = market; temp.encounterTotal = Integer.valueOf(ar.get('total')); temp.encounterTarget = target;
		result.add(temp);
		result2.add(new List<String> {market, String.valueOf(ar.get('total')), String.valueOf(target)});
		res += '{"c":[{"v":"'+market+'","f":null},{"v":'+Integer.valueOf(ar.get('total'))+',"f":null},{"v":'+target+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
	// return result2;
}

private static set<Id> getSubRoleIds(set<Id> roleIds) {
	set<Id> returnRoleIds = new set<Id>();
	for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
		returnRoleIds.add(r.Id);
	}
	if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
	return returnRoleIds;
}

public PageReference nextWeek(){
	return weekAdjust(true);
}

public PageReference previousWeek(){
	return weekAdjust(false);
}

public PageReference selectCL(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().put('cl', String.valueOf(selectedCL));
	page.setRedirect(true);
	return page;
}


private static PageReference weekAdjust(Boolean add){
	Integer weekOffset = 0;
	if(ApexPages.currentPage().getParameters().get('w')!=null) {
		weekOffset=Integer.valueOf(ApexPages.currentPage().getParameters().get('w'));
	}
	if(add) weekOffset++;
	else weekOffset--;
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().put('w', String.valueOf(weekOffset));
	page.setRedirect(true);
	return page;
}

}
