public with sharing class AA_MergeRequest {

    public class listWrapper{
        @AuraEnabled 
        public sObject itm  {get;set;}
        @AuraEnabled 
        public Boolean selected    {get;set;}
        @AuraEnabled 
        public string itemID  {get;set;}
        @AuraEnabled 
        public string name  {get;set;} 
        @AuraEnabled 
        public string npi   {get;set;} 
        @AuraEnabled 
        public string shippingCity  {get;set;} 
        @AuraEnabled 
        public string shippingState {get;set;} 
        @AuraEnabled 
        public string shippingStreet    {get;set;} 
        @AuraEnabled 
        public string shippingPostalCode    {get;set;} 
        @AuraEnabled
        public string phone {get;set;}
        @AuraEnabled
        public string horizon   {get;set;}
        @AuraEnabled
        public string unity {get;set;}
        @AuraEnabled
        public string meditech  {get;set;}
        @AuraEnabled 
        public string rType {get;set;}
        @AuraEnabled 
        public string owner {get;set;}
        @AuraEnabled 
        public string definitive {get;set;}
        @AuraEnabled 
        public string cms {get;set;}
        
        public listWrapper(Account a){
            itm = a;
            itemID = a.ID;
            selected = false;
            name = a.Name;
            npi = a.NPI__c;
            horizon = a.Horizon_ID__c;
            meditech = a.Meditech_ID__c;
            unity = a.Unity_ID__c;
            if(a.ShippingCity != null){
            	shippingCity = a.ShippingCity;
            	}
            else{
            	shippingCity = a.BillingCity;
            	}
            if(a.shippingState != null){		
            	shippingState = a.ShippingState;
            	}
            else{
            	shippingState = a.BillingState;
            	}
            if(a.Shippingstreet != null){		 
            	shippingStreet = a.Shippingstreet;
            	}
            else{
            	shippingStreet = a.Billingstreet;
            	}	
            if(a.ShippingPostalCode != null){
            	shippingPostalCode = a.ShippingPostalCode;
            	}
            else{
            	shippingPostalCode = a.BillingPostalCode;
            	}	
            rType = a.RecordType.Name;
            owner = a.Owner.Name;
            phone = a.Phone;
            definitive = a.KRS_Definitive_ID__c;
            cms = a.CMS_Provider_ID__c;
            }
            
        public listWrapper(Contact c){
            itm = c;
            selected = false;
            itemID = c.ID;
            name = c.Name;
            npi = c.NPI__c;
            horizon = c.Horizon_ID__c;
            meditech = c.Meditech_Contact_ID__c;
            unity = c.Unity_ID__c;
            shippingCity = c.MailingCity;
            shippingState = c.MailingState; 
            shippingStreet = c.MailingStreet;
            shippingPostalCode = c.MailingPostalCode;
            rType = c.RecordType.Name;
            owner = c.Owner.Name;
            phone = c.Phone;
            }   
        
        }
        
    //Get list of available state options
    @AuraEnabled(cacheable=true) 
    public static list<string> getStateList(){
        list<string> lstStates = new list<string>();
        lstStates.add('None');
        for(States__c objState : [SELECT Id, Name FROM States__c Order BY Name]) {
            lstStates.add(objState.Name);
            }
        return lstStates;
        }   

    @AuraEnabled(cacheable=true)
    public static Account getAccount(ID id){
        Account acc = new Account();
            acc = [SELECT ID,
                          Name,
                          Phone,
                          NPI__c,
                          Type,
                          Owner.Name,
                          Horizon_ID__c,
                          Unity_ID__c,
                          Meditech_ID__c,
                          RecordType.Name,
                          BillingStreet, 
                          BillingCity, 
                          BillingState, 
                          BillingPostalCode,
                          ShippingStreet,
                          ShippingCity,
                          ShippingState,
                          ShippingPostalCode,
                          KRS_Definitive_ID__c,
                          CMS_Provider_ID__c
                          FROM
                          Account
                          WHERE ID =: id];
        return acc;
        }
    
    @AuraEnabled(cacheable=true)
    public static Contact getContact(ID id){
        Contact ctc = new Contact();
        ctc = [SELECT ID,
                      Account.Name,
                      Account.NPI__c,
                      Owner.Name,
                      Name,
                      Email,
                      NPI__c,
                      Horizon_ID__c,
                      Unity_ID__c,
                      Meditech_Contact_ID__c,
                      FirstName,
                      LastName,
                      Phone,
                      RecordType.Name,
                      MailingStreet,
                      MailingCity,
                      MailingState,
                      MailingPostalCode
                      FROM
                      Contact
                      WHERE ID =: id];
        return ctc; 
        }
        
    
    @AuraEnabled(cacheable=true)
    public static list<listWrapper> getAccountItems(string searchStr, ID id, string cityFilter, string stateFilter){
        
        list<ID> salesKAHIDs = new list<ID>();
        salesKAHIDs.add('01230000000Khh2');
        
        list<ID> salesHDIDs = new list<ID>();
        salesHDIDs.add('0121B000001CGFs');
    
        list<ID> rehabIDs = new list<ID>();
        rehabIDs.add('01213000001WHKX');
        rehabIds.add('01213000001WHKY');
    
        list<ID> krsIDs = new list<ID>();
        krsIDs.add('0121B0000018Fz1');
        
        system.debug('City filter: ' + cityFilter);
        system.debug('State filter: ' + stateFilter);
        
                
        ID id1 = userInfo.getProfileID();
        list<Profile> profiles = [SELECT Name FROM Profile WHERE id = :id1 LIMIT 1];
        string profileName = string.valueOf(profiles[0].Name);
        system.debug('Profile Name: ' + profileName);
        list<listWrapper> acclstWrp = new list<ListWrapper>();
        string sortStr = '';
        string sortVal = '';
        list<Account> accList = new list<Account>();
            string searchID = id;
            string query = '';
            if(userInfo.getProfileID() == '00e300000010RQT'){
                query = 'SELECT ID, Name, Phone, KRS_Definitive_ID__c, CMS_Provider_ID__c, NPI__c, Owner.Name, HMS_POID__c, Horizon_ID__c, HPAS_ID__c, Unity_ID__c, Meditech_ID__c, RecordType.Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE ID !=: searchID AND Name LIKE \'%'+ searchStr + '%\'';
                }
            else{
                query = 'SELECT ID, Name, Phone, KRS_Definitive_ID__c, CMS_Provider_ID__c, NPI__c, Owner.Name, HMS_POID__c, Horizon_ID__c, HPAS_ID__c, Unity_ID__c, Meditech_ID__c, RecordType.Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE RecordType.ID !=\'01230000000YKF4\' AND ID !=: searchID AND Name LIKE \'%'+ searchStr + '%\'';            
                }
            if(profileName.contains('Sales: KAH') || profileName == 'Sales - KAH Admin'){
                query = query + ' AND RecordTypeID IN : salesKAHIDs';
                }
            else if(profileName.contains('Sales: HD') || profileName == 'Sales - HD Admin'){
                query = query + ' AND RecordTypeID IN : salesHDIDs';
                }   
            else if(profileName.contains('RHC')){
                query = query + ' AND RecordTypeID IN : rehabIDs';
                }
            else if(profileName.contains('KRS')){
                query = query + ' AND RecordTypeID IN : krsIDs';
                }
            
            if(cityFilter != null && cityFilter != ''){
                query = query + ' AND (ShippingCity LIKE: cityFilter OR BillingCity =: cityFilter)';
                }
            if(stateFilter != null && stateFilter != 'None'){
                query = query + ' AND (ShippingState =: stateFilter OR BillingState =: stateFilter)';
                }       
                
            system.debug('query: ' + query);        
            accList = database.query(query);    
        for(Account a: accList){
            accLstWrp.add(new listWrapper(a));
            }
        return accLstWrp;
        }
    
    @AuraEnabled(cacheable=true)
    public static list<listWrapper> getContactItems(string searchStr, ID id, string cityFilter, string stateFilter){
        
        list<ID> salesKAHIDs = new list<ID>();
        salesKAHIDs.add('01230000000Khno');
    
        list<ID> salesHDIDs = new list<ID>();
        salesHDIDs.add('0121B000001CGFx');
    
        list<ID> rehabIDs = new list<ID>();
        rehabIDs.add('01213000001WHKZ');
        
        list<ID> krsIDs = new list<ID>();
        krsIDs.add('0121B0000018Fz2');
        
        system.debug('City filter: ' + cityFilter);
        system.debug('State filter: ' + stateFilter);
        
        ID id1 = userInfo.getProfileID();
        list<Profile> profiles = [SELECT Name FROM Profile WHERE id = :id1 LIMIT 1];
        string profileName = string.valueOf(profiles[0]);
        
        list<listWrapper> conlstWrp = new list<ListWrapper>();
        string sortStr = '';
        string sortVal = '';
        list<Contact> ctcList = new list<Contact>();
        
            string searchID = id;   
            string query = 'SELECT ID, Name, NPI__c, HMS_PIID__c, Horizon_ID__c, HPAS_Contact_ID__c, Unity_ID__c, Meditech_Contact_ID__c, Phone, RecordType.Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, Owner.Name FROM Contact WHERE ID !=: searchID AND Name LIKE \'%'+ searchStr + '%\'';
            if(profileName.contains('Sales: KAH') || profileName == 'Sales - KAH Admin'){
                query = query + ' AND RecordTypeID IN : salesKAHIDs';
                }
            else if(profileName.contains('Sales: HD') || profileName == 'Sales - HD Admin'){
                query = query + ' AND RecordTypeID IN : salesHDIDs';
                }
            else if(profileName.contains('RHC')){
                query = query + ' AND RecordTypeID IN : rehabIDs';
                }
            else if(profileName.contains('KRS')){
                query = query + ' AND RecordTypeID IN : krsIDs';
                }
            
            if(cityFilter != null  && cityFilter != ''){
                query = query + ' AND MailingCity LIKE: cityFilter';
                }
            if(stateFilter != null && stateFilter != 'None'){
                query = query + ' AND MailingState =: stateFilter';
                }
            system.debug('query: ' + query);
            ctcList = database.query(query);
        for(Contact c: ctcList){
            conLstWrp.add(new listWrapper(c));
            }
        
        return conLstWrp;
        }
    
    @AuraEnabled
    public static string getRequestMergeResult(list<string> checkedItems, ID accID, ID ctcID, string additionalInstruct, string objType){
        list<Account> toUpdateA = new list<Account>();
        list<Contact> toUpdateC = new list<Contact>();
        list<Approval> toInsertA = new list<Approval>();
                
        ID objID;
        string result = '';
        system.debug('checkedItems: ' + checkedItems);
        system.debug('accID: ' + accID);
        system.debug('ctcID: ' + ctcID);
        system.debug('objType: ' + objType);
        if(accID != null && objType == 'account'){
            objID = accID;
            Account mWin = [SELECT ID, Name, Merge_Approved__c, Merge_Master__c, Merge_Requested__c, Merge_Request_With_Name__c, Merge_Requested_With_ID__c, Merge_requested_by__c FROM Account WHERE ID =: accID];
            mWin.Merge_Master__c = true;
            mWin.Merge_Requested__c = true;
            mWin.Merge_Requested_With_ID__c = accID;
            mWin.Merge_Request_With_Name__c = mWin.Name;
            mwin.Merge_Approved__c = true;
            mWin.Merge_requested_by__c = UserInfo.getName();
            
            update mWin;
            
            for(Account a : [SELECT ID, Name, Merge_Requested__c, Merge_Requested_With_ID__c, Merge_Request_With_Name__c, Merge_requested_by__c FROM Account WHERE ID In: checkedItems]){
                a.Merge_Requested__c = true;
                a.Merge_Requested_With_ID__c = objID;
                a.Merge_Request_With_Name__c = mWin.Name;
                a.Merge_requested_by__c = UserInfo.getName();
                update a;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            
                req.setComments('A Merge has Been Requested for the following items.  ' +
                                'New master item: ' + mWin.Name 
                              + '.  Merged Record: ' + a.Name + '.  ' +
                                'Please review the items and approve or reject the request so it can be processed.  ' +
                                'If the requester has provided any additional comments they will appear here: ' + additionalInstruct);
                req.setObjectId(a.ID);
                system.debug('reqCheck'+req);
                // submit the approval request(s) for processing
                Approval.ProcessResult rslt = Approval.process(req);
                }
            result = 'Your request has been sent and will be processed.';   
            }
        if(ctcID != null && objType == 'contact'){
            objID = ctcID;
            Contact mWin = [SELECT ID, Name, Merge_Approved__c, Merge_Master__c, Merge_Requested__c, Merge_Request_With_Name__c, Merge_Requested_With_ID__c, Merge_requested_by__c FROM Contact WHERE ID =: ctcID];
            mWin.Merge_Master__c = true;
            mWin.Merge_Requested__c = true;
            mWin.Merge_Requested_With_ID__c = ctcID;
            mWin.Merge_Request_With_Name__c = mWin.Name;
            mwin.Merge_Approved__c = true;
            mWin.Merge_requested_by__c = UserInfo.getName();
            update mWin;
            
            for(Contact c : [SELECT ID, Name, Merge_Requested__c, Merge_Requested_With_ID__c, Merge_Request_With_Name__c, Merge_requested_by__c FROM Contact WHERE ID In: checkedItems]){
                c.Merge_Requested__c = true;
                c.Merge_Requested_With_ID__c = objID;
                c.Merge_Request_With_Name__c = mWin.Name;
                c.Merge_requested_by__c = UserInfo.getName();
                update c;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            
                req.setComments('A Merge has Been Requested for the following items.  ' +
                                'New master item: ' + mWin.Name 
                              + '.  Merged Record: ' + c.Name + '.  ' +
                                'Please review the items and approve or reject the request so it can be processed.  ' +
                                'If the requester has provided any additional comments they will appear here: ' + additionalInstruct);
                req.setObjectId(c.ID);
                //req.setSubmitterId(system.Userinfo.getUserId());
                system.debug('reqCheck'+req);
                // submit the approval request for processing
                system.debug('Submitting Contact approval');
                Approval.ProcessResult rslt = Approval.process(req);
                }
            result = 'Your request has been sent and will be processed.';
            }
        return result;
        }           
    
}