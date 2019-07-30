@isTest 
private class AA_AutoDataValidationAlertTest {

    static testMethod void myUnitTest(){
        Account a = new Account(Name='TestAccount', RecordTypeId = '01230000000Khh2', NPI__c = '12');
        Contact c = new Contact(LastName='TestContact', RecordTypeId = '01230000000Khno', NPI__c = '1263');
        insert a;
        insert c;
        
        String CRON_EXP = '0 0 * * * ?';
		AA_AutoDataValidationAlertScheduler sch = new AA_AutoDataValidationAlertScheduler();
		system.schedule('MonthlyEmailDataAlert', CRON_EXP, sch);
        }
        
}