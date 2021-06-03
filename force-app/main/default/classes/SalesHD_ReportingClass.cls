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
	'ICU - MEDICAL' => 'ICU',

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
public String encountersByPurpose {get; set;}
public String encountersByType {get; set;}
public String encountersByPayorType {get; set;}
public String encountersByObjective {get; set;}
public String encountersByUnit {get; set;}
public String encountersByAccount {get; set;}
public String encountersByUsers {get; set;}
public String encountersByAccount20 {get; set;}
public String encountersByPayorParent10 {get; set;}
public String encountersByMCO {get; set;}
public String encountersByAccountUpcoming {get; set;}
public String encountersByPayorParentUpcoming {get; set;}
public String upcomingEncounters {get; set;}

public String clPerformanceTrend {get; set;}

public string admitsRevenue {get; set;}

public string selectedCL {get; set;}
public string clName {get; set;}

public string selectedAccount {get; set;}

public SalesHD_KPI__c kpi {get; set;}
public SalesHD_KPI__c kpi_previous {get; set;}
public SalesHD_KPI__c highKpi {get; set;}
public SalesHD_KPI__c middleKpi {get; set;}
public SalesHD_KPI__c lowKpi {get; set;}
public List<String> kpiColors {get; set;}

public k_kpi k_kpi {get; set;}
public k_kpi k_kpi_previous {get; set;}
public class k_kpi {
public SalesHD_KPI__c kpi {get; set;}
public String kpiDate {get; set;}
public List<String> kpiColors {get; set;}
public k_kpi(SalesHD_KPI__c kpi){
	this.kpi = kpi;
	kpiColors = new List<String> {'', '', '', '', '', '', '', '', ''};
}
}

public String dateRange {get; set;}
public static Datetime lowDate, highDate;

public class encounterLastWeek {
public String market;
public Integer encounterTotal;
public Integer encounterTarget;
}

public String district = '%%';
public String area = '%%';
public String userType {get; set;}

public List<User> users {get; set;}

private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public User usr {get; set;}

// Map<String, Integer> contactMethod = new Map<String, Integer>();

public SalesHD_ReportingClass() {

	users = new List<User>();

	usr = new User();
	usr.Region__c='HD';
	if(ApexPages.currentPage().getParameters().get('district')!=null) usr.District__c=ApexPages.currentPage().getParameters().get('district');
	if(ApexPages.currentPage().getParameters().get('area')!=null) usr.Area__c=ApexPages.currentPage().getParameters().get('area');
	if(ApexPages.currentPage().getParameters().get('user_type')!=null) userType=ApexPages.currentPage().getParameters().get('user_type');
	if(usr.District__c!=null) district = '%'+usr.District__c+'%';
	if(usr.Area__c!=null) area = '%'+usr.Area__c+'%';
	// if(usr.ProfileId!=null) userType = usr.ProfileId;

	// setWeeks();
	setDates();

	dateRange = lowDate.format() + ' - ' + highDate.format();

	clName = UserInfo.getName();

	kpiColors = new List<String> {'', '', '', '', '', '', '', '', '', '', ''};

	if(ApexPages.currentPage().getParameters().get('mco_state')!=null){
		selectedMCOState = ApexPages.currentPage().getParameters().get('mco_state');
	}
	if(ApexPages.currentPage().getParameters().get('cl')!=null) {

		for(User u : [select id, name, userRoleId, Region__c, Area__c, District__c, ProfileId from User where id=:ApexPages.currentPage().getParameters().get('cl')]) {
			if(allSubRoleIds.contains(u.userRoleId) || u.Id==UserInfo.getUserId()) {
				selectedCL = u.id;
				clName = u.Name;
				if(u.Region__c!=null) usr.Region__c = u.Region__c;
				if(u.District__c!=null) usr.District__c = u.District__c;
				if(u.Area__c!=null) usr.Area__c = u.Area__c;
				userType = u.ProfileId;
			}
		}
	} else{
		allSubRoleIds.add(UserInfo.getUserRoleId());
		if(userType==null || userType=='') {
			users = [select id from user where (userRoleId in :allSubRoleIds or Id=:UserInfo.getUserId())
			         and Area__c like :area and
			         District__c like :district];
		} else {
			users = [select id from user where (userRoleId in :allSubRoleIds or Id=:UserInfo.getUserId())
			         and Area__c like :area and
			         District__c like :district and profileId=:userType];
		}


	}

	if(selectedCL!=null) getKpi(selectedCL);
	else getKpi(UserInfo.getUserId());

	if(ApexPages.currentPage().getParameters().get('account')!=null) {
		selectedAccount = ApexPages.currentPage().getParameters().get('account');
	}

	dateOptionSetup();

}

public void getKpi(Id clId){
	for(SalesHD_KPI__c kpis : [select id, CL__r.Name,Admit_Lag_Time__c,
	                           Admits_Per_Day__c, Batting_Average__c, CMI__c, Conversion_Percentage__c, Encounters_Per_Day_Quarter__c,
	                           Encounters_Per_Day_Month__c, Encounters_Per_Day__c, ICU_Referral_Percentage__c,  Referral_Lag_Time__c,
	                           Referrals_Per_Day__c, RecordType.Name from SalesHD_KPI__c where (CL__c=:clId or
	                                                                                                   RecordType.Name='KPI High Baseline' or RecordType.Name='KPI Middle Baseline'
	                                                                                                                                                           or RecordType.Name='KPI Low Baseline') order by KPI_Date__c desc limit 4]) {
		if(kpis.RecordType.Name=='KPI High Baseline') highKpi = kpis;
		else if(kpis.RecordType.Name=='KPI Middle Baseline') middleKpi = kpis;
		else if(kpis.RecordType.Name=='KPI Low Baseline') lowKpi = kpis;
		else if(kpis.CL__c==clId) {
			// kpi = kpis;
			k_kpi = new k_kpi(kpis);
		}
	}

	if(k_kpi!=null && k_kpi.kpi!=null) {
		for(SalesHD_KPI__c kpis : [select CL__r.Name,Admit_Lag_Time__c,
		                           Admits_Per_Day__c, Batting_Average__c, CMI__c, Conversion_Percentage__c, Encounters_Per_Day_Quarter__c,
		                           Encounters_Per_Day_Month__c, Encounters_Per_Day__c, ICU_Referral_Percentage__c,  Referral_Lag_Time__c,
		                           Referrals_Per_Day__c, RecordType.Name from SalesHD_KPI__c where CL__c=:clId and Id != :k_kpi.kpi.Id order by KPI_Date__c desc limit 1]) {
			k_kpi_previous = new k_kpi(kpis);
		}
	}

	if(k_kpi!=null && k_kpi.kpi!=null && highKpi!=null && middleKpi!=null && lowKpi!=null) {
		k_kpi.kpiColors[0] = kpiColor(k_kpi.kpi.Referrals_Per_Day__c, highKpi.Referrals_Per_Day__c, middleKpi.Referrals_Per_Day__c, lowKpi.Referrals_Per_Day__c);
		k_kpi.kpiColors[1] = kpiColor(k_kpi.kpi.Admits_Per_Day__c, highKpi.Admits_Per_Day__c, middleKpi.Admits_Per_Day__c, lowKpi.Admits_Per_Day__c);
		k_kpi.kpiColors[2] = kpiColor(k_kpi.kpi.Batting_Average__c, highKpi.Batting_Average__c, middleKpi.Batting_Average__c, lowKpi.Batting_Average__c);
		k_kpi.kpiColors[3] = kpiColor(k_kpi.kpi.CMI__c, highKpi.CMI__c, middleKpi.CMI__c, lowKpi.CMI__c);
		k_kpi.kpiColors[4] = kpiColorLowerIsBetter(k_kpi.kpi.Referral_Lag_Time__c, highKpi.Referral_Lag_Time__c, middleKpi.Referral_Lag_Time__c, lowKpi.Referral_Lag_Time__c);
		k_kpi.kpiColors[5] = kpiColorLowerIsBetter(k_kpi.kpi.Admit_Lag_Time__c, highKpi.Admit_Lag_Time__c, middleKpi.Admit_Lag_Time__c, lowKpi.Admit_Lag_Time__c);
		k_kpi.kpiColors[6] = kpiColor(k_kpi.kpi.Conversion_Percentage__c, highKpi.Conversion_Percentage__c, middleKpi.Conversion_Percentage__c, lowKpi.Conversion_Percentage__c);
		k_kpi.kpiColors[7] = kpiColor(k_kpi.kpi.ICU_Referral_Percentage__c, highKpi.ICU_Referral_Percentage__c, middleKpi.ICU_Referral_Percentage__c, lowKpi.ICU_Referral_Percentage__c);
		k_kpi.kpiColors[8] = kpiColor(k_kpi.kpi.Encounters_Per_Day__c, highKpi.Encounters_Per_Day__c, middleKpi.Encounters_Per_Day__c, lowKpi.Encounters_Per_Day__c);
	}

	if(k_kpi_previous!=null && highKpi!=null && middleKpi!=null && lowKpi!=null) {
		k_kpi_previous.kpiColors[0] = kpiColor(k_kpi_previous.kpi.Referrals_Per_Day__c, highKpi.Referrals_Per_Day__c, middleKpi.Referrals_Per_Day__c, lowKpi.Referrals_Per_Day__c);
		k_kpi_previous.kpiColors[1] = kpiColor(k_kpi_previous.kpi.Admits_Per_Day__c, highKpi.Admits_Per_Day__c, middleKpi.Admits_Per_Day__c, lowKpi.Admits_Per_Day__c);
		k_kpi_previous.kpiColors[2] = kpiColor(k_kpi_previous.kpi.Batting_Average__c, highKpi.Batting_Average__c, middleKpi.Batting_Average__c, lowKpi.Batting_Average__c);
		k_kpi_previous.kpiColors[3] = kpiColor(k_kpi_previous.kpi.CMI__c, highKpi.CMI__c, middleKpi.CMI__c, lowKpi.CMI__c);
		k_kpi_previous.kpiColors[4] = kpiColorLowerIsBetter(k_kpi_previous.kpi.Referral_Lag_Time__c, highKpi.Referral_Lag_Time__c, middleKpi.Referral_Lag_Time__c, lowKpi.Referral_Lag_Time__c);
		k_kpi_previous.kpiColors[5] = kpiColorLowerIsBetter(k_kpi_previous.kpi.Admit_Lag_Time__c, highKpi.Admit_Lag_Time__c, middleKpi.Admit_Lag_Time__c, lowKpi.Admit_Lag_Time__c);
		k_kpi_previous.kpiColors[6] = kpiColor(k_kpi_previous.kpi.Conversion_Percentage__c, highKpi.Conversion_Percentage__c, middleKpi.Conversion_Percentage__c, lowKpi.Conversion_Percentage__c);
		k_kpi_previous.kpiColors[7] = kpiColor(k_kpi_previous.kpi.ICU_Referral_Percentage__c, highKpi.ICU_Referral_Percentage__c, middleKpi.ICU_Referral_Percentage__c, lowKpi.ICU_Referral_Percentage__c);
		k_kpi_previous.kpiColors[8] = kpiColor(k_kpi_previous.kpi.Encounters_Per_Day__c, highKpi.Encounters_Per_Day__c, middleKpi.Encounters_Per_Day__c, lowKpi.Encounters_Per_Day__c);
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

public String dateOption {get; set;}

public List<SelectOption> getDateOptionPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('This Week', 'This Week'));
	picklist.add(new selectOption('Previous Week', 'Previous Week'));
	picklist.add(new selectOption('Month to Date', 'Month to Date'));
	picklist.add(new selectOption('Previous Month', 'Previous Month'));
	picklist.add(new selectOption('Current Quarter', 'Current Quarter'));
	picklist.add(new selectOption('Previous Quarter', 'Previous Quarter'));
	return picklist;
}

public string selectedMCOState {get; set;}

public List<SelectOption> getMCOStatePicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- MCO State -'));
	for(AggregateResult ar : [select shippingState state from account where recordtype.name = 'HD Managed Care Accounts' group by shippingState ]){
		String state = String.valueOf(ar.get('state'));
		if(state!=null) picklist.add(new selectOption(state, state));
	}
	return picklist;
}

public void dateOptionSetup(){
	if(dateOption==null) dateOption = 'Previous Week';

	if(ApexPages.currentPage().getParameters().get('date_option')!=null)
		dateOption = String.valueOf(ApexPages.currentPage().getParameters().get('date_option'));
}



public List<SelectOption> getEmployeeTypePicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Employee Type -'));
	for(Profile p : [select name from profile where name like '%HD Associate Redesign%' or name like '%HD PAC Redesign%'
	                 or name like '%HD Manager Redesign%'  or name like '%HD CEO Manager Redesign%'  or name like '%HD DVP Manager Redesign%']) {
		String name = p.name;
		if(name.contains('HD Manager')) name = 'Manager';
		if(name.contains('CEO')) name = 'CEO';
		if(name.contains('DVP')) name = 'DVP';
		if(name.contains('Associate')) name = 'CL';
		if(name.contains('PAC')) name = 'PAC';
		picklist.add(new selectOption(p.id, name));
	}
	return picklist;
}

public List<Selectoption> getCLPicklist(){

	allSubRoleIds.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Employee -'));
	List<User> userList = new List<User>();
	if(userType==null || userType=='') {
		userList = [select id, name from user where userRoleId in :allSubRoleIds and
		            District__c like :district and Area__c like :area order by name];
	} else{
		userList = [select id, name from user where userRoleId in :allSubRoleIds and
		            District__c like :district and Area__c like :area and profileId=:userType order by name];
	}
	for(User u : userList) {
		picklist.add(new selectOption(u.id, u.name));
	}
	return picklist;
}

public List<Selectoption> getAccountPicklist(){

	allSubRoleIds.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Account -'));

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

public static void setDates(){

	lowDate = Datetime.newInstance(Date.today().toStartOfWeek().addDays(-7), Time.newInstance(0, 0, 0, 0));
	highDate = Datetime.newInstance(Date.valueOf(lowDate).addDays(7-1), Time.newInstance(23, 59, 59, 99));

	String dateOption = 'Previous Week';
	if(ApexPages.currentPage().getParameters().get('date_option')!=null) {
		dateOption = String.valueOf(ApexPages.currentPage().getParameters().get('date_option'));
	}

	if(dateOption == 'This Week') {
		lowDate = Datetime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(0, 0, 0, 0));
		highDate = Datetime.newInstance(Date.valueOf(lowDate).addDays(7-1), Time.newInstance(23, 59, 59, 99));
	} else if(dateOption == 'Previous Week') {
		lowDate = Datetime.newInstance(Date.today().toStartOfWeek().addDays(-7), Time.newInstance(0, 0, 0, 0));
		highDate = Datetime.newInstance(Date.valueOf(lowDate).addDays(7-1), Time.newInstance(23, 59, 59, 99));
	} else if(dateOption == 'Month to Date') {
		lowDate = Datetime.newInstance(Date.today().toStartOfMonth(), Time.newInstance(0, 0, 0, 0));
		highDate = Datetime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 99));
	} else if(dateOption == 'Previous Month') {
		lowDate = Datetime.newInstance(Date.today().toStartOfMonth().addMonths(-1), Time.newInstance(0, 0, 0, 0));
		highDate = Datetime.newInstance(
			Date.valueOf(lowDate.addDays(Date.daysInMonth(lowDate.month(), lowDate.year()))),
			Time.newInstance(23, 59, 59, 99));
	} else if(dateOption == 'Current Quarter') {
		Datetime low_dt = getQuarter(Date.today().toStartOfMonth());
		if(low_dt != null) {
			lowDate = low_dt;
			highDate = lowDate.addMonths(2);
			highdate = Datetime.newInstance(
				Date.newInstance(highDate.year(), highDate.month(), Date.daysInMonth(highDate.month(), highDate.year())),
				Time.newInstance(23, 59, 59, 99));
		}
	} else if(dateOption == 'Previous Quarter') {
		Datetime low_dt = getQuarter(Date.today().toStartOfMonth());
		if(low_dt != null) {
			lowDate = Datetime.newInstance(
				Date.valueOf(low_dt.addMonths(-3)),
				Time.newInstance(0, 0, 0, 0));

			highDate = low_dt.addDays(-1);
			highDate = Datetime.newInstance(Date.valueOf(highDate), Time.newInstance(23, 59, 59, 99));
		}
	}
}

private static Datetime getQuarter(Date d){
	Date low = Date.newInstance(d.year(), 1, 1);
	Date high = low.addMonths(2);
	high = high.addDays(Date.daysInMonth(high.month(),high.year())-1);

	if(d >= low && d <= high) {
		return Datetime.newInstance(low, Time.newInstance(0, 0, 0, 0));
	}

	low = high.addDays(1);
	high = low.addMonths(2);
	high = high.addDays(Date.daysInMonth(high.month(),high.year())-1);
	if(d >= low && d <= high) {
		return Datetime.newInstance(low, Time.newInstance(0, 0, 0, 0));
	}

	low = high.addDays(1);
	high = low.addMonths(2);
	high = high.addDays(Date.daysInMonth(high.month(),high.year())-1);
	if(d >= low && d <= high) {
		return Datetime.newInstance(low, Time.newInstance(0, 0, 0, 0));
	}

	low = high.addDays(1);
	high = low.addMonths(2);
	high = high.addDays(Date.daysInMonth(high.month(),high.year())-1);
	if(d >= low && d <= high) {
		return Datetime.newInstance(low, Time.newInstance(0, 0, 0, 0));
	}

	return null;
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

public void eLastWeekPurpose(){
	encountersByPurpose = JSON.serializePretty(getEncountersPurpose(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eLastWeekType(){
	encountersByType = JSON.serializePretty(getEncountersType(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

// public void eLastWeekPayorType(){
// 	encountersByPayorType = JSON.serializePretty(getEncountersPayorType(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
// }

public void eLastWeekObjective(){
	encountersByObjective = JSON.serializePretty(getEncountersObjective(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eLastWeekAccounts(){
	encountersByAccount = JSON.serializePretty(getEncountersAccount(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

public void eLastWeekUsers(){
	encountersByUsers = JSON.serializePretty(getEncountersUsers(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

// public void eLastWeekAccounts20(){
// 	encountersByAccount20 = getEncountersAccount20(UserInfo.getUserRoleId(), selectedCL, selectedMCOState, users);
// }

// public void eLastWeekPayorParent10(){
// 	encountersByPayorParent10 = getEncountersPayorParent10(UserInfo.getUserRoleId(), selectedCL, selectedMCOState, users);
// }

public void eByAccount(){
	encountersByMCO = getEcnountersMCO(UserInfo.getUserRoleId(), selectedCL, selectedMCOState, users);
}

public void eUpcomingAccounts(){
	encountersByAccountUpcoming = JSON.serializePretty(getEncountersAccountUpcoming(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
}

// public void eUpcomingPayorParent(){
// 	encountersByPayorParentUpcoming = JSON.serializePretty(getEncountersPayorParentUpcoming(UserInfo.getUserRoleId(), selectedCL, selectedAccount, users));
// }

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
	// setWeeks();
	setDates();
	for(event e : [select whoId from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId()) and startDateTime>=:lowDate and startDateTime<=:highDate]) {
		contactIds.add(e.whoId);
	}

	for(contact c : [select id, title__c from contact where id in :contactIds]) {
		if(c.title__c!=null) contacts.put(c.id, c.title__c);
		else contacts.put(c.id, '-');
	}

	Integer physicianEncounters=0, npEncounters=0, cmEncounters=0, directorEncounters=0, otherEncounters=0;





	// setWeeks();
	setDates();

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
	// setWeeks();
	setDates();

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
	// setWeeks();
	setDates();

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

public static String getEncountersType(Id rId, Id cl, Id accountId, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"Metting Type","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	// setWeeks();
	setDates();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalByType, Type
		       from event where ownerId=:cl
		                                 and startDateTime>=:lowDate and startDateTime<=:highDate group by Type];
	} else if(accountId!=null) {
		ars = [select count(id) totalByType, Type
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
		       and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId group by Type];
	} else{
		ars = [select count(id) totalByType, Type
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
		       and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate group by Type];
	}

	for(AggregateResult ar : ars) {
		Integer totalByType = Integer.valueOf(ar.get('totalByType'));
		String type = '-';
		if(ar.get('Type')!=null) type = String.valueOf(ar.get('Type'));
		res += '{"c":[{"v":"'+type+'","f":null},{"v":'+totalByType+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

public static String getEncountersPurpose(Id rId, Id cl, Id accountId, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"Contact Title","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	// setWeeks();
	setDates();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalByPurpose, Subject__c
		       from event where ownerId=:cl
		                                 and startDateTime>=:lowDate and startDateTime<=:highDate group by Subject__c];
	} else if(accountId!=null) {
		ars = [select count(id) totalByPurpose, Subject__c
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
		       and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId group by Subject__c];
	} else{
		ars = [select count(id) totalByPurpose, Subject__c
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
		       and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate group by Subject__c];
	}

	for(AggregateResult ar : ars) {
		Integer totalByPurpose = Integer.valueOf(ar.get('totalByPurpose'));
		String purpose = '-';
		if(ar.get('Subject__c')!=null) purpose = String.valueOf(ar.get('Subject__c'));
		res += '{"c":[{"v":"'+purpose+'","f":null},{"v":'+totalByPurpose+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;
}

// public static String getEncountersPayorType(Id rId, Id cl, Id accountId, List<User> usrs){

// 	String res = '{ "cols" : [{"id":"","label":"Contact Title","pattern":"","type":"string"}, ' +
// 	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
// 	             '"rows": [';
// 	// setWeeks();
// 	setDates();

// 	List<AggregateResult> ars = new List<AggregateResult>();
// 	if(cl!=null) {
// 		ars = [select count(id) totalByPayorType, SalesHD_Managed_Care_Payor__c
// 		       from event where ownerId=:cl
// 		                                 and startDateTime>=:lowDate and startDateTime<=:highDate group by SalesHD_Managed_Care_Payor__c];
// 	} else if(accountId!=null) {
// 		ars = [select count(id) totalByPayorType, SalesHD_Managed_Care_Payor__c
// 		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
// 		       and ownerId in :usrs
// 		       and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId group by SalesHD_Managed_Care_Payor__c];
// 	} else{
// 		ars = [select count(id) totalByPayorType, SalesHD_Managed_Care_Payor__c
// 		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
// 		       and ownerId in :usrs
// 		       and startDateTime>=:lowDate and startDateTime<=:highDate group by SalesHD_Managed_Care_Payor__c];
// 	}

// 	for(AggregateResult ar : ars) {
// 		Integer totalByPayorType = Integer.valueOf(ar.get('totalByPayorType'));
// 		String payorType = '-';
// 		if(ar.get('SalesHD_Managed_Care_Payor__c')!=null) payorType = String.valueOf(ar.get('SalesHD_Managed_Care_Payor__c'));
// 		res += '{"c":[{"v":"'+payorType+'","f":null},{"v":'+totalByPayorType+',"f":null}] },';
// 	}
// 	if(res.right(1) == ',') res = res.left(res.length()-1);
// 	res += ']}';
// 	return res;
// }

public static String getEncountersObjective(Id rId, Id cl, Id accountId, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"Objective","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	// setWeeks();
	setDates();


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
	// setWeeks();
	setDates();

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
	// setWeeks();
	setDates();

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

public static String getEncountersUsers(Id rId, Id cl, Id accountId, List<User> usrs){
	String res = '{ "cols" : [{"id":"","label":"Account","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	// setWeeks();
	setDates();

	List<AggregateResult> ars = new List<AggregateResult>();
	if(cl!=null) {
		ars = [select count(id) totalEncounters, Owner.Name accountName
		       from event where ownerId=:cl and startDateTime>=:lowDate and startDateTime<=:highDate
		                                 group by Owner.Name];
	} else if(accountId!=null) {
		ars = [select count(id) totalEncounters, Owner.Name accountName
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
		       and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate and accountId=:accountId
		                                                                               group by Owner.Name];
	} else{
		ars = [select count(id) totalEncounters, Owner.Name accountName
		       from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
		       and ownerId in :usrs
		       and startDateTime>=:lowDate and startDateTime<=:highDate
		       group by Owner.Name];
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

private static Map<String, Integer> ContactMethod(){
	Map<String, Integer> contactMethod = new Map<String, Integer>();
	Schema.DescribeFieldResult fieldResult =
		Event.SalesHD_Contact_Method__c.getDescribe();
	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	for( Schema.PicklistEntry f : ple)
	{
		contactMethod.put(f.getLabel(), 0);
	}
	return contactMethod;
}



// public static String getEncountersAccount20(Id rId, Id cl, String selectedMCOState, List<User> usrs){
// 	return '';
// }

public static String getEcnountersMCO(Id rId, Id cl, String selectedMCOState, List<User> usrs){
	Map<String, Integer> contactMethod = ContactMethod();
	contactMethod.put('-', 0);
	String result = '[\'Contact Method\'';
	for(String cm : contactMethod.keyset()) {
		result += ', \''+String.escapeSingleQuotes(cm)+'\', { role: \'annotation\' }';
	}
	result += ', { role: \'annotation\' }]';


	setDates();



	List<AggregateResult> ars = new List<AggregateResult>();

	String query = 'select count(id) totalEncounters, Account.Name accountName, SalesHD_Contact_Method__c contactMethod'+
	' from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(cl!=null) query += 'and ownerId=:cl';
	else query += ' and ownerId in :usrs';
	if(selectedMCOState!=null) query +=  ' and account.shippingState=:selectedMCOState';
	query+= ' and startDateTime>=:lowDate and startDateTime<=:highDate'+
	' group by Account.Name, SalesHD_Contact_Method__c order by count(id) desc limit 10';


	ars = database.query(query);

	Map<String, Map<String, Integer> > data = new Map<String, Map<String, Integer> >();
	for(AggregateResult ar : ars) {
		Integer totalEncounters = Integer.valueOf(ar.get('totalEncounters'));
		String accountName = '-';
		String cMethod = '-';
		if(ar.get('accountName')!=null) accountName = String.escapeSingleQuotes(String.valueOf(ar.get('accountName')));
		if(ar.get('contactMethod')!=null && contactMethod.containsKey(String.valueOf(ar.get('contactMethod')))) cMethod = String.escapeSingleQuotes(String.valueOf(ar.get('contactMethod')));

		Map<String, Integer> temp = new Map<String, Integer>(contactMethod);
		if(data.containsKey(accountName)) {
			temp = data.remove(accountName);
			temp.put(cMethod, totalEncounters);
		} else{
			temp.put(cMethod, totalEncounters);
		}
		data.put(accountName, temp);

	}

	for(String accountName : data.keySet()) {
		result += ', [ \''+accountName+'\'';

		for(Integer cm : data.remove(accountName).values()) {
			if(cm>0) result += ', '+cm+', \''+cm+'\'';
			else result += ', '+cm+', \'\'';
		}

		result += ', \'\']';
	}
	return result;
}

public Static Id currentUserId = UserInfo.getUserId();
// public static String getEncountersPayorParent10(Id rId, Id cl, String selectedMCOState, List<User> usrs){
// 	return '';
// }

public static String getEncountersAccountUpcoming(Id rId, Id cl, Id accountId, List<User> usrs){
	String res = '{ "cols" : [{"id":"","label":"Account","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	// setWeeks();
	setDates();
	lowDate = Date.valueOf(System.now());
	highDate = Date.valueOf(lowDate).addDays(30);
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

// public static String getEncountersPayorParentUpcoming(Id rId, Id cl, Id accountId, List<User> usrs){
// 	return '';
// }

public static String getUpcomingEncounters(Id rId, Id cl, List<User> usrs){

	String res = '{ "cols" : [{"id":"","label":"CL","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';
	// setWeeks();
	setDates();

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
	// setWeeks();
	setDates();

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

public PageReference selectMCOState(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().put('mco_state', String.valueOf(selectedMCOState));
	page.setRedirect(true);
	return page;
}

public PageReference selectUserType(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().remove('cl');
	page.getParameters().remove('account');
	page.getParameters().put('user_type', String.valueOf(userType));
	page.setRedirect(true);
	return page;
}

public PageReference selectDateOption(){
	PageReference page = new PageReference(ApexPages.currentPage().getUrl());
	page.getParameters().put('date_option', String.valueOf(dateOption));
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

public Integer getTotalEncounters(){
	setDates();
	Integer result = 0;
	Id currentUserId = UserInfo.getUserId();
	Id cl = null;
	if(ApexPages.currentPage().getParameters().get('cl')!=null) cl = ApexPages.currentPage().getParameters().get('cl');
	String query = 'select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(cl!=null) query += ' and ownerId=:cl';
	query += ' and ownerId in :users'+
	' and startDateTime>=:lowDate and startDateTime<=:highDate';
	for(AggregateResult ar: database.query(query)){
		result = Integer.valueOf(ar.get('totalEncounters'));
	}

	// for(AggregateResult ar: [select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
	//                          and ownerId in :users
	//                          and startDateTime>=:lowDate and startDateTime<=:highDate]) {
	// 	result = Integer.valueOf(ar.get('totalEncounters'));
	// }
	return result;

}

public Integer getTotalJQC(){
	setDates();
	Integer result = 0;
	Id currentUserId = UserInfo.getUserId();
	String query = 'select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	query += ' and ownerId in :users and Type=\'JQC\''+
	' and startDateTime>=:lowDate and startDateTime<=:highDate';
	for(AggregateResult ar: database.query(query)){
		result = Integer.valueOf(ar.get('totalEncounters'));
	}

	// for(AggregateResult ar: [select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
	//                          and ownerId in :users and Type='JQC'
	//                                                          and startDateTime>=:lowDate and startDateTime<=:highDate]) {
	// 	result = Integer.valueOf(ar.get('totalEncounters'));
	// }
	return result;

}

public Integer getTotalPresentation(){
	setDates();
	Integer result = 0;
	Id currentUserId = UserInfo.getUserId();
	String query = 'select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	query += ' and ownerId in :users and Type=\'Scheduled presentation/in-service\''+
	' and startDateTime>=:lowDate and startDateTime<=:highDate';
	for(AggregateResult ar: database.query(query)){
		result = Integer.valueOf(ar.get('totalEncounters'));
	}

	// for(AggregateResult ar: [select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
	//                          and ownerId in :users and Type='Scheduled presentation/in-service'
	//                                                          and startDateTime>=:lowDate and startDateTime<=:highDate]) {
	// 	result = Integer.valueOf(ar.get('totalEncounters'));
	// }
	return result;

}

public Integer getTotalSmallGroup(){
	setDates();
	Integer result = 0;
	Id currentUserId = UserInfo.getUserId();
	String query = 'select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	query += ' and ownerId in :users and Type=\'1:1 conversation/small group\''+
	' and startDateTime>=:lowDate and startDateTime<=:highDate';
	for(AggregateResult ar: database.query(query)){
		result = Integer.valueOf(ar.get('totalEncounters'));
	}
	// for(AggregateResult ar: [select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
	//                          and ownerId in :users and Type='1:1 or small group meeting or conversation'
	//                                                          and startDateTime>=:lowDate and startDateTime<=:highDate]) {
	// 	result = Integer.valueOf(ar.get('totalEncounters'));
	// }
	return result;

}

public Integer getTotalCareCoor(){
	setDates();
	Integer result = 0;
	Id currentUserId = UserInfo.getUserId();
	String query = 'select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	query += ' and ownerId in :users and Type=\'Care Coordination/ICT\''+
	' and startDateTime>=:lowDate and startDateTime<=:highDate';
	for(AggregateResult ar: database.query(query)){
		result = Integer.valueOf(ar.get('totalEncounters'));
	}

	// for(AggregateResult ar: [select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
	//                          and ownerId in :users and Type='Care Coordination/ICT'
	//                                                          and startDateTime>=:lowDate and startDateTime<=:highDate]) {
	// 	result = Integer.valueOf(ar.get('totalEncounters'));
	// }
	return result;

}
public Integer getTotalTour(){
	setDates();
	Integer result = 0;
	Id currentUserId = UserInfo.getUserId();
	String query = 'select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:currentUserId)';
	if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	query += ' and ownerId in :users and Type=\'Tour\''+
	' and startDateTime>=:lowDate and startDateTime<=:highDate';
	for(AggregateResult ar: database.query(query)){
		result = Integer.valueOf(ar.get('totalEncounters'));
	}

	// for(AggregateResult ar: [select count(id) totalEncounters from event where (owner.userRoleId in :allSubRoleIds or ownerId=:UserInfo.getUserId())
	//                          and ownerId in :users and Type='Tour'
	//                                                          and startDateTime>=:lowDate and startDateTime<=:highDate]) {
	// 	result = Integer.valueOf(ar.get('totalEncounters'));
	// }
	return result;

}

}
