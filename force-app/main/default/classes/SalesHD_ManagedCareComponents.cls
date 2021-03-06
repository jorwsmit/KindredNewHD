public without sharing class SalesHD_ManagedCareComponents {

public String objectType {get; set;}
public String recordId {get; set;}
private Map<String, String> objectKeys;
public List<Id> documentIds = new List<Id>();
public boolean favorited {get; set;}
private String currentPageUrl {get; set;}


public SalesHD_ManagedCareComponents() {
	currentPageUrl = ApexPages.currentPage().getUrl();
	objectKeys = getObjectKeys();
	favorited = false;
	if(ApexPages.currentPage().getParameters().get('id')!=null) {
		recordId = ApexPages.currentPage().getParameters().get('id');
	}

	if(recordId!=null && objectKeys.containsKey(String.valueOf(recordId).substring(0,3))) {
		objectType = objectKeys.get(String.valueOf(recordId).substring(0,3));
		isFavorited(recordId);
	}

	if(recordId!=null) documentIds = getDocumentIds(recordId);
}

private Map<String, String> getObjectKeys(){
	Map<String,String> keys = new Map<String,String>();
	Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
	for(String s:describe.keyset()) {
		keys.put(describe.get(s).getDescribe().getKeyPrefix(),s);
	}
	return keys;
}

private List<Id> getDocumentIds(String rId){
	List<Id> docIds = new List<Id>();
	for(ContentDocumentLink cdl : [select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:rId]) {
		docIds.add(cdl.ContentDocumentId);
	}
	return docIds;
}

public List<Event> getRelatedEvents(){
	if(recordId!=null && objectType!=null) {
		// String objectType = objectKeys.get(String.valueOf(recordId).substring(0,3));
		String query = 'select Id, owner.Name, SalesHD_Open_ended_questions__c, ActivityDate,'
		               +'SalesHD_Call_Objective__c, Who.Name, Account.Name from event ';
		if(objectType == 'Account') query += ' where accountId =: recordId';
		else if(objectType == 'Contact') query += ' where whoId =: recordId';
		query += ' order by activityDate desc limit 200';
		return database.query(query);
	}
	return new List<Event>();
}

public List<Report> getReports(){
	return [select Id, Name FROM Report where FolderName='HD Managed Care Reports' order by Name asc];
}


public List<Contact> getRelatedContacts(){
	if(recordId!=null && objectKeys.containsKey(String.valueOf(recordId).substring(0,3)) &&
	   objectKeys.get(String.valueOf(recordId).substring(0,3)) == 'Account') {
		String query = 'select id, name, title__c, lastActivityDate from contact where id in '+
		               '(select contact__c from account_unit_contact__c where account_unit__r.account__c=:recordId)';
		return database.query(query);
	}
	return new List<Contact>();
}

public List<Account> getRelatedAccounts(){
	if(recordId!=null && objectKeys.containsKey(String.valueOf(recordId).substring(0,3)) &&
	   objectKeys.get(String.valueOf(recordId).substring(0,3)) == 'Contact') {

		Set<Id> accountIds = new Set<Id>();
		for(AggregateResult ar : [select account__c accountId from account_unit__c where id in
		                                  (select account_unit__c from account_unit_contact__c where contact__c=:recordId) group by account__c]) {
			accountIds.add(String.valueOf(ar.get('accountId')));
		}

		String query = 'select id, name, ShippingState, lastActivityDate from Account where id in :accountIds';
		return database.query(query);
	}
	return new List<Account>();
}


// public List<ContentDocument> getMyNotesOld(){
//  if(!documentIds.isEmpty())
//      return [select Id, LatestPublishedVersionId, LatestPublishedVersion.Title,
//              LatestPublishedVersion.Description, LatestPublishedVersion.TextPreview, FileType, FileExtension
//              from ContentDocument where Id =: documentIds and OwnerId =: UserInfo.getUserId()];
//  return new List<ContentDocument>();
// }

public List<Notes> getMyNotes(){
	if(!documentIds.isEmpty()) {
		List<Notes> noteList = new List<Notes>();
		for(ContentDocument cd : [select Id, LatestPublishedVersionId, LatestPublishedVersion.Title, Createdby.name,
		                          LatestPublishedVersion.Description, LatestPublishedVersion.TextPreview, FileType, FileExtension
		                          from ContentDocument where Id =: documentIds and OwnerId =: UserInfo.getUserId()]) {
			noteList.add(newNote(cd));
		}
		return noteList;
	}

	return new List<Notes>();
}



private Notes newNote(ContentDocument cd){
	notes n = new notes(cd.Id);
	n.title = cd.LatestPublishedVersion.Title;
	if(cd.LatestPublishedVersion.TextPreview!=null)
		n.body = cd.LatestPublishedVersion.TextPreview;
	if(cd.LatestPublishedVersion.Description!=null)
		n.body = cd.LatestPublishedVersion.Description;
	if(cd.createdBy.name!=null)
		n.createdBy = cd.createdBy.name;
	if(cd.FileType!='SNOTE')
		n.fileLink = '<div><a href="/sfc/servlet.shepherd/version/download/'+cd.LatestPublishedVersionId+'">'+
		             cd.LatestPublishedVersion.Title+'.'+String.valueOf(cd.FileExtension).toLowerCase()+'</a></div>';
	return n;
}


public class notes {
public String noteId {get; set;}
public String title {get; set;}
public String body {get; set;}
public String fileLink {get; set;}
public String createdBy {get; set;}
public notes(Id noteId){
	this.noteId = noteId;
	title = '';
	body = '';
	fileLink = '';
	createdBy = '';
}
}

// public List<ContentDocument> getNotes(){
//  if(!documentIds.isEmpty())
//      return [select Id, LatestPublishedVersionId, LatestPublishedVersion.Title,
//              LatestPublishedVersion.Description, LatestPublishedVersion.TextPreview, FileType, FileExtension
//              from ContentDocument where Id =: documentIds and OwnerId !=: UserInfo.getUserId()];
//  return new List<ContentDocument>();
// }

public List<Notes> getNotes(){
	if(!documentIds.isEmpty()) {
		List<Notes> noteList = new List<Notes>();
		for(ContentDocument cd : [select Id, LatestPublishedVersionId, LatestPublishedVersion.Title, CreatedBy.Name,
		                          LatestPublishedVersion.Description, LatestPublishedVersion.TextPreview, FileType, FileExtension
		                          from ContentDocument where Id =: documentIds and OwnerId !=: UserInfo.getUserId()]) {
			noteList.add(newNote(cd));
		}
		return noteList;
	}

	return new List<Notes>();
}

public String noteTitle {get; set;}
public String noteBody {get; set;}
public blob file {get; set;}
public String fileName {get; set;}

public PageReference saveNote(){
	if(recordId == null) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No record ID provided!'));
		return null;
	}
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
					cdl.LinkedEntityId = recordId;
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
				ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId=recordId, ContentDocumentId=n.Id, ShareType='V');
				insert cdl;
			}

			PageReference page = ApexPages.currentPage();
			page.setRedirect(true);
			return page;

		} catch(DmlException ex) {
			ApexPages.addMessages(ex);
			return null;
		}
	}
}

public String noteId {get; set;}
public PageReference deleteNote(){
	try{
		List<ContentDocument> n = [select Id from ContentDocument where Id=:noteId limit 1];
		if(!n.isEmpty()) delete n;
		PageReference page = ApexPages.currentPage();
		page.setRedirect(true);
		return page;
	}catch(DmlException ex) {
		ApexPages.addMessages(ex);
		return null;
	}
}

public List<Selectoption> getFavoritedContactPicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', 'My Favorited Contacts'));
	for(Contact_Team__c ct : [select contact__c, contact__r.name from Contact_Team__c where
	                          contact__r.status__c='Active' and user__c=:UserInfo.getUserId() order by contact__r.lastActivityDate desc]) {
		picklist.add(new selectOption(ct.contact__c, ct.contact__r.name));
	}
	return picklist;
}

public String favoritedContactIdToRelate {get; set;}
public PageReference relateContactToAccount(){
	if(recordId == null) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No record ID provided!'));
		return null;
	}
	if(favoritedContactIdToRelate==null || favoritedContactIdToRelate=='') {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a contact from your favorited list to relate it.'));
		return null;
	} else {
		try{

			List<Account_Unit__c> aus = [select Id from Account_Unit__c where Account__c=:recordId and Unit__r.Name='Administrative'];
			if(aus.isEmpty()) {
				List<Unit__c> u = [select Id from Unit__c where name='Administrative'];
				if(!u.isEmpty()) {
					Account_Unit__c au = new Account_Unit__c(Account__c=recordId, Unit__c=u[0].Id);
					insert au;
					insert new Account_Unit_Contact__c(Account_Unit__c=au.Id, Contact__c=favoritedContactIdToRelate);
				}
			} else{
				List<Account_Unit_Contact__c> aucs = [select Id from Account_Unit_Contact__c
				                                      where Contact__c=:favoritedContactIdToRelate and Account_Unit__c=:aus[0].Id];
				if(aucs.isEmpty()) {
					insert new Account_Unit_Contact__c(Account_Unit__c=aus[0].Id, Contact__c=favoritedContactIdToRelate);
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The selected contact is already related to this MCO.'));
				}
			}

		} catch(DmlException ex) {
			ApexPages.addMessages(ex);
			return null;
		}
	}
	Pagereference page = new PageReference(currentPageUrl);
	page.setredirect(true);
	return null;
}


private static ContentVersion prepareFile(blob file, String title, String fileName, String body){
	ContentVersion cv = new ContentVersion();
	cv.versionData = file;
	cv.title = title;
	cv.description = body;
	cv.pathOnClient = fileName;
	return cv;
}

public PageReference favorite(){

	if(recordId!=null) {
		if(objectType=='Account') {
			List<AccountTeamMember> atms = [select Id from AccountTeamMember where AccountId=:recordId and userId=:UserInfo.getUserId()];
			if(atms.size()>0) {
				try{
					delete atms;
					favorited = false;
				} catch(DmlException ex) {
					ApexPages.addMessages(ex);
					return null;
				}
			} else {
				AccountTeamMember atm = new AccountTeamMember(userId=UserInfo.getUserId(), accountId=recordId);
				try{
					insert atm;
					favorited = true;
				} catch(DmlException ex) {
					ApexPages.addMessages(ex);
					return null;
				}
			}
		} else if(objectType=='Contact') {
			List<Contact_Team__c> cts = [select Id from Contact_Team__c where contact__c=:recordId and user__c=:UserInfo.getUserId()];
			if(cts.size()>0) {
				try{
					delete cts;
					favorited = false;
				} catch(DmlException ex) {
					ApexPages.addMessages(ex);
					return null;
				}
			} else {
				Contact_Team__c ct = new Contact_Team__c();
				ct.User__c = UserInfo.getUserId();
				ct.Contact__c = recordId;
				try{
					insert ct;
					favorited = true;
				} catch(DmlException ex) {
					ApexPages.addMessages(ex);
					return null;
				}
			}
		}
	}
	return null;
}

public String relatedAccountId {get; set;}
public Pagereference deleteAccountRelation(){
	List<Account_Unit__c> aus = [select Id from Account_Unit__c where Account__c=:relatedAccountId and Unit__r.Name='Administrative'];
	List<Account_unit_contact__c> auc = [select id from account_unit_contact__c where account_unit__c in :aus and Contact__c=:recordId];
	try{
		if(!auc.isEmpty()) delete auc;
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
		return null;
	}
	return null;
}

private void isFavorited(String collateralId){
	if(recordId!=null) {
		if(objectType=='Account') {
			List<AccountTeamMember> atms = [select Id from AccountTeamMember where AccountId=:recordId and userId=:UserInfo.getUserId()];
			if(atms.size()>0) {
				favorited = true;
			}
		} else if(objectType=='Contact') {
			List<Contact_Team__c> cts = [select Id from Contact_Team__c where contact__c=:recordId and user__c=:UserInfo.getUserId()];
			if(cts.size()>0) {
				favorited = true;
			}
		}
	}
}

public class contactRelations {
public string relationship {get; set;}
public Integer totalContacts {get; set;}
public Integer totalEncounters {get; set;}
public contactRelations(string relationship, integer totalContacts){
	this.relationship = '';
	this.totalContacts = 0;
	this.totalEncounters = 0;

	if(relationship!=null) this.relationship = relationship;
	if(totalContacts!=null) this.totalContacts = totalContacts;

}
}

public List<contactRelations> getContactRelationships(){
	Map<String, contactRelations> data = new Map<String, contactRelations>();
	for(AggregateResult ar : [select SalesHD_Managed_Care_Relationship__c relationship, count(id) total from
	                          contact where (recordtype.name='Managed Care Contacts' or recordtype.name='HD Physicians') and SalesHD_Managed_Care_Relationship__c!=null group by SalesHD_Managed_Care_Relationship__c]) {
		String relation = '';
		if(String.valueOf(ar.get('relationship'))!=null) relation = String.valueOf(ar.get('relationship'));
		Integer totalContacts = 0;
		if(Integer.valueOf(ar.get('total'))!=null) totalContacts = Integer.valueOf(ar.get('total'));
		data.put(relation, new contactRelations(relation, totalContacts));
	}

	Map<Id, Integer> contactIds = new Map<Id, Integer>();

	for(AggregateResult ar : [select WhoId contactId, count(id) total from event where
	                                  (who.recordtype.name='HD Contacts' or who.recordtype.name='HD Physicians')
	                          and (activitydate=last_month) and
	                          whoId in (select id from contact where (recordtype.name='Managed Care Contacts' or recordtype.name='HD Physicians') and SalesHD_Managed_Care_Relationship__c!=null)  group by WhoId]) {
		Id contactId = String.valueOf(ar.get('contactId'));
		Integer total = Integer.valueOf(ar.get('total'));
		contactIds.put(contactId, total);
	}

	for(Contact c : [select id, SalesHD_Managed_Care_Relationship__c from
	                 contact where id in :contactIds.keyset() and SalesHD_Managed_Care_Relationship__c!=null]) {
		String relation = c.SalesHD_Managed_Care_Relationship__c;
		// contactRelations cr = data.remove(relation);
		// cr.totalEncounters = 10;
		// data.put(relation, cr);
		data.get(relation).totalEncounters+=contactIds.get(c.Id);
	}

	return data.values();
}

public class message {
public String author {get; set;}
public String authorTitle {get; set;}
public String message {get; set;}
public String sentDate {get; set;}
public String attachment {get; set;}
public message(){
	author = '';
	authorTitle = '';
	message = '';
	sentDate = '';
	attachment = '';
}
}

private static Set<Id> parentUsers = getParentRoleId(new Set<ID> {UserInfo.getUserRoleId()});

private static Set<ID> getParentRoleId(Set<ID> roleIds) {
	Set<ID> currentRoleIds = new Set<ID>();
	for(UserRole ur :[select Id, ParentRoleId from UserRole where Id in: roleIds]) {
		currentRoleIds.add(ur.ParentRoleId);
	}
	if(currentRoleIds.size() > 0) {
		currentRoleIds.addAll(getParentRoleId(currentRoleIds));
	}
	return currentRoleIds;
}

public List<Message> getMessages() {
	parentUsers.add(UserInfo.getUserRoleId());
	List<Alert_and_Comment__c> acs = [select Id, Comment__c, Comment_By__r.Name, Comment_By__r.Title, Datetime__c
	                                  from Alert_and_Comment__c where Type__c='HD Corporate Message' and Comment_By__r.UserRoleId in: parentUsers
	                                                                           and (Datetime__c=last_n_days:15 or Datetime__c=this_month) order by createdDate desc];

	Map<Id, ContentDocumentLink> fileLinks = new Map<Id, ContentDocumentLink>();
	for(ContentDocumentLink cdl : [select LinkedEntityId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId in
	                                       (select Id from Alert_and_Comment__c where Type__c='HD Corporate Message' and Comment_By__r.UserRoleId in: parentUsers
	                                                                                           and (Datetime__c=last_n_days:15 or Datetime__c=this_month))]) {
		fileLinks.put(cdl.LinkedEntityId, cdl);
	}

	List<message> messages = new List<message>();
	for(Alert_and_Comment__c ac : acs) {
		message temp = new message();
		if(ac.Comment__c!=null) temp.message=ac.Comment__c;
		if(ac.Comment_By__r.Name!=null) temp.author=ac.Comment_By__r.Name;
		if(ac.Comment_By__r.Title!=null) temp.authorTitle=ac.Comment_By__r.Title;
		if(ac.Datetime__c!=null) temp.sentDate=Date.valueOf(ac.Datetime__c).format();
		if(fileLinks.containsKey(ac.Id)) temp.attachment = '<a href="/sfc/servlet.shepherd/version/download/'+
			                                           fileLinks.get(ac.Id).ContentDocument.LatestPublishedVersionId+'">'+fileLinks.get(ac.Id).ContentDocument.Title+'</a>';
		messages.add(temp);
	}
	return messages;
}

public String messageText {get; set;}

public PageReference newMessage(){
	Alert_and_Comment__c ac = new Alert_and_Comment__c();
	ac.Comment__c = messageText; ac.Datetime__c = System.now(); ac.Type__c = 'HD Corporate Message'; ac.Comment_By__c = UserInfo.getUserId();
	try{
		insert ac;
		List<ContentVersion> cvs = new List<ContentVersion>();
		if(file!=null) {
			cvs.add(prepareFile(file, fileName, fileName, null));
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
				cdl.LinkedEntityId = ac.Id;
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
		}
	} catch(DmlException ex) {
		ApexPages.addMessages(ex);
	}
	PageReference page = new PageReference('/apex/SalesHD_ManagedCareHome');
	page.setRedirect(true);
	return page;
}

public class Notification {
public String n_date {get; set;}
public String body {get; set;}
public String n_id {get; set;}
public String n_type {get; set;}
public String icon {get; set;}
public Notification(){
	n_date = '';
	body = '';
	n_id = '';
	n_type = '';
	icon = '';
}
}

public List<Notification> getNotifications() {
	List<notification> notifications = new List<notification>();

	for(Contact pr : [select FirstName, LastName, Id, HD_Physician_Request_Completed_Date__c from Contact
	                  where (HD_Physician_Request_Completed_Date__c=null or HD_Physician_Request_Completed_Date__c>=last_n_weeks:2
	                                                                 or HD_Physician_Request_Completed_Date__c=today or HD_Physician_Request_Completed_Date__c<=next_n_weeks:2)
	                  and OwnerId=:UserInfo.getUserId() and RecordType.Name='HD Physician Requests']) {
		notification temp = new notification();
		temp.n_type = 'physician';
		if(pr.HD_Physician_Request_Completed_Date__c==null) {
			temp.icon = '<i class="fas fa-user-md blue round-icon-blue"></i>';
			temp.body = 'Your new physician, '+pr.FirstName+' '+pr.LastName+', has been requested.';
		} else {
			temp.n_id = pr.Id;
			temp.icon = '<i class="fas fa-user-md green round-icon-green"></i>';
			temp.body = 'Your new physician, '+pr.FirstName+' '+pr.LastName+', has been processed! Click here to open their contact page.';
		}
		notifications.add(temp);
	}

	for(event e : [select ActivityDateTime, who.Name, what.Name, Id from event where ownerId=:UserInfo.getUserId() and
	                                                                                                  (activityDateTime=last_n_weeks:2 or activityDateTime=last_n_days:14) and (SalesHD_Complete__c=false or Result__c=null) and WhoId!=null and WhatId!=null]) {
		notification temp = new notification();
		temp.n_id = e.Id;
		temp.n_type = 'event';
		temp.icon = '<i class="fas fa-phone red round-icon-red"></i>';
		temp.body = 'You need to fill out results/follow-ups for the encounter with '+e.who.Name+' at '+e.what.Name+' scheduled for '+ String.valueOf(Date.valueOf(e.ActivityDateTime).format())+'.';
		notifications.add(temp);
	}

	return notifications;
}

public String getEncountersByAccount(){
	String currentUserId = UserInfo.getUserId();
	String query = 'select count(id) total, account.name accountName from event where accountId in '+
	               '(select accountid from accountTeamMember where userId=:currentUserId) '+
	               'and activityDate=Last_Week and account.status__c=\'Active\' group by account.name';
	if(getIsManager()) {
		query = 'select count(id) total, account.name accountName from event where '+
		        'activityDate=Last_Week and account.status__c=\'Active\' group by account.name order by count(id) desc limit 10';
	}

	String res = '{ "cols" : [{"id":"","label":"Account","pattern":"","type":"string"}, ' +
	             '{"id":"","label":"Total Encounters","pattern":"","type":"number"}], ' +
	             '"rows": [';

	for(AggregateResult ar : database.query(query)) {
		Integer totalEncounters = Integer.valueOf(ar.get('total'));
		String accountName = '-';
		if(ar.get('accountName')!=null) accountName = String.valueOf(ar.get('accountName'));
		res += '{"c":[{"v":"'+accountName+'","f":null},{"v":'+totalEncounters+',"f":null}] },';
	}
	if(res.right(1) == ',') res = res.left(res.length()-1);
	res += ']}';
	return res;

}


private String currentUserProfileName(){
	User u = [select profile.name from user where id=:UserInfo.getUserId()];
	return u.profile.name;
}

public boolean getIsManager(){
	String profileName = currentUserProfileName();
	if(profileName.contains('Manager')) return true;
	if(profileName.contains('Admin')) return true;
	if(profileName.contains('Leader')) return true;
	return false;
}


public class directoryObject {

public String name {get; set;}
public Id directoryId {get; set;}
public String type {get; set;}
public String title {get; set;}
public boolean isPhysician {get; set;}
public String lastCalled {get; set;}

public directoryObject(String name, Id directoryId, String type){
	this.name = name;
	this.directoryId = directoryId;
	this.type = type;
	this.title = '';
	this.isPhysician = false;
	this.lastCalled ='';
}
}


public List<directoryObject> getDirectory() {
	List<directoryObject> directory = new List<directoryObject>();
	Id currentUser = UserInfo.getUserId();
	for(Contact_team__c c : [select Contact__r.Id, Contact__r.Name, Contact__r.RecordType.Name, Contact__r.Title__c from Contact_Team__c where User__c =: currentUser]) {
		directoryObject temp = new directoryObject(c.Contact__r.Name, c.Contact__r.Id, 'Contact');
		if(c.Contact__r.RecordType.Name=='HD Physicians') temp.isPhysician=true;
		if(c.Contact__r.Title__c!=null) temp.title= ' - ' + String.valueOf(c.Contact__r.Title__c);
		directory.add(temp);
	}

	for(AccountTeamMember a : [select AccountId, Account.Name from AccountTeamMember where Account.Status__c='Active' and UserId =: currentUser
	                                                                                                                               and (Account.RecordType.Name='HD Accounts' or Account.RecordType.Name='HD Managed Care Accounts')]) {
		directoryObject temp = new directoryObject(a.Account.Name, a.AccountId, 'Account');
		directory.add(temp);
	}

	return directory;
}



public class DataYOY {
public Integer py {get; set;}
public Integer referralsPy {get; set;}
public Integer admitsPy {get; set;}
public Decimal conversionPy {get; set;}
public Integer revenuePy {get; set;}

public Integer cy {get; set;}
public Integer referralsCy {get; set;}
public Integer admitsCy {get; set;}
public Decimal conversionCy {get; set;}
public Integer revenueCy {get; set;}
}

public DataYOY getDataYoy(){
	DataYOY data = new DataYOY();
	data.py = System.now().year()-1;
	// Integer referrals = Integer.valueOf(Math.random()*500);
	// Integer admits = Integer.valueOf(referrals*Math.random());
	data.referralsPy = Integer.valueOf(Math.random()*500);
	data.admitsPy = Integer.valueOf(data.referralsPy*Math.random());
	data.conversionPy = ((Decimal.valueOf(data.admitsPy)/Decimal.valueOf(data.referralsPy))*100).setScale(2);
	data.revenuePy = Integer.valueOf(Math.random()*1000000);

	data.cy = System.now().year();
	// referrals = Integer.valueOf(Math.random()*500);
	// admits = Integer.valueOf(referrals*Math.random());
	data.referralsCy = Integer.valueOf(Math.random()*500);
	data.admitsCy = Integer.valueOf(data.referralsCy * (Math.random()));
	data.conversionCy = ((Decimal.valueOf(data.admitsCy)/Decimal.valueOf(data.referralsCy))*100).setScale(2);
	data.revenueCy = Integer.valueOf(Math.random()*1500000);

	return data;
}

}