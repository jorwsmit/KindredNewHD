trigger AA_NoteTrigger on Note (before update, before delete) {
    List<ID> noDelete = new list<ID>();
	//SRS Finance
	noDelete.add('00e1B000001p1wJ');
	//SRS User
	noDelete.add('00e1B000001p1wK');
	
	if(trigger.isUpdate){
    	for(integer i = 0; i < trigger.new.size(); i++){
    		system.debug('User ID: ' + UserInfo.getUserId() + ' Created By ID: ' + trigger.new[i].OwnerId);
    		system.debug('User Profile: ' + UserInfo.getProfileId());
    		if(UserInfo.getProfileId() == '00e13000001dtUiAAI' && UserInfo.getUserId() != trigger.new[i].OwnerId){
    			trigger.new[i].addError('You are not permitted to edit a note that you did not create.  Please create a new note.');
    			}
    		}
    	}
    	
    if(trigger.isDelete){
    	for(Note n: trigger.old){
    		if((UserInfo.getProfileId() == '00e13000001dtUiAAI' && UserInfo.getUserId() != n.OwnerId)){
    			n.addError('You are not permitted to edit or delete a note that you did not create.  Please create a new note.');
    			}
    		if(noDelete.contains(UserInfo.getProfileId()) && UserInfo.getUserId() != n.OwnerId){
				n.addError('You do not have permission to delete notes you did not create, only administrators are allowed, please contact an admin user if you need assistance.');
				}
					
    		}
    	}	
}