public without sharing class SalesHD_ReportingClass {


private static Integer targetEncountersPerDay = 2;

private static Id dashboardRunningUserRoleId = null;

private static Set<String> csuiteTitles = new Set<String> {'CCO', 'CEO', 'CFO', 'CMO', 'COO', 'CNO'};

private static Map<String, String> unitBuckets = new Map<String, String> {
	'INTENSIVE CARE UNIT' => 'ICU',
	'ICU - CARDIAC' => 'ICU',
	'ICU - SURGICAL' => 'ICU',
	'ICU - NEURO' => 'ICU',
	'ICU - CV SURGERY' => 'ICU',
	'ICU - TRANSPLANT' => 'ICU',
	'ICU - BURN' => 'ICU',
	'ICU - TRAUMA' => 'ICU',

	'SDU - CARDIAC' => 'SDU',
	'SDU - SURGICAL' => 'SDU',
	'SDU - VENT/PULMONARY' => 'SDU',
	'STEP-DOWN' => 'SDU',

	'MED-SURG' => 'M/S',

	'Administrative' => 'Global/Director',

	'OTHER' => 'Other',
	'EMERGENCY ROOM' => 'Other',
	'REHAB UNIT' => 'Other',
	'SKILLED NURSING UNIT' => 'Other',
	'HOME' => 'Other',
	'PHYSICIAN OFFICE' => 'Other',
	'SKILLED NURSING FAC' => 'Other',
	'EMERGENCY DEPARTMENT' => 'Other',
	'OUTPATIENT CLINIC' => 'Other',
	'HOME WITH HH' => 'Other',
	'OBSERVATION' => 'Other',
	'CARDIAC CARE UNIT' => 'Other'
};

private static Map<String, String> contactTitleBuckets = new Map<String, String> {
	'Physician - Intensivist/Critical Care' => 'Physician',
	'Physician - Specialty' => 'Physician',
	'Physician - Hospitalist/Internal Med' => 'Physician',
	'Fellow' => 'Physician',
	'Resident' => 'Physician',
	'Nurse Manager' => 'Allied Health Professionals/Direct Care Practitioner',
	'Nurse Supervisor' => 'Allied Health Professionals/Direct Care Practitioner',
	'Nurse ' => 'Allied Health Professionals/Direct Care Practitioner',
	'Respiratory Therapist' => 'Allied Health Professionals/Direct Care Practitioner',
	'Physical Therapist' => 'Allied Health Professionals/Direct Care Practitioner',
	'Speech Therapist' => 'Allied Health Professionals/Direct Care Practitioner',
	'Occupational Therapist' => 'Allied Health Professionals/Direct Care Practitioner',
	'Physician Assistant' => 'Allied Health Professionals/Direct Care Practitioner',
	'Nurse Practitioner' => 'Allied Health Professionals/Direct Care Practitioner',
	'COO' => 'C-suite/Administrative',
	'CCO' => 'C-suite/Administrative',
	'CMO' => 'C-suite/Administrative',
	'CEO' => 'C-suite/Administrative',
	'CFO' => 'C-suite/Administrative',
	'CNO' => 'C-suite/Administrative',
	'Director of Business Development' => 'Director/Administrative',
	'Director of Case Management' => 'Director/Administrative',
	'Director of Social Work' => 'Director/Administrative',
	'Director of Rehabilitation' => 'Director/Administrative',
	'Director of Respiratory Therapy' => 'Director/Administrative',
	'Director of Utilization Review' => 'Director/Administrative',
	'Director of ACO/PPN' => 'Director/Administrative',
	'Unit Director' => 'Director/Administrative',
	'Physician Advisor' => 'Director/Administrative',
	'Nurse Navigator' => 'Other',
	'Consultant' => 'Other',
	'Case Manager' => 'Other',
	'Social Worker' => 'Other',
	'Utilization Review Nurse' => 'Other',
	'Wound Care Coordinator' => 'Other',
	'Educator' => 'Other',
	'Case Management Manager' => 'Other',
	'Social Work Manager' => 'Other',
	'Medical Director' => 'Managed Care',
	'Director of Utilization Management' => 'Managed Care',
	'Director of Case Management' => 'Managed Care',
	'Director of Quality Improvement' => 'Managed Care',
	'Director of Network Development/Contracting' => 'Managed Care',
	'Post Acute Care UM Review' => 'Managed Care',
	'Insurance Nurse' => 'Managed Care'
};


public String encountersLastWeek {get; set;}
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

public string selectedAccount {get; set;}

public SalesHD_KPI__c kpi {get; set;}
public SalesHD_KPI__c highKpi {get; set;}
public SalesHD_KPI__c middleKpi {get; set;}
public SalesHD_KPI__c lowKpi {get; set;}
public List<String> kpiColors {get; set;}

public String dateRange {get; set;}
public static Datetime lowDate, highDate;

public class encounterLastWeek {
public String market;
public Integer encounterTotal;
public Integer encounterTarget;
}

public String district = '%%';
public String area = '%%';

public List<User> users {get; set;}

private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public User usr {get; set;}

public SalesHD_ReportingClass() {

	users = new List<User>();
	
	usr = new User();
	usr.Region__c='HD';
	if(ApexPages.currentPage().getParameters().get('district')!=null) usr.District__c=ApexPages.currentPage().getParameters().get('district');
	if(ApexPages.currentPage().getParameters().get('area')!=null) usr.Area__c=ApexPages.currentPage().getParameters().get('area');
	if(usr.District__c!=null) district = '%'+usr.District__c+'%';
	if(usr.Area__c!=null) area = '%'+usr.Area__c+'%';

	setWeeks();
	dateRange = lowDate.format() + ' - ' + highDate.format();

	clName = UserInfo.getName();

	kpiColors = new List<String> {'', '', '', '', '', '', '', '', '', ''};

	if(ApexPages.currentPage().getParameters().get('cl')!=null) {

		for(User u : [select id, name, userRoleId, Region__c, Area__c, District__c from User where id=:ApexPages.currentPage().getParameters().get('cl')]) {
			if(allSubRoleIds.contains(u.userRoleId) || u.Id==UserInfo.getUserId()) {
				selectedCL = u.id;
				clName = u.Name;
				if(u.Region__c!=null) usr.Region__c = u.Region__c;
				if(u.District__c!=null) usr.District__c = u.District__c;
				if(u.Area__c!=null) usr.Area__c = u.Area__c;
			}
		}
	} else{
		allSubRoleIds.add(UserInfo.getUserRoleId());
		users = [select id from user where (userRoleId in :allSubRoleIds or Id=:UserInfo.getUserId()) 
		and Area__c like :area and
		District__c like :district];
	}

	if(selectedCL!=null) getKpi(selectedCL);
	else getKpi(UserInfo.getUserId());

	if(ApexPages.currentPage().getParameters().get('account')!=null) {
		selectedAccount = ApexPages.currentPage().getParameters().get('account');
	}

}

public void getKpi(Id clId){
	// SalesHD_KPI__c highKpi, middleKpi, lowKpi;
	for(SalesHD_KPI__c kpis : [select CL__r.Name,Admit_Lag_Time__c,
	                           Admits_Per_Day__c, Batting_Average__c, CMI__c, Conversion_Percentage__c, Encounters_Per_Day_Quarter__c,
	                           Encounters_Per_Day_Month__c, ICU_Referral_Percentage__c,  Referral_Lag_Time__c,
	                           Referrals_Per_Day__c, RecordType.Name from SalesHD_KPI__c where (CL__c=:clId or
	                        	RecordType.Name='KPI High Baseline' or RecordType.Name='KPI Middle Baseline' or RecordType.Name='KPI Low Baseline') and KPI_Date__C=this_quarter]) {
		if(kpis.RecordType.Name=='KPI High Baseline') highKpi = kpis;
		else if(kpis.RecordType.Name=='KPI Middle Baseline') middleKpi = kpis;
		else if(kpis.RecordType.Name=='KPI Low Baseline') lowKpi = kpis;
		else if(kpis.CL__c==clId) kpi = kpis;
	}

	if(kpi!=null && highKpi!=null && middleKpi!=null && lowKpi!=null) {
			kpiColors[0] = kpiColor(kpi.Referrals_Per_Day__c, highKpi.Referrals_Per_Day__c, middleKpi.Referrals_Per_Day__c, lowKpi.Referrals_Per_Day__c);
			kpiColors[1] = kpiColor(kpi.Admits_Per_Day__c, highKpi.Admits_Per_Day__c, middleKpi.Admits_Per_Day__c, lowKpi.Admits_Per_Day__c);
			kpiColors[2] = kpiColor(kpi.Batting_Average__c, highKpi.Batting_Average__c, middleKpi.Batting_Average__c, lowKpi.Batting_Average__c);
			kpiColors[3] = kpiColor(kpi.CMI__c, highKpi.CMI__c, middleKpi.CMI__c, lowKpi.CMI__c);
			kpiColors[4] = kpiColorLowerIsBetter(kpi.Referral_Lag_Time__c, highKpi.Referral_Lag_Time__c, middleKpi.Referral_Lag_Time__c, lowKpi.Referral_Lag_Time__c);
			kpiColors[5] = kpiColorLowerIsBetter(kpi.Admit_Lag_Time__c, highKpi.Admit_Lag_Time__c, middleKpi.Admit_Lag_Time__c, lowKpi.Admit_Lag_Time__c);
			kpiColors[6] = kpiColor(kpi.Conversion_Percentage__c, highKpi.Conversion_Percentage__c, middleKpi.Conversion_Percentage__c, lowKpi.Conversion_Percentage__c);
			kpiColors[7] = kpiColor(kpi.ICU_Referral_Percentage__c, highKpi.ICU_Referral_Percentage__c, middleKpi.ICU_Referral_Percentage__c, lowKpi.ICU_Referral_Percentage__c);
			kpiColors[8] = kpiColor(kpi.Encounters_Per_Day_Month__c, highKpi.Encounters_Per_Day_Month__c, middleKpi.Encounters_Per_Day_Month__c, lowKpi.Encounters_Per_Day_Month__c);
			kpiColors[9] = kpiColor(kpi.Encounters_Per_Day_Quarter__c, highKpi.Encounters_Per_Day_Quarter__c, middleKpi.Encounters_Per_Day_Quarter__c, lowKpi.Encounters_Per_Day_Quarter__c);					
	}
}

public static string kpiColor(Decimal clValue, Decimal highValue, Decimal middleValue, Decimal lowValue ){
	if(clValue!=null && highValue!=null && middleValue!=null && lowValue!=null) {
		if(clValue>highValue) return 'bg-primary';
		else if(clValue<=highValue && clValue>middleValue) return 'bg-success';
		else if(clValue<=middleValue && clValue>lowValue) return 'bg-warning';
		else if(clValue<=lowValue) return 'bg-danger';
		else return '';
	} else return '';

}

public static string kpiColorLowerIsBetter(Decimal clValue, Decimal highValue, Decimal middleValue, Decimal lowValue ){
	if(clValue!=null && highValue!=null && middleValue!=null && lowValue!=null) {
		if(clValue<highValue) return 'bg-primary';
		else if(clValue>=highValue && clValue<middleValue) return 'bg-success';
		else if(clValue>=middleValue && clValue<lowValue) return 'bg-warning';
		else if(clValue>=lowValue) return 'bg-danger';
		else return '';
	} else return '';

}

public List<Selectoption> getAdmitsRevenuePicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Admissions or Revenue -'));
	picklist.add(new selectOption('Admissions', 'Admissions'));
	picklist.add(new selectOption('Revenue', 'Revenue'));
	return picklist;
}

public List<Selectoption> getCLPicklist(){

	allSubRoleIds.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Employee -'));
	for(User u : [select id, name from user where userRoleId in :allSubRoleIds and
	District__c like :district and Area__c like :area order by name]) {
		picklist.add(new selectOption(u.id, u.name));
	}
	return picklist;
}

public List<Selectoption> getAccountPicklist(){

	allSubRoleIds.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Account -'));
	// for(AggregateResult ar : [select accountId, account.name name from AccountTeamMember where
	// (user.userRoleId in :allSubRoleIds or userId=:UserInfo.getUserId()) group by accountId, account.name order by account.name]) {
	// 	picklist.add(new selectOption(String.valueOf(ar.get('accountId')), String.valueOf(ar.get('name'))));
	// }

	Set<Id> atms = new Set<Id>();

	for(AccountTeamMember atm : [select accountId, account.name from AccountTeamMember where
	                             userId=:UserInfo.getUserId() order by account.name limit 999]) {
		if(!atms.contains(atm.accountId) && picklist.size()<999)
			picklist.add(new selectOption(atm.accountId, atm.account.name));
		atms.add(atm.accountId);
	}

	for(AccountTeamMember atm : [select accountId, account.name from AccountTeamMember where
								 user.userRoleId in :allSubRoleIds and userId in :users
								 and accountId not in:atms order by account.name limit 999]) {
		if(!atms.contains(atm.accountId) && picklist.size()<999)
			picklist.add(new selectOption(atm.accountId, atm.account.name));
		atms.add(atm.accountId);
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

public void eLastWeek(){
	encountersLastWeek = JSON.serializePretty(getEncountersWeek(UserInfo.getUserRoleId(), selectedCL, users));
}

public void eLastWeekContact(){
	encountersByContact = JSON.serializePretty(getEncountersContact(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eLastWeekMedium(){
	encountersByMedium = JSON.serializePretty(getEncountersMedium(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eLastWeekObjective(){
	encountersByObjective = JSON.serializePretty(getEncountersObjective(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eLastWeekAccounts(){
	encountersByAccount = JSON.serializePretty(getEncountersAccount(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eUpcoming(){
	upcomingEncounters = JSON.serializePretty(getUpcomingEncounters(UserInfo.getUserRoleId(), selectedCL, users));
}

public void eLastWeekUnit(){
	encountersByUnit = JSON.serializePretty(getEncountersUnit(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void spTrend(){
	if(admitsRevenue!=null) clPerformanceTrend = getPerformanceTrend(UserInfo.getUserRoleId(), admitsRevenue, selectedCL);
}

public static String getEncountersContact(Id rId, Id cl, Id accountId, List<User> usrs){

	Map<String, String> contacts = new Map<String, String>();

	List<id> contactIds = new List<id>();
	setWeeks();
	for(event e : [select whoId from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate]) {
		contactIds.add(e.whoId);
	}

	for(contact c : [select id, title__c from contact where id in :contactIds]) {
		if(c.title__c!=null) contacts.put(c.id, c.title__c);
		else contacts.put(c.id, '-');
	}

	Integer physicianEncounters=0, npEncounters=0, cmEncounters=0, directorEncounters=0, otherEncounters=0;





	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	
	if(cl!=null) {
		ars = [select count(id) totalByContact, whoId
		       from event where ownerId=:cl
		                                 and startDateTime>=:lowDate and startDateTime<=:highDate group by whoId];
	} else if(accountId!=null) {
		ars = [select count(id) totalByContact, whoId
			   from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId group by whoId];
	} else{
		ars = [select count(id) totalByContact, whoId
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs  
			   and startDateTime>=:lowDate and startDateTime<=:highDate group by whoId];
	}


	Map<String, Integer> contactTitleTotals = new Map<String, Integer>();
	for(AggregateResult ar : ars) {

		Integer totalByContact = Integer.valueOf(ar.get('totalByContact'));
		String contactId = String.valueOf(ar.get('whoId'));
		String title;
		if(contactTitleBuckets.containsKey(contacts.get(contactId)))
			title = contactTitleBuckets.get(contacts.get(contactId));
		else title = 'Other';

		if(contactTitleTotals.containsKey(title)) {
			contactTitleTotals.put(title,
			                       contactTitleTotals.get(title) + totalByContact);
		} else {
			contactTitleTotals.put(title, totalByContact);
		}

	}

	String res = '{ "cols" : [{"id":"","label":"Contact Category","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	for(String contactTitle : contactTitleTotals.keySet()) {
		res += '{"c":[{"v":"'+contactTitle+'","f":null},{"v":'+contactTitleTotals.get(contactTitle)+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersWeek(Id rId, Id cl, List<User> usrs){

	allSubRoleIds.add(rId);

	String res = '{ "cols" : [{"id":"","label":"CL","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Planned Encounters","pattern":"","type":"number"}, ' +
	             '{"id":"","label":"Unplanned Encounters","pattern":"","type":"number"}],'+
	             '"rows": [';
	setWeeks();

	//Maps userIds to a list containing complete encounter totals at index 0 and incomplete at index 1
	Map<Id, List<Integer> > usersEncounters = new Map<Id, List<Integer> >();
	Map<Id, String> usernames = new Map<Id, String>();
	for(User u : [select Id, Name from user where (UserRoleId in :allSubRoleIds or Id=:UserInfo.getUserId())
	and (Id=:cl or Id in :usrs) order by Name]) {
		usersEncounters.put(u.Id, new List<Integer> {0,0});
		usernames.put(u.Id, u.Name);
	}

	for(AggregateResult ar : [select OwnerId, saleshd_planned_encounter__c plannedUnplanned, count(id) total
	                          from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId()) and
	                          startDateTime>=:lowDate and startDateTime<=:highDate group by OwnerId, saleshd_planned_encounter__c]) {
		if(usersEncounters.containsKey(String.valueOf(ar.get('OwnerId')))) {
			List<Integer> encounterTotals = usersEncounters.get(String.valueOf(ar.get('OwnerId')));
			if(ar.get('plannedUnplanned')==true) encounterTotals[0] = Integer.valueOf(ar.get('total'));
			else encounterTotals[1] = Integer.valueOf(ar.get('total'));
			usersEncounters.put(String.valueOf(ar.get('OwnerId')), encounterTotals);
		}
	}

	for(Id userId : usersEncounters.keySet()) {
		res += '{"c":[{"v":"'+usernames.get(userId)+'","f":null},{"v":'+usersEncounters.get(userId)[0]+',"f":null},{"v":'+usersEncounters.get(userId)[1]+',"f":null}] },';
	}

	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersMedium(Id rId, Id cl, Id accountId, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"Contact Title","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();


	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalByMedium, SalesHD_Contact_Method__c
		       from event where ownerId=:cl
		                                 and startDateTime>=:lowDate and startDateTime<=:highDate group by SalesHD_Contact_Method__c];
	} else if(accountId!=null) {
		ars = [select count(id) totalByMedium, SalesHD_Contact_Method__c
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
				and ownerId in :usrs  
			   and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId group by SalesHD_Contact_Method__c];
	} else{
		ars = [select count(id) totalByMedium, SalesHD_Contact_Method__c
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
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

public static String getEncountersObjective(Id rId, Id cl, Id accountId, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"Objective","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalByObjective, SalesHD_Call_Objective__c
		       from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		                                 group by SalesHD_Call_Objective__c];
	} else if(accountId!=null) {
		ars = [select count(id) totalByObjective, SalesHD_Call_Objective__c
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			 	and ownerId in :usrs  
			   and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId
		                                                                               group by SalesHD_Call_Objective__c];
	} else{
		ars = [select count(id) totalByObjective, SalesHD_Call_Objective__c
			   from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
			   and startDateTime>=:lowDate and startDateTime<=:highDate
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

	String res = '{ "cols" : [{"id":"","label":"Month","pattern":"","type":"date"}, ' +
	             '{"id":"","label":"Actual","pattern":"","type":"number"}, ' +
	             '{"id":"","label":"Target","pattern":"","type":"number"}],'+
	             '"rows": [';
	setWeeks();

	List<Sales_Performance__c> sps = new List<Sales_Performance__c>();
	if(cl!=null) {
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

public static String getEncountersAccount(Id rId, Id cl, Id accountId, List<User> usrs){
	String res = '{ "cols" : [{"id":"","label":"Account","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalEncounters, Account.Name accountName
		       from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		                                 group by Account.Name];
	} else if(accountId!=null) {
		ars = [select count(id) totalEncounters, Account.Name accountName
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
			   and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId
		                                                                               group by Account.Name];
	} else{
		ars = [select count(id) totalEncounters, Account.Name accountName
			   from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
			   and startDateTime>=:lowDate and startDateTime<=:highDate
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

public static String getUpcomingEncounters(Id rId, Id cl, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"CL","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	setWeeks();

	lowDate = Date.valueOf(System.now());
	highDate = Date.valueOf(lowDate).addDays(30);
	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalEncounters, Owner.Name ownerName
		       from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		                                 group by Owner.Name];
	} else{
		ars = [select count(id) totalEncounters, Owner.Name ownerName
			   from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
			   and startDateTime>=:lowDate and startDateTime<=:highDate
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


public static String getEncountersUnit(Id rId, Id cl, Id accountId, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"Unit","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';

	List<Id> accountUnitIds = new List<Id>();
	setWeeks();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalByUnit, SalesHD_Account_Unit__r.Unit__r.Name unit
		       from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		                                 group by SalesHD_Account_Unit__r.Unit__r.Name];
	} else if(accountId!=null) {
		ars = [select count(id) totalByUnit, SalesHD_Account_Unit__r.Unit__r.Name unit
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
			   and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId
		                                                                               group by SalesHD_Account_Unit__r.Unit__r.Name];
	} else{
		ars = [select count(id) totalByUnit, SalesHD_Account_Unit__r.Unit__r.Name unit
			   from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
			   and ownerId in :usrs    
			   and startDateTime>=:lowDate and startDateTime<=:highDate
		       group by SalesHD_Account_Unit__r.Unit__r.Name];
	}

	Map<String, Integer> unitGroupTotals = new Map<String, Integer>();
	for(AggregateResult ar : ars) {
		Integer totalByUnit = Integer.valueOf(ar.get('totalByUnit'));
		String unit = '-';
		if(ar.get('unit')!=null ) {
			if(unitBuckets.containsKey(String.valueOf(ar.get('unit'))))
				unit = unitBuckets.get(String.valueOf(ar.get('unit')));
			else
				unit = String.valueOf(ar.get('unit'));

			if(unitGroupTotals.containsKey(unit)) unitGroupTotals.put(unit, unitGroupTotals.get(unit)+totalByUnit);
			else unitGroupTotals.put(unit, totalByUnit);
		}
	}
	for(String unit : unitGroupTotals.keySet()) {
		res += '{"c":[{"v":"'+unit+'","f":null},{"v":'+unitGroupTotals.get(unit)+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
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
	page.getParameters().remove('account');
	page.getParameters().put('cl', String.valueOf(selectedCL));
	page.setRedirect(true);
	return page;
}

public PageReference selectAccount(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().remove('cl');
	page.getParameters().put('account', String.valueOf(selectedAccount));
	page.setRedirect(true);
	return page;
}

public PageReference selectDistrict(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().remove('cl');
	page.getParameters().remove('account');
	page.getParameters().remove('area');
	page.getParameters().put('district', String.valueOf(usr.District__c));
	page.setRedirect(true);
	return page;
}

public PageReference selectArea(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().remove('cl');
	page.getParameters().remove('account');
	page.getParameters().put('area', String.valueOf(usr.Area__c));
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
