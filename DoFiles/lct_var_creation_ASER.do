#delimit;
cap clear matrix;
clear;
set mem 500m;
set more off;


****************************************************;
** CREATION VARIABLE FOR LEARNING ASER TESTS;
****************************************************;



********************************************;
********************************************;
*** 1. GET BASELINE INFO ABOUT CHILD *********;
********************************************;
********************************************;

**********************************;
**********************************;
** 1.1 GET BASIC DEMOGRAPHIC INFO;
**********************************;
**********************************;
#delimit;
use "Input\cct_baseline_an.dta", clear; 

keep hhid-id8 a1_1-a20_23;

******************************************;
* NEED TO RESHAPE DATA INTO LONG FORMAT;
******************************************;
* to do reshape, first need to rename a number of variables;

foreach i of numlist 1/23 {;

	foreach q of numlist 1/20 {;
		cap rename a`q'_`i' a`q'_id`i';
	};

	foreach q of numlist 1/6 {;
		cap rename a14_`i'_`q' a14_`q'_id`i';
	};

	cap rename a14_`i'_nrns a14_nrns_id`i';

	foreach q of numlist 1/3 {;
		cap rename a15_`i'_`q' a15_`q'_id`i';
	};

	cap rename a15_`i'_nrns a15_nrns_id`i';
	cap rename a17_`i'_cycle a17_cycle_id`i';
	cap rename a17_`i'_niveau a17_niveau_id`i';
};


*need to preserve labels;
foreach var in a1_id a2_id a3_id a4_id a5_id a6_id a7_id a8_id a9_id 
a10_id a11_id a12_id a13_id a14_1_id a14_2_id a14_3_id a14_4_id 
a14_5_id a14_6_id a14_nrns_id a15_1_id a15_2_id a15_3_id a15_nrns_id 
a16_id a17_cycle_id a17_niveau_id a18_id a19_id a20_id {;
        local l`var' : variable label `var'1;
 };

* actual reshape;
reshape long  a1_id a2_id a3_id a4_id a5_id a6_id a7_id a8_id a9_id 
a10_id a11_id a12_id a13_id a14_1_id a14_2_id a14_3_id a14_4_id 
a14_5_id a14_6_id a14_nrns_id a15_1_id a15_2_id a15_3_id a15_nrns_id 
a16_id a17_cycle_id a17_niveau_id a18_id a19_id a20_id
, i(hhid) j(member);

*need to restore labels;
foreach var in a1_id a2_id a3_id a4_id a5_id a6_id a7_id a8_id a9_id 
a10_id a11_id a12_id a13_id a14_1_id a14_2_id a14_3_id a14_4_id 
a14_5_id a14_6_id a14_nrns_id a15_1_id a15_2_id a15_3_id a15_nrns_id 
a16_id a17_cycle_id a17_niveau_id a18_id a19_id a20_id {;
        label var `var' "`l`var''";
 };


*drop if a1_id==.;
gen id_enf_test=member;
sort hhid id_enf_test;
save "Output\baselinedemo_tomerge", replace;


**********************************;
**********************************;
** 1.2. GET SCHOOLING INFO;
**********************************;
**********************************;
use "Input\cct_baseline_an", clear; 

******************************************;
* NEED TO RESHAPE DATA INTO LONG FORMAT;
******************************************;
* to do reshape, first need to rename a number of variables;

foreach i of numlist 1/6 {;

	foreach q of numlist 1/46 {;
		cap rename d`q'_`i' d`q'_id`i';
	};
	foreach q of numlist 1/4 {;
		cap rename e`q'_`i' e`q'_id`i';
	};

	cap rename d4_`i'_1 d4_1_id`i';
	cap rename d4_`i'_2 d4_2_id`i'; 

	foreach q of numlist 1/17 {;
		cap rename d7_`i'_`q' d7_`q'_id`i';
	};
	cap rename d7_`i'_nr d7_nr_id`i';
	cap rename d7_`i'_ns d7_ns_id`i';

	foreach q of numlist 1/23 {;
		cap rename d10_`i'_`q' d10_`q'_id`i';
	};
	cap rename d10_`i'_nr d10_nr_id`i';
	cap rename d10_`i'_ns d10_ns_id`i';
	cap rename d12_`i'_cycle d12_cycle_id`i';
	cap rename d12_`i'_niveau d12_niveau_id`i';
	cap rename d19_`i'_num d19_num_id`i';
	
	foreach q of numlist 1/8 {;
		cap rename d20_`i'_`q' d20_`q'_id`i';
	};
	cap rename d20_`i'_ns d20_ns_id`i';
	cap rename d24_`i'_cycle d24_cycle_id`i';
	cap rename d24_`i'_niveau d24_niveau_id`i';
	
	foreach q of numlist 1/8 {;
		cap rename d32_`i'_`q' d32_`q'_id`i';
	};
	cap rename d32_`i'_ns d32_ns_id`i';

	foreach q of numlist 1/3 {;
		cap rename d35_`i'_`q' d35_`q'_id`i';
	};
	cap rename d35_`i'_ns d35_ns_id`i';

	foreach q of numlist 11 12 21 22 31 32 41 42 51 52 61 62 71 72 {;
		cap rename d45_`i'_`q' d45_`q'_id`i';
		cap rename d47_`i'_`q' d47_`q'_id`i';
	};
	cap rename  id_enfant_`i'  id_enfant_id`i';
	foreach q of numlist 43 53 63 73 {;
		cap rename d47_`i'_`q' d47_`q'_id`i';
	};
	
	cap rename e1_`i'_num e1_num_id`i'; 
	foreach q of numlist 1/2 {;
		cap rename e5_`i'_`q' e5_`q'_id`i';
		cap rename e6_`i'_`q' e6_`q'_id`i';
		cap rename e7_`i'_`q' e7_`q'_id`i';
	};

};



keep hhid b1- b14_2 d1_id1- f20_periode ;

destring d9_id5, force replace;
destring d19_id*, replace;
destring d22_id*, replace;
tostring d26_id6 d27_id6 d28_id6 d30_id6, replace;

destring d34_id*, replace;
destring d41_id3  d45_32_id3 d45_42_id5 e5_2_id1, force replace;
destring d42_id6, replace;
destring e1_id*, replace;

*need to preserve labels;
foreach var in d1_id  d2_id d3_id d4_1_id d4_2_id d5_id d6_id 
d7_1_id d7_2_id d7_3_id d7_4_id d7_5_id d7_6_id d7_7_id d7_8_id d7_9_id 
d7_10_id d7_11_id d7_12_id d7_13_id d7_14_id d7_15_id d7_16_id d7_17_id d7_nr_id d7_ns_id
 d8_id d9_id 
d10_1_id d10_2_id d10_3_id d10_4_id d10_5_id d10_6_id d10_7_id d10_8_id d10_9_id
 d10_10_id d10_11_id d10_12_id d10_13_id d10_14_id d10_15_id d10_16_id d10_17_id 
 d10_18_id d10_19_id d10_20_id d10_21_id d10_22_id d10_23_id d10_nr_id d10_ns_id 
d11_id d12_cycle_id d12_niveau_id d13_id d14_id d15_id d16_id d17_id d18_id d19_id d19_num_id 
d20_1_id d20_2_id d20_3_id d20_4_id d20_5_id d20_6_id d20_7_id d20_8_id d20_ns_id 
d21_id d22_id
 d23_id d24_cycle_id d24_niveau_id d25_id d26_id d27_id d28_id d29_id d30_id d31_id 
 d32_1_id d32_2_id d32_3_id d32_4_id d32_5_id d32_6_id d32_7_id d32_8_id d32_ns_id 
 d33_id d34_id d35_1_id d35_2_id d35_3_id d35_ns_id 
d36_id d37_id d38_id d39_id d40_id
 d41_id d42_id d43_id d44_id d45_11_id d45_12_id d45_21_id d45_22_id d45_31_id d45_32_id 
 d45_41_id d45_42_id d45_51_id d45_52_id d45_61_id d45_62_id d45_71_id d45_72_id d46_id 
 d47_11_id d47_12_id d47_21_id d47_22_id d47_31_id d47_32_id d47_41_id d47_42_id d47_43_id 
 d47_51_id d47_52_id d47_53_id d47_61_id d47_62_id d47_63_id d47_71_id d47_72_id d47_73_id
id_enfant_id  e1_id e1_num_id e2_id e3_id e4_id e5_1_id e5_2_id e6_1_id e6_2_id e7_1_id e7_2_id {;
        local l`var' : variable label `var'1;
 };

drop d4_id6 d7_autre id_abond*;
 
*actual reshape;
reshape long 
d1_id  d2_id d3_id d4_1_id d4_2_id d5_id d6_id 
d7_1_id d7_2_id d7_3_id d7_4_id d7_5_id d7_6_id d7_7_id d7_8_id d7_9_id d7_10_id d7_11_id d7_12_id d7_13_id d7_14_id d7_15_id d7_16_id d7_17_id d7_nr_id d7_ns_id
 d8_id d9_id 
d10_1_id d10_2_id d10_3_id d10_4_id d10_5_id d10_6_id d10_7_id d10_8_id d10_9_id d10_10_id d10_11_id d10_12_id d10_13_id d10_14_id d10_15_id d10_16_id d10_17_id d10_18_id d10_19_id d10_20_id d10_21_id d10_22_id d10_23_id d10_nr_id d10_ns_id 
d11_id d12_cycle_id d12_niveau_id d13_id d14_id d15_id d16_id d17_id d18_id d19_id d19_num_id 
d20_1_id d20_2_id d20_3_id d20_4_id d20_5_id d20_6_id d20_7_id d20_8_id d20_ns_id 
d21_id d22_id
 d23_id d24_cycle_id d24_niveau_id d25_id d26_id d27_id d28_id d29_id d30_id d31_id d32_1_id d32_2_id d32_3_id d32_4_id d32_5_id d32_6_id d32_7_id d32_8_id d32_ns_id d33_id d34_id d35_1_id d35_2_id d35_3_id d35_ns_id 
d36_id d37_id d38_id d39_id d40_id
 d41_id d42_id d43_id d44_id d45_11_id d45_12_id d45_21_id d45_22_id d45_31_id d45_32_id d45_41_id d45_42_id d45_51_id d45_52_id d45_61_id d45_62_id d45_71_id d45_72_id d46_id d47_11_id d47_12_id d47_21_id d47_22_id d47_31_id d47_32_id d47_41_id d47_42_id d47_43_id d47_51_id d47_52_id d47_53_id d47_61_id d47_62_id d47_63_id d47_71_id d47_72_id d47_73_id
id_enfant_id  e1_id e1_num_id e2_id e3_id e4_id e5_1_id e5_2_id e6_1_id e6_2_id e7_1_id e7_2_id
, i(hhid) j(child_col);

*need to restore labels;
foreach var in d1_id  d2_id d3_id d4_1_id d4_2_id d5_id d6_id 
d7_1_id d7_2_id d7_3_id d7_4_id d7_5_id d7_6_id d7_7_id d7_8_id 
d7_9_id d7_10_id d7_11_id d7_12_id d7_13_id d7_14_id d7_15_id d7_16_id d7_17_id d7_nr_id d7_ns_id
 d8_id d9_id 
d10_1_id d10_2_id d10_3_id d10_4_id d10_5_id d10_6_id d10_7_id d10_8_id
 d10_9_id d10_10_id d10_11_id d10_12_id d10_13_id d10_14_id d10_15_id 
 d10_16_id d10_17_id d10_18_id d10_19_id d10_20_id d10_21_id d10_22_id d10_23_id d10_nr_id d10_ns_id 
d11_id d12_cycle_id d12_niveau_id d13_id d14_id d15_id d16_id d17_id d18_id d19_id d19_num_id 
d20_1_id d20_2_id d20_3_id d20_4_id d20_5_id d20_6_id d20_7_id d20_8_id d20_ns_id 
d21_id d22_id
 d23_id d24_cycle_id d24_niveau_id d25_id d26_id d27_id d28_id d29_id d30_id
 d31_id d32_1_id d32_2_id d32_3_id d32_4_id d32_5_id d32_6_id d32_7_id d32_8_id
 d32_ns_id d33_id d34_id d35_1_id d35_2_id d35_3_id d35_ns_id 
d36_id d37_id d38_id d39_id d40_id
 d41_id d42_id d43_id d44_id d45_11_id d45_12_id d45_21_id d45_22_id d45_31_id 
 d45_32_id d45_41_id d45_42_id d45_51_id d45_52_id d45_61_id d45_62_id d45_71_id
 d45_72_id d46_id d47_11_id d47_12_id d47_21_id d47_22_id d47_31_id d47_32_id d47_41_id
 d47_42_id d47_43_id d47_51_id d47_52_id d47_53_id d47_61_id
 d47_62_id d47_63_id d47_71_id d47_72_id d47_73_id
id_enfant_id  e1_id e1_num_id e2_id e3_id e4_id e5_1_id e5_2_id e6_1_id e6_2_id e7_1_id e7_2_id {;
        label var `var' "`l`var''";
 };

*drop if d1_id==2;
gen id_enf_test=d2_id;
sort hhid id_enf_test;
save "Output\baselineschooling_tomerge", replace;


****************************************************;
****************************************************;
******2. MERGING ASER TESTS TO BASELINE INFO ********;
****************************************************;
****************************************************;
#delimit;
use "Input\cct_aser_an.dta", clear;

drop if prenom_enf_test=="pas d'enfant à tester";
sort hhid id_enf_test;
merge hhid id_enf_test using "Output\baselinedemo_tomerge", _merge(merge_basedemo);
tab merge_basedemo;

drop if merge_basedemo==2;
sort hhid id_enf_test;
merge hhid id_enf_test using "Output\baselineschooling_tomerge", _merge(merge_baseschooling);
tab merge_baseschooling;
drop if merge_baseschooling==2;
* TO DO: we still have 99 obs that do not merge;


#delimit;
** We merge with stratification data;
	sort schoolid;
	merge schoolid using "Input\cct_stratum_an.dta";
		tab _merge;

		drop if _merge==2;
		drop _merge;

save "Output\ASERdata", replace;
erase "Output\baselinedemo_tomerge.dta";
erase "Output\baselineschooling_tomerge.dta";



*********************************************************;
**** 3. CREATE RHS VARIABLES ****************************;
*********************************************************;


use "Output\ASERdata", clear;
* create a satellite dummy;
 	gen satellite=0;
		replace satellite=1 if type_unit=="Satellite";


* create dummies for treatment groups;
	for any control uncond cond_teachers cond_inspectors cond_machines \ num 0/4 :
	 gen X=1 if group==Y \ 
	 replace X=0 if group!=Y & group!=. ;
	
	gen anycond=0 if group!=.;
		replace anycond=1 if group==2|group==3|group==4;
	gen anytransfer=1 if group!=.;
		replace anytransfer=0 if group==0;	
	gen pere=(benef=="Father");
	gen mere=(benef=="Mother");	
	gen uncond_mere=uncond*mere;
	gen anycond_mere=anycond*mere;
	gen anytrans_satellite=anytransfer*satellite;
	gen anytrans_mere_satellite=anytransfer*satellite*mere;
	gen anycond_satellite=anycond*satellite;
	gen anycond_mere_satellite=anycond*satellite*mere;


* create indiv controls;
gen age_2008=a13_id;
gen female=(a4_id==2);
gen inschool08=(d5_id==1) if d5_id!=.;
	gen inschool08_missing=(d5_id==.);
	replace inschool08=1 if  inschool08_missing==1;
gen out_school_baseline=(d5_id!=1) if d5_id!=.;

gen everenrolled=1 if d5_id==1;
	replace everenrolled=1 if d6_id==1;
	replace everenrolled=0 if d6_id==2;
gen everenrolled_missing= (everenrolled==.);
	replace everenrolled=1 if everenrolled_missing==1;	


*********************************************************;
*********************************************************;
**** 4. CREATE LHS VARIABLES ****************************;
*********************************************************;
*********************************************************;



******;
** score without standardization;
gen div=t6;
recode div (2=0);

gen attrited=0 if t1==1;
	replace attrited=1 if t1==2|t1==.;

gen know_digit=t3_2==5 if t3_2!=.;
label var know_digit "knows digits";
gen know_num=t4_2==5 if t4_2!=.;
label var know_num "knows numbers";
gen know_sub=t5_2>0 if t5_2!=.;
label var  know_sub "right at least 1 substraction";
gen know_div=div;
label var know_div "right at the divison";


******;
** correcting for consistency in Kids' answers;
replace know_digit=1 if (know_num==1 | know_sub==1 |  know_div==1);
replace know_num=1 if (know_sub==1 |  know_div==1);


******;
** dummies for categories;
gen all=1;
gen age510=(age_2008<10);
gen boys=female==0;	
gen girls=female==1;	
gen center=satellite==0;
gen sat=satellite==1;
gen out=out_school_baseline==1;
gen ins=1-out;
gen age6_9=age_2008>5 & age_2008<10 if age_2008!=.;
gen age10_12=age_2008>9 & age_2008<13 if age_2008!=.;

foreach x in "all" "boys" "girls" "center" "sat" "ins" "out" "age6_9" "age10_12" {;
	foreach k in "know_digit" "know_num" "know_sub" "know_div" {;
gen `k'_`x'=`k' if `x'==1;
	};
};


** droping duplicates; 
duplicates drop hhid,force;	
save tp1,replace;	
	


**************************;
** ;
use "Output\foranalysis.dta", clear;

gen cond_pere=anycond*pere;

****************************************;
*** GENDER AND IDENTITY OF RESPONDENT *;
****************************************;

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


**************************************;
*** MISSING HH CONTROLS;
**************************************;
foreach var in bs_pchildren_enrolled bs_nchildren bs_nchildren615 
bs_pchildren_dropout bs_pchildren_neverenrolled  
	bs_own_cellphone bs_age_head{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};

	
local hhcontrols "mother_resp other_resp survey_date survey_date_miss 
	bs_nchildren bs_nchildren_miss bs_nchildren615 bs_nchildren615_miss 
	bs_pchildren_dropout bs_pchildren_dropout_miss
	bs_pchildren_neverenrolled bs_pchildren_neverenrolled_miss
	bs_pchildren_enrolled bs_pchildren_enrolled_miss bs_own_cellphone
	bs_own_cellphone_miss bs_age_head bs_age_head_miss";


******;
** we need date of survey end;
gen survey_start=id12_3;
replace survey_start=99 if survey_start==.;

		#delimit;
keep hhid `hhcontrols' c0_1 survey_start;
duplicates drop hhid,force;	
keep if hhid!="";

sort hhid;
tempfile tp_aser_merge;
save `tp_aser_merge';

u tp1,clear;
erase tp1.dta;
** we add HHs variables;
sort hhid;
merge hhid using `tp_aser_merge';
ta _merge t1,m;
drop if _merge!=3;
* we have 13 HH that we drop because they merged with other study HH at endline;
drop _merge;




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



*****;
** day of the week survey;
gen dow_survey=dow(survey_date);
gen dow_survey_miss=dow_survey==. | dow_survey==0;
replace dow_survey=0 if dow_survey==.;


*****;
** school period;
gen school_period=c0_1==1;
gen school_period_miss=c0_1==. | c0_1==-8888;



*******;
* adding weights;
preserve;
u "Input\cct_hh_weights_an",clear;
drop if hhid=="";
duplicates drop hhid,force;
sort hhid;
save tp1,replace; 

restore;
** we add weight;
sort hhid;
merge hhid using tp1;
erase tp1.dta;
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;

******;
** adding treatment variables;
gen cond_pere=anycond*pere;
gen uncond_pere=uncond*pere;
gen cond_mere=anycond*mere;


isid hhid;

********************************************;
save "Output\workingtable_aser",replace;
********************************************;
