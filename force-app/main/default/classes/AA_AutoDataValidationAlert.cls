public class AA_AutoDataValidationAlert {

    public static void searchRecords() {
        list<Account> accs = new list<Account>();
        list<Contact> ctcs = new list<Contact>();
        set<ID> ids = new set<ID>(); 
        set<User> userSet = new set<User>();
        list<User> users = new list<User>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        list<string> exclusionOwners = new list<string>();
        exclusionOwners.add('0051300000C41YU'); //All Users - Admin Maintenance
        exclusionOwners.add('00530000003TUiB'); //Charles Cox
        exclusionOwners.add('00530000003VrT0'); //Integration User
        exclusionOwners.add('00530000005s9PC'); //Brian Seong
        exclusionOwners.add('005a0000007hkj8'); //Marketo Integration
        exclusionOwners.add('005a000000Ad52s'); //All Users
        
        accs = [SELECT OwnerID, Name, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE (ShippingCity = null OR ShippingState = null OR ShippingPostalCode = null) AND RecordType.ID ='01230000000Khh2'];
    	ctcs = [SELECT OwnerID, Name, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE (MailingCity = null OR MailingState = null OR MailingPostalCode = null) AND RecordType.ID = '01230000000Khno'];
    	
    	for(Account a: accs){
    		ids.add(a.OwnerID);
    		}
    	for(Contact c: ctcs){
    		ids.add(c.OwnerID);
    		}
    		
    	users = [SELECT ID, Email, isActive, Name, Manager.Email, Manager.isActive, Manager.ID FROM User WHERE ID IN: ids];
    	userSet.addAll(users);		    	
    	string subject = 'Notification of invalid record data';
    	string sendEmail;
    	string addressee = '';
    	for(User u: userSet){
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		string userID = '';
    		if(u.isActive == true && !exclusionOwners.contains(u.Id) && u.Email != null){
    			sendEmail = u.Email;
    			userID = u.ID;
    			addressee = u.Name;
    			}
    		else if(u.Manager.Email != null && u.Manager.isActive == true && !exclusionOwners.contains(u.Manager.ID)){
    				sendEmail = u.Manager.Email;
    				userID = u.ID;
    				addressee = u.Manager.Name;
    				}
    		else{
    			sendEmail = 'RMB_Sales_Support@kindred.com';
    			userID = u.ID;
    			addressee = 'Admin';
    			}			
    		
    		string htmlBody = 'Hello ' + u.Name + ', <br>' 
    		+ 'You are receiving this notification because you are listed as the owner of'
    		+ ' Account or Contact records with invalid data, or have been designated the recipient for a user of such that is no longer active.<br/>'
    		+ 'In this case, invalid data refers to missing contact informaiton for the record in question, such as city, state, and zip missing from an applicable contact address.<br/>'
    		+ 'If the issue is not remediated, the record will be deleted, so please address promptly.<br/>'
    		+ 'You can view a report containing all records in question to see what they\'re missing by clicking <a href="https://kindred.my.salesforce.com/00O1B000008d3K5?pv0='+u.Name+'" target="_blank">here</a> for Accounts and <a href="https://kindred.my.salesforce.com/00O1B000008d3K6?pv0='+u.Name+'" target="_blank">here</a> for contacts.<br/>'
    		+ 'Thanks for your assistance with this.';

            System.debug('Email Body: ' + htmlBody);
            // Build Email
            String[] toAddresses = new String[] {};
            toAddresses.add(sendEmail);                             
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mailList.add(mail);
    		
    		}
    		
    	 if(mailList != null && mailList.size() != 0){
         	system.debug('mailList' + mailList);
            Messaging.sendEmail(mailList,true);
            }	
    	
    	}
}