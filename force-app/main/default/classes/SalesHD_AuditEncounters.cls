public with sharing class SalesHD_AuditEncounters {

private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public boolean weekly {get; set;}
public boolean monthly {get; set;}
public boolean audited {get; set;}

public List<Event> encounters {get; set;}

public String selectedCL {get; set;}

public String selectedNDays {get; set;}

public String dateRangeStr {get; set;}

private Integer maxDays = 60;
private Integer minDays = 2;
private Integer days = minDays;


public SalesHD_AuditEncounters() {



	weekly = true;
	monthly = false;
	audited = false;

	if(ApexPages.currentPage().getParameters().get('weekly')!=null)
		weekly=Boolean.valueOf(ApexPages.currentPage().getParameters().get('weekly'));

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



	if(weekly) {
		Date d = System.Today().toStartOfWeek().addDays(-7);
		dateRangeStr = d.format() + ' - ' + d.addDays(7-1).format();
	} else if(monthly) {
		Date d = System.Today().addDays(-days);
		dateRangeStr = d.format() + ' - ' + d.addDays(days).format();
	}


	encounters = new List<Event>();
	List<User> u = [select Profile.name from User where Id=:UserInfo.getUserId()];
	if(!u.isEmpty() && ( u[0].Profile.name.contains('Associate') || u[0].Profile.name.contains('PAC') )) {
		audited=true;
		encounters = getMyEncounters();
	} else {
		// if(selectedCL!=null) encounters = getEncountersCL();
        // else encounters = getEncounters();
        encounters = getEncounters();
	}




}

// public List<Event> getEncountersCL(){
// 	if(audited) {
// 		if(weekly) {
// 			return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
// 			        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
// 			        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
// 			        Owner.Name
// 			        from event where owner.userRoleId in : allSubRoleIds
// 			        and startDateTime=Last_Week and OwnerId =: selectedCL];
// 		} if(monthly) {
// 			return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
// 			        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
// 			        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
// 			        Owner.Name
// 			        from event where owner.userRoleId in : allSubRoleIds
// 			        and startDateTime=Last_n_days :30 and OwnerId =: selectedCL];
// 		}
// 	} else{
// 		if(weekly) {
// 			return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
// 			        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
// 			        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
// 			        Owner.Name
// 			        from event where owner.userRoleId in : allSubRoleIds and Encounter_Audit__r.Audit_Result__c=null
// 			                                                                                                     and startDateTime=Last_Week and OwnerId =: selectedCL];
// 		} if(monthly) {
// 			return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
// 			        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
// 			        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
// 			        Owner.Name
// 			        from event where owner.userRoleId in : allSubRoleIds and Encounter_Audit__r.Audit_Result__c=null
// 			                                                                                                     and startDateTime=Last_n_days :30  and OwnerId =: selectedCL];
// 		}
// 	}
// 	return null;
// }

public List<Event> getEncounters(){

    String query = 'select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,'+
    'SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,'+
    'SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,'+
    'Owner.Name from event where owner.userRoleId in : allSubRoleIds';

    if(!audited) query += ' and Encounter_Audit__r.Audit_Result__c=null';

    if(weekly) query += ' and startDateTime=Last_Week';
    else if(monthly) query += ' and startDateTime=Last_n_days:'+days;

    if(selectedCL!=null) query += ' and ownerId=:selectedCL';

    return database.query(query);
	// if(audited) {
	// 	if(weekly) {
	// 		return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
	// 		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
	// 		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
	// 		        Owner.Name
	// 		        from event where owner.userRoleId in : allSubRoleIds
	// 		        and startDateTime=Last_Week];
	// 	} if(monthly) {
	// 		return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
	// 		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
	// 		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
	// 		        Owner.Name
	// 		        from event where owner.userRoleId in : allSubRoleIds
	// 		        and startDateTime=Last_n_days :30];
	// 	}
	// } else{
	// 	if(weekly) {
	// 		return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
	// 		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
	// 		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
	// 		        Owner.Name
	// 		        from event where owner.userRoleId in : allSubRoleIds and Encounter_Audit__r.Audit_Result__c=null
	// 		                                                                                                     and startDateTime=Last_Week];
	// 	} if(monthly) {
	// 		return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
	// 		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
	// 		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
	// 		        Owner.Name
	// 		        from event where owner.userRoleId in : allSubRoleIds and Encounter_Audit__r.Audit_Result__c=null
	// 		                                                                                                     and startDateTime=Last_n_days :30];
	// 	}
	// }
	// return null;
}

public List<Event> getMyEncounters(){

	if(weekly) {
		return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
		        Owner.Name
		        from event where ownerId=: UserInfo.getUserId()
		                                  and startDateTime=Last_Week];
	} if(monthly) {
		return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, Encounter_Audit__r.Rating__c, Encounter_Audit__r.Audit_Result__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c, Encounter_Audit__r.Manager_Comment__c,
		        Owner.Name
		        from event where ownerId=: UserInfo.getUserId()
		                                  and startDateTime=Last_n_days : 30];
	}
	return null;
}

public List<Selectoption> getCLPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Employee -'));
	for(User u : [select id, name from user where userRoleId in :allSubRoleIds order by name]) {
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


private static set<Id> getSubRoleIds(set<Id> roleIds) {
	set<Id> returnRoleIds = new set<Id>();
	for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
		returnRoleIds.add(r.Id);
	}
	if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
	return returnRoleIds;
}

public Pagereference toggleWeekly(){
	if(weekly==false) monthly = true;
	else monthly = false;
	return toggleFilters();
}
public Pagereference toggleMonthly(){
	if(monthly==false) weekly = true;
	else weekly = false;
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
	page.getParameters().put('monthly', String.valueOf(monthly));
	page.getParameters().put('weekly', String.valueOf(weekly));
	page.getParameters().put('audited', String.valueOf(audited));
    page.getParameters().put('cl', String.valueOf(selectedCL));
    page.getParameters().put('days', String.valueOf(selectedNDays));
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
