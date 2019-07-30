/**
@ClassName    : TBN_CaseEntry
@CreatedOn    : 
@ModifiedBy   : Ritika, Rashmi
@Description  : Controller for TBN_CaseEntry page 
**/
global with sharing class TBN_CaseEntry {
    
    public static Integer COUNT_INFINITE_SCROLL     {get {return 16;}   }       // used for displaying no of article at a time
    
    // To store a RecordType Id for Contact with type "Individual" 
    private static Id CONTACT_RT_INDIVIDUAL = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Contact' AND DeveloperName = 'Individual'].Id;
    
    // To store a RecordType Id for Account with type "Center"
    private static Id ACCOUNT_RT_CENTER = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Account' AND DeveloperName = 'Center'].Id;  
    
    //Sobject type var                                      
    //public List<Account> accounts   {get;set;}                        // To store list of facility center account
    public List<Contact_Center__kav> lstKAV         {get;set;}          // List to hold knowledge article on load only
    public Case objCase                             {get;set;}          // Used with apex:inputField and to create a case
    public Contact objContact                       {get;set;}          // Used with apex:inputField and to create a contact
    public Patient_NEW__c objPatient                {get;set;}          // used when case type is referral and need to create patient record
    public Assessment__c objAssessment              {get;set;}          // used to store assessment data while createing case type referral
    public Patient_NEW__c objPatientForContactState {get;set;}          // used for showing picklist of states at case entry section
    public Patient_NEW__c objPatientForWebState     {get;set;}          // used for showing picklist value for web states on edit of case
    public Attachment objAttachment                 {get;set;}
    public string strGoogleAPIKey                   {get;set;}          //used to store the Google API key from custom settings
    
    //Primitive type var
    public Integer maxSize          {get;set;}                          // Will be indicatior of number of articles absed on filteration and search
    public String contactId         {get;set;}                          // Used with apex:inputHidden and refer while creating a case
    public String accountId         {get;set;}                          // Used with apex:inputHidden and refer while creating a case
    public String patientId         {get;set;}                          // Used with apex:inputHidden and refer while creating a case
    public String strphoneType      {get;set;}                          // Used with apex:inputHidden to store phone type
    public String strRefererURL     {get;set;}                          // Gets the referer url to redirect to when Cancel button is clicked
    public Boolean isEdit           {get;set;}                          // To identify page launched from Edit button
    public Boolean isWebToCase      {get;set;}                          // To identify weather case is originated from web
    public Account objAccount       {get;set;}                          // To create a Account
    public String strPhoneInURL     {get;set;}
            
    private List<RecordType> lstRTCase;                                 // To store locally RecordType obj
    private Id contactRTIndividual;                                     // Id for Contact's Individual RT
    private Id caseRtReferral;                                          // Id for Case's Referral RT
    private Id caseRtGeneral;                                           // Id for Case's General RT
    private Id accountRtHousehold;                                      // Id for Account's Household RT
    private String caseId;                                              // Id of Case from where page is launched                             
    private string strLiveAgentTranscriptId;
    
    // Constructor
    global TBN_CaseEntry(ApexPages.StandardController controller) {
            
        init();
    } 
    
    /*
    Method Name: createCase
    Return type: PageReference
    Description: To create a case based on information filled at page side form 
    */
    public PageReference createCaseNRedirectToDetail() {
        
        String attachmentId = Apexpages.currentPage().getParameters().containsKey('attachmentId') ? Apexpages.currentPage().getParameters().get('attachmentId') : '';
        String callerId = Apexpages.currentPage().getParameters().containsKey('callerId') ? Apexpages.currentPage().getParameters().get('callerId') : '';
        
        Id idToReturn = createACase(attachmentId, callerId);
        
        if(idToReturn == Null)  {
            
            return null;
        }
        else {
            
            return new pageReference('/'+idToReturn).setRedirect(true);
        }
    }
    
    
    /*
    Method Name: createCaseWithClose
    Return type: PageReference
    Description: To create a case with Status 'Closed' based on information filled at page side form 
    */
    public PageReference createCaseWithCloseNRedirectToDetail() {
        
        String attachmentId = Apexpages.currentPage().getParameters().containsKey('attachmentId') ? Apexpages.currentPage().getParameters().get('attachmentId') : '';
        String callerId = Apexpages.currentPage().getParameters().containsKey('callerId') ? Apexpages.currentPage().getParameters().get('callerId') : '';
        
        objCase.Status = 'Closed';
        Id idToReturn = createACase(attachmentId, callerId);
        
        if(idToReturn == Null)  {
            
            return null;
        }
        else {
            
            return new pageReference('/'+idToReturn).setRedirect(true);
        }
    }
  
    /*
        Method Name: getColorCodesFromCS
        Return Type: map<String, String>
        Description: To return the color codes stored in Custom Setting.
    */
    
    @RemoteAction
    global static  map<String, String> getColorCodesFromCS() {
        
        map<String, String>mapColorCodes = new map<String,String>();

        for(Case_Entry_Map_Color_Codes__c objCS : Case_Entry_Map_Color_Codes__c.getAll().values() ){
          
          mapColorCodes.put(objCS.Type__c, objCS.Color_Code__c);
        }
        
        return mapColorCodes;
    }
    
    /*
    Method Name: searchPatients
    Return Type: List<Patient_NEW__c>
    Description; To search Patients based on given searchText parameter
    */
    @RemoteAction
    global static List<Patient_NEW__c> searchPatients(String searchText) {
        
        String strSOSL = 'Find \''+ String.escapeSingleQuotes(searchText) +'*\' IN ALL FIELDS RETURNING Patient_NEW__c '+
                         '(Name, Date_of_Birth__c, Suffix__c, First_Name__c, Last_Name__c, Middle_Initial__c, Age__c, Sex__c, '+
                            'E_mail__c, Phone__c, Street__c, City__c, Status__c, Status_Detail__c, Lead_Lost_Date__c, Next_Call_Date__c, State__c, Postal_Code__c limit 500)'; 
                            
        return search.query(strSOSL)[0];
    }
    
    /*
    Method Name: searchContacts
    Return Type: List<Contact>
    Description; To search contact based on given searchText parameter in 'Indiviual' recordType
    */
    @RemoteAction
    global static List<Contact> searchContacts(String searchText) {
        
        String strSOSL = 'Find \''+ String.escapeSingleQuotes(searchText) +'*\' IN ALL FIELDS RETURNING Contact '+
                         '(FirstName, AccountId, LastName, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, ' +
                            'Phone, HomePhone, MobilePhone, OtherPhone, Email WHERE RecordTypeId =: CONTACT_RT_INDIVIDUAL limit 500)'; 
                            
        return search.query(strSOSL)[0];
    }
    
    /*
    Method Name: getNearByAccounts
    Return Type: void
    Description; To search account in 100 mile radius based on given geolocation  where record type is 'Center'
    */
    @RemoteAction 
    global static List<Account> getNearByAccounts(String city, String state, String zipCode, Double latitude, Double longitude) {
        
        Integer maxDistance = 100;
      	system.debug('city: ' + city);
      	system.debug('state: ' + state);
      	system.debug('zipCode: ' + zipCode);
      	system.debug('latitude: ' + latitude);
      	system.debug('longitude: ' + longitude);
      	
        String strQueryString;
        string status = 'Active';
        strQueryString = 'SELECT Name, Central_Intake_Email__c, Facility_Number__c, ShippingStreet, Shipping_Geolocation__Latitude__s, Shipping_Geolocation__Longitude__s, ShippingCity, ShippingState, ShippingCountry, Type, Phone, ShippingPostalCode FROM Account WHERE RecordTypeId = : ACCOUNT_RT_CENTER AND Type != null AND Status__c=: status';
           
        if(city != '' || zipCode != '' ) {
          
            strQueryString += ' AND DISTANCE(Shipping_Geolocation__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') < '+ maxDistance+
                                ' ORDER BY DISTANCE(Shipping_Geolocation__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') limit 250';
        }
        else if(state != '')     
            strQueryString +=' AND ShippingState = : state ORDER BY DISTANCE(Shipping_Geolocation__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') ASC limit 250';
    
    	system.debug('query: ' + strQueryString);
        List<Account> accounts = new List<Account>();
        accounts = Database.query(strQueryString);
        
        return accounts;
    }
    
    /*
    Method Name: filterArticles
    Return type: InfiniteScrollResponse wrapper object
    Description: Code Related to Knowledge base actions called when search is performed or Case type is changes at page side
    */
    @RemoteAction
    global static InfiniteScrollResponse filterArticles(String searchString, String caseType, Integer offset, String strFilter) {
        
        List<Contact_Center__kav> lstSKAV = new List<Contact_Center__kav>();
        caseType = String.isEmpty(caseType) ? 'All' : caseType;
        String dataCategoryFilter = '';
        
        //strFilter will be empty when both Kindred & Gentiva are unchecked
        if(String.isNotEmpty(strFilter))
            dataCategoryFilter = ' WITH DATA CATEGORY Contact_Center__c ABOVE_OR_BELOW '+ strFilter;
        else
            return new InfiniteScrollResponse(new List<Contact_Center__kav>(), false);
            
        if(String.isNotEmpty(searchString)) {
            
            String searchquery = 'FIND \'' + String.escapeSingleQuotes(searchString) + '*\'IN ALL FIELDS RETURNING'+
                          ' Contact_Center__kav(Id, title, Summary ,How_To_Resolve__c where'+
                          ' PublishStatus =\'online\' and Language = \'en_US\') '+ dataCategoryFilter;
                          
            lstSKAV = search.query(searchquery)[0];  
        }
        else {
            
            String qryString = 'SELECT Id, title, Summary, How_To_Resolve__c FROM '+
                                'Contact_Center__kav WHERE (PublishStatus = \'online\' and Language = \'en_US\') '+ dataCategoryFilter + 
                                ' Order By Title limit '+COUNT_INFINITE_SCROLL+' offset '+offset;
                                
            lstSKAV = Database.query(qryString);
        }
        
        Boolean hasMore = COUNT_INFINITE_SCROLL == lstSKAV.size();
        
        if(!lstSKAV.isEmpty() && hasMore)
            lstSKAV.remove(lstSKAV.size()-1); //removing extra record from list
        
        return new InfiniteScrollResponse(lstSKAV, hasMore);
    }
    
    
    /*
    Method Name: retreiveFacilityContent
    Return type: List<ContentVersion> 
    Description: called when we click on facility either at map or at list of faclity and retrun related Content of facility
    */
    @RemoteAction
    global static List<ContentVersion> retreiveFacilityContent(String accId) {
        
        return [SELECT Id, Title, FileType, ContentDocumentId, ContentSize 
                FROM ContentVersion 
                WHERE Center__c =:accId And IsLatest = true And  FileType In ('MP4','PDF') ORDER BY Title LIMIT 1000];
    }

    
    /*
    Method Name: createACase
    Return type: Id
    Description: A common method to create a account, contact, case, patient
    */
    private Id createACase(String attachmentId, String callerId) {
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            Id caseId;
            Boolean isNewContact = false;
            
            //In case of manual entry at case page . either no result from autocomplete or no use of autocomplete
            if(String.isEmpty(contactId)) {
                
                isNewContact = true;
                objContact.MailingState = objPatientForContactState.State__c;
                objPatientForContactState = new Patient_NEW__c(); 
                objContact.LastName = string.isNotBlank(objContact.LastName) ? objContact.LastName.trim(): '';
                objContact.FirstName = string.isNotBlank(objContact.FirstName) ? objContact.FirstName.trim(): '';
              
                objAccount.Name = (!String.isEmpty(objContact.FirstName))? 'The Household of '+objContact.FirstName +' '+objContact.LastName :  'The Household of '+objContact.LastName;
                
                objAccount.ShippingStreet = objContact.MailingStreet;
                objAccount.ShippingCity = objContact.MailingCity;
                objAccount.ShippingState = objContact.MailingState;
                objAccount.ShippingPostalCode = objContact.MailingPostalCode;
                
                upsert objAccount;
                
                objContact.AccountId = objAccount.Id;
                
                if(strphoneType != 'Phone') {
                     
                     
                    if(String.isNotBlank(callerId))
                        objContact.put(strphoneType, callerId);
                    else 
                        objContact.put(strphoneType, strPhoneInURL);
                    
                    if(String.isBlank(objContact.Caller_id__c))
                        objContact.Caller_id__c = strPhoneInURL;
                            
                    objContact.Phone = '';
                }
                else {
                
                    if(String.isBlank(callerId))
                        objContact.Phone = strPhoneInURL;
                        
                    if(String.isBlank(objContact.Caller_id__c))
                        objContact.Caller_id__c = strPhoneInURL;
                }
                
                upsert objContact;
                 
                contactId = objContact.Id;
                accountId = objAccount.Id;
            }
            else {
                contact objContact = new Contact(Id = contactId, MailingStreet = objContact.MailingStreet, MailingCity = objContact.MailingCity, MailingPostalCode = objContact.MailingPostalCode, Email = objContact.Email, Caller_id__c = objContact.Caller_id__c);
                objContact.MailingState = objPatientForContactState.State__c;
                
                if(String.isBlank(callerId))
                    objContact.Phone = strPhoneInURL;
                    
                if(String.isBlank(objContact.Caller_id__c))
                    objContact.Caller_id__c = strPhoneInURL;
                
                upsert objContact;
                
                objAccount.Name = (!String.isEmpty(objContact.FirstName))?'The Household of '+objContact.FirstName +' '+objContact.LastName :'The Household of '+objContact.LastName; 
                    
                objAccount.ShippingStreet = objContact.MailingStreet;
                objAccount.ShippingCity = objContact.MailingCity;
                objAccount.ShippingState = objContact.MailingState;
                objAccount.ShippingPostalCode = objContact.MailingPostalCode;
                
                upsert objAccount;        
            }
            
            //To create a Patient Record
            if(objCase.Type == 'Referral') {
                
                if(String.isNotBlank(objPatient.Last_Name__c) && String.isEmpty(patientId)) {
                    
                    if(objPatient.First_Name__c == null){
                        objPatient.First_Name__c = '';
                      }
                    if(objContact.FirstName == null){
                        objContact.FirstName = '';    
                      }
                    if(isNewContact && (objContact.FirstName != objPatient.First_Name__c || objContact.LastName != objPatient.Last_Name__c || 
                                        objContact.phone != objPatient.Phone__c || objContact.Email != objPatient.E_mail__c)) {
                        
                        Contact objPatientContact = new Contact(FirstName = objPatient.First_Name__c, 
                                                                LastName = objPatient.Last_Name__c, 
                                                                AccountId = accountId, 
                                                                RecordTypeId = contactRTIndividual, 
                                                                phone = objPatient.Phone__c, 
                                                                Email = objPatient.E_mail__c);
                        insert objPatientContact;
                        
                        objPatient.Contact__c = objPatientContact.Id;
                        objPatient.Parent_Contact__c = objContact.Id;
                    }
                    else  {
                        
                        objPatient.Contact__c = contactId;
                    } 
                    
                    // insert or update depending on 'New' button hit or 'Edit' button
                    try{
                      upsert objPatient; 
                      }
                    catch(Exception E){
                      system.debug('Warning: No previous patient record Present, creating new one.');
                      Patient_New__c pt = new Patient_New__c(Last_Name__c = objPatient.Last_Name__c,
                                           First_Name__c = objPatient.First_Name__c,
                                           Middle_Initial__c = objPatient.Middle_Initial__c,
                                           Suffix__c = objPatient.Suffix__c,
                                           Date_of_Birth__c = objPatient.Date_of_Birth__c,
                                           Age__c = objPatient.Age__c,
                                           Sex__c = objPatient.Sex__c,
                                           E_mail__c = objPatient.E_mail__c,
                                           City__c = objPatient.City__c,
                                           State__c = objPatient.State__c,
                                           Contact__c = objContact.Id,
                                           Phone__c = objPatient.Phone__c,
                                           Postal_Code__c = objPatient.Postal_Code__c,
                                           Street__c = objPatient.Street__c,
                                           Status__c = objPatient.Status__c,
                                           Status_Detail__c = objPatient.Status_Detail__c
                                           );
                      insert pt;
                      objCase.Patient_New__c = pt.ID;                     
                      }  
                      
                    patientId = objPatient.Id;
                }
                
                if(String.isNotEmpty(patientId))
                    objCase.Patient_New__c = patientId;
                    
                objCase.RecordTypeId = caseRtReferral;
            }
            
            objCase.ContactId = contactId;
            objCase.Web_State__c = objPatientForWebState.State__c;
            objCase.Level_Of_Care__c = objAccount.Type;
            upsert objCase;
            
            LiveChatTranscript objLiveChatTranscript = new LiveChatTranscript();
            
            if( ApexPages.currentPage().getParameters().containsKey('transcriptId') ) {
                
                
                List<LiveChatTranscript> lstLiveChatTranscript = [select id, caseId,New_Case_Id__c from LiveChatTranscript where id =: strLiveAgentTranscriptId];
                                
                if(!lstLiveChatTranscript.isEmpty()){
                    objLiveChatTranscript = lstLiveChatTranscript[0];
                    objLiveChatTranscript.New_Case_Id__c = objCase.Id;
                    update objLiveChatTranscript;
                }
            }
             
            
            caseId = objCase.Id;
            
            //Create Assessment Record after case and patient record has been created
            if(objCase.Type == 'Referral' && String.isNotEmpty(patientId)) {
                
                if(!isEdit)
                    objAssessment.Status__c = 'Draft'; //Default value of Assessment should be pending
                  
                if(String.isBlank(objAssessment.Patient__c))
                    objAssessment.Patient__c =  patientId;
                
                upsert objAssessment;
                
                objCase.Assessment__c = objAssessment.Id;
                update objCase;
                
                if(String.isNotEmpty(attachmentId)) {
                    
                    Attachment objAttachment  = [Select Body,ContentType, Name,BodyLength from Attachment where Id =: attachmentId limit 1];
                    Attachment objAttachmentToInsert = new Attachment( ParentId = objAssessment.Id, Body = objAttachment.Body, Name = objAttachment.Name);
                    insert objAttachmentToInsert;
                }
                
                List<Case> lstDummyCase = new List<Case>();
                lstDummyCase = [Select Id from Case where Subject =:'Test$$$Patient$$$$$'+UserInfo.getName()];
                
                if(!lstDummyCase.isEmpty())
                    delete lstDummyCase;
            }
            
            return caseId;
        }
        catch(Exception ex){
            
            system.debug(':::Exception:::'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            Database.rollback(sp);
            
            objAccount.Id = null;
            objContact.Id = null;
            objPatient.Id = null;
            objCase.Id = null;
            objAssessment.Id = null;
            
            return null;
        }
    }
    
    /*
    init method for initilizating the class variables
    */
    private void init() {
        try{
        List<Google_API_Key__c> lstGoogleAPI = Google_API_Key__c.getall().values();
        
        for(Google_API_Key__c objGoogleAPI : lstGoogleAPI){
            
            if(objGoogleAPI.Name == 'GoogleAPIKey')
                strGoogleAPIKey = objGoogleAPI.Value__c;
        }
        
        strLiveAgentTranscriptId =  System.currentPageReference().getParameters().containsKey('transcriptId') ? 
                                        System.currentPageReference().getParameters().get('transcriptId') : '';
        objPatient = new Patient_NEW__c();
        objPatientForContactState = new Patient_NEW__c();
        objPatientForWebState = new Patient_NEW__c();
        objAssessment = new Assessment__c();
        lstKAV = new List<Contact_Center__kav>(); 
        //lstContact = new List<Contact>();
        
        isEdit = false;
        isWebToCase = false;
        caseId = '';
        
        maxSize = 1;
        Integer countForEachIteration = TBN_CaseEntry.COUNT_INFINITE_SCROLL - 1;
        String qryString = 'SELECT Id, title, Summary, How_To_Resolve__c FROM '+
                            'Contact_Center__kav WHERE (PublishStatus = \'online\' and Language = \'en_US\') ORDER By title limit '+ 
                            countForEachIteration +' offset 0';
                            
        lstKAV = Database.query(qryString);
        maxSize = lstKAV.size() ;
        
        contactId = '';
        strphoneType = 'Phone';
        lstRTCase = [Select SobjectType, Name, DeveloperName From RecordType where DeveloperName IN ('General_Inquiry', 'Individual', 'Household','Center','Referring_Contact', 'Referral')];
        
        contactRTIndividual = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Contact' AND DeveloperName = 'Individual'].Id;
        accountRtHousehold = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Account' AND DeveloperName = 'Household'].Id;
        caseRtReferral = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Case' AND DeveloperName = 'Referral'].Id;
        caseRtGeneral = [Select SobjectType, Name, DeveloperName From RecordType where SobjectType = 'Case' AND DeveloperName = 'General_Inquiry'].Id;
        
        objCase = new Case(RecordTypeId = caseRtGeneral);
        objAccount = new Account(RecordTypeId = accountRtHousehold);
        objContact = new Contact(RecordTypeId = contactRTIndividual);
        
        strRefererURL = ApexPages.currentPage().getParameters().get('retURL');
        
        // method to handle edit case
         if( apexpages.currentPage().getParameters().containsKey('id') && 
                String.isNotBlank( (String)apexpages.currentPage().getParameters().get('id') ) ) {
               
               caseId = (String)apexpages.currentPage().getParameters().get('id');
               isEdit = true;
               onEditOfCase(caseId);     
         }
         else
            isEdit = false;
        // fetch the related contact to display on page
        if(apexpages.currentPage().getParameters().containsKey('phone') && 
                String.isNotBlank((String)apexpages.currentPage().getParameters().get('phone'))) {
            
            strPhoneInURL = (String)apexpages.currentPage().getParameters().get('phone');
            //if 'noskill' or 'restricted' value passed in the URL then the new case entry page has to be opened without querying contacts.
            if(String.isNotBlank(strPhoneInURL) && 
                    !(strPhoneInURL.toLowerCase() == 'restricted' || strPhoneInURL.toLowerCase() == 'noskill')) {
                
                List<List<SObject>> searchList = [  FIND :strPhoneInURL IN PHONE FIELDS 
                                                    Returning Contact(Id, Phone, Email, FirstName, LastName, MailingState, MailingStreet, Caller_id__c, 
                                                                        MailingCity, MailingPostalCode, HomePhone, MobilePhone, OtherPhone
                                                                        Where RecordTypeId = :CONTACT_RT_INDIVIDUAL
                                                                        Order By LastModifiedDate desc
                                                                        LIMIT 1)];
    
                List<Contact> lstContacts= (List<Contact>) searchList[0];
                
                if(!lstContacts.isEmpty()) {
                    
                    objContact = lstContacts[0];
                    contactId = objContact.Id;     
                    
                    if(String.isBlank(objContact.Phone))  {    
                        
                        objContact.Phone = strPhoneInURL;
                        objContact.Caller_id__c = strPhoneInURL;
                    }
                    
                    objPatientForContactState.State__c = objContact.MailingState;
                    
                    if(!isEdit)
                        objCase = new Case(RecordTypeId = caseRtGeneral, ContactId = objContact.Id );
                }
                else{
                    objContact = new Contact(Phone = strPhoneInURL, Caller_id__c = strPhoneInURL, RecordTypeId = contactRTIndividual);
                }
            }
            else {
                    
                objContact = new Contact(Phone = strPhoneInURL, Caller_id__c = strPhoneInURL, RecordTypeId = contactRTIndividual);
            }
            
            if(apexpages.currentPage().getParameters().containsKey('caseOrigin') && 
                    String.isNotBlank((String)apexpages.currentPage().getParameters().get('caseOrigin')) &&
                    !(apexpages.currentPage().getParameters().containsKey('id') && 
                        String.isNotBlank((String)apexpages.currentPage().getParameters().get('id')))) {
                    
                string strCaseOrg = (String)apexpages.currentPage().getParameters().get('caseOrigin');
                List<Case_Origin_for_IVR__c> lstCaseOrigin = new list<Case_Origin_for_IVR__c>();
                
                for(Case_Origin_for_IVR__c objCaseOrigin : [ Select Id, Name, Case_Origin__c From Case_Origin_for_IVR__c where Case_Origin_Code__c =: strCaseOrg ]) {
                    
                    objCase.Origin = objCaseOrigin.Case_Origin__c;
                }
            }
           // objCase.Origin = 'Tele - Test'; 
        }
        
        //If the transcript id is passed in the URL, contact should be queried based on the transcript's contact value.
        if(apexpages.currentPage().getParameters().containsKey('transcriptId') && 
                    String.isNotBlank(System.currentPageReference().getParameters().get('transcriptId')) && 
            !(apexpages.currentPage().getParameters().containsKey('id') || 
                    String.isNotBlank( (String)apexpages.currentPage().getParameters().get('id'))) ) {
            list<LiveChatTranscript> lstLiveChatTranscript = [  select id, Email__c, Phone__c, First_Name__c, Last_Name__c, Zip_Code__c, Description__c, 
                                                                        What_would_you_like_to_discuss_today__c,  Street_Address__c, City__c, State__c  
                                                                from LiveChatTranscript
                                                                where id =: strLiveAgentTranscriptId];
            
            LiveChatTranscript objLiveChat = new LiveChatTranscript();
            

            if(!lstLiveChatTranscript.isEmpty())
               objLiveChat = lstLiveChatTranscript[0];
            
            string strPhone = objLiveChat.Phone__c;
            
                objPatientForContactState.State__c = objLiveChat.State__c;
                objContact = new Contact(Phone = strPhone, Caller_id__c = strPhone, RecordTypeId = contactRTIndividual, 
                                        FirstName = objLiveChat.First_Name__c, LastName = objLiveChat.Last_Name__c, Email = objLiveChat.Email__c, MailingPostalCode = objLiveChat.Zip_Code__c,
                                        MailingStreet = objLiveChat.Street_Address__c, MailingCity = objLiveChat.City__c
                                        );
                                     
           
            objCase = new Case(RecordTypeId = caseRtGeneral, ContactId = objContact.Id, Description = objLiveChat.Description__c, What_would_you_like_to_discuss_today__c = objLiveChat.What_would_you_like_to_discuss_today__c, Origin = 'Live Chat');
                                            
        }
        // If no referer is returned, make sure that the page is redirected to Case list view
        if(strRefererURL == null) {
            strRefererURL = '/500/o';
        }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber()));
            }
            
    }
    
    /* method called on case Edit*/
    private void onEditOfCase(String caseId) {
         
        String strQuery = '';
        String strContactId = '';
         
        // form a query string to query case
        strQuery = 'SELECT Description, Case_Source__c, Subtype__c, Origin, Type, Subject, ContactId, Assessment__c, Patient_New__c, AccountId, Level_Of_Care__c, Web_First_Name__c, Web_Last_Name__c, Web_Street_Address__c, Web_State__c, Web_City__c, Web_Zip_Code__c, SuppliedPhone, SuppliedEmail';
        
        // get fields from fieldset
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Case');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('TBN_WebToCaseFields');
        
        // attach fields from field set to query string
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields() ){
        
            strQuery+=', ';
            strQuery+=fieldSetMemberObj.getFieldPath();   
        }
        
        strQuery += ' FROM Case WHERE ID =: caseId LIMIT 1';
        
        //query case to display it's field values on page
        List<sObject> sobjList = Database.query(strQuery);
        objCase = (Case)sobjList[0];
        
        if(objCase.Origin == 'Web')
            isWebToCase = true;
        
        // assign web state value of Case to patient state picklist field to display in vf page
        objPatientForWebState.State__c = objCase.Web_State__c!=null?objCase.Web_State__c:'--None--';
        
        strContactId = objCase.ContactId;
        
        // fetch the related contact to display on page on Edit
        if(String.isNotBlank(strContactId)) {
            
            objContact = [ SELECT Phone, Email, FirstName, LastName, MailingState, MailingStreet, MailingCity, MailingPostalCode, Caller_id__c
                           FROM Contact
                           WHERE Id =: strContactId
                           LIMIT 1];

            contactId = objContact.Id;           
            objPatientForContactState.State__c = objContact.MailingState;
        }
        
        objAccount.Type = objCase.Level_Of_Care__c;
        
        if(objCase.Type == 'Referral') {
            
            if(objCase.Patient_New__c != null) {
                
                objPatient = [ SELECT Suffix__c, Street__c, State__c, Sex__c, Postal_Code__c, Phone__c, Name, Middle_Initial__c, Last_Name__c, First_Name__c, E_mail__c, Date_of_Birth__c, City__c, Age__c, Status__c, Status_Detail__c, Next_Call_Date__c, Lead_Lost_Date__c  
                               FROM Patient_NEW__c 
                               WHERE Id =: objCase.Patient_New__c
                               LIMIT 1];
            }
            
            if(objCase.Assessment__c != null) {
                
                 objAssessment = [ SELECT Referral_Notes__c, Preferred_Facility__c, Patient__c
                                  FROM Assessment__c 
                                  WHERE Id =: objCase.Assessment__c
                                  LIMIT 1];
            }
        }                            
    }
    
    /*
    Wrapper class for Knowledge Article used in infinite scroll
    */
    global class InfiniteScrollResponse {
        
        public Boolean hasMore;
        public List<SObject> records;
        public InfiniteScrollResponse(List<SObject> records, Boolean isTrue) {
            this.records = records;
            this.hasMore = isTrue;
        }
    }
}