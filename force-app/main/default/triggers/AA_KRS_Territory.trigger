trigger AA_KRS_Territory on KRS_SRS_BDO_Territory__c (before delete, before insert, before update, after delete, after insert, after undelete, 
after update){

    public class InvalidTerritoryOperationException extends Exception{
    }
    
    if(trigger.isBefore){  
        if(Trigger.isDelete || Trigger.isUpdate){
            for(KRS_SRS_BDO_Territory__c terr : Trigger.old){
            if(Trigger.isDelete && terr.Name == 'Unknown'){
                terr.addError('Cannot delete the \'Unknown\' territory.');
                }
            else if(Trigger.isUpdate && terr.Name == 'Unknown' && terr.Name != trigger.newMap.get(terr.Id).Name){
                trigger.newMap.get(terr.Id).addError('Cannot rename the \'Unknown\' territory.');
                }
            }
        } 
    else if(Trigger.isInsert){
        KRS_SRS_BDO_Territory__c unkTerr = null;
        for(KRS_SRS_BDO_Territory__c terr : Trigger.new){
            if(terr.Name == 'Unknown'){
                if(unkTerr == null){
                    try{
                        unkTerr = [Select Id From KRS_SRS_BDO_Territory__c Where Name = 'Unknown' limit 1];
                        }
                    catch(Exception E){
                        (system.debug('No previous territories named Unknown exist.'));
                        }   
                    }
            if(unkTerr != null){
                terr.addError('Cannot create duplicate \'Unknown\' territory.');
                }
            }
            }
        }
    }
    
    if(trigger.isAfter){
        // Multiple triggers may fire to schedule this batch apex.  Ensure that it only runs once.
        if(KRS_ResetAccountSrsBdoTerritories.contextExecutionCount++ == 0){
            KRS_ResetAccountSrsBdoTerritories batch = new KRS_ResetAccountSrsBdoTerritories();
            Database.executeBatch(batch);
            }
        }
}