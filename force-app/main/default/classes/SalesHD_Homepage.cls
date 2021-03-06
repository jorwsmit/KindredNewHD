global without sharing class SalesHD_Homepage {

public String actualAdmits {get; set;}
public String admitTarget {get; set;}
public String admitsTotarget {get; set;}

public String accountSearchString {get; set;}
public String selectedAccountId {get; set;}

public String contactSearchString {get; set;}
public String selectedContactId {get; set;}

public String medparStates {get; set;}
public String medparYears {get; set;}
public String medparFiles {get; set;}

public String messageText {get; set;}

public List<leaderboardObject> leaderboardList {get; set;}

public String messagesJSON {get; set;}
public String leaderboardJSON {get; set;}

public blob file {get; set;}
public String fileName {get; set;}

public String marketDropdown {get; set;}


private static Id currentUser = UserInfo.getUserId();

public class directoryObject {
public String name;
public Id directoryId;
public String type;
public String title = '';
public boolean isPhysician = false;
// public String lastCalled ='<p class="text-danger">Never called</p>';
public String lastCalled ='';
}

public class leaderboardObject {
public String name;
public Id userId;
public String market;
public String district;
public String revenue;
public String photoUrl;
public Integer ranking;
}

public class message {
@AuraEnabled public String author {get; set;}
@AuraEnabled public String authorTitle {get; set;}
@AuraEnabled public String message {get; set;}
@AuraEnabled public String sentDate {get; set;}
@AuraEnabled public String attachment {get; set;}
@AuraEnabled public String link {get; set;}
@AuraEnabled public String linkTitle {get; set;}
@AuraEnabled public String key {get; set;}

public message () {
	this.author = '';
	this.authorTitle = '';
	this.message = '';
	this.sentDate = '';
	this.attachment = '';
	this.link = '';
	this.linkTitle = '';
	this.key = '';
}
}

public class notification {
public String n_date = '';
public String body = '';
public String n_id = '';
public String n_type = '';
public String icon = '';
}

private static Set<Id> parentUsers = getParentRoleId(new Set<ID> {UserInfo.getUserRoleId()});

public ApexPages.StandardSetController accountSSC {get; private set;}


public SalesHD_Homepage() {

	parentUsers.add(UserInfo.getUserRoleId());

	messagesJSON = getMessages();

	// leaderboardJSON = getLeaderboard1();
	getLeaderboard();

	this.actualAdmits = null;
	this.admitTarget = null;
	this.admitsTotarget = null;
	for(Sales_Performance__c sp : [select Actual_Admissions__c, Targeted_Admissions__c from Sales_Performance__c where
	                               OwnerId =: currentUser and Month__c = this_month]) {
		this.actualAdmits = String.valueOf(sp.Actual_Admissions__c);
		this.admitTarget = String.valueOf(sp.Targeted_Admissions__c);
		if(sp.Actual_Admissions__c < sp.Targeted_Admissions__c) {
			this.admitsTotarget = String.valueOf(sp.Targeted_Admissions__c - sp.Actual_Admissions__c);
		} else{
			this.admitsTotarget = String.valueOf(0);
		}

	}

	Id workspaceId;

	for(ContentWorkspace cw : [select Id from ContentWorkspace where name='Sales Medpar' limit 1]) {
		workspaceId = cw.Id;
	}

	List<ContentVersion> medpar = new List<ContentVersion>();
	Set<String> medparStateSet = new Set<String>();
	Set<Integer> medparYearSet = new Set<Integer>();
	for(ContentVersion cv : [select Title, Id, FileType, Medpar_Year__c, Medpar_State__c from ContentVersion where IsLatest=true and ContentDocument.ParentId =: workspaceId]) {
		if(cv.Medpar_State__c!=null && !medparStateSet.contains(cv.Medpar_State__c)) {
			medparStateSet.add(cv.Medpar_State__c);
		}
		if(cv.Medpar_Year__c!=null && !medparYearSet.contains(Integer.valueOf(cv.Medpar_Year__c))) {
			medparYearSet.add(Integer.valueOf(cv.Medpar_Year__c));
		}
		medpar.add(cv);
	}
	medparStates = JSON.serializePretty(medparStateSet);
	medparYears = JSON.serializePretty(medparYearSet);
	medparFiles = JSON.serializePretty(medpar);


	setupAccountStandardSetSetup();
}

public Pagereference managedCareRedirect(){
	if([select Profile.name from user where Id=: currentUser][0].Profile.name.contains('Managed Care')) {
		PageReference page = new PageReference('/apex/SalesHD_ManagedCareHome');
		page.setRedirect(true);
		return page;
	}
	return null;
}

@RemoteAction global static String getDirectory() {
	List<directoryObject> directory = new List<directoryObject>();

	for(Contact_team__c c : [select Contact__r.Id, Contact__r.Name, Contact__r.RecordType.Name, Contact__r.Title__c from Contact_Team__c where User__c =: currentUser]) {
		directoryObject temp = new directoryObject();
		temp.name = c.Contact__r.Name;
		temp.directoryId = c.Contact__r.Id;
		temp.type = 'Contact';
		if(c.Contact__r.Title__c!=null) temp.title= ' - ' + String.valueOf(c.Contact__r.Title__c);
		if(c.Contact__r.RecordType.Name=='HD Physicians') temp.isPhysician=true;
		directory.add(temp);
	}

	for(AccountTeamMember a : [select AccountId, Account.Name from AccountTeamMember where Account.Status__c='Active' and UserId =: currentUser and Account.RecordType.Name='HD Accounts']) {
		directoryObject temp = new directoryObject();
		temp.name = a.Account.Name;
		temp.directoryId = a.AccountId;
		temp.type = 'Account';
		directory.add(temp);
	}

	return JSON.serializePretty(directory);
}

// @RemoteAction global static String getLeaderboard() {
// 	List<leaderboardObject> leaderboard = new List<leaderboardObject>();
// 	Integer i = 1;
// 	List<Id> roleId = new List<Id>();
// 	roleId.add(UserInfo.getUserRoleId());
// 	Map<Id, User> users = new Map<ID, User>([select Name, SmallPhotoUrl, UserRole.Name from User where UserRoleId in: roleId]);
// 	for(Sales_Performance__c sp : [select OwnerId, Actual_Revenue__c, Revenue_to_Goal__c from Sales_Performance__c where
// 	                               OwnerId in :users.keyset() and Month__c = last_month and Actual_Revenue__c!=null order by Revenue_to_Goal__c desc]) {
// 		leaderboardObject temp = new leaderboardObject();
// 		temp.name = users.get(sp.OwnerId).Name;
// 		temp.userId = sp.OwnerId;
// 		// temp.revenue = '$'+String.valueOf(sp.Actual_Revenue__c.setScale(2));
// 		temp.revenue = '%'+String.valueOf(sp.Revenue_to_Goal__c.setScale(2));
// 		temp.market = users.get(sp.OwnerId).UserRole.Name;
// 		temp.photoUrl =  users.get(sp.OwnerId).SmallPhotoUrl;
// 		temp.ranking =  i;
// 		leaderboard.add(temp);
// 		i++;
// 	}
// 	return JSON.serializePretty(leaderboard);
// }


public PageReference getLeaderboard() {
	List<leaderboardObject> leaderboard = new List<leaderboardObject>();
	Integer i = 1;
	Set<Id> roleIds = new Set<Id>();
	if(marketDropdown=='nation') {
		String roleId = '';
		for(UserRole ur : [select Id from UserRole where name = 'HD - VP']) {
			roleId = ur.Id;
		}
		roleIds = getSubRoleIds(new set<ID> {roleId});
		roleIds.add(roleId);
	}
	roleIds.add(UserInfo.getUserRoleId());
	Map<Id, User> users = new Map<ID, User>([select Name, SmallPhotoUrl, UserRole.Name from User where (UserRoleId in: roleIds or Id=: currentUser) and isActive=true]);
	for(Sales_Performance__c sp : [select OwnerId, Actual_Revenue__c, Revenue_to_Goal__c from Sales_Performance__c where
	                                       (OwnerId in :users.keyset() or OwnerId=:currentUser) and Month__c = last_month and Actual_Revenue__c!=null order by Revenue_to_Goal__c desc]) {
		leaderboardObject temp = new leaderboardObject();
		temp.name = users.get(sp.OwnerId).Name;
		temp.userId = sp.OwnerId;
		// temp.revenue = '$'+String.valueOf(sp.Actual_Revenue__c.setScale(2));
		temp.revenue = '%'+String.valueOf(sp.Revenue_to_Goal__c.setScale(2));
		temp.market = users.get(sp.OwnerId).UserRole.Name;
		temp.photoUrl =  users.get(sp.OwnerId).SmallPhotoUrl;
		temp.ranking =  i;
		leaderboard.add(temp);
		i++;
	}

	leaderboardJSON = JSON.serializePretty(leaderboard);
	// return leaderboard;
	// return JSON.serializePretty(leaderboard);
	return null;
}

private static set<Id> getSubRoleIds(set<Id> roleIds) {
	set<Id> returnRoleIds = new set<Id>();
	for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
		returnRoleIds.add(r.Id);
	}
	if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
	return returnRoleIds;
}

// @RemoteAction global static String getAccounts() {
// 	return JSON.serializePretty([select AccountId, Account.Name, Account.ShippingAddress__c from AccountTeamMember where Account.Status__c='Active' and UserId =: currentUser and Account.RecordType.Name='HD Accounts']);
// }

public List<AccountTeamMember> getAccounts(){
	return [select AccountId, Account.Name, Account.ShippingAddress__c from AccountTeamMember where
	        Account.Status__c='Active' and UserId =: currentUser and Account.RecordType.Name='HD Accounts'];
}


public Integer getNumberToAudit(){
	Set<Id> roleIds  = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});
	Date auditStartDate = Date.newInstance(2020, 6, 1);
	List<AggregateResult> ar = [select Count(id) total from event where owner.userRoleId in :roleIds
	                            and startDateTime>=:auditStartDate and startDateTime<=last_week and Encounter_Audit__r.Audit_Result__c=null];
	Integer num = 0;
	if(ar.size()>0 && Integer.valueOf(ar[0].get('total'))>0) num = Integer.valueOf(ar[0].get('total'));
	return num;
}

// @RemoteAction global static String getMessages() {
// 	Set<Id> parentUserIds = getParentRoleId(new Set<ID> {UserInfo.getUserRoleId()});
// 	parentUserIds.add(UserInfo.getUserRoleId());

// 	List<message> messages = new List<message>();
// 	for(Alert_and_Comment__c ac : [select Comment__c, Comment_By__r.Name, Comment_By__r.Title, Datetime__c
// 	                               from Alert_and_Comment__c where Type__c='HD Corporate Message' and Comment_By__r.UserRoleId in: parentUserIds
// 	                                                                        and (Datetime__c=last_n_days:15 or Datetime__c=this_month)]) {
// 		message temp = new message();
// 		if(ac.Comment__c!=null) temp.message=ac.Comment__c;
// 		if(ac.Comment_By__r.Name!=null) temp.author=ac.Comment_By__r.Name;
// 		if(ac.Comment_By__r.Title!=null) temp.authorTitle=ac.Comment_By__r.Title;
// 		if(ac.Datetime__c!=null) temp.sentDate=Date.valueOf(ac.Datetime__c).format();
// 		messages.add(temp);
// 	}
// 	return JSON.serializePretty(messages);
// }

private static String getMessages() {

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
	return JSON.serializePretty(messages);
}


// copied from above for LWC use
@AuraEnabled(cacheable=true)
public static List<message> getMessagesLWC() {

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
		if(fileLinks.containsKey(ac.Id)){
			temp.link = '/sfc/servlet.shepherd/version/download/'+
			                                           fileLinks.get(ac.Id).ContentDocument.LatestPublishedVersionId;
													   temp.linkTitle = fileLinks.get(ac.Id).ContentDocument.Title;
		}
		temp.key = ac.Id;
													   messages.add(temp);
	}
	return messages;
}

@RemoteAction global static String getNotifications() {
	List<notification> notifications = new List<notification>();

	// for(New_Physician_Request__c pr : [select First_Name__c, Last_Name__c, Contact__c, Completed_Date__c from New_Physician_Request__c
	// where (Completed_Date__c=null or Completed_Date__c>=last_n_weeks:2
	// or Completed_Date__c=today or Completed_Date__c<=next_n_weeks:2)
	// and CreatedById=:currentUser]){
	// 	notification temp = new notification();
	// 	temp.n_type = 'physician';
	// 	if(pr.Completed_Date__c==null){
	// 		temp.icon = '<i class="fas fa-user-md blue round-icon-blue"></i>';
	// 		temp.body = 'Your new physician, '+pr.First_Name__c+' '+pr.Last_Name__c+', has been requested.';
	// 	} else {
	// 		temp.n_id = pr.Contact__c;
	// 		temp.icon = '<i class="fas fa-user-md green round-icon-green"></i>';
	// 		temp.body = 'Your new physician, '+pr.First_Name__c+' '+pr.Last_Name__c+', has been processed! Click here to open their contact page.';
	// 	}
	// 	notifications.add(temp);
	// }

	// List<event> totalEncountersLastWeek = [select id from event where startdatetime=last_week and ownerId=:currentUser];
	// List<event> unauditedEncountersLastWeek = [select id from event where startdatetime=last_week and Encounter_Audit__r.Audit_Result__c=null and ownerId=:currentUser];
	// if(unauditedEncountersLastWeek.isEmpty() && totalEncountersLastWeek.size()>0){
	// 	notification temp = new notification();
	// 	temp.icon = '<i class="fas fa-info-circle blue round-icon-blue"></i>';
	// 	temp.body = 'All of your encounters last week have been audited.';
	// 	notifications.add(temp);
	// }


	for(Contact pr : [select FirstName, LastName, Id, HD_Physician_Request_Completed_Date__c from Contact
	                  where (HD_Physician_Request_Completed_Date__c=null or HD_Physician_Request_Completed_Date__c>=last_n_weeks:2
	                                                                 or HD_Physician_Request_Completed_Date__c=today or HD_Physician_Request_Completed_Date__c<=next_n_weeks:2)
	                  and OwnerId=:currentUser and RecordType.Name='HD Physician Requests']) {
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

	for(event e : [select ActivityDateTime, who.Name, what.Name, Id from event where ownerId=:currentUser and
	                                                                                                  (activityDateTime=last_n_weeks:2 or activityDateTime=last_n_days:14) and (SalesHD_Complete__c=false or Result__c=null) and WhoId!=null and WhatId!=null]) {
		notification temp = new notification();
		// if(e.who.Name!=null) temp.body = 'You have a follow up with '+e.who.Name+' scheduled for '+ String.valueOf(Date.valueOf(e.ActivityDateTime).format())+'.';
		// else if(e.what.Name!=null) temp.body = 'You have a follow up with '+e.what.Name+' scheduled for '+ String.valueOf(Date.valueOf(e.ActivityDateTime).format())+'.';
		temp.n_id = e.Id;
		temp.n_type = 'event';
		temp.icon = '<i class="fas fa-phone red round-icon-red"></i>';
		temp.body = 'You need to fill out results/follow-ups for the encounter with '+e.who.Name+' at '+e.what.Name+' scheduled for '+ String.valueOf(Date.valueOf(e.ActivityDateTime).format())+'.';

		notifications.add(temp);
	}


	return JSON.serializePretty(notifications);
}


@RemoteAction global static String getContacts() {
	return JSON.serializePretty([select Contact__r.Id, Contact__r.Name, Contact__r.MailingAddress__c, Contact__r.RecordType.Name, Contact__r.Title__c from Contact_Team__c where User__c =: currentUser]);
}

@RemoteAction global static List<Account> searchAccounts(String accountSearchString, String selectedState) {
	List<Account> accounts = new List<Account>();
	if(selectedState!=null && selectedState!='') accounts = Database.query('Select Id, Name, ShippingAddress__c from Account where name like \'%' + String.escapeSingleQuotes(accountSearchString) + '%\' and recordtype.name=\'HD Accounts\' and Status__c=\'Active\' and ShippingState=\''+selectedState+'\' limit 100');
	else accounts = Database.query('Select Id, Name, ShippingAddress__c from Account where name like \'%' + String.escapeSingleQuotes(accountSearchString) + '%\' and recordtype.name=\'HD Accounts\' and Status__c=\'Active\' limit 100');
	return accounts;
}

@RemoteAction global static List<Contact> searchContacts(String contactSearchString, String selectedState) {
	List<Contact> contacts = new List<Contact>();
	if(selectedState!=null && selectedState!='') contacts = Database.query('Select Id, Name, MailingAddress__c from Contact where name like \'%' + String.escapeSingleQuotes(contactSearchString) + '%\' and (recordtype.name=\'HD Contacts\' or recordtype.name=\'HD Physicians\') and Status__c=\'Active\' and MailingState=\''+selectedState+'\' limit 100');
	else contacts = Database.query('Select Id, Name, MailingAddress__c, Title__c from Contact where name like \'%' + String.escapeSingleQuotes(contactSearchString) + '%\' and (recordtype.name=\'HD Contacts\' or recordtype.name=\'HD Physicians\') and Status__c=\'Active\' limit 100');
	return contacts;
}

@RemoteAction global static String getDischargeDisposition() {
	Id workspaceId;
	for(ContentWorkspace cw : [select Id from ContentWorkspace where Name = 'Sales Discharge Disposition']) {
		workspaceId = cw.Id;
	}

	return resourceJSON(workspaceId);
}

@RemoteAction global static String getReports() {
	return JSON.serializePretty([select Id, Name FROM Report where FolderName='HD Redesign Reports' order by Name asc]);
}

private static String resourceJSON(Id workspaceId){
	Id dischargeId;
	for(ContentVersion cv : [select Title, Id, Description, FileType from ContentVersion where IsLatest=true and ContentDocument.ParentId=:workspaceId order by LastModifiedDate desc limit 1]) {
		dischargeId = cv.Id;
	}
	return dischargeId;
}

public PageReference newMessage(){
	Alert_and_Comment__c ac = new Alert_and_Comment__c();
	ac.Comment__c = messageText; ac.Datetime__c = System.now(); ac.Type__c = 'HD Corporate Message'; ac.Comment_By__c = currentUser;
	try{
		insert ac;
		List<ContentVersion> cvs = new List<ContentVersion>();
		if(file!=null) {
			cvs.add(prepareFile(file, fileName));
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
	PageReference page = new PageReference('/apex/SalesHD_Homepage');
	page.setRedirect(true);
	return page;
}

public static Set<ID> getParentRoleId(Set<ID> roleIds) {
	Set<ID> currentRoleIds = new Set<ID>();
	for(UserRole ur :[select Id, ParentRoleId from UserRole where Id in: roleIds]) {
		currentRoleIds.add(ur.ParentRoleId);
	}
	if(currentRoleIds.size() > 0) {
		currentRoleIds.addAll(getParentRoleId(currentRoleIds));
	}
	return currentRoleIds;
}


private static ContentVersion prepareFile(blob file, String fileName){
	ContentVersion cv = new ContentVersion();
	cv.versionData = file;
	cv.title = fileName;
	cv.pathOnClient = fileName;
	return cv;
}



public List<Account> getAllAccounts (){
	return accountSSC.getRecords();
}

public String accountSearch {get; set;}

private void setupAccountStandardSetSetup(){
	// if(accountSearch==null) accountSearch='';
	String query = 'select id, name, shippingAddress__c, type from account where recordtype.name=\'HD Accounts\' and status__c=\'Active\'';
	if(accountSearch!=null)
		query += ' and (name like \'%'+accountSearch+'%\' or shippingAddress__c like \'%'+accountSearch+'%\')';

	if(selectedState!=null) query += ' and ShippingState like \''+selectedState+'\'';
	query += ' order by name asc';

	accountSSC = new ApexPages.StandardSetController(Database.getQueryLocator(
								 query
								 ));
	accountSSC.setPageSize(20);
}

public PageReference searchAccounts() {
	setupAccountStandardSetSetup();
	getAllAccounts();
	return null;
}

public String selectedState {get; set;}

public List<Selectoption> getStatePicklist(){
	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', 'State'));
	for(AggregateResult ar : [select ShippingState state from account where ShippingState!=null
	                          and status__c='Active' and recordType.name='HD Accounts' group by ShippingState order by ShippingState ]) {
		String state = String.valueOf(ar.get('state'));
		picklist.add(new selectOption(state, state));
	}
	return picklist;
}

}