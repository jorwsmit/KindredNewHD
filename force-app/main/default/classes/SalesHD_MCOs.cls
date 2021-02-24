public with sharing class SalesHD_MCOs {

    public String selectedState {get; set;}
    public String selectedPayorType {get; set;}
    public String searchString {get; set;}
    public ApexPages.StandardSetController accountSSC {get; private set;}
    public List<account> mcos {get; set;}
    public Account mco {get; set;}


    public SalesHD_MCOs(ApexPages.StandardController stdController) {

        mco = (Account)stdController.getRecord();
        
        setupAccountStandardSetSetup();
    }


    public List<Selectoption> getStatePicklist(){
        List<Selectoption> picklist = new List<selectoption>();
        picklist.add(new selectOption('', 'State'));
        for(AggregateResult ar : [select ShippingState state from account where ShippingState!=null
        and status__c='Active' and recordType.name='HD MCOs' group by ShippingState order by ShippingState ]){
            String state = String.valueOf(ar.get('state'));
            picklist.add(new selectOption(state, state));
        }
        return picklist;
    }

    public List<Selectoption> getPayorTypePicklist(){
        List<Selectoption> picklist = new List<selectoption>();
        picklist.add(new selectOption('', 'Payor Type'));
         Schema.DescribeFieldResult fieldResult = Account.SalesHD_MCO_Payor_Type__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             picklist.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
         }     
         return picklist;
     }

    public PageReference searchAccounts() {
        setupAccountStandardSetSetup();
        getAllAccounts();
        return null;
    }

    private void setupAccountStandardSetSetup(){
        String query = 'select id, name, shippingAddress__c, type, SalesHD_MCO_Payor_Type__c, Payor_Parent__r.Name, '+
        'LastActivityDate from account where recordtype.name=\'HD MCOs\' and status__c=\'Active\'';
        if(searchString!=null)
        query += ' and (name like \'%'+searchString+'%\' or shippingAddress__c like \'%'+searchString+'%\')';
    
        if(selectedState!=null) query += ' and ShippingState like \''+selectedState+'\'';
        if(selectedPayorType!=null) query += ' and SalesHD_MCO_Payor_Type__c like \''+selectedPayorType+'\'';

        query += ' order by name asc';
    
        accountSSC = new ApexPages.StandardSetController(Database.getQueryLocator(
            query
        ));
        accountSSC.setPageSize(20);
    }

    public List<Account> getAllAccounts (){	
        return accountSSC.getRecords();
    }

    public List<AccountTeamMember> getFavoritedAccounts (){	
        String userId = UserInfo.getUserId();
        String query = 'select accountId, account.name, account.shippingAddress__c'+
        ', account.type, account.SalesHD_MCO_Payor_Type__c, account.Payor_Parent__r.Name, '+
        'account.LastActivityDate from accountTeamMember where account.recordtype.name=\'HD MCOs\' and'+
        ' account.status__c=\'Active\' and userId=:userId';
        return Database.query(query);
    }

    public PageReference save() {
		PageReference mcoPage;
		try{
			update mco;
			mcoPage = new PageReference('/apex/SalesHD_MCO?id='+mco.Id);
		}
		catch(DmlException ex){
			ApexPages.addMessages(ex);
		}
		if(mcoPage!=null) mcoPage.setRedirect(true);
		return mcoPage;
	}

}
