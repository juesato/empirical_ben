#delimit;
cap clear matrix;
clear;
set mem 600m;
set more off;

***************************************************;
**** VARIABLE creation knowledge survey ***********;
***************************************************;


******************************************;
** knowledge teachers year 1;
******************************************;

u "Input\cct_knowledge_teachers_year1_an",clear;

sort schoolunitid;
preserve;

** we merge with school level data;
u "Output\school_level_data",clear;
global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";

keep schoolunitid-province $school_var;
 sort schoolunitid;
save tp2,replace;

restore;
 merge schoolunitid using tp2;
 ta _merge;
drop if _merge==1 ;
sort schoolunitid;
ren _merge ks1_not_surveyed;
recode ks1_not_surveyed 3=0 2=1;

foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};
erase tp2.dta;	


******;
** we _merge with visits dates;
sort schoolunitid;
preserve;
u "Input\cct_school_visits_an",clear;
keep schoolunitid  v2_date v2_heure v2_inacc;
duplicates drop schoolunitid,force;
sort schoolunitid;
save tp1,replace;

restore;
merge schoolunitid using tp1;
erase tp1.dta;	
ta _merge;
drop if _merge==2;
drop _merge;


******;
** date format;
gen v2_date_td=mdy(real(substr(v2_date,3,2)),real(substr(v2_date,1,2)),2000+real(substr(v2_date,5,2)));
format v2_date_td %td;

******;
** we replace attrition by . if surveyed before 09APR;
replace ks1_not_surveyed=. if v2_date_td<17995 & ks1_not_surveyed==1;
gen ks1_not_surveyed_dir=ks1_not_surveyed;
replace ks1_not_surveyed_dir=. if type_unit=="Satellite";
replace ks1_not_surveyed_dir=. if e5==2;
gen ks1_not_surveyed_ens=ks1_not_surveyed;
replace ks1_not_surveyed_ens=. if e5==1;

count if ks1_not_surveyed_ens==. & ks1_not_surveyed_dir==. & ks1_not_surveyed!=.;
assert r(N)==0;


******;
** we drop group0;
drop if group==0;


******;
** variables creation;
forvalues i=1/6 {;

	gen ks1_e15_r`i'=0 if e14!=.;
	move e16 ks1_e15_r`i';

forvalues j=1/4 {;
	replace ks1_e15_r`i'=1 if e15_`j'==`i'; 

	};
};

** condit on 5 abs;
gen ks1_cond_5abs=ks1_e15_r3;

** condi on attendance;
gen ks1_cond_abs=ks1_e15_r3;
replace ks1_cond_abs=1 if  ks1_e15_r2==1 
 |  e15_5=="2" | e15_5=="moins de 2 absences par mois"
	| e15_5=="pointer aux machines";

** condit on 5 abs and now that it's conditionnal;
gen ks1_cond_5abs_if_cond=ks1_e15_r3 if ks1_cond_abs==1;	
	
** uncond or only enroll in school or only 6-15 years old;
gen ks1_uncond=e14==1 | e14==3 if e14!=.;
replace ks1_uncond=1 if ks1_e15_r2==0  & ks1_e15_r3==0 
	& e15_5!="2" & e15_5!="moins de 2 absences par mois"
	& e15_5!="pointer aux machines";
	

** know right amont;
gen ks1_amount_cor=e19==80 if e19!=.;

	
** var ens and var dir;
foreach x in ks1_uncond ks1_cond_5abs ks1_cond_abs ks1_cond_5abs_if_cond ks1_amount_cor{;
	gen `x'_dir=`x' if e5==1;
	gen `x'_ens=`x' if e5==2;
	};
	

** gender;
gen sexe=e6;
recode sexe 2=1 1=0;
gen sexe_miss=sexe==.;
qui sum sexe;
replace sexe=r(mean) if sexe==.;


******;
** we merge with stratification data;
	sort schoolid;
	merge schoolid using "Input\cct_stratum_an.dta";
		tab _merge;

		drop if _merge==2;
		drop _merge;

	sort schoolid schoolunitid;


*************************************************************;
save "Output\working_knowledge1",replace;
*************************************************************;



******************************************;
******************************************;
** knowledge teachers year 2;
******************************************;
******************************************;


u "Input\cct_knowledge_teachers_year2_an",clear;



******;
** Merging with School data;
sort schoolunitid;
preserve;
u "Output\school_level_data",clear;
global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter ";

keep schoolunitid-province $school_var mere;
 sort schoolunitid;
save tp1,replace;
restore;
merge schoolunitid using tp1;
erase tp1.dta;
 ta _merge;
drop if _merge==1;
drop _merge;

foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};




******;
** variables creation;

gen ks2_not_surveyed=e5==.;
gen ks2_not_surveyed_dir=ks2_not_surveyed;
replace ks2_not_surveyed_dir=. if e5==2;
replace ks2_not_surveyed_dir=. if type_unit=="Satellite";

gen ks2_not_surveyed_ens=ks2_not_surveyed;
replace ks2_not_surveyed_ens=. if e5==1 | e5==3;


count if ks2_not_surveyed_ens==. & ks2_not_surveyed_dir==. & ks2_not_surveyed!=.;
assert r(N)==0;


** we keep only the sample;
gen survey=e5!=.;
sort schoolunitid e5;
by schoolunitid,sort:gen tp1=_n;
by schoolunitid,sort:egen tp2=total(ks2_not_surveyed); 

** only one survey to do in satellite, and 2 in center schools;
drop if tp1==2 & e5==. & type_unit=="Satellite";
drop if tp2==2 & tp1==2 & e5==. & type_unit=="Secteur Scolaire Centre";
drop if tp1==3 & e5==.;
drop tp1 tp2;

** still working on the sample;
gen tp1=ks2_not_surveyed_ens!=.;
by schoolunitid,sort: egen tot_tp1=total(tp1);
replace ks2_not_surveyed_ens=. if tot_tp1==2 & e5==.;
drop tp1 tot_tp1;

gen tp1=ks2_not_surveyed_dir!=.;
by schoolunitid,sort: egen tot_tp1=total(tp1);
replace ks2_not_surveyed_dir=. if tot_tp1==2 & e5==.;
drop tp1 tot_tp1;


** condit on 5 abs;
gen ks2_cond_5abs=e15_3;
replace ks2_cond_5abs=0 if e14!=. & ks2_cond_5abs==.;


** condi on attendance;
gen ks2_cond_abs=ks2_cond_5abs;
replace ks2_cond_abs=1 if e15_2==1 ;

** condit on 5 abs and know it's conditionnal;
gen ks2_cond_5abs_if_cond=ks2_cond_5abs if  ks2_cond_abs==1;

** uncond or only enroll in school or only 6-15 years old;
gen ks2_uncond=0 if e14!=.;
replace ks2_uncond=1 if ks2_cond_abs==0 & e15_6!=1;

** this variable don't exixt here but we create it;
gen ks2_amount_cor=e19==80 if e19!=.;
	
** var ens and var dir;
foreach x in ks2_cond_5abs ks2_cond_abs 
	ks2_cond_5abs_if_cond ks2_uncond ks2_amount_cor{;
	gen `x'_dir=`x' if e5==1 | e5==3;
	gen `x'_ens=`x' if e5==2;
	};

** gender;
gen sexe=e6;
recode sexe 2=1 1=0;
gen sexe_miss=sexe==.;
qui sum sexe;
replace sexe=r(mean) if sexe==.;

	
******;
** we merge with stratification data;
	sort schoolid;
	merge schoolid using "Input\cct_stratum_an.dta";
		tab _merge;
		drop if _merge==2;
		assert _merge==3;
		drop _merge;

	sort schoolid schoolunitid;

*************************************************************;
save "Output\working_knowledge2",replace;
*************************************************************;


******************************************;
******************************************;
** Appending the two datasets;
******************************************;
******************************************;


forvalues j=1/2 {;

u "Output\working_knowledge`j'",clear;


drop if ks`j'_not_surveyed==. & ks`j'_not_surveyed_dir==. & ks`j'_not_surveyed_ens==.;

local vars "ks`j'_not_surveyed ks`j'_uncond
ks`j'_cond_5abs ks`j'_cond_abs ks`j'_cond_5abs_if_cond ks`j'_amount_cor";

gen year=2008+`j';
gen director=e5==1 | e5==3 if e5!=.;
replace director=1 if  ks`j'_not_surveyed_dir!=.;
replace director=0 if e5==. & ks`j'_not_surveyed_ens!=. & director==.;

save tp3,replace;
keep if ks`j'_not_surveyed_ens==1 & ks`j'_not_surveyed_dir==1;
replace director=0 if e5==. & ks`j'_not_surveyed_ens==1;
append using tp3;
erase tp3.dta;

keep schoolunitid-province sexe sexe_miss e5 year director
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss
	prel_toilet prel_toilet_miss 
	 `vars' stratum;

renpfix ks`j'_ ks_;

save tp`j',replace;

};


*** appending;
u tp1,clear;
append using tp2;
erase tp1.dta;
erase tp2.dta;


******;
** adding treatment variables;
gen control=(group==0);
gen anytransfer=(inrange(group,1,4));
gen mere=(benef=="Mother");
gen pere=(benef=="Father");
gen uncond=group==1;
gen anycond=(inrange(group,2,4));
gen anycond_mere=anycond==1 & mere==1;
gen satellite=(type_unit=="Satellite");
cap gen cond_pere=anycond*pere;
cap gen uncond_mere=uncond*mere;
cap gen uncond_pere=uncond*pere;
cap gen cond_mere=anycond*mere;



*************************************************************;
save "Output\working_knowledge_append",replace;
*************************************************************;





******************************************;
******************************************;
** Knowledge HOUSEHOLDS YEAR 1;
******************************************;
******************************************;

u "Input\cct_knowledge_households_year1_an",clear;


******;
** we _merge with visits dates;
sort schoolunitid;
preserve;
u "Input\cct_school_visits_an",clear;
keep schoolunitid  v2_date v2_heure v2_inacc;
duplicates drop schoolunitid,force;
sort schoolunitid;
save tp1,replace;

restore;
merge schoolunitid using tp1;
erase tp1.dta;	
ta _merge;
drop if _merge==2;
drop _merge;




*** surveyed;
gen surveyed=ksm_a13!=.  | ksm_a12!=.;
by schoolunitid,sort: egen tot_survey=total(surveyed);

******;
** date format;
gen v2_date_td=mdy(real(substr(v2_date,3,2)),real(substr(v2_date,1,2)),2000+real(substr(v2_date,5,2)));
format v2_date_td %td;


******;
** we drop if not in the sample;
drop if surveyed==0 & v2_date_td<17995;
drop if tot_survey==2 & surveyed==0;
drop if tot_survey==0 & surveyed==0 & (ksm_num_menage==3 | ksm_num_menage==4);


*****;
** we merge with knowledge year1 sample;
** to find which schools are not in the sample;
sort schoolunitid;
save tp1,replace;

u "Output\working_knowledge1",clear;

keep if ks1_not_surveyed!=.;
keep schoolunitid;
duplicates drop schoolunitid,force;

sort schoolunitid;
merge schoolunitid using tp1;
ta _merge;
drop if _merge==1;
drop if _merge==2 & surveyed==0 & tot_survey==0;
drop _merge;
erase tp1.dta;


******;
** we merge with school level data;
sort schoolunitid;
preserve;

u "Output\school_level_data",clear;
global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";

keep schoolunitid $school_var mere;
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
qui sum `var';
replace `var'=r(mean) if `var'==.;
};




*************************************;
** merge with HH level data;
preserve;
use "Output\foranalysis.dta", clear; 

gen cond_pere=anycond*pere;

******;
*** GENDER AND IDENTITY OF RESPONDENT ;

gen male_resp=.;
gen cm_resp=.;
gen ccm_resp=.;

global id_rep="j_id_rep";

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



local hhcontrols "bs_pchildren_enrolled bs_nchildren  bs_nchildren615  
	bs_pchildren_dropout 
	bs_pchildren_neverenrolled bs_own_cellphone bs_age_head";


keep hhid schoolid schoolunitid `hhcontrols';
duplicates drop hhid,force;	
	
keep if hhid!="";

duplicates drop hhid,force;
sort hhid;
save tp1,replace;

restore;
** we add HHs variables;
sort hhid;
merge hhid using tp1;
erase tp1.dta;
ta _merge ;


******;
** sampling weight;
gen sampled1=ksm_strate==1 & ksm_c1_!=.;
gen sampled2=ksm_strate==2 & ksm_c1_!=.;

gen baseline=_merge==2 | _merge==3;

by schoolunitid,sort: egen tot_s1=total(sampled1);
by schoolunitid,sort: egen tot_s2=total(sampled2);
by schoolunitid,sort: egen tot_base=total(baseline);
gen ksm_weight=tot_s1/tot_base if ksm_strate==1;
replace ksm_weight=(tot_s2/tot_base) if ksm_strate==2;
replace ksm_weight=1/ksm_weight;

drop if _merge==2;
drop _merge;


******;
*** MISSING HH CONTROLS;
foreach var in  `hhcontrols'{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};




********************************************;
** VARIABLES CREATION;

** attrition;
gen ksm_not_surveyed=1-surveyed;

** controls;
* gender resp;
gen ksm_gender=ksm_a13;
recode ksm_gender 1=0 2=1;

* echantillon reserve;
gen ksm_reserve=ksm_a6;
recode ksm_reserve 1=0 2=1;

gen ksm_date_v2=v2_date_td;

* miss values;
foreach var in  ksm_gender ksm_reserve ksm_date_v2{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};

** analysis variables; 
gen ksm_know_program_exist=ksm_c2_==1 | ksm_c1_==1 if ksm_c1_!=.;

gen ksm_cond_5abs=0 if ksm_know_program_exist==1;
forvalues i=1/5 {;
replace ksm_cond_5abs=1 if ksm_c4_`i'==3 & ksm_know_program_exist==1;;
};
gen ksm_cond_abs=ksm_cond_5abs;
forvalues i=1/5 {;
replace ksm_cond_abs=1 if ksm_c4_`i'==2 & ksm_know_program_exist==1;;
};
gen ksm_uncond=0 if ksm_know_program_exist==1;
replace ksm_uncond=1 if ksm_c4_1!=2 & ksm_c4_1!=3 & ksm_c4_1!=6 &
	ksm_c4_2!=2 & ksm_c4_2!=3 &  ksm_c4_2!=6 &
	ksm_c4_3!=2 & ksm_c4_3!=3 & ksm_c4_3!=6 &
	ksm_c4_4!=2 & ksm_c4_4!=3 & ksm_c4_4!=6 &
	ksm_c4_5!=2 & ksm_c4_5!=3 & ksm_c4_5!=6 & ksm_know_program_exist==1;

replace ksm_uncond=1 if ksm_c4_1==1 & ksm_c4_2==6 & ksm_c4_3==.
	& ksm_c4_5==. & ksm_know_program_exist==1;;
replace ksm_uncond=1 if (hhid=="A561004" | hhid=="A633005")
	& ksm_know_program_exist==1;


gen ksm_cond_nsp=0 if ksm_know_program_exist==1;
forvalues i=1/5 {;
replace ksm_cond_nsp=1 if ksm_c4_`i'==6 & ksm_know_program_exist==1;;
};
forvalues i=1/5 {;
replace ksm_cond_nsp=0 if ksm_c4_`i'!=6 & ksm_c4_`i'!=. & ksm_know_program_exist==1;;
};

gen ksm_cond_5abs_if_cond=ksm_cond_5abs if ksm_cond_abs==1;

 
local var_analysis ksm_not_surveyed ksm_know_program_exist ksm_uncond 
	ksm_cond_5abs ksm_cond_abs ksm_cond_nsp ksm_cond_5abs_if_cond;

foreach x in `var_analysis' {;
gen `x'_s1=`x' if  ksm_strate==1;
gen `x'_s2=`x' if  ksm_strate==2;
};


	
******;
** we merge with stratification data;
	sort schoolid;
	merge schoolid using "Input\cct_stratum_an.dta";
		tab _merge;
		drop if _merge==2;
		drop _merge;

	sort schoolid schoolunitid;


*****;
** adding treatment variables;
gen control=(group==0);
gen anytransfer=(inrange(group,1,4));
replace mere=(benef=="Mother");
gen pere=(benef=="Father");
gen uncond=group==1;
gen anycond=(inrange(group,2,4));
gen anycond_mere=anycond==1 & mere==1;
gen satellite=(type_unit=="Satellite");
cap gen cond_pere=anycond*pere;
cap gen uncond_mere=uncond*mere;
cap gen uncond_pere=uncond*pere;
cap gen cond_mere=anycond*mere;

	
	

*************************************************************;
save "Output\working_knowledge3",replace;
*************************************************************;
 

 
 

******************************************;
******************************************;
** Knowledge HOUSEHOLDS YEAR 2 (Endline survey);
******************************************;
******************************************;

#delimit;
cap clear matrix;
clear;
set mem 500m;
set more off;

use "Output\foranalysis.dta", clear; 

***************;
** WE ADD HHS level controls;
***************;

*** GENDER AND IDENTITY OF RESPONDENT;
gen male_resp=.;
gen cm_resp=.;
gen ccm_resp=.;

global id_rep="j_id_rep";

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


*** MISSING HH CONTROLS;
foreach var in bs_nchildren bs_nchildren615 bs_pchildren_dropout 
bs_pchildren_neverenrolled bs_pchildren_enrolled bs_own_cellphone bs_age_head{;
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
qui sum `var';
replace `var'=r(mean) if `var'==.;
};



*****************************;
** Variables creation;
*****************************;

******;
** ever heard of the program (m8 m9);
gen ksm2_know_program_exist=(m8==1 | m9==1) if m8!=. & control==0;

******;
** uncond;
gen ksm2_uncond=(m13==1 & (m14>3 | m14==-99)) | (m13==2 & (m14==4 | m14==5)) 
		if m13!=. & control==0 & ksm2_know_program_exist==1;

******;
** cond don'ty know on what;
gen ksm2_cond_nsp=m14==-99 if m13!=. & control==0 & ksm2_know_program_exist==1;
		
******;
** cond on attendance;
gen ksm2_cond_abs=m14<4 & m14!=-99 if m13!=. & control==0 & ksm2_know_program_exist==1;

******;
** 5 abs if thinks its cond;
gen ksm2_cond_5abs_if_cond=m14==1 if ksm2_cond_abs==1 & ksm2_know_program_exist==1;



******;
** we add weights;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;

** and some treatment variables;
cap gen cond_pere=anycond*pere;
cap gen uncond_mere=uncond*mere;
cap gen uncond_pere=uncond*pere;
cap gen cond_mere=anycond*mere;



** SAVING;
*************************************************************;
save "Output\working_knowledge4",replace;
*************************************************************;
 
