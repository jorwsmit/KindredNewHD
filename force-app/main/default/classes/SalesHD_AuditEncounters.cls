public without sharing class SalesHD_AuditEncounters {

	private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});
	
	public boolean weekly {get; set;}
	public boolean thisweek {get; set;}
	public boolean mtd {get; set;}
	public boolean monthly {get; set;}
	public boolean audited {get; set;}
	
	public String month {get; set;}
	public String year {get; set;}
	
	//chart all needs to be implemented fully
	public boolean chartAll {get; set;}
	
	public List<Event> encounters {get; set;}
	
	public String selectedCL {get; set;}
	
	public String selectedNDays {get; set;}
	
	public String dateRangeStr {get; set;}
	
	private Integer maxDays = 60;
	private Integer minDays = 2;
	private Integer days = minDays;
	
	public class auditReport {
	public String cl {get; set;}
	public String clId {get; set;}
	public Integer totalEncounters {get; set;}
	public Integer totalAudited {get; set;}
	public Integer totalApproved {get; set;}
	public Integer totalNeedsReview {get; set;}
	public Integer totalRejected {get; set;}
	public Decimal percentApproved {get; set;}
	public Decimal percentNeedsReview {get; set;}
	public Decimal percentRejected {get; set;}
	public Decimal percentAudited {get; set;}
	
	public auditReport(){
		cl = '';
		clId = '';
		totalEncounters = 0;
		totalAudited= 0;
		totalApproved = 0;
		totalNeedsReview = 0;
		totalRejected = 0;
		percentApproved = 0;
		percentNeedsReview = 0;
		percentRejected = 0;
		percentAudited = 0;
	}
	}
	
	public chartData cd {get; set;}
	
	public class chartData {
	public Integer totalEncounters {get; set;}
	public Integer totalAudited {get; set;}
	public Integer totalApproved {get; set;}
	public Integer totalNeedsReview {get; set;}
	public Integer totalRejected {get; set;}
	
	public chartData(){
		totalEncounters = 0;
		totalAudited= 0;
		totalApproved = 0;
		totalNeedsReview = 0;
		totalRejected = 0;
	}
	}
	
	public districtChartData dcd {get; set;}
	
	public class districtChartData {
	public String district {get; set;}
	public chartData chartData {get; set;}
	public districtChartData(String district, chartData chartData){
		this.district = district;
		this.chartData = chartData;
	}
	}
	
	public User usr {get; set;}
	
	
	public SalesHD_AuditEncounters() {
	
		usr = new User();
		usr.Region__c='HD';
	
		for(User u : [select id, region__c, district__c, area__c, profile.name from user where Id=:UserInfo.getUserId()]) {
			// if(u.Region__c!=null) usr.Region__c = u.Region__c;
			if(u.district__c!=null && ApexPages.currentPage().getParameters().get('district')==null) usr.district__c = u.district__c;
			if(u.area__c!=null&& ApexPages.currentPage().getParameters().get('district')==null && ApexPages.currentPage().getParameters().get('market')==null) usr.area__c = u.area__c;
	
			if(u.profile.name.contains('Associate') || u.profile.name.contains('PAC')) selectedCL=u.Id;
		}
	
	
		weekly = true;
		thisweek = false;
		mtd = false;
		monthly = false;
		audited = false;
	
		chartAll = true;
	
		month = String.valueOf(Date.valueOf(system.now()).month());
		year = String.valueOf(Date.valueOf(system.now()).year());
	
		if(ApexPages.currentPage().getParameters().get('month')!=null)
			month = String.valueOf(ApexPages.currentPage().getParameters().get('month'));
		if(ApexPages.currentPage().getParameters().get('year')!=null)
			year = String.valueOf(ApexPages.currentPage().getParameters().get('year'));
	
		if(ApexPages.currentPage().getParameters().get('weekly')!=null)
			weekly=Boolean.valueOf(ApexPages.currentPage().getParameters().get('weekly'));
	
		if(ApexPages.currentPage().getParameters().get('thisweek')!=null)
			thisweek=Boolean.valueOf(ApexPages.currentPage().getParameters().get('thisweek'));
	
		if(ApexPages.currentPage().getParameters().get('mtd')!=null)
			mtd=Boolean.valueOf(ApexPages.currentPage().getParameters().get('mtd'));
	
		if(ApexPages.currentPage().getParameters().get('monthly')!=null)
			monthly=Boolean.valueOf(ApexPages.currentPage().getParameters().get('monthly'));
	
		if(ApexPages.currentPage().getParameters().get('audited')!=null)
			audited=Boolean.valueOf(ApexPages.currentPage().getParameters().get('audited'));
	
		if(ApexPages.currentPage().getParameters().get('cl')!=null)
			selectedCL=String.valueOf(ApexPages.currentPage().getParameters().get('cl'));
	
		if(ApexPages.currentPage().getParameters().get('days')!=null && ApexPages.currentPage().getParameters().get('days').isNumeric()) {
			if(Integer.valueOf(ApexPages.currentPage().getParameters().get('days'))>maxDays) selectedNDays = String.valueOf(maxDays);
			else if(Integer.valueOf(ApexPages.currentPage().getParameters().get('days'))<minDays) selectedNDays = String.valueOf(minDays);
			else selectedNDays=String.valueOf(ApexPages.currentPage().getParameters().get('days'));
			days = Integer.valueOf(selectedNDays);
		}
	
		if(ApexPages.currentPage().getParameters().get('district')!=null)
			usr.District__c=String.valueOf(ApexPages.currentPage().getParameters().get('district'));
	
		if(ApexPages.currentPage().getParameters().get('market')!=null)
			usr.Area__c=String.valueOf(ApexPages.currentPage().getParameters().get('market'));
	
	
	
		if(weekly) {
			Date d = System.Today().toStartOfWeek().addDays(-7);
			dateRangeStr = d.format() + ' - ' + d.addDays(7-1).format();
		} else if(thisweek) {
			Date d = System.Today().toStartOfWeek();
			dateRangeStr = d.format() + ' - ' + d.addDays(7-1).format();
		}
		else if(monthly) {
			Date d = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
			dateRangeStr = d.format() + ' - ' + d.addDays(Date.daysInMonth(Integer.valueOf(year), Integer.valueOf(month))).format();
		} else if(mtd) {
			Date d = System.Today().addDays(-System.Today().day()+1);
			dateRangeStr = d.format() + ' - ' + d.addDays(System.Today().day()-1).format();
		}
	
		if(Apexpages.currentPage().getUrl().toLowerCase().contains('auditencounters')) {
	
			encounters = new List<Event>();
	
			List<User> u = [select Profile.name from User where Id=:UserInfo.getUserId()];
			if(!u.isEmpty() && ( u[0].Profile.name.contains('Associate') || u[0].Profile.name.contains('PAC') )) {
				audited=true;
				encounters = getMyEncounters();
			} else {
				encounters = getEncounters();
			}
		}
	
		cd = new chartData();
	
	}
	
	public List<Event> getEncounters(){
		List<Event> events = new List<Event>();
		if(usr.District__c!=null) {
	
	
			String query = 'select SalesHD_Call_Objective__c, Who.Name, Who.Title, What.Name, SalesHD_Account_Unit__r.Unit__r.Name, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,'+
						   'SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,'+
						   'SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,'+
						   'Owner.Name, event.SalesHD_Account_Strategy__c, SalesHD_Account_Strategy__r.Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c from event where owner.isActive=true';
	
	
	
			if(weekly) query += ' and startDateTime=Last_Week';
			else if(thisweek) query += ' and startDateTime=This_Week';
			else if(monthly) query += ' and startDateTime>=' + monthYearQueryStringLow() + ' and startDateTime<=' + monthYearQueryStringHigh();
	
			if(!audited) query += ' and Encounter_Audit__r.Audit_Result__c=null';
	
			if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	
			if(usr.District__c!=null && usr.Area__c==null) query += ' and District__c=\''+usr.District__c+'\'';
			else if(usr.Area__c!=null && usr.District__c==null) query += ' and Area__c=\''+usr.Area__c+'\'';
			else if(usr.Area__c!=null && usr.District__c!=null) query += ' and District__c=\''+usr.District__c+'\' and Area__c=\''+usr.Area__c+'\'';
	
			query += ' limit 1000';
			events = database.query(query);
		}
		return events;
	
	}
	
	private String monthYearQueryStringLow(){
		String monthYear = year + '-' + month + '-' + '01';
		if(Integer.valueOf(month)<10) monthYear = year+'-0'+month+'-01T00:00:00Z';
		else monthYear = year+'-'+month+'-01T00:00:00Z';
		return monthYear;
	}
	private String monthYearQueryStringHigh(){
		String monthYear = year + '-' + month + '-' + Date.daysInMonth(Integer.valueOf(year), Integer.valueOf(month));
		Date d = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
		d = d.addMonths(1);
		if(d.month()<10) monthYear = d.year()+'-0'+d.month()+'-01T00:00:00Z';
		else monthYear = d.year()+'-'+d.month()+'-01T00:00:00Z';
		return monthYear;
	}
	
	private Map<String, String> auditResultMap = new Map<String, String>
	{'Approved' => 'Approved',
	 'Rejected' => 'Rejected',
	 'Asking for business only' => 'Rejected',
	 'Duplicate encounter' => 'Rejected',
	 'Not a sales call' => 'Rejected',
	 'Referral managing' => 'Rejected'};
	
	
	public List<auditReport> getReport(){
		Map<Id, auditReport> userData = new Map<Id, auditReport>();
	
		if(usr.District__c!=null) {
			Id currentUserId = UserInfo.getUserId();
			String userQuery = 'select Id, Name from user where isActive=true';
			if(selectedCL!=null) userQuery += ' and Id=:selectedCL';
			if(usr.District__c!=null && usr.Area__c==null) userQuery += ' and District__c=\''+usr.District__c+'\'';
			else if(usr.Area__c!=null && usr.District__c==null) userQuery += ' and Area__c=\''+usr.Area__c+'\'';
			else if(usr.Area__c!=null && usr.District__c!=null) userQuery += ' and District__c=\''+usr.District__c+'\' and Area__c=\''+usr.Area__c+'\'';
	
	
			for(User u : database.query(userQuery)) {
				auditReport ar = new auditReport();
				ar.cl = u.Name;
				ar.clId = u.Id;
				userData.put(u.Id, ar);
			}
	
	
			String query = 'select OwnerId cl, Encounter_Audit__r.Audit_Result__c result, Count(Id) total from event where owner.isActive=true';
	
	
			if(weekly) query += ' and startDateTime=Last_Week';
			else if(thisweek) query += ' and startDateTime=This_Week';
			else if(monthly) query += ' and startDateTime>=' + monthYearQueryStringLow() + ' and startDateTime<=' + monthYearQueryStringHigh();
			else if(mtd) query += ' and startDateTime>=this_month and startDateTime<=today';
	
			if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	
			if(usr.District__c!=null && usr.Area__c==null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\')';
			else if(usr.Area__c!=null && usr.District__c==null) query += ' and ownerId in (select Id from user where Area__c=\''+usr.Area__c+'\')';
			else if(usr.Area__c!=null && usr.District__c!=null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\' and Area__c=\''+usr.Area__c+'\')';
	
			query += ' group by OwnerId, Encounter_Audit__r.Audit_Result__c';
	
			for(AggregateResult ar : database.query(query)) {
				if(userData.containsKey(String.valueOf(ar.get('cl')))) {
					auditReport aReport = userData.remove(String.valueOf(ar.get('cl')));
					aReport.totalEncounters += Integer.valueOf(ar.get('total'));
					if(ar.get('result')!=null) {
						aReport.totalAudited += Integer.valueOf(ar.get('total'));
						if(!auditResultMap.containsKey(String.valueOf(ar.get('result')))) aReport.totalNeedsReview += Integer.valueOf(ar.get('total'));
						if(auditResultMap.get(String.valueOf(ar.get('result')))=='Approved') {
							aReport.totalApproved += Integer.valueOf(ar.get('total'));
						}else if(auditResultMap.get(String.valueOf(ar.get('result')))=='Rejected') {
							aReport.totalRejected += Integer.valueOf(ar.get('total'));
						}
					}
					userData.put(String.valueOf(ar.get('cl')), aReport);
				}
	
			}
	
			List<auditReport> emptyData = new List<auditReport>();
			for(String userId : userData.keySet()) {
				auditReport aReport = userData.remove(userId);
				if(aReport.totalEncounters!=0) {
					cd.totalEncounters += aReport.totalEncounters;
					cd.totalAudited += aReport.totalAudited;
					cd.totalApproved += aReport.totalApproved;
					cd.totalNeedsReview += aReport.totalNeedsReview;
					cd.totalRejected += aReport.totalRejected;
	
					aReport.percentAudited = Decimal.valueOf(aReport.totalAudited)/Decimal.valueOf(aReport.totalEncounters);
					aReport.percentApproved = Decimal.valueOf(aReport.totalApproved)/Decimal.valueOf(aReport.totalEncounters);
					aReport.percentNeedsReview = Decimal.valueOf(aReport.totalNeedsReview)/Decimal.valueOf(aReport.totalEncounters);
					aReport.percentRejected = Decimal.valueOf(aReport.totalRejected)/Decimal.valueOf(aReport.totalEncounters);
					userData.put(userId, aReport);
				} else {
					emptyData.add(aReport);
				}
	
	
			}
			for(auditReport ar : emptyData) {
				userData.put(ar.clId, ar);
			}
		}
	
		return userData.values();
	
	}
	
	public Boolean getShowChart(){
		Id currentUserId = UserInfo.getUserId();
		String query = 'select Count(Id) total from event where owner.isActive=true';
	
		if(weekly) query += ' and startDateTime=Last_Week';
		else if(thisweek) query += ' and startDateTime=This_Week';
		// else if(monthly) query += ' and startDateTime=Last_n_days:'+days;
		else if(monthly) query += ' and startDateTime>=' + monthYearQueryStringLow() + ' and startDateTime<=' + monthYearQueryStringHigh();
		else if(mtd) query += ' and startDateTime>=this_month and startDateTime<=today';
	
		if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	
		if(usr.District__c!=null && usr.Area__c==null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\')';
		else if(usr.Area__c!=null && usr.District__c==null) query += ' and ownerId in (select Id from user where Area__c=\''+usr.Area__c+'\')';
		else if(usr.Area__c!=null && usr.District__c!=null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\' and Area__c=\''+usr.Area__c+'\')';
	
		for(AggregateResult ar : database.query(query)) {
			if(Integer.valueOf(ar.get('total'))>0) return true;
		}
		return false;
	}
	
	private List<String> districts = new List<String>
	{'California', 'Dallas/Ft. Worth', 'East', 'Florida', 'Houston', 'Midwest', 'Mountain'};
	
	public List<districtChartData> getdistrictChart(){
		Map<String, chartData> chartData = new Map<String, chartData>();
	
		String query = 'select District__c, Encounter_Audit__r.Audit_Result__c from event where owner.isActive=true';
	
		if(weekly) query += ' and startDateTime=Last_Week';
		else if(thisweek) query += ' and startDateTime=This_Week';
		// else if(monthly) query += ' and startDateTime=Last_n_days:'+days;
		else if(monthly) query += ' and startDateTime>=' + monthYearQueryStringLow() + ' and startDateTime<=' + monthYearQueryStringHigh();
		else if(mtd) query += ' and startDateTime>=this_month and startDateTime<=today';
	
		if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	
		// if(usr.District__c!=null && usr.Area__c==null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\')';
		// else if(usr.Area__c!=null && usr.District__c==null) query += ' and ownerId in (select Id from user where Area__c=\''+usr.Area__c+'\')';
		// else if(usr.Area__c!=null && usr.District__c!=null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\' and Area__c=\''+usr.Area__c+'\')';
	
		// query += ' and startDateTime=Last_n_days:'+60;
	
		// query += ' group by District__c, Encounter_Audit__r.Audit_Result__c';
	
		for(Event e : database.query(query)) {
			chartData cData = new chartData();
			if(chartData.containsKey(e.district__c)) {
				cData = chartData.remove(e.district__c);
			}
			chartData.put(String.valueOf(e.district__c), calcChartData(cData, e.Encounter_Audit__r.Audit_Result__c));
	
		}
	
		for(AggregateResult ar : [select District__c district from user where isActive=true group by District__c]) {
			String d = String.valueOf(ar.get('district'));
			if(d != null && !chartData.containsKey(d)) {
				chartData cData = new chartData();
				chartData.put(d, cData);
			}
		}
	
		List<districtChartData> divChartList = new List<districtChartData>();
		for(String district : chartData.keySet()) {
			districtChartData divChartData = new districtChartData(district, chartData.get(district));
			divChartList.add(divChartData);
		}
		return divChartList;
	}
	
	public List<districtChartData> getMarketChart(){
		Map<String, chartData> chartData = new Map<String, chartData>();
	
		String query = 'select Area__c, Encounter_Audit__r.Audit_Result__c from event where owner.isActive=true';
	
		if(weekly) query += ' and startDateTime=Last_Week';
		else if(thisweek) query += ' and startDateTime=This_Week';
		// else if(monthly) query += ' and startDateTime=Last_n_days:'+days;
		else if(monthly) query += ' and startDateTime>=' + monthYearQueryStringLow() + ' and startDateTime<=' + monthYearQueryStringHigh();
		else if(mtd) query += ' and startDateTime>=this_month and startDateTime<=today';
	
		if(selectedCL!=null) query += ' and ownerId=:selectedCL';
	
		// if(usr.District__c!=null && usr.Area__c==null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\')';
		// else if(usr.Area__c!=null && usr.District__c==null) query += ' and ownerId in (select Id from user where Area__c=\''+usr.Area__c+'\')';
		// else if(usr.Area__c!=null && usr.District__c!=null) query += ' and ownerId in (select Id from user where District__c=\''+usr.District__c+'\' and Area__c=\''+usr.Area__c+'\')';
	
		// query += ' and startDateTime=Last_n_days:'+60;
	
		// query += ' group by District__c, Encounter_Audit__r.Audit_Result__c';
	
		for(Event e : database.query(query)) {
			chartData cData = new chartData();
			if(chartData.containsKey(e.area__c)) {
				cData = chartData.remove(e.area__c);
			}
			chartData.put(String.valueOf(e.area__c), calcChartData(cData, e.Encounter_Audit__r.Audit_Result__c));
	
		}
	
		for(AggregateResult ar : [select Area__c area from user where isActive=true group by Area__c]) {
			String market = String.valueOf(ar.get('area'));
			if(market != null && !chartData.containsKey(market)) {
				chartData cData = new chartData();
				chartData.put(market, cData);
			}
		}
	
		Map<String,List<String> > dependentPicklistValuesMap = getDependentPicklistValues(user.Area__c);
		List<districtChartData> divChartList = new List<districtChartData>();
		if(dependentPicklistValuesMap.containsKey(usr.District__c)) {
			for(String market : dependentPicklistValuesMap.get(usr.District__c)) {
				districtChartData divChartData = new districtChartData(market, chartData.get(market));
				divChartList.add(divChartData);
			}
		}
	
	
		// List<districtChartData> divChartList = new List<districtChartData>();
		// for(String market : chartData.keySet()) {
		//  districtChartData divChartData = new districtChartData(market, chartData.get(market));
		//  divChartList.add(divChartData);
		// }
		return divChartList;
	}
	
	public static Map<String, List<String> > getDependentPicklistValues(Schema.sObjectField dependToken) {
		Schema.DescribeFieldResult depend = dependToken.getDescribe();
		Schema.sObjectField controlToken = depend.getController();
		if (controlToken == null) {
			return new Map<String, List<String> >();
		}
	
		Schema.DescribeFieldResult control = controlToken.getDescribe();
		List<Schema.PicklistEntry> controlEntries;
		if(control.getType() != Schema.DisplayType.Boolean) {
			controlEntries = control.getPicklistValues();
		}
	
		String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
		Map<String,List<String> > dependentPicklistValues = new Map<String,List<String> >();
		for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
			if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
				List<String> base64chars =
					String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
				for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
					Object controlValue =
						(controlEntries == null
						 ?   (Object) (index == 1)
						 :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
						);
					Integer bitIndex = index / 6;
					if (bitIndex > base64chars.size() - 1) {
						break;
					}
					Integer bitShift = 5 - Math.mod(index, 6);
					if  (   controlValue == null
							|| (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
							) continue;
					if (!dependentPicklistValues.containsKey((String) controlValue)) {
						dependentPicklistValues.put((String) controlValue, new List<String>());
					}
					dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
				}
			}
		}
		return dependentPicklistValues;
	}
	
	public chartData calcChartData(chartData cData, String result){
		cData.totalEncounters += 1;
		if(result!=null) {
			cData.totalAudited += 1;
			if(!auditResultMap.containsKey(result)) cData.totalNeedsReview += 1;
			if(auditResultMap.get(result)=='Approved') {
				cData.totalApproved += 1;
			}else if(auditResultMap.get(result)=='Rejected') {
				cData.totalRejected += 1;
			}
		}
		return cData;
	}
	
	public List<Event> getMyEncounters(){
	
		Id currentUserId = UserInfo.getUserId();
		String query = 'select SalesHD_Call_Objective__c, Who.Name, Who.Title, What.Name, SalesHD_Account_Unit__r.Unit__r.Name, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,'+
					   'SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,'+
					   'SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,'+
					   'Owner.Name, event.SalesHD_Account_Strategy__c, SalesHD_Account_Strategy__r.Account_Sales_Plan__r.Parent_Sales_Plan__r.SalesHD_Plan_Date__c from event where ownerId=:currentUserId';
	
	
		if(weekly) query += ' and startDateTime=Last_Week';
		else if(thisweek) query += ' and startDateTime=This_Week';
		else if(monthly) query += ' and startDateTime>=' + monthYearQueryStringLow() + ' and startDateTime<=' + monthYearQueryStringHigh();
	
		return database.query(query);
		// return null;
	}
	
	public List<Selectoption> getCLPicklist(){
		List<Selectoption> picklist = new List<selectoption>();
		picklist.add(new selectOption('', '- Select an Employee -'));
		String query = 'select id, name from user where userRoleId in :allSubRoleIds ';
		if(usr.District__c != null) System.debug('has district');
		if(usr.District__c != null) query += 'and District__c=\''+usr.District__c+'\' ';
		if(usr.Area__c != null) query += 'and Area__c=\''+usr.Area__c+'\' ';
		query += 'order by name';
		for(User u : database.query(query)) {
			picklist.add(new selectOption(u.id, u.name));
		}
		return picklist;
	}
	
	public List<Selectoption> getDaysPicklist(){
		List<Selectoption> picklist = new List<selectoption>();
		picklist.add(new selectOption('', 'Number of'));
		for(Integer i=minDays; i<=maxDays; i++) {
			picklist.add(new selectOption(String.valueOf(i), String.valueOf(i)));
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
		// picklist.add(new selectOption('', '- Select a Month -'));
		for(String monthNum : monthMap.keyset()) {
			picklist.add(new selectOption(monthNum, monthMap.get(monthNum)));
		}
		return picklist;
	}
	
	public List<Selectoption> getYearPicklist(){
		List<Selectoption> picklist = new List<selectoption>();
		Integer currentYear = System.now().year();
		// picklist.add(new selectOption('', '- Select a Year -'));
		picklist.add(new selectOption(String.valueOf(currentYear-1), String.valueOf(currentYear-1)));
		picklist.add(new selectOption(String.valueOf(currentYear), String.valueOf(currentYear)));
		picklist.add(new selectOption(String.valueOf(currentYear+1), String.valueOf(currentYear+1)));
		return picklist;
	}
	
	
	private static set<Id> getSubRoleIds(set<Id> roleIds) {
		set<Id> returnRoleIds = new set<Id>();
		for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
			returnRoleIds.add(r.Id);
		}
		if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
		return returnRoleIds;
	}
	
	public PageReference changeMarket(){
		selectedCL = null;
		return toggleFilters();
	}
	
	public PageReference changeDistrict(){
		selectedCL = null;
		usr.area__c = null;
		return toggleFilters();
	}
	
	public Pagereference toggleWeekly(){
		if(weekly==false) weekly = true;
		else{
			thisweek = false;
			monthly = false;
			mtd = false;
		}
		return toggleFilters();
	}
	
	public Pagereference toggleThisWeek(){
		if(thisweek==false) thisweek = true;
		else{
			weekly = false;
			monthly = false;
			mtd = false;
		}
		return toggleFilters();
	}
	
	public Pagereference toggleMonthly(){
		if(monthly==false) monthly = true;
		else{
			thisweek = false;
			weekly = false;
			mtd = false;
		}
		return toggleFilters();
	}
	
	public Pagereference toggleMtd(){
		if(mtd==false) mtd = true;
		else{
			thisweek = false;
			weekly = false;
			monthly = false;
		}
		return toggleFilters();
	}
	
	public Pagereference toggleAudited(){
		return toggleFilters();
	}
	
	public Pagereference toggleCL(){
		return toggleFilters();
	}
	
	public Pagereference toggleDays(){
		return toggleFilters();
	}
	
	public Pagereference toggleFilters(){
		encounters = new List<Event>();
		// if(selectedCL!=null) encounters = getEncountersCL();
		// else encounters = getEncounters();
		// encounters = getEncounters();
		PageReference page = new Pagereference('/apex/SalesHD_AuditEncounters');
		if(Apexpages.currentPage().getUrl().contains('AuditReport')) page = new Pagereference('/apex/SalesHD_AuditReport');
		if(Apexpages.currentPage().getUrl().toLowerCase().contains('homepage')) page = new Pagereference('/apex/SalesHD_Homepage');
		page.getParameters().put('monthly', String.valueOf(monthly));
		page.getParameters().put('month', String.valueOf(month));
		page.getParameters().put('year', String.valueOf(year));
		page.getParameters().put('weekly', String.valueOf(weekly));
		page.getParameters().put('thisweek', String.valueOf(thisweek));
		page.getParameters().put('mtd', String.valueOf(mtd));
		page.getParameters().put('audited', String.valueOf(audited));
		page.getParameters().put('cl', String.valueOf(selectedCL));
		page.getParameters().put('days', String.valueOf(selectedNDays));
		page.getParameters().put('district', String.valueOf(usr.District__c));
		page.getParameters().put('market', String.valueOf(usr.Area__c));
		page.setRedirect(true);
		return page;
	}
	
	public Id encounterId {get; set;}
	public String auditResult {get; set;}
	public String managerComment {get; set;}
	
	public Pagereference saveAudit(){
	
		List<Event> encounters = [select Encounter_Audit__c,Encounter_Audit__r.Audit_Result__c from Event where Id=:encounterId];
		if(!encounters.isEmpty()) {
			if(encounters[0].Encounter_Audit__c==null) {
				Encounter_Audit__c audit = new Encounter_Audit__c(Audit_Result__c=auditResult);
				insert audit;
				encounters[0].Encounter_Audit__c = audit.Id;
				update encounters;
			} else{
				Encounter_Audit__c audit = new Encounter_Audit__c(id=encounters[0].Encounter_Audit__c, Audit_Result__c=auditResult);
				update audit;
			}
		}
	
		return toggleFilters();
	}
	
	
	
	
	public Pagereference saveComment(){
	
		List<Event> encounters = [select Encounter_Audit__c,Encounter_Audit__r.Audit_Result__c from Event where Id=:encounterId];
		if(!encounters.isEmpty()) {
			if(encounters[0].Encounter_Audit__c==null) {
				Encounter_Audit__c audit = new Encounter_Audit__c(Manager_Comment__c=managerComment);
				insert audit;
				encounters[0].Encounter_Audit__c = audit.Id;
				update encounters;
			} else{
				Encounter_Audit__c audit = new Encounter_Audit__c(id=encounters[0].Encounter_Audit__c, Manager_Comment__c=managerComment);
				update audit;
			}
		}
	
		return toggleFilters();
	}
	
	}
	