public with sharing class AA_MEDPARController {
	
	public HRS_MEDPAR__c medparData	{get;set;}
	
    @AuraEnabled
    public static HRS_MEDPAR__c getMEDPARData(ID id){
        system.debug('ID: ' + id);
        HRS_MEDPAR__c mData = new HRS_MEDPAR__c();
        try{
        mData = [SELECT Account__c,
        				Account__r.KRS_MEDPAR_Master_ID__c,
						Acute_ADC__c,
						Acute_Beds__c,
						Buds_Notes__c,
						Acute_Occupancy__c,
						ARU_Location_for_Shared_IDs__c,
						CMS_Provider_ID__c,
						CON_State_Existing_Business__c,
						CON_State_New_Business__c,
						County__c,
						Do_Not_Call_Date__c,
						HCRIS_Reporting_End_Date__c,
						HCRIS_Reporting_Months__c,
						HIH_Indicator__c,
						HRS_Affiliate_1__c,
						HRS_Affiliate_2__c,
						HRS_Affiliate_3__c,
						IP_Cost_PPD__c,
						IP_LOS__c,
						IRF_ADC__c,
						IRF_Beds__c,
						IRF_Difference_in_Potential_ADC__c,
						IRF_Occupancy__c,
						IRF_Potential_ADC__c,
						LTACH_ADC__c,
						LTACH_Beds__c,
						LTACH_Occupancy__c,
						MSA_Micro__c,
						Non_Compete__c,
						SNF_ADC__c,
						SNF_Beds__c,
						SNF_Occupancy__c,
						Type_of_Facility__c,
						Type_of_Facility_Secondary__c,
						LastModifiedDate
                        FROM HRS_MEDPAR__c
                        WHERE Account__c =: id];
            }
        catch(exception E){
            system.debug('No MEDPAR Data Present for Account');
            }
        return mData;
        }
        
        public AA_MEDPARController(ApexPages.StandardController controller){
        	
        	}
        
        public void pullPDFData(){
        	medparData = new HRS_MEDPAR__c();
        	ID id = ApexPages.currentPage().getParameters().get('id');
        	
        	try{
        	medparData = [SELECT Account__c,
        						 Account__r.KRS_MEDPAR_Master_ID__c,
								 Acute_ADC__c,
								 Acute_Beds__c,
								 Acute_Occupancy__c,
								 ARU_Location_for_Shared_IDs__c,
								 Buds_Notes__c,
								 CMS_Provider_ID__c,
								 CON_State_Existing_Business__c,
								 CON_State_New_Business__c,
								 County__c,
								 Do_Not_Call_Date__c,
								 HCRIS_Reporting_End_Date__c,
								 HCRIS_Reporting_Months__c,
								 HIH_Indicator__c,
								 HRS_Affiliate_1__c,
								 HRS_Affiliate_2__c,
								 HRS_Affiliate_3__c,
								 IP_Cost_PPD__c,
								 IP_LOS__c,
								 IRF_ADC__c,
								 IRF_Beds__c,
								 IRF_Difference_in_Potential_ADC__c,
								 IRF_Occupancy__c,
								 IRF_Potential_ADC__c,
								 LTACH_ADC__c,
								 LTACH_Beds__c,
								 LTACH_Occupancy__c,
								 MSA_Micro__c,
								 Non_Compete__c,
								 SNF_ADC__c,
								 SNF_Beds__c,
								 SNF_Occupancy__c,
								 Type_of_Facility__c,
								 Type_of_Facility_Secondary__c,
								 LastModifiedDate
                        		 FROM HRS_MEDPAR__c
                        		 WHERE ID =: id];
            					 }
            	catch(exception E){
            	system.debug('No MEDPAR Data Present for Account');
            	}
        	}
    
}