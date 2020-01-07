@isTest(seeAllData=true)
public class SalesHD_CollateralTests {

@isTest static void emailCollateral(){
	ContentWorkspace cw = [select Id from ContentWorkspace where Name = 'HD Collaterals'];

	ContentVersion cv = new ContentVersion();
	cv.title='ABC';
	cv.PathOnClient ='test';
	Blob b=Blob.valueOf('Unit Test Attachment Body');
	cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
	insert cv;

	ContentDocument cd = [select Id from ContentDocument where LatestPublishedVersionId =: cv.Id];

	ContentworkspaceDoc cwd = new ContentworkspaceDoc(ContentDocumentId=cd.Id, ContentWorkspaceId = cw.Id);
	insert cwd;

	Test.startTest();
	PageReference pageRef = Page.SalesHD_Collateral;
	pageRef.getParameters().put('id', cv.Id);
	Test.setCurrentPage(pageRef);
	SalesHD_Collaterals controller = new SalesHD_Collaterals();
	controller.emailBody = 'test';
	controller.contactEmail = 'test@test.com';
	controller.sendEmail();
	Test.stopTest();

}

@isTest static void favoriteUnfavorite(){
	ContentWorkspace cw = [select Id from ContentWorkspace where Name = 'HD Collaterals'];

	ContentVersion cv = new ContentVersion();
	cv.title='ABC';
	cv.PathOnClient ='test';
	Blob b=Blob.valueOf('Unit Test Attachment Body');
	cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
	cv.Audience_Tag__c = 'Patient';
	insert cv;

	ContentDocument cd = [select Id from ContentDocument where LatestPublishedVersionId =: cv.Id];

	ContentworkspaceDoc cwd = new ContentworkspaceDoc(ContentDocumentId=cd.Id, ContentWorkspaceId = cw.Id);
	insert cwd;

	Test.startTest();
	PageReference pageRef = Page.SalesHD_Collateral;
	pageRef.getParameters().put('id', cv.Id);
	Test.setCurrentPage(pageRef);
	SalesHD_Collaterals controller = new SalesHD_Collaterals();
	controller.favoriteCollateral();
	controller.favoriteCollateral();
	Test.stopTest();

}

@isTest static void isFavorited(){
	ContentWorkspace cw = [select Id from ContentWorkspace where Name = 'HD Collaterals'];

	ContentVersion cv = new ContentVersion();
	cv.title='ABC';
	cv.PathOnClient ='test';
	Blob b=Blob.valueOf('Unit Test Attachment Body');
	cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
	cv.Audience_Tag__c = 'Professional';
	insert cv;

	ContentDocument cd = [select Id from ContentDocument where LatestPublishedVersionId =: cv.Id];

	ContentworkspaceDoc cwd = new ContentworkspaceDoc(ContentDocumentId=cd.Id, ContentWorkspaceId = cw.Id);
	insert cwd;

	Test.startTest();
	PageReference pageRef = Page.SalesHD_Collateral;
	pageRef.getParameters().put('id', cv.Id);
	Test.setCurrentPage(pageRef);
	SalesHD_Collaterals controller = new SalesHD_Collaterals();
	controller.favoriteCollateral();
	controller = new SalesHD_Collaterals();
	Test.stopTest();

}


}