public with sharing class SalesHD_AuditEncounters {

private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public boolean weekly {get; set;}
public boolean monthly {get; set;}
public boolean audited {get; set;}

public List<Event> encounters {get; set;}


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

	encounters = new List<Event>();
	encounters = getEncounters();

}

public List<Event> getEncounters(){
	if(audited) {
        if(weekly){
            return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, SalesHD_Encounter_Audit__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c
		        from event where owner.userRoleId in : allSubRoleIds
                and startDateTime=Last_Week];
        } if(monthly){
            return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, SalesHD_Encounter_Audit__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c
		        from event where owner.userRoleId in : allSubRoleIds
                and startDateTime=Last_n_days:30];
        }
	} else {
        if(weekly){
            return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, SalesHD_Encounter_Audit__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c
		        from event where owner.userRoleId in : allSubRoleIds
		        and startDateTime=Last_Week and SalesHD_Encounter_Audit__c=null];
        } if(monthly) {
            return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, SalesHD_Encounter_Audit__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c
		        from event where owner.userRoleId in : allSubRoleIds
		        and startDateTime=Last_n_days:30 and SalesHD_Encounter_Audit__c=null];
        }
    }
    return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, SalesHD_Encounter_Audit__c,
		        SalesHD_Contact_Method__c, SalesHD_Topic__c, SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c, SalesHD_Data_Preparation__c,
		        SalesHD_Agenda_Preparation__c, SalesHD_Close_Customer_Commitment__c, Result__c, SalesHD_Next_Encounter__c
		        from event where owner.userRoleId in : allSubRoleIds
		        and startDateTime=Last_Week and SalesHD_Encounter_Audit__c=null];
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

public Pagereference toggleFilters(){
    encounters = new List<Event>();
	encounters = getEncounters();
    PageReference page = new Pagereference('/apex/SalesHD_AuditEncounters');
    page.getParameters().put('monthly', String.valueOf(monthly));
    page.getParameters().put('weekly', String.valueOf(weekly));
	page.getParameters().put('audited', String.valueOf(audited));
    page.setRedirect(true);
    return page;
}

}
