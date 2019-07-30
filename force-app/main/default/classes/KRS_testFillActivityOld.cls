@isTest
public class KRS_testFillActivityOld
{
    public static Id AccountId;
    public testMethod static void  Testit()
    {
        KRS_SRS_BDO_Territory__c nT = new KRS_SRS_BDO_Territory__c();
        nt.name = 'Unknown';
        insert nt; 
        
        Account Act = new Account();
        Act.Name = 'Sumit';
        Act.Type = 'Agency';
        insert Act;
        AccountId = Act.Id;
        Task t=new Task(WhatId = Act.Id, Subject='Sumit Test', ActivityDate=Date.Today(),Status='Completed');
        insert t;
        
        test.StartTest();
        KRS_FillActivityOld  FillActivityOld1 = new KRS_FillActivityOld();    
        id batchProcessid = Database.executeBatch(FillActivityOld1 , 200);
        test.Stoptest();
        List< KRS_Activity_History_Old__c> l = [Select id from  KRS_Activity_History_Old__c where Account__c = :Act.Id];
        system.assertEquals(l.Size(),1);
    }
}