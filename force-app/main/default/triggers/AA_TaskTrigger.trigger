trigger AA_TaskTrigger on Task (before insert, before update, after delete, after insert, after update) {
   
    map<ID, Task> accLst = new map<ID, Task>();
    
    list<String> typeList = new list<String>();
    
    List<ID> noDelete = new list<ID>();
	//SRS Finance
	noDelete.add('00e1B000001p1wJ');
	//SRS User
	noDelete.add('00e1B000001p1wK');
    
    typeList.Add('Face to Face/ In Person');
    typeList.Add('In services');
    typeList.Add('Letter');
    typeList.Add('Needs Analysis/Account Strategies');
    typeList.Add('Other');
    typeList.Add('Prepare Presentation');
    typeList.Add('Referral Source Meeting');
    typeList.Add('Sales Team Meeting');
    typeList.Add('Phone Call');
    typeList.Add('Call');
    typeList.Add('Inbound Phone Call');
    
    	
    if(trigger.isAfter){
    	if(trigger.isInsert){
    		list<ID> toUpdatePF = new list<ID>();
    		for(Task tsk: trigger.new){
    			if(tsk.RecordTypeID == '0121B000001CGNN' && tsk.Subject.contains('NPS Survey')){
                	toUpdatePF.add(tsk.Id);
                	}
    			}
    			system.debug('toUpdate: ' + toUpdatePF);
    			AA_PFTaskProcessor.updateTaskRecords(toUpdatePF);
    		}
    	}
    if(Trigger.isBefore){
    	if(Trigger.isInsert || Trigger.isUpdate){
            //Map Sales_Performance_ID__c (OwnerId + MM + YYYY) to Tasks
            Map<String, Task> salesPerfIdsToTasks = new Map<String, Task>();
            Set<String> spIds = new Set<String>();
            
            Set<Id> ownerIds = new Set<Id>();
            Map<Id, ID> ownerIdsToProfileNames= new Map<Id, ID>();
            
            for(Task t : Trigger.new){
                if(!ownerIds.contains(t.ownerId)){
                    ownerIds.add(t.ownerId);
                    }
                }
            
            for(User u : [select Id, Profile.ID from user where id in :ownerIds]){
                ownerIdsToProfileNames.put(u.Id, u.Profile.ID);
                }
            
            Integer i=0;
            for(Task t : Trigger.new){
                                                                            //Sales_HD_Associate                                       //Sales_NCD_Associate
                if(t.Type != 'PTO' && (ownerIdsToProfileNames.get(t.ownerId) == '00ea0000001serv' || ownerIdsToProfileNames.get(t.ownerId) == '00e1300000225Lu')){
                    salesPerfIdsToTasks.put(t.OwnerId + mmyyyy(t.ActivityDate) + String.valueOf(i), t);
                    i++;
                    if(!spIds.contains(t.OwnerId + mmyyyy(t.ActivityDate))){
                        spIds.add(t.OwnerId + mmyyyy(t.ActivityDate));
                        }
                    }
                else{
                    t.Sales_Performance_ID__c = null;    
                    }
                }//end for loop updated and inserted Tasks
            
            List<Sales_Performance__c> salesPerfs = [select Id, Sales_Performance_ID__c, Sales_Calls__c from Sales_Performance__c
                                                     where Sales_Performance_ID__c in :spIds];
            Map<String, Id> invalidSpIdsToSpIds = new Map<String, Id>();
            
            for(String invalidSpId : salesPerfIdsToTasks.keySet()){
                for(Sales_Performance__c sp : salesPerfs){
                    if(sp.Sales_Performance_ID__c == invalidSpId.substring(0,24)){
                        invalidSpIdsToSpIds.put(invalidSpId, sp.Id);
                        }
                    }
                }
            for(String invalidSpId : salesPerfIdsToTasks.keySet()){
                Task t = salesPerfIdsToTasks.get(invalidSpId);
                t.Sales_Performance_ID__c = invalidSpIdsToSpIds.get(invalidSpId);
                }
            //The update below causes LengthOfRelatedActivitiesToSalesCalls to be triggered
            //LengthOfRelatedActivitiesToSalesCalls sets the Sales_Calls__c field 
            //to the number of tasks and Tasks related to that Sales_Performance__c object
            update salesPerfs;
            }
         if(trigger.isDelete){
         	for(Task t : trigger.new){
         		if(noDelete.contains(UserInfo.getProfileId())  && UserInfo.getProfileId() != t.OwnerID){
					t.addError('You do not have permission to delete events, only administrators are allowed, please contact an admin user if you need assistance.');
					}
         		}
         	}   
         } //End trigger.isBefore
     else{
        if(Trigger.isDelete){
            //list of Sales_Performance_c IDs based on deleted Tasks related Sales_Performance__c
            //System.debug('Number of Tasks deleted: '+Trigger.old.size());
            List<String> spIds = new List<String>();
            for(Task t : Trigger.old){
                if(t.Type != 'PTO'){
                    spIds.add(t.Sales_Performance_ID__c);
                    }
                }//end for loop old deleted Tasks
            //Query the Sales_Performance__c's from the list of Sales_Performance_c IDs
            List<Sales_Performance__c> salesPerfs = [select Id from Sales_Performance__c
                                                     where Id in :spIds];
            //The update below causes LengthOfRelatedActivitiesToSalesCalls to be triggered
            //LengthOfRelatedActivitiesToSalesCalls sets the Sales_Calls__c field 
            //to the number of tasks and Tasks related to that Sales_Performance__c object
            
            update salesPerfs;
            }//End if isDelete
          else if(Trigger.isInsert){
            //System.debug('Number of Tasks after update: '+Trigger.old.size()+Trigger.new.size());
            List<String> spIds = new List<String>();
            for(Task t : Trigger.new){
                if(t.Type != 'PTO'){    
                    spIds.add(t.Sales_Performance_ID__c);
                    }
                for(String s : typeList){
                        system.debug('Check: ' + s);
                        system.debug('Check Against: ' + t.Type);
                        if(s == t.Type){
                            accLst.put(t.WhatID, t);
                            }
                        }
                }
            List<Sales_Performance__c> newSalesPerfs = [select Id from Sales_Performance__c
                                                        where Id in :spIds];
            update newSalesPerfs;
            }//End if isInsert
         else if(Trigger.isUpdate){
            //System.debug('Number of Tasks after update: '+Trigger.old.size()+Trigger.new.size());
            List<String> spIds = new List<String>();
            for(Task t : Trigger.old){
                if(t.Type != 'PTO' && t.Sales_Performance_ID__c != null){    
                    spIds.add(t.Sales_Performance_ID__c);
                    }
                }
            for(Task t : Trigger.new){
                if(t.Type != 'PTO'){    
                    spIds.add(t.Sales_Performance_ID__c);
                    }
                }
            List<Sales_Performance__c> newSalesPerfs = [select Id from Sales_Performance__c
                                                        where Id in :spIds];
            update newSalesPerfs;
        }//end if Trigger is insert/update or delete/after update
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
    
     if(accLst.size() > 0){
        AA_TaskAndEventHelper.updateAccountsTask(accLst);
        }
}