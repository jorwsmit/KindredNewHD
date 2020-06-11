public with sharing class SalesHD_RedesignNavController {

    public Boolean hasSalesPlanAccess {get; set;}
    public String salesPlanView {get; set;}

    public SalesHD_RedesignNavController() {
        hasSalesPlanAccess = false;
        salesPlanView = '#';
        List<User> u = [select HD_Sales_Plan_Access__c, Profile.Name from user where Id = :UserInfo.getUserId()];
        if(!u.isEmpty() && (u[0].HD_Sales_Plan_Access__c || u[0].Profile.Name.contains('Admin'))){
            hasSalesPlanAccess = true;
            if(u[0].Profile.Name.contains('Manager') || u[0].Profile.Name.contains('Admin')) salesPlanView = '/apex/saleshd_salesplansmanager';
            else if(u[0].Profile.Name.contains('Associate') || u[0].Profile.Name.contains('PAC')) salesPlanView = '/apex/saleshd_salesplans';
        }
    }
}
