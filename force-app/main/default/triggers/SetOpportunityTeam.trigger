trigger SetOpportunityTeam on Opportunity (after update, before update) {
List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();


if(trigger.isBefore){
for(Opportunity o : trigger.new){
	if(o.RecordTypeID == '0121B0000018GAj' && o.KRS_Contract_Lost_Date__c != null){
		o.KRS_Future_Task__c = true;
		}
	}
	}

if(trigger.isAfter){
Map< Id , Id > opportunityIdToAccountId = new Map< Id , Id >();
for(Opportunity o : Trigger.new)  {
    if(o.StageName == 'Commit'||o.StageName == 'Deferred')  {
        opportunityIdToAccountId.put(o.Id,  o.AccountId );
    }
}


Map<id, List<AccountTeamMember > > accountIdToAccountTeamMembers = new    Map<id,  List<AccountTeamMember > > ();
for(AccountTeamMember accountTeamMember : [SELECT a.UserId,a.User.Name,a.TeamMemberRole, a.Id, a.AccountId
                        FROM AccountTeamMember a
                        WHERE a.TeamMemberRole IN ('Clinical Liaison','RDBD') AND
                        a.AccountId in :opportunityIdToAccountId.values() ])   {

        List<AccountTeamMember > accountTeamMembers = ( accountIdToAccountTeamMembers.get(accountTeamMember.Accountid) == null) ?
                                                       new  List<AccountTeamMember >() :
                                                       accountIdToAccountTeamMembers.get(accountTeamMember.Accountid);

        accountTeamMembers.add(accountTeamMember);
        accountIdToAccountTeamMembers.put(accountTeamMember.Accountid, accountTeamMembers);

}



for(Opportunity o : Trigger.new) {
    if(o.StageName == 'Commit'||o.StageName == 'Deferred')   {
        Id accountId  = opportunityIdToAccountId.get(o.Id);
        for ( AccountTeamMember accountTeamMember : accountIdToAccountTeamMembers.get(accountId) )  {
            OpportunityTeamMember opportunityTeamMember  = new OpportunityTeamMember();
            opportunityTeamMember.UserId = accountTeamMember.UserId;
            opportunityTeamMember.TeamMemberRole = accountTeamMember.TeamMemberRole;
            opportunityTeamMember.OpportunityId = o.ID;
            oppTeamMembersList.add(opportunityTeamMember);
        }
     }
}
		
insert oppTeamMembersList;
}
}