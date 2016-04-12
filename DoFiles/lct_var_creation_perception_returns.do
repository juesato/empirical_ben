#delimit;
cap clear matrix;
clear;
set mem 500m;
set more off;


use "Output\foranalysis.dta", clear; 

************************************************;
************************************************;
* Var creation for analysis on PERCEPTION AND EDUC RETURNS;
************************************************;
************************************************;


****************************************;
*** GENDER AND IDENTITY OF RESPONDENT *;
****************************************;

gen male_resp=.;
gen cm_resp=.;
gen ccm_resp=.;

global id_rep="f_id_rep";

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


******************************;
* EDUCATION PERCEPTION;
**************************;

* Conseil de gestion ou autre association;

gen conseil_gestion=0 if f1_enf==2 | (f1!=. & f1!=-99);
	replace conseil_gestion=1 if f1==1;

gen partic_cgestion=0 if conseil_gestion!=.;
	replace partic_cgestion=1 if f2==1;
	replace partic_cgestion=. if f1==1 & (f2==-99 | f2==.);

* Education quality Index;

forvalues i=4/7 {;
gen f`i'_2=f`i';
};
recode f4_2 f5_2 f6_2 f7_2 (-99=.) (1=5) (2=6) (3=7) (4=8);
recode f4_2 f5_2 f6_2 f7_2 (5=4) (6=3) (7=2) (8=1);

global education f4_2 f5_2 f6_2 f7_2;

local i = 1; 
foreach var in $education {;
	summ `var', detail; 
	local mean = r(mean); 
	local std_s = r(sd); 
	gen outcome`i' = (`var'-`mean')/`std_s'; 
	local i = `i' + 1;
	}; 

*egen education_index= rsum(outcome1 outcome2 outcome3);

egen education_index= rsum(f4_2 f5_2 f6_2);

	replace education_index=education_index/3; 

foreach j in 4 5 6 {;
	replace education_index=. if f`j'_2==.;
		};

	drop outcome*;

gen unuseful_educ=f7==3 | f7==4 if f7>0 & f7<5;

*******;
* Importance of schooling;

	* we create a variable to identify missing answers;
		gen nanswers_f8=0;

foreach j of numlist 1(1)9{;
	gen school_`j'=0;
		replace school_`j'=1 if f8_`j'==1 & f8_`j'_ordre==1 | f8_`j'_ordre==2;
		replace nanswers_f8=nanswers_f8+1 if f8_`j'==1;
		};

foreach j of numlist 1(1)9{;
	replace school_`j'=. if nanswers_f8==0;
	};  

  	rename school_1 school_workchoice;
	rename school_2 school_knoworld;
	rename school_3 school_money;
	rename school_6 school_readwrite;


* Returns to Education;
local n 1;
foreach var in f9 f15 f21 f27 f33 f39 f45 f51 {;
	gen probempl_`n'=.;
		replace probempl_`n'=0 if `var'==1;
		replace probempl_`n'=0.25 if `var'==2;
		replace probempl_`n'=0.50 if `var'==3;
		replace probempl_`n'=0.75 if `var'==4;
		replace probempl_`n'=1 if `var'==5;
		local n = `n' + 1;
		};

** employed jobs;
local n 1;
foreach x in  9 15 21 27 33 39 45 51 {;
local y=`x'+1;
 gen pemployed_job_`n'=0 if f`x'>0 & f`x'<100;
	replace pemployed_job_`n'=0.25 if f`x'==2 & f`y'!=5 & f`y'!=6 & f`y'>0 & f`y'<100;
	replace pemployed_job_`n'=0.50 if f`x'==3 & f`y'!=5 & f`y'!=6 & f`y'>0 & f`y'<100;
	replace pemployed_job_`n'=0.75 if f`x'==4 & f`y'!=5 & f`y'!=6 & f`y'>0 & f`y'<100;
	replace pemployed_job_`n'=1 if f`x'==5 & f`y'!=5 & f`y'!=6 & f`y'>0 & f`y'<100;	
	local n=`n'+1;
};		
		
		
local n 1;
foreach var in f11 f17 f23 f29 f35 f41 f47 f53 {;
	gen meansalary_`n'=0 if probempl_`n'!=.;
		replace meansalary_`n'=. if (`var'_montant==-99 | (`var'_montant>=0 & `var'_montant!=. & `var'_periode==.));
		replace meansalary_`n'=`var'_montant if `var'_montant>=0 & `var'_montant!=. & `var'_periode!=.;

		replace meansalary_`n'=meansalary_`n'*4.35 if `var'_periode==1;
		replace meansalary_`n'=meansalary_`n'/12 if `var'_periode==3;
* mean salary for employment jobs if employed;
	gen mean_sal_empljob_`n'=meansalary_`n' if pemployed_job_`n'>0 & pemployed_job_`n'<100 ;
		local n = `n' + 1;
		
		};
		

local n 1;
foreach var in f12 f18 f24 f30 f36 f42 f48 f54 {;
	gen maxsalary_`n'=0 if probempl_`n'!=.;
		replace maxsalary_`n'=. if (`var'_montant==-99 | (`var'_montant>=0 & `var'_montant!=. & `var'_periode==.));
		replace maxsalary_`n'=`var'_montant if `var'_montant>=0 & `var'_montant!=. & `var'_periode!=.;

		replace maxsalary_`n'=maxsalary_`n'*4.35 if `var'_periode==1;
		replace maxsalary_`n'=maxsalary_`n'/12 if `var'_periode==3;
		local n = `n' + 1;
		};


local n 1;
foreach var in f13 f19 f25 f31 f37 f43 f49 f55 {;
	gen minsalary_`n'=0 if probempl_`n'!=.;
		replace minsalary_`n'=. if (`var'_montant==-99 | (`var'_montant>=0 & `var'_montant!=. & `var'_periode==.));
		replace minsalary_`n'=`var'_montant if `var'_montant>=0 & `var'_montant!=. & `var'_periode!=.;

		replace minsalary_`n'=minsalary_`n'*4.35 if `var'_periode==1;
		replace minsalary_`n'=minsalary_`n'/12 if `var'_periode==3;
		local n = `n' + 1;
		};


local n 1;
foreach var in f14 f20 f26 f32 f38 f44 f50 f56 {;
	gen probmsalary_`n'=0 if probempl_`n'!=.;
		replace probmsalary_`n'=. if `var'==-99 | (probempl_`n'!=0 & `var'==.);
		replace probmsalary_`n'=`var' if `var'>=0 & `var'<=100;
		local n = `n' + 1;
		
		};
		
foreach n of numlist 1(1)8 {;
	gen exp_meansal_`n'=(probmsalary_`n'/100)*meansalary_`n';
	};

** types of jobs;
local n 1;
foreach x in  9 15 21 27 33 39 45 51 {;
local y=`x'+1;
 gen phigh_job_`n'=0 if f`x'>0 & f`x'<100;
	replace phigh_job_`n'=0.25 if f`x'==2 & (f`y'==3 | f`y'>5) & f`y'>0 & f`y'<100;
	replace phigh_job_`n'=0.50 if f`x'==3 & (f`y'==3 | f`y'>5) & f`y'>0 & f`y'<100;
	replace phigh_job_`n'=0.75 if f`x'==4 & (f`y'==3 | f`y'>5) & f`y'>0 & f`y'<100;
	replace phigh_job_`n'=1 if f`x'==5 & (f`y'==3 | f`y'>5) & f`y'>0 & f`y'<100;	
	local n=`n'+1;
};


	
foreach var in probempl meansalary
		maxsalary minsalary probmsalary 
		exp_meansal phigh_job 
		pemployed_job mean_sal_empljob {;
	rename `var'_1 `var'_princompl_boys;
	rename `var'_2 `var'_prcompl_boys;
	rename `var'_3 `var'_college_boys;
	rename `var'_4 `var'_lycee_boys;
	rename `var'_5 `var'_princompl_girls;
	rename `var'_6 `var'_prcompl_girls;
	rename `var'_7 `var'_college_girls;
	rename `var'_8 `var'_lycee_girls;
	}; 


*****;
** we also want mean salary conditional on having a job;
foreach x in meansalary_princompl_boys
 meansalary_prcompl_boys meansalary_college_boys  meansalary_lycee_boys
 meansalary_princompl_girls
 meansalary_prcompl_girls meansalary_college_girls 
 meansalary_lycee_girls {;

gen `x'_c=`x';
replace `x'_c=. if `x'_c==0;
	};

******;
** difference of salary as education increase;
gen dif_lycee_boys= meansalary_lycee_boys- meansalary_college_boys;
gen dif_lycee_girls= meansalary_lycee_girls- meansalary_college_girls;

gen dif_prcomple_boys= meansalary_college_boys- meansalary_prcompl_boys;
gen dif_prcomple_girls= meansalary_college_girls- meansalary_prcompl_girls;

gen dif_princomple_boys= meansalary_prcompl_boys- meansalary_princompl_boys;
gen dif_princomple_girls= meansalary_prcompl_girls- meansalary_princompl_girls;
	


	

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


******;
** we add weight;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
drop if _merge==2;
assert _merge==3;
drop _merge;




	
	
************************************************;
save "Output\workingtable_returns",replace;
************************************************;
