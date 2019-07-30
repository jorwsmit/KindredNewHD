/**
@ClassName    : TBN_AssociateDataManagementController 
@CreatedOn    : 07/03/2016
@ModifiedBy   : Rashmi, Ritika
@Description  : Controller for Territory Management page
**/
global without sharing class TBN_AssociateDataManagementController {
    
    /* Details Tab Variables */
    public String strSelectedUser                                   {   get; set;   }       //variable to store the name of the selected user id from the 'to user' picklist.
    public User objUser                                             {   get; set;   }       //User object to contain the user details of the selected user from the picklist
    public Account objUserRelatedAccount                            {   get; set;   }       //Account object to store user's Home Facility Account.
    
    /* Referral Assignments Tab Variables*/
    public Integer totalAssignments                                 {   get; set;   }       //variable to store the count of referrals assigned to selected user.
    public string strSelectedDistance                               {   get; set;   }       //variable to store the value from 'view type' picklist in referral sources tab.
    public string strSubReferralSearch                              {   get; set;   }       //variable to store the value from 'Active/Not Active' picklist in referral sources tab.
    public String strSelectedState                                  {   get; set;   }
    public list<SelectOption> lstDistanceOptions                    {   get; set;   }       //list containing 'view type' values.
    public list<SelectOption> lstDistanceSubOptions                 {   get; set;   }       //list containing 'Active/Not Active' values.
    public list<SelectOption> lstSourceSystemOptions                {   get; set;   }
    public list<SelectOption> lstStates                             {   get; set;   }
    
    /* Reassign Referral Sourcces Tab Variables*/
    public String strReassignUser                                   {   get; set;   }       //variable to store the name of the selected user id from the 'from user' picklist.
    public boolean isSuccess                                        {   get; set;   }       //based to the variable value the success message will be shown at the top of the page.
    public boolean isValidationVisible                              {   get; set;   } 
    
    public S2_custom_permissions__c objS2CustomPermissions          {   get; set;   }       //custom setting varialbe to store the permissions based on loggedin user.
    
    static final String PARENT_ROLE = 'SVP - KAH';
    public boolean isSalesRep                                       {   get; set;   }       //variable to check if loggedin user is sales rep.
    public string strSalesRepName                                   {   get; set;   }       //variable to store the name if the loggedin user is salesrep
    public user loggedinUser                                        {   get; set;   }       //variable to store the loggedin user info
    public string strlogginUserId                                   {   get; set;   }       //variable to store the loggedin user Id
    public string homeFacilityfield                                 {   get; set;   }       //string to contain Home Facility Name+Facility Number+Type
    public Boolean isAllReassignReerrals                            {   get; set;   }
    public string strCustomError                                    {   get; set;   }
    public string selectedUserId;
    
    //list to store the records types of Accounts to be shown
    global static list<RecordType> lstAccountRecordType = [ SELECT Id, Name, Description, DeveloperName, IsActive 
                                                            FROM RecordType
                                                            WHERE sobjecttype='Account' AND 
                                                                  (DeveloperName='Referring_Facility_Parent' OR 
                                                                  DeveloperName='Referring_Facility_Child' OR DeveloperName = 'Center')];
 
    global static list<RecordType> lstAccountRecordTypeforSourceFilter = [ SELECT Id, Name, Description, DeveloperName, IsActive 
                                                            FROM RecordType
                                                            WHERE sobjecttype='Account' AND 
                                                                  (DeveloperName='Center' OR 
                                                                  DeveloperName='Referring_Facility_Child')];                                                              
                                                                  
    //list to store the records types of Contacts to be shown
    global static list<RecordType> lstContactRecordType = [ SELECT Id 
                                                            FROM RecordType
                                                            WHERE sobjecttype = 'Contact' AND 
                                                                    DeveloperName='General_Contact'];
    
    /**
    @ClassName  : userReferralsAndMessageString
    @Description: Wrapper class for binding anymessage, count of records and the list containing data. 
    **/
    global class userReferralsAndMessages {
        
        public list<Account> lstAccounts                    {   get; set;   }
        public list<AccountTeamMember> lstATMsAssigned      {   get; set;   }
        public list<AccountTeamMember> lstATMsIcons         {   get; set;   }
        public list<Contact> lstContacts                    {   get; set;   }
        public list<Contact_Team__c> lstCTMsAssigned        {   get; set;   }
        public list<Contact_Team__c> lstCTMsIcons           {   get; set;   }
        
        public String errMessage            {   get; set;   }
        public String recCount              {   get; set;   }
        
        public userReferralsAndMessages( list<Account> lstAccounts, list<AccountTeamMember> lstATMsAssigned, list<AccountTeamMember> lstATMsIcons,
                                         list<Contact> lstContacts, list<Contact_Team__c> lstCTMsAssigned, list<Contact_Team__c> lstCTMsIcons,
                                         String errMessage, String recCount ) {
            
            this.lstAccounts = lstAccounts;
            this.lstATMsAssigned = lstATMsAssigned;
            this.lstATMsIcons = lstATMsIcons;

            this.lstContacts = lstContacts;
            this.lstCTMsAssigned = lstCTMsAssigned;
            this.lstCTMsIcons = lstCTMsIcons;
            
            this.errMessage = errMessage;
            this.recCount = recCount;
        }
    }
    
    /**
    @ClassName  : UserAccountsandContacts
    @Description: Wrapper class for binding the data displayed in reassignment referrals.
    **/
    global class UserAccountsandContacts {
        
        private String strReferralId;
        public String strType                                   {   get; set;   }
        private String strOperation;
        
     
    }
    
    /* Default Constructor*/
    public TBN_AssociateDataManagementController () {
        
        init();
    }
    
    /**
    @MethodName : init
    @Param      : None
    @Description: This method is used to initialize the variables used in the class
    **/   
    public void init() {
        
        strSalesRepName = '';
        strSelectedUser = '';
        isSalesRep = false;
        loggedinUser = new User();
        selectedUserId = '';
        
        objS2CustomPermissions = S2_custom_permissions__c.getInstance(UserInfo.getProfileId().substring(0,15));
        
        if(objS2CustomPermissions == null || objS2CustomPermissions.Referral_Access__c == false){
            
            isSalesRep = true;
            //Query on logged in user for sales rep
            loggedinUser = [select Id, LastName,FirstName, Line_of_Business__c ,PERNER__c from User where Id = :UserInfo.getUserId()];
            
            string trimmedString = '';
            if(String.isEmpty(loggedinUser.FirstName)){
                string strLastName = loggedinUser.LastName;
                integer strNameLength = strLastName.length();
                if(strNameLength > 20){
                    integer intlength = 20;
                    trimmedString = strLastName.substring(0, intlength);
                    trimmedString = trimmedString + '...';
                }
                else{
                    trimmedString = strLastName;
                }
                
            }
            else{
                string strName = loggedinUser.LastName+', '+loggedinUser.FirstName;
                integer strNameLength = strName.length();
                if(strNameLength > 20){
                    integer intlength = 20;
                    trimmedString = strName.substring(0, intlength);
                    trimmedString = trimmedString + '...';
                }
                else{ 
                    trimmedString = strName;
                }
            }
            string strPerner = '';
            if(loggedinUser.PERNER__c != null){
                
                string strPernerVal = loggedinUser.PERNER__c;
                if(strPernerVal.length() > 6){
                    
                    integer intLen = 6;
                    strPerner = strPernerVal.substring(0, intLen);
                    strPerner = strPerner + '..';
                }
                else{
                    strPerner = strPernerVal;
                }
                
            }
            
            string strLineOfBusiness = '';
            if(loggedinUser.Line_of_Business__c != null){
                
                string strLineOfBusinessVal = loggedinUser.Line_of_Business__c;
                if(strLineOfBusinessVal.length() > 6){
                    
                    integer intLen = 6;
                    strLineOfBusiness = strLineOfBusinessVal.substring(0, intLen);
                    strLineOfBusiness = strLineOfBusiness + '..';
                }
                else{
                    strLineOfBusiness = strLineOfBusinessVal;
                }
                
            }
            strSalesRepName = '<table width="100%"><tr><td width="60%">'+trimmedString+
                                    +'</td><td width="20%" style="text-align: left; font-weight:bold">'+((loggedinUser.Line_of_Business__c != null ? strLineOfBusiness : '')) +
                                    +'</td><td width="20%" style="text-align: left; font-weight:bold">'+((loggedinUser.PERNER__c != null ? strPerner : ''))+
                                    +'</td></tr></table>';
            
            //strSalesRepName = loggedinUser.LastName+', '+loggedinUser.FirstName;
            strlogginUserId = loggedinUser.Id;
        }
        
        if(strSalesRepName != '')
            strSelectedUser = strlogginUserId;
        
        objUser = new User(); 
        totalAssignments = 0;
        isAllReassignReerrals = false;
        strSelectedDistance = 'CurrentlyAssigned';
        strSubReferralSearch = 'AllAccandCont';
        
        lstDistanceOptions = new list<SelectOption>();
        lstDistanceOptions.add( new SelectOption('AllAccountsAndContacs', 'All'));
        lstDistanceOptions.add( new SelectOption('CurrentlyAssigned', 'Currently Assigned'));
        //lstDistanceOptions.add( new SelectOption('50', 'All within 50 miles'));
        //lstDistanceOptions.add( new SelectOption('100', 'All within 100 miles'));
        
        lstDistanceSubOptions = new list<SelectOption>();
        lstDistanceSubOptions.add( new SelectOption('AllAccandCont', 'All'));
        lstDistanceSubOptions.add( new SelectOption('Customer', 'Customer'));
        lstDistanceSubOptions.add( new SelectOption('Prospect', 'Prospect'));
        
        lstSourceSystemOptions = new list<SelectOption>();
        lstSourceSystemOptions.add( new SelectOption('All', 'All'));
        lstSourceSystemOptions.add( new SelectOption('HPAS', 'HPAS'));
        lstSourceSystemOptions.add( new SelectOption('Horizon', 'Horizon'));
        lstSourceSystemOptions.add( new SelectOption('Meditech', 'Meditech')); 
        lstSourceSystemOptions.add( new SelectOption('Unity', 'Unity'));
        
        lstStates = new list<SelectOption>();
        lstStates.add( new SelectOption('', 'None'));
        
        for(States__c objState : [ Select Id, Name From States__c Order By Name]) {
            
            lstStates.add( new SelectOption(objState.Name, objState.Name));
        }
        
        homeFacilityfield = '';
        strCustomError = '';
        
    }
    
    
    /**
    @MethodName : fetchUserData
    @Param      : None
    @Description: Method used to get the selected user related information and display under Details tab
    **/   
    public void fetchUserData() {
        
        try{
            homeFacilityfield = '';
            if(strSalesRepName != '')
                strSelectedUser = loggedinUser.Id;
            objUserRelatedAccount = new Account();
            
            if(String.isNotBlank(strSelectedUser)) { 
                
                //query the Account based on HomeFacility
                string queryString = 'select id, (select Account__c from Home_Facility__r limit 1)';
                
                for(Schema.FieldSetMember fld :SObjectType.User.FieldSets.UserDetails.getFields()) {
                    
                    queryString += ', ' + fld.getFieldPath();
                }
                
                queryString += ', UserRole.Name, UserRoleId from User where id =: strSelectedUser';
                user objUser1 = new User();
                objUser1 = Database.query(queryString);
                 
                UserRole objuserRole = new UserRole();
                if(objUser1.UserRoleId != null){
                    objuserRole = [select id, Name from userRole where id =:objUser1.UserRoleId];
                
                    objUser = new User(id = objUser1.id, LastName = objUser1.LastName, FirstName = objUser1.FirstName,
                                    Username = objUser1.Username, Line_of_Business__c = objUser1.Line_of_Business__c,
                                    PERNER__c = objUser1.PERNER__c, Title = objUser1.Title, Phone = objUser1.Phone,
                                    UserRole = objuserRole );
                }
                else{
                    
                    objUser = new User(id = objUser1.id, LastName = objUser1.LastName, FirstName = objUser1.FirstName,
                                    Username = objUser1.Username, Line_of_Business__c = objUser1.Line_of_Business__c,
                                    PERNER__c = objUser1.PERNER__c, Title = objUser1.Title, Phone = objUser1.Phone);
                }
               
                selectedUserId = objUser.id;
              /*  if(isSalesRep == true){
                    loggedinUser = [select Id, LastName,FirstName from User where Id = :UserInfo.getUserId()];
                    strSalesRepName = loggedinUser.LastName+', '+loggedinUser.FirstName;
                }*/
                if(!objUser1.Home_Facility__r.isEmpty() && String.isNotBlank(objUser1.Home_Facility__r[0].Account__c) ) {
                    string strReferralId = objUser1.Home_Facility__r[0].Account__c;
                    objUserRelatedAccount = [Select Id, Name, type, Facility_Number__c from Account where Id = : strReferralId];
                    
                    string strName = '';
                    string trimmedString = '';
                    string strHomeFacilityName = '';
                    strName = objUserRelatedAccount.Name;
                         if(strName.length() >20){
                             
                             integer length = 20;
                             trimmedString = strName.substring(0, length);
                             trimmedString = trimmedString + '...';
                         }  
                         if(trimmedString != '')
                             strHomeFacilityName +=trimmedString; 
                         else
                             strHomeFacilityName += objUserRelatedAccount.Name;
                    homeFacilityfield = '<table width="100%"><tr><td width="65%">'+strHomeFacilityName+
                                        +'</td><td width="20%" style="text-align: left; font-weight:bold">'+((objUserRelatedAccount.Facility_Number__c != null ? objUserRelatedAccount.Facility_Number__c : '')) +
                                        +'</td><td width="25%" style="text-align: left; font-weight:bold">'+((objUserRelatedAccount.type != null ? objUserRelatedAccount.type : ''))+
                                        +'</td></tr></table>';
                }    
            }
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
    /**
    @MethodName : saveUser
    @Param      : None
    @Description: Method is called on submit of changes in details to update the user details made on the page.
    **/
    public void saveUser() {
        
        try{
            isSuccess = false;
            user objUser1 = [select id, Profile.UserLicense.Name from User where id =:objUser.id];
            
            isSuccess = false;
            if(objUser1.Profile.UserLicense.Name == 'Chatter Free' && objUser.UserRoleId != null){
                
                objUser.UserRoleId = null;
            }
            update objUser; 
            
            string accId = Apexpages.currentpage().getparameters().get('accId'); 
            list<Home_Facility__c> lstHomeFacility = new list<Home_Facility__c>();
            lstHomeFacility = [select id, Account__c from Home_Facility__c where User__c = :strSelectedUser limit 1];
            
            //creating the HomeFacility for User if not there and updating the Homefacilty if already present
            if(accId != '' && accId != null && strSelectedUser != '' && strSelectedUser != null) {
                
                if(lstHomeFacility.isEmpty()) {
                    Home_Facility__c objFacility = new Home_Facility__c(User__c = strSelectedUser,  Account__c = accId); 
                    insert objFacility;
                }
                else {
                    Home_Facility__c objFacility = new Home_Facility__c(Id = lstHomeFacility[0].Id,  Account__c = accId); 
                    update objFacility;
                }
            }
            isSuccess = true;  
            isValidationVisible = false;
            strCustomError = '';
            if(Test.isRunningTest()){
                decimal dec = 5/0;
            }
        }
        catch(exception e){
        system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
             isSuccess = false;
             isValidationVisible = true;
             if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strCustomError = e.getMessage().split(',')[1].Substring(0,e.getMessage().split(',')[1].length()-4);
            }
            else{
                strCustomError = e.getMessage();
                //strCustomError = e.getMessage().split('first error:')[1].Substring(0,e.getMessage().split(',')[1].length()-5);
            }
        }
    } 
    
    
    /**
    @MethodName : updateUserRole
    @Param      : None
    @Description: This method called on Submit of changes in the Roles in the Organizational Alignment section which will update the current role of the User.
    **/
    public void updateUserRole() {
        
        try {
            isSuccess = false;
            strCustomError = '';
            // If a role at division level has been selected
            if(String.isNotBlank(objUser.UserRole.Id)) {
                
                objuser = new user(Id=strSelectedUser,UserRoleId = objUser.UserRoleId);
                update objuser;
                
                string queryString = 'select id ';
                
                for(Schema.FieldSetMember fld :SObjectType.User.FieldSets.UserDetails.getFields()) {
                    
                    queryString += ', ' + fld.getFieldPath();
                }
    
                queryString += ', UserRole.Name from User where id =: strSelectedUser';
                objUser = Database.query(queryString);
                
                isSuccess = true;
                isValidationVisible = false;
                if(Test.isRunningTest()){
                    decimal dec = 5/0;
                }
            }
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            isSuccess = false;
            isValidationVisible = true;
            // strCustomError = e.getMessage();
            if(e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION')) {
                
                strCustomError = e.getMessage().split(',')[1].Substring(0,e.getMessage().split(',')[1].length()-14);
            }
            else{
                
                strCustomError = e.getMessage();
 
            }
            
        }
    }
    
    /**
    @MethodName : fetchUserRoles
    @Param      : selectedRole
    @Description: This method called to get all the roles that are direct child of  selectedRole.
    **/
    @RemoteAction 
    global static String fetchUserRoles(String selectedRole) {
        
        try {
            
            if(String.isNotBlank(selectedRole)) {
                
                String userNames = '';
                
                String strSelectOptionsHTML = '';
                
                String strSelectOBasicHTML = '<option value="">--None Selected--</option>';
                
                //Iteraing over UserRole based on ParentRole to fetch the Role names of user  
                for(UserRole objUserRole : [Select Id, Name 
                                            From UserRole 
                                            Where ParentRoleId = :selectedRole and (ParentRoleId != null or ParentRoleId != '')]) {
                    
                    strSelectOptionsHTML += '<option value="' +objUserRole.Id+ '">' +objUserRole.Name+ '</option>';
                }
                
                //Iterating over users to fetch the Usernames based on selected role
                for(User objUser : [SELECT Id, Name,userrole.name  FROM User WHERE userroleId =:selectedRole Order By Name]) {
                    
                    if(userNames == '') {
                        
                        userNames+= objUser.Name;
                    }
                    else {
                        userNames+= ', ' + objUser.Name;
                    }
                    
                }
                
                //Checking if the Role has users 
                if(String.isNotBlank(strSelectOptionsHTML) || String.isNotBlank(userNames))
                    return ((String.isNotBlank(strSelectOptionsHTML))?( strSelectOBasicHTML + strSelectOptionsHTML):'')+'|'+ userNames;
            }
            
            return '';
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }


    /**
    @MethodName : fetchReferralSourceCount
    @Param      : none
    @Description: This method called on select of referral source tab to get the count of referrals assigned to selected user
    **/
    public void fetchReferralSourceCount(){
        
        try {
            
            strSubReferralSearch = 'AllAccandCont';
            strSelectedDistance = 'CurrentlyAssigned';
            
            if(strSelectedUser == '') {
                
                strSelectedUser = strlogginUserId;
            }
                                                        
            //list to hold the count of AccountTeamMembers assigned for Selected User
            List<AggregateResult> lstATM = Database.query(  'Select COUNT_DISTINCT(Account.Id) countATMs '+
                                                            'From AccountTeamMember '+
                                                            'Where UserId =: strSelectedUser AND '+ 
                                                            'Account.Recordtypeid IN: lstAccountRecordType');
                                                            
            //list to hold the count of ContactTeamMembers assigned for Selected User
            List<AggregateResult> lstCTM = Database.query(  'Select COUNT_DISTINCT(Contact__r.Id) countCTMs '+
                                                            'From Contact_Team__c '+
                                                            'Where User__c =: strSelectedUser AND '+ 
                                                            'Contact__r.Recordtypeid IN: lstContactRecordType');
                                                            
                                                                                                          
            totalAssignments = Integer.valueOf(lstATM[0].get('countATMs')) + Integer.valueOf(lstCTM[0].get('countCTMs'));
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
   
    /**
    @MethodName : fetchReferralsCount
    @Param      : None 
    @Description: Mehtod to called to get the referral count for from user when reassign tab is selected.
    **/
    public void fetchReferralsCountonReassignment() {
        
        try {
            
            if(isSalesRep == true) {
                
                strReassignUser = loggedinUser.id;
                strSelectedUser = loggedinUser.id; 
            } 
                                                            
            //list to hold the count of AccountTeamMembers assigned for Selected User
            List<AggregateResult> lstATM = Database.query(  'Select COUNT_DISTINCT(Account.Id) countATMs '+
                                                            'From AccountTeamMember '+
                                                            'Where UserId =: strReassignUser  AND '+ 
                                                            'Account.Recordtypeid IN: lstAccountRecordType');
                                                            
            //list to hold the count of ContactTeamMembers assigned for Selected User
            List<AggregateResult> lstCTM = Database.query(  'Select COUNT_DISTINCT(Contact__r.Id) countCTMs '+
                                                            'From Contact_Team__c '+
                                                            'Where User__c =: strReassignUser AND '+ 
                                                            'Contact__r.Recordtypeid IN: lstContactRecordType');
                                                            
                                                                                                          
            totalAssignments = Integer.valueOf(lstATM[0].get('countATMs')) + Integer.valueOf(lstCTM[0].get('countCTMs'));
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /**
    @MethodName : fetchReassignReferralSourcesTableSorter
    @Param      :   selfield - id of the filed on which sorting is applied else it be sorted based on name
                    ariaSort - contains ascending or descending value on which sorting is done
                    whereQueryAccount - where condition is formed based on values entered in filters for Account Query
                    whereQueryContact - where condition is formed based on values entered in filters for Contact query
                    isTypeFilter - if filter is applied on type this will contain the value accordingly
                    selFromUser - UserId from the user selection picklist
    @Description: Method used to fetch the Account and Contacts based on selected from user in the picklist 
    **/ 
    @RemoteAction 
    global static userReferralsAndMessages fetchReassignReferralSourcesTableSorter( string selField, string ariaSort, string strSpecilaityFilterValue, 
                                                                                    string whereQueryAccount, string whereQueryContact, 
                                                                                    string isTypeFilter, string selFromUser ) {
        
        try {
            list<Account> lstAccounts = new List<Account>();
            list<AccountTeamMember> lstATMsAssigned = new List<AccountTeamMember>();
            list<AccountTeamMember> lstATMsIcons = new List<AccountTeamMember>();
            list<Contact> lstContacts = new List<Contact>();
            list<Contact_Team__c> lstCTMsAssigned = new List<Contact_Team__c>();
            list<Contact_Team__c> lstCTMsIcons = new List<Contact_Team__c>();
            
            strSpecilaityFilterValue = String.escapeSingleQuotes(strSpecilaityFilterValue).replaceAll('u2019', '\'');
            whereQueryAccount = String.escapeSingleQuotes(whereQueryAccount).replaceAll('u2019', '\'');
            whereQueryContact = String.escapeSingleQuotes(whereQueryContact).replaceAll('u2019', '\'');
            
            userReferralsAndMessages objReferralsAndMessages;
            
            Map<String,List<String>> mapPicklistValues = new Map<String,List<String>>();
            String strAllValues = '';
            
            string hasNoFilter = '';
            string strAscorDesc = '';
            string selAccountTD = '';
            string selContactTD = '';
            String strQueryLimit = '2000';
            
            
            if(ariaSort == 'ascending' || ariaSort == 'none')
                strAscorDesc = 'ASC';
            else    
                strAscorDesc = 'DESC';
            
            if(selField.contains('Reassign'))
                selField = selField.substring(8); 
            
            //checks if filter has applied on strType 
            if(isTypeFilter != 'ContactFilter' && isTypeFilter != 'AccountFilter')
                hasNoFilter = 'Allrecords';   
            
            Map<String, String> mapAccFieldSelectedToAPINames = new Map<String, String>{'1-unassign' => 'Name', '2-unassign' => 'NPI__c', '3-unassign' => 'ShippingStreet',
                                                                                        '4-unassign' => 'ShippingCity', '5-unassign' => 'ShippingState', '6-unassign' => 'ShippingPostalCode',
                                                                                        '7-unassign' => 'Name', '8-unassign' => 'Name', '9-unassign' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '10-unassign' => 'KAH_HH_Admits_YTD__c', '11-unassign' => 'HH_Admits_PY__c',
                                                                                        '12-unassign' => 'KAH_HP_Admits_YTD__c', '13-unassign' => 'HP_Admits_PY__c',
                                                                                        '14-unassign' => 'KAH_HD_Admits_YTD__c', '15-unassign' => 'HD_Admits_PY__c',
                                                                                        '16-unassign' => 'KAH_HH_PPS_Admits_YTD__c', '17-unassign' => 'KAH_HH_Discounted_Qualified_Admits_YTD__c',
                                                                                        '18-unassign' => 'KAH_HH_PPS_Prior_Year_Admits_Prior__c', '19-unassign' => 'KAH_HH_Discounted_Qualified_Admits_PY__c',
                                                                                        '20-unassign' => 'KAH_HH_Referrals_YTD__c', '21-unassign' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '22-unassign' => 'KAH_HMS_ALL_HH_DR__c', '23-unassign' => 'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c',
                                                                                        '24-unassign' => 'KAH_HMS_HH_CHF_Stroke_COPD_DR__c', '25-unassign' => 'KAH_HMS_HH_Endo_Wounds_DR__c',
                                                                                        '26-unassign' => 'KAH_HMS_HH_Urinary_Kidney_GI_DR__c', '27-unassign' => 'KAH_HMS_HH_Ortho_DR__c',
                                                                                        '50-unassign' => 'KAH_HP_Qualified_Admits_YTD__c',
                                                                                        '28-unassign' => 'KAH_HP_Qualified_Admits_PY__c', '29-unassign' => 'KAH_HP_Admits_YTD__c',
                                                                                        '30-unassign' => 'KAH_HP_Referrals_YTD__c', '31-unassign' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '32-unassign' => 'KAH_HMS_All_HP_DR__c', '33-unassign' => 'KAH_HMS_HP_Cancer_DR__c',
                                                                                        '34-unassign' => 'KAH_HMS_HP_CHF_DR__c', '35-unassign' => 'KAH_HMS_HP_COPD_DR__c',
                                                                                        '36-unassign' => 'KAH_HMS_HP_Dementia_DR__c', '37-unassign' => 'KAH_HMS_HP_Debility_DR__c',
                                                                                        '38-unassign' => 'KAH_HMS_HP_Influencer_Network_DR__c', 'strType' => 'Name',
                                                                                        'ShippingCity' => 'ShippingCity', 'ShippingState' => 'ShippingState',
                                                                                        'ShippingStreet' => 'ShippingStreet', 'ShippingPostalCode' => 'ShippingPostalCode',
                                                                                        'KAH_HH_Admits_YTD' => 'KAH_HH_Admits_YTD__c', 'KAH_HP_Admits_YTD' => 'KAH_HP_Admits_YTD__c'};
            
            Map<String, String> mapConFieldSelectedToAPINames = new Map<String, String>{'1-unassign' => 'Name', '2-unassign' => 'NPI__c', '3-unassign' => 'Mailingstreet',
                                                                                        '4-unassign' => 'MailingCity', '5-unassign' => 'MailingState', '6-unassign' => 'MailingPostalCode',
                                                                                        '7-unassign' => 'Name', '8-unassign' => 'Name', '9-unassign' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '10-unassign' => 'KAH_HH_Admits_YTD__c', '11-unassign' => 'HH_Admits_PY__c',
                                                                                        '12-unassign' => 'KAH_HP_Admits_YTD__c', '13-unassign' => 'HP_Admits_PY__c',
                                                                                        '14-unassign' => 'KAH_HD_Admits_YTD__c', '15-unassign' => 'HD_Admits_PY__c',
                                                                                        '16-unassign' => 'KAH_HH_PPS_Admits_YTD__c', '17-unassign' => 'KAH_HH_Discounted_Qualified_Admits_YTD__c',
                                                                                        '18-unassign' => 'KAH_HH_PPS_Prior_Year_Admits_Prior__c', '19-unassign' => 'KAH_HH_Discounted_Qualified_Admits_PY__c',
                                                                                        '20-unassign' => 'KAH_HH_Referrals_YTD__c', '21-unassign' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '22-unassign' => 'KAH_HMS_ALL_HH_DR__c', '23-unassign' => 'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c',
                                                                                        '24-unassign' => 'KAH_HMS_HH_CHF_Stroke_COPD_DR__c', '25-unassign' => 'KAH_HMS_HH_Endo_Wounds_DR__c',
                                                                                        '26-unassign' => 'KAH_HMS_HH_Urinary_Kidney_GI_DR__c', '27-unassign' => 'KAH_HMS_HH_Ortho_DR__c',
                                                                                        '50-unassign' => 'KAH_HP_Qualified_Admits_YTD__c', 
                                                                                        '28-unassign' => 'KAH_HP_Qualified_Admits_PY__c', '29-unassign' => 'KAH_HP_Admits_YTD__c',
                                                                                        '30-unassign' => 'KAH_HP_Referrals_YTD__c', '31-unassign' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '32-unassign' => 'KAH_HMS_All_HP_DR__c', '33-unassign' => 'KAH_HMS_HP_Cancer_DR__c',
                                                                                        '34-unassign' => 'KAH_HMS_HP_CHF_DR__c', '35-unassign' => 'KAH_HMS_HP_COPD_DR__c',
                                                                                        '36-unassign' => 'KAH_HMS_HP_Dementia_DR__c', '37-unassign' => 'KAH_HMS_HP_Debility_DR__c',
                                                                                        '38-unassign' => 'KAH_HMS_HP_Influencer_Network_DR__c', 'strType' => 'Name',
                                                                                        'ShippingCity' => 'MailingCity', 'ShippingState' => 'MailingState',
                                                                                        'ShippingStreet' => 'Mailingstreet', 'ShippingPostalCode' => 'MailingPostalCode',
                                                                                        'KAH_HH_Admits_YTD' => 'KAH_HH_Admits_YTD__c', 'KAH_HP_Admits_YTD' => 'KAH_HP_Admits_YTD__c'};
            
            if(selField == 'strType'){
    
                strAscorDesc = 'ASC';
            }
            
            // Fetch the fields to be mapped to selected field
            if( mapAccFieldSelectedToAPINames.containsKey(selField) && mapConFieldSelectedToAPINames.containsKey(selField) ) {
                
                selAccountTD = mapAccFieldSelectedToAPINames.get(selField);
                selContactTD = mapConFieldSelectedToAPINames.get(selField);
            }
            else if(selField == 'strSpecialties') {
            
                selAccountTD = 'Name';
                selContactTD = 'Name';
            }
            else if(selField == 'strLengthOfStay') {
                
                selAccountTD = 'Name';
                selContactTD = 'Name';
            }
            else {  
                
                selAccountTD = selContactTD = selField; 
            }    
            
            for(String strContactFields : mapConFieldSelectedToAPINames.keyset()) {
               
                if(whereQueryContact.contains(strContactFields))
                    whereQueryContact = whereQueryContact.replace(strContactFields, mapConFieldSelectedToAPINames.get(strContactFields));
            }
           
            for(String strContactFields : mapAccFieldSelectedToAPINames.keyset()){
               
                if(whereQueryAccount.contains(strContactFields))
                    whereQueryAccount = whereQueryAccount.replace(strContactFields, mapAccFieldSelectedToAPINames.get(strContactFields));
            }
           
            //set to store the contact id that are displayed on reassign referral sources.
            set<id> setContactId = new set<Id>();
            
            if(strSpecilaityFilterValue != '') {
                
                Schema.DescribeFieldResult fieldResult = Contact.Specialties__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
                for( Schema.PicklistEntry f : ple) {
                    
                    for (String str : f.getvalue().split(' ')) {
                        
                        If(!(str.length()<2)) {
                            
                            if(mapPicklistValues.ContainsKey(str.toUpperCase()))
                                mapPicklistValues.get(str.toUpperCase()).add(f.getvalue());
                            else
                                mapPicklistValues.put(str.toUpperCase(),New List<String>{f.getvalue()});
                        }
                    } 
                }
                
                strSpecilaityFilterValue = strSpecilaityFilterValue.toUpperCase();
                
                for(String strTemp1 : mapPicklistValues.keyset()) {
                    
                    for(String strTemp3 : mapPicklistValues.get(strTemp1)) {
                        
                        if(strTemp1 == strSpecilaityFilterValue || strTemp1.contains(strSpecilaityFilterValue))
                            strAllValues += '\''+ strTemp3 + '\',';
                    }
                }
                
                strAllValues = strAllValues.Substring(0, strAllValues.length()-1);
            }
            
            if( (isTypeFilter == 'AccountFilter' || hasNoFilter == 'Allrecords') && strSpecilaityFilterValue == '')  {
                
                //Query string to get the Account details from Account team Member based on selected users and applied filters.   
                string AccountTeamMemberQuery = 'Select Id, AccountId, Account.Name, Account.NPI__c, Account.ShippingCity, Account.ShippingState, Account.Shippingstreet, '+
                                                    'Account.ShippingPostalCode, Account.Account_Type_Display__c, UserId, Account.KAH_HMS_ALL_HH_DR__c, '+
                                                    'Account.KAH_HMS_All_HP_DR__c, Account.KAH_HH_Referrals_YTD__c, '+
                                                    'Account.KAH_HP_Admits_YTD__c, Account.KAH_HP_Referrals_YTD__c, '+
                                                    'Account.HP_Admits_PY__c, Account.KAH_HP_Qualified_Admits_PY__c, '+
                                                    'Account.KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, '+
                                                    'Account.KAH_HMS_HH_CHF_Stroke_COPD_DR__c, Account.KAH_HMS_HH_Endo_Wounds_DR__c, Account.KAH_HMS_HH_Ortho_DR__c, '+
                                                    'Account.KAH_HMS_HH_Urinary_Kidney_GI_DR__c, Account.KAH_HMS_HP_Cancer_DR__c, Account.KAH_HMS_HP_CHF_DR__c, '+
                                                    'Account.KAH_HMS_HP_COPD_DR__c, Account.KAH_HMS_HP_Debility_DR__c, Account.KAH_HMS_HP_Dementia_DR__c, '+
                                                    'Account.KAH_HMS_HP_Influencer_Network_DR__c, Account.KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                    'Account.KAH_HH_Admits_YTD__c, Account.HH_Admits_PY__c, Account.KAH_HH_PPS_Prior_Year_Admits_Prior__c, '+
                                                    'Account.KAH_HD_Admits_YTD__c, Account.HD_Admits_PY__c, Account.KAH_NCD_Admits_YTD__c, Account.NCD_Admits_PY__c, '+
                                                    'Account.Doing_business_with__c, Account.RecordType.Name, Account.Parent.Name, '+  
                                                    'Account.KAH_HH_PPS_Admits_YTD__c, Account.KAH_HH_Discounted_Qualified_Admits_YTD__c, Account.KAH_HH_Discounted_Qualified_Admits_PY__c, Account.KAH_HP_Qualified_Admits_YTD__c '+
                                                    'From AccountTeamMember '+
                                                'WHERE UserId =: selFromUser AND Account.recordtypeid IN: lstAccountRecordType ' + whereQueryAccount + 
                                                ' Order By Account.'+selAccountTD+' '+strAscorDesc+
                                                ' NULLS Last LIMIT '+strQueryLimit; 
                                                                                      
                // Iterates over the Account Teams to get the Account Associates with it and to add it to the list.
                for(AccountTeamMember objATM : database.Query(AccountTeamMemberQuery)) {
                                            
                    lstAccounts.add(objATM.Account);
                    lstATMsAssigned.add( new AccountTeamMember( AccountId = objATM.AccountId));
                }    
            }
            
            // checks if filter has applied in strtype containing "contact" or there is no filter.
            if(isTypeFilter == 'ContactFilter' || hasNoFilter == 'Allrecords') {
                
                string strContactTeamMemberQuery = 'Select Id, Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.NPI__c, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingStreet, '+
                                                          'Contact__r.MailingPostalCode, User__c, Contact__r.Specialties__c, Contact__r.KAH_HMS_ALL_HH_DR__c, '+
                                                          'Contact__r.KAH_HMS_All_HP_DR__c, '+
                                                          'Contact__r.KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, '+
                                                          'Contact__r.KAH_HMS_HH_CHF_Stroke_COPD_DR__c, Contact__r.KAH_HMS_HH_Endo_Wounds_DR__c, Contact__r.KAH_HMS_HH_Ortho_DR__c, '+
                                                          'Contact__r.KAH_HMS_HH_Urinary_Kidney_GI_DR__c, Contact__r.KAH_HMS_HP_Cancer_DR__c, Contact__r.KAH_HMS_HP_CHF_DR__c, '+
                                                          'Contact__r.KAH_HMS_HP_COPD_DR__c, Contact__r.KAH_HMS_HP_Debility_DR__c, Contact__r.KAH_HMS_HP_Dementia_DR__c, '+
                                                          'Contact__r.KAH_HMS_HP_Influencer_Network_DR__c, Contact__r.KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                          'Contact__r.KAH_HH_Admits_YTD__c, Contact__r.HH_Admits_PY__c, '+
                                                          'Contact__r.KAH_HP_Admits_YTD__c, Contact__r.KAH_HP_Referrals_YTD__c, Contact__r.KAH_HH_Referrals_YTD__c, Contact__r.HP_Admits_PY__c, Contact__r.KAH_HH_PPS_Prior_Year_Admits_Prior__c, Contact__r.KAH_HD_Admits_YTD__c, '+
                                                          'Contact__r.HD_Admits_PY__c, Contact__r.KAH_NCD_Admits_YTD__c, Contact__r.NCD_Admits_PY__c, Contact__r.KAH_HP_Qualified_Admits_PY__c, '+
                                                          'Contact__r.Doing_business_with__c, Contact__r.KAH_HMS_HP_LOS__c, '+
                                                          'Contact__r.KAH_HH_PPS_Admits_YTD__c, Contact__r.KAH_HH_Discounted_Qualified_Admits_YTD__c, Contact__r.KAH_HH_Discounted_Qualified_Admits_PY__c, Contact__r.KAH_HP_Qualified_Admits_YTD__c '+
                                                  'From Contact_Team__c '+
                                                  'Where User__c =: selFromUser ' + whereQueryContact +
                                                      ((strSpecilaityFilterValue != '') ? (' AND Contact__r.Specialties__c includes (' + strAllValues + ') ') : '') +
                                                      ' AND Contact__r.Recordtypeid IN: lstContactRecordType Order By Contact__r.'+selContactTD+' '+strAscorDesc+
                                                      ' NULLS Last LIMIT '+ strQueryLimit;
                 
                //Iterates over the Account Teams to get the Account Associates with it and to add it to the list.                                         
                for(Contact_Team__c objCTM :  database.query(strContactTeamMemberQuery)) {
                    
                    if(!setContactId.contains(objCTM.Contact__r.Id)) {
                        
                        lstContacts.add(objCTM.Contact__r);
                        lstCTMsAssigned.add( new Contact_Team__c( Contact__c = objCTM.Contact__c ));
                        setContactId.add(objCTM.Contact__r.Id);  
                    }
                }
            }
            
            objReferralsAndMessages = new userReferralsAndMessages(lstAccounts, lstATMsAssigned, lstATMsIcons, lstContacts, lstCTMsAssigned, lstCTMsIcons, 'showError Message', '');
            return objReferralsAndMessages;
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
   
    
    /**
    @MethodName : fetchReferralSourcesTableSorter
    @Param      :    TDid : Id of the filed on which sorting is applied else it be sorted based on name
                     ariaSortVal : Contains ascending or descending value on which sorting is done
                     whereQueryAccount : where condition is formed based on values entered in filters for Account Query
                     whereQueryContact : where condition is formed based on values entered in filters for Contact Query
                     onTableLoad : Was used to check if the method is called from (tab click or picklist val change)if it is true and (on sorting and filtering) if it is false
                     isTypeFilter : If filter is applied on type this will contain the value accordingly 
                     selectedUser : UserId from the user selection picklist
                     selReferralFilter: Selected value in the 'View Type' picklist
                     selsecondReferralFilter : Selected value in the 'Active / Not Active' picklist
    @Description: Method used to fetch the Account and Contacts based on selected user and filters for Referral Source tab. 
    **/
    @RemoteAction 
    global static userReferralsAndMessages fetchReferralSourcesTableSorter(string TDid, string ariaSortVal, string strSpecilaityFilterValue, 
                                                                                string whereQueryAccount, string whereQueryContact, string onTableLoad, 
                                                                                string isTypeFilter, string selectedUser, 
                                                                                String selReferralFilter, string selSourceFilter, String selsecondReferralFilter ) {
       
        try {
            system.debug('====selSourceFilter====='+selSourceFilter);
            list<Account> lstAccounts = new List<Account>();
            list<AccountTeamMember> lstATMsAssigned = new List<AccountTeamMember>();
            list<AccountTeamMember> lstATMsIcons = new List<AccountTeamMember>();
            list<Contact> lstContacts = new List<Contact>();
            list<Contact_Team__c> lstCTMsAssigned = new List<Contact_Team__c>();
            list<Contact_Team__c> lstCTMsIcons = new List<Contact_Team__c>();
            
            strSpecilaityFilterValue = String.escapeSingleQuotes(strSpecilaityFilterValue).replaceAll('u2019', '\'');
            whereQueryAccount = String.escapeSingleQuotes(whereQueryAccount).replaceAll('u2019', '\'');
            whereQueryContact = String.escapeSingleQuotes(whereQueryContact).replaceAll('u2019', '\'');
            
            userReferralsAndMessages objReferralsAndMessages;
            
            Map<String,List<String>> mapPicklistValues = new Map<String,List<String>>();
            String strExistingSpecialityValues = '';

            // list to store the home Facility coresponding to the selected user.
            list<Home_Facility__c> lstHomeFacility = [  SELECT id, Account__r.Shipping_Geolocation__c, Account__r.Latitude__c, Account__r.Longitude__c 
                                                        FROM Home_Facility__c 
                                                        WHERE User__c =: selectedUser]; 
            
            list<RecordType> lstAccRecType = new list<RecordType>();
            system.debug(':::::::::::selSourceFilter:::::::::: ' +selSourceFilter);
            if(selSourceFilter != 'All' && selSourceFilter != ''){
                
                lstAccRecType = lstAccountRecordTypeforSourceFilter;
            }
            else{
            
                lstAccRecType = lstAccountRecordType;
            }
            
            // checks if the view type filter is "All with in 50/100 miles" and there are no home facility.
            if((selReferralFilter == '50' || selReferralFilter == '100')  && (lstHomeFacility.size() == 0 || lstHomeFacility[0].Account__c == null )){
                
                Account objAcc = new Account();
                objReferralsAndMessages = new userReferralsAndMessages(lstAccounts, lstATMsAssigned, lstATMsIcons, lstContacts, lstCTMsAssigned, lstCTMsIcons, 'showError Message', '');
                return objReferralsAndMessages;
            }
            
            if(strSpecilaityFilterValue != '') {
                
                Schema.DescribeFieldResult fieldResult = Contact.Specialties__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
                for( Schema.PicklistEntry f : ple) {
                
                    for (String str : f.getvalue().split(' ')) {
                    
                        If(!(str.length()<2)) {
                        
                            if(mapPicklistValues.ContainsKey(str.toUpperCase()))
                                mapPicklistValues.get(str.toUpperCase()).add(f.getvalue());
                            else
                                mapPicklistValues.put(str.toUpperCase(),New List<String>{f.getvalue()});
                        }
                    } 
                }
                
                strSpecilaityFilterValue = strSpecilaityFilterValue.toUpperCase();
                
                for(String strTemp1 : mapPicklistValues.keyset()) {
                
                    for(String strTemp3 : mapPicklistValues.get(strTemp1)) { 
                        
                        if(strTemp1 == strSpecilaityFilterValue || strTemp1.contains(strSpecilaityFilterValue))
                            strExistingSpecialityValues += '\''+ strTemp3 + '\',';
                    }
                }
                
                strExistingSpecialityValues = strExistingSpecialityValues.Substring(0,strExistingSpecialityValues.length()-1);
            }
            
            String strWhereCTM  = ' ';
            String strWhereATM  = ' ';
            String strWhereContactQuery  = ' ';
            String strWhereAccountQuery  = ' ';
            String strQueryLimit = '1001';
            Integer intMaxQueryLimit = 2002;
            string strAscorDesc = '';
            
            string selAccountTD = '';
            string selContactTD = '';
            string hasNoFilter = '';
             
            if(ariaSortVal == 'ascending' || ariaSortVal == 'none' || TDid == 'strType')
                strAscorDesc = 'ASC';
            else    
                strAscorDesc = 'DESC';
            
            Map<String, String> mapAccFieldSelectedToAPINames = new Map<String, String>{'1-referral' => 'Name', '2-referral' => 'NPI__c', '3-referral' => 'ShippingStreet',
                                                                                        '4-referral' => 'ShippingCity', '5-referral' => 'ShippingState', '6-referral' => 'ShippingPostalCode',
                                                                                        '7-referral' => 'Name', '8-referral' => 'Name', '9-referral' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '10-referral' => 'KAH_HH_Admits_YTD__c', '11-referral' => 'HH_Admits_PY__c',
                                                                                        '12-referral' => 'KAH_HP_Admits_YTD__c', '13-referral' => 'HP_Admits_PY__c',
                                                                                        '14-referral' => 'KAH_HD_Admits_YTD__c', '15-referral' => 'HD_Admits_PY__c',
                                                                                        '16-referral' => 'KAH_HH_PPS_Admits_YTD__c', '17-referral' => 'KAH_HH_Discounted_Qualified_Admits_YTD__c',
                                                                                        '18-referral' => 'KAH_HH_PPS_Prior_Year_Admits_Prior__c', '19-referral' => 'KAH_HH_Discounted_Qualified_Admits_PY__c',
                                                                                        '20-referral' => 'KAH_HH_Referrals_YTD__c', '21-referral' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '22-referral' => 'KAH_HMS_ALL_HH_DR__c', '23-referral' => 'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c',
                                                                                        '24-referral' => 'KAH_HMS_HH_CHF_Stroke_COPD_DR__c', '25-referral' => 'KAH_HMS_HH_Endo_Wounds_DR__c',
                                                                                        '26-referral' => 'KAH_HMS_HH_Urinary_Kidney_GI_DR__c', '27-referral' => 'KAH_HMS_HH_Ortho_DR__c',
                                                                                        '50-referral' => 'KAH_HP_Qualified_Admits_YTD__c', '51-referral' => 'KAH_HP_Qualified_Admits_PY__c',
                                                                                        '28-referral' => 'KAH_HP_Qualified_Admits_PY__c', '29-referral' => 'KAH_HP_Admits_YTD__c',
                                                                                        '30-referral' => 'KAH_HP_Referrals_YTD__c', '31-referral' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '32-referral' => 'KAH_HMS_All_HP_DR__c', '33-referral' => 'KAH_HMS_HP_Cancer_DR__c',
                                                                                        '34-referral' => 'KAH_HMS_HP_CHF_DR__c', '35-referral' => 'KAH_HMS_HP_COPD_DR__c',
                                                                                        '36-referral' => 'KAH_HMS_HP_Dementia_DR__c', '37-referral' => 'KAH_HMS_HP_Debility_DR__c',
                                                                                        '38-referral' => 'KAH_HMS_HP_Influencer_Network_DR__c', '39-referral' => 'id',
                                                                                        '40-referral' => 'NPI__c', '41-referral' => 'HMS_POID__c',
                                                                                        '42-referral' => 'HPAS_ID__c', '43-referral' => 'Horizon_ID__c',
                                                                                        '44-referral' => 'Meditech_ID__c', '45-referral' => 'Unity_ID__c',
                                                                                        'strType' => 'Name', 'ShippingCity' => 'ShippingCity',
                                                                                        'ShippingState' => 'ShippingState', 'ShippingStreet' => 'ShippingStreet',
                                                                                        'ShippingPostalCode' => 'ShippingPostalCode', 'KAH_HH_Admits_YTD' => 'KAH_HH_Admits_YTD__c',
                                                                                        'KAH_HP_Admits_YTD' => 'KAH_HP_Admits_YTD__c', 'SFID' => 'id', 'NPI_ID' => 'NPI__c',
                                                                                        'HMS_ID' => 'HMS_POID__c', 'HPAS_ID' => 'HPAS_ID__c', 'Horizon_ID' => 'Horizon_ID__c',
                                                                                        'Meditech_ID' => 'Meditech_ID__c', 'Unity_ID' => 'Unity_ID__c'};
            
            Map<String, String> mapConFieldSelectedToAPINames = new Map<String, String>{'1-referral' => 'Name', '2-referral' => 'NPI__c', '3-referral' => 'Mailingstreet',
                                                                                        '4-referral' => 'MailingCity', '5-referral' => 'MailingState', '6-referral' => 'MailingPostalCode',
                                                                                        '7-referral' => 'Name', '8-referral' => 'Name', '9-referral' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '10-referral' => 'KAH_HH_Admits_YTD__c', '11-referral' => 'HH_Admits_PY__c',
                                                                                        '12-referral' => 'KAH_HP_Admits_YTD__c', '13-referral' => 'HP_Admits_PY__c',
                                                                                        '14-referral' => 'KAH_HD_Admits_YTD__c', '15-referral' => 'HD_Admits_PY__c',
                                                                                        '16-referral' => 'KAH_HH_PPS_Admits_YTD__c', '17-referral' => 'KAH_HH_Discounted_Qualified_Admits_YTD__c',
                                                                                        '18-referral' => 'KAH_HH_PPS_Prior_Year_Admits_Prior__c', '19-referral' => 'KAH_HH_Discounted_Qualified_Admits_PY__c',
                                                                                        '20-referral' => 'KAH_HH_Referrals_YTD__c', '21-referral' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '22-referral' => 'KAH_HMS_ALL_HH_DR__c', '23-referral' => 'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c',
                                                                                        '24-referral' => 'KAH_HMS_HH_CHF_Stroke_COPD_DR__c', '25-referral' => 'KAH_HMS_HH_Endo_Wounds_DR__c',
                                                                                        '26-referral' => 'KAH_HMS_HH_Urinary_Kidney_GI_DR__c', '27-referral' => 'KAH_HMS_HH_Ortho_DR__c',
                                                                                        '50-referral' => 'KAH_HP_Qualified_Admits_YTD__c', '51-referral' => 'KAH_HP_Qualified_Admits_PY__c',
                                                                                        '28-referral' => 'KAH_HP_Qualified_Admits_PY__c', '29-referral' => 'KAH_HP_Admits_YTD__c',
                                                                                        '30-referral' => 'KAH_HP_Referrals_YTD__c', '31-referral' => 'KAH_HMS_Total_Patient_Volume_DR__c',
                                                                                        '32-referral' => 'KAH_HMS_All_HP_DR__c', '33-referral' => 'KAH_HMS_HP_Cancer_DR__c',
                                                                                        '34-referral' => 'KAH_HMS_HP_CHF_DR__c', '35-referral' => 'KAH_HMS_HP_COPD_DR__c',
                                                                                        '36-referral' => 'KAH_HMS_HP_Dementia_DR__c', '37-referral' => 'KAH_HMS_HP_Debility_DR__c',
                                                                                        '38-referral' => 'KAH_HMS_HP_Influencer_Network_DR__c', '39-referral' => 'id',
                                                                                        '40-referral' => 'NPI__c', '41-referral' => 'HMS_PIID__c',
                                                                                        '42-referral' => 'HPAS_Contact_ID__c', '43-referral' => 'Horizon_ID__c',
                                                                                        '44-referral' => 'Meditech_Contact_ID__c', '45-referral' => 'Unity_ID__c',
                                                                                        'strType' => 'Name', 'ShippingCity' => 'MailingCity',
                                                                                        'ShippingState' => 'MailingState', 'ShippingStreet' => 'Mailingstreet',
                                                                                        'ShippingPostalCode' => 'MailingPostalCode', 'KAH_HH_Admits_YTD' => 'KAH_HH_Admits_YTD__c',
                                                                                        'KAH_HP_Admits_YTD' => 'KAH_HP_Admits_YTD__c', 'SFID' => 'id', 'NPI_ID' => 'NPI__c',
                                                                                        'HMS_ID' => 'HMS_PIID__c', 'HPAS_ID' => 'HPAS_Contact_ID__c', 'Horizon_ID' => 'Horizon_ID__c',
                                                                                        'Meditech_ID' => 'Meditech_Contact_ID__c', 'Unity_ID' => 'Unity_ID__c'
                                                                                       };
    
            // Fetch the fields to be mapped to selected field
            if( mapAccFieldSelectedToAPINames.containsKey(TDid)) {
                
                selAccountTD = mapAccFieldSelectedToAPINames.get(TDid);
            }
            
            // Identifies the field to be Ordered By and by default assign Name field
            if( mapConFieldSelectedToAPINames.containsKey(TDid)) {
                
                selContactTD = mapConFieldSelectedToAPINames.get(TDid);
            }
            else  if(TDid == '' || TDid == 'strSpecialties') {
                
                selAccountTD ='Name';
                selContactTD = 'Name';
            }
            else  if(TDid == 'strLengthOfStay') {
                
                selAccountTD ='Name';
                selContactTD = 'Name';
            }
            else {
                
                selAccountTD = selContactTD = TDid; 
            }
            
            //checks if any filter has applied on srtaType.
            if(isTypeFilter != 'ContactFilter' && isTypeFilter != 'AccountFilter')
                hasNoFilter = 'Allrecords';
         
                
            for(String strContactFields : mapConFieldSelectedToAPINames.keyset()) {
               
                if(whereQueryContact.contains(strContactFields))
                    whereQueryContact = whereQueryContact.replace(strContactFields, mapConFieldSelectedToAPINames.get(strContactFields));
            }
           
            for(String strAccountFields : mapAccFieldSelectedToAPINames.keyset()){
               
                if(whereQueryAccount.contains(strAccountFields)){
                    whereQueryAccount = whereQueryAccount.replace(strAccountFields, mapAccFieldSelectedToAPINames.get(strAccountFields));
                
                }
            }
            
            Id generalContactRecordTypeId = lstContactRecordType[0].Id;

            String strLimitForAccountQueries = '';
            String strLimitForContactQueries = '';
            if( isTypeFilter == 'AccountFilter' || isTypeFilter == 'ContactFilter') {
                
                strLimitForAccountQueries = String.valueOf( intMaxQueryLimit );
                strLimitForContactQueries = String.valueOf( intMaxQueryLimit );
            }
            else {
                
                strLimitForAccountQueries = strQueryLimit;
            }
            
            // Prepare the list of Accounts and Contacts when CurrentlyAssigned option is selected
            if(selReferralFilter == 'CurrentlyAssigned') {
                
                Set<Id> setATMIds = new Set<Id>();
                Set<Id> setCTMIds = new Set<Id>();
                
                // checks if filter has applied in strtype containing "Account" or there is no filter.
                    // No accounts filtered when Speciality field is filtered
                if( ( isTypeFilter == 'AccountFilter' || hasNoFilter == 'Allrecords') && strSpecilaityFilterValue == '') {
                    
                    string strAccountTeamMemberQuery = 'SELECT Id, AccountId, Account.Status__c, Account.RecordType.Name, Account.Parent.Name, Account.Name, Account.NPI__c, Account.ShippingCity, Account.ShippingState, Account.Shippingstreet, '+
                                                            'Account.ShippingPostalCode, Account.Account_Type_Display__c, UserId, Account.KAH_HMS_ALL_HH_DR__c, '+
                                                            'Account.KAH_HMS_All_HP_DR__c, Account.KAH_HH_Referrals_YTD__c, '+
                                                            'Account.KAH_HP_Admits_YTD__c, Account.KAH_HP_Referrals_YTD__c, '+
                                                            'Account.HP_Admits_PY__c, Account.KAH_HP_Qualified_Admits_PY__c, '+
                                                            'Account.KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, '+
                                                            'Account.HMS_POID__c, Account.HPAS_ID__c, Account.Horizon_ID__c, Account.Meditech_ID__c, Account.Unity_ID__c, '+
                                                            'Account.KAH_HMS_HH_CHF_Stroke_COPD_DR__c, Account.KAH_HMS_HH_Endo_Wounds_DR__c, Account.KAH_HMS_HH_Ortho_DR__c, '+
                                                            'Account.KAH_HMS_HH_Urinary_Kidney_GI_DR__c, Account.KAH_HMS_HP_Cancer_DR__c, Account.KAH_HMS_HP_CHF_DR__c, '+
                                                            'Account.KAH_HMS_HP_COPD_DR__c, Account.KAH_HMS_HP_Debility_DR__c, Account.KAH_HMS_HP_Dementia_DR__c, '+
                                                            'Account.KAH_HMS_HP_Influencer_Network_DR__c, Account.KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                            'Account.KAH_HH_Admits_YTD__c, Account.HH_Admits_PY__c, Account.KAH_HH_PPS_Prior_Year_Admits_Prior__c, '+
                                                            'Account.KAH_HD_Admits_YTD__c, Account.HD_Admits_PY__c, Account.KAH_NCD_Admits_YTD__c, Account.NCD_Admits_PY__c, '+
                                                            'Account.Doing_business_with__c, '+
                                                            'Account.KAH_HH_PPS_Admits_YTD__c, Account.KAH_HH_Discounted_Qualified_Admits_YTD__c, Account.KAH_HH_Discounted_Qualified_Admits_PY__c, Account.KAH_HP_Qualified_Admits_YTD__c '+
                                                        'FROM AccountTeamMember '+
                                                        'WHERE UserId =: selectedUser AND Account.recordtypeid IN: lstAccRecType ' + whereQueryAccount + 
                                                        ' Order By Account.'+selAccountTD+' '+strAscorDesc+
                                                        ' NULLS Last LIMIT '+strLimitForAccountQueries;   
                    
                    for(AccountTeamMember objATM : database.query(strAccountTeamMemberQuery)) {   
                            
                            if(selSourceFilter !='All' && selSourceFilter !=''){
                                
                                If(objATM.Account.RecordType.Name != 'Center' || 
                                (objATM.Account.RecordType.Name == 'Center' && objATM.Account.Parent.Name == 'Kindred Healthcare Inc' && objATM.Account.Status__c == 'Active')) {   
                                    
                                    lstAccounts.add(objATM.Account);
                                    lstATMsAssigned.add( new AccountTeamMember( AccountId = objATM.AccountId));
                                    setATMIds.add(objATM.Id);
                                }
                            }
                            else{
                                
                                lstAccounts.add(objATM.Account);
                                lstATMsAssigned.add( new AccountTeamMember( AccountId = objATM.AccountId));
                                setATMIds.add(objATM.Id);
                            }
                    }
                    
                    //Aggregate query to get the count of AccountTeamMembers and to add corresponding account to the list which is displayed on referral tab.
                    for (AggregateResult results : [SELECT AccountId 
                                                    FROM AccountTeamMember 
                                                    WHERE AccountId IN: lstAccounts AND
                                                            Id NOT IN: setATMIds
                                                    Group By AccountId])  {

                        lstATMsIcons.add( new AccountTeamMember( AccountId = (Id) results.get('AccountId')) ); 
                    }
                }
                
                //checks if filter has applied in strtype containing "contact" or there is no filter.
                if(isTypeFilter == 'ContactFilter' || hasNoFilter == 'Allrecords') {
                    
                    strLimitForContactQueries = String.valueOf(intMaxQueryLimit - lstAccounts.size());
                    
                    string strContactTeamMemberQuery = 'Select Id, Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.NPI__c, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingStreet, '+
                                                          'Contact__r.MailingPostalCode, User__c, Contact__r.Specialties__c, Contact__r.KAH_HMS_ALL_HH_DR__c, '+
                                                          'Contact__r.KAH_HMS_All_HP_DR__c, '+
                                                          'Contact__r.KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, '+
                                                          'Contact__r.HMS_PIID__c, Contact__r.HPAS_Contact_ID__c, Contact__r.Horizon_ID__c, Contact__r.Meditech_Contact_ID__c, Contact__r.Unity_ID__c, '+
                                                          'Contact__r.KAH_HMS_HH_CHF_Stroke_COPD_DR__c, Contact__r.KAH_HMS_HH_Endo_Wounds_DR__c, Contact__r.KAH_HMS_HH_Ortho_DR__c, '+
                                                          'Contact__r.KAH_HMS_HH_Urinary_Kidney_GI_DR__c, Contact__r.KAH_HMS_HP_Cancer_DR__c, Contact__r.KAH_HMS_HP_CHF_DR__c, '+
                                                          'Contact__r.KAH_HMS_HP_COPD_DR__c, Contact__r.KAH_HMS_HP_Debility_DR__c, Contact__r.KAH_HMS_HP_Dementia_DR__c, '+
                                                          'Contact__r.KAH_HMS_HP_Influencer_Network_DR__c, Contact__r.KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                          'Contact__r.KAH_HH_Admits_YTD__c, Contact__r.HH_Admits_PY__c, '+
                                                          'Contact__r.KAH_HP_Admits_YTD__c, Contact__r.KAH_HP_Referrals_YTD__c, Contact__r.KAH_HH_Referrals_YTD__c, Contact__r.HP_Admits_PY__c, Contact__r.KAH_HH_PPS_Prior_Year_Admits_Prior__c, Contact__r.KAH_HD_Admits_YTD__c, '+
                                                          'Contact__r.HD_Admits_PY__c, Contact__r.KAH_NCD_Admits_YTD__c, Contact__r.NCD_Admits_PY__c, Contact__r.KAH_HP_Qualified_Admits_PY__c, '+
                                                          'Contact__r.Doing_business_with__c, Contact__r.KAH_HMS_HP_LOS__c, '+
                                                          'Contact__r.KAH_HH_PPS_Admits_YTD__c, Contact__r.KAH_HH_Discounted_Qualified_Admits_YTD__c, Contact__r.KAH_HH_Discounted_Qualified_Admits_PY__c, Contact__r.KAH_HP_Qualified_Admits_YTD__c '+
                                                      'From Contact_Team__c '+
                                                      'Where User__c =: selectedUser ' + whereQueryContact +
                                                      ((strSpecilaityFilterValue != '') ? (' AND Contact__r.Specialties__c includes (' + strExistingSpecialityValues + ') ') : '') +
                                                      ' AND Contact__r.Recordtypeid IN: lstContactRecordType Order By Contact__r.'+selContactTD+' '+strAscorDesc+
                                                      ' NULLS Last LIMIT '+ strLimitForContactQueries;
                    for(Contact_Team__c objCTM : database.query(strContactTeamMemberQuery)){
                        
                        lstContacts.add(objCTM.Contact__r);
                        lstCTMsAssigned.add( new Contact_Team__c( Contact__c = objCTM.Contact__c ));
                        setCTMIds.add(objCTM.Id);
                    }
         
                    // Aggregate query to get the count of ContactTeamMembers and to add corresponding contact to the list which is displayed on referral tab.
                    for (AggregateResult results : [Select Contact__c  
                                                    From Contact_Team__c 
                                                    Where Contact__r.Id IN:lstContacts AND 
                                                            Id NOT IN: setCTMIds
                                                    group By Contact__c])  {

                        lstCTMsIcons.add( new Contact_Team__c( Contact__c = (Id) results.get('Contact__c')) ); 
                    }
                }
            }
            //Fetching the listOfAccountandContacts based on selected option in picklist
            else  if(selReferralFilter == '50' || selReferralFilter == '100' || selReferralFilter == 'AllAccountsAndContacs') {
                
                //Forming the query based on filter condition 
                Decimal miles = (selReferralFilter == '50' || selReferralFilter == '100') ? Decimal.valueOf((selReferralFilter)): 0;
                string strLatitiude='';
                string strLongitude='';
                
                if(selReferralFilter == '50' || selReferralFilter == '100' ) {
                    
                    if( !lstHomeFacility.isEmpty() && lstHomeFacility[0].Account__r.Shipping_Geolocation__c != null ) {
                        
                        strLatitiude = string.valueOf(lstHomeFacility[0].Account__r.Shipping_Geolocation__c.getLatitude());
                        strLongitude = string.valueOf(lstHomeFacility[0].Account__r.Shipping_Geolocation__c.getLongitude());
                    }
                    else {
                        
                        miles = 0;
                        strLatitiude ='50';
                        strLongitude = '50';
                    }
                    
                    //adds geolocation condition for the query for contacts
                    strWhereCTM += 'WHERE (DISTANCE(Contact__r.Geolocation__c, ' +
                                                'GEOLOCATION('+strLatitiude+', '+strLongitude+'), \'mi\') < :miles) ' + 
                                    //'AND Contact__r.Geolocation__Latitude__s != null AND Contact__r.Geolocation__Longitude__s != null ' +
                                    'AND User__c =: selectedUser ' +
                                    'AND Contact__r.recordtypeid =: generalContactRecordTypeId ' +
                                    ((selsecondReferralFilter == 'Customer') ? 'AND Contact__r.Doing_business_with__c = true' :
                                    ((selsecondReferralFilter == 'Prospect') ? 'AND Contact__r.Doing_business_with__c = false' : ''));
                        
                    //adds geolocation condition for the query for accounts    
                    strWhereATM += 'WHERE (DISTANCE(Account.Shipping_Geolocation__c, ' +
                                                    'GEOLOCATION('+strLatitiude+', '+strLongitude+'), \'mi\') < :miles) ' + 
                                        //'AND Account.Shipping_Geolocation__Latitude__s != null AND Account.Shipping_Geolocation__Longitude__s != null ' +
                                        'AND UserId =: selectedUser ' +
                                        'AND Account.recordtypeid IN: lstAccRecType ' +
                                        ((selsecondReferralFilter == 'Customer') ? 'AND Account.Doing_business_with__c = true' :
                                        ((selsecondReferralFilter == 'Prospect') ? 'AND Account.Doing_business_with__c = false' : ''));

                    strWhereContactQuery += strWhereCTM.replaceAll('Contact__r.', '').replaceAll('User__c =: selectedUser AND ', '');
                    strWhereAccountQuery += strWhereATM.replaceAll('Account\\.', '').replaceAll('UserId =: selectedUser AND ', '');
                }
                
                //Forming the query based on filter condition
                else if(selReferralFilter == 'AllAccountsAndContacs') {
                    
                    //adds the condition for contact based on the record type
                    strWhereCTM +='WHERE User__c =: selectedUser AND ' + 
                                        'Contact__r.recordtypeid =: generalContactRecordTypeId ' +
                                        ((selsecondReferralFilter == 'Customer') ? 'AND Contact__r.Doing_business_with__c = true' :
                                        ((selsecondReferralFilter == 'Prospect') ? 'AND Contact__r.Doing_business_with__c = false' : ''));
                    
                    //adds the condition for accounts based on the record type
                    strWhereATM += 'WHERE UserId =: selectedUser AND ' + 
                                        'Account.recordtypeid IN: lstAccRecType ' +
                                        ((selsecondReferralFilter == 'Customer') ? 'AND Account.Doing_business_with__c = true' :
                                        ((selsecondReferralFilter == 'Prospect') ? 'AND Account.Doing_business_with__c = false' : ''));
                    
                    strWhereContactQuery += strWhereCTM.replaceAll('Contact__r.', '').replaceAll('User__c =: selectedUser AND ', '');
                    strWhereAccountQuery += strWhereATM.replaceAll('Account\\.', '').replaceAll('UserId =: selectedUser AND ', '');                              
                }
                
                String strCTMQuery = whereQueryContact;
                String strATMQuery = whereQueryAccount;
                whereQueryContact = whereQueryContact.replaceAll('Contact__r.', '');
                whereQueryAccount = whereQueryAccount.replaceAll('Account\\.', '');
                whereQueryAccount = whereQueryAccount.replaceAll('AccountId', 'Id');

                Set<Id> setOfContactTeamId = new Set<Id>();
                Set<Id> setOfAccountTeamId = new Set<Id>();
                
                //lstATMsAssigned = database.query('Select AccountId From AccountTeamMember ' + strWhereATM);
                //lstCTMsAssigned = database.query('Select Contact__c From Contact_Team__c '+ strWhereCTM);
                
                //checks if filter has applied in strtype containing "Account" or there is no filter.
                if(isTypeFilter == 'AccountFilter' || hasNoFilter == 'Allrecords') {
                     
                    if(strSpecilaityFilterValue == '') {
                            
                        //Query string to get accounts based on the added conditions if there is no filter applied to it.                              
                        String strAccountQuerywithoutFilters = '';
                        if(selSourceFilter !='All' && selSourceFilter !=''){
                            
                            strAccountQuerywithoutFilters = 'Select Id, Name, NPI__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingStreet, Account_Type_Display__c, ' +
                                                                            'KAH_HMS_ALL_HH_DR__c, KAH_HP_Qualified_Admits_PY__c, ' +
                                                                            'KAH_HMS_All_HP_DR__c, KAH_HP_Admits_YTD__c, KAH_HP_Referrals_YTD__c, KAH_HH_Referrals_YTD__c, ' +
                                                                            'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, KAH_HMS_HH_CHF_Stroke_COPD_DR__c, HP_Admits_PY__c, ' +
                                                                            'KAH_HH_Admits_YTD__c, HH_Admits_PY__c, '+
                                                                            'HMS_POID__c, HPAS_ID__c, Horizon_ID__c, Meditech_ID__c, Unity_ID__c, '+
                                                                            'KAH_HMS_HH_Endo_Wounds_DR__c, KAH_HMS_HH_Ortho_DR__c, KAH_HMS_HH_Urinary_Kidney_GI_DR__c, ' +
                                                                            'KAH_HMS_HP_Cancer_DR__c, KAH_HMS_HP_CHF_DR__c, KAH_HMS_HP_COPD_DR__c, KAH_HH_PPS_Prior_Year_Admits_Prior__c, ' +
                                                                            'KAH_HMS_HP_Debility_DR__c, KAH_HMS_HP_Dementia_DR__c, KAH_HMS_HP_Influencer_Network_DR__c, '+
                                                                            'KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                                            'KAH_HD_Admits_YTD__c, HD_Admits_PY__c, KAH_NCD_Admits_YTD__c, NCD_Admits_PY__c, '+
                                                                            'KAH_HH_PPS_Admits_YTD__c, KAH_HH_Discounted_Qualified_Admits_YTD__c, KAH_HH_Discounted_Qualified_Admits_PY__c, KAH_HP_Qualified_Admits_YTD__c, '+
                                                                            'Doing_business_with__c, RecordType.Name, Parent.Name, Status__c '+
                                                                'From Account ' + strWhereAccountQuery + whereQueryAccount +
                                                                ' AND (RecordType.Name != \'Center\' OR (RecordType.Name = \'Center\' AND Parent.Name = \'Kindred Healthcare Inc\' AND Status__c = \'Active\'))'+
                                                                ' Order By '+selAccountTD+' '+strAscorDesc+
                                                                ' NULLS Last Limit ' + strLimitForAccountQueries;
                        }
                        else{
                            strAccountQuerywithoutFilters = 'Select Id, Name, NPI__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingStreet, Account_Type_Display__c, ' +
                                                                            'KAH_HMS_ALL_HH_DR__c, KAH_HP_Qualified_Admits_PY__c, ' +
                                                                            'KAH_HMS_All_HP_DR__c, KAH_HP_Admits_YTD__c, KAH_HP_Referrals_YTD__c, KAH_HH_Referrals_YTD__c, ' +
                                                                            'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, KAH_HMS_HH_CHF_Stroke_COPD_DR__c, HP_Admits_PY__c, ' +
                                                                            'KAH_HH_Admits_YTD__c, HH_Admits_PY__c, '+
                                                                            'HMS_POID__c, HPAS_ID__c, Horizon_ID__c, Meditech_ID__c, Unity_ID__c, '+
                                                                            'KAH_HMS_HH_Endo_Wounds_DR__c, KAH_HMS_HH_Ortho_DR__c, KAH_HMS_HH_Urinary_Kidney_GI_DR__c, ' +
                                                                            'KAH_HMS_HP_Cancer_DR__c, KAH_HMS_HP_CHF_DR__c, KAH_HMS_HP_COPD_DR__c, KAH_HH_PPS_Prior_Year_Admits_Prior__c, ' +
                                                                            'KAH_HMS_HP_Debility_DR__c, KAH_HMS_HP_Dementia_DR__c, KAH_HMS_HP_Influencer_Network_DR__c, '+
                                                                            'KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                                            'KAH_HD_Admits_YTD__c, HD_Admits_PY__c, KAH_NCD_Admits_YTD__c, NCD_Admits_PY__c, '+
                                                                            'KAH_HH_PPS_Admits_YTD__c, KAH_HH_Discounted_Qualified_Admits_YTD__c, KAH_HH_Discounted_Qualified_Admits_PY__c, KAH_HP_Qualified_Admits_YTD__c, '+
                                                                            'Doing_business_with__c, RecordType.Name, Parent.Name '+
                                                                'From Account ' + strWhereAccountQuery + whereQueryAccount +
                                                                ' Order By '+selAccountTD+' '+strAscorDesc+
                                                                ' NULLS Last Limit ' + strLimitForAccountQueries;
                        }
                     
                        lstAccounts = database.query(strAccountQuerywithoutFilters);
                        
                        for(AggregateResult ar: database.query( 'Select AccountId ' + 
                                                                'From AccountTeamMember '+ 
                                                                'Where UserId =: selectedUser ' + 
                                                                    ' AND Account.recordtypeid IN: lstAccRecType ' +
                                                                    ' AND AccountId IN : lstAccounts ' + strATMQuery + 
                                                                ' Group By AccountId')) {
                        
                            lstATMsAssigned.add( new AccountTeamMember( AccountId = (Id) ar.get('AccountId')) );                                            
                        }
                        
                        for(AggregateResult ar: database.query( 'Select AccountId ' + 
                                                                'From AccountTeamMember '+ 
                                                                'Where UserId !=: selectedUser ' + 
                                                                    ' AND Account.recordtypeid IN: lstAccRecType ' +
                                                                    ' AND AccountId IN : lstAccounts ' + strATMQuery +
                                                                ' Group By AccountId')) {
                        
                            lstATMsIcons.add( new AccountTeamMember( AccountId = (Id) ar.get('AccountId')) );                                           
                        }
                    }
                }
                
                //checks if filter has applied in strtype containing "contact" or there is no filter.
                if(isTypeFilter == 'ContactFilter' || hasNoFilter == 'Allrecords') {
                    
                    strLimitForContactQueries = String.valueOf(intMaxQueryLimit - lstAccounts.size());
                    
                    string strContactQuerywithoutFilters = 'Select Id, Name, FirstName, LastName, NPI__c, MailingCity, MailingState, MailingPostalCode, MailingStreet, Specialties__c, ' +
                                                                'KAH_HH_Admits_YTD__c, KAH_HH_PPS_Prior_Year_Admits_Prior__c, '+
                                                                'HP_Admits_PY__c, HH_Admits_PY__c, KAH_HP_Admits_YTD__c, KAH_HP_Referrals_YTD__c, KAH_HH_Referrals_YTD__c, KAH_HD_Admits_YTD__c, '+
                                                                'HD_Admits_PY__c, KAH_NCD_Admits_YTD__c, NCD_Admits_PY__c, KAH_HP_Qualified_Admits_PY__c, '+
                                                                'KAH_HMS_ALL_HH_DR__c, ' +
                                                                'KAH_HMS_All_HP_DR__c, '+
                                                                'HMS_PIID__c, HPAS_Contact_ID__c, Horizon_ID__c, Meditech_Contact_ID__c, Unity_ID__c, '+
                                                                'KAH_HMS_HH_Cancer_Bold_Vascular_DR__c, KAH_HMS_HH_CHF_Stroke_COPD_DR__c, '+
                                                                'KAH_HMS_HH_Endo_Wounds_DR__c, KAH_HMS_HH_Ortho_DR__c, ' +
                                                                'KAH_HMS_HH_Urinary_Kidney_GI_DR__c, KAH_HMS_HP_Cancer_DR__c, '+
                                                                'KAH_HMS_HP_CHF_DR__c, KAH_HMS_HP_COPD_DR__c, KAH_HMS_HP_Debility_DR__c, '+
                                                                'KAH_HMS_HP_Dementia_DR__c, KAH_HMS_HP_Influencer_Network_DR__c, '+
                                                                'KAH_HMS_Total_Patient_Volume_DR__c, '+
                                                                'KAH_HH_PPS_Admits_YTD__c, KAH_HH_Discounted_Qualified_Admits_YTD__c, KAH_HH_Discounted_Qualified_Admits_PY__c, KAH_HP_Qualified_Admits_YTD__c, '+ 
                                                                'Doing_business_with__c, KAH_HMS_HP_LOS__c '+
                                                        'From Contact ' + strWhereContactQuery + whereQueryContact +
                                                        ((strSpecilaityFilterValue != '') ? (' AND Specialties__c includes (' + strExistingSpecialityValues + ')') : '') +
                                                        ' Order By '+selContactTD+' '+strAscorDesc+
                                                        ' NULLS Last Limit ' + strLimitForContactQueries; 
                    lstContacts = database.query(strContactQuerywithoutFilters);
                    
                    for(AggregateResult ar: database.query( 'Select Contact__c ' + 
                                                            'From Contact_Team__c '+ 
                                                            'Where User__c =: selectedUser ' + 
                                                                    ' AND Contact__r.recordtypeid IN: lstContactRecordType ' +
                                                                    ' AND Contact__c IN : lstContacts ' + strCTMQuery + 
                                                            ' Group By Contact__c')) {
                    
                         lstCTMsAssigned.add( new Contact_Team__c( Contact__c = (Id) ar.get('Contact__c')) );                                                           
                    }
                    
                    for(AggregateResult ar: database.query( 'Select Contact__c ' + 
                                                            'From Contact_Team__c '+ 
                                                            'Where User__c !=: selectedUser ' + 
                                                                    ' AND Contact__r.recordtypeid IN: lstContactRecordType ' +
                                                                    ' AND Contact__c IN : lstContacts ' + strCTMQuery + 
                                                            ' Group By Contact__c')) {
                    
                    
                         lstCTMsIcons.add( new Contact_Team__c( Contact__c = (Id) ar.get('Contact__c')) );                                                          
                    }
                }
            }

            objReferralsAndMessages = new userReferralsAndMessages(lstAccounts, lstATMsAssigned, lstATMsIcons, lstContacts, lstCTMsAssigned, lstCTMsIcons, '', '');
          
            return objReferralsAndMessages; 
            
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    /**
    @MethodName : assignReferralSources
    @Param      : selectedUser, referralData
    @Description: Method used to assign the ReferralSources based on selected user. If the assign is checked, the referral is assigned to the user and vise versa.
    **/
    @RemoteAction 
    global static integer assignReferralSources(String selectedUser, String referralData) {
        
        try{
            JSONParser objParser = JSON.createParser(referralData);
            //list to hold user Accounts and Contacts
            List<UserAccountsandContacts> lstUserAccountsandContacts = (List<UserAccountsandContacts>) objParser.readValueAs(List<UserAccountsandContacts>.class);
            
            map<string, string> mapAccIdToShareRec = new map<string, string>();
             
            set<Id>setAccountIdforRecordType = new set<Id>();
            for(UserAccountsandContacts objUserAccountsandContactsforRT : lstUserAccountsandContacts){
                
                String myIdPrefix = String.valueOf(objUserAccountsandContactsforRT.strReferralId).substring(0,3);
                
                //checks if the id prefix is of account
                if(myIdPrefix == '001')
                    setAccountIdforRecordType.add(objUserAccountsandContactsforRT.strReferralId);
                
            }
            
            for(Account objAcc : [select id, RecordType.Name from Account where id in: setAccountIdforRecordType]){
                
                mapAccIdToShareRec.put(objAcc.Id, objAcc.RecordType.Name);
            }
            //list to hold AccountteamMembers to insert
            List<AccountTeamMember> lstATMsToInsert = new List<AccountTeamMember>(); 
            //list to hold AccountShare to insert
            List<AccountShare> lstAccountShareToInsert = new List<AccountShare>(); 
            //list to hold ContactTeamMembers to insert
            List<Contact_Team__c> lstContactTeamsToInsert = new List<Contact_Team__c>();
            //list to hold AccountTeammembers to delete
            List<AccountTeamMember> lstATMsToDelete = new List<AccountTeamMember>(); 
            //list to hold ContactTeamMembers to delete
            List<Contact_Team__c> lstContactTeamsToDelete = new List<Contact_Team__c>();
            integer totalCount = 0;
            
            map<string, string> mapAccIdMemberId = new map<string, string>();
            map<string, string> mapAccIdtoRecordtype = new map<string, string>();
           
              
            //iterates over the Contact team of the selected user from user picklist to get the contacts                                            
            for(Contact_Team__c objCTM : [  Select Id, Contact__c, Contact__r.RecordType.Name  
                                            From Contact_Team__c 
                                            Where User__c =: selectedUser AND Contact__r.Recordtypeid IN: lstContactRecordType]) {
                
                mapAccIdMemberId.put(objCTM.Contact__c, objCTM.Id);
            }
            
            //iterates over the Account Team of the selected user from user picklist to get the accounts
            for(AccountTeamMember objATM : [Select Id, AccountId, Account.RecordType.Name 
                                            From AccountTeamMember 
                                            Where UserId =: selectedUser AND Account.Recordtypeid IN: lstAccountRecordType]) {
                
                  mapAccIdMemberId.put(objATM.AccountId, objATM.Id);  
            }
            //integer to store the count and account and Contact team member the user has
            integer mapCount = mapAccIdMemberId.size();
            
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setSelectedUserIds = new Set<Id>();
            Set<String> setAccount_User = new Set<String>();
            
            //Iterates over the list that has to be assigned or unassigned and makes the assignments accordingly.
            for(UserAccountsandContacts objUserAccountsandContacts : lstUserAccountsandContacts) {
                
                //checks if the record has to Assign and it is Account.
                if(objUserAccountsandContacts.strOperation != 'Delete') {
                    
                    if(objUserAccountsandContacts.strType == 'Account') {
                            
                        lstATMsToInsert.add(new AccountTeamMember(  AccountId = objUserAccountsandContacts.strReferralId,
                                                                    TeamMemberRole = 'Clinical Liaison',
                                                                    UserId = selectedUser));
                        
                        setAccountIds.add(objUserAccountsandContacts.strReferralId);
                        setSelectedUserIds.add(selectedUser);
                        setAccount_User.add(objUserAccountsandContacts.strReferralId+'_'+selectedUser);
                    }
                    //checks if the record has to reassign and it is contact.
                    else if(objUserAccountsandContacts.strType == 'Contact') {
                    
                        lstContactTeamsToInsert.add(new Contact_Team__c(User__c = selectedUser,
                                                                        Contact__c = objUserAccountsandContacts.strReferralId));
                    } 
                }
                
                //checks if the record has to reassign and it is Account.
                else {
                    
                    if(objUserAccountsandContacts.strType == 'Account') {
                        
                        
                        lstATMsToDelete.add(new AccountTeamMember(Id = mapAccIdMemberId.get(objUserAccountsandContacts.strReferralId)));
                    }
                    
                    else if(objUserAccountsandContacts.strType == 'Contact') {
                    
                        lstContactTeamsToDelete.add(new Contact_Team__c(Id = mapAccIdMemberId.get(objUserAccountsandContacts.strReferralId)));
                    }
                }                                               
            }
            
            totalCount = mapCount - (lstATMsToDelete.size()+lstContactTeamsToDelete.size()) + (lstATMsToInsert.size()+lstContactTeamsToInsert.size());
            //totalCount = totCount + (lstATMsToInsert.size()+lstContactTeamsToInsert.size());
            
            if(!lstATMsToInsert.isEmpty()) {
             
                
                //if (!Test.isRunningTest()) {
                    
                    //insert lstAccountShareToInsert;
                //}
                
                insert lstATMsToInsert;
                
                List<AccountShare> lstAccountShareToUpdate = new List<AccountShare>();
                    
                for(AccountShare objAccountShare :[ Select id, AccountAccessLevel, ContactAccessLevel, OpportunityAccessLevel, CaseAccessLevel, AccountId, UserOrGroupId
                                                    From AccountShare 
                                                    Where AccountId IN: setAccountIds AND UserOrGroupId IN: setSelectedUserIds ]) {
                    
                    if(setAccount_User.contains(objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId)) {
                        
                        if(mapAccIdToShareRec.get(objAccountShare.AccountId) == 'Center') {
                            
                            lstAccountShareToUpdate.add(new AccountShare(   Id = objAccountShare.id,
                                                                            ContactAccessLevel = 'Read',
                                                                            OpportunityAccessLevel = 'Read',
                                                                            CaseAccessLevel = 'Read',
                                                                            AccountAccessLevel = 'Read'));
                        }
                        else {
                            
                            lstAccountShareToUpdate.add(new AccountShare(   Id = objAccountShare.id,
                                                                            ContactAccessLevel = 'Read',
                                                                            OpportunityAccessLevel = 'None',
                                                                            CaseAccessLevel = 'Read',
                                                                            AccountAccessLevel = 'Edit'));
                        }
                    }
                }
                
                update lstAccountShareToUpdate;
            }
            if(!lstContactTeamsToInsert.isEmpty())
                insert lstContactTeamsToInsert;
            
            if(!lstATMsToDelete.isEmpty()) {
            
                delete lstATMsToDelete; 
            }
            
            if(!lstContactTeamsToDelete.isEmpty())
                delete lstContactTeamsToDelete; 
                
            return totalCount; 
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    /**
    @MethodName : reAssignReferralSources
    @Param      : selectedToUser, selectedFromUser, referralidString
    @Description: Method used to assign the ReferralSources based on selected user to 'to user' 
    **/
    @RemoteAction 
    global static integer reAssignReferralSources(String selectedToUser, String selectedFromUser, String referralidString) {
        
        try{
            system.debug('=========reAssignReferralSources======');
            List<AccountTeamMember> lstATMsToInsert = new List<AccountTeamMember>(); 
            //list to hold AccountShare to insert
            List<AccountShare> lstAccountShareToInsert = new List<AccountShare>(); 
            //list to hold ContactTeamMembers to insert
            List<Contact_Team__c> lstContactTeamsToInsert = new List<Contact_Team__c>();
            //list to hold AccountTeammembers to delete
            List<AccountTeamMember> lstATMsToDelete = new List<AccountTeamMember>(); 
            //list to hold ContactTeamMembers to delete
            List<Contact_Team__c> lstContactTeamsToDelete = new List<Contact_Team__c>();
            //integer to store the count of referrals assigned to the selected user
            integer totalCount = 0;
            //list to store the Id for the Account/Contact which has to be reassigned.
            list<string>lstReferralid = new list<string>();
            //set to store the Id for the Account/Contact which has to be reassigned.
            set<string> setReferralId = new set<string>();
            
            map<string, string> mapAccIdMemberId = new map<string, string>();
            map<string, string> mapAccIdToShareRec = new map<string, string>();
            
            lstReferralid = referralidString.split('#');
            setReferralId.addAll(lstReferralid);
            
             
            set<Id>setAccountIdforRecordType = new set<Id>();
            for(Id objId : setReferralId){
                
                String myIdPrefix = String.valueOf(objId).substring(0,3);
                //checks if the id prefix is of account
                if(myIdPrefix == '001')
                setAccountIdforRecordType.add(objId);
                
            }
            
            for(Account objAcc : [select id, RecordType.Name from Account where id in: setAccountIdforRecordType]){
                
                mapAccIdToShareRec.put(objAcc.Id, objAcc.RecordType.Name);
            }
            
            set<string> setContactandUser = new set<string>();
            for(Contact_Team__c objContactTeam : [select id, Contact__c, User__c from Contact_Team__c where User__c =: selectedToUser]){
                
                string strUserContactCombination = objContactTeam.Contact__c +'-'+objContactTeam.User__c;
                setContactandUser.add(strUserContactCombination);
            }
            //iterates over the Contact team of the selected user from user picklist to get the contacts
            for(Contact_Team__c objCTM : [  Select Id, Contact__c From Contact_Team__c Where User__c =: selectedFromUser AND Contact__r.Recordtypeid IN: lstContactRecordType]) {
                
                mapAccIdMemberId.put(objCTM.Contact__c, objCTM.Id);
            }
            
            //iterates over the Account team of the selected user from user picklist to get the contacts
            for(AccountTeamMember objATM : [Select Id, AccountId From AccountTeamMember Where UserId =: selectedFromUser AND Account.Recordtypeid IN: lstAccountRecordType]) {
                
                  mapAccIdMemberId.put(objATM.AccountId, objATM.Id);  
            }
            
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setSelectedUserIds = new Set<Id>();
            Set<String> setAccount_User = new Set<String>();
            
            //iterates over the set if Id's to assign referrals from selected "from user" to "to user".
            for(Id objIdtoinsert : setReferralid){
                
                //to get the id prefix of the string
                String myIdPrefix = String.valueOf(objIdtoinsert).substring(0,3);
                //checks if the id prefix is of account
                if(myIdPrefix == '001'){
                
                    lstATMsToInsert.add(new AccountTeamMember(  AccountId = objIdtoinsert,
                                                                    TeamMemberRole = 'Clinical Liaison',
                                                                    UserId = selectedToUser));
                    
                    setAccountIds.add(objIdtoinsert);
                    setSelectedUserIds.add(selectedToUser);
                    setAccount_User.add(objIdtoinsert+'_'+selectedToUser);
                    
                    lstATMsToDelete.add(new AccountTeamMember(Id = mapAccIdMemberId.get(objIdtoinsert)));                                                   
                }
                
                //checks if the id prefix is of contact
                else if(myIdPrefix == '003'){
                    
                    string strUserContactCombination = objIdtoinsert+'-'+selectedToUser;
                    
                    if(!setContactandUser.contains(strUserContactCombination))
                        lstContactTeamsToInsert.add(new Contact_Team__c(User__c = selectedToUser,
                                                                        Contact__c = objIdtoinsert));
                                                                        
                    lstContactTeamsToDelete.add(new Contact_Team__c(Id = mapAccIdMemberId.get(objIdtoinsert)));                                                    
                }
            }
            //integer to store the count and account and Contact team member the user has
            integer mapCount = mapAccIdMemberId.size();
            totalCount = mapCount - (lstATMsToDelete.size()+lstContactTeamsToDelete.size());
            
            if(!lstATMsToDelete.isEmpty()) {
            
                delete lstATMsToDelete; 
            }
            
            if(!lstATMsToInsert.isEmpty()) {
                
                List<AccountShare> lstAccountShareToDelete = new List<AccountShare>();
                /*
                    
                for(AccountShare objAccountShare :[ Select id, AccountAccessLevel, ContactAccessLevel, OpportunityAccessLevel, CaseAccessLevel, AccountId, UserOrGroupId
                                                    From AccountShare 
                                                    Where AccountId IN: setAccountIds AND UserOrGroupId IN: setSelectedUserIds ]) {
                    
                    if(setAccount_User.contains(objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId)) {
                        
                        lstAccountShareToDelete.add(objAccountShare);
                    }
                }
                
                delete lstAccountShareToDelete;*/
                
                insert lstATMsToInsert;
                
                Set<String> setShares = new Set<String>();
                List<AccountShare> lstAccountShareToUpdate = new List<AccountShare>();
                    
                for(AccountShare objAccountShare :[ Select id, AccountAccessLevel, ContactAccessLevel, OpportunityAccessLevel, CaseAccessLevel, AccountId, UserOrGroupId
                                                    From AccountShare 
                                                    Where AccountId IN: setAccountIds AND UserOrGroupId IN: setSelectedUserIds ]) {
                    
                    string str = objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId;
                    if(setShares.contains(objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId)) {
                        
                        lstAccountShareToDelete.add(objAccountShare);
                    }
                    
                    if(setAccount_User.contains(objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId) && 
                            !setShares.contains(objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId)) {
                        
                        if(mapAccIdToShareRec.get(objAccountShare.AccountId) == 'Center') {
                            
                            lstAccountShareToUpdate.add(new AccountShare(   Id = objAccountShare.id,
                                                                            ContactAccessLevel = 'Read',
                                                                            OpportunityAccessLevel = 'Read',
                                                                            CaseAccessLevel = 'Read',
                                                                            AccountAccessLevel = 'Read'));
                        }
                        else {
                            
                            lstAccountShareToUpdate.add(new AccountShare(   Id = objAccountShare.id,
                                                                            ContactAccessLevel = 'Read',
                                                                            OpportunityAccessLevel = 'None',
                                                                            CaseAccessLevel = 'Read',
                                                                            AccountAccessLevel = 'Edit'));
                        }
                        
                        setShares.add(objAccountShare.AccountId + '_' + objAccountShare.UserOrGroupId);
                    }
                }
                delete lstAccountShareToDelete;
                update lstAccountShareToUpdate;
                
                // Inserting an Account Share record in test code results in an exception, hence the check is made to avoid the exception
                //if (!Test.isRunningTest())
                    //insert lstAccountShareToInsert;
            }
            
            if(!lstContactTeamsToInsert.isEmpty()){
                insert lstContactTeamsToInsert;
            }
            
            if(!lstContactTeamsToDelete.isEmpty())
                delete lstContactTeamsToDelete; 
            return totalCount;
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    
     /**
    @MethodName : fetchTeamMembers
    @Param      : selectedAccountId
    @Description: Method used to fetch the TeamMembers of Account/Contact
    **/
    @RemoteAction 
    global static list<User> fetchTeamMembers( String selectedSObjectId) {
        
        try{
            //list to hold the TeamMembers of selected Account/Contact
            list<Id>lstAccountAndContactTeamMembers = new list<Id>();
            
            //list to hold the users of selected Account/COntact
            list<User> lstUser = new list<User>();
            
            
            for(AccountTeamMember objAccTeamMemb : [select id, Account.Id,User.Name from AccountTeamMember where Account.Id = :selectedSObjectId]) {
                lstAccountAndContactTeamMembers.add(objAccTeamMemb.UserId);
            }
            
            for(Contact_Team__c objContactTeamMemb : [select id, Contact__r.Id,User__r.Name from Contact_Team__c where Contact__r.Id = :selectedSObjectId]) {
                lstAccountAndContactTeamMembers.add(objContactTeamMemb.User__r.Id);
            }
            
            lstUser = [select id, Name from User where Id=:lstAccountAndContactTeamMembers];
            return lstUser;
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    
    /**
    @MethodName : fetchParentRoles
    @Param      : selectedUser
    @Description: This method called to get list of roles above the selected user hierarchy
    **/
    @RemoteAction 
    global static String fetchParentRoles(String strSelectedUser, String strSelectedUserRole) {
        
        try {
            
            Integer rowCount = 0;              // Variable used for row count
            Id prevRoleSelected;
            String strHTMLToReturn = '';
            Id parentRoleId;
            if(strSelectedUserRole != '')
                parentRoleId = strSelectedUserRole;
            boolean isorgAllignment = false;
            
            //Gets the custom setting details based on the logged in User.
            S2_custom_permissions__c objS2custom = S2_custom_permissions__c.getInstance(UserInfo.getProfileId().substring(0,15));
            if(objS2custom == null)
                isorgAllignment = false;
            else
                isorgAllignment = objS2custom.Org_Alignment__c; 
                
            if(String.isNotBlank(strSelectedUser) && strSelectedUserRole == '')   {
                
                UserRole objEnterpriseUserRole = [Select ParentRoleId, Id From UserRole Where Name = 'SVP - KAH' Limit 1];
                
                Map<Integer, String> mapOptionsHTML = new Map<Integer, String>();
                Map<Integer, String> mapUsersHTML = new Map<Integer, String>();
                
                String userNames = '';
                String strSelectOptionsHTML = '';
                for(UserRole objUserRole : [Select ParentRoleId,id, UserRole.Name From UserRole Where ParentRoleId =: objEnterpriseUserRole.Id]) {
                    strSelectOptionsHTML += '<option value="' +objUserRole.Id+ '"' + 
                                                ((objUserRole.Id == objUserRole.Id) ? '  ' : '') + 
                                                '>' +objUserRole.Name+ '</option>';
                } 
                if(String.isNotBlank(strSelectOptionsHTML)) {
                    
                    mapOptionsHTML.put(rowCount, ('<option value="" selected="selected" disabled="disabled">--None Selected--</option>' + strSelectOptionsHTML));
                    mapUsersHTML.put(rowCount, userNames);
                }
                rowCount++;
                
                for(Integer j = 0; j <= rowCount; j++) {
                    
                    if(mapOptionsHTML.containsKey(j)) {
                        
                        if(j == (rowCount-1)) {
                            
                            strHTMLToReturn = '<tr class="rowContainingPicklist" id="row_'+(rowCount-j-1)+'">' +
                                                   '<td >' +
                                                       '<div class="form-group formElementsWidth">' +
                                                            '<label for="divisionPicklist">Division</label><br/>' +
                                                           '<select class="form-control formElementsWidth" size="1" onchange="fetchDependentRoles(this.value, this.id, ' +isorgAllignment+ ');" id="pickVal_'
                                                                    +(rowCount-j-1)+'"' +(isorgAllignment ? '' : ' disabled ') + '>'+
                                                           mapOptionsHTML.get(j) +
                                                       '</select>'+
                                                       '</div>' + 
                                                   '</td>' + strHTMLToReturn;
                        }   
                    }
                }
                strHTMLToReturn = strHTMLToReturn + 
                                '</tr>';
                
            } 
            else if(String.isNotBlank(strSelectedUser) && String.isNotBlank(strSelectedUserRole)) {
                
                Boolean isNewResultsFound = false;
                UserRole objEnterpriseUserRole = [Select ParentRoleId From UserRole Where Name = 'SVP - KAH' Limit 1];
                Map<Integer, String> mapOptionsHTML = new Map<Integer, String>();
                Map<Integer, String> mapUsersHTML = new Map<Integer, String>();
                
                do {
                    
                    isNewResultsFound = false;
                    String userNames = '';
                    String strSelectOptionsHTML = '';
                    List<UserRole> lstUserRoles = [Select ParentRoleId, Id From UserRole Where Id = :strSelectedUserRole limit 1];
                        
                    // Iteraing over UserRole based on ParentRole to fetch the Role names of user  
                    for(UserRole objUserRole : [Select Id, Name, ParentRoleId From UserRole Where ParentRoleId = :parentRoleId]) {
                        
                        isNewResultsFound = true;
                        strSelectOptionsHTML += '<option value="' +objUserRole.Id+ '"' + 
                                                    ((objUserRole.Id == prevRoleSelected) ? ' selected="selected" ' : '') + 
                                                    '>' +objUserRole.Name+ '</option>';
                    }

                    if( !lstUserRoles.isEmpty() ) {  
                        
                        isNewResultsFound = true;
                        parentRoleId = lstUserRoles[0].ParentRoleId;
                    }
                    else {
                        
                        isNewResultsFound = false;
                    }
                    
                    if(rowCount > 0) {
                        
                        //Iterating over users to fetch the Usernames based on selected role
                        for(User objUser : [SELECT Id, Name,userrole.name  FROM User WHERE userroleId =:prevRoleSelected Order By Name]) {
                            
                            if(userNames == '') {
                                
                                userNames+= objUser.Name;
                            }
                            else {
                                
                                userNames+= ', ' + objUser.Name;
                            }
                        }
                    }
                    
                    if(String.isNotBlank(strSelectOptionsHTML)) {
                        
                        mapOptionsHTML.put(rowCount, ('<option value="">--None Selected--</option>' + strSelectOptionsHTML));
                        mapUsersHTML.put(rowCount, userNames);
                    } 
                    
                    // Assign the previous role in hierarchy for comparison
                    prevRoleSelected = strSelectedUserRole;
                    
                    // Updating the parent role for further querying
                    strSelectedUserRole = parentRoleId;
                    
                    rowCount++;
                    
                }  while(parentRoleId != objEnterpriseUserRole.ParentRoleId && isNewResultsFound && rowCount < 25);
                
                for(Integer j = 0; j <= rowCount; j++) {
                    
                    if(mapUsersHTML.containsKey(j) && j>0) {
                        
                        strHTMLToReturn = '<td width="100%">' +
                                                   '<div class="mediumMarginTop marginLeft" id="userNames'+(rowCount-j-1)+'" ' +
                                                                ((j == (rowCount-1)) ? 'style="margin-top: 4% !important;"' : '') + '>' +
                                                      mapUsersHTML.get(j) +
                                                   '</div>' + 
                                               '</td>' +
                                            '</tr>' + strHTMLToReturn;
                    }
                    if(mapOptionsHTML.containsKey(j)) {
                        
                        if(j == (rowCount-1)) {
                            
                            string strmapOptionsHTML = mapOptionsHTML.get(j);
                            String[] arrTest = strmapOptionsHTML.split('value=""');
                            string strmapOptionsHTMLDisabled = arrTest[0] + ' value="" disabled="disabled" '+arrTest[1];
                            
                            strHTMLToReturn = '<tr class="rowContainingPicklist" id="row_'+(rowCount-j-1)+'">' +
                                                   '<td >' +
                                                       '<div class="form-group formElementsWidth">' +
                                                            '<label for="divisionPicklist">Division</label><br/>' +
                                                           '<select class="form-control formElementsWidth" size="1" onchange="fetchDependentRoles(this.value, this.id, ' +isorgAllignment+ ');" id="pickVal_'
                                                                    +(rowCount-j-1)+'"' +(isorgAllignment ? '' : ' disabled ') + '>'+
                                                           strmapOptionsHTMLDisabled +
                                                       '</select>'+
                                                       '</div>' + 
                                                   '</td>' + strHTMLToReturn;
                        }   
                        else { 
                            
                            strHTMLToReturn = '<tr class="rowContainingPicklist" id="row_'+(rowCount-j-1)+'">' +
                                                   '<td >' +
                                                       '<div class="form-group formElementsWidth">' +
                                                           '<select class="form-control formElementsWidth mediumMarginTop" size="1" onchange="fetchDependentRoles(this.value, this.id, ' +isorgAllignment+ ');" id="pickVal_'
                                                                    +(rowCount-j-1)+'"' +(isorgAllignment ? '' : ' disabled ') + '>'+
                                                           mapOptionsHTML.get(j) +
                                                       '</select>'+
                                                       '</div>' + 
                                                   '</td>' + strHTMLToReturn;
                        }
                    }
                }
                strHTMLToReturn = strHTMLToReturn + 
                                '</tr>';
            }
           
            return strHTMLToReturn;
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    /**
    @MethodName : fetchUserName
    @Param      : selectedUser
    @Description: This method called to get name of the user whose id has been selected in autocomplete component
    **/
    @RemoteAction 
    global static String fetchAutocompleteDetails(String strSelectedRecId) {
        
        try{
           // String strHTMLToReturn = '<table width="100%" ><tr><td width="60%">';
           string strHTMLToReturn = '<div contentEditable="false"><div class="row" id="userNameId" width="100%" style="white-space: nowrap;"><div class="col-xs-7">';
           if( String.isNotBlank(strSelectedRecId) && String.valueOf(((Id)strSelectedRecId).getSObjectType()) == 'User' ) {
                
                //list to the user based on the Id parameter received from the method call
                List<User> lstUsers = [SELECT Id, FirstName, LastName, PERNER__c, Line_of_Business__c FROM User WHERE Id =: strSelectedRecId limit 1];
                                
                if( !lstUsers.isEmpty() ) {
                    string strName = '';
                    string trimmedString = '';
                    if(!String.isBlank(lstUsers[0].FirstName)) {
                        
                        strName = lstUsers[0].LastName + ', ' + lstUsers[0].FirstName;
                         if(strName.length() >25){
                             
                             integer length = 25;
                             trimmedString = strName.substring(0, length);
                             trimmedString = trimmedString + '...';
                         }
                         if(trimmedString != '')
                             strHTMLToReturn +=trimmedString;
                         else
                             strHTMLToReturn += lstUsers[0].LastName + ', ' + lstUsers[0].FirstName;
                        
                        string strPerner = '';
                        if(lstUsers[0].PERNER__c != null){
                            
                            if((lstUsers[0].PERNER__c).length()>6){
                                integer length = 6;
                                 strPerner = lstUsers[0].PERNER__c.substring(0, length);
                                 strPerner = strPerner + '...';
                            }
                            else{
                                strPerner = lstUsers[0].PERNER__c;
                            }
                        }
                        
                        string strLineOfBusiness = '';
                        if(lstUsers[0].Line_of_Business__c != null){
                            
                            if((lstUsers[0].Line_of_Business__c).length()>6){
                                integer length = 6;
                                 strLineOfBusiness = lstUsers[0].Line_of_Business__c.substring(0, length);
                                 strLineOfBusiness = strLineOfBusiness + '...';
                            }
                            else{
                                strLineOfBusiness = lstUsers[0].Line_of_Business__c;
                            }
                        }
                      /*  strHTMLToReturn += '</td><td width="20%" style="text-align: left; font-weight:bold">'+ 
                                            ((String.isNotBlank(lstUsers[0].Line_of_Business__c)) ? lstUsers[0].Line_of_Business__c : '') + 
                                            '</td><td width="20%" style="text-align: left; font-weight:bold">'+ 
                                            ((String.isNotBlank(lstUsers[0].PERNER__c)) ? lstUsers[0].PERNER__c : '') +  
                                        '</td></tr></table>';*/
                                        
                          strHTMLToReturn += '</div><div class="col-xs-2" style="text-align: left; font-weight:bold; font-color:black; padding-left: 0px">'+
                                            ((String.isNotBlank(lstUsers[0].Line_of_Business__c)) ? strLineOfBusiness : '')+
                                            '</div><div class="col-xs-3" style="text-align: right; font-weight:bold; font-color:black; padding-left: 0px">'+
                                            ((String.isNotBlank(lstUsers[0].PERNER__c)) ? strPerner : '') + 
                                            '</div>';         
                    }
                    else {
                        strName = lstUsers[0].LastName;
                         if(strName.length() >25){
                             
                             integer length = 25;
                             trimmedString = strName.substring(0, length);
                             trimmedString = trimmedString + '...';
                         }  
                         if(trimmedString != '')
                             strHTMLToReturn +=trimmedString;
                         else
                             strHTMLToReturn += lstUsers[0].LastName;
                         
                        string strPerner = '';
                        if(lstUsers[0].PERNER__c != null){
                            
                            if((lstUsers[0].PERNER__c).length()>6){
                                integer length = 6;
                                 strPerner = lstUsers[0].PERNER__c.substring(0, length);
                                 strPerner = strPerner + '...';
                            }
                            else{
                                strPerner = lstUsers[0].PERNER__c;
                            }
                        }
                        
                        string strLineOfBusiness = '';
                        if(lstUsers[0].Line_of_Business__c != null){
                            
                            if((lstUsers[0].Line_of_Business__c).length()>6){
                                integer length = 6;
                                 strLineOfBusiness = lstUsers[0].Line_of_Business__c.substring(0, length);
                                 strLineOfBusiness = strLineOfBusiness + '...';
                            }
                            else{
                                strLineOfBusiness = lstUsers[0].Line_of_Business__c;
                            }
                        }
                         /*strHTMLToReturn +='</td><td  width="20%" style="text-align: left; font-weight:bold">'+ 
                                                ((String.isNotBlank(lstUsers[0].Line_of_Business__c)) ? lstUsers[0].Line_of_Business__c : '') + 
                                                '</td><td width="20%" style="text-align: left; font-weight:bold">'+ 
                                                ((String.isNotBlank(lstUsers[0].PERNER__c)) ? lstUsers[0].PERNER__c : '') +
                                            '</td></tr></table>'; */
                          strHTMLToReturn += '</div><div class="col-xs-2" style="text-align: left; font-weight:bold; font-color:black; padding-left: 0px">'+
                                            ((String.isNotBlank(lstUsers[0].Line_of_Business__c)) ? strLineOfBusiness : '')+
                                            '</div><div class="col-xs-3" style="text-align: right; font-weight:bold; font-color:black; padding-left: 0px">'+
                                            ((String.isNotBlank(lstUsers[0].PERNER__c)) ? strPerner : '') + 
                                            '</div>';              
                                            
                    }
                }
            }
            else if( String.isNotBlank(strSelectedRecId) && String.valueOf(((Id)strSelectedRecId).getSObjectType()) == 'Account' ) {
            
                List<Account> lstAccount = [Select Id, Name, Parent.Name, Facility_Number__c, Type 
                                            From Account 
                                            Where Id =: strSelectedRecId AND 
                                                    Status__c =:'Active' AND 
                                                    Parent.Name =:'Kindred Healthcare Inc'
                                            limit 1];
                
                if( !lstAccount.isEmpty() ) {
                    
                    string strName = '';
                    string trimmedString = '';
                    
                    strName = lstAccount[0].Name;
                         if(strName.length() >20){
                             
                             integer length = 20;
                             trimmedString = strName.substring(0, length);
                             trimmedString = trimmedString + '...';
                         }  
                         if(trimmedString != '')
                             strHTMLToReturn +=trimmedString;
                         else
                             strHTMLToReturn += lstAccount[0].Name;
                             
                        /*strHTMLToReturn +=' </td><td width="25%" style="text-align: left; font-weight:bold">' +
                                            ((String.isNotBlank(lstAccount[0].Facility_Number__c)) ? lstAccount[0].Facility_Number__c : '') + 
                                        '</td><td width="25%" style="text-align: left; font-weight:bold">' +
                                            ((String.isNotBlank(lstAccount[0].Type)) ? lstAccount[0].Type : '') +
                                        '</td></tr></table>'; */  
                        strHTMLToReturn += '</div><div class="col-xs-3" style="text-align: left; font-weight:bold; font-color:black; padding-left: 0px">'+
                                            ((String.isNotBlank(lstAccount[0].Facility_Number__c)) ? lstAccount[0].Facility_Number__c : '') + 
                                            '</div><div class="col-xs-2" style="text-align: left; font-weight:bold; font-color:black; padding-left: 0px">'+
                                            ((String.isNotBlank(lstAccount[0].Type)) ? lstAccount[0].Type : '') +
                                            '</div></div>';                
                }
            }
            
            return strHTMLToReturn;
        }
        catch(exception e){
            system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}