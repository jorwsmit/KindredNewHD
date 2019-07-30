@isTest 
private class AA_LeadTriggerTest {

	private static testMethod void AA_LeadTest(){ 
    	
    	list<User> lstUserToInsert = new list<User>();
        
        Id profileId=userinfo.getProfileId();
        
        for(Integer i=0; i<=14; i++){
            lstUserToInsert.add(new User(Alias = 'teCon'+i, Email='testContactTeam'+i+'@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='testContactTeam'+i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='testContactTeam'+i+'@testorg.com'));
        	}
        insert lstUserToInsert;
        
	    list<Lead>lstLead = new list<Lead>();
        
        List<RecordType> lstRecTypesLead = [Select Name, Id From RecordType where sObjectType='Lead' AND isActive = true];
        List<RecordType> lstRecTypesCon = [Select Name, Id From RecordType where sObjectType='Contact' AND isActive = true];
        
        Lead objLead = new Lead(Company = 'TestLead', LastName = 'Tester', FirstName ='Test', RecordTypeId = lstRecTypesLead[0].Id, NPI__c = '12');
		lstLead.add(objLead);
		
		Lead objLead2 = new Lead(Company = 'TestLead2', LastName = 'Tester', FirstName ='Test', RecordTypeId = lstRecTypesLead[0].Id, NPI__c = '123');
		lstLead.add(objLead2);
		
		Lead objLead5 = new Lead(Company = 'TestLead5', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead5);
		
		Lead objLead6 = new Lead(Company = 'TestLead6', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead6);
		
		Lead objLead7 = new Lead(Company = 'TestLead7', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead7);
		
		Lead objLead8 = new Lead(Company = 'TestLead8', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead8);
		
		Lead objLead9 = new Lead(Company = 'TestLead9', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead9);
		
		Lead objLead10 = new Lead(Company = 'TestLead10', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead10);
		
		Lead objLead11 = new Lead(Company = 'TestLead11', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead11);
		
		Lead objLead12 = new Lead(Company = 'TestLead12', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead12);
		
		Lead objLead13 = new Lead(Company = 'TestLead13', LastName = 'Tester', FirstName ='Test');
		lstLead.add(objLead13);
		
		insert lstLead;
		
		Lead objLead3 = new Lead(Company = 'TestLead3', LastName = 'Tester', FirstName ='Test');
		insert objLead3;
		
		Lead objLead4 = new Lead(Company = 'TestLead4', LastName = 'Tester', FirstName ='Test');
		insert objLead4;
		
		merge objLead3 objLead4; 
	
		objLead11.Street = '680 S 4th St';
		objLead11.City = 'Louisville';
		objLead11.State = 'KY';
		objLead11.PostalCode = '40202';
		update objLead11;
	}
    
}