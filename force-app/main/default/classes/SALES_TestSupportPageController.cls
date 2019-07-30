@isTest(SeeAllData = false)
public class SALES_TestSupportPageController {

  private static final Id marketoLiaisonProfileId = '00ea0000001servAAA';
  private static final Id ncdClProfileId = '00e1300000225LuAAI';
  private static final Id khrsLiaisonProfileId = '00e13000001dtHjAAI';
  private static final Id kahSalesAssociateProfileId = '00e1300000225C9AAI';
  private static final Id sysAdminProfileId = '00e300000010RQTAA2';

  @isTest static void sendSupportTicket() {
    User usrHD = new User(Alias = 'test', Email='MarketoLiaison@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = marketoLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='MarketoLiaison@testorg.com');

    User usrNCD = new User(Alias = 'test', Email='NCDCL@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = ncdClProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='NCDCL@testorg.com');

    User usrKHRS = new User(Alias = 'test', Email='KHRS@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = khrsLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KHRS@testorg.com');

    User usrKAH = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = kahSalesAssociateProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');

    Test.StartTest();
    System.runAs(usrHD){
      SALES_SupportPageController.sendSupportTicket('Test', 'Testing');
    }
    System.runAs(usrNCD){
      SALES_SupportPageController.sendSupportTicket('Test', 'Testing');
    }
    System.runAs(usrKHRS){
      SALES_SupportPageController.sendSupportTicket('Test', 'Testing');
    }
    System.runAs(usrKAH){
      SALES_SupportPageController.sendSupportTicket('Test', 'Testing');
    }
    SALES_SupportPageController.sendSupportTicket('Test', 'Testing');
    SALES_SupportPageController.sendSupportTicket(null, null);
    Test.StopTest();
  }

  @isTest static void passwordReset() {
    User usrHD = new User(Alias = 'test', Email='MarketoLiaison@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = marketoLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='MarketoLiaison@testorg.com');
    insert usrHD;

    User usrNCD = new User(Alias = 'test', Email='NCDCL@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = ncdClProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='NCDCL@testorg.com');
    insert usrNCD;

    User usrKHRS = new User(Alias = 'test', Email='KHRS@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = khrsLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KHRS@testorg.com');
    insert usrKHRS;

    User usrKAH = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = kahSalesAssociateProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');
    insert usrKAH;

    User usrSys = new User(Alias = 'test', Email='KindredSysAdmin@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = sysAdminProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KindredSysAdmin@testorg.com');
    insert usrSys;

    Test.StartTest();
    SALES_SupportPageController.passwordReset('asdf');
    SALES_SupportPageController.passwordReset('Testing');
    SALES_SupportPageController.passwordReset('Testing1');
    SALES_SupportPageController.passwordReset('Testing2');
    SALES_SupportPageController.passwordReset('Testing3');
    SALES_SupportPageController.passwordReset('Testing4');
    SALES_SupportPageController.passwordReset('Testing5');
    //SALES_SupportPageController.passwordReset(null);
    Test.StopTest();

  }

  @isTest static void employeeForm() {
    User usrHD = new User(Alias = 'test', Email='MarketoLiaison@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = marketoLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='MarketoLiaison@testorg.com');

    User usrNCD = new User(Alias = 'test', Email='NCDCL@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = ncdClProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='NCDCL@testorg.com');

    User usrKHRS = new User(Alias = 'test', Email='KHRS@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = khrsLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KHRS@testorg.com');

    User usrKAH = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = kahSalesAssociateProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');

    Test.StartTest();
    System.runAs(usrHD){
      SALES_SupportPageController.employeeForm('New Employee', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    System.runAs(usrNCD){
      SALES_SupportPageController.employeeForm('Edit Employee', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    System.runAs(usrKHRS){
      SALES_SupportPageController.employeeForm('Transfer Employee', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    System.runAs(usrKAH){
      SALES_SupportPageController.employeeForm('Terminate Employee', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    SALES_SupportPageController.employeeForm('Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test', 'Test');
    SALES_SupportPageController.employeeForm('', '', '', '', '', '', '', '', '', '', '');
    Test.StopTest();
  }

  @isTest static void issue() {
    User usrHD = new User(Alias = 'test', Email='MarketoLiaison@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = marketoLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='MarketoLiaison@testorg.com');

    User usrNCD = new User(Alias = 'test', Email='NCDCL@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = ncdClProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='NCDCL@testorg.com');

    User usrKHRS = new User(Alias = 'test', Email='KHRS@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = khrsLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KHRS@testorg.com');

    User usrKAH = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = kahSalesAssociateProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');

    Test.StartTest();
    System.runAs(usrHD){
      SALES_SupportPageController.issue('Test', 'Testing');
    }
    System.runAs(usrNCD){
      SALES_SupportPageController.issue('Test', 'Testing');
    }
    System.runAs(usrKHRS){
      SALES_SupportPageController.issue('Test', 'Testing');
    }
    System.runAs(usrKAH){
      SALES_SupportPageController.issue('Test', 'Testing');
    }
    SALES_SupportPageController.issue('Test', 'Testing');
    SALES_SupportPageController.issue(null, null);
    Test.StopTest();
  }

  @isTest static void trainingDates() {
    User usrHD = new User(Alias = 'test', Email='MarketoLiaison@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = marketoLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='MarketoLiaison@testorg.com');

    User usrNCD = new User(Alias = 'test', Email='NCDCL@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = ncdClProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='NCDCL@testorg.com');

    User usrKHRS = new User(Alias = 'test', Email='KHRS@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = khrsLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KHRS@testorg.com');

    User usrKAH = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = kahSalesAssociateProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');

    Test.StartTest();
    System.runAs(usrHD){
      SALES_SupportPageController.trainingDates();
    }
    System.runAs(usrNCD){
      SALES_SupportPageController.trainingDates();
    }
    System.runAs(usrKHRS){
      SALES_SupportPageController.trainingDates();
    }
    System.runAs(usrKAH){
      SALES_SupportPageController.trainingDates();
    }
    SALES_SupportPageController.trainingDates();
    Test.StopTest();
  }

  @isTest static void missingReferralSources() {
    User usrHD = new User(Alias = 'test', Email='MarketoLiaison@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = marketoLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='MarketoLiaison@testorg.com');

    User usrNCD = new User(Alias = 'test', Email='NCDCL@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = ncdClProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='NCDCL@testorg.com');

    User usrKHRS = new User(Alias = 'test', Email='KHRS@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = khrsLiaisonProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KHRS@testorg.com');

    User usrKAH = new User(Alias = 'test', Email='KAHSalesAssociate@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = kahSalesAssociateProfileId,
    TimeZoneSidKey='America/Los_Angeles', UserName='KAHSalesAssociate@testorg.com');

    Test.StartTest();
    System.runAs(usrHD){
      SALES_SupportPageController.missingReferralSources('Test');
    }
    System.runAs(usrNCD){
      SALES_SupportPageController.missingReferralSources('Test');
    }
    System.runAs(usrKHRS){
      SALES_SupportPageController.missingReferralSources('Test');
    }
    System.runAs(usrKAH){
      SALES_SupportPageController.missingReferralSources('Test');
    }
    SALES_SupportPageController.missingReferralSources('Test');
    Test.StopTest();
  }

}