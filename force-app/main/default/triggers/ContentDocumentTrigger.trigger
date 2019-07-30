trigger ContentDocumentTrigger on ContentDocument (after update) {
    if(trigger.isafter && trigger.isupdate){
        list<string> titlelist = new list<String>();
        list<Content_Link__c> contentLiskList = new list<Content_Link__c>();
        for(ContentDocument cd : trigger.new){
            if(cd.PublishStatus == 'P'){
                titlelist.add(cd.title);
                
            }
        }
        list<ContentVersion> versionList = new list<ContentVersion>();
        versionList = [SELECT id
                                ,ContentDocumentID
                                ,Title
                                ,Center__c
                                ,Program__c
                       FROM ContentVersion
                       WHERE Title in :titlelist];
        
        for(ContentVersion cv : versionList){
            contentLiskList.add(new Content_Link__c(
                                                        Document_Id__c = cv.ContentDocumentID
                                                        ,Document_Name__c=cv.Title
                                                        ,Account__c= cv.Center__c
                                                        ,Program__c = cv.Program__c));
        }
        insert contentLiskList;               
    }
}