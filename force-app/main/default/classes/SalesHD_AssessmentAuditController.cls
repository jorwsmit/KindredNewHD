public with sharing class SalesHD_AssessmentAuditController {

public Assessment_Audit__c assessmentAudit {get; set;}

public User cl {get; set;}

private static Id currentUser = UserInfo.getUserId();

public SalesHD_AssessmentAuditController(ApexPages.StandardController stdController) {
	assessmentAudit = (Assessment_Audit__c)stdController.getRecord();
    for(Assessment_Audit__c aa : [select Advance_Directives_Indicated__c,Allergies_Y_or_NKA_Indicated__c,
	All_Relevant_Items_are_Selected__c,All_Subspecialties_are_Selected__c,Assessment_Date__c,Cardio__c,
	Care_Indicated_Appropriately__c,CL__c,Comorbidities_are_Identified__c,Comorbidity_is_Proven__c,
	Cultures_Attached__c,Current_Code_Status_Indicated__c,Emergency_Contact_Completed__c,GI__c,
	GU__c,Hospital_Admission_Section_Completed__c,ICU_CCU_Stepdown_Days_are_Indicated__c,IV_Antibiotics_Indicated__c,
	Labs_Attached__c,Level_of_Care_Indicated__c,Lines_Indicated__c,MAR_Attached__c,Medication_Sheet_Attached__c,
	Musculoskeletal__c,Narratives_Use_Approved_Abbreviations__c,Neuro__c,Patient_Able_to_Sign_Consent_Indicated__c,
	Patient_Name__c,Plan_for_the_Comorbidity_is_Outlined__c,Primary_Diagnosis_is_Proven__c,Psychosocial_Considerations__c,
	Referring_Facility_Unit_Type_Provided__c,Referring_Physician_Provided__c,Renal__c,Respiratory__c,
	Significant_Chronic_Conditions_Listed__c,Skin_Wound_Integumentary__c,SSN_Completed__c,Subspecialty_Physician_is_Listed__c,
	Titratable_Drips_Indicated__c,Transfusion_Indicated__c,Treatment_Plan_is_Outlined__c,Vitals__c,
	Why_Patient_Admitted_to_STAC_Outlined__c, Comments__c
    from Assessment_Audit__c where Id=:ApexPages.CurrentPage().getparameters().get('id')]){
        assessmentAudit = aa;
    }
}

public List<SelectOption> getYesNo(){
	List<selectOption> options = new List<selectOption>();
	options.add(new selectOption('Yes', 'Yes'));
    options.add(new selectOption('No', 'No'));
	return options;
}

public List<SelectOption> getYesNoNa(){
	List<selectOption> options = new List<selectOption>();
	options.add(new selectOption('Yes', 'Yes'));
    options.add(new selectOption('No', 'No'));
    options.add(new selectOption('N/A', 'N/A'));
	return options;
}

public List<SelectOption> getCls(){
	List<selectOption> options = new List<selectOption>();
    options.add(new selectOption('', 'Select a CL'));

    set<Id> allSubRoleIds = getSubRoleIds(new set<ID> {UserInfo.getUserRoleId()});
    for(User u : [select Id, Name from User where isActive=true and UserRoleId in :allSubRoleIds order by Name]){
        options.add(new selectOption(u.Id, u.Name));
    }
	return options;
}

private static set<Id> getSubRoleIds(set<Id> roleIds) {
	set<Id> returnRoleIds = new set<Id>();
	for (UserRole r : [select Id from UserRole where ParentRoleId in :roleIds and ParentRoleID != null]) {
		returnRoleIds.add(r.Id);
	}
	if (!returnRoleIds.isEmpty()) returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
	return returnRoleIds;
}

public PageReference submitAudit() {
		upsert assessmentAudit;
		PageReference auditPage = new PageReference('/apex/SalesHD_AssessmentAudit?id='+assessmentAudit.Id);
		auditPage.setRedirect(true);
		return auditPage;
	}

}
