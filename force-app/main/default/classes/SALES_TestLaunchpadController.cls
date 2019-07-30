@isTest(SeeAllData = false)
public class SALES_TestLaunchpadController {
    public static Id userId;
    @testSetup static void setup(){
        final ID SALES_KAH_Associate = '00e1300000225C9';
        User usr = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = SALES_KAH_Associate,  
        TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');
        
        Datetime cd = System.now();
        
        Account unassignedAcct = new Account(Name='Unassigned Account - Admin Maintenance');
        insert unassignedAcct;
        
        insert usr;
        Account acct = new Account(Name='Test Account', KAH_Account_Classification__c = 'A+1');
        insert acct;
        AccountTeamMember actm = new AccountTeamMember(UserId = usr.Id, AccountId = acct.Id);
        insert actm;
        
        Contact con = new Contact(FirstName='Test', LastName = 'Account', KAH_Account_Classification__c = 'A+1');
        insert con;
        Contact_Team__c ct = new Contact_Team__c(User__c = usr.Id, Contact__c = con.Id);
        insert ct;
        
        cd.addDays(-1);
        Event e = new Event(ActivityDateTime = cd, OwnerId = usr.Id, DurationInMinutes = 15, whoId = con.Id, whatId = acct.Id);
        insert e;
        
        acct = new Account(Name='Test Account2', KAH_Account_Classification__c = 'A1');
        insert acct;
        actm = new AccountTeamMember(UserId = usr.Id, AccountId = acct.Id);
        insert actm;
        Sales_account_metrics__c am = new Sales_account_metrics__c(Name='1', Account__c=acct.Id, Month__c=date.newInstance(System.now().year(), System.now().month(), 1));
        insert am;
        am = new Sales_account_metrics__c(Name='2', Account__c=acct.Id, Month__c=date.newInstance(System.now().year(), System.now().month(), 1).addMonths(-1));
        insert am;
        am = new Sales_account_metrics__c(Name='3', Account__c=acct.Id, Month__c=date.newInstance(System.now().year()-1, System.now().month(), 1));
        insert am;
        
         con = new Contact(FirstName='Test', LastName = 'Account2', KAH_Account_Classification__c = 'A1');
        insert con;
        ct = new Contact_Team__c(User__c = usr.Id, Contact__c = con.Id);
        insert ct;
        Sales_contact_metrics__c cm = new Sales_contact_metrics__c(Name='1', Contact__c=con.Id, Month__c=date.newInstance(System.now().year(), System.now().month(), 1).addMonths(-1));
        insert cm;
        cm = new Sales_contact_metrics__c(Name='2', Contact__c=con.Id, Month__c=date.newInstance(System.now().year(), System.now().month(), 1));
        insert cm;
        cm = new Sales_contact_metrics__c(Name='3', Contact__c=con.Id, Month__c=date.newInstance(System.now().year()-1, System.now().month(), 1));
        insert cm;
        
        cd.addDays(-2);
        e = new Event(ActivityDateTime = cd, OwnerId = usr.Id, DurationInMinutes = 15, whoId = con.Id, whatId = acct.Id);
        insert e;
        
        userId = usr.Id;
               
    }
    
    @isTest static void test1() {
        
        User usr = [select Id from user where username='KAHSalesAssociate@testorg.com'];
        
        Test.StartTest();
        SALES_LaunchpadController.getSPDataSalesCalls(usr.Id, 0);
        SALES_LaunchpadController.getSPData(usr.Id, 0);
        SALES_LaunchpadController.getThisWeeksEvents(usr.Id, 0);
        SALES_LaunchpadController.getRecentBirthdays(usr.Id);
        SALES_LaunchpadController.getReports('Sales: KAH Reports');
        SALES_LaunchpadController.getDefaultRadio(usr.Id);
        SALES_LaunchpadController.getRecordType('name');
        
        
        SALES_LaunchpadController.emailLastActivityByClassification(usr.Id, 'Blob');

        UserRole ur = [select Id from UserRole where Name='SVP - KAH'];
        SALES_LaunchpadController.getUsersByRole(ur.Id);
        SALES_LaunchpadController.getUsersUnderRoleId(ur.Id);
        ur = [select Id from UserRole where Name like 'SA%' limit 1];
        SALES_LaunchpadController.getLogins(usr.Id, ur.Id);
        SALES_LaunchpadController.getUsersByRole(ur.Id);
        Test.StopTest();
    }
    
    @isTest static void test2() {
        
        User usr = [select Id from user where username='KAHSalesAssociate@testorg.com'];
        
        Test.StartTest();
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', 'All', '', 'HH');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', '1', '', 'HH');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A+', '1', '', 'HH');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', '1', '', 'HH');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', 'All', '', 'HH');
            
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', 'All', '', 'HP');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', '1', '', 'HP');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A+', '1', '', 'HP');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', '1', '', 'HP');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', 'All', '', 'HP');
            
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', 'All', '', 'MTD');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', '1', '', 'MTD');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A+', '1', '', 'MTD');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', '1', '', 'MTD');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', 'All', '', 'MTD');
            
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', 'All', '', 'YOY');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'All', '1', '', 'YOY');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A+', '1', '', 'YOY');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', '1', '', 'YOY');
            SALES_LaunchpadController.getLastActivityByClassification(usr.Id, 'A', 'All', '', 'YOY');
        Test.StopTest();
    }
}