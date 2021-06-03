global without sharing class SalesHD_Account {

public Account acct {get; set;}

public List<notes> notesList {get; set;}
public String notes {get; set;}
public String noteTitle {get; set;}
public String noteBody {get; set;}
public blob file {get; set;}
public String fileName {get; set;}

private static Id currentUser = UserInfo.getUserId();

private static List<String> csuiteTitles = new List<String> {'CCO', 'CEO', 'CFO', 'COO', 'CMO'};

public class updateUnit {
public Id unitId;
public Boolean isActive;
}

public class unitList {
public String name;
public Id unitId;
public String contactCount = 'No Contacts';
public String census = '';
public String beds = '';
public String censusDate = '';
public String nickname = '';
public Boolean isActive;
}

public class notes {
public String noteId;
public String title;
public String body;
public String fileLink;
}


public SalesHD_Account(ApexPages.StandardController stdController) {
	acct = (Account)stdController.getRecord();
	notes = JSON.serializePretty(getNotes(acct.Id));
	notesList = getNotes(acct.Id);
}

public Pagereference managedCareRedirect(){
	if([select RecordType.Name from account where Id=:acct.Id][0].RecordType.name.contains('Managed Care')) {
		PageReference page = new PageReference('/apex/SalesHD_MCO?id='+acct.Id);
		page.setRedirect(true);
		return page;
	}
	return null;
}

@RemoteAction global static String getCsuite(Id acctId){
	List<Id> administrativeContactIds = new List<Id>();
	for(Account_unit_contact__c auc : [select Contact__c from Account_unit_contact__c
	                                   where Account_unit__r.Account__c=:acctId and Account_Unit__r.Unit__r.Name='Administrative']) {
		administrativeContactIds.add(auc.Contact__c);
	}

	return JSON.serializePretty([select Name, Title__c from Contact where Title__c in: csuiteTitles and
	                                     (Id in: administrativeContactIds)]);
}

@RemoteAction global static String getDirectors(Id acctId){
	List<Id> administrativeContactIds = new List<Id>();
	for(Account_unit_contact__c auc : [select Contact__c from Account_unit_contact__c
	                                   where Account_unit__r.Account__c=:acctId and Account_Unit__r.Unit__r.Name='Administrative']) {
		administrativeContactIds.add(auc.Contact__c);
	}

	return JSON.serializePretty([select Name, Title__c from Contact where Title__c like '%Director%' and
	                                     (Id in: administrativeContactIds)]);
}

@RemoteAction global static String getContacts(Id acctId){
	List<Id> administrativeContactIds = new List<Id>();
	for(Account_unit_contact__c auc : [select Contact__c from Account_unit_contact__c
	                                   where Account_unit__r.Account__c=:acctId and Account_Unit__r.Unit__r.Name='Administrative']) {
		administrativeContactIds.add(auc.Contact__c);
	}

	return JSON.serializePretty([select Name, Title__c from Contact where Title__c not in: csuiteTitles and
	                                     (not Title__c like '%Director%') and (Id in: administrativeContactIds)]);
}

@RemoteAction global static String getFavoritedContacts(){
	return JSON.serializePretty([select Contact__r.Name from Contact_Team__c where Contact__r.Status__c='Active' and User__c =: currentUser]);
}

@RemoteAction global static void saveContact(Id acctId, Id contactId){
	List<Account_Unit__c> au = [select Id from Account_Unit__c where Account__c=:acctId and Unit__r.Name='Administrative' limit 1];
	List<Account_Unit_Contact__c> auc = [select id from Account_Unit_Contact__c where Account_Unit__c in :au and Contact__c=:contactId];
	if(auc.isEmpty()) insert new Account_Unit_Contact__c(Account_Unit__c=au[0].Id, Contact__c=contactId);
}



@RemoteAction global static String getUnits(Id acctId){
	List<unitList> units = new List<unitList>();
	Map<Id, Integer> contactCount = new Map<Id, Integer>();

	for(AggregateResult ar : [select Account_unit__c, count(Contact__c) from Account_unit_contact__c
	                          where Account_unit__r.Account__c=:acctId group by Account_unit__c]) {
		contactCount.put(String.valueOf(ar.get('Account_unit__c')), Integer.valueOf(ar.get('expr0')));
	}
	for(Account_Unit__c au : [select Unit__r.Name, Id, Active__c, SalesHD_Unit_Census_Date__c,
	                          SalesHD_Unit_Census__c, SalesHD_Unit_Beds__c, SalesHD_Unit_Nickname__c from Account_Unit__c
	                          where Account__c = :acctId and Unit__r.Name!='Administrative' and Unit__r.Active__c=true]) {
		unitList temp = new unitList();
		temp.name = au.Unit__r.Name;
		if(au.SalesHD_Unit_Nickname__c!=null) temp.nickname = au.SalesHD_Unit_Nickname__c;
		temp.unitId = au.Id;
		temp.isActive = au.Active__c;
		if(au.SalesHD_Unit_Census_Date__c!=null) temp.censusDate = '<b>Census Date</b></br>'+au.SalesHD_Unit_Census_Date__c.format();
		if(au.SalesHD_Unit_Census__c!=null) temp.census = '<b>Census</b></br>'+au.SalesHD_Unit_Census__c;
		if(au.SalesHD_Unit_Census__c!=null) temp.beds = '<b>Total Beds</b></br>'+au.SalesHD_Unit_Beds__c;
		if(contactCount.containsKey(au.Id) && contactCount.get(au.Id)>1) {
			temp.contactCount = String.valueOf(contactCount.get(au.Id)) + ' contacts';
		} else if(contactCount.containsKey(au.Id) && contactCount.get(au.Id)==1) {
			temp.contactCount = String.valueOf(contactCount.get(au.Id)) + ' contact';
		}
		units.add(temp);
	}
	return JSON.serializePretty(units);

}

@RemoteAction global static Boolean isFavorited(Id acctId){
	List<AccountTeamMember> atm = [select Id from AccountTeamMember where
	                               AccountId =: acctId and Account.Status__c='Active' and UserId =: currentUser];
	if(atm.size()>=1) {
		return true;
	}
	return false;
}

@RemoteAction global static void saveFollowup(Id acctId, String dateString){
	Datetime followupDate = Datetime.newInstance(Date.parse(dateString), Time.newInstance(12, 0, 0, 0));
	insert new event(whatId=acctId, ActivityDateTime=followupDate, durationInMinutes=15, type='Follow-up');
}

@RemoteAction global static String getNotesAsync(Id acctId){
	return JSON.serializePretty(getNotes(acctId));
}

public static List<notes> getNotes(Id acctId){
	List<Id> documentIds = new List<Id>();
	for(ContentDocumentLink cdl : [select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:acctId]) {
		documentIds.add(cdl.ContentDocumentId);
	}

	List<notes> nList = new List<notes>();
	for(ContentDocument cd : [select Id, LatestPublishedVersionId, LatestPublishedVersion.Title,
	                          LatestPublishedVersion.Description, LatestPublishedVersion.TextPreview, FileType, FileExtension from ContentDocument
	                          where Id =: documentIds]) {
		notes n = new notes();
		n.noteId = cd.Id;
		n.title = cd.LatestPublishedVersion.Title;
		n.body = '';
		if(cd.LatestPublishedVersion.TextPreview!=null)
			n.body = cd.LatestPublishedVersion.TextPreview;
		if(cd.LatestPublishedVersion.Description!=null)
			n.body = cd.LatestPublishedVersion.Description;
		n.fileLink = '';
		if(cd.FileType!='SNOTE')
			n.fileLink = '<div><a class="blue-link" href="/sfc/servlet.shepherd/version/download/'+cd.LatestPublishedVersionId+'">'+
			             cd.LatestPublishedVersion.Title+'.'+String.valueOf(cd.FileExtension).toLowerCase()+'</a></div>';
		nList.add(n);
	}
	return nList;
}

// @RemoteAction global static void saveNote(Id acctId, String noteInput, String titleInput){
// 	ContentNote n = new ContentNote(Title=titleInput, Content=blob.valueOf(noteInput));
// 	insert n;
// 	ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId=acctId, ContentDocumentId=n.Id, ShareType='V');
// 	insert cdl;
// }

private static ContentVersion prepareFile(blob file, String title, String fileName, String body){
	ContentVersion cv = new ContentVersion();
	cv.versionData = file;
	cv.title = title;
	cv.description = body;
	cv.pathOnClient = fileName;
	return cv;
}

public PageReference newNote(){
	if(noteBody==null && file==null) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must write a note, or attach a document to save.'));
		return null;
	} else {
		try{
			if(file!=null) {
				List<ContentVersion> cvs = new List<ContentVersion>();
				cvs.add(prepareFile(file, noteTitle, fileName, noteBody));
				insert cvs;
				List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
				List<ContentWorkspaceDoc> cwds = new List<ContentWorkspaceDoc>();
				List<Id> cdIds = new List<Id>();

				String workspaceId = '';
				for(ContentWorkspace cw : [select Id from ContentWorkspace where name='HD Shared Content']) {
					workspaceId = cw.Id;
				}

				for(ContentVersion cv : [select ContentDocumentId from ContentVersion where Id in :cvs]) {
					ContentDocumentLink cdl = new ContentDocumentLink();
					cdl.ContentDocumentId = cv.ContentDocumentId;
					cdIds.add(cv.ContentDocumentId);
					cdl.LinkedEntityId = acct.Id;
					cdl.ShareType = 'V';
					cdl.Visibility = 'AllUsers';
					cdls.add(cdl);

					if(workspaceId != '') {
						ContentWorkspaceDoc cwd = new ContentWorkspaceDoc(ContentDocumentId=cv.ContentDocumentId, ContentWorkspaceId=workspaceId);
						cwds.add(cwd);
					}


				}
				insert cdls;
				insert cwds;
			} else if(noteBody!=null) {
				ContentNote n = new ContentNote(Title=noteTitle, Content=blob.valueOf(noteBody));
				insert n;
				ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId=acct.Id, ContentDocumentId=n.Id, ShareType='V');
				insert cdl;
			}

			PageReference page = new PageReference('/apex/SalesHD_Account?id='+acct.Id);
			page.setRedirect(true);
			return page;

		} catch(DmlException ex) {
			ApexPages.addMessages(ex);
			return null;
		}
	}
}

@RemoteAction global static void deleteNote(Id documentId){
	try{
		ContentDocument cd = [select Id from ContentDocument where Id=:documentId limit 1];
		delete cd;
	}catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
}

@RemoteAction global static void updateNote(Id documentId, String noteInput, String titleInput){
	try{
		ContentDocument cd = [select LatestPublishedVersionId from ContentDocument where Id=:documentId limit 1];

		List<ContentNote> notes = [select Id, Title, Content from ContentNote where
		LatestPublishedVersionId=:cd.LatestPublishedVersionId limit 1];

		List<ContentVersion> versions = [select Id, Title, Description from ContentVersion where
		Id=:cd.LatestPublishedVersionId limit 1];

		if(!notes.isEmpty()) {
			notes[0].Title = titleInput;
			notes[0].Content = blob.valueOf(noteInput);
			update notes;
		} else if(!versions.isEmpty()){
			versions[0].Title = titleInput;
			versions[0].Description = noteInput;
			update versions;
		}

	}catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
}

@RemoteAction global static void saveUnits(Id acctId, String units){
	List<updateUnit> tempUnits = (List<updateUnit>) JSON.deserialize(units, List<updateUnit>.class);
	Map<Id, Boolean> unitMap = new Map<Id, Boolean>();
	for(updateUnit u : tempUnits) {
		unitMap.put(u.unitId, u.isActive);
	}
	List<Account_Unit__c> updateUnits = [select Id, Active__c from Account_Unit__c where Id in :unitMap.keySet()];
	for(Account_Unit__c au : updateUnits) {
		au.Active__c = unitMap.get(au.Id);
	}
	update updateUnits;
}

@RemoteAction global static void favoriteUnfavoriteAccount(Id acctId){
	List<AccountTeamMember> atm = [select Id from AccountTeamMember where AccountId =: acctId and Account.Status__c='Active' and UserId =: currentUser];

	if(atm.size()>=1) {
		delete atm;
	} else{
		insert new AccountTeamMember(AccountId=acctId, UserId=currentUser);
	}
}

@RemoteAction global static String getEncounters(Id acctId){

	// List<Event> pastEvents = new List<Event>();
	List<EventRelation> pastEvents = new List<EventRelation>();
	List<EventRelation> futureEvents = new List<EventRelation>();
	// List<Event> futureEvents = new List<Event>();

	// pastEvents = [select id, subject, startDateTime, SalesHD_Complete__c, description,
	// who.name, SalesHD_Call_Objective__c, what.Name, SalesHD_Account_Unit__r.Unit__r.Name,
	// SalesHD_Open_Ended_Questions__c, createdby.Name, createdby.SmallPhotoUrl, ActivityDate from event
	// where whatId=:acctId and activityDateTime<TODAY order by activityDateTime desc limit 100 ];

	pastEvents = [select eventId, event.subject, event.startDateTime, event.SalesHD_Complete__c, event.description,
	              relation.name, event.SalesHD_Call_Objective__c, event.what.Name, event.SalesHD_Account_Unit__r.Unit__r.Name,
	              event.SalesHD_Open_Ended_Questions__c, event.createdby.Name, event.createdby.SmallPhotoUrl, event.ActivityDate from eventRelation
	              where event.whatId=:acctId and event.activityDateTime<TODAY and isWhat=false order by event.activityDateTime desc limit 100 ];

	futureEvents = [select eventId, event.subject, event.startDateTime, event.SalesHD_Complete__c, event.description,
	                relation.name, event.SalesHD_Call_Objective__c, event.what.Name, event.SalesHD_Account_Unit__r.Unit__r.Name,
	                event.SalesHD_Open_Ended_Questions__c, event.createdby.Name, event.createdby.SmallPhotoUrl, event.ActivityDate from eventRelation
	                where event.whatId=:acctId and event.activityDateTime>=TODAY and isWhat=false order by event.activityDateTime desc limit 100 ];

	// futureEvents = [select id, subject, startDateTime, SalesHD_Complete__c, description,
	// who.name, SalesHD_Call_Objective__c, SalesHD_Open_Ended_Questions__c, what.Name,
	// SalesHD_Account_Unit__r.Unit__r.Name, createdby.Name, createdby.SmallPhotoUrl, ActivityDate from event
	// where whatId=:acctId and activityDateTime>=TODAY order by activityDateTime desc limit 100];

	return '{"pastEvents" : '+JSON.serialize(pastEvents)+', "futureEvents" : '+JSON.serialize(futureEvents)+'}';
}

// @RemoteAction global static void updateAccount(Id acctId, String dataJson){
// 	Account updateAccount = (Account)JSON.deserializeStrict(dataJson, Account.class);
// }

public PageReference save() {
	update acct;
	PageReference accountPage = new PageReference('/apex/SalesHD_Account?id='+acct.Id);
	accountPage.setRedirect(true);
	return accountPage;
}

}