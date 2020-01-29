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

public String debugstr {get; set;}
public String data {get; set;}

public String dateRange {get; set;}
public static Date lowDate, highDate;

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

public SalesHD_ReportingClass() {
	setWeeks();
	dateRange = lowDate.format() + ' - ' + highDate.format();

	encountersLastWeek = '[]';
	encountersLastWeekAdmin = '';
}

public static void setWeeks(){
	Integer weekOffset = 0;
	if(ApexPages.currentPage().getParameters().get('offset')!=null) {
		weekOffset=Integer.valueOf(ApexPages.currentPage().getParameters().get('offset'));
	}

	lowDate = Date.today().toStartOfWeek().addDays(7*weekOffset);
	highDate = lowDate.addDays(7);
}

public void eLastWeek(){
	encountersLastWeek = JSON.serializePretty(getEncountersLastWeek(UserInfo.getUserRoleId()));
}

public void eLastWeekContact(){
	encountersByContact = JSON.serializePretty(getEncountersContact(UserInfo.getUserRoleId()));
}

public void eLastWeekMedium(){
	encountersByMedium = JSON.serializePretty(getEncountersMedium(UserInfo.getUserRoleId()));
}

public void eLastWeekObjective(){
	encountersByObjective = JSON.serializePretty(getEncountersObjective(UserInfo.getUserRoleId()));
}

public void eLastWeekUnit(){
	encountersByUnit = JSON.serializePretty(getEncountersUnit(UserInfo.getUserRoleId()));
}

public static String getEncountersContact(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	allSubRoleIds.add(rId);

	Map<String, String> contacts = new Map<String, String>();

	List<id> contactIds = new List<id>();
	setWeeks();
	for(event e : [select whoId from event where owner.userRoleId in :allSubRoleIds and startDateTime>=:lowDate and startDateTime<=:highDate]) {
		contactIds.add(e.whoId);
	}

	for(contact c : [select id, title__c from contact where id in :contactIds]) {
		if(c.title__c!=null) contacts.put(c.id, c.title__c);
		else contacts.put(c.id, '-');
	}

	Integer physicianEncounters=0, npEncounters=0, cmEncounters=0, directorEncounters=0, otherEncounters=0;




	Map<String, Integer> contactTitleTotals = new Map<String, Integer>();
	setWeeks();
	for(AggregateResult ar : [select count(id) totalByContact, whoId
	                          from event where owner.userRoleId in :allSubRoleIds and startDateTime>=:lowDate and startDateTime<=:highDate group by whoId]) {

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

public static String getEncountersMedium(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Contact Title","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();
	for(AggregateResult ar : [select count(id) totalByMedium, SalesHD_Contact_Method__c
	                          from event where owner.userRoleId in :allSubRoleIds and startDateTime>=:lowDate and startDateTime<=:highDate group by SalesHD_Contact_Method__c]) {
		Integer totalByMedium = Integer.valueOf(ar.get('totalByMedium'));
		String medium = '-';
		if(ar.get('SalesHD_Contact_Method__c')!=null) medium = String.valueOf(ar.get('SalesHD_Contact_Method__c'));
		res += '{"c":[{"v":"'+medium+'","f":null},{"v":'+totalByMedium+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersObjective(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Objective","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();
	for(AggregateResult ar : [select count(id) totalByObjective, SalesHD_Call_Objective__c
	                          from event where owner.userRoleId in :allSubRoleIds and startDateTime>=:lowDate and startDateTime<=:highDate
	                          group by SalesHD_Call_Objective__c]) {
		Integer totalByObjective = Integer.valueOf(ar.get('totalByObjective'));
		String objective = '-';
		if(ar.get('SalesHD_Call_Objective__c')!=null) objective = String.valueOf(ar.get('SalesHD_Call_Objective__c'));
		res += '{"c":[{"v":"'+objective+'","f":null},{"v":'+totalByObjective+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}


public static String getEncountersUnit(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"Unit","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';

	List<Id> accountUnitIds = new List<Id>();
	setWeeks();
	for(Event e : [select SalesHD_Account_Unit__c from event
	               where owner.userRoleId in :allSubRoleIds and startDateTime>=:lowDate and startDateTime<=:highDate]) {
		accountUnitIds.add(e.SalesHD_Account_Unit__c);
	}

	Map<Id, String> unitNames = new Map<Id, String>();
	for(Account_Unit__c au : [select Id, Unit__r.Name, Account__r.Name from Account_Unit__c where Id in :accountUnitIds]) {
		if(au.Unit__r.Name!='Administrative') unitNames.put(au.Id, au.Account__r.Name+' - '+au.Unit__r.Name);
		else unitNames.put(au.Id, au.Account__r.Name+' - Global / Director');
	}
	setWeeks();
	for(AggregateResult ar : [select count(id) totalByUnit, SalesHD_Account_Unit__c
	                          from event where owner.userRoleId in :allSubRoleIds and startDateTime>=:lowDate and startDateTime<=:highDate
	                          group by SalesHD_Account_Unit__c]) {
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

public static String getEncountersLastWeek(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	allSubRoleIds.add(rId);

	Map<Id, String> roleIdArea = new Map<Id, String>();
	Map<Id, Integer> roleIdUserTotal = new Map<Id, Integer>();
	for(User u : [select area__c, userRoleId from user where area__c!=null and userRoleId in :allSubRoleIds and isActive=true]) {
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
	for(AggregateResult ar : [select owner.userRoleId roleId, count(Id) total from event where
	                          startDateTime>=:lowDate and startDateTime<=:highDate and SalesHD_Account_Unit__c!=null and SalesHD_Complete__c=true
	                                                                                                                                          and ownerId in (select id from user where isActive=true and area__c!=null) and owner.userRoleId in :allSubRoleIds group by owner.userRoleId order by count(Id) desc]) {
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

private static PageReference weekAdjust(Boolean add){
	Integer weekOffset = 0;
	if(ApexPages.currentPage().getParameters().get('offset')!=null) {
		weekOffset=Integer.valueOf(ApexPages.currentPage().getParameters().get('offset'));
	}
	if(add) weekOffset++;
	else weekOffset--;
	PageReference page = new PageReference('/apex/SalesHD_DashboardCL');
	page.getParameters().put('offset', String.valueOf(weekOffset));
	page.setRedirect(true);
	return page;
}

}
