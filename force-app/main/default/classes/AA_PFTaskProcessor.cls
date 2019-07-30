public with sharing class AA_PFTaskProcessor {
    
    @Future 
    public static void updateTaskRecords(list<ID> toUpdatePF){
    	list<ID> conIDs = new list<ID>();
    	list<Task> taskList = new list<Task>();
    	//taskID, contactID
    	list<Task> toUpdate = new list<Task>();
    	map<ID, ID> processMap = new map<ID, ID>();
    	
    	system.debug('toUpdatePF: ' + toUpdatePF);
    	taskList = [SELECT ID, WhoID, PF_Product_Type__c, PF_NPS_Score__c FROM Task WHERE ID IN: toUpdatePF];
    	system.debug('taskList: ' + taskList);
    	try{
    	for(Task t: taskList){
    		conIDs.add(t.WhoID);
    		processMap.put(t.ID, t.WhoID);
    		}
    	system.debug('conIDs: ' + conIDs);
    	system.debug('processMap: ' + processMap);
    	
    	list<Contact> contacts = new list<Contact>();
    		contacts = [SELECT ID, Account.PF_Product_Type__c, PF_NPS_Rating__c FROM Contact WHERE ID IN: conIDs];
    	system.debug('Contacts: ' + contacts);
    	
    			for(ID tID : processMap.keyset()){
    				for(Task tk: taskList){
    		for(Contact c: contacts){
    				if(tk.ID == tID && processMap.get(tID) == c.ID){
    					tk.PF_Product_Type__c = c.Account.PF_Product_Type__c;
    					tk.PF_NPS_Score__c = c.PF_NPS_Rating__c;
    					toUpdate.add(tk);
    					}
    				}
    			}
    		
    		}
    		
    		if(toUpdate.size() > 0){
    			update toUpdate;
    			}
    		}
    	catch(Exception e){
    			system.debug('Error: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
    			}	
    		}
    		
    		
    		    
    
}