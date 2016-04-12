#delimit;

capture clear matrix;  
clear;
set mem 500m;
set maxvar 17000;
set more off;



**********************;
 * HH ENDLINE database;

use "Input\cct_endline_an.dta", clear;

	gen surveyed_august=0;
		replace surveyed_august=1 if id12_2==8;
		label var surveyed_august "1 if HH interviewed during the month of August 2010";

	gen surveyed_august_miss=0;
		replace surveyed_august_miss=1 if id12_2<6 | id12_2>8;

	keep hhid surveyed_august surveyed_august_miss;
	duplicates drop hhid, force;
	sort hhid;
	save "Output\end_temp.dta", replace; 



****************************************;
** BASELINE SECTION D at the child level;
****************************************;
#delimit;
use "Input\cct_baseline_an.dta", clear; 

	* we define variables of interest;
	qui foreach j of numlist 1(1)6 {;
		gen bs_name`j'="";
		gen bs_girl`j'=.;
		gen bs_age`j'=.;	
	qui foreach k of numlist 1(1)23 {;
			replace bs_name`j'=a2_`k' if d2_`j'==`k';
			replace bs_girl`j'=1 if d2_`j'==`k' & d2_`j'!=. & a4_`k'==2;
			replace bs_girl`j'=0 if d2_`j'==`k' & d2_`j'!=. & a4_`k'==1;
			replace bs_age`j'=a13_`k' if d2_`j'==`k';
			};
			};

	qui foreach j of numlist 1(1)6 {;
		gen bs_age_d4`j'=.;
			replace bs_age_d4`j'=2008-d4_`j'_2 if inrange(d4_`j'_2, 1990,2004);
			replace bs_age_d4`j'=bs_age_d4`j'-1 if inrange(d4_`j'_1,8,12);
			};		
	foreach j of numlist 1/6 {;
		count if (bs_age`j'>16 & bs_age`j'!=. & bs_age_d4`j'>16 & bs_age_d4`j'!=.) | (bs_age`j'<6 & bs_age_d4`j'<6);
		}; 
		* note: Section D baseline: there are 12 obs for which we need to fix age;


	foreach j of numlist 1/6 {;
		gen bs_enrolled`j'=(d5_`j'==1);
		gen bs_dropout`j'=(d5_`j'!=1 & d6_`j'==1);
		gen bs_neverinschool`j'=(d5_`j'!=1 & d6_`j'==2);
			foreach var in bs_enrolled`j' bs_dropout`j' bs_neverinschool`j'{ ;
				replace `var'=. if (bs_enrolled`j'==0 | bs_enrolled`j'==.) & (bs_dropout`j'==0 | bs_dropout`j'==.) & (bs_neverinschool`j'==0 | bs_neverinschool`j'==.);
		};
				
		gen bs_grade`j'=d24_`j'_niveau if d24_`j'_cycle==3 & d24_`j'_niveau!=.;
		gen bs_second_school`j'=d24_`j'_cycle==4 | d24_`j'_cycle==5 if d24_`j'_cycle!=.;
		
		};

* we compute a dummy=1 if droped out in 2007 - 2008;
destring d9_5,replace;
	foreach j of numlist 1/6 {;
		gen bs_dropout_2007_2008`j'=bs_dropout`j'==1 & 
			(bs_age_d4`j'==d8_`j' | bs_age_d4`j'==d8_`j'+1 & d9_`j'>8 & d9_`j'<13)
			if bs_dropout`j'!=. & (d8_`j'>5 & d8_`j'<17) & (bs_age_d4`j'>=d8_`j') 
			& (bs_age_d4`j'>5 & bs_age_d4`j'<17);		
	};	

	
	keep hhid  d2_* bs_name* bs_girl* bs_age* 
	bs_age_d4* bs_enrolled* bs_dropout* bs_neverinschool* 
	bs_grade* bs_second_school* bs_dropout_2007_2008*;

	reshape long d2_ bs_name bs_girl bs_age bs_age_d4 bs_enrolled bs_dropout
	bs_neverinschool bs_grade bs_second_school bs_dropout_2007_2008, 
	i(hhid) j(bs_child_column); 
		rename d2_ d2;
		sort hhid bs_child_column;

			gen misscolumn=(d2==. & bs_name=="" & bs_girl==. & bs_age==.);
			egen n_misscol=sum(misscolumn), by(hhid);
			codebook hhid if n_misscol==6;
			note: 10 households at baseline has no kid in section D;  
			drop misscolumn n_misscol;


		* we drop lines with no kid;
		drop if d2==. & bs_name=="" & bs_girl==. & bs_age==.;
			codebook hhid;
			* we now have 4822 households instead of 4855;

* we identify HH surveyed at endline;
		sort hhid;
		merge hhid using "Output\end_temp.dta";
			tab _merge;
			drop if _merge==2;
			rename _merge attrition;
			recode attrition (3=0);
			drop surveyed_august surveyed_august_miss;

* we create a child ID;
		tostring d2, replace;
		gen idlength=length(d2);
		replace d2="0"+d2 if idlength==1;
		drop idlength;
	   	gen bs_idmember=hhid+d2; 
		order bs_idmember;

	* 55 kids with no info on enrollment;

	rename d2 bs_d2;
	sort bs_idmember;
 	save "Output\bs_indiv_sectionD.dta", replace; 


*******************;
* BASELINE variables for verifying randomization;

#delimit;
set more off;
	use "Input\cct_baseline_an.dta", clear; 

	
	
	gen male_head=.;
		qui foreach i of numlist 1/23 {;
			replace male_head=1 if a3_`i'==1 & a4_`i'==1;
			replace male_head=0 if a3_`i'==1 & a4_`i'==2;
			};
			
	gen age_head=.;
	gen age_spouse=.;
replace age_spouse=. ;
		qui foreach i of numlist 1/23 {;
			replace age_head=a13_`i' if a3_`i'==1;
			replace age_spouse=a13_`i' if a3_`i'==2;
			};
replace age_head=. if age_head<15;

	gen npeople=0 ;
		qui foreach i of numlist 1/23 {;
		replace npeople=npeople+1 if a2_`i'!="" | a3_`i'!=.;
		};

	gen nmember=0;
		qui foreach i of numlist 1/23 {;
		replace nmember=nmember+1 if inrange(a5_`i',1,3) | a13_`i'!=.
			| a7_`i'!=.;
		};

	gen nchildren=0;
		qui foreach i of numlist 1/23 {;
		replace nchildren=nchildren+1 if a13_`i'<=15 & a13_`i'!=.;
		};

	gen ngirls=0;

		qui foreach i of numlist 1/23 {;
		replace ngirls=ngirls+1 if  a13_`i'<=15 & a4_`i'==2 & a13_`i'!=.;
		};

	gen nchildren615=0;
		qui foreach i of numlist 1/23 {;
		replace nchildren615=nchildren615+1 if  a13_`i'<=15 & a13_`i'>=6;
		};

gen nchildren1618=0;
		qui foreach i of numlist 1/23 {;
		replace nchildren1618=nchildren1618+1 if  a13_`i'>=16 & a13_`i'<=18;
		};
		
	gen nboys615=0;
		qui foreach i of numlist 1/23 {;
		replace nboys615=nboys615+1 if  a13_`i'<=15 & a13_`i'>=6 & a4_`i'==1 ;
		};
gen nboys1618=0;
		qui foreach i of numlist 1/23 {;
		replace nboys1618=nboys1618+1 if  a13_`i'>=16 & a13_`i'<=18  & a4_`i'==1;
		};

	gen ngirls615=0;
		qui foreach i of numlist 1/23 {;
		replace ngirls615=ngirls615+1 if  a13_`i'<=15 & a13_`i'>=6 & a4_`i'==2 ;
		};

		gen ngirls1618=0;
		qui foreach i of numlist 1/23 {;
		replace ngirls1618=ngirls1618+1 if a13_`i'>=16 & a13_`i'<=18  & a4_`i'==2;
		};

	
	gen head_amazygh=0;
		qui foreach i of numlist 1/23 {;
		replace head_amazygh=1 if a14_`i'_4==1 & a3_`i'==1;
		};

		gen nonmiss=0;
		qui foreach j of numlist 1/6 {;
		qui foreach i of numlist 1/23 {;
			replace nonmiss=1 if a14_`i'_`j'==1;
			};
			};
		replace head_amazygh=. if nonmiss==0;
			drop nonmiss; 

	gen head_readwrite=.;
	gen headwife_readwrite=.;
		qui foreach i of numlist 1/23 {;
		replace head_readwrite=1 if a15_`i'_1==1 & a15_`i'_2==1 & a3_`i'==1;
		replace head_readwrite=0 if (a15_`i'_1==2 | a15_`i'_2==2) & a3_`i'==1;
** we assume that if no level of education , the HH head cannot read and write;
		replace head_readwrite=0 if (a15_`i'_1==. & a15_`i'_2==.) & a3_`i'==1 & a17_`i'_cycle==1;
*wife;
		replace headwife_readwrite=1 if a15_`i'_1==1 & a15_`i'_2==1 & a3_`i'==2;
		replace headwife_readwrite=0 if (a15_`i'_1==2 | a15_`i'_2==2) & a3_`i'==2;
** we assume that if no level of education , the HH head wife cannot read and write;
		replace headwife_readwrite=0 if (a15_`i'_1==. & a15_`i'_2==.) & a3_`i'==2 & a17_`i'_cycle==1;

		
		};		

		gen nonmiss=0;
		qui foreach j of numlist 1/3 {;
		qui foreach i of numlist 1/23 {;
			replace nonmiss=1 if a15_`i'_`j'==1;
			};
			};
		replace head_readwrite=. if nonmiss==0;
		replace headwife_readwrite=. if nonmiss==0;
			drop nonmiss; 

	gen head_completeprimary=.;
		qui foreach i of numlist 1/23 {;
		replace head_completeprimary=1 if ((a17_`i'_cycle==3 & a17_`i'_niveau==6) | inrange(a17_`i'_cycle,4,7)) & a3_`i'==1;
		replace head_completeprimary=0 if ((a17_`i'_cycle==3 & inrange(a17_`i'_niveau,1,5)) | inrange(a17_`i'_cycle,1,2)) & a3_`i'==1;
		};
		
	gen head_some_educ=.;
		qui foreach i of numlist 1/23 {;
		replace head_some_educ=1 if inrange(a17_`i'_cycle,2,7) & a3_`i'==1;
		replace head_some_educ=0 if a17_`i'_cycle==1 & a3_`i'==1;
		};
		
	gen head_some_educ_no_koran=.;
		qui foreach i of numlist 1/23 {;
		replace head_some_educ_no_koran=1 if inrange(a17_`i'_cycle,3,7) & a3_`i'==1;
		replace head_some_educ_no_koran=0 if (a17_`i'_cycle==1 | a17_`i'_cycle==2)
			& a3_`i'==1;
		};

* wife of the HH head;
gen headwife_completeprimary=.;
		qui foreach i of numlist 1/23 {;
		replace headwife_completeprimary=1 if 
			((a17_`i'_cycle==3 & a17_`i'_niveau==6) 
			| inrange(a17_`i'_cycle,4,7)) & a3_`i'==2;
		replace headwife_completeprimary=0 if ((a17_`i'_cycle==3 
		& inrange(a17_`i'_niveau,1,5)) | inrange(a17_`i'_cycle,1,2)) & a3_`i'==2;
		};
		
	gen headwife_some_educ=.;
		qui foreach i of numlist 1/23 {;
		replace headwife_some_educ=1 if inrange(a17_`i'_cycle,2,7) & a3_`i'==2;
		replace headwife_some_educ=0 if a17_`i'_cycle==1 & a3_`i'==2;
		};
	gen headwife_some_educ_no_koran=.;
		qui foreach i of numlist 1/23 {;
		replace headwife_some_educ_no_koran=1 if inrange(a17_`i'_cycle,3,7) & a3_`i'==2;
		replace headwife_some_educ_no_koran=0 if (a17_`i'_cycle==1 | a17_`i'_cycle==2)
			& a3_`i'==2;
		};	
**;
* share educated for other members;
	gen tot_memb18plus=0;
	gen tot_memb18plus_nocm_ccm_a17=0;
qui foreach i of numlist 1/23 {;
		replace tot_memb18plus=tot_memb18plus+1 if inrange(a5_`i',1,3);
		replace tot_memb18plus_nocm_ccm_a17=tot_memb18plus_nocm_ccm_a17+1
	if a3_`i'!=1 & a3_`i'!=2 & inrange(a5_`i',1,3) & a13_`i'>17 & a17_`i'_cycle!=.;
		};
		
   * some educ;
gen tot_other_some_educ_no_koran=0;	
qui foreach i of numlist 1/23 {;
		replace tot_other_some_educ_no_koran=tot_other_some_educ_no_koran+1
	if a3_`i'!=1 & a3_`i'!=2 & inrange(a5_`i',1,3) & a13_`i'>17 
		& inrange(a17_`i'_cycle,3,7);
		};
gen sha_other_some_educ_no_koran=tot_other_some_educ_no_koran/tot_memb18plus_nocm_ccm_a17;

   * primary school competed;
gen tot_other_completeprimary=0;	
qui foreach i of numlist 1/23 {;
		replace tot_other_completeprimary=tot_other_completeprimary+1
	if a3_`i'!=1 & a3_`i'!=2 & inrange(a5_`i',1,3) & a13_`i'>17 
		& (inrange(a17_`i'_cycle,4,7) | (a17_`i'_cycle==6 & a17_`i'_niveau==6));		
		};
gen sha_other_completeprimary=tot_other_completeprimary/tot_memb18plus_nocm_ccm_a17;

	* read and write;
gen tot_memb18plus_nocm_ccm_a15=0;	
qui foreach i of numlist 1/23 {;
		replace tot_memb18plus_nocm_ccm_a15=tot_memb18plus_nocm_ccm_a15+1
	if a3_`i'!=1 & a3_`i'!=2 & inrange(a5_`i',1,3) 
	& a13_`i'>17 & a15_`i'_1!=. & a15_`i'_2!=.;
		};

gen tot_other_readwrite=0;	
qui foreach i of numlist 1/23 {;
		replace tot_other_readwrite=tot_other_readwrite+1
	if a3_`i'!=1 & a3_`i'!=2 & inrange(a5_`i',1,3) & a13_`i'>17 
		& a15_`i'_1==1 & a15_`i'_2==1;
		};
gen sha_other_readwrite=tot_other_readwrite/tot_memb18plus_nocm_ccm_a15;


	* schooling;
	qui foreach i of numlist 1/6 {;
		gen age`i'=.;
		gen gender`i'=.;
			qui foreach j of numlist 1/23 {;
			replace age`i'=a13_`j' if d2_`i'==`j' & a13_`j'>=0 & a13_`j'!=.;
			replace gender`i'=a4_`j' if d2_`i'==`j' & inrange(a4_`j',1,2);
				recode gender`i' (2=0); 
			};
			}; 

	gen nchildren_enrolled=0;
	gen nchildren_dropout=0;
	gen nchildren_neverenrolled=0;
		qui foreach i of numlist 1/6 {;
		replace nchildren_enrolled=nchildren_enrolled+1 if d5_`i'==1 ;
		replace nchildren_dropout=nchildren_dropout+1 if d5_`i'==2 & d6_`i'==1 ;
		replace nchildren_neverenrolled=nchildren_neverenrolled+1 if d5_`i'==2 & d6_`i'==2 ;
		};
	egen nchildren615D=rsum(nchildren_enrolled nchildren_dropout nchildren_neverenrolled);

	gen nboys_enrolled=0 ;
	gen nboys_dropout=0 ;
	gen nboys_neverenrolled=0 ;
		qui foreach i of numlist 1/6 {;
		replace nboys_enrolled=nboys_enrolled+1 if d5_`i'==1  & gender`i'==1;
		replace nboys_dropout=nboys_dropout+1 if d5_`i'==2 & d6_`i'==1  & gender`i'==1;
		replace nboys_neverenrolled=nboys_neverenrolled+1 if d5_`i'==2 & d6_`i'==2  & gender`i'==1;
		};
	egen nboys615D=rsum(nboys_enrolled nboys_dropout nboys_neverenrolled);

	gen ngirls_enrolled=0 ;
	gen ngirls_dropout=0;
	gen ngirls_neverenrolled=0 ;
		qui foreach i of numlist 1/6 {;
		replace ngirls_enrolled=ngirls_enrolled+1 if d5_`i'==1  & gender`i'==1;
		replace ngirls_dropout=ngirls_dropout+1 if d5_`i'==2 & d6_`i'==1 & gender`i'==1;
		replace ngirls_neverenrolled=ngirls_neverenrolled+1 if d5_`i'==2 & d6_`i'==2  & gender`i'==1;
		};
	egen ngirls615D=rsum(ngirls_enrolled ngirls_dropout ngirls_neverenrolled);

	foreach var in nchildren_enrolled nchildren_dropout nchildren_neverenrolled 
		nboys_enrolled nboys_dropout nboys_neverenrolled 
		ngirls_enrolled ngirls_dropout ngirls_neverenrolled {;
			replace `var'=. if nchildren615D==0;
			};

	foreach group in children boys girls {;
		gen p`group'_enrolled=n`group'_enrolled/n`group'615D;
		gen p`group'_dropout=n`group'_dropout/n`group'615D;
		gen p`group'_neverenrolled=n`group'_neverenrolled/n`group'615D;
		};

		drop nchildren615D nboys615D ngirls615D;

	foreach i of numlist 1/6 {;
		count if d5_`i'==2 & d6_`i'==.;
		};
	foreach i of numlist 1/6 {;
		count if d5_`i'==1 & d6_`i'!=.;
		};

		drop age1-gender6;


	* assets;
	gen nrooms=0;
		replace nrooms=b2 if b2>0 & b2<25;
	
	gen house_stone=(b3_1==3);
		replace house_stone=. if b3_1==.  | b3_1==-99;

	gen own_tv=.;
		replace own_tv=1 if b10_1==1 | b10_2==1;
		replace own_tv=0 if b10_1==2 & b10_2==2;
	
	gen own_fridge=.;
		replace own_fridge=1 if b10_5==1;
		replace own_fridge=0 if b10_5==2;

	gen own_cellphone=.;
		replace own_cellphone=1 if b10_20==1;
		replace own_cellphone=0 if b10_20==2;

	gen own_radio=.;
		replace own_radio=1 if b10_21==1;
		replace own_radio=0 if b10_21==2;

	gen own_land=.;
		replace own_land=1 if b12==1;
		replace own_land=0 if b12==2;

	gen gov_aid=.;
		replace gov_aid=1 if j23==1;
		replace gov_aid=0 if j23==2;

	gen bank_account=.;
		replace bank_account=1 if k15==1;		
		replace bank_account=0 if k15==2;

	gen elec=b6_1==1 if b6_1!=.;

	
	* perception of education;
forvalues i=4/7 {;
gen f`i'_2=f`i';
};
recode f4_2 f5_2 f6_2 f7_2 (-99=.) (1=5) (2=6) (3=7) (4=8);
recode f4_2 f5_2 f6_2 f7_2 (5=4) (6=3) (7=2) (8=1);


egen education_index= rsum(f4_2 f5_2 f6_2);

	replace education_index=education_index/3; 

foreach j in 4 5 6 {;
	replace education_index=. if f`j'_2==.;
		};
gen unuseful_educ=f7==3 | f7==4 if f7>0 & f7<5;
	

	
	* We compute monthly household consumption;
	#delimit; 
	gen cons1=0;
		qui foreach j of numlist 1/21 {;
			replace cons1=cons1+h1_`j' if h1_`j'>0 & h1_`j'!=.;
			};
		replace cons1=cons1*4.35;

	gen cons2=0;
		qui foreach j in 1 4 5 6 8 10 11 12 14 19 20 21 {;
			replace cons2=cons2+h2_`j' if h2_`j'>0 & h2_`j'!=.;
			};
		replace cons2=cons2*4.35;
			
	rename h3_30_2 h3_30; 
	rename h3_31_2 h3_31;
	rename h3_32_2 h3_32;

	gen cons3=0;
		qui foreach j of numlist 1/32 {;
			replace cons3=cons3+h3_`j' if h3_`j'>0 & h3_`j'!=.;
			};

	rename h4_32_2 h4_32; 
	rename h4_33_2 h4_33;

	gen cons4=0;
		qui foreach j of numlist 1/16 18/33 {;
			replace cons4=cons4+h4_`j' if h4_`j'>0 & h4_`j'!=.;
			};
			replace cons4=cons4/12;

	qui foreach var in cons2 cons3 cons4 cons1 {;
		replace `var'=. if cons1==0;
		};
 
	gen bs_monthly_consump=cons1 + cons2 + cons3 + cons4;
	* sum bs_monthly_consump, detail;

	qui foreach var in cons1 cons2 cons3 cons4 bs_monthly_consump {;
		replace `var'=. if bs_monthly_consump>30000;
		};

	gen bs_monthly_consump_pc=bs_monthly_consump/nmember;
	
	foreach group in top50 q1 q2 q3 q4 {;
		gen bs_cons_`group'=0 if bs_monthly_consump!=.;
		};

		sum bs_monthly_consump, detail;
			replace bs_cons_top50=1 if bs_monthly_consump>=r(p50) & bs_monthly_consump!=.;
			replace bs_cons_q1=1 if bs_monthly_consump<r(p25);
			replace bs_cons_q2=1 if bs_monthly_consump<r(p50) & bs_monthly_consump>=r(p25);
			replace bs_cons_q3=1 if bs_monthly_consump<r(p75) & bs_monthly_consump>=r(p50);
			replace bs_cons_q4=1 if bs_monthly_consump<r(p100) & bs_monthly_consump>=r(p75);



* we rename variables we want to keep and merge later with endline;
	foreach i of numlist 1/23 {;
		rename a2_`i' bs_a2_`i';
		rename a3_`i' bs_a3_`i';
		rename a4_`i' bs_a4_`i';
		rename a5_`i' bs_a5_`i';
		rename a13_`i' bs_a13_`i';
		};

	foreach i of numlist 1/6 {;
		rename d1_`i' bs_d1_`i';
		rename d2_`i' bs_d2_`i';
		rename d3_`i' bs_d3_`i';
		rename d4_`i'_1 bs_d4_`i'_1;
		rename d4_`i'_2 bs_d4_`i'_2;
		rename d5_`i' bs_d5_`i';
		rename d6_`i' bs_d6_`i';
		};

	foreach var of varlist male_head-cons4 {;
		rename `var' bs_`var';
		};

* we identify HH surveyed at endline;
	sort hhid;
	merge hhid using "Output\end_temp.dta";
		tab _merge;
		drop if _merge==2;
		rename _merge attrition;
		recode attrition (3=0);
		erase "Output\end_temp.dta";

	gen control=(group==0);
	gen anytransfer=(inrange(group,1,4));
	gen mere=(benef=="Mother");
	gen pere=(benef=="Father");
	gen uncond=group==1;
	gen anycond=(inrange(group,2,4));
	gen satellite=(type_unit=="Satellite");

*Base database;
	sort hhid;
	keep hhid-benef  bs_male_head-bs_cons4 bs_monthly_consump* bs_cons* bs_* 
	attrition control-satellite  surveyed_august surveyed_august_miss;
	save "Output\temp_baseline_forothers.dta", replace;

* Database to be merged with SectionD endline, individual data (we will use it to look for kids that do not merge between bs and end);
	keep hhid bs_a2* bs_a3_* bs_a4_* bs_a5_* bs_a13_* bs_d1_*
	bs_d2_* bs_d3_* bs_d4_* bs_d5_* bs_d6_* attrition;
	sort hhid;
	save "Output\temp_base_forsectionD.dta", replace;

* Database to check randomization;
	use "Output\temp_baseline_forothers.dta", clear;
	drop bs_a2* bs_a3_* bs_a4_* bs_a5_* bs_a13_* bs_d1_* bs_d2_* bs_d3_*
	bs_d4_* bs_d5_* bs_d6_*;
 	save "Output\baseline_randomization.dta", replace;

* Database of baseline covariates;
	use "Output\temp_baseline_forothers.dta", clear;
	drop bs_a3_* bs_a4_* bs_a5_* bs_a13_* bs_d1_* bs_d2_*
	bs_d3_* bs_d4_* bs_d5_* bs_d6_* attrition surveyed_august surveyed_august_miss;
	sort hhid;
	save "Output\baseline_cov.dta", replace;

	erase "Output\temp_baseline_forothers.dta";
	

	
	

	
*************************************;
** TAYSSIR ADMIN DATA;
*************************************;

#delimit;
use "Input\cct_tayssir_admin_data_an.dta", clear;

foreach x in  11_2008 12_2008 1_2008 2_2008 3_2008 4_2008
 5_2008 6_2008 9_2009 10_2009 11_2009 12_2009 1_2009 
 2_2009 3_2009 4_2009 5_2009 6_2009 {;
	gen transfert_miss_`x'=montant`x'==0 & (montant_th`x'==60 
 | montant_th`x'==80 | montant_th`x'==100);

 by hhid_tayssir,sort: egen trans_miss_HH_`x'=total(transfert_miss_`x');
 by hhid_tayssir,sort: egen mean_trans_miss_HH_`x'=mean(transfert_miss_`x');

		};

egen tot_trans_miss_HH=rsum(trans_miss_HH_*);
egen mean_trans_miss_HH=rsum(mean_trans_miss_HH_*);

	
	gen amt_transfer_admin0809 = 0;
	gen ntransf_admin0809 = 0;
	
	foreach var in 
		T1_9_10_2008normal T2_11_2_2008normal T3_3_6_2008normal 
		T4_9_10_2009normal T4_9_10_2009relicat T5_11_12_2009normal
		T6_1_2_2009normal T7_3_4_2009normal T8_5_6_2009normal	
		 {;

replace amt_transfer_admin0809=amt_transfer_admin0809+montant`var' if montant`var'>0 & montant`var'!=.;
replace ntransf_admin0809 =ntransf_admin0809 +1 if montant`var'>0 & montant`var'!=.;
			};

	gen paid_transfer_admin0809 = 0;
	gen ntransf_paid_admin0809 = 0;
	 foreach var in 
		T1_9_10_2008normal T2_11_2_2008normal T3_3_6_2008normal 
		T4_9_10_2009normal T4_9_10_2009relicat T5_11_12_2009normal T6_1_2_2009normal T7_3_4_2009normal T8_5_6_2009normal	
		TX_9_2_2008relicat TX_9_2_2009relicat TX_9_4_2009relicat TX_x_x_2008relicat TX_x_x_2009relicat {;

replace paid_transfer_admin0809=paid_transfer_admin0809+montant`var' if montant`var'>0 & montant`var'!=. & paye`var'=="Y";
replace ntransf_paid_admin0809 =ntransf_paid_admin0809 +1 if montant`var'>0 & montant`var'!=. & paye`var'=="Y";
			};


	duplicates drop hhid_tayssir
		montantT1_9_10_2008normal payeT1_9_10_2008normal montantT2_11_2_2008normal payeT2_11_2_2008normal 
		montantT3_3_6_2008normal payeT3_3_6_2008normal	
		montantT4_9_10_2009normal payeT4_9_10_2009normal montantT4_9_10_2009relicat payeT4_9_10_2009relicat 
		montantT5_11_12_2009normal payeT5_11_12_2009normal montantT6_1_2_2009normal payeT6_1_2_2009normal 
		montantT7_3_4_2009normal payeT7_3_4_2009normal montantT8_5_6_2009normal payeT8_5_6_2009normal	
		montantTX_9_2_2008relicat payeTX_9_2_2008relicat montantTX_9_2_2009relicat payeTX_9_2_2009relicat 
		montantTX_9_4_2009relicat payeTX_9_4_2009relicat montantTX_x_x_2008relicat payeTX_x_x_2008relicat 
		montantTX_x_x_2009relicat payeTX_x_x_2009relicat, force;


	
keep  hhid_endline-province amt_transfer_admin0809 paid_transfer_admin0809 ntransf*
	tot_trans_miss_HH mean_trans_miss_HH;

sort hhid_endline;

save "Output\tayssir_admin_data_allpilot.dta", replace;		

	keep if hhid_endline!="";
	isid hhid_endline;
	keep hhid_endline amt_transfer_admin0809 paid_transfer_admin0809 ntransf* 
			tot_trans_miss_HH mean_trans_miss_HH;
	sort hhid_endline;

save "Output\tayssir_admin_data.dta", replace;


**********************************************;
** ENDLINE Variables we will need all through;
**********************************************;
#delimit;
use "Input\cct_endline_an.dta", clear;


** HH size;
	gen npeople=0;
		qui foreach j of numlist 1(1)32 {;
		replace npeople=npeople+1 if a2_`j'!="" | a3_`j'!=.;
		};

	gen nmember=0;
		qui foreach j of numlist 1(1)32 {;
		replace nmember=nmember+1 if inrange(a5_`j',1,3) | a5_`j'==9;
		};

		
** We merge with baseline covariates database;
	sort hhid;

	merge hhid using "Output\baseline_cov.dta";

	foreach i of numlist 1/2 {;
		count if a2_`i'==bs_a2_`i';
		}; 
		drop if _merge==2;
		rename _merge onlyendlinehh;
			recode onlyendlinehh (3=0);
		drop bs_a2_*;
		

** Household surveyed during the school period;
	gen schoolperiod=0;
		replace schoolperiod=1 if c0_1==1;
		label var schoolperiod "1 if HH interviewed during school session";

	gen schoolperiod_miss=0;
		replace schoolperiod_miss=1 if c0_1!=1 & c0_1!=2; 

** more than 50% of HHs in the douar said that it's still school period;
by schoolunitid,sort: gen tot_child=_N;
by schoolunitid,sort: egen tot_schoolper=total(schoolperiod);
gen percent_period=tot_schoolper/tot_child;

gen schoolperiod_douar=percent_period>0.5;
drop tot_child tot_schoolper;

	
** Survey date: date in which the HH was surveyed;
	gen day=string(id12_1);
		replace day="" if day==".";
		gen lengthday=length(day);
		replace day="0"+day if lengthday==1 & day!=""; 

	gen month=string(id12_2);
		replace month="" if month==".";
		replace month="" if month=="0" | month=="1" | month=="2" | month=="3" | month=="5" | month=="9" | month=="10" | month=="11" | month=="12" | day=="";
		replace day="" if month=="";
		gen date=day+"0"+month+"2010";
		codebook date; 
	
	gen survey_date=date(date, "DMY");
		replace survey_date=0 if survey_date==.;
		label var survey_date "interview date";

	gen survey_date_miss=0;
		replace survey_date_miss=1 if survey_date==0;

		drop day month date;

** Household surveyed during August 2010 (month in which HHs received 4th transfer);
	gen surveyed_august=0;
		replace surveyed_august=1 if id12_2==8;
		label var surveyed_august "1 if HH interviewed during the month of August 2010";

	gen surveyed_august_miss=0;
		replace surveyed_august_miss=1 if id12_2<6 | id12_2>8;

		tab id12_2 if schoolperiod==1;
		* to be checked: we have 6% of HH with incoherent obs (declare to be in school period and surveyed after Juin 2012);

		
** We merge with stratification data;
	sort schoolid;
	merge schoolid using "Input\cct_stratum_an.dta";
		tab _merge;
		drop if _merge==2;
		drop _merge;

** We merge with Tayssir admin data;
	sort hhid_endline;

	merge hhid_endline using "Output\tayssir_admin_data.dta";
		tab _merge;
		drop if _merge==2;
		drop _merge;

	foreach var in amt_transfer_admin0809 ntransf_admin0809 paid_transfer_admin0809 ntransf_paid_admin0809 {;
		replace `var'=0 if `var'==. & group==0;
		};


** HH endline-baseline database for analysis;
save "Output\foranalysis.dta", replace; 






**************************;
* INDIV ENDLINE databases;
**************************;
* variables we want to keep in individual databases C, D and G;

	global hhvariables="bs_male_head-bs_cons_q4 mother_resp* father_resp* other_resp* 
		schoolperiod schoolperiod_miss schoolperiod_douar percent_period
		survey_date survey_date_miss surveyed_august surveyed_august_miss stratum";


** SECTION A
#delimit;
set more off;

use "Output\foranalysis.dta", clear; 
	keep hhid_endline-satellite a1_1-a20_32 stratum;

	reshape long a1_ a2_ a2_2_ a3_ a4_ a5_ a6_ a7_ a8_ a9_ a10_ a11_ a12_ a13_ 
			a14_1_ a14_2_ a14_3_ a14_4_ a14_5_ a14_6_ a14_nrns_ a15_1_ a15_2_ a15_3_ a15_nrns_ a16_ 
			a17_cycle_ a17_niveau_ a18_ a19_ a20_, i(hhid_endline) j(member);

	foreach var in a1 a2 a2_2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 
			a14_1 a14_2 a14_3 a14_4 a14_5 a14_6 a14_nrns a15_1 a15_2 a15_3 a15_nrns a16 
			a17_cycle a17_niveau a18 a19 a20 {;
			rename `var'_ `var';
			};

* we create a member ID;
		tostring member, replace;
		gen idlength=length(member);
		replace member="0"+member if idlength==1;
		drop idlength;
   	gen hhmid=hhid_endline+member; 
		drop member;

	gen hhmember=0;
		replace hhmember=1 if inrange(a5,1,3) | a5==9;
	save "Output\indiv_sectionA.dta", replace;   


	
	
	
*********************;
** SECTION C;

#delimit;
set more off;

use "Output\foranalysis.dta", clear; 


****************************************;
*** GENDER AND IDENTITY OF RESPONDENT *;
****************************************;

foreach j of numlist 1/12 {;

gen male_resp`j'=.;
gen cm_resp`j'=.;
gen ccm_resp`j'=.;

	qui foreach i of  numlist 1/27 {;
		replace male_resp`j'=1 if c_id_rep_`j'==`i' & a4_`i'==1;
		replace male_resp`j'=0 if c_id_rep_`j'==`i' & a4_`i'==2;
		replace cm_resp`j'=1 if c_id_rep_`j'==`i' & a3_`i'==1;
	 	replace ccm_resp`j'=1 if c_id_rep_`j'==`i' & a3_`i'==2;
		};

	gen mother_resp`j'=(ccm_resp`j'==1) * (male_resp`j'==0);
		replace mother_resp`j'=1 if cm_resp`j'==1 & male_resp`j'==0;
	gen father_resp`j'=(cm_resp`j'==1) * (male_resp`j'==1);
		replace father_resp`j'=1 if ccm_resp`j'==1 & male_resp`j'==1;
	gen other_resp`j'=(mother_resp`j'==0) * (father_resp`j'==0);
	};


** we create age and sex variables;
	foreach j of numlist 1(1)12 {;
		gen age_endline`j'=.;
		gen girl`j'=.;
	foreach k of numlist 1(1)32 {;
			replace age_endline`j'=a13_`k' if c1_`j'==`k';
			replace girl`j'=1 if c1_`j'==`k' & a4_`k'==2;
			replace girl`j'=0 if c1_`j'==`k' & a4_`k'==1;
			};
			};

** preparation before reshaping;
			
foreach i of numlist 2 3 4 5 {; 
gen c0_`i'=c0_1;
};
foreach i of numlist 7 8 9 10 {; 
gen c0_`i'=c0_6;
};
gen c0_12=c0_11;
gen c_enf_1=.;
gen c_enf_6=.;
gen c_enf_11=.;
			
	keep hhid_endline-province anytrans* 
	anycond* uncond* c_id_rep_1-c3_43_2_12  
	c0_2-c0_12 c_enf_1-c_enf_11 age_endline* girl* ${hhvariables};


*******;
** we reshape long;

reshape long
c_id_rep_ c_enf_ c0_ c1_ c2_ 
c3_1_1_ c3_1_2_ c3_2_1_ c3_2_2_ c3_3_1_ c3_3_2_ c3_4_1_ c3_4_2_ c3_5_1_ c3_5_2_ 
c3_6_1_ c3_6_2_ c3_7_1_ c3_7_2_ c3_8_1_ c3_8_2_ c3_9_1_ c3_9_2_ c3_10_1_ c3_10_2_
c3_11_1_ c3_11_2_ c3_12_1_ c3_12_2_ c3_13_1_ c3_13_2_ c3_14_1_ c3_14_2_ c3_15_1_ c3_15_2_
c3_16_1_ c3_16_2_ c3_17_1_ c3_17_2_ c3_18_1_ c3_18_2_ c3_19_1_ c3_19_2_ c3_20_1_ c3_20_2_ 
c3_21_1_ c3_21_2_ c3_22_1_ c3_22_2_ c3_23_1_ c3_23_2_ c3_24_1_ c3_24_2_ c3_25_1_ c3_25_2_
c3_26_1_ c3_26_2_ c3_27_1_ c3_27_2_ c3_28_1_ c3_28_2_ c3_29_1_ c3_29_2_ c3_30_1_ c3_30_2_
c3_31_1_ c3_31_2_ c3_32_1_ c3_32_2_ c3_33_1_ c3_33_2_ c3_34_1_ c3_34_2_ c3_35_1_ c3_35_2_
c3_36_1_ c3_36_2_ c3_37_1_ c3_37_2_ c3_38_1_ c3_38_2_ c3_39_1_ c3_39_2_ c3_40_1_ c3_40_2_
c3_41_1_ c3_41_2_ c3_42_1_ c3_42_2_ c3_43_1_ c3_43_2_ 
age_endline
girl
mother_resp father_resp other_resp
, i(hhid_endline) j(child_column);


order hhid_endline child_column c_id_rep_ c0_;


foreach var in
c_id_rep c_enf c0 c1 c2
c3_1_1 c3_1_2 c3_2_1 c3_2_2 c3_3_1 c3_3_2 c3_4_1 c3_4_2 c3_5_1 c3_5_2
c3_6_1 c3_6_2 c3_7_1 c3_7_2 c3_8_1 c3_8_2 c3_9_1 c3_9_2 c3_10_1 c3_10_2
c3_11_1 c3_11_2 c3_12_1 c3_12_2 c3_13_1 c3_13_2 c3_14_1 c3_14_2 c3_15_1 c3_15_2
c3_16_1 c3_16_2 c3_17_1 c3_17_2 c3_18_1 c3_18_2 c3_19_1 c3_19_2 c3_20_1 c3_20_2
c3_21_1 c3_21_2 c3_22_1 c3_22_2 c3_23_1 c3_23_2 c3_24_1 c3_24_2 c3_25_1 c3_25_2
c3_26_1 c3_26_2 c3_27_1 c3_27_2 c3_28_1 c3_28_2 c3_29_1 c3_29_2 c3_30_1 c3_30_2
c3_31_1 c3_31_2 c3_32_1 c3_32_2 c3_33_1 c3_33_2 c3_34_1 c3_34_2 c3_35_1 c3_35_2
c3_36_1 c3_36_2 c3_37_1 c3_37_2 c3_38_1 c3_38_2 c3_39_1 c3_39_2 c3_40_1 c3_40_2
c3_41_1 c3_41_2 c3_42_1 c3_42_2 c3_43_1 c3_43_2 
{;
rename `var'_ `var';
	};


drop if (c_enf==2 | c_enf==.) &  c1==.;
drop if c_enf==1 & c1==. & c2==. & c3_1_1==.;

* we create a child ID;

		gen idtemp=string(c1);
		gen idlength=length(idtemp);
		replace idtemp="0"+idtemp if idlength==1;
		drop idlength;
   	gen hhmid2=hhid+idtemp; 
	gen hhmid=hhid_endline+idtemp;
		drop idtemp;
	save "Output\indiv_sectionC.dta", replace;   


***********************;
** SECTON D: SCHOOLING;

#delimit;
set more off;

use "Output\foranalysis.dta", clear; 


****************************************;
*** GENDER AND IDENTITY OF RESPONDENT *;
****************************************;

gen male_resp=.;
gen cm_resp=.;
gen ccm_resp=.;

global id_rep="d_id_rep";

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


** we create age and sex variables;

	foreach j of numlist 1(1)12 {;
		gen age_endline`j'=.;	
		gen girl`j'=.;
		gen relation`j'=.;
	foreach k of numlist 1(1)32 {;
			replace age_endline`j'=a13_`k' if d2_`j'==`k' & d2_`j'!=.;
			replace girl`j'=1 if d2_`j'==`k' & d2_`j'!=. & a4_`k'==2;
			replace girl`j'=0 if d2_`j'==`k' & d2_`j'!=. & a4_`k'==1;
			replace relation`j'=a3_`k' if d2_`j'==`k' & a3_`k'>0 & a3_`k'!=.;
			};
			};


	keep hhid_endline-province anytrans* anycond* 
	uncond* d_id_rep-d51_autre_prec_q3 age_endline* girl* 
	relation* ${hhvariables};


* we reshape;
#delimit;
set more off;

tostring d3_12, replace;
tostring d14_9 d14_10 d14_11 d14_12, replace;
tostring d15_9 d15_10 d15_11 d15_12, replace;

tostring d17_9 d17_10 d17_11 d17_12 d26_12 d27_12 d28_12, replace;
 
reshape long 
d1_ d2_ d3_ d4_1_ d4_2_ d5_ d6_ 
d7_1_ d7_2_ d7_3_ d7_4_ d7_5_ d7_6_ d7_7_ d7_8_ d7_9_ d7_10_ 
d7_11_ d7_12_ d7_13_ d7_14_ d7_15_ d7_16_ d7_17_ d7_18_ d7_19_ d7_20_

d8_ d9_m_ d9_a_ 
d10_1_ d10_2_ d10_3_ d10_4_ d10_5_ d10_6_ d10_7_ d10_8_ d10_9_ d10_10_ 
d10_11_ d10_12_ d10_13_ d10_14_ d10_15_ d10_16_ d10_17_ d10_18_ d10_19_ 
d10_20_ d10_21_ d10_22_ d10_23_ d10_24_ d10_25_ d10_26_ d11_ 
d12_cycle_ d12_niveau_ d13_ d14_ d15_ d16_ d17_ d18_ d19_ 
d20_1_ d20_2_ d20_3_ d20_4_ d20_5_ d20_6_ d20_7_ d20_8_ d20_9_
d21_ d22_1_ d22_2_

d23_ d24_cycle_ d24_niveau_ d25_ d26_ d27_ d28_ d29_ d30_ d31_ 
d32_1_ d32_2_ d32_3_ d32_4_ d32_5_ d32_6_ d32_7_ d32_8_ d32_9_ 
d33_  d34_ d34_a_ d35_1_ d35_2_ d35_3_ d35_4_ d36_ d37_ d38_ d39_ d40_

d41_ d42_ d43_ d44_ 
d45_11_ d45_12_ d45_21_ d45_22_ d45_31_ d45_32_ d45_41_ d45_42_ d45_51_ d45_52_ 
d45_61_ d45_62_ d45_71_ d45_72_ 
d46_
d47_11_ d47_12_ d47_21_ d47_22_ d47_31_ d47_32_ d47_41_ d47_42_ d47_43_ 
d47_51_ d47_52_ d47_53_ d47_61_ d47_62_ d47_63_ d47_71_ d47_72_ d47_73_ 
d48_ d49_m_ d49_a_ d50_
d51_1_ d51_2_ d51_3_ d51_4_ d51_5_ d51_6_ d51_7_ d51_8_ d51_9_ d51_10_ 
d51_11_ d51_12_ d51_13_ d51_14_ d51_15_ d51_16_ d51_17_ d51_18_ d51_19_ 
d51_20_ d51_21_ d51_22_ d51_23_ d51_24_ d51_25_ d52_m_ d52_a_ d53_ 

age_endline 
girl
relation
, i(hhid_endline) j(child_column);


* we rename var;

foreach var in
d1 d2 d3 d4_1 d4_2 d5 d6 
d7_1 d7_2 d7_3 d7_4 d7_5 d7_6 d7_7 d7_8 d7_9 d7_10 
d7_11 d7_12 d7_13 d7_14 d7_15 d7_16 d7_17 d7_18 d7_19 d7_20

d8 d9_m d9_a 
d10_1 d10_2 d10_3 d10_4 d10_5 d10_6 d10_7 d10_8 d10_9 d10_10 
d10_11 d10_12 d10_13 d10_14 d10_15 d10_16 d10_17 d10_18 d10_19 
d10_20 d10_21 d10_22 d10_23 d10_24 d10_25 d10_26
d11 d12_cycle d12_niveau d13 d14 d15 d16 d17 d18 d19 
d20_1 d20_2 d20_3 d20_4 d20_5 d20_6 d20_7 d20_8 d20_9 
d21 d22_1 d22_2

d23 d24_cycle d24_niveau d25 d26 d27 d28 d29 d30 d31
d32_1 d32_2 d32_3 d32_4 d32_5 d32_6 d32_7 d32_8 d32_9
d33 d34 d34_a d35_1 d35_2 d35_3 d35_4 d36 d37 d38 d39 d40

d41 d42 d43 d44 
d45_11 d45_12 d45_21 d45_22 d45_31 d45_32 d45_41 d45_42 
d45_51 d45_52 d45_61 d45_62 d45_71 d45_72 
d46 
d47_11 d47_12 d47_21 d47_22 d47_31 d47_32 d47_41 d47_42 d47_43 
d47_51 d47_52 d47_53 d47_61 d47_62 d47_63 d47_71 d47_72 d47_73 
d48 d49_m d49_a d50
d51_1 d51_2 d51_3 d51_4 d51_5 d51_6 d51_7 d51_8 d51_9 d51_10 
d51_11 d51_12 d51_13 d51_14 d51_15 d51_16 d51_17 d51_18 d51_19 
d51_20 d51_21 d51_22 d51_23 d51_24 d51_25 d52_m d52_a d53 			
			{; 
			rename `var'_ `var';
			};


	* we drop lines with no data;
		drop if d1==. & d2==.;
		drop if (d1==2 & d2==.) | (d1==1 & d2==. & d3=="");
		drop if d1==-8888 & d3=="" & age_endline==.;


* we create child IDs for baseline and endline databases;
		tostring d2, replace;
		gen idlength=length(d2);
		replace d2="0"+d2 if idlength==1;
		drop idlength;
   	gen end_idmember=hhid_endline+d2; 
	gen bs_idmember=hhid+d2;


* we merge with baseline Section D;
	sort bs_idmember;
	merge bs_idmember using "Output\bs_indiv_sectionD.dta";
		tab _merge;
		tab _merge if bs_enrolled==1;

		gen status="";
			replace status="only endline" if _merge==1;
			replace status="onlybase-hhattrition" if _merge==2 & attrition==1;
			replace status="only baseline" if _merge==2 & attrition==0;
			replace status="merged" if _merge==3;

			rename _merge _merge_indivD;

		save "Output\temp_indivD_main.dta", replace;   


** we identify status of not merged kids and we merge with ;
** Section D individual main database; 
#delimit;
set more off;
	do "DoFiles\lct_sectionD_kidmerging";

	use "Output\temp_indivD_main.dta", clear;
		sort bs_idmember;
		merge bs_idmember using "Output\kid_statusD.dta";	
			assert _merge==3;
			drop _merge;	

* we create a final endline child ID;
   	gen hhmid=hhid_endline+d2;
		label var hhmid "ID member, unique endline"; 
		order hhmid;

	drop attrition child_column end_idmember bs_idmember bs_child_column bs_d2;

save "Output\indiv_sectionD.dta", replace;

erase "Output\temp_indivD_main.dta";
erase "Output\temp_base_forsectionD.dta";



**************************;
** SECTION G: ACTIVITIES;
#delimit;
use "Output\foranalysis.dta", clear; 


****************************************;
*** GENDER AND IDENTITY OF RESPONDENT *;

gen male_resp=.;
gen cm_resp=.;
gen ccm_resp=.;

global id_rep="g_id_rep";

qui foreach i of  numlist 1/32 {;
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



** We reshape;

keep hhid_endline-province anytrans* anycond* uncond* g_id_rep-g23_32 ${hhvariables};

reshape long
g1_ g3_ 
g4_act1_ g4_act2_ g4_act3_
g5_act1_ g5_act2_ g5_act3_
g6_act1_ g6_act2_ g6_act3_
g7_act1_ g7_act2_ g7_act3_
g7_2_act1_ g7_2_act2_ g7_2_act3_
g7_3_act1_ g7_3_act2_ g7_3_act3_
g7_4_act1_ g7_4_act2_ g7_4_act3_
g7_5_ g7_6_ g7_7_
g11_a1_ g12_a1_ g13_a1_ g14_a1_ g15_a1_
g11_a2_ g12_a2_ g13_a2_ g14_a2_ g15_a2_
g11_a3_ g12_a3_ g13_a3_ g14_a3_ g15_a3_
g16_ g17_ g18_ g19_ g20_ g21_ g21_cp_ g22_ g23_
	, i(hhid_endline) j(member);


foreach var in 
g1 g3 
g4_act1 g4_act2 g4_act3
g5_act1 g5_act2 g5_act3
g6_act1 g6_act2 g6_act3
g7_act1 g7_act2 g7_act3
g7_2_act1 g7_2_act2 g7_2_act3
g7_3_act1 g7_3_act2 g7_3_act3
g7_4_act1 g7_4_act2 g7_4_act3
g7_5 g7_6 g7_7 
g11_a1 g12_a1 g13_a1 g14_a1 g15_a1
g11_a2 g12_a2 g13_a2 g14_a2 g15_a2
g11_a3 g12_a3 g13_a3 g14_a3 g15_a3
g16 g17 g18 g19 g20 g21 g21_cp g22 g23
		{;
		rename `var'_ `var';
		};


* we create a member ID;

		tostring member, replace;
		gen idlength=length(member);
		replace member="0"+member if idlength==1;
		drop idlength;
   	gen hhmid=hhid_endline+member; 

	sort hhmid;
save "Output\indiv_sectionG.dta", replace;
