#delimit;
cap clear matrix ;
clear;
set more off;


*************************************;
use "Output\indiv_sectionA.dta", clear; 
	sort hhmid;


***********************************;
* we first merge with Section A and keep HH members 16 years old and more;

	merge hhmid using "Output\indiv_sectionG.dta";
		assert _merge==3;
		drop _merge;
		drop if hhmember==0;

** only if 6-15 years old;
keep if a13<16 & a13>5;

** keeping only control group;
*keep if group==0;

gen worked_last_30_days=g3==1 if g3==1 | g3==2;

gen average_hrs_worked_by_day=(g6_act1*g7_act1) if g6_act1!=. & g7_act1!=. & worked_last_30_days==1;
replace average_hrs_worked_by_day=average_hrs_worked_by_day+(g6_act2*g7_act2) 
			if g6_act2!=. & g7_act2!=. & worked_last_30_days==1;
replace average_hrs_worked_by_day=average_hrs_worked_by_day+(g6_act3*g7_act3) 
			if g6_act3!=. & g7_act3!=. & worked_last_30_days==1;
replace average_hrs_worked_by_day=average_hrs_worked_by_day/30 if average_hrs_worked_by_day>0;

gen worked_outside_hh=worked_last_30_days==1 & ((g5_act1!=7 & g5_act1!=8 & g5_act1!=.) 
	| (g5_act2!=7 & g5_act2!=8 & g5_act2!=.) | (g5_act3!=7 & g5_act3!=8 & g5_act3!=.))
			if worked_last_30_days!=.;
gen average_hrs_worked_by_day_self=average_hrs_worked_by_day if worked_outside_hh==0;
gen worked_self_hh=1-worked_outside_hh if worked_outside_hh!=.;
gen average_hrs_worked_by_day_out=average_hrs_worked_by_day if worked_outside_hh==1;

gen worked_more_10days_4hours=worked_last_30_days==1 & ( (g6_act1>10 & g6_act1!=.) & 
		( (g7_act1>4 & g7_act1!=.) | (g7_act1+g7_act2>4 & g7_act1!=. & g7_act2!=.) 
			| (g7_act1+g7_act2+g7_act3>4 & g7_act1!=. & g7_act2!=. & g7_act3!=.)))
				if worked_last_30_days!=.;

gen earnings_outside_hh=0 if worked_outside_hh==1;
forvalues i=1/3 {;
replace earnings_outside_hh=earnings_outside_hh+g7_3_act`i' if g7_3_act`i'>0 & g7_3_act`i'!=. & worked_outside_hh==1;
};
forvalues i=1/3 {;
replace earnings_outside_hh=. if earnings_outside_hh==0 & (g7_2_act`i'==1 | g7_3_act`i'==-99) ;
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
** mergeing with schooling status;
preserve;
u "Output\workingtable6",clear;
sort  hhmid;
duplicates drop hhmid,force;
save tp1,replace;
restore;
sort hhmid;
merge hhmid using tp1;
erase tp1.dta;
ta _merge;
drop if _merge==2;
drop _merge;



** SAVING;
*********************************;
save "Output\workingtable_child_work",replace;
*********************************;

				



