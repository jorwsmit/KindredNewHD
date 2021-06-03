
@isTest(seeAllData=false)
public class SalesHD_TestManagedCare {

@testSetup static void setup(){
	RecordType mcAccountRecordType = [select Id from RecordType where name = 'HD Managed Care Accounts'];
	Account mcAcct = new Account(Name='Test Managed Care Account', Status__c='Active', RecordtypeId=mcAccountRecordType.Id, ShippingState='KY');
	insert mcAcct;

    Unit__c u1 = new Unit__c(Name='Administrative', Active__c=True);
	insert u1;

    Contact con = new Contact(FirstName='Favorite', LastName = 'Contact', Status__c='Active', Title__c='ICU Director', SalesHD_Managed_Care_Relationship__c='Good');
    insert con;

    Contact_Team__c ct = new Contact_Team__c(Contact__c=con.Id, User__c=UserInfo.getUserId());
	insert ct;

	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		User usr = new User(Alias = 'newUser2', Email='testhduser2@kndcrm.com',
		                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                    LocaleSidKey='en_US', ProfileId = '00e1B000000jWdg',
		                    TimeZoneSidKey='America/Los_Angeles', UserName='testhduser2@kndcrm.com', UserRoleId='00E130000020vp7');
		insert usr;

		Alert_and_Comment__c ac = new Alert_and_Comment__c(Datetime__c=System.now(), Comment_By__c=thisUser.Id,
		                                                   Type__c='HD Corporate Message', Comment__c='Test');
		insert ac;

        AccountTeamMember atm = new AccountTeamMember(AccountId=mcAcct.Id, UserId=UserInfo.getUserId());
	    insert atm;

        RecordType contactRecordType = [select Id from RecordType where name = 'Managed Care Contacts' limit 1];
        con = new Contact(FirstName='Test', LastName = 'Contact', Status__c='Active', Title__c='ICU Director', SalesHD_Managed_Care_Relationship__c='Good'
        , recordTypeId=contactRecordType.Id);
        insert con;

        contactRecordType = [select Id from RecordType where name = 'HD Physicians' limit 1];
        con = new Contact(FirstName='Test', LastName = 'Physician', Status__c='Active', Title__c='ICU Director', recordTypeId=contactRecordType.Id);
	    insert con;

	}
}

@isTest static void MCOs() {
	PageReference pageRef = Page.SalesHD_MCOs;
	Test.setCurrentPage(pageRef);
	Account acct = [select Id from account where name='Test Managed Care Account' limit 1];
	ApexPages.StandardController sc = new ApexPages.standardController(acct);
	Test.startTest();
	SalesHD_MCOs controller = new SalesHD_MCOs(sc);

	List<SelectOption> picklist = controller.getTypePicklist();
	picklist = controller.getStatePicklist();

	controller.selectedState = 'KY';
	controller.searchAccounts();

	controller.selectedType = 'MCO';
	controller.searchAccounts();

    controller.getFavoritedAccounts();

    controller.save();

	Test.stopTest();

}

@isTest static void ManagedCareContacts() {
	PageReference pageRef = Page.SalesHD_ManagedCareContacts;
	Test.setCurrentPage(pageRef);
	Contact con = [select Id from contact where name='Test Contact' limit 1];
	ApexPages.StandardController sc = new ApexPages.standardController(con);
	Test.startTest();
	SalesHD_ManagedCareContacts controller = new SalesHD_ManagedCareContacts(sc);

	List<SelectOption> picklist = controller.getTypePicklist();
	picklist = controller.getStatePicklist();
    picklist = controller.getRelationshipPicklist();

	controller.selectedState = 'KY';
	controller.searchContacts();

    RecordType rt = [select Id from recordType where name = 'Managed Care Contacts' limit 1];
	controller.selectedType = rt.Id;
	controller.searchContacts();

    controller.getFavoritedContacts();

    controller.save();

	Test.stopTest();

}

@isTest static void ManagedCareComponents_Contacts() {
    Contact con = [select Id from contact where name='Test Contact' limit 1];
    PageReference page = new PageReference('/apex/SalesHD_Contact?id='+con.Id);
	Test.setCurrentPage(page);
	Test.startTest();
    SalesHD_ManagedCareComponents controller = new SalesHD_ManagedCareComponents();
    controller.recordId = con.Id;
    controller.favorite();
    controller.favorite();
    Test.stopTest();
}

@isTest static void ManagedCareComponents_Files() {
    Contact con = [select Id from contact where name='Test Contact' limit 1];
    PageReference page = new PageReference('/apex/SalesHD_Contact?id='+con.Id);
	Test.setCurrentPage(page);
	Test.startTest();
    SalesHD_ManagedCareComponents controller = new SalesHD_ManagedCareComponents();
    controller.saveNote();
    controller.recordId = con.Id;
    controller.saveNote();
    controller.noteBody = 'test';
    controller.file = Blob.valueOf('test file');
	controller.fileName = 'testfile.pdf';
    controller.saveNote();
    controller.getMyNotes();
    User u = [select Id from user where username='testhduser2@kndcrm.com' limit 1];
    System.runAs(u) {
		controller.saveNote();
	}
    controller.getNotes();
    List<ContentDocumentLink> noteIds = [select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:con.Id];
	controller.noteId = noteIds[0].ContentDocumentId;
    controller.deleteNote();
    Test.stopTest();
}

@isTest static void ManagedCareComponents_Events() {
    Contact con = [select Id from contact where name='Test Contact' limit 1];
    Account acct = [select Id from account where name='Test Managed Care Account' limit 1];
    PageReference page = new PageReference('/apex/SalesHD_Contact?id='+con.Id);
	Test.setCurrentPage(page);
    Event e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now().addDays(-1),
	                    EndDateTime=system.now().addDays(-1)+5, Type='Follow-up', whoId=con.Id, whatId=acct.Id);
	Test.startTest();
    insert e;
    SalesHD_ManagedCareComponents controller = new SalesHD_ManagedCareComponents();
    controller.recordId = con.Id;
    controller.getRelatedEvents();
    controller.recordId = acct.Id;
    controller.getRelatedEvents();
    Test.stopTest();
}

@isTest static void ManagedCareComponents_Accounts() {
    Contact con = [select Id from contact where name='Test Contact' limit 1];
    Account acct = [select Id from account where name='Test Managed Care Account' limit 1];
    PageReference page = new PageReference('/apex/SalesHD_MCO?id='+acct.Id);
	Test.setCurrentPage(page);
	Test.startTest();
    SalesHD_ManagedCareComponents controller = new SalesHD_ManagedCareComponents();
    controller.recordId = acct.Id;
    controller.favorite();
    controller.favorite();
    controller.getFavoritedContactPicklist();
    controller.favoritedContactIdToRelate = con.Id;
    controller.relateContactToAccount();
    controller.getRelatedContacts();
    controller.recordId = con.Id;
    controller.favorite();
    controller.favorite();
    controller.favorite();
    controller.getRelatedAccounts();
    controller.relatedAccountId = acct.Id;
    controller.deleteAccountRelation();
    controller.getDirectory();
    Test.stopTest();
}

@isTest static void ManagedCareComponents_Homepage() {
    Contact con = [select Id from contact where name='Test Contact' limit 1];
    Account acct = [select Id from account where name='Test Managed Care Account' limit 1];
    PageReference page = new PageReference('/apex/SalesHD_ManagedCareHome');
	Test.setCurrentPage(page);
    Event e = new Event(ownerId=UserInfo.getUserId(), ActivityDateTime=System.now().addDays(-1),
	                    EndDateTime=system.now().addDays(-1)+5, Type='Follow-up', whoId=con.Id, whatId=acct.Id);
	Test.startTest();
    insert e;
    SalesHD_ManagedCareComponents controller = new SalesHD_ManagedCareComponents();
    controller.messageText = 'test';
    controller.file = Blob.valueOf('test file');
	controller.fileName = 'testfile.pdf';
    controller.newMessage();
    controller.getMessages();
    controller.getNotifications();
    controller.getDataYoy();
    controller.getEncountersByAccount();
    controller.getContactRelationships();
}


}