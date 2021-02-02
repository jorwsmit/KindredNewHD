@isTest(seeAllData=false)
public class SalesHD_TestAccountHelper {
    @testSetup static void setup(){
        RecordType accountRecordType = [select Id from RecordType where name = 'HD Accounts'];
        Account acct = new Account(Name='Test Account', Status__c='Active', RecordtypeId=accountRecordType.Id);
        insert acct;
    
        AccountTeamMember atm = new AccountTeamMember(AccountId=acct.Id, UserId=UserInfo.getUserId());
        insert atm;
    
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User usr = new User(Alias = 'newUser2', Email='testhduser2@kndcrm.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = '00e1B000000jWdg',
                                TimeZoneSidKey='America/Los_Angeles', UserName='testhduser2@kndcrm.com', UserRoleId='00E130000020vp7');
            insert usr;
    
            Sales_Plans__c sp = new Sales_Plans__c();
            sp.ownerId = usr.id;
            sp.SalesHD_Plan_date__c = Date.newInstance(System.now().year(),
                                                       System.now().month(), 1);
            insert sp;

            Account_Sales_Plan__c asp = new Account_Sales_Plan__c();
            asp.Parent_Sales_Plan__c = sp.Id;
            asp.Account__c = acct.Id;
            insert asp;
        }
    
    }

    @isTest static void CoverAccountHelper() {
        Test.startTest();
        SalesHD_AccountHelper controller = new SalesHD_AccountHelper();
        PageReference pageRef = Page.SalesHD_Account;
        Account a = [select Id from account where name='Test Account' limit 1];
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        controller.getAccountPlans();
	    Test.setCurrentPage(pageRef);
        controller.getAccountPlans();
        Test.stopTest();
    }

}
