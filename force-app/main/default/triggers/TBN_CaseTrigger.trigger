trigger TBN_CaseTrigger on Case (After Insert, After Update, After Delete, Before Insert) {
    
    TBN_CaseTriggerHandler objHandler = new TBN_CaseTriggerHandler();
    
    // If Trigger is fired in After Context
    if(Trigger.isAfter) {
        
        // Case record inserted
        if(Trigger.isInsert) {
            
            objHandler.onAfterInsert(trigger.newMap);
        }
        // Case Record Update
        else if(Trigger.isUpdate) {
            
            objHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        } 
        
        // Case record Delete 
        if(Trigger.isDelete) {
            
            objHandler.onAfterDelete(trigger.oldMap);
        }
    }
    
    // If Trigger is fired in Before Context
    if(Trigger.isBefore) {
        
        if(Trigger.isInsert) {
            
           objHandler.onBeforeInsert(trigger.new);
        }
    }
}