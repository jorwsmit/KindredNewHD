global class Sales_AssignmentSnapshotScheduled implements Schedulable {
	private static final Id kahSalesAssociate = '00e1300000225C9';
	private static final Id kahMarketManager = '00e130000024QC8';
	global string query = 'select id from user where user.isActive=true and (user.profileId=\''+kahSalesAssociate+'\' or user.profileId=\''+kahMarketManager+'\')';
    global void execute(SchedulableContext sc) {
        Sales_AssignmentSnapshot batch = new Sales_AssignmentSnapshot();
        batch.query = query;
        Database.executeBatch(batch, 1);
    }
}