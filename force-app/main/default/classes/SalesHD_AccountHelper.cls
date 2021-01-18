public with sharing class SalesHD_AccountHelper {

public SalesHD_AccountHelper() {

}

public List<Account_Sales_Plan__c> getAccountPlans(){
	if(apexpages.currentpage().getparameters().get('id')!=null) {
		return [select Parent_Sales_Plan__c, Parent_Sales_Plan__r.SalesHD_Plan_Date__c from Account_Sales_Plan__c where
                Account__c=: apexpages.currentpage().getparameters().get('id') 
                order by Parent_Sales_Plan__r.SalesHD_Plan_Date__c limit 100];
	} else{
        return new List<Account_Sales_Plan__c>();
    }
}

}
