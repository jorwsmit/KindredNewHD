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
	                                                                'UNKNOWN' => '<i class="fa fa-file-o resource-icon" aria-hidden="true"></i>'};


private static Id currentUser = UserInfo.getUserId();

public class collateral {
Id collateralId;
Id documentId;
String title = '';
String description = '';
String icon;
Boolean audience_professional = false;
Boolean audience_patient = false;
Boolean favorited = false;
String type = '';
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

public String collateralId {get; set;}

public SalesHD_Collaterals() {
	collaterals = getCollaterals();
	if(ApexPages.CurrentPage().getparameters().get('id')!=null) {
		getCollateral(ApexPages.CurrentPage().getparameters().get('id'));
		isFavorited(ApexPages.CurrentPage().getparameters().get('id'));
	}

	favoritedContactList = getContacts1();

	favoritedContacts = getContacts();

	collateralTypes = getCollateralTypes();

}

private static String getCollaterals(){

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
	                               ContentDocument.LatestPublishedVersion.Audience_Tag__c, ContentDocumentId
	                               from ContentWorkspaceDoc where ContentWorkspace.Name='HD Collaterals']) {
		collateral c = new collateral();
		c.collateralId = cwd.ContentDocument.LatestPublishedVersionId;
		if(cwd.ContentDocument.Title!=null) c.title = cwd.ContentDocument.Title;
		if(cwd.ContentDocument.Description!=null) c.description = cwd.ContentDocument.Description;
		c.icon = fileIcons.get(cwd.ContentDocument.FileType);
		if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c!=null) {
			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('professional')) c.audience_professional = true;
			if(cwd.ContentDocument.LatestPublishedVersion.Audience_Tag__c.contains('patient')) c.audience_patient = true;
		}
		if(favoriteCollaterals.contains(cwd.ContentDocumentId)) c.favorited = true;
        if(cwd.ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c!=null) c.type = cwd.ContentDocument.LatestPublishedVersion.HD_Collateral_Type__c;
		cList.add(c);
	}
	return JSON.serializePretty(cList);
}

private PageReference getCollateral(String collateralId){

	for(ContentWorkspaceDoc cwd : [select ContentDocument.Title, ContentDocument.FileType,
	                               ContentDocument.LatestPublishedVersionId, ContentDocument.Description,
	                               ContentDocument.LatestPublishedVersion.Audience_Tag__c, ContentDocumentId
	                               from ContentWorkspaceDoc where ContentDocument.LatestPublishedVersionId = :collateralId]) {
		collateral c = new collateral();
		c.collateralId = cwd.ContentDocument.LatestPublishedVersionId;
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
		emailBody = 'Hi,\n\nClick on the link below to view the collateral.\n\n'+link+'\n\nThanks,\n'+UserInfo.getName();

	}
	return null;
}

private static List<String> getCollateralTypes(){
	List<String> pickListValuesList= new List<String>{'Show All Types'};
	Schema.DescribeFieldResult fieldResult = ContentVersion.HD_Collateral_Type__c.getDescribe();
	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	for( Schema.PicklistEntry pickListVal : ple) {
		pickListValuesList.add(pickListVal.getLabel());
	}
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
	Messaging.reserveSingleEmailCapacity(2);
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	String[] toAddresses = new String[] {contactEmail};
	mail.setToAddresses(toAddresses);
	mail.setReplyTo(UserInfo.getUserEmail());
	mail.setSenderDisplayName(UserInfo.getName());
	mail.setSubject(thisCollateral.title);
	mail.setPlainTextBody(emailBody);
	mail.setHtmlBody(emailBody);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	return null;
}

}