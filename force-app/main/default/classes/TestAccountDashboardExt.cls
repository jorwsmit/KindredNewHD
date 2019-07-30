@isTest
public class TestAccountDashboardExt {
  @isTest static void calingAllRemoteQueryFunctions() {
        
        final id Sales_HD_Associate = '00ea0000001serv';
                
        Account acct = new Account(Name='Test Account');
      	User u = new User(Alias = 'standt', Email='test@jstestord.com', EmailEncodingKey='UTF-8',
                          LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = Sales_HD_Associate, 
            			  TimeZoneSidKey='America/Los_Angeles', UserName='test@jstestord.com'); 
        insert acct;
      	insert u;
        AccountDashboardExt.loadOpps(acct.id);
        AccountDashboardExt.queryHms(acct.id);
      	AccountDashboardExt.queryAdmits(acct.id);
        AccountDashboardExt.queryAccountTeam(acct.id);
        AccountDashboardExt.queryLastActivty(u.id, acct.id);
      	AccountDashboardExt.queryBirthdays(acct.id);
      	AccountDashboardExt.queryEvents(acct.id);
      	AccountDashboardExt.queryEvent180(acct.id);
      	AccountDashboardExt.queryTouchpoints(acct.id);
    }
}