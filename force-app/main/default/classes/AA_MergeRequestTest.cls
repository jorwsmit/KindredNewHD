@isTest
private class AA_MergeRequestTest {

    static testMethod void myUnitTest() {
        
        List<RecordType> lstRecTypesAcc = [Select Name, Id From RecordType where sObjectType='Account' AND isActive = true];
        list<Account>lstAccount = new list<Account>();
        
        
        Account objAccount = new Account(Name='TestAccount', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '12');
        lstAccount.add(objAccount);
        
        Account objAccount2 = new Account(Name='TestAccount2', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '123');
        lstAccount.add(objAccount2);
        
        Account objAccount5 = new Account(Name='TestAccount5');
        lstAccount.add(objAccount5);
        insert lstAccount;
        
        list<String> idLst = new list<String>();
        idLst.Add(objAccount5.ID);
        
        AA_MergeRequest.getStateList();
        AA_MergeRequest.getAccount(objAccount.ID);
        AA_MergeRequest.getAccountItems('Test', objAccount.ID, 'San Francisco', 'CA');
        
        AA_MergeRequest.getAccountItems('Test', objAccount.ID, '', 'CA');
        AA_MergeRequest.getAccountItems('Test', objAccount.ID, 'San Francisco', '');
        AA_MergeRequest.getAccountItems('Test', objAccount.ID, '', '');
        
        AA_MergeRequest.getRequestMergeResult(idLst, objAccount.ID, null, 'Test Comments', 'account');
        
        AA_ApprovalReviewController.getApprovals();
        }
        
    static testMethod void unitTest2(){
        List<RecordType> lstRecTypesAcc = [Select Name, Id From RecordType where sObjectType='Account' AND isActive = true];
        list<Account>lstAccount = new list<Account>();
        
        
        Account objAccount = new Account(Name='TestAccount', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '12');
        lstAccount.add(objAccount);
        
        Account objAccount2 = new Account(Name='TestAccount2', RecordTypeId = lstRecTypesAcc[0].Id, NPI__c = '123');
        lstAccount.add(objAccount2);
        
        Account objAccount5 = new Account(Name='TestAccount5');
        lstAccount.add(objAccount5);
        insert lstAccount;
        
        List<RecordType> lstRecTypesCon = [Select Name, Id From RecordType where sObjectType='Contact' AND isActive = true];
        list<Contact>lstContact = new list<Contact>();
        Contact objContact = new Contact(LastName='TestContact', RecordTypeId = lstRecTypesCon[0].Id, NPI__c = '1263', AccountID = objAccount.ID);
        lstContact.add(objContact);
        
        Contact objContact2 = new Contact(LastName='TestContact2', RecordTypeId = lstRecTypesCon[0].Id, NPI__c = '5123', AccountID = objAccount2.ID);
        lstContact.add(objContact2);
        
        Contact objContact3 = new Contact(LastName='TestContact3', RecordTypeId = lstRecTypesCon[0].Id, NPI__c = '7123', AccountID = objAccount5.ID);
        lstContact.add(objContact3);
        insert lstContact;
        
        list<String> idLst = new list<String>();
        idLst.Add(objContact3.ID);
        
        AA_MergeRequest.getContact(objContact.ID);
        
        AA_MergeRequest.getContactItems('Test', objContact.ID, 'San Francisco', 'CA');
        
        AA_MergeRequest.getContactItems('Test', objContact.ID, '', 'CA');
        AA_MergeRequest.getContactItems('Test', objContact.ID, 'San Francisco', '');
        AA_MergeRequest.getContactItems('Test', objContact.ID, '', '');
        
        AA_MergeRequest.getRequestMergeResult(idLst, null, objContact.ID, 'Test Comments', 'contact');
        AA_ApprovalReviewController.getApprovals();
    }   
}