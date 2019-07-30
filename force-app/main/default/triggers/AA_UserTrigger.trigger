trigger AA_UserTrigger on User (after insert, before update){
    
    final static id SALES_KAH_ASSOCIATE = '00e1300000225C9';
    final static id SALES_KAH_Market_Manager = '00e130000024QC8';
    final static id SALES_HD_Associate = '00ea0000001serv';
    final static id SALES_NCD_Associate = '00e1300000225Lu';
    
    map<ID, String> profileMap = new map<ID, String>();
    map<ID, String> roleMap = new map<ID, String>();
    list<Profile> pList = New list<Profile>();
    	pList = [SELECT ID, Name FROM Profile];
    	for(Profile up : pList){
    		profileMap.put(up.ID, up.Name);
    		}
    	list<UserRole> rList = New list<UserRole>();
    	rList = [SELECT ID, Name FROM UserRole];
    	for(UserRole ur : rList){
    		roleMap.put(ur.ID, ur.Name);
    		}
    
    if(trigger.isBefore && trigger.isUpdate){
    	for(integer i = 0; i < trigger.new.size(); i++){
    		if((trigger.new[i].isActive == false || trigger.new[i].UserRoleId == '00Ea0000001cb3t' || trigger.new[i].profileId == '00e1B00000286ux') && trigger.new[i].Previous_Role__c == null && trigger.new[i].Previous_Profile__c == null){
    			trigger.new[i].Previous_Role__c = roleMap.get(trigger.old[i].UserRoleId);
    			trigger.new[i].Previous_Profile__c = profileMap.get(trigger.old[i].profileId);
    			}
    		}
    	}
    
    if(trigger.isAfter && trigger.isInsert){
    	Map<String, String> SPIdToRecordTypeId = new Map<String, String>();
    	String KAHrecTypeId; String LegacyrecTypeId;
    	for(RecordType rt : [select Id, name from recordType where SobjectType = 'sales_performance__c' and (name = 'KAH' or name = 'Legacy')]){
        	if (rt.name == 'KAH') KAHrecTypeId = rt.Id;
        	if (rt.name =='Legacy') LegacyrecTypeId = rt.Id;
    		}
    
    	for(User u : [select id, profile.ID, perner__c from user where id in :Trigger.new]){
        	if(u.PERNER__c != null && (u.Profile.ID == SALES_KAH_ASSOCIATE || u.Profile.ID == SALES_KAH_Market_Manager || u.Profile.ID == SALES_HD_Associate || u.Profile.ID == SALES_NCD_Associate)){
            	for(Integer i=1; i<=12; i++){
                	String SPId = u.Id + mmyyyy(date.newinstance(System.now().year(), i, 1));
                	String RecTypeId;
                	if(u.Profile.ID == SALES_KAH_ASSOCIATE || u.Profile.ID == SALES_KAH_Market_Manager) RecTypeId = KAHrecTypeId;
                	else RecTypeId = LegacyrecTypeId;
                	SPIdToRecordTypeId.put(SPId, RecTypeId);
            		}  
        		}
    		}
    
    	for(Sales_Performance__c sp : [select Sales_Performance_Id__c from Sales_Performance__c where Sales_Performance_Id__c in :SPIdToRecordTypeId.keySet()]){
        	SPIdToRecordTypeId.remove(sp.Sales_Performance_Id__c);
    		}
    
    	if(SPIdToRecordTypeId.size() > 0){
        	Database.executeBatch(new Create12SalesPerf4NewUserBatch(SPIdToRecordTypeId));
    		}
    	}
    
    public static string mmyyyy(Date d){
        String mmyyyy;
        if (String.valueOf(d.month()).length() == 1){
            mmyyyy = '0'+String.valueOf(d.month())+String.valueOf(d.year());
        } else {
            mmyyyy = String.valueOf(d.month())+String.valueOf(d.year());
        }
        return mmyyyy;
    }//end mmyyyy
    
}