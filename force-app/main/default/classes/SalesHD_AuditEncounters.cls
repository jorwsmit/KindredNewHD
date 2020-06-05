public with sharing class SalesHD_AuditEncounters {

    private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});


    public SalesHD_AuditEncounters() {

        

    }

    public List<Event> getEncounters(){
        return [select SalesHD_Call_Objective__c, Who.Name, Who.Title, StartDateTime, SalesHD_Encounter_Audit__c
        from event where owner.userRoleId in :allSubRoleIds
        and startDateTime=Last_Week];
    }
    

    private static set<Id> getSubRoleIds(set<Id> roleIds) {
        set<Id> returnRoleIds = new set<Id>();
        for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
            returnRoleIds.add(r.Id);
        }
        if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
        return returnRoleIds;
    }

}
