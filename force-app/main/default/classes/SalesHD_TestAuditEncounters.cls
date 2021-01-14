@isTest(seeAllData=false)

public class SalesHD_TestAuditEncounters {

@testSetup static void setup(){
	RecordType accountRecordType = [select Id from RecordType where name = 'HD Accounts'];
	Account acct = new Account(Name='Test Account', Status__c='Active', RecordtypeId=accountRecordType.Id);
    insert acct;

    Unit__c u = new Unit__c(Name='test unit');
    insert u;
    
    Account_Unit__c au = new Account_Unit__c(Unit__c=u.Id, Account__c=acct.Id);
    insert au;                          
    
    Contact con = new Contact(FirstName='Test', LastName = 'Contact', Status__c='Active', Title__c='ICU Director');
    insert con;
    

	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		User usr = new User(Alias = 'newUser2', Email='testhduser2@kndcrm.com',
		                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                    LocaleSidKey='en_US', ProfileId = '00e1B000000jWdg', Region__c='HD', District__c='California',
		                    TimeZoneSidKey='America/Los_Angeles', UserName='testhduser2@kndcrm.com', UserRoleId='00E130000020vp7');
        insert usr;

		Event e = new Event(ownerId=usr.id, ActivityDateTime=System.now(),
	                    EndDateTime=system.now()+5, Type='Follow-up', whoId=con.Id, whatId=acct.Id,
	                    SalesHD_Account_Unit__c=au.Id, SalesHD_Call_Objective__c='Other',
                        SalesHD_Open_Ended_Questions__c='test');

        insert e;

        e = new Event(ownerId=usr.Id, ActivityDateTime=System.now().addDays(-7),
	                    EndDateTime=System.now().addDays(-7)+5, Type='Follow-up', whoId=con.Id, whatId=acct.Id,
	                    SalesHD_Account_Unit__c=au.Id, SalesHD_Call_Objective__c='Other',
                        SalesHD_Open_Ended_Questions__c='test');
        insert e;
	}

}

@isTest static void AuditEncounter_constructor() {
	PageReference pageRef = Page.SalesHD_AuditEncounters;
	Test.setCurrentPage(pageRef);
	Test.startTest();
	SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
	Test.stopTest();
}

@isTest static void AuditReport() {
	PageReference pageRef = Page.SalesHD_AuditReport;
	Test.setCurrentPage(pageRef);
    Test.startTest();
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.getReport();
    controller.thisweek = true;
    controller.toggleThisWeek();
    controller.getReport();
    User u = [select Id from user where UserName='testhduser2@kndcrm.com' limit 1];
    controller.selectedCL = u.Id;
    controller.getReport();
	Test.stopTest();
}

@isTest static void ShowChart() {
	PageReference pageRef = Page.SalesHD_AuditReport;
	Test.setCurrentPage(pageRef);
    Test.startTest();        
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.getReport();
    controller.thisweek = true;
    controller.toggleThisWeek();
    controller.getShowChart();
	Test.stopTest();
}

@isTest static void GetPicklists() {
	PageReference pageRef = Page.SalesHD_AuditReport;
	Test.setCurrentPage(pageRef);
    Test.startTest();        
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.getCLPicklist();
    controller.getMonthPicklist();
    controller.getYearPicklist();
	Test.stopTest();
}

@isTest static void DistrictMarketChart() {
	PageReference pageRef = Page.SalesHD_AuditReport;
	Test.setCurrentPage(pageRef);
    Test.startTest();        
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.getReport();
    controller.thisweek = true;
    controller.toggleThisWeek();
    controller.getDistrictChart();
    controller.getMarketChart();
	Test.stopTest();
}

@isTest static void MyEncounters() {
	PageReference pageRef = Page.SalesHD_AuditReport;
	Test.setCurrentPage(pageRef);
    Test.startTest();        
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.thisweek = true;
    controller.toggleThisWeek();
    User u = [select Id from user where UserName='testhduser2@kndcrm.com' limit 1];
    System.runAs(u){
        controller.getMyEncounters();
    }
	Test.stopTest();
}

@isTest static void ChangeDateFilter() {
	PageReference pageRef = Page.SalesHD_AuditEncounters;
	Test.setCurrentPage(pageRef);
	Test.startTest();
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.thisweek = true;
    controller.toggleThisWeek();
    controller.getEncounters();
    controller.weekly = true;
    controller.toggleWeekly();
    controller.getEncounters();
    controller.monthly = true;
    controller.toggleMonthly();
    controller.getEncounters();
	Test.stopTest();
}

@isTest static void AuditFirst() {
	PageReference pageRef = Page.SalesHD_AuditReport;
    Test.setCurrentPage(pageRef);
    User u = [select Id from user where UserName='testhduser2@kndcrm.com' limit 1];
    Event e = [select id from event where ownerid=:u.id order by activitydate desc limit 1];
    Test.startTest();        
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.encounterId = e.Id;
    controller.auditResult = 'Approved';
    controller.saveAudit();
    controller.managerComment = 'Testing a comment';
    controller.saveComment();
	Test.stopTest();
}

@isTest static void CommentFirst() {
	PageReference pageRef = Page.SalesHD_AuditReport;
    Test.setCurrentPage(pageRef);
    User u = [select Id from user where UserName='testhduser2@kndcrm.com' limit 1];
    Event e = [select id from event where ownerid=:u.id order by activitydate desc limit 1];
    Test.startTest();        
    SalesHD_AuditEncounters controller = new SalesHD_AuditEncounters();
    controller.usr.Region__c = 'HD';
    controller.usr.District__c = 'California';
    controller.encounterId = e.Id;
    controller.managerComment = 'Testing a comment';
    controller.saveComment();
    controller.auditResult = 'Missing Agenda';
    controller.saveAudit();
	Test.stopTest();
}


}