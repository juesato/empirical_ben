#delimit;
cap clear matrix ;
clear;
clear mata;
set maxvar 20000;
set mem 500m;
set more off;

************************************************;
************************************************;
* Var creation for analysis on Child's time use;
************************************************;
************************************************;

***************************************;
use "Output\indiv_sectionC.dta", clear;


**************************************;
*** MISSING HH CONTROLS;
**************************************;
foreach var in bs_pchildren_enrolled bs_nchildren bs_nchildren615 
bs_pchildren_dropout bs_pchildren_neverenrolled bs_own_cellphone bs_age_head{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};


*******************************;
** OUTCOMES;
*******************************;
gen age_baseline=age_endline-2;

** We define time variables;
* by categorie;
	foreach j of numlist 11(1)14 21(1)25 31(1)41 51(1)53 61(1)68 71(1)77 81(1)87 91(1)93 {;
		gen act`j'=0;
			foreach i of numlist 1(1)43{;
				replace c3_`i'_1 = . if c3_`i'_1 == -77 | c3_`i'_1 == -99;
				replace act`j'=act`j'+2 if c3_`i'_1==`j' & inrange(`i',1,5);
				replace act`j'=act`j'+1 if c3_`i'_1==`j' & inrange(`i',6,43);
			};
			};
	foreach j of numlist 11(1)14 21(1)25 31(1)41 51(1)53 61(1)68 71(1)77 81(1)87 91(1)93 {;
		replace act`j'=act`j'*30;
		};


* by group;
	gen time_perso=0;
		foreach j of numlist 11(1)14 {;
			replace time_perso=time_perso+act`j';
			}; 

	gen time_school=0;
		foreach j of numlist 21(1)25 {;
			replace time_school=time_school+act`j';
			};

	gen time_chores=0;
		foreach j of numlist 31(1)41 {;
			replace time_chores=time_chores+act`j';
			};

	gen time_careothers=0;
		foreach j of numlist 51(1)53 {;
			replace time_careothers=time_careothers+act`j';
			};

	gen time_inwork=0;
		foreach j of numlist 61(1)68 {;
			replace time_inwork=time_inwork+act`j';
			};

	gen time_outsidework=0;
		foreach j of numlist 71(1)77 {;
			replace time_outsidework=time_outsidework+act`j';
			};

	gen time_social=0;
		foreach j of numlist 81(1)87 {;
			replace time_social=time_social+act`j';
			};

	gen time_leisure=0;
		foreach j of numlist 83(1)87 {;
			replace time_leisure=time_leisure+act`j';
			};
	
	gen time_other=0;
		foreach j of numlist 91(1)93 {;
			replace time_other=time_other+act`j';
			};

* specific activities;
	gen time_goinschool=act21+act22;

	gen time_inschool=act22;
	
	gen time_traveltoschool=act21;
	
	gen time_school_activ=act24+act25;
	
	gen time_homework=act23;

	gen time_hhagriculture=act61;

	gen time_hhlivestock=act62+act63;

	gen time_hhotherwork=act64+act65+act66+act67+act68;

	gen time_outagriculture=act71;

	gen time_outlivestock=act72;

	gen time_outother=act73+act74+act75+act76;

	gen time_play=act83+act87;

	gen time_visit=act84;

	gen time_sport=act85;

	gen time_tv=act86;

	gen time_ill=act91;

	gen time_rest=act92;


** we now get rids of kids that were not at home the previous 
* day and therefore we do not have data for them;
	egen time_total=rsum(act11-act93);
		sum time_total, detail;

	foreach var of varlist act11-time_rest {;
		replace `var'=. if time_total==0;
		};


	
****************************************************;
** Only 6-15 years old at baseline children;
keep if age_baseline>=6 & age_baseline<=15;
****************************************************;


******;
** var for boys girls and sat;

global time_use "time_perso time_school time_homework time_school_activ 
 time_inschool time_traveltoschool time_chores 
time_careothers time_inwork time_outsidework time_social time_other time_leisure 
time_hhagriculture time_hhlivestock time_hhotherwork
time_outagriculture time_outlivestock time_outother time_play time_tv time_rest";


** one impossible timetable we replace by missing;
gen tp1=time_perso==60;
foreach var in $time_use  {;
replace `var'=. if tp1==1;
};
drop tp1;

gen satellite=type_unit=="Satellite";


foreach var in $time_use {;
gen `var'_boys=`var' if girl==0;
gen `var'_girls=`var' if girl==1;
gen `var'_sat=`var' if satellite==1;
gen `var'_center=`var' if satellite==0;
gen `var'_schoolperiod=`var' if  schoolperiod==1;
};




************;
**** we add school level data;
cap drop _merge;
sort schoolunitid;
preserve;
u "Output\school_level_data",clear;

global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid $school_var;
sort schoolunitid;
 save tp1,replace;
restore;merge schoolunitid using tp1;
erase tp1.dta;	
ta _merge;
drop if _merge==2;
drop _merge;
foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};



*** survey day of the week ;
gen dow_survey=dow(survey_date);
replace dow_survey=0 if survey_date_miss==1;



******;
** We need grades of the kid at baseline;
** so we merge with section D;
preserve;
u "Output\indiv_sectionD",clear;

drop if hhmid=="";
duplicates drop hhmid,force;
sort hhmid;
save tp1,replace;

******;
restore;
sort hhmid;
merge hhmid using tp1;
erase tp1.dta;
ta _merge; 
drop if _merge==2;
drop _merge;


** we generate the grades variables;
gen bs_grade_var=bs_grade if bs_grade!=-99;
replace bs_grade_var=11 if  bs_neverinschool==1;
replace bs_grade_var=12 if  bs_dropout==1;
replace bs_grade_var=11 if  bs_age_d4<7 & bs_grade_var==.;
replace bs_grade_var=77 if  bs_grade_var==.;
label var bs_grade_var "grade at baseline, 11=never_enrolled, 12=dropped out 77=missing";


** we generate teacher absenteism in may to control for in regressions;
gen teach_abs=d41+d42 if d41!=. & d41!=-99 & d42!=. & d42!=-99;
gen teach_abs_miss=teach_abs==.;
sum teach_abs;
replace teach_abs=r(mean) if teach_abs==.;

gen teach_strike=d41 if d41!=. & d41!=-99;
gen teach_strike_miss=teach_strike==.;
sum teach_strike;
replace teach_strike=r(mean) if teach_strike==.;



******;
** we add weight;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;


******;
** and treatment variables;
gen control=group==0;
gen pere=benef=="Father";
gen mere=benef=="Mother";
gen cond_pere=anycond*pere;
*gen uncond_mere=uncond*mere;
*gen uncond_pere=uncond*pere;
gen cond_mere=anycond*mere;



** SAVING;
*********************************;
save "Output\workingtable8",replace;
*********************************;



