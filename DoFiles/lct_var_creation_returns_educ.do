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

** only if more than 15 years old;
drop if a13<18;
keep if a3==1 | a3==2;

******;
** we gen variables;

** educ level;
gen some_educ_no_koran=inrange(a17_cycle,3,7) if a17_cycle!=.;

gen completeprimary=inrange(a17_cycle,4,7) 
		| (a17_cycle==3 & a17_niveau==6) if a17_cycle!=.;

gen readwrite=a15_1==1 & a15_2==1 if a15_1!=. & a15_2!=.;



** employed;
gen employed=g5_act1==2 | g5_act2==2 | g5_act3==2;

** total of income if employed;
gen tot_income_employed=0 if employed==1; 
forvalues i=1/3 {;
replace tot_income_employed=tot_income_employed+g7_3_act`i'
	if employed==1 & g7_3_act`i'>0 & g7_3_act`i'!=. & g7_3_act`i'!=99;
};


*****;
** we add weights;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;





**************************************************;
save "output\workingtable_educ_return",replace;
**************************************************;

	
