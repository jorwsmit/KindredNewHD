trigger SalesHD_EventTrigger on Event (before delete) {
    Set<id> eventIds = new Set<id>();
    for(Event e : Trigger.Old){
        if(!eventIds.contains(e.Id)) eventIds.add(e.Id);
    }
    List<Account_Event__c> aes = [select id from Account_Event__c where Event_ID__c in :eventIds];
    if(!aes.isEmpty()) delete aes;
}