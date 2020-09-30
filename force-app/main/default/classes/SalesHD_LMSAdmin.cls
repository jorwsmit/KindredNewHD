public with sharing class SalesHD_LMSAdmin {

    public User selectedUser {get; set;}

    private static Set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});

public SalesHD_LMSAdmin() {

}

public static List<SelectOption> getUsers(){
	allSubRoleIds.add(UserInfo.getUserRoleId());

	List<Selectoption> picklist = new List<selectoption>();
	picklist.add(new selectOption('', '- Select an Employee -'));
	for(User u : [select id, name from user where userRoleId in :allSubRoleIds order by name]) {
		picklist.add(new selectOption(u.id, u.name));
	}
	return picklist;
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
