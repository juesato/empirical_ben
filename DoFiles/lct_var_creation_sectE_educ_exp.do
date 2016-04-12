#delimit;
cap clear matrix;
clear;
set mem 500m;
set more off;


use "Output\foranalysis.dta", clear; 

************************************************;
************************************************;
* Var creation for analysis on SECTION E: Educational expenses;
************************************************;
************************************************;

*****************;
** Enrolment status of kids in sect E;

forvalues i=1/14 {; 
	gen tot_educ_expenses`i'=0 if  id_enfant_`i'!=.;
	gen tot_educ_annual_expenses`i'=0 if  id_enfant_`i'!=.;
	gen tot_educ_monthly_expenses`i'=0 if  id_enfant_`i'!=.;
	gen tot_expenses_fournit`i'=0 if  id_enfant_`i'!=.;
replace tot_expenses_fournit`i'=e9_`i'*9 if e9_`i'!=. & e9_`i'>0;
replace tot_expenses_fournit`i'=tot_expenses_fournit`i'+e8_`i' if e8_`i'!=. & e8_`i'>0;
* annual expenses;
	forvalues x=1/8 {;
 qui replace tot_educ_expenses`i'=tot_educ_expenses`i'+e`x'_`i' if e`x'_`i'>0 & e`x'_`i'!=.;
 qui replace tot_educ_annual_expenses`i'=tot_educ_annual_expenses`i'+e`x'_`i' if e`x'_`i'>0 & e`x'_`i'!=.;
	};
* monthly expenses;
	forvalues x=9/14 {;
 qui replace tot_educ_expenses`i'=tot_educ_expenses`i'+(e`x'_`i'*9) if e`x'_`i'>0 & e`x'_`i'!=.;
 qui replace tot_educ_monthly_expenses`i'=tot_educ_monthly_expenses`i'+(e`x'_`i'*9) if e`x'_`i'>0 & e`x'_`i'!=.;

		};
	};

egen tot_educ_expenses=rsum(tot_educ_expenses*);
	label var tot_educ_expenses "All HH educ expenses";
egen tot_educ_annual_expenses=rsum(tot_educ_annual_expenses*);
	label var tot_educ_annual_expenses "All HH Annual educ expenses";
egen tot_educ_monthly_expenses=rsum(tot_educ_monthly_expenses*);
	label var tot_educ_monthly_expenses "All HH Monthly educ expenses";

forvalues i=1/14 {; 
	gen statut_educ_`i'=-99 if id_enfant_`i'!=.;
forvalues j=1/12 {;
	qui	replace statut_educ_`i'=1 if id_enfant_`i'==d2_`j' & d5_`j'==1;
	qui	replace statut_educ_`i'=0 if id_enfant_`i'==d2_`j' & d5_`j'==0;	
		};
	};
** we tag those older than 17 (18-25);
forvalues i=1/14 {; 
forvalues j=1/32 {;
	qui	replace statut_educ_`i'=-77 if statut_educ_`i'==-99 & (a13_`j'>17 & a13_`j'<26) ;
			};
	};
** we add info on cycle;
forvalues i=1/14 {; 
forvalues j=1/12 {;
	forvalues k=3/5 {;
	qui	replace statut_educ_`i'=`k' if id_enfant_`i'==d2_`j' 
					& statut_educ_`i'!=. & d24_cycle_`j'==`k';
	qui	replace statut_educ_`i'=`k' if id_enfant_`i'==d2_`j' 
					& statut_educ_`i'==-99 & d12_cycle_`j'==`k';
				};
			};
		};

** we generate total of expenditure by type of educ;

local l=0;
foreach j in  -99 -77 3 4 5 {;
local `++l';
	gen tot_educ_exp_`l'=0;
	gen tot_educ_annual_exp_`l'=0;
	gen tot_educ_montly_exp_`l'=0;
	gen tot_founit_exp_`l'=0;
forvalues i=1/14 {; 
	qui replace tot_educ_exp_`l'=tot_educ_exp_`l'+tot_educ_expenses`i' if statut_educ_`i'==`j';
	qui replace tot_founit_exp_`l'=tot_founit_exp_`l'+tot_expenses_fournit`i' if statut_educ_`i'==`j';
	
	qui replace tot_educ_annual_exp_`l'=tot_educ_annual_exp_`l'+tot_educ_annual_expenses`i' if statut_educ_`i'==`j';
	qui replace tot_educ_montly_exp_`l'=tot_educ_montly_exp_`l'+tot_educ_monthly_expenses`i' if statut_educ_`i'==`j';		
		};
	};
** we also generate total expenditure for higher than primary;
	gen tot_educ_exp_high=0;
	gen tot_educ_annual_exp_high=0;
	gen tot_educ_montly_exp_high=0;
	gen tot_founit_exp_high=0;
forvalues i=1/14 {; 
	qui replace tot_educ_exp_high=tot_educ_exp_high+tot_educ_expenses`i' 
		if statut_educ_`i'!=3 & statut_educ_`i'!=. & statut_educ_`i'!=-99;
	qui replace tot_founit_exp_high=tot_founit_exp_high+tot_expenses_fournit`i' 
		if statut_educ_`i'!=3 & statut_educ_`i'!=. & statut_educ_`i'!=-99;

	qui replace tot_educ_annual_exp_high=tot_educ_annual_exp_high+tot_educ_annual_expenses`i' 
		if statut_educ_`i'!=3 & statut_educ_`i'!=. & statut_educ_`i'!=-99;
	qui replace tot_educ_montly_exp_high=tot_educ_montly_exp_high+tot_educ_monthly_expenses`i' 
		if statut_educ_`i'!=3 & statut_educ_`i'!=. & statut_educ_`i'!=-99;
		};
		
		
*******;
** we want the average expense by kid in primary or secondary;

gen total_kids_3=0;
gen total_kids_45=0;
forvalues i=1/9 {;
	replace total_kids_3=total_kids_3+1 if statut_educ_`i'==3;
	replace total_kids_45=total_kids_45+1 if statut_educ_`i'==4
		| statut_educ_`i'==5;
	};


foreach x in  tot_educ_exp_3 
	tot_founit_exp_3 tot_educ_annual_exp_3 
	tot_educ_montly_exp_3  {;
gen `x'_byk=`x'/total_kids_3;
	};
foreach x in   tot_educ_exp_high
	 tot_founit_exp_high tot_educ_annual_exp_high
	 tot_educ_montly_exp_high {;
gen `x'_byk=`x'/total_kids_45;
	};

	

		
****************************************;
*** GENDER AND IDENTITY OF RESPONDENT *;
****************************************;

gen male_resp=.;
gen cm_resp=.;
gen ccm_resp=.;

replace e_id_rep=2 if e_id_rep==-2;

global id_rep="e_id_rep";

qui foreach i of  numlist 1/27 {;
	replace male_resp=1 if $id_rep==`i' & a4_`i'==1;
	replace male_resp=0 if $id_rep==`i' & a4_`i'==2;
	replace cm_resp=1 if $id_rep==`i' & a3_`i'==1;
 	replace ccm_resp=1 if $id_rep==`i' & a3_`i'==2;
};

gen mother_resp=(ccm_resp==1) * (male_resp==0);
	replace mother_resp=1 if cm_resp==1 & male_resp==0;
gen father_resp=(cm_resp==1) * (male_resp==1);
	replace father_resp=1 if ccm_resp==1 & male_resp==1;
gen other_resp=(mother_resp==0) * (father_resp==0);
		

	

**************************************;
*** MISSING HH CONTROLS;
**************************************;
foreach var in bs_pchildren_enrolled bs_nchildren bs_nchildren615 
bs_pchildren_dropout bs_pchildren_neverenrolled bs_own_cellphone bs_age_head{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};


	
	
************;
**** we add school level data;
sort schoolunitid;
preserve;
u "Output\school_level_data",clear;

global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid $school_var;
sort schoolunitid;
 save tp1,replace;
restore;
merge schoolunitid using tp1;
erase tp1.dta;	
ta _merge;
drop if _merge==2;
drop _merge;
foreach var in $school_var {;
gen `var'_miss=`var'==.;
sum `var';
replace `var'=r(mean) if `var'==.;
};




******;
** we add weight;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;

******;
** Treatment variables;
cap gen cond_mere=anycond*mere;
cap gen cond_pere=anycond*pere;
cap gen uncond_mere=uncond*mere;
cap gen uncond_pere=uncond*pere;


	
**************************************************;
save "Output\workingtable_sectE",replace;
**************************************************;

		
	

