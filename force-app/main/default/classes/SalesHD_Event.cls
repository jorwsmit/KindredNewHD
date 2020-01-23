global with sharing class SalesHD_Event {


public Event thisEvent {get; set;}
public Date startDate {get; set;}
public String startDateFormated {get; set;}
public Time startTime {get; set;}
public Integer duration {get; set;}
public Date endDate {get; set;}
public String endDateFormated {get; set;}
public Time endTime {get; set;}
public Id contactId {get; set;}

public blob file {get; set;}
public String fileName {get; set;}
public String fileId {get; set;}

public List<ContentVersion> files {get; set;}



public String additionalContactIdString {get; set;}
public String removeAdditionalContactIdString {get; set;}
private Map<Id, String> additionalContacts {get; set;}
public String additionalContactsString {get; set;}

public String additionalTeamIdString {get; set;}
public String removeAdditionalTeamIdString {get; set;}
private Map<Id, String> additionalTeam {get; set;}
public String additionalTeamString {get; set;}

public Id accountId {get; set;}
public Id unitId {get; set;}



public String selectedRecurrenceType {get; set;}
public Boolean displayRecurrence {get; set;}

public String contactName {get; set;}
public String accountName {get; set;}
public String unitName {get; set;}

public String unitList {get; set;}

public String encounters {get; set;}

public String ownerPhotoUrl {get; set;}




private static Id currentUser = UserInfo.getUserId();

public SalesHD_Event(ApexPages.StandardController stdController) {


	if(ApexPages.CurrentPage().getparameters().get('id')!=null) {
		List<Id> fileIds = new List<Id>();
		for(ContentDocumentLink cdl : [select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:ApexPages.CurrentPage().getparameters().get('id')]) {
			fileIds.add(cdl.ContentDocumentId);
		}
		files = new List<ContentVersion>();
		for(ContentVersion cv : [select Id, ContentDocumentId, Title, TextPreview from ContentVersion where ContentDocumentId =: fileIds and isLatest=true]) {
			files.add(cv);
		}
	}


	startDate = Date.valueOf(System.now());
	startTime = Time.newInstance(System.now().hour(), System.now().minute()-(math.mod(System.now().minute(), 15)),0,0);
	duration = 15;
	Datetime endDatetime = Datetime.newInstance(startDate, startTime);
	endDatetime = endDatetime.addMinutes(15);
	endTime = endDatetime.time();
	endDate = endDatetime.date();

	thisEvent = (Event)stdController.getRecord();

	for(Event e : [select Id, OwnerId, CreatedById, StartDatetime, EndDatetime, WhoId, Who.Name,
	               WhatId, What.Name, SalesHD_Account_Unit__c, SalesHD_Account_Unit__r.Unit__r.Name from Event where Id=:ApexPages.CurrentPage().getparameters().get('id')]) {
		if(e.StartDatetime!=null) {
			startDateFormated = e.StartDatetime.format();
			startDate = e.StartDatetime.date();
			startTime = e.StartDatetime.time();
		}
		if(e.EndDatetime!=null) {
			endDateFormated = e.EndDatetime.format();
			endDate = e.EndDatetime.date();
			endTime = e.EndDatetime.time();

			Long dt1Long = e.StartDatetime.getTime();
			Long dt2Long = e.EndDatetime.getTime();
			Long milliseconds = dt2Long - dt1Long;
			Long seconds = milliseconds / 1000;
			duration = Integer.valueOf(seconds / 60);
		}
		if(e.WhoId!=null) {
			contactId = e.WhoId;
			contactName = e.Who.Name;
		}
		if(e.WhatId!=null) {
			accountId = e.WhatId;
			accountName = e.What.Name;
		}
		if(e.SalesHD_Account_Unit__c!=null) {
			unitId = e.SalesHD_Account_Unit__c;
			if(e.SalesHD_Account_Unit__r.Unit__r.Name=='Administrative') unitName = 'Global / Director';
			else unitName = e.SalesHD_Account_Unit__r.Unit__r.Name;
		}
	}

	additionalContacts = new Map<Id, String>();
	additionalContactIdString = '';
	additionalTeam = new Map<Id, String>();
	additionalTeamIdString = '';
	for(EventRelation er : [select Relation.Name, RelationId from EventRelation where EventId=:ApexPages.CurrentPage().getparameters().get('id') and IsInvitee=true]) {
		if(String.valueOf(er.RelationId).left(3)=='003') {
			additionalContacts.put(er.RelationId, er.Relation.Name);
			additionalContactIdString += er.RelationId+',';
		} else if(String.valueOf(er.RelationId).left(3)=='005') {
			additionalTeam.put(er.RelationId, er.Relation.Name);
			additionalTeamIdString += er.RelationId+',';
		}

	}


	additionalContactIdString.removeEnd(',');
	additionalContactsString = JSON.serializePretty(additionalContacts);

	additionalTeamIdString.removeEnd(',');
	additionalTeamString = JSON.serializePretty(additionalTeam);

	unitList = '[]';
	for(Account a : [select Id, Name from Account where Id=:ApexPages.CurrentPage().getparameters().get('accountId') or Id=:accountId limit 1]) {
		accountId = a.Id;
		accountName = a.Name;
		unitList = getUnits(a.Id);
	}

	for(Account_Unit__c au : [select Account__c, Account__r.Name, Unit__r.Name, Id from Account_Unit__c where Id=:ApexPages.CurrentPage().getparameters().get('unitId') limit 1]) {
		accountId = au.Account__c;
		accountName = au.Account__r.Name;
		unitId = au.Id;
		unitName = au.Unit__r.Name;
		unitList = getUnits(au.Account__c);
	}

	for(Contact c : [select Id, Name from Contact where Id=:ApexPages.CurrentPage().getparameters().get('contactId') limit 1]) {
		contactId = c.Id;
		contactName = c.Name;
	}


	List<Event> encountersList = new List<Event>();
	for(Event e : [select Id, SalesHD_Complete__c, Subject, Type, OwnerId, CreatedById from Event where OwnerId=:currentUser and ActivityDate=THIS_MONTH]) {
		encountersList.add(e);
	}
	encounters = JSON.serializePretty(encountersList);

	if(ApexPages.CurrentPage().getparameters().get('duplicate')=='true') {

	}

}

@RemoteAction global static String getTeam(){
	String roleId = '';
	for(UserRole ur : [select Id from UserRole where name = 'HD - VP']) {
		roleId = ur.Id;
	}
	set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {roleId});
	allSubRoleIds.add(roleId);
	return JSON.serializePretty([select Name, Id from User where isActive=true and UserRoleId in: allSubRoleIds order by Name asc]);
	return null;
}

@RemoteAction global static String getContacts() {
	return JSON.serializePretty([select Contact__r.Id, Contact__r.Name from Contact_Team__c where User__c =: currentUser order by Contact__r.LastActivityDate desc nulls last, Contact__r.name asc]);
}

@RemoteAction global static String getAccounts() {
	return JSON.serializePretty([select AccountId, Account.Name from AccountTeamMember where UserId =: currentUser and Account.RecordType.Name='HD Accounts' order by Account.LastActivityDate desc nulls last, Account.Name asc]);
}

@RemoteAction global static String getUnits(Id accountId) {
	return JSON.serializePretty([select Id, Unit__r.Name from Account_Unit__c where Account__c =: accountId and Active__c=true]);
}

public void selectRecurrenceType() {
	if(selectedRecurrenceType == 'RecursDaily') {
		thisEvent.RecurrenceType = 'RecursDaily';
	} else if(selectedRecurrenceType == 'RecursWeekly') {
		thisEvent.RecurrenceType = 'RecursWeekly';
	} else if(selectedRecurrenceType == 'RecursMonthly') {
		thisEvent.RecurrenceType = 'RecursMonthly';
	}
}

private static Integer getRecurrenceWeekdayMask(Integer weekday){
	if(weekday==0) return 1;
	if(weekday==1) return 2;
	if(weekday==2) return 4;
	if(weekday==3) return 8;
	if(weekday==4) return 16;
	if(weekday==5) return 32;
	if(weekday==6) return 64;
	return null;
}

public PageReference uploadFiles(){
	try{
		List<ContentVersion> cvs = new List<ContentVersion>();
		if(file!=null) cvs.add(prepareFile(file, fileName));
		insert cvs;
		List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
		List<Id> cdIds = new List<Id>();
		for(ContentVersion cv : [select ContentDocumentId from ContentVersion where Id in :cvs]) {
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = cv.ContentDocumentId;
			cdIds.add(cv.ContentDocumentId);
			cdl.LinkedEntityId = thisEvent.Id;
			cdl.ShareType = 'V';
			cdls.add(cdl);
		}
		insert cdls;

		List<Id> fileIds = new List<Id>();
		for(ContentDocumentLink cdl : [select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:thisEvent.Id]) {
			fileIds.add(cdl.ContentDocumentId);
		}
		files = new List<ContentVersion>();
		for(ContentVersion cv : [select Id, ContentDocumentId, Title, TextPreview from ContentVersion where ContentDocumentId =: fileIds and isLatest=true]) {
			files.add(cv);
		}


	}catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_Encounter?id='+thisEvent.Id);
	page.setRedirect(true);
	return page;
}

public PageReference deleteFiles(){
	try{
		ContentDocument cd = [select id from ContentDocument where Id in (select ContentDocumentId from ContentVersion where Id=:fileId) limit 1];
		delete cd;

		List<Id> fileIds = new List<Id>();
		for(ContentDocumentLink cdl : [select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:thisEvent.Id]) {
			fileIds.add(cdl.ContentDocumentId);
		}
		files = new List<ContentVersion>();
		for(ContentVersion cv : [select Id, ContentDocumentId, Title, TextPreview from ContentVersion where ContentDocumentId =: fileIds and isLatest=true]) {
			files.add(cv);
		}
	}catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	return null;
}

private static ContentVersion prepareFile(blob file, String fileName){
	ContentVersion cv = new ContentVersion();
	cv.versionData = file;
	cv.title = fileName;
	cv.pathOnClient = fileName;
	return cv;
}

public PageReference saveEvent(){

	thisEvent.WhoId = contactId;
	thisEvent.WhatId = accountId;
	thisEvent.SalesHD_Account_Unit__c = unitId;
	thisEvent.Subject = thisEvent.Type;

	thisEvent.StartDateTime = Datetime.newInstance(startDate, startTime);
	thisEvent.EndDateTime = thisEvent.StartDateTime.addMinutes(duration);
	// thisEvent.EndDateTime = Datetime.newInstance(endDate, endTime);

	if(thisEvent.IsRecurrence) {

		thisEvent.RecurrenceStartDateTime = thisEvent.StartDateTime;
		thisEvent.RecurrenceInterval = 1;

		if(selectedRecurrenceType == null) {
			selectedRecurrenceType = 'RecursDaily';
			thisEvent.RecurrenceType = selectedRecurrenceType;
		}

		if(selectedRecurrenceType == 'RecursDaily') {
			thisEvent.RecurrenceEndDateOnly = Date.valueOf(thisEvent.RecurrenceStartDateTime.addDays(3));
		} else if(selectedRecurrenceType == 'RecursWeekly') {
			Date tempDate = Date.valueOf(thisEvent.StartDateTime).toStartofWeek();
			integer dayOfWeek = tempDate.daysBetween(Date.valueOf(thisEvent.StartDateTime));
			thisEvent.RecurrenceDayOfWeekMask = getRecurrenceWeekdayMask(dayOfWeek);
			thisEvent.RecurrenceEndDateOnly = Date.valueOf(thisEvent.RecurrenceStartDateTime.addDays(7*3));
		} else if(selectedRecurrenceType == 'RecursMonthly') {
			thisEvent.RecurrenceDayOfMonth = thisEvent.RecurrenceStartDateTime.day();
			thisEvent.RecurrenceEndDateOnly = Date.valueOf(thisEvent.RecurrenceStartDateTime.addMonths(3));
		}

	}

	PageReference eventPage = null;

	try{
		if(thisEvent.SalesHD_Complete__c==true && (thisEvent.Result__c==null || thisEvent.SalesHD_Close_Customer_Commitment__c==null)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Results and Close / Customer Commitment must be filled out for a complete encounter.'));
		} else{
			if(ApexPages.CurrentPage().getparameters().get('duplicate')=='true') {
				Event tempEvent = new Event();
				tempEvent = thisEvent.clone(false, true);
				tempEvent.Result__c=null;
				tempEvent.SalesHD_Close_Customer_Commitment__c=null;
				tempEvent.SalesHD_Complete__c=false;
				insert tempEvent;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, additionalContactIdString));
				additionalContacts.clear();
				additionalRelatedContacts(tempEvent);
				removeRelatedContacts(tempEvent);

				additionalTeam.clear();
				additionalRelatedTeamMembers(tempEvent);
				removeRelatedTeamMembers(tempEvent);
				eventPage = new PageReference('/apex/SalesHD_Encounter?id='+tempEvent.Id);
			} else {
				upsert thisEvent;
				removeRelatedContacts(thisEvent);
				additionalRelatedContacts(thisEvent);

				additionalRelatedTeamMembers(thisEvent);
				removeRelatedTeamMembers(thisEvent);
				eventPage = new PageReference('/apex/SalesHD_Encounter?id='+thisEvent.Id);
			}
		}
	}
	catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}

	return eventPage;

}

public PageReference saveNew() {
	PageReference eventPage = null;
	eventPage = saveEvent();
	if(eventPage!=null) eventPage.setRedirect(true);
	return eventPage;
}

private void removeRelatedContacts(Event e){
	List<EventRelation> removeEventContacts = new List<EventRelation>();
	Set<String> removeContactIds = new Set<String>();
	if(removeAdditionalContactIdString!=null && removeAdditionalContactIdString!='') {
		removeContactIds.addAll(removeAdditionalContactIdString.split(','));
		for(EventRelation er : [select RelationId from EventRelation where EventId=:e.Id and IsParent=false]) {
			if(removeContactIds.contains(er.RelationId)) removeEventContacts.add(er);
		}
		delete removeEventContacts;
	}
}

private void removeRelatedTeamMembers(Event e){
	List<EventRelation> removeEventTeamMembers = new List<EventRelation>();
	Set<String> removeTeamIds = new Set<String>();
	if(removeAdditionalTeamIdString!=null && removeAdditionalTeamIdString!='') {
		removeTeamIds.addAll(removeAdditionalTeamIdString.split(','));
		for(EventRelation er : [select RelationId from EventRelation where EventId=:e.Id and IsParent=false]) {
			if(removeTeamIds.contains(er.RelationId)) removeEventTeamMembers.add(er);
		}
		delete removeEventTeamMembers;
	}
}

private void additionalRelatedContacts(Event e ){
	List<EventRelation> additionalEventContacts = new List<EventRelation>();
	if(additionalContactIdString!=null && additionalContactIdString!='') {
		for(Id additionalContactId : additionalContactIdString.split(',')) {
			if(!additionalContacts.containsKey(additionalContactId) && e.WhoId!=additionalContactId) additionalEventContacts.add(new EventRelation(RelationId=additionalContactId, IsInvitee=true, EventId=e.Id));
		}
		insert additionalEventContacts;
	}
}

private void additionalRelatedTeamMembers(Event e ){
	List<EventRelation> additionalEventTeamMembers = new List<EventRelation>();
	if(additionalTeamIdString!=null && additionalTeamIdString!='') {
		List<Id> teamToEmail = new List<Id>();
		for(Id additionalTeamId : additionalTeamIdString.split(',')) {
			if(!additionalTeam.containsKey(additionalTeamId) && e.OwnerId!=additionalTeamId
			   && e.CreatedById!=additionalTeamId) {
				additionalEventTeamMembers.add(new EventRelation(RelationId=additionalTeamId, IsInvitee=true, EventId=e.Id));
				teamToEmail.add(additionalTeamId);

			}
		}
		insert additionalEventTeamMembers;
		if(!teamToEmail.isEmpty()) emailKindredTeam(teamToEmail, e);
	}
}


private static void emailKindredTeam(List<Id> userIds, Event e){

	String location = '';
	for(Account a : [select shippingAddress__c from Account where id=:e.whatId]) {
		location = a.shippingAddress__c;
	}


	Messaging.reserveSingleEmailCapacity(2);

	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

	List<String> toAddresses = new List<String>();
	for(User u : [select email from user where Id in :userIds]) {
		toAddresses.add(u.email);
	}

	mail.setToAddresses(toAddresses);
	mail.setReplyTo(UserInfo.getUserEmail());
	mail.setSenderDisplayName(UserInfo.getName());
	mail.setSubject('Salesforce Meeting Invitation - '+e.startDateTime.format());
	mail.setPlainTextBody(emailBody(e, location)+'<br/><br/>'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/saleshd_encounter?id='+e.Id);
	mail.setHtmlBody(emailBody(e, location)+'<br/><br/><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/saleshd_encounter?id='+e.Id+'">Open Encounter in Salesforce</a>');
	Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
	attach.filename = 'meeting.ics';
	attach.ContentType = 'text/calendar;';

	attach.setBody(invite(e, location));
	attach.setContentType('text/calendar; charset=utf-8; method=REQUEST');

	mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

}


public PageReference saveCompleteEvent() {
	PageReference eventPage = null;
	try{
		thisEvent.SalesHD_Complete__c=true;
		update thisEvent;
		eventPage = new PageReference('/apex/SalesHD_Encounter?id='+thisEvent.Id);
	}
	catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	return eventPage;
}

public PageReference completeEvent() {
	PageReference eventPage = saveCompleteEvent();
	if(eventPage!=null) eventPage.setRedirect(true);
	return eventPage;
}

public PageReference completeAndNew() {
	saveCompleteEvent();
	PageReference eventPage = new PageReference('/apex/SalesHD_NewEncounter');
	eventPage.setRedirect(true);
	return eventPage;
}

public PageReference completeAndNext() {
	PageReference eventPage = null;
	try{
		thisEvent.SalesHD_Complete__c=true;
		update thisEvent;

		Event tempEvent = new Event();
		Event e = [select StartDateTime, EndDateTime, WhoId, WhatId,
		           SalesHD_Account_Unit__c, Type, SalesHD_Call_Objective__c,
		           SalesHD_Open_Ended_Questions__c, SalesHD_Marketing_Collateral__c,
		           SalesHD_Agenda_Preparation__c, SalesHD_Data_Preparation__c,
		           Subject, OwnerId, CreatedById from Event where Id=:thisEvent.Id];
		tempEvent = e.clone(false, true);
		tempEvent.SalesHD_Last_Encounter__c = thisEvent.SalesHD_Next_Encounter__c;
		insert tempEvent;
		additionalContacts.clear();
		additionalRelatedContacts(tempEvent);

		additionalTeam.clear();
		additionalRelatedTeamMembers(tempEvent);
		eventPage = new PageReference('/apex/SalesHD_NewEncounter?id='+tempEvent.Id);
	}
	catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	if(eventPage!=null) eventPage.setRedirect(true);
	return eventPage;
}

public PageReference saveAndNext() {

	thisEvent.WhoId = contactId;
	thisEvent.WhatId = accountId;
	thisEvent.SalesHD_Account_Unit__c = unitId;
	thisEvent.Subject = thisEvent.Type;

	thisEvent.StartDateTime = Datetime.newInstance(startDate, startTime);
	thisEvent.EndDateTime = thisEvent.StartDateTime.addMinutes(duration);
	// thisEvent.EndDateTime = Datetime.newInstance(endDate, endTime);

	PageReference eventPage = null;

	try{
		if(thisEvent.SalesHD_Complete__c==true && (thisEvent.Result__c==null || thisEvent.SalesHD_Close_Customer_Commitment__c==null)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Results and Close / Customer Commitment must be filled out for a complete encounter.'));
		} else{
			if(ApexPages.CurrentPage().getparameters().get('duplicate')=='true') {
				Event tempEvent = new Event();
				tempEvent = thisEvent.clone(false, true);
				insert tempEvent;
				additionalRelatedContacts(tempEvent);
				removeRelatedContacts(tempEvent);

				additionalRelatedTeamMembers(tempEvent);
				removeRelatedTeamMembers(tempEvent);
				Event tempEvent2 = new Event();
				tempEvent2 = tempEvent.clone(false, true);
				tempEvent2.SalesHD_Next_Encounter__c = null;
				tempEvent2.Result__c=null;
				tempEvent2.SalesHD_Close_Customer_Commitment__c=null;
				tempEvent2.SalesHD_Complete__c=false;
				tempEvent2.SalesHD_Last_Encounter__c = tempEvent.SalesHD_Next_Encounter__c;
				insert tempEvent2;
				additionalRelatedContacts(tempEvent2);
				removeRelatedContacts(tempEvent2);

				additionalRelatedTeamMembers(tempEvent2);
				removeRelatedTeamMembers(tempEvent2);

				eventPage = new PageReference('/apex/SalesHD_NewEncounter?id='+tempEvent2.Id);
			} else {
				upsert thisEvent;
				removeRelatedContacts(thisEvent);
				additionalRelatedContacts(thisEvent);

				removeRelatedTeamMembers(thisEvent);
				additionalRelatedTeamMembers(thisEvent);
				Event tempEvent = new Event();
				tempEvent = thisEvent.clone(false, true);
				tempEvent.SalesHD_Next_Encounter__c = null;
				tempEvent.Result__c=null;
				tempEvent.SalesHD_Close_Customer_Commitment__c=null;
				tempEvent.SalesHD_Complete__c=false;
				tempEvent.SalesHD_Last_Encounter__c = thisEvent.SalesHD_Next_Encounter__c;
				insert tempEvent;
				additionalRelatedContacts(tempEvent);
				removeRelatedContacts(tempEvent);

				additionalRelatedTeamMembers(tempEvent);
				removeRelatedTeamMembers(tempEvent);
				eventPage = new PageReference('/apex/SalesHD_NewEncounter?id='+tempEvent.Id);
			}
		}
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}

	if(eventPage!=null) eventPage.setRedirect(true);
	return eventPage;
}

public PageReference saveAndNew() {
	PageReference eventPage = null;
	eventPage = saveEvent();
	if(eventPage!=null) {
		eventPage = new PageReference('/apex/SalesHD_NewEncounter');
		eventPage.setRedirect(true);
	}
	return eventPage;
}

public PageReference deleteEvent() {
	PageReference eventPage = null;
	try{
		delete thisEvent;
		eventPage = new PageReference('/apex/SalesHD_Encounters');
		eventPage.setRedirect(true);
	}
	catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	return eventPage;
}

public PageReference recurrenceClicked() {

	displayRecurrence = thisEvent.IsRecurrence;

	return null;
}


public class calendarEvent {
public Id eventId;
public String eventSubject;
public Datetime eventDatetime;
public Boolean complete;
public Boolean isInvitee;
}

@RemoteAction global static String getCalendar(Integer monthOffset, Integer weekOffset, Boolean isWeekly, Id userId){
	Datetime firstDay;
	Integer numberOfDays;
	if(isWeekly) {
		firstDay =  Datetime.newInstance(Date.valueOf(System.now()).addDays(weekOffset*7).toStartOfWeek(), System.now().time());
		numberOfDays = 7;
	} else{
		firstDay =  Datetime.newInstance(Date.valueOf(System.now()).addMonths(monthOffset).toStartOfMonth(), System.now().time());
		numberOfDays = Date.daysInMonth(firstDay.year(), firstDay.month());
	}

	String startDay = String.valueOf(firstDay.format('EEEE'));
	Date lowDate = Date.newInstance(firstDay.year(), firstDay.month(), firstDay.day());
	// Date highDate = Date.newInstance(firstDay.year(), firstDay.addDays(numberOfDays).month(), firstDay.addDays(numberOfDays).day());
	Date highDate = lowDate.addDays(numberOfDays);

	List<Event> eventList = [select id, subject, StartDateTime, EndDateTime, SalesHD_Complete__c, description,
	                         who.name, SalesHD_Call_Objective__c, SalesHD_Open_Ended_Questions__c, OwnerId, CreatedById from event where
	                         ownerId=:userId and startDateTime>=:lowDate and endDateTime<=:highDate];

	List<EventRelation> eventRelationList = [select eventId, event.subject, event.StartDateTime, event.EndDateTime,
	                                         event.SalesHD_Complete__c, event.description, event.who.name, event.SalesHD_Call_Objective__c,
	                                         event.SalesHD_Open_Ended_Questions__c, event.OwnerId, event.CreatedById from EventRelation where
	                                         RelationId=:userId and event.startDateTime>=:lowDate and event.endDateTime<=:highDate];

	List<Id> whoIds = new List<Id>();
	for(Event e : eventList) {
		if(e.WhoId!=null) whoIds.add(e.WhoId);
	}
	Map<Id, Contact> contactTiles = new Map<Id, Contact>([select Id, Title__c from contact where Id in: whoIds]);
	Map<Integer, List<calendarEvent> > calendarEvents = new Map<Integer, List<calendarEvent> >();
	for(Event e : eventList) {
		String eventSubject = '';
		if(e.Subject == 'Assessment') {
			eventSubject = String.valueOf(event.Description);
			if(eventSubject!=null && (eventSubject.contains('Submitted Assessment for ') || eventSubject.contains('Submitted Reassessment for '))) {
				eventSubject = eventSubject.replace('Submitted Assessment for ', '').replace('Submitted Reassessment for ', '');
				eventSubject = eventSubject + ': Assessment';
			}
		} else if(e.Who.Name != null) {
			if(contactTiles.containsKey(e.WhoId)) eventSubject = e.Who.Name + ' - '+contactTiles.get(e.WhoId).Title__c+': '+e.SalesHD_Call_Objective__c;
			else eventSubject = e.Who.Name + ': '+e.SalesHD_Call_Objective__c;
		}
		calendarEvent temp = new calendarEvent();
		temp.eventId=e.Id; temp.eventSubject=eventSubject; temp.eventDatetime=e.startDateTime;
		temp.complete=e.SalesHD_Complete__c;
		if(calendarEvents.containsKey(e.startDateTime.day())) {
			calendarEvents.get(e.startDateTime.day()).add(temp);
		} else{
			calendarEvents.put(e.startDateTime.day(), new List<calendarEvent> {temp});
		}
	}

	return '{"startDay": "'+startDay+'", "startDayNumber": '+firstDay.day()+', "numberOfDays": '+numberOfDays+', "events":'+JSON.serialize(calendarEvents)+',"lowDate": "'+lowDate.format()+'","highDate": "'+highDate.format()+'"}';
}

@RemoteAction global static List<User> getUsersUnderRoleId(Id roleId) {
	set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {roleId});
	return [select Id, Name, UserRoleId, UserRole.Name from User where UserRoleId in : allSubRoleIds and IsActive=true];
}

private static set<Id> getSubRoleIds(set<Id> roleIds) {
	set<Id> returnRoleIds = new set<Id>();
	for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
		returnRoleIds.add(r.Id);
	}
	if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
	return returnRoleIds;
}

@RemoteAction global static String getUsersByRole(String roleId) {
	String currentRoleName = '';
	List<UserRole> currentRoleNameList = [select Name from UserRole where Id = :roleId];
	if(!currentRoleNameList.isEmpty()) {
		currentRoleName = currentRoleNameList[0].Name;
	}
	List<UserRole> subRoles = [select Id, Name from UserRole where parentRoleId = :roleId order by Name];
	List<User> users = [select Id, Name from User where UserRoleId = :roleId and isActive=true order by Name];
	return '{ "currentRoleName":"'+currentRoleName+
	       '", "subRoles": '+JSON.serializePretty(subRoles)+
	       ', "users": '+JSON.serializePretty(users)+'  }';
}

@RemoteAction global static String getDay(String dateString){
	Time startTime = Time.newInstance(0,0,0,0);
	Time endTime = Time.newInstance(23,59,59,999);
	Datetime startDate = Datetime.newInstance(System.now().date(), startTime);
	Datetime endDate = Datetime.newInstance(System.now().date(), endTime);
	if(dateString!=null) {
		Date d = Date.valueOf(dateString);
		startDate = Datetime.newInstance(d, startTime);
		endDate= Datetime.newInstance(d, endTime);
	}
	// return startDate.format() + ' '+endDate.format();

	return JSON.serialize([select id, subject, StartDateTime, EndDateTime, SalesHD_Complete__c, description,
	                       who.name, SalesHD_Call_Objective__c, SalesHD_Open_Ended_Questions__c, OwnerId, CreatedById from event
	                       where ownerId=: currentUser and startDateTime>=: startDate and endDateTime<=: endDate]);
}

public PageReference addToOutlook(){
	Event e = [select Id, startDateTime, endDatetime, whatId, Subject, SalesHD_Call_Objective__c,
	           Owner.Name, Who.Name, OwnerId, CreatedById from event where Id=:thisEvent.Id];
	String location = '';
	for(Account a : [select shippingAddress__c from Account where id=:e.whatId]) {
		location = a.shippingAddress__c;
	}


	Messaging.reserveSingleEmailCapacity(2);

	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

	String[] toAddresses = new String[] {UserInfo.getUserEmail()};

	mail.setToAddresses(toAddresses);
	mail.setReplyTo(UserInfo.getUserEmail());
	mail.setSenderDisplayName(UserInfo.getName());
	mail.setSubject('Salesforce Meeting Invitation - '+e.startDateTime.format());
	mail.setPlainTextBody(emailBody(e, location)+'<br/><br/>'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/saleshd_encounter?id='+e.Id);
	mail.setHtmlBody(emailBody(e, location)+'<br/><br/><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/saleshd_encounter?id='+e.Id+'">Open Encounter in Salesforce</a>');
	Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
	attach.filename = 'meeting.ics';
	attach.ContentType = 'text/calendar;';

	attach.setBody(invite(e, location));
	attach.setContentType('text/calendar; charset=utf-8; method=REQUEST');

	mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

	return null;
}

private static String emailBody(Event e, String location){

	List<String> contactNames = new List<String>();
	List<String> kindredTeamNames = new List<String>();
	for(EventRelation er : [select Relation.Name, RelationId from EventRelation where EventId=:e.Id and IsInvitee=true]) {
		if(String.valueOf(er.RelationId).left(3)=='003') {
			contactNames.add(er.Relation.Name);
		} else if(String.valueOf(er.RelationId).left(3)=='005') {
			kindredTeamNames.add(er.Relation.Name);
		}
	}



	String emailBody = 'The following meeting was generated from a Kindred Salesforce encounter.'+
	                   ' If you have access to Kindred\'s Salesforce Org, then you may use the link to open the encounter in Salesforce.'+
	                   '<br/><br/>When: '+e.StartDateTime.format()+ ' to ' + e.EndDateTime.format() +
	                   '<br/>Location: '+location+
	                   '<br/>Kindred Team Members: ';
	for(String name : kindredTeamNames) emailBody += name +', ';
	emailBody.removeEnd(', ');
	emailBody +='<br/>Contacts: ' + e.Who.Name;
	for(String name : contactNames) emailBody += ', ' + name;
	// for(EventRelation er : [select Relation.Name, RelationId from EventRelation where EventId=:e.Id and IsInvitee=true]) {
	// 	emailBody += ', '+ er.Relation.Name;
	// }
	emailBody += '<br/>Encounter Invitation From: '+UserInfo.getName();
	return emailBody;
}

private static Blob invite(Event e, String location) {
	Integer offset = UserInfo.getTimezone().getOffset(e.startDateTime);
	String start = String.valueOf(e.startDateTime.addSeconds(math.abs(offset)/1000)).replaceAll('-', '').replaceAll(' ','T').replaceAll(':','')+'Z';
	offset = UserInfo.getTimezone().getOffset(e.endDateTime);
	String ending = String.valueOf(e.endDateTime.addSeconds(math.abs(offset)/1000)).replaceAll('-', '').replaceAll(' ','T').replaceAll(':','')+'Z';
	offset = UserInfo.getTimezone().getOffset(system.now());
	String current = String.valueOf(system.now().addSeconds(math.abs(offset)/1000)).replaceAll('-', '').replaceAll(' ','T').replaceAll(':','')+'Z';
	String attachment = 'BEGIN:VCALENDAR' + '\n' + 'PRODID:-//Force.com Labs//iCalendar Export//EN' + '\n' +
	                    'VERSION:2.0' + '\n' + 'CALSCALE:GREGORIAN' + '\n' + 'METHOD:REQUEST'+ '\n'+ 'BEGIN:VEVENT'+ '\n' +
	                    'DTSTART:'+ start + '\n' + 'DTEND:'+ ending + '\n' + 'DTSTAMP:'+ current + '\n' + 'LOCATION:'+ location + '\n'+
	                    'ORGANIZER;CN=noreply@salesforce.com:MAILTO:noreply@salesforce.com\n' + 'UID:' + String.valueOf(Crypto.getRandomLong()) + '\n' +
	                    'CREATED:'+ current + '\n' + 'LAST-MODIFIED:'+ current + '\n' +
	                    'SEQUENCE:0' + '\n' + 'STATUS:CONFIRMED' + '\n' + 'SUMMARY:'+ e.SalesHD_Call_Objective__c +'\n' + 'TRANSP:OPAQUE' + '\n' +
	                    'END:VEVENT'+ '\n' + 'END:VCALENDAR';
	return Blob.valueof(attachment);
}

}