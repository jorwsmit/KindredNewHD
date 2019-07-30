global class KRS_FillActivityOld implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      system.debug('Sumit-Start');
        string query = 'Select Id From Account';
    List<Id> lst1=new List<id>();
    lst1.add('0016000000J3a3m');
    //lst1.add('0016000000J3a3S');
    
        if(Test.isRunningTest())
            query = query +' Where Id =\'' + KRS_testFillActivityOld.AccountId +'\'';
        //else
        //  query = query +' Where Name Like \'a%\' OR Name Like \'b%\' OR Name Like \'c%\' OR Name Like \'d%\' OR Name Like \'e%\' OR Name Like \'f%\'';
        //  query = query +' Where Id in :lst1';
        query = query +' ORDER BY Name';
        system.debug('Sumit-Start1');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
      system.debug('Sumit-Execute Start');
        List<Id> lstAct = new List<Id>();
        for(Account act:scope)
            lstAct.add(act.Id);
        system.debug('Sumit-Execute Start1---'+lstAct.size());
        List<KRS_Activity_History_Old__c> listOAct = new List<KRS_Activity_History_Old__c>();
        integer actNo = 0;
        integer TotalactNo = 0;
        for(Account s : [Select Id,Name,(Select Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, Priority, ActivityType, IsClosed, IsAllDayEvent, DurationInMinutes, Location, Description, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, KRS_Audio_Schedule__c, KRS_Benchmark_Report_Corporate__c, KRS_Benchmark_Report_Facility__c, KRS_Best_Action_Commitment__c, KRS_Eyeglass_Case__c, KRS_Legacy_Record_Owner__c, KRS_Literature_Request__c, KRS_MH_Action__c, KRS_Minimum_Acceptable_Action__c, KRS_Polaris_Pen__c, KRS_Polaris_Private_Notes__c, KRS_Polaris_Pulse_current_edition__c, KRS_Publications_Catalog__c, KRS_Ruler__c, KRS_SLX_Activity_ID__c, KRS_SLX_History_ID__c, KRS_Sales_Flyers_Packet__c, KRS_Services_Booklet__c, KRS_Slick_Audio__c, KRS_Slick_Manual__c, KRS_Valid_Business_Reason__c 
                                    ,Createdby.Name,LastModifiedby.Name,Owner.Name
                            From ActivityHistories) From Account where id in :lstAct])
        {
          system.debug('Sumit-Execute Start2---INNN--'+actNo +'---'+ s.Id+'---'+s.Name);
          actNo++;
          integer actNo1 =0;
            for(ActivityHistory act:s.ActivityHistories)
            {
              system.debug('Sumit-Execute Start2---Activ--'+act.Id +'---'+ actNo1);
              actNo1++;
              TotalactNo++;
                KRS_Activity_History_Old__c oAct = new KRS_Activity_History_Old__c();
                oAct.ActivityDate__c = Act.ActivityDate;
                oAct.ActivityType__c = Act.ActivityType;
                oAct.Best_Action_Commitment__c = Act.KRS_Best_Action_Commitment__c;
                oAct.Calldisposition__c = Act.CallDisposition;
                oAct.CallDurationInseconds__c = Act.CallDurationInSeconds;
                oAct.CallObject__c = Act.CallObject;
                oAct.CallType__c = Act.CallType;
                oAct.Created_By__c = Act.CreatedBy.Name;
                oAct.Description__c = Act.Description;
                oAct.DurationInMinutes__c = Act.DurationInMinutes;
                oAct.IsAllDayEvent__c = Act.IsAllDayEvent;
                oAct.IsClosed__c = Act.IsClosed;
                oAct.IsDeleted__c = Act.IsDeleted;
                oAct.IsReminderSet__c = Act.IsReminderSet;
                oAct.IsTask__c = Act.IsTask;
                oAct.LastModifiedbyName__c = Act.LastModifiedby.Name;
                oAct.Legacy_Record_Owner__c = Act.KRS_Legacy_Record_Owner__c;
                oAct.Location__c = Act.Location;
                oAct.MH_Action__c = Act.KRS_MH_Action__c;
                oAct.Minimum_Acceptable_Action__c = Act.KRS_Minimum_Acceptable_Action__c;
                oAct.Owner_Name__c = Act.Owner.name;
                oAct.Polaris_Priviate_Notes__c = Act.KRS_Polaris_Private_Notes__c;
                oAct.Priority__c = Act.Priority;
                oAct.ReminderDateTime__c = Act.ReminderDateTime;
                oAct.status__c = Act.Status;
                oAct.Subject__c = Act.Subject;
                oAct.Valid_Business_Reason__c = Act.KRS_Valid_Business_Reason__c;
                if(Act.WhatId!=null)
                {
                    string whatI = Act.WhatId;
                    if(whatI.Length()>3)
                    {
                        if(whatI.substring(0,3)=='001')
                            oAct.Account__c = Act.WhatId;
                        else
                            oAct.Opportunity__c = Act.WhatId;
                    }
                }
                oAct.Contact__c = Act.WhoId;
                listOAct.add(oAct);
                if(listOAct.size()>=200)
              {
                insert listOAct;
                listOAct.clear();
              }
            }
            system.debug('Print Total Account :'+TotalactNo+':::::Last Sum:'+actNo1);
        }
        insert listOAct;
        system.debug('Sumit-Execute End');
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}