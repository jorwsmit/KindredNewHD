public without sharing class SalesHD_ReportingClass {

private static Integer targetEncountersPerDay = 2;

private static Id dashboardRunningUserRoleId = null;

private static Map<String, String> contactTitleBuckets = new Map<String, String> {'Fellow'=>'Physician', 'Hospitalist'=>'Physician',
	                                                                          'Intensivist'=>'Physician', 'Palliative Care Physician'=>'Physician', 'Physician'=>'Physician',
	                                                                          'Physician Assistant'=>'Physician',

	                                                                          'Nurse Practitioner'=>'Nurse Practitioner',

	                                                                          'Case Manager'=>'Case Manager', 'Case Management Manager'=>'Case Management Manager',

	                                                                          'Medical Director of Facility'=>'Director', 'Medical Director of UR'=>'Director', 'Unit Medical Director'=>'Director',
	                                                                          'Director of Business Development'=>'Director', 'Director of Case management'=>'Director', 'Director of Nursing'=>'Director',
	                                                                          'Director of Quality'=>'Director', 'Director of Rehab'=>'Director', 'Director of Respiratory Work'=>'Director', 'Director of Social Work'=>'Director',
	                                                                          'Director of Staff Development'=>'Director', 'Director of Utilization Management'=>'Director', 'Director of Nursing'=>'Director'};


public String encountersLastWeek {get; set;}
public String encountersLastWeekAdmin {get; set;}

public String encounterSummary {get; set;}
public String encounterSummaryAdmin {get; set;}

public String debugstr {get; set;}


public class encounterSummary {
public String clName = '';
public String clMarket = '';
public Integer totalEncounters = 0;
public Integer physicianEncounters = 0;
public Integer npEncounters = 0;
public Integer cmEncounters = 0;
public Integer directorEncounters = 0;
public Integer otherEncounters = 0;
}

public class encounterLastWeek {
public String market;
public Integer encounterTotal;
public Integer encounterTarget;
}

public SalesHD_ReportingClass() {
	encountersLastWeek = '[]';
	encountersLastWeekAdmin = '';

	// for(Dashboard db : [select id, RunningUser.UserRoleId, Title from Dashboard WHERE id=:dashboardID]) {
    //     dashboardRunningUserRoleId = db.RunningUser.UserRoleId;
	// }
}

public void eLastWeek(){
	encountersLastWeek = JSON.serializePretty(getEncountersLastWeek(UserInfo.getUserRoleId()));
}

public void eLastWeekSummary(){
	encountersLastWeek = JSON.serializePretty(getEncounterSummary(UserInfo.getUserRoleId()));
}

public static Map<Id, Map<Id, encounterSummary> > getEncounterSummary(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
	allSubRoleIds.add(rId);

	Map<Id, String> roleIdArea = new Map<Id, String>();
	for(User u : [select area__c, userRoleId from user where area__c!=null and userRoleId in :allSubRoleIds and isActive=true]) {
		if(!roleIdArea.containsKey(u.userRoleId)) roleIdArea.put(u.userRoleId, u.area__c);
	}

	Map<Id, Map<Id, encounterSummary> > result = new Map<Id, Map<Id, encounterSummary> >();

	Map<Id, String> contacts = new Map<Id, String>();

	List<id> contactIds = new List<id>();

	for(event e : [select whoId from event where owner.userRoleId in :allSubRoleIds and startDateTime=last_week]) {
		contactIds.add(e.whoId);
	}

	for(contact c : [select id, title__c from contact where id in :contactIds]) {
		if(c.title__c!=null) contacts.put(c.id, c.title__c);
	}

	for(event e : [select id, whoId, owner.userRoleId, owner.name, ownerId from event where owner.userRoleId in :allSubRoleIds and startDateTime=last_week]) {
		encounterSummary temp = new encounterSummary();

		// Map<Id, encounterSummary> temp = new Map<Id, encounterSummary>();

		if(!result.containsKey(e.owner.userRoleId)) result.put(e.owner.userRoleId, new Map<Id,encounterSummary> {e.ownerId=>new encounterSummary()});
		else if(!result.get(e.owner.userRoleId).containsKey(e.ownerId)) result.get(e.owner.userRoleId).put(e.ownerId, new encounterSummary());

		// temp = result.get(e.owner.userRoleId);

		temp = result.get(e.owner.userRoleId).get(e.ownerId);

		if(temp.clMarket=='' && roleIdArea.containsKey(e.owner.userRoleId)) temp.clMarket = roleIdArea.get(e.owner.userRoleId);
		if(temp.clName=='') temp.clName = e.owner.name;

		if(contactTitleBuckets.containsKey(contacts.get(e.whoId))) {
			// temp.clMarket = contactTitleBuckets.get(contacts.get(e.whoId));

			if(contactTitleBuckets.get(contacts.get(e.whoId))=='Physician') temp.physicianEncounters++;
			else if(contactTitleBuckets.get(contacts.get(e.whoId))=='Nurse Practitioner') temp.npEncounters++;
			else if(contactTitleBuckets.get(contacts.get(e.whoId))=='Case Manager') temp.cmEncounters++;
			else if(contactTitleBuckets.get(contacts.get(e.whoId))=='Director') temp.directorEncounters++;
			else temp.otherEncounters++;

		} else temp.otherEncounters++;

		temp.totalEncounters++;

		// temp.clName = e.owner.name;

		result.get(e.owner.userRoleId).put(e.ownerId, temp);


		result.put(e.owner.userRoleId, result.get(e.owner.userRoleId));

		// result.put(e.id, new List<encounterSummary>{temp});
	}

	return result;
}

public static String getEncountersLastWeek(Id rId){
	set<Id> allSubRoleIds;
	allSubRoleIds = getSubRoleIds(new set<ID> {rId});
    allSubRoleIds.add(rId);

	Map<Id, String> roleIdArea = new Map<Id, String>();
	Map<Id, Integer> roleIdUserTotal = new Map<Id, Integer>();
	for(User u : [select area__c, userRoleId from user where area__c!=null and userRoleId in :allSubRoleIds and isActive=true]) {
		if(!roleIdArea.containsKey(u.userRoleId)) {
			roleIdArea.put(u.userRoleId, u.area__c);
			roleIdUserTotal.put(u.userRoleId, 1);
		} else{
			roleIdUserTotal.put(u.userRoleId, roleIdUserTotal.get(u.userRoleId)+1);
		}
	}

	List<encounterLastWeek> result = new List<encounterLastWeek>();
    List<List<String>> result2 = new List<List<String>>();
    result2.add(new List<String> {'Market', 'Total Encounters', 'Targeted Encounters'});
    String res = '{ "cols" : [{"id":"","label":"Market","pattern":"","type":"string"}, ' +
    '{"id":"","label":"Total Encounters","pattern":"","type":"number"}, ' +
    '{"id":"","label":"Targeted Encounters","pattern":"","type":"number"}],'+
    '"rows": [';
	// for(AggregateResult ar : [select owner.userRoleId roleId, count(Id) total from event where
	//                         startDateTime=last_week and SalesHD_Account_Unit__c!=null and SalesHD_Complete__c=true
	// 						and ownerId in (select id from user where isActive=true and area__c!=null) and owner.userRoleId in :allSubRoleIds group by owner.userRoleId]) {
        for(AggregateResult ar : [select owner.userRoleId roleId, count(Id) total from event where
	                        startDateTime=last_week and SalesHD_Account_Unit__c!=null and SalesHD_Complete__c=true
							and ownerId in (select id from user where isActive=true and area__c!=null) and owner.userRoleId in :allSubRoleIds group by owner.userRoleId order by count(Id) desc]) {
		encounterLastWeek temp = new encounterLastWeek();
		String market = '';
		Id roleId = String.valueOf(ar.get('roleId'));
		if(roleIdArea.containsKey(roleId)) market = roleIdArea.get(roleId);
		Integer target;
		if(roleIdUserTotal.containsKey(roleId)) target = roleIdUserTotal.get(roleId) * 5 * targetEncountersPerDay;
		temp.market = market; temp.encounterTotal = Integer.valueOf(ar.get('total')); temp.encounterTarget = target;
		result.add(temp);
        result2.add(new List<String> {market, String.valueOf(ar.get('total')), String.valueOf(target)});
        res += '{"c":[{"v":"'+market+'","f":null},{"v":'+Integer.valueOf(ar.get('total'))+',"f":null},{"v":'+target+',"f":null}] },';
	}
    if(res.right(1) == ',') res = res.left(res.length()-1);
    res += ']}';
    return res;
	// return result2;
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
