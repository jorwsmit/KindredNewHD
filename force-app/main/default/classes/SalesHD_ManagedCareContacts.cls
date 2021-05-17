public without sharing class SalesHD_ManagedCareContacts {

    public String searchString {get; set;}
    public String selectedState {get; set;}
    public String selectedType {get; set;}
    public String selectedRelationship {get; set;}
    // public String selectedPayorType {get; set;}
    public ApexPages.StandardSetController contactSSC {get; private set;}
    public List<contact> contacts {get; set;}

    public Contact cont {get; set;}

    public SalesHD_ManagedCareContacts(ApexPages.StandardController stdController) {
        cont = (Contact)stdController.getRecord();
        setupContactStandardSetSetup();
    }

    public List<Selectoption> getStatePicklist(){
        List<Selectoption> picklist = new List<selectoption>();
        picklist.add(new selectOption('', 'State'));
        for(AggregateResult ar : [select MailingState state from contact where MailingState!=null
        and status__c='Active' and (recordType.name='HD Contacts' or recordtype.name='HD Physicians'
        or recordtype.name='Managed Care Contacts')
         group by MailingState order by MailingState ]){
            String state = String.valueOf(ar.get('state'));
            picklist.add(new selectOption(state, state));
        }
        return picklist;
    }

    public List<Selectoption> getTypePicklist(){
        List<Selectoption> picklist = new List<selectoption>();
        picklist.add(new selectOption('', 'Contact Type'));
        for(recordType rt : [select Id, Name from recordType where SobjectType='Contact' 
        and (name='HD Physicians' or name='Managed Care Contacts')]){
            picklist.add(new selectOption(rt.Id, rt.Name));
        }
        return picklist;
    }

    public List<Selectoption> getRelationshipPicklist(){
        List<Selectoption> picklist = new List<selectoption>();
        picklist.add(new selectOption('', 'Relationship'));
         Schema.DescribeFieldResult fieldResult = Contact.SalesHD_Managed_Care_Relationship__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             picklist.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
         }     
         return picklist;
     }

    public PageReference searchContacts() {
        setupContactStandardSetSetup();
        getAllContacts();
        return null;
    }

    private void setupContactStandardSetSetup(){
        String query = 'select id, name, MailingAddress__c, Title__c, SalesHD_Managed_Care_Relationship__c, '+
        'LastActivityDate, MailingState from contact where status__c=\'Active\' and recordType.name!=\'HD Contacts\' and recordType.name!=\'HD Physician Requests\' ' ;
        if(searchString!=null)
        query += ' and (name like \'%'+searchString+'%\' or MailingAddress__c like \'%'+searchString+'%\')';
    
        if(selectedState!=null) query += ' and MailingState like \''+selectedState+'\'';
        if(selectedType!=null) query += ' and RecordTypeId = \''+selectedType+'\'';
        if(selectedRelationship!=null) query += ' and SalesHD_Managed_Care_Relationship__c like \''+selectedRelationship+'\'';
        query += ' order by name asc';
    
        contactSSC = new ApexPages.StandardSetController(Database.getQueryLocator(
            query
        ));
        contactSSC.setPageSize(20);
    }

    public List<Contact> getAllContacts (){	
        return contactSSC.getRecords();
    }

    public List<Contact_Team__c> getFavoritedContacts (){	
        String userId = UserInfo.getUserId();
        String query = 'select contact__c, contact__r.name, contact__r.MailingAddress__c,'+
        ' contact__r.Title__c, contact__r.SalesHD_Managed_Care_Relationship__c, '+
        'contact__r.LastActivityDate, contact__r.MailingState from contact_team__c where contact__r.status__c=\'Active\''+
        ' and user__c=:userId';
        return Database.query(query);
    }

    public PageReference save() {
		PageReference contactPage;
		try{
			update cont;
			contactPage = new PageReference('/apex/SalesHD_ManagedCareContact?id='+cont.Id);
		}
		catch(DmlException ex){
			ApexPages.addMessages(ex);
		}
		if(contactPage!=null) contactPage.setRedirect(true);
		return contactPage;
	}

}
