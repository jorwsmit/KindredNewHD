trigger AA_LeadTrigger on Lead (after delete, after insert, after update) {
   
    List<Merge__c> newMergeRows = new List<Merge__c>();
    
    Integer maxRecordsToGeocode = 10;
    
    //Lead geoCoding
    //Future methods cannot be called from a future or batch method
    if(trigger.isAfter && !System.isBatch() && !System.isFuture() &&(trigger.isInsert || trigger.isUpdate)) {
    	List<Id> idsToGeocode = new List<Id>();
    	//Get ids for some records to geocode, up to max
    	//(note due to callout and future limits this trigger may not attempt to geocode all records passed in)
    	for(Lead x : Trigger.new) {
    		if(Trigger.isInsert && !x.IsConverted) {
    			//Want to geocode any newly created record, regardless
    			idsToGeocode.Add(x.Id);	
    		}
    		else if(Trigger.isUpdate && !x.IsConverted) {
    			//Only geocode an updated record if an address field has changed
            	Lead old = Trigger.oldMap.get(x.Id);
	        
	            if(old.Street != x.Street || 
	                old.City != x.City ||
	                old.State != x.State ||
	                old.PostalCode != x.PostalCode ||
	                old.Country != x.Country){
	                    idsToGeocode.Add(x.Id);	
	                	}
    			}
    		//Ensure we're within our predetermined limit
    		if(idsToGeocode.size()>=maxRecordsToGeocode){
    			break;
    			}
    		}
    	LeadGeocodeCallout.doGeocodeRecords(idsToGeocode);
    	}
    
    //After Delete during a merge operation
    if(trigger.isAfter && trigger.isDelete){
    	for(Lead x : trigger.old) {
        	if(String.isNotBlank(x.MasterRecordId)) { 
    	        newMergeRows.add(new Merge__c(LoserId__c = x.Id, WinnerId__c = x.MasterRecordId));  
        		}         
    		}
    	if(newMergeRows.size() > 0) {
        	insert newMergeRows;
    		}
    	}

}