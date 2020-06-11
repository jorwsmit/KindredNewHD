@isTest(seeAllData=false)
public class SalesHD_TestRedesignNavController {
    @isTest static void InitializeNav() {
        PageReference pageRef = Page.SalesHD_Homepage;
        Test.setCurrentPage(pageRef);
        Test.startTest();
        SalesHD_RedesignNavController controller =
            new SalesHD_RedesignNavController();
        Test.stopTest();
    }

}