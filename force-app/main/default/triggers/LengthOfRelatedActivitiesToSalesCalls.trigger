trigger LengthOfRelatedActivitiesToSalesCalls on Sales_Performance__c (before update) {
    
    //Initialize KAH profile IDs 	  //KAH Sales Associate  //KAH Market Manager  //KAH Manager
    Set<ID> KAHProfileIDs = new Set<ID> {'00e1300000225C9', '00e130000024QC8', '00e1300000225CA'};
    //Map Sales Performance Ids with the Profile of the Owner on the record
    Map<Id, String> SPIdToProfileName = new Map<Id, String>();
    for (Sales_Performance__c sp : [select Id, Owner.Profile.ID, Sales_Calls__c from Sales_Performance__c where Id in :Trigger.new]){
        SPIdToProfileName.put(sp.Id, sp.Owner.Profile.ID);
    }
    //Initialize KAH types to include in the sales calls total
    List<String> KAHTypeList = new List<String> {'Care Coordination', 'Cold Call', 'Community Event', 'Informational Meeting',
                                'Memory Care Inservice', 'Patient Follow-up', 'Physician Office Sales Call', 'Scheduled Appointment',
                                'Unscheduled/Drop By', 'We Honor Veterans Presentation', 'External In-service', 'Other'};
    //KAH map has more restrictive query on agregate count
    Map<String, Integer> SPIdToEventTotal = new Map<String, Integer>();
    Map<String, Integer> KAHSPIdToEventTotal = new Map<String, Integer>();
    Map<String, Integer> KAHSPIdToPlannedTotal = new Map<String, Integer>();
    //Both have the same task total count
    Map<String, Integer> SPIdToTaskTotal = new Map<String, Integer>();
    /******The following 3 for loops map the Sales Performance Id with an agregate count of the records for a Sales Calls total*****/
    for (AggregateResult ar : [select sales_performance_id__c SPId, count(id) EventTotal from event where
                               sales_performance_id__c in :Trigger.new and isrecurrence != true group by sales_performance_id__c]){
        SPIdToEventTotal.put(String.valueof( ar.get('SPId')), Integer.valueof(ar.get('EventTotal')));
    }

    for (AggregateResult ar : [select sales_performance_id__c SPId, count(id) EventTotal from event where
                               sales_performance_id__c in :Trigger.new and isrecurrence != true and
                               Type in :KAHTypeList and Complete__c = true group by sales_performance_id__c]){
        KAHSPIdToEventTotal.put(String.valueof( ar.get('SPId')), Integer.valueof(ar.get('EventTotal')));
    }

    for (AggregateResult ar : [select sales_performance_id__c SPId, count(id) EventTotal from event where
                               sales_performance_id__c in :Trigger.new and isrecurrence != true and
                               Type in :KAHTypeList group by sales_performance_id__c]){
        KAHSPIdToPlannedTotal.put(String.valueof( ar.get('SPId')), Integer.valueof(ar.get('EventTotal')));
    }

    for (AggregateResult ar : [select sales_performance_id__c SPId, count(id) TaskTotal from task where
                               sales_performance_id__c in :Trigger.new group by sales_performance_id__c]){
        SPIdToTaskTotal.put(String.valueof( ar.get('SPId')), Integer.valueof(ar.get('TaskTotal')));
    }
    //The for loop below runs through the triggered Sales Performances and applies the Sales Calls to them
    for (Sales_Performance__c sp : Trigger.new){
        Integer SalesCallsTotal = 0;
        //Checks if Sales Performance owner is KAH
        if(KAHProfileIDs.contains(SPIdToProfileName.get(sp.Id))){
            Integer PlannedSalesCalls = 0;
            if(KAHSPIdToEventTotal.containsKey(sp.Id)) SalesCallsTotal += KAHSPIdToEventTotal.get(sp.Id);
            if(SPIdToTaskTotal.containsKey(sp.Id)) SalesCallsTotal += SPIdToTaskTotal.get(sp.Id);
            if(KAHSPIdToPlannedTotal.containsKey(sp.Id)) PlannedSalesCalls = KAHSPIdToPlannedTotal.get(sp.Id);
            sp.Planned_Sales_Calls__c = PlannedSalesCalls;
            sp.Sales_Calls__c = SalesCallsTotal;
        } else {
            if(SPIdToEventTotal.containsKey(sp.Id)) SalesCallsTotal += SPIdToEventTotal.get(sp.Id);
            if(SPIdToTaskTotal.containsKey(sp.Id)) SalesCallsTotal += SPIdToTaskTotal.get(sp.Id);
            sp.Sales_Calls__c = SalesCallsTotal;
        }
    }

    /*******OLD TRIGGER BELOW*********/
    /*
    List<Sales_Performance__c> SPs = new List<Sales_Performance__c>();
    SPs.addAll(Trigger.new);

    List<Event> events = [select id, Sales_Performance_ID__c, Owner.Profile.Name, Complete__c from event where Sales_Performance_ID__c in :Trigger.new and IsRecurrence != true];
    List<Task> tasks = [select id, Sales_Performance_ID__c from task where Sales_Performance_ID__c in :Trigger.new];

    for (Sales_Performance__c sp : SPs){
        sp.Sales_Calls__c = getEventsAndTasksTotal(sp.Id);
    }

    public static Integer getEventsAndTasksTotal(Id spId){
        Integer eventsAndTasksTotal = 0;
        for (Event e : events){
            if(e.Owner.Profile.Name =='KAH Sales Associate' || e.Owner.Profile.Name =='KAH Market Manager' || e.Owner.Profile.Name =='KAH Manager'){
                if(e.Complete__c && e.Sales_Performance_ID__c == spId) eventsAndTasksTotal++;
            } else {
                if (e.Sales_Performance_ID__c == spId) eventsAndTasksTotal++;
            }
        }

        for (Task t : tasks){
            if (t.Sales_Performance_ID__c == spId) eventsAndTasksTotal++;
        }

        return eventsAndTasksTotal;
    }
    */
}