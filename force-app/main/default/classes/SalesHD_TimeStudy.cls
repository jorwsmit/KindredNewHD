global with sharing class SalesHD_TimeStudy {

public Date studyDate {get; set;}
public Integer totalHours {get; set;}
public Integer allowable {get; set;}
public Integer activityTime {get; set;}
public Integer nonAllowable {get; set;}
public String activityType {get; set;}
public String accountName {get; set;}
public Id accountId {get; set;}
public String patientInitials {get; set;}

public List<Time_Study_Activity__c> activitiesList {get; set;}

private static Id currentUser = UserInfo.getUserId();

public SalesHD_TimeStudy(ApexPages.StandardController stdController) {
	studyDate = System.now().date();
	activitiesList = new List<Time_Study_Activity__c>();
    activities();
}

public PageReference getActivities(){
	activities();
    return null;
}

public void activities(){
    activitiesList.clear();
    allowable = 0;
    nonAllowable = 0;
	for(Time_Study_Activity__c tsa : [select Id, Patient_Initials__c, Allowable_Time__c, Activity_Type__c, 
	                                  Referring_Facility__r.Name from Time_Study_Activity__c where Time_Study__r.Study_Date__c=:studyDate and Time_Study__r.OwnerId=:currentUser]) {
		activitiesList.add(tsa);
        allowable += Integer.valueOf(tsa.Allowable_Time__c);
	}
    if(totalHours!=null) nonAllowable = totalHours - allowable;
	
}

public List<SelectOption> getActivityOptions() {
	List<SelectOption> activityOptions = new List<SelectOption>();
	activityOptions.add(new SelectOption('','-None-'));
	activityOptions.add(new SelectOption('Type 1','Type 1'));
	activityOptions.add(new SelectOption('Type 2','Type 2'));
	activityOptions.add(new SelectOption('Type 3','Type 3'));
	activityOptions.add(new SelectOption('Type 4','Type 4'));

	return activityOptions;
}

public PageReference saveActivity() {
	try{
		// update thisUnit;
		if(patientInitials.length()>3) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Patient initials can\'t be longer than 3 characters.'));
		} else{
			List<Time_Study__c> studies = [select Id from Time_Study__c where Study_Date__c=:studyDate and OwnerId=:currentUser];
			ID tsId;
			if(studies.size()==0) {
				Time_Study__c ts = new Time_Study__c(Study_Date__c=studyDate, Non_Allowable_Time__c=totalHours);
				insert ts;
				tsId = ts.Id;
			} else{
				for(Time_Study__c t : studies) {
					tsId = t.Id;
				}
			}
			insert new Time_Study_Activity__c(Referring_Facility__c=accountId, Time_Study__c=tsId,
			                                  Patient_Initials__c=patientInitials, Activity_Type__c=activityType, Allowable_Time__c = activityTime);

			activities();
		}
	}
	catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}

	return null;
}

@RemoteAction global static String getAccounts() {
	return JSON.serializePretty([select AccountId, Account.Name from AccountTeamMember where UserId =: currentUser and Account.RecordType.Name='HD Accounts']);
}
}
