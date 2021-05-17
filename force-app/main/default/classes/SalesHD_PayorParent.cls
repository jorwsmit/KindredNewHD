public with sharing class SalesHD_PayorParent {

    public Account payorParent {get; set;}
    public String selectedState {get; set;}
    public String selectedPayorType {get; set;}
    public String searchString {get; set;}
    public ApexPages.StandardSetController accountSSC {get; private set;}
    public List<account> mcos {get; set;}


    public SalesHD_PayorParent(ApexPages.StandardController stdController) {

        payorParent = (Account)stdController.getRecord();
        
        setupAccountStandardSetSetup();
    }


    public List<Selectoption> getStatePicklist(){
        List<Selectoption> picklist = new List<selectoption>();
        picklist.add(new selectOption('', 'State'));
        for(AggregateResult ar : [select ShippingState state from account where ShippingState!=null
        and status__c='Active' and recordType.name='HD Accounts' group by ShippingState order by ShippingState ]){
            String state = String.valueOf(ar.get('state'));
            picklist.add(new selectOption(state, state));
        }
        return picklist;
    }

    // public List<Selectoption> getPayorTypePicklist(){
    //     List<Selectoption> picklist = new List<selectoption>();
    //     picklist.add(new selectOption('', 'Payor Type'));
    //      Schema.DescribeFieldResult fieldResult = Account.SalesHD_MCO_Payor_Type__c.getDescribe();
    //      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    //      for( Schema.PicklistEntry pickListVal : ple){
    //          picklist.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
    //      }     
    //      return picklist;
    //  }

    public PageReference searchAccounts() {
        setupAccountStandardSetSetup();
        getAllAccounts();
        return null;
    }

    private void setupAccountStandardSetSetup(){
        Id payorParentId = payorParent.Id;
        String query = 'select id, name, shippingAddress__c, type, Payor_Parent__r.Name, '+
        'LastActivityDate from account where recordtype.name=\'HD MCOs\' and status__c=\'Active\' and Payor_Parent__c=:payorParentId';
        if(searchString!=null)
        query += ' and (name like \'%'+searchString+'%\' or shippingAddress__c like \'%'+searchString+'%\')';
    
        if(selectedState!=null) query += ' and ShippingState like \''+selectedState+'\'';
        query += ' order by name asc';
    
        accountSSC = new ApexPages.StandardSetController(Database.getQueryLocator(
            query
        ));
        accountSSC.setPageSize(20);
    }

    public List<Account> getAllAccounts (){	
        return accountSSC.getRecords();
    }
}
