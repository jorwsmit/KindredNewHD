@isTest
private class AA_PFTaskPRocessorTest {

    static testMethod void myUnitTest(){
        User u2 = new User(ProfileId = '00e13000001dtUi', 
	    				   UserRoleId = '00E130000027IJE',
	    				   FirstName = 'Test2',
	    				   LastName = 'User2',
	    				   userName = 'test2323@usertest.none',
	    				   Alias = 'te9200', Email ='testC98@testorg.com', 
            			   EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', 
            			   LocaleSidKey ='en_US', TimeZoneSidKey ='America/Los_Angeles');
	    				  
	    insert u2;
	    system.runAs(u2){
	    List<RecordType> lstRecTypesAcc = [Select Name, Id From RecordType where sObjectType='Account' AND isActive = true];
        List<RecordType> lstRecTypesCon = [Select Name, Id From RecordType where sObjectType='Contact' AND isActive = true];
        
        Account objAccount = new Account(Name='TestAccount', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '12', PF_Product_Type__c = 'Test Product');
		insert objAccount;
        
		Contact objContact = new Contact(LastName='TestContact', RecordTypeId = lstRecTypesCon[0].Id, NPI__c = '1263', PF_NPS_Rating__c = 5, Account = objAccount);
		insert objContact;
	    
	    Task t = new Task(Subject = 'NPS Survey',
	    				  RecordTypeID = '0121B000001CGNN',
	    				  ActivityDate = system.today(),
	    				  OwnerId = u2.ID,
	    				  Priority = 'Low',
	    				  WhoID = objContact.ID
	    				  );
	    				  insert t;
	    }
    	}
}