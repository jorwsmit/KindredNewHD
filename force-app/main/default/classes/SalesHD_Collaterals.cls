public without sharing class SalesHD_Collaterals {

private static Map<String, String> fileIcons = new Map<String, String> {'PDF' => '<i class="fa fa-file-pdf-o resource-icon" aria-hidden="true"></i>',
	                                                                'CSV' => '<i class="fa fa-file-excel-o resource-icon" aria-hidden="true"></i>',
	                                                                'EXCEL' => '<i class="fa fa-file-excel-o resource-icon" aria-hidden="true"></i>',
	                                                                'EXCEL_M' => '<i class="fa fa-file-excel-o resource-icon" aria-hidden="true"></i>',
	                                                                'EXCEL_X' => '<i class="fa fa-file-excel-o resource-icon" aria-hidden="true"></i>',
	                                                                'JPG' => '<i class="fa fa-file-image-o resource-icon" aria-hidden="true"></i>',
	                                                                'JPEG' => '<i class="fa fa-file-image-o resource-icon" aria-hidden="true"></i>',
	                                                                'MOV' => '<i class="fa fa-file-video-o resource-icon" aria-hidden="true"></i>',
	                                                                'MP4' => '<i class="fa fa-file-video-o resource-icon" aria-hidden="true"></i>',
	                                                                'PNG' => '<i class="fa fa-file-image-o resource-icon" aria-hidden="true"></i>',
	                                                                'TIFF' => '<i class="fa fa-file-image-o resource-icon" aria-hidden="true"></i>',
	                                                                'POWER_POINT' => '<i class="fa fa-file-powerpoint-o resource-icon" aria-hidden="true"></i>',
	                                                                'POWER_POINT_X' => '<i class="fa fa-file-powerpoint-o resource-icon" aria-hidden="true"></i>',
	                                                                'WORD' => '<i class="fa fa-file-word-o resource-icon" aria-hidden="true"></i>',
																	'WORD_X' => '<i class="fa fa-file-word-o resource-icon" aria-hidden="true"></i>',
																	'EMAIL' => '<i class="fa fa-envelope resource-icon" aria-hidden="true"></i>',
	                                                                'UNKNOWN' => '<i class="fa fa-file-o resource-icon" aria-hidden="true"></i>'};


private static Id currentUser = UserInfo.getUserId();

public class collateral {
public String collateralId {get; set;}
public String documentId {get; set;}
public String title {get; set;}
public String description {get; set;}
public String icon  {get; set;}
public Boolean audience_professional {get; set;}
public Boolean audience_patient {get; set;}
public Boolean favorited {get; set;}
public String type {get; set;}
public String lastModifiedDate {get; set;}
public collateral(String collateralId){
	this.collateralId = collateralId;
	this.documentId = '';
	this.title = '';
	this.description = '';
	this.icon = null;
	this.audience_professional = false;
	this.audience_patient = false;
	this.favorited = false;
	this.type = '';
	this.lastModifiedDate = '';
}
}

public String collaterals {get; set;}

public String collateralJSON {get; set;}
public collateral thisCollateral {get; set;}

public Boolean favorited {get; set;}

public String favoritedContacts {get; set;}
public List<Contact_Team__c> favoritedContactList {get; set;}

public List<String> collateralTypes {get; set;}

public String contactEmail {get; set;}
public String emailBody {get; set;}
public String emailSubject {get; set;}

public String collateralId {get; set;}

public Boolean emailSent {get; set;}

public SalesHD_Collaterals() {
	// collaterals = getCollaterals();
	if(ApexPages.CurrentPage().getparameters().get('id')!=null && ApexPages.currentPage().getUrl().contains('SalesHD_Collateral')) {
		getCollateral(ApexPages.CurrentPage().getparameters().get('id'));
		isFavorited(ApexPages.CurrentPage().getparameters().get('id'));
	}
	if(ApexPages.CurrentPage().getparameters().get('id')!=null && ApexPages.currentPage().getUrl().contains('SalesHD_EmailTemplate')){
		getEmailTemplate(ApexPages.CurrentPage().getparameters().get('id'));
	}

	favoritedContactList = getContacts1();

	favoritedContacts = getContacts();

	collateralTypes = getCollateralTypes();

}


public List<collateral> getCollateralList(){

	//update map to hold favoirtes
	Map<Id, collateral> cMap = new Map<Id, collateral>();
	List<collateral> cList = new List<collateral>();
	Set<Id> favoriteCollaterals = new Set<Id>();

	for(Favorite_Collateral__c fc : [select ContentDocumentId__c from
	                                 Favorite_Collateral__c where User__c =: currentUser]) {
		favoriteCollaterals.add(fc.ContentDocumentId__c);
	}

	for(ContentWorkspaceDoc cwd : [select ContentDocument.Title, ContentDocument.FileType,
	                               ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c,
	                               ContentDocument.LatestPublishedVersionId, ContentDocument.Description,
	                               ContentDocument.LatestPublishedVersion.Audience_Tag__c, ContentDocumentId,
	                               ContentDocument.LatestPublishedVersion.LastModifiedDate
	                               from ContentWorkspaceDoc where ContentWorkspace.Name='HD Collaterals'
	                                                                                     and ContentDocument.LatestPublishedVersionId!=null]) {
		collateral c = new collateral(cwd.ContentDocument.LatestPublishedVersionId);
		// c.collateralId = cwd.ContentDocument.LatestPublishedVersionId;
		if(cwd.ContentDocument.Title!=null) c.title = cwd.ContentDocument.Title;
		if(cwd.ContentDocument.Description!=null) c.description = cwd.ContentDocument.Description;
		c.icon = fileIcons.get(cwd.ContentDocument.FileType);
		if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c!=null) {
			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('Professional')) c.audience_professional = true;
			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('Patient')) c.audience_patient = true;
		}
		if(favoriteCollaterals.contains(cwd.ContentDocumentId)) c.favorited = true;
		if(cwd.ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c!=null) c.type = cwd.ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c;
		if(cwd.ContentDocument.LatestPublishedVersion.LastModifiedDate!=null) c.lastModifiedDate = Date.valueOf(cwd.ContentDocument.LatestPublishedVersion.LastModifiedDate).format();
		cList.add(c);
	}


	// public collateral(String collateralId){
	// 	this.collateralId = collateralId;
	// 	this.documentId = '';
	// 	this.title = '';
	// 	this.description = '';
	// 	this.icon = null;
	// 	this.audience_professional = false;
	// 	this.audience_patient = false;
	// 	this.favorited = false;
	// 	this.type = '';
	// 	this.lastModifiedDate = '';
	// }


	for(EmailTemplate et : getEmailTemplates()){
		collateral c = new collateral(et.Id);
		c.title = et.name;
		c.description = et.description;
		c.icon = fileIcons.get('EMAIL');
		//favorited??
		c.type = 'Email Templates';
		cList.add(c);
	}
	


	return cList;
}

// private static String getCollaterals(){

// 	//update map to hold favoirtes
// 	Map<Id, collateral> cMap = new Map<Id, collateral>();
// 	List<collateral> cList = new List<collateral>();
// 	Set<Id> favoriteCollaterals = new Set<Id>();

// 	for(Favorite_Collateral__c fc : [select ContentDocumentId__c from
// 	                                 Favorite_Collateral__c where User__c =: currentUser]) {
// 		favoriteCollaterals.add(fc.ContentDocumentId__c);
// 	}

// 	for(ContentWorkspaceDoc cwd : [select ContentDocument.Title, ContentDocument.FileType,
// 	                               ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c,
// 	                               ContentDocument.LatestPublishedVersionId, ContentDocument.Description,
// 	                               ContentDocument.LatestPublishedVersion.Audience_Tag__c, ContentDocumentId
// 	                               from ContentWorkspaceDoc where ContentWorkspace.Name='HD Collaterals']) {
// 		collateral c = new collateral();
// 		c.collateralId = cwd.ContentDocument.LatestPublishedVersionId;
// 		if(cwd.ContentDocument.Title!=null) c.title = cwd.ContentDocument.Title;
// 		if(cwd.ContentDocument.Description!=null) c.description = cwd.ContentDocument.Description;
// 		c.icon = fileIcons.get(cwd.ContentDocument.FileType);
// 		if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c!=null) {
// 			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('Professional')) c.audience_professional = true;
// 			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('Patient')) c.audience_patient = true;
// 		}
// 		if(favoriteCollaterals.contains(cwd.ContentDocumentId)) c.favorited = true;
// 		if(cwd.ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c!=null) c.type = cwd.ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c;
// 		cList.add(c);
// 	}
// 	return JSON.serializePretty(cList);
// }

private PageReference getCollateral(String collateralId){

	for(ContentWorkspaceDoc cwd : [select ContentDocument.Title, ContentDocument.FileType,
	                               ContentDocument.LatestPublishedVersionId, ContentDocument.Description,
	                               ContentDocument.LatestPublishedVersion.Audience_Tag__c, ContentDocumentId
	                               from ContentWorkspaceDoc where ContentDocument.LatestPublishedVersionId = :collateralId]) {
		collateral c = new collateral(cwd.ContentDocument.LatestPublishedVersionId);
		// c.collateralId = cwd.ContentDocument.LatestPublishedVersionId;
		c.documentId = cwd.ContentDocumentId;
		if(cwd.ContentDocument.Title!=null) c.title = cwd.ContentDocument.Title;
		if(cwd.ContentDocument.Description!=null) c.description = cwd.ContentDocument.Description;
		c.icon = fileIcons.get(cwd.ContentDocument.FileType);
		if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c!=null) {
			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('professional')) c.audience_professional = true;
			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('patient')) c.audience_patient = true;
		}
		collateralJSON = JSON.serializePretty(c);
		thisCollateral = c;
		collateralId = cwd.ContentDocumentId;

		String link = URL.getSalesforceBaseUrl().toExternalForm()+cwd.ContentDocument.LatestPublishedVersionId;
		emailBody = 'Hi,\n\nClick on the link below to view the collateral.\n\nThanks,\n'+UserInfo.getName();

	}
	return null;
}

private static List<String> getCollateralTypes(){
	List<String> pickListValuesList= new List<String> {'Show All Types'};
	Schema.DescribeFieldResult fieldResult = ContentVersion.HD_Collateral_Type__c.getDescribe();
	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	for( Schema.PicklistEntry pickListVal : ple) {
		pickListValuesList.add(pickListVal.getLabel());
	}
	pickListValuesList.add('Email Templates');
	return pickListValuesList;
}

private PageReference isFavorited(String collateralId){
	for(Favorite_Collateral__c fc : [select ContentDocumentId__c from
	                                 Favorite_Collateral__c where User__c =: currentUser and ContentDocumentId__c=:thisCollateral.documentId]) {
		favorited = true;
	}
	return null;
}

private static String getContacts() {
	return JSON.serializePretty([select Contact__r.Id, Contact__r.Name, Contact__r.Email from Contact_Team__c
	                             where User__c =: currentUser and Contact__r.email!=null order by Contact__r.LastActivityDate desc nulls last, Contact__r.name asc]);
}

private static List<Contact_Team__c> getContacts1() {
	return [select Contact__r.Id, Contact__r.Name, Contact__r.Email from Contact_Team__c
	        where User__c =: currentUser and Contact__r.email!=null order by Contact__r.LastActivityDate desc nulls last, Contact__r.name asc];
}

public PageReference favoriteCollateral(){
	Favorite_Collateral__c fav = new Favorite_Collateral__c();
	favorited = true;
	fav.User__c = currentUser;
	fav.ContentDocumentId__c = thisCollateral.documentId;
	for(Favorite_Collateral__c fc : [select Id from
	                                 Favorite_Collateral__c where User__c =: currentUser and ContentDocumentId__c=:thisCollateral.documentId]) {
		favorited = false;
		fav = fc;
	}
	if(favorited) insert fav;
	else delete fav;
	return null;
}

public PageReference sendEmail(){
	emailSent = false;
	Messaging.reserveSingleEmailCapacity(2);
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	if(isValidEmail(contactEmail)) {
		try{
			String[] toAddresses = new String[] {contactEmail};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo(UserInfo.getUserEmail());
			mail.setSenderDisplayName(UserInfo.getName());
			mail.setSubject(thisCollateral.title);
			String publicUrl = getPublicUrl(thisCollateral);
			mail.setPlainTextBody(emailBody +'<br/><br/>'+ publicUrl);
			mail.setHtmlBody(emailBody +'<br/><br/>'+ '<a href="'+publicUrl+
			                 '">'+thisCollateral.title+'</a>');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			emailSent = true;
			logEmail(UserInfo.getUserEmail(), UserInfo.getUserId(), contactEmail, publicUrl, thisCollateral.title);
		} catch(Exception ex) {
			ApexPages.addMessages(ex);
		}
	} else{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, contactEmail+' is not a valid email address. Please enter a valid email address and try again.'));
	}

	contactEmail = '';
	return null;
}

private static void logEmail(String fromEmail, Id fromUser, String toEmail, String sharedFileLink, String sharedFileName){
	SalesHD_Email_Log__c emailLog = new SalesHD_Email_Log__c(From_Email__c=fromEmail, From_User__c=fromUser,
	                                                         Shared_File_Link__c=sharedFileLink, Shared_File_Name__c=sharedFileName, To_Email__c=toEmail);
	List<Contact> contacts = [select Id from contact where email=:toEmail limit 1];
	if(!contacts.isEmpty()) emailLog.To_Contact__c=contacts[0].Id;
	insert emailLog;
}

private static Boolean isValidEmail(String email){
	String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
	Pattern emailPattern = Pattern.compile(emailRegex);
	Matcher emailMatch = emailPattern.matcher(email);
	if (emailMatch.matches()) {
		return true;
	}
	return false;
}

private static String getPublicUrl(collateral c){
	List<ContentDistribution> cds = [select DistributionPublicUrl
	                                 from ContentDistribution where ContentVersionId = :c.collateralId];
	if(!cds.isEmpty() && cds[0].DistributionPublicUrl!=null) return cds[0].DistributionPublicUrl;

	ContentDistribution cd = new ContentDistribution();
	if(c.title.length()>=80) cd.Name = c.title.substring(0,80) + System.now().format('mm/dd/yyyy');
	else cd.Name = c.title.substring(0,c.title.length()) + System.now().format('mm/dd/yyyy');
	cd.ContentVersionId = c.collateralId;
	cd.PreferencesAllowViewInBrowser= true;
	cd.PreferencesLinkLatestVersion=true;
	cd.PreferencesNotifyOnVisit=false;
	cd.PreferencesPasswordRequired=false;
	cd.PreferencesAllowOriginalDownload= true;
	insert cd;
	cd = [select DistributionPublicUrl
	      from ContentDistribution where Id = :cd.Id];
	return cd.DistributionPublicUrl;
}

public List<EmailTemplate> getEmailTemplates(){
	List<EmailTemplate> templates = [select id, name, htmlValue, description from EmailTemplate where folderId in (select id from folder where name='Hospital Division Email Templates')];
	return templates;
}

// public List<Selectoption> getFavoritedContactEmailAddress(){
// 	List<Selectoption> picklist = new List<selectoption>();
// 	picklist.add(new selectOption('', 'Favorited Contact Email Addresses'));
// 	for(Contact_Team__c ct : [select contact__r.email from contact_team__c where contact__r.email!=null and user__c=:UserInfo.getUserId()]){
// 		String email = ct.contact__r.email;
// 		picklist.add(new selectOption(email, email));
// 	}
// 	return picklist;
// }

public String templateId {get; set;}
public String favoritedEmail {get; set;}

public PageReference populateEmail() {
	if(favoritedEmail!=null && favoritedEmail!='') {
		contactEmail = favoritedEmail;
	}
	return null;
}

public PageReference sendEmailTemplate(){

	emailSent = false;
	if(isValidEmail(contactEmail)) {
		Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, null);
		List<Contact> contacts = [select Id from contact where email=:contactEmail limit 1];
		if(!contacts.isEmpty()) email = Messaging.renderStoredEmailTemplate(templateId, contacts[0].Id, null);
		String subject = email.getSubject();
		String body = email.gethtmlBody();
		email.setSubject(subject);
		email.sethtmlBody(body);
		email.saveAsActivity = false;
		email.toAddresses = new String[] {contactEmail};
		try{
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			List<EmailTemplate> templates = [select id, name from EmailTemplate where id=:templateId];
			String templateName = '';
			if(!templates.isEmpty()) templateName = templates[0].name;
			logEmail(UserInfo.getUserEmail(), UserInfo.getUserId(), contactEmail, System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+templateId, 'Email Template: '+templateName);
			emailSent = true;
		} catch(Exception ex) {
			ApexPages.addMessages(ex);
		}
	} else {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, contactEmail+' is not a valid email address. Please enter a valid email address and try again.'));
	}
	contactEmail = '';
	return null;

}

public PageReference sendTemplateEmail(){
	emailSent = false;
	Messaging.reserveSingleEmailCapacity(2);
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	if(isValidEmail(contactEmail)) {
		try{
			String[] toAddresses = new String[] {contactEmail};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo(UserInfo.getUserEmail());
			mail.setSenderDisplayName(UserInfo.getName());
			// Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, null);
			// String subject = email.getSubject();
			// mail.setSubject(subject);
			mail.setSubject(emailSubject);
			String plainText = emailBody.replaceAll('<a"', '');
			plainText = plainText.replaceAll('href="', '');
			plainText = plainText.replaceAll('">', ' - ');
			plainText = plainText.replaceAll('</a>', '');

			emailBody.replace('/(?:\r\n|\r|\n)/g', '<br/>');
			mail.setPlainTextBody(plainText);
			mail.setHtmlBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			emailSent = true;
			// logEmail(UserInfo.getUserEmail(), UserInfo.getUserId(), contactEmail, publicUrl, thisCollateral.title);
		} catch(Exception ex) {
			ApexPages.addMessages(ex);
		}
	} else{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, contactEmail+' is not a valid email address. Please enter a valid email address and try again.'));
	}

	contactEmail = '';
	return null;
}

private PageReference getEmailTemplate(String emailTemplateId){

	for(EmailTemplate et : [select id, name, htmlValue, description from EmailTemplate where id=:emailTemplateId and 
	folderId in (select id from folder where name='Hospital Division Email Templates')]) {
		templateId = et.Id;
		emailSubject = Messaging.renderStoredEmailTemplate(emailTemplateId, null, null).getSubject();
		emailBody = Messaging.renderStoredEmailTemplate(emailTemplateId, null, null).gethtmlBody();
		
	}
	return null;
}

}