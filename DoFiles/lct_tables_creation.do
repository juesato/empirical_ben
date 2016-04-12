cap clear matrix  
clear
set mem 500m
set maxvar 20000
#delimit;
set more off;
set matsize 1000;


*********************************************************************;
***** TAYSSIR ANALYSIS: TABLE CONSTRUCTION;
*********************************************************************;



***********************************;
*** Global for reg variables and controls;
***********************************;

** dummies treatment;
global treatmentdummies11="uncond_mere cond_pere cond_mere";
global treatmentdummies10="anytransfer uncond_mere cond_pere cond_mere";


******;
** general;
** control when we use HH survey data;
global hhcontrols "bs_pchildren_enrolled bs_pchildren_enrolled_miss"; 
	
******;
** by Tables;
*(if not specified, all regression included strata dummies);

** Table1;
* no control ;


** Table2;
* no control ;


** Table 3;
* table 3_1;
global control_table3 "${hhcontrols} 
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";

* table 3_2;
global control_table3_2 "prel_elec prel_elec_miss prel_inacc_winter
		prel_inacc_winter_miss";


** Table 4;
* table 4 households;
global control_table4_hh "${hhcontrols}
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss
	ksm_reserve ksm_reserve_miss";

* table4 teachers;
global control_table4 "director sexe sexe_miss
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";

* table 4: HH with endline data;
global control_table4_hh_endline "${hhcontrols} 
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";
	

** Table 5 ;
* table 5_1 (HH data) (Control also used for table 8 and table A6);
global control_table5_1 "${hhcontrols} age_baseline girl
	bs_inschool08 bs_neverenrolled08 bs_inschool08_miss bs_neverenrolled08_miss
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";

* table5_2 (School visit data dropout) (Control also used for table A2_2);
global control_table5_2 "age_2008 agemissing female i.niv_baseline
	prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";

* table 5_3 (School visit data attendance) (Control also used for table 8);
global control_table5_3 "age_2008 female i.niv_baseline 
i.day_of_week day_of_week_miss i.visit
 prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";


** Table 6 ;
global control_table6 "${hhcontrols} age_baseline i.bs_grade_var girl i.dow_survey
 prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";


** Table 7 ;
global control_table7 "age_2008 female inschool08 inschool08_missing 
everenrolled everenrolled_missing ${hhcontrols}
i.survey_start
prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss
school_period school_period_miss";


** Table 8;
** part 1: same control as for table 5_1 and 5_3;
** part 2: same control as for table  5_3;
** part 3: same control as for table 6;


** Table9;
global control_table9 "${hhcontrols} 
prel_elec prel_elec_miss prel_inacc_winter prel_inacc_winter_miss";


** Appendix ;
** tableA1: attrition;
* no control ;

** tableA2;
* no control ;

** tableA3;
* no control ;

** table A4 ;
* see regression ;

** table A5 ;
* only means ;

** table A5 ;
* same as table 5 ;

** table A6 ;
* same as table 5 ;







******************************************;
******************************************;
******  TABLE 1  *******;
******************************************;
******************************************;
#delimit;
set more off;

u "Output\school_level_data",clear;


global table1_var obs multiniveau num_sections
v0_age v0_female v0_student_classroom_ratio
teacher_presence v0_presence prel_dist_road
 prel_inacc_winter prel_elec prel_toilet prel_dist_post;

 
gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";

local i -1;
foreach var of global table1_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} i.stratum, cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytrans anycond i.stratum, cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytrans pere i.stratum, cluster(schoolid);	
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
			
};


** only if we want the number of obs by group;
foreach x in  $treatmentdummies10 {;
count if `x'==1 ;
replace coef_`x'=string(r(N)) if _n==`i'+2;
};
count if pere==1 & uncond==1;
replace coef_anytrans=string(r(N)) if _n==`i'+2;
count if control==1 ;
replace mean_control=string(r(N)) if _n==`i'+2;
count;
replace N=r(N) if _n==`i'+2;

** number of school sectors;
foreach x in  $treatmentdummies10 {;
duplicates r schoolid if `x'==1 ;
replace coef_`x'=string(r(unique_value)) if _n==`i'+3;
};
duplicates r schoolid if pere==1 & uncond==1 ;
replace coef_anytrans=string(r(unique_value)) if _n==`i'+3;
duplicates r schoolid  if control==1 ;
replace mean_control=string(r(unique_value)) if _n==`i'+3;
duplicates r schoolid ;
replace N=r(unique_value) if _n==`i'+3;

*edit vars-p_val_mo_dif_fa  if _n<100;


outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table1.out"  if _n<100 ,replace;	





******************************************;
******************************************;
******  TABLE 2  *******;
******************************************;
******************************************;


**************************************;
* Checking randomization and attrition;
**************************************;


u "Output\workingtable_hh_baseline",clear;


** we trimed the top 1% for the monthly consumption;
sum bs_monthly_consump_pc,detail;
replace bs_monthly_consump_pc=. if bs_monthly_consump_pc>r(p99) | bs_monthly_consump_pc<r(p1);
replace attrition_aser=. if attrition_aser_no_test==1;


global table2_var attrition attrition_aser
sampling_frame_problem
bs_male_head bs_age_head bs_nmember  bs_nchildren615
bs_pchildren_enrolled bs_pchildren_neverenrolled bs_pchildren_dropout
bs_head_readwrite bs_head_completeprimary
bs_head_some_educ bs_monthly_consump_pc bs_own_land bs_own_cellphone
bs_own_tv bs_own_radio bs_bank_account bs_elec;


sort attrition;
gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 

local i -1;
foreach var of global table2_var {;
local i=`i'+2;

local weight "";
local weight2 "";
if `i'>4 {;
keep if attrition==0;
local weight "[pw=weight_hh]";
local weight2 "[iw=weight_hh]";
};

replace vars="`var'" if _n==`i';
	sum `var' `weight2' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} i.stratum `weight' , cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytrans anycond i.stratum `weight', cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytrans pere i.stratum `weight', cluster(schoolid);	
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
				
	};

** only if we want the number of obs by group;
foreach x in  $treatmentdummies10 {;
count if `x'==1 & attrition!=.;
replace coef_`x'=string(r(N)) if _n==`i'+2;
};
count if pere==1 & uncond==1 & attrition!=.;
replace coef_anytrans=string(r(N)) if _n==`i'+2;

count if control==1 & attrition!=.;
replace mean_control=string(r(N)) if _n==`i'+2;

count if attrition!=.;
replace N=r(N) if _n==`i'+2;

*edit vars-p_val_mo_dif_fa  if _n<100;

outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table2.out"  if _n<100 ,replace;	




*************************************;
************************************;
** TABLES 3: TAYSSIR TRANSFERS ;
***********************************;
*************************************;

#delimit;
set more off;

u "Output\workingtable_transfer_data",clear;


**********************************;
***  FATHER_UCT VS FATHER_CT/MOTHER_UCT/MOTHER COND: ONLY TREATMENT;
** Table 3: take up;

replace tot_trans_miss_HH=0 if group==1;
replace mean_trans_miss_HH=0 if group==1;


global table3_var 
ty_enrolled 
ty_enrolled_enrolled ty_enrolled_dropout
ty_percent_kids 
ty_mother_benef 
ty_onlymother_paid ty_onlyfather_paid 
ty_motherfather_paid  ty_mothersomeone_paid
ty_transp_amount
ntransf_paid_admin0809
amt_transfer_admin0809 
share_transfer_admin0809
tot_trans_miss_HH;

gen vars="";
gen mean_control="";
for any ${treatmentdummies11}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table3_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if uncond_pere==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

	xi: reg `var' ${treatmentdummies11} ${control_table3}
	sampling_frame_problem i.stratum [pw=weight_hh]  
		if control==0 , cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies11}:	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anycond ${control_table3}
	sampling_frame_problem i.stratum [pw=weight_hh]  
		if control==0 , cluster(schoolid);	

		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' pere ${control_table3}
	sampling_frame_problem i.stratum [pw=weight_hh]  
		if control==0 , cluster(schoolid);			
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
						
};

*edit vars-p_val_mo_dif_fa if _n<100;

outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table3.out"  if _n<100 ,replace;	




*************************************;
************************************;
** TABLES 4: Knowledge surveys  ;
***********************************;
*************************************;


*********************************;
** PART 1 (in fact 2) ON HOUSEHOLDS;

#delimit;
set more off;

u "Output\working_knowledge3",clear;

global table4_var 
 ksm_know_program_exist ksm_uncond ksm_cond_nsp
	 ksm_cond_abs  ksm_cond_5abs_if_cond ksm_not_surveyed;

	
gen vars="";
gen mean_control="";
for any anycond: gen coef_X="";
gen N=.;

local i -1;
foreach var of global table4_var {;
local i=`i'+2;

local control_table4_check "$control_table4_hh";
local weight "[pw=ksm_weight]";
	if substr("`var'",1,16)=="ksm_not_surveyed" {;
local control_table4_check "prel_elec prel_elec_miss 
prel_inacc_winter prel_inacc_winter_miss";
local weight "";
	};

replace vars="`var'" if _n==`i';
	sum `var' if anycond==0 & anytransfer==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

	xi: reg `var'  anycond `control_table4_check' 
	i.stratum `weight' if control==0, cluster(schoolid) ;
replace N=e(N) if _n==`i';
for any anycond:	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
					
};
*edit vars-N if _n<100;
keep if mean_control!="";
keep vars-N;
save tp1,replace;



*********************************;
** table 4: PART 3 HH data at endline survey;
#delimit;
set more off;

u "Output\working_knowledge4",clear;


global table4_var "ksm2_know_program_exist ksm2_uncond
 ksm2_cond_nsp ksm2_cond_abs ksm2_cond_5abs_if_cond";
	
gen vars="";
gen mean_control="";
for any anycond: gen coef_X="";
gen N=.;

local i -1;
foreach var of global table4_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if anycond==0 & anytransfer==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' anycond ${control_table4_hh_endline}
	sampling_frame_problem
	i.stratum [pw=weight_hh] if control==0, cluster(schoolid) ;
replace N=e(N) if _n==`i';
for any anycond:	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

};
*edit vars-N if _n<100;
keep if mean_control!="";
keep vars-N;
save tp2,replace;


*********************************;
** table 4: PART 3 bis HH data at endline survey;
#delimit;
set more off;

u "Output\workingtable_hh_baseline",clear;
global table4_var_bis "attrition";
	
gen vars="";
gen mean_control="";
for any anycond: gen coef_X="";
gen N=.;

local i -1;
foreach var of global table4_var_bis {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if anycond==0 & anytransfer==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' anycond 
	sampling_frame_problem
	i.stratum [pw=weight_hh] if control==0, cluster(schoolid) ;
replace N=e(N) if _n==`i';
for any anycond:	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

};
*edit vars-N if _n<100;
keep if mean_control!="";
keep vars-N;
save tp2_bis,replace;



*********************************;
** table 4: PART 2 ON TEACHERS AND DIRECTORS;

#delimit;
set more off;

forvalues y=2009/2010 {;

u "Output\working_knowledge_append",clear;

** we keep only the good year;
keep if year==`y';

global table4_var  ks_uncond ks_cond_abs 
ks_cond_5abs_if_cond ks_amount_cor ks_not_surveyed ;
 
gen vars="";
gen mean_control="";
for any anycond: gen coef_X="";
gen N=.;

local i -1;
foreach var of global table4_var {;
local i=`i'+2;

local control_table4_check "$control_table4";
	if substr("`var'",1,16)=="ks_not_surveyed" {;
local control_table4_check "director prel_elec prel_elec_miss 
prel_inacc_winter prel_inacc_winter_miss";
	};

replace vars="`var' `y'" if _n==`i';
	sum `var' if anycond==0 & anytransfer==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

	xi: reg `var' anycond `control_table4_check' 
			i.stratum if control==0, cluster(schoolid);

replace N=e(N) if _n==`i';
for any anycond:	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
			
};

keep vars-N;
keep if coef_anycond!="";

save tp`y' ,replace ;

};


u tp2009,clear;
append using tp2010;

*edit vars-N if _n<100;
erase tp2009.dta;
erase tp2010.dta;


** appending all parts;
append using tp1;
append using tp2;
append using tp2_bis;
erase tp1.dta;
erase tp2.dta;
*edit vars-N if _n<100;

outsheet vars-N using "Tables_paper\cct_table4_uct_cct.out"  if _n<100 ,replace;	





***********************************;
***********************************;
*** TABLES 5: ALL school participation outcomes;
***********************************;
***********************************;

** PART 1 ;
#delimit;
set more off;
global table5_1_var enroll_attend_May2010
	dropout_since2008_grade_1234
	dropout08_enroll10 neverenrolled; 

u "Output\workingtable6",clear;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table5_1_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
			
};

keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";

*edit vars-p_val_mo_dif_fa  if _n<100;
*outsheet vars-p_val_mo_dif_fa using Tables_paper\cct_table5_1.out  if _n<100 ,replace;	
tempfile tp_tab5_a;
save `tp_tab5_a';



******************************; 
*** Table 5 PART 2 : Impact on dropouts visit data;
******************************; 
#delimit;
clear; 
set more off;
global table5_2_var dropout_g14 dropout_g14_y1 
dropout_g14_y2 completed_g5 ;

local i -1;
foreach var of global table5_2_var {;
local i=`i'+2;

use "Output\workingtable3", clear;
gen cond_pere=anycond*pere;
gen cond_mere=anycond*mere;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
replace vars="`var'" if _n==`i';
	sum `var' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;


xi: reg `var' ${treatmentdummies10} ${control_table5_2} i.stratum, cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	
xi: reg `var' anytransfer anycond ${control_table5_2} i.stratum, cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_2} i.stratum, cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
			

tempfile tp_`var';
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_`var'';

};
*edit vars-p_val_mo_dif_fa  if _n<100;


************************************;
** Table 5: PART 3 Impacts on attendance;
************************************;

#delimit;
use "Output\workingtable5", clear;

gen cond_pere=anycond*pere;
gen uncond_mere=uncond*mere;
gen uncond_pere=uncond*pere;
gen cond_mere=anycond*mere;

replace visit=. if visit==1 | visit==4;
**If we want to exclude those in grade 5 at baseline;
*drop if v1_c4==5;


gen attenance_all_v2_v5=attenance_all if visit==2 | visit==5;
gen attenance_all_v3_v6=attenance_all if visit==3 | visit==6;

foreach i of numlist 2 3 5 6 {;
gen attenance_all_`i'=attenance_all if visit==`i';
};

set more off;
global table5_3_var attenance_all;
* attenance_all_v2_v5 attenance_all_v3_v6 attenance_all_2 attenance_all_3 attenance_all_5 attenance_all_6;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table5_3_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table5_3}
	i.stratum, cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table5_3}
	i.stratum, cluster(schoolid);	  
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_3}
	i.stratum, cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
			
};

tempfile tp_table5_3;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_table5_3';
*edit vars-p_val_mo_dif_fa  if _n<100;
*outsheet vars-p_val_mo_dif_fa using Tables_paper\cct_table5_attendance.out  if _n<100 ,replace;


******;
** appending all parts;

u `tp_tab5_a',clear;

append using `tp_dropout_g14';
append using `tp_dropout_g14_y1';
append using `tp_dropout_g14_y2';
append using `tp_table5_3';
append using `tp_completed_g5';

*edit vars-p_val_mo_dif_fa  if _n<100;
outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table5.out"  if _n<100 ,replace;	




******************************************;
******************************************;
******  TABLE 6  Child time use *******;
******************************************;
******************************************;


#delimit;
u "Output\workingtable8",clear;


***;
** We keep only data during the school period;
** before june 15: data after which we consider schools as closed ;
keep if survey_date<18428 & survey_date!=0;


global time_use "time_perso time_school time_homework time_school_activ time_chores 
time_careothers time_inwork time_outsidework time_social time_other time_leisure 
time_hhagriculture time_hhlivestock time_hhotherwork
time_outagriculture time_outlivestock time_outother time_play time_tv time_rest";


gen some_time_school=time_inschool>0 if time_inschool!=.;


global table6_var some_time_school
time_school time_inschool 
time_homework 
time_traveltoschool
time_chores 
time_inwork time_social 
time_perso time_other; 

gen vars="";
gen mean_control="";
for any anytransfer  : gen coef_X="";
gen N=.;
 
local i -1;
foreach var of global table6_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.01)) if _n==`i';
replace mean_control=string(round(r(sd),.01)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' anytransfer  ${control_table6} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);

replace N=e(N) if _n==`i';
for any anytransfer : 	
			replace coef_X=string(round(_b[X],.01)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.01)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

};


*edit vars-N if _n<100;
outsheet vars-N using "Tables_paper\cct_table6.out"  if _n<100 ,replace;	





******************************************;
******************************************;
****** TABLE 7:  ASER tests  *******;
******************************************;
******************************************;

***************;
** part 1 ;

#delimit;
set more off;
u "Output\workingtable_aser",clear;


global table7_var  know_digit_all know_num_all know_sub_all 
know_div_all;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table7_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);

	
replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" & _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
		
};


*edit vars-p_val_mo_dif_fa  if _n<100;

tempfile tp_aser1;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_aser1';


***************;
** part 2;
**  SUMMARY INDICES;

#delimit;
u "Output\workingtable_aser",clear;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
global cat "_all _boys _girls _center _sat _ins _out _age6_9 _age10_12";

foreach x of global cat {;
** we standardize each outcome using control mean and sd; 
** we include the weights; 
foreach v in know_digit`x' know_num`x' know_sub`x' 
				know_div`x' {;
	sum `v' [iw=weight_hh] if control==1 ;
gen sd_`v'=(`v'-r(mean))/r(sd);
};

** we sum the standardized outcomes and divide by the total number of outcomes;
gen sd_aver_sum`x'=(sd_know_digit`x'+sd_know_num`x'+sd_know_sub`x'+sd_know_div`x')/4;
};


global table7_sum_var "sd_aver_sum_all sd_aver_sum_boys
sd_aver_sum_girls sd_aver_sum_center sd_aver_sum_sat sd_aver_sum_ins
sd_aver_sum_out";

local i -1;
foreach var of global table7_sum_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;


xi: reg `var' ${treatmentdummies10} ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
	
replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	  
xi: reg `var' anytransfer anycond ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';

};


*****;
** we add coef with join regressions with interaction terms;
** interaction dummies for categories;
for any ${treatmentdummies10}: gen X_girls=X*girls \ gen X_out=X*out
									\ gen X_sat=X*sat;
for any girls sat out: gen anycond_X=anycond*X
						\ gen pere_X=pere*X;
									
global interact_dum_girls "anytransfer_girls uncond_mere_girls cond_pere_girls cond_mere_girls";
global interact_dum_out "anytransfer_out uncond_mere_out cond_pere_out cond_mere_out";
global interact_dum_sat "anytransfer_sat uncond_mere_sat cond_pere_sat cond_mere_sat";



**;
local i=`i'-2;
foreach k in "girls" "sat" "out" {;
local i=`i'+4;

* cat=0;
replace vars="sd_aver_sum_all `k'=0" if _n==`i';
	sum sd_aver_sum_all [iw=weight_hh] if control==1 & `k'==0;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

* cat=1;
replace vars="sd_aver_sum_all `k'=1" if _n==`i'+2;
	sum sd_aver_sum_all [iw=weight_hh] if control==1 & `k'==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i'+2;
replace mean_control=string(round(r(sd),.001)) if _n==`i'+3;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+3 | _n==`i'+2);
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i'+2;
replace mean_control="["+mean_control+"]" if _n==`i'+3 ;


xi: reg sd_aver_sum_all ${treatmentdummies10} ${interact_dum_`k'} ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
	replace N=e(N) if _n==`i';
	replace N=e(N) if _n==`i'+2;
** effect for cat =0;
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

** effect for cat =1;
for any ${treatmentdummies10} \ any ${interact_dum_`k'} :
			lincom X+Y \	
			replace coef_X=string(round(r(estimate),.001)) if _n==`i'+2 \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+2 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+2 \
			replace coef_X=string(round(r(se),.001)) if _n==`i'+3\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+3 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+3 \
			replace coef_X="("+coef_X+")" if _n==`i'+3 \
			test X+Y=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+3 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+3 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+3 ;	

** p values CCT/UCT father/mother;
xi: reg sd_aver_sum_all anytransfer anycond anytransfer_`k' anycond_`k'  ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
		test anycond=0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';
		test anycond+anytransfer_`k'=0;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i'+2;
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i'+2 & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i'+2;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+2;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+2;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i'+2;

xi: reg sd_aver_sum_all anytransfer pere anytransfer_`k' pere_`k' ${control_table7}
	sampling_frame_problem i.stratum [pw=weight_hh], cluster(schoolid);
		test pere=0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
		test pere+pere_`k'=0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i'+2;
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i'+2 & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+2;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+2;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i'+2;
					
};
	
*edit vars-p_val_mo_dif_fa  if _n<100;

tempfile tp_aser2;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_aser2';

*** APPENDING all parts;
u `tp_aser1',clear;
append using `tp_aser2';
*edit vars-p_val_mo_dif_fa  if _n<100;

outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table7.out"  if _n<100 ,replace;	




************************************************;
***********************************************;
***********************************************;
*** Table 8 ;
*** Impacts on Schooling by subgroups;
***********************************************;
***********************************************;

******;
** Part 1;
* same control as table 51;

#delimit;
set more off;
global table81_var enroll_attend_May2010_boys enroll_attend_May2010_girls
enroll_attend_May2010_sch_sec enroll_attend_May2010_sat
enroll_attend_May2010_lp enroll_attend_May2010_hp

dropout_since2008_grade_14_b dropout_since2008_grade_14_g
dropout_since2008_grade_14_c dropout_since2008_grade_14_sat 

dropout08_enroll10_boys dropout08_enroll10_girls
dropout08_enroll10_sch_sec dropout08_enroll10_sat ;

u "Output\workingtable6",clear;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 #delimit;
local i -1;
foreach var of global table81_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
	
replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
		
};

tempfile tp_tab8_1;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_tab8_1';
*edit vars-p_val_mo_dif_fa  if _n<100;

************************************;
** PART 2  Impacts on attendance;
************************************;
** SAME control as for table 5_3;
#delimit;
use "Output\workingtable5", clear;

gen cond_pere=anycond*pere;
gen uncond_mere=uncond*mere;
gen uncond_pere=uncond*pere;
gen cond_mere=anycond*mere;
replace visit=. if visit==1 | visit==4;
**If we want to exclude those in grade 5 at baseline;
*drop if v1_c4==5;

set more off;
global table7_var attenance_boys attenance_girls 
 attenance_ecolemere attenance_sat;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table7_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table5_3}
	i.stratum, cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table5_3}
	i.stratum, cluster(schoolid);
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_3}
	i.stratum, cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
		
};

tempfile tp_tab8_2;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_tab8_2';
*edit vars-p_val_mo_dif_fa  if _n<100;


*************************************;
** Part 3: timetables intensive margin;
*************************************;
** SAME controls as for table 6;
#delimit;
u "Output\workingtable8",clear;


***;
** only school period;
** before june 15 (after that date we consider school as closed);
keep if survey_date<18428 & survey_date!=0;


global time_use "time_school ";
foreach var in $time_use {;
drop `var'_boys `var'_girls `var'_sat `var'_center;
gen `var'_boys=`var' if girl==0;
gen `var'_girls=`var' if girl==1;
gen `var'_sat=`var' if satellite==1;
gen `var'_center=`var' if satellite==0;
};


global table82_var 
time_school_boys time_school_girls time_school_center time_school_sat; 

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table82_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.01)) if _n==`i';
replace mean_control=string(round(r(sd),.01)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table6} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.01)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.01)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table6} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table6} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
		

};

tempfile tp_tab8_3;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_tab8_3';

*edit vars-p_val_mo_dif_fa if _n<100;

*****************;
*** appending all part;

u `tp_tab8_1',clear;


append using `tp_tab8_2';
append using `tp_tab8_3';
*edit vars-p_val_mo_dif_fa if _n<100;
outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table8.out"  if _n<100 ,replace;	




******************************************;
******************************************;
******  TABLE 9 : Parental involment and beliefs *******;
******************************************;
******************************************;
#delimit;
u "Output\workingtable_returns",clear;


#delimit;
set more off;

global table9_var partic_cgestion education_index  
  dif_princomple_girls dif_prcomple_girls
  dif_princomple_boys dif_prcomple_boys 
pemployed_job_princompl_girls
pemployed_job_prcompl_girls
pemployed_job_college_girls
pemployed_job_princompl_boys
pemployed_job_prcompl_boys
pemployed_job_college_boys
mean_sal_empljob_princompl_girls
mean_sal_empljob_prcompl_girls
mean_sal_empljob_college_girls
mean_sal_empljob_princompl_boys
mean_sal_empljob_prcompl_boys
mean_sal_empljob_college_boys;

gen vars="";
gen mean_control="";
for any anytransfer: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table9_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' anytransfer ${control_table9} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);

replace N=e(N) if _n==`i';
for any anytransfer: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	

};

*edit vars-N  if _n<400;

outsheet vars-N using "Tables_paper\cct_table9.out"  if _n<400 ,replace	;






***********************************************;
***********************************************;
*** GRaph 1 & 2  mechanism: Impacts on dropout: HH data;
***********************************************;
***********************************************;
	

***********************************************;
***********************************************;
*** FIGURE 1 mechanism: Impacts on dropout: HH data;
***********************************************;
***********************************************;

**************;
** GRAPH 1

#delimit;
set more off;
u "Output\workingtable6",clear;

local i -2;
gen mean_var=.;
gen xaxis=_n;
gen vars="";
foreach var in 
	do_old_since2008 
	do_work_outside_since2008 
	do_health_since2008  
	do_schoolquality_since2008 
	do_hhwork_since2008
	do_kidwanted_since2008 
	do_financial_since2008
	do_schoolaccess_since2008 {;
local i=`i'+3;
replace vars="`var'" if _n==`i';
mean `var' [pw=weight_hh] if anytransf==1;
mat beta=e(b);
replace mean_var=beta[1,1] if _n==`i';
mean `var' [pw=weight_hh] if anytransf==0;
mat beta=e(b);
replace mean_var=beta[1,1]  if _n==`i'+1;
replace mean_var=0 if _n==`i'+2;
qui xi: reg `var' anytransfer ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid);
test anytransfer;
local pv_`var'=" ";
if r(p)<0.1 {;
local pv_`var'=" *";
}; 
if r(p)<0.05 {;
local pv_`var'=" **";
}; 
if r(p)<0.01 {;
local pv_`var'=" ***";
}; 
	
};

#delimit;
keep if mean_var!=.;
keep vars mean_var xaxis;


qui twoway (bar mean_var xaxis if xaxis==1 | xaxis==4
| xaxis==7 | xaxis==10 | xaxis==13 | xaxis==16
| xaxis==19 | xaxis==22 ,  hor color(gs6))
(bar mean_var xaxis if xaxis==2 | xaxis==5
| xaxis==8 | xaxis==11 | xaxis==14
| xaxis==17 | xaxis==20 | xaxis==23,  hor color(gs11)), xtitle("Share of students who dropped out for this reason", margin(medium))
legend(row(2) position(3) bmargin(vsmall) ring(0) symysize(small) symxsize(small)
 size(small) order(2 "Control group" 1 "Tayssir Transfers (any type)"  )) 
ylabel(22.8 "School too far "
21.8 "or inaccessible `pv_do_schoolaccess_since2008' " 
 19.5 "Financial difficulties `pv_do_financial_since2008' "
 16.5 "Child's choice `pv_do_kidwanted_since2008' "
 13.8 "Needed child's help " 
 12.8 "(HH business or chore) `pv_do_hhwork_since2008' "
 10.5 "Poor school quality `pv_do_schoolquality_since2008' "
 7.5 "Health problem `pv_do_health_since2008' " 
 4.8 "Child had to work "
 3.8 "(outside HH) `pv_do_work_outside_since2008' "
 1.5 "Child was too old `pv_do_old_since2008' " , nogrid angle(0) noticks labsize(small)) ytitle("")
title("")
graphregion(color(white) fcolor(white))  ;
qui graph save "Tables_paper\graph_1",replace;




**********************************************;
**********************************************;
****** APPENDIX TABLES;
**********************************************;
**********************************************;


******************************************;
******************************************;
******  TABLE A1  *******;
******************************************;
******************************************;
#delimit;
set more off;

u "Output\workingtableA2",clear;


gen cond_pere=anycond*pere;
gen cond_mere=anycond*mere;

gen missing_info_dropout_y2_moved=missing_info_dropout_y2;
replace missing_info_dropout_y2_moved=0 if v6_statut==.;
gen missing_info_dropout_y2_att=missing_info_dropout_y2;
replace missing_info_dropout_y2_att=0 if v6_statut!=.;

global tablea1_var age_2008 female
	 missing_info_dropout_y2;

	
gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global tablea1_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} i.stratum, cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	  
xi: reg `var' anytransfer anycond i.stratum, cluster(schoolid);
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT="0.000" if p_val_CCT_dif_UCT=="0" & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere i.stratum, cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
					
};

*edit vars-p_val_mo_dif_fa  if _n<100;
tempfile tp_tabA1_1;

keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_tabA1_1';


***************************;
** Part 2;
***************************;
** SAME control as for table 5_2;
 
#delimit;
use "Output\workingtable3", clear;
gen cond_pere=anycond*pere;
gen cond_mere=anycond*mere;

set more off;
global tableA1_2_var
moved_y0_y2 moved_y0_y2_m moved_y0_y2_f 
moved_y0_y2_ecolemere moved_y0_y2_sat;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global tableA1_2_var {;
local i=`i'+2;
 
replace vars="`var'" if _n==`i';
	sum `var' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;


xi: reg `var' ${treatmentdummies10} ${control_table5_2} i.stratum, cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	
xi: reg `var' anytransfer anycond ${control_table5_2} i.stratum, cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_2} i.stratum, cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
	};		

tempfile tp_tabA1_2;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_tabA1_2';


*edit vars-p_val_mo_dif_fa  if _n<100;

*** appending both parts;
u `tp_tabA1_1',clear;
append using `tp_tabA1_2';
*edit vars-p_val_mo_dif_fa if _n<100;
outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_tableA1.out"  if _n<100 ,replace;





******************************************;
******************************************;
******  TABLE A2  *******;
******************************************;
******************************************;


**************************************;
* Attrition;
**************************************;
#delimit;
u "Output\workingtable_hh_baseline",clear;


*replace attrition_baseline=. if  tot_never_sur_etab==0;
replace attrition_endline_whole=. if  tot_never_sur_etab==0;
* if no child 6-12 at baseline the HH was not in the ASER sample so;
** we excluded those HH from the sample;
replace attrition_aser=. if attrition_aser_no_test==1;

foreach var in attrition_aser_menage_not_sur
attrition_aser_absent attrition_aser_refuse attrition_aser_moved
attrition_aser_other {;
replace `var'=. if attrition_aser_no_test==1;
};

global tableA3_var attrition_baseline
 attrition_endline_whole
attrition_endline_whole_cor
 attrition attrition_moved attrition_not_in_town
attrition_refused attrition_fusion
attrition_unknown attrition_unreachable
attrition_other
 attrition_aser 
 attrition_aser_menage_not_sur
attrition_aser_absent attrition_aser_refuse attrition_aser_moved
attrition_aser_other;

sort attrition;
gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global tableA3_var {;
local i=`i'+2;

local weight "";
local weight2 "";
if `i'>2 {;
local weight "[pw=weight_hh]";
local weight2 "[iw=weight_hh]";
};

replace vars="`var'" if _n==`i';
	sum `var' `weight2' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} i.stratum `weight', cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" & _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	  
xi: reg `var' anytransfer anycond i.stratum `weight', cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere i.stratum `weight', cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
};



** adding number of observations for aser survey by group;
replace vars="N observation ASER" if _n==`i'+2;
	count if attrition_aser==0 & control==1;
replace mean_control=string(r(N)) if _n==`i'+2;
	count if attrition_aser==0 & uncond==1 & pere==1;
replace coef_anytransfer=string(r(N)) if _n==`i'+2;
	count if attrition_aser==0 & uncond==1 & mere==1;
replace coef_uncond_mere=string(r(N)) if _n==`i'+2;
	count if attrition_aser==0 & anycond==1 & pere==1;
replace coef_cond_pere=string(r(N)) if _n==`i'+2;
	count if attrition_aser==0 & anycond==1 & mere==1;
replace coef_cond_mere=string(r(N)) if _n==`i'+2;
	count if attrition_aser==0 ;
replace N=r(N) if _n==`i'+2;
*edit vars-p_val_mo_dif_fa  if _n<100;

outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_tableA2.out"  if _n<100 ,replace;	




******************************************;
******************************************;
******  TABLE A3  *******;
******************************************;
******************************************;


**************************************;
* Part 1: Checking randomization and attrition for ASER TEST;
**************************************;
#delimit;
u "Output\workingtable_hh_baseline",clear;

replace attrition_aser=. if attrition_aser_no_test==1;

global tableA3_var attrition_aser bs_male_head bs_age_head bs_nmember bs_nchildren
bs_pchildren_enrolled bs_head_readwrite bs_head_completeprimary
bs_head_some_educ bs_monthly_consump_pc bs_own_cellphone
bs_own_tv bs_own_radio bs_own_land bs_bank_account bs_elec;

sort attrition_aser;
gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
 
** 1st part on attrition at baseine; 
local i -1;
foreach var of global tableA3_var {;
local i=`i'+2;

** for balance check we keep only post attrition sample;
local weight "";
local weight2 "";
if `i'>2 {;
keep if attrition_aser==0;
local weight "[pw=weight_hh]";
local weight2 "[iw=weight_hh]";
};


replace vars="`var'" if _n==`i';
	sum `var' `weight2' if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} i.stratum `weight', cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	  
xi: reg `var' anytransfer anycond   i.stratum `weight' , cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere  i.stratum `weight' , cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
};

*edit vars-p_val_mo_dif_fa  if _n<100;
tempfile tp_tableA3_1;
keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
save `tp_tableA3_1';


*******************;
** A3 PART2: balance check of kids surveyed;

u "Output\workingtable_aser",clear;
drop if attrited==1;


global tableA3_2_var age_2008 female inschool08 
everenrolled;
for any inschool08 everenrolled: replace X=. if X_miss==1;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
 
local i -1;
foreach var of global tableA3_2_var {;
local i=`i'+2;


replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10}  i.stratum [pw=weight_hh], cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	  
xi: reg `var' anytransfer anycond  i.stratum [pw=weight_hh] , cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere  i.stratum [pw=weight_hh] , cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
};

*edit vars-tot_ef_UCT_f  if _n<100;

keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";
tempfile tp_tableA3_2;
save `tp_tableA3_2';

******;
** appending the two parts;
u `tp_tableA3_1';
append using `tp_tableA3_2';
*edit vars-p_val_mo_dif_fa  if _n<100;

outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_tableA3.out"  if _n<100 ,replace;	




******************************************;
******************************************;
******  TABLE A4  *******;
** looking at if the program have more effect on those;
** for which the prediction of baseline enrolment is high;
** First stage regression;
******************************************;
******************************************;
#delimit;
u "Output\workingtable6",clear;

gen bs_age_spouse_sqr=bs_age_spouse*bs_age_spouse;
gen bs_age_head_sqr=bs_age_head*bs_age_head;

global dropout_list bs_girl bs_age bs_male_head bs_age_head 
 bs_age_spouse bs_head_amazygh 
 bs_head_readwrite bs_headwife_readwrite
 bs_education_index bs_unuseful_educ
 bs_nmember  bs_nchildren bs_ngirls
 bs_nrooms bs_house_stone bs_own_tv bs_own_cellphone bs_own_land 
 bs_own_fridge bs_bank_account 
 bs_elec bs_monthly_consump_pc_d100 
 satellite prel_elec prel_inacc_winter prel_toilet ;

 local reg_list "";
 local reg_list_out "";

 foreach var in $dropout_list {;
gen `var'2=`var';
 gen `var'2_miss=`var'==.;
 qui sum `var'2;
 replace `var'2=r(mean) if `var'2_miss==1;
local reg_list "`reg_list'`var'2 `var'2_miss "; 
local reg_list_out "`reg_list_out'`var'2 "; 
 };

sum enroll_attend_May2010 [iw=weight_hh] if control==1;
local mean=r(mean);

** we regress only for control group;
 xi: reg enroll_attend_May2010 `reg_list' i.stratum [pw=weight_hh], cluster(schoolid),
 if control==1;

outreg2 `reg_list_out'
using "Tables_paper\cct_tableA4.out", nonote se symbol(***,**,*) replace
	nolabel addstat("Mean dependent variable", `mean')
	 adec(3) bdec(3);



#delimit;

*************************************;
************************************;
** TABLES A5: Child's work ;
***********************************;
*************************************;

u "Output\workingtable_child_work",clear;

global tableA5_var " worked_last_30_days average_hrs_worked_by_day 
worked_self_hh average_hrs_worked_by_day_self worked_outside_hh 
average_hrs_worked_by_day_out  worked_more_10days_4hours";


gen vars="";

forvalues j=1/3 {;
gen mean_control`j'="";
gen N_`j'=.;
};


local i -1;
foreach var of global tableA5_var {;
local i=`i'+2;

forvalues j=1/3 {;
local condition "";
if `j'==2 {;
** before june 15: data after which we consider schools as closed ;
local condition "& survey_date<18428 & survey_date!=0";
};
if `j'==3 {;
** before june 15: data after which we consider schools as closed ;
local condition "& survey_date>=18428 & survey_date!=0";
};

replace vars="`var'" if _n==`i';

	sum `var' [iw=weight_hh] if control==1 `condition';
replace mean_control`j'=string(round(r(mean),.001)) if _n==`i';
replace mean_control`j'=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control`j'="0"+mean_control`j' if (substr(mean_control`j',1,1)=="." 
	| substr(mean_control`j',1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control`j'="["+mean_control`j'+"]" if _n==`i'+1 ;
count if `var'!=. `condition';
replace N_`j'=r(N) if _n==`i';
	};

};

*edit vars-N_3 if _n<100;
outsheet vars-N_3 using "Tables_paper\cct_tableA5.out"  if _n<100 ,replace;

** OTHER STATS;
** earnings of kids who work ouside HH;
sum earnings_outside_hh [iw=weight_hh] if earnings_outside_hh>-1 & control==1;
sum earnings_outside_hh [iw=weight_hh] if earnings_outside_hh>0 & control==1;

** share of kids >10yo not enrolled in school who are working outside the HH;
sum  worked_outside_hh [iw=weight_hh] if enroll_attend_May2010==0 & a13>10 ;

** share 6-11 never enrolled at baseline;
#delimit;
u "Output\workingtable6",clear;

sum bs_neverinschool [iw=weight_hh] if bs_age>5 & bs_age<12;
sum bs_neverinschool if bs_age>5 & bs_age<12;



***********************************;
***********************************;
*** TABLES A5:HH school participation outcomes;
*** BY DISTANCE AND TIME TO GO TO SCHOOL;
***********************************;
***********************************;

** PART 1 ;
#delimit;
set more off;
global table5_1_var dropout_since2008_grade_1234
	dropout08_enroll10; 

forvalues j=0/1 {;
	#delimit;
u "Output\workingtable6",clear;

gen an_distance_school=d30 if d30>=0;
replace an_distance_school=d19 if d19>=0 & an_distance_school==.;
sum an_distance_school,detail;
gen an_dist_school_above_med=an_distance_school>r(p50) if an_distance_school!=.;

gen an_time_to_school=d34 if d34>=0;
replace an_time_to_school=d22_1 if d22_1>=0 & an_time_to_school==.;
sum an_time_to_school,detail;
gen an_time_to_sch_above_med=an_time_to_school>r(p50) if an_time_to_school!=.;


local var_median="an_dist_school_above_med";


gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table5_1_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var' [iw=weight_hh] if `var_median'==`j' & control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid), if `var_median'==`j';

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid) , if `var_median'==`j';	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_1} sampling_frame_problem
	i.stratum [pw=weight_hh], cluster(schoolid), if `var_median'==`j';
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
			
};

keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";

tempfile tp_tab5_`j';
save `tp_tab5_`j'';

};

******;
** appending all parts;
u `tp_tab5_0',clear;
append using `tp_tab5_1';

edit vars-p_val_mo_dif_fa  if _n<100;

outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table5_time_school.out"  if _n<100 ,replace;	





**********************************************;
**********************************************;
**********************************************;
******* TABLE 5 6 AND 9 WITHOUT THE WEIGHTS;
**********************************************;
**********************************************;


***********************************;
***********************************;
*** TABLES 5: ALL school participation outcomes;
***********************************;
***********************************;

** PART 1 ;
#delimit;
set more off;
global table5_1_var enroll_attend_May2010
	dropout_since2008_grade_1234
	dropout08_enroll10 neverenrolled; 

u "Output\workingtable6",clear;

gen vars="";
gen mean_control="";
for any ${treatmentdummies10}: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table5_1_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var'  if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' ${treatmentdummies10} ${control_table5_1} sampling_frame_problem
	i.stratum , cluster(schoolid);

replace N=e(N) if _n==`i';
for any ${treatmentdummies10}: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

xi: reg `var' anytransfer anycond ${control_table5_1} sampling_frame_problem
	i.stratum, cluster(schoolid);	
		test anycond==0 ;
 			replace p_val_CCT_dif_UCT=string(round(r(p),.001)) if _n==`i';
 			replace p_val_CCT_dif_UCT="0"+p_val_CCT_dif_UCT if _n==`i' & round(r(p),.001)!=0;
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_CCT_dif_UCT=p_val_CCT_dif_UCT+"***" if r(p)<0.01 & _n==`i';

xi: reg `var' anytransfer pere ${control_table5_1} sampling_frame_problem
	i.stratum , cluster(schoolid);
		test pere==0;
 			replace p_val_mo_dif_fa=string(round(r(p),.001)) if _n==`i';
 			replace p_val_mo_dif_fa="0"+p_val_mo_dif_fa if _n==`i' & round(r(p),.001)!=0;
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i';
			replace p_val_mo_dif_fa=p_val_mo_dif_fa+"***" if r(p)<0.01 & _n==`i';
			
};

keep vars-p_val_mo_dif_fa;
keep if coef_anytransfer!="";


*edit vars-p_val_mo_dif_fa  if _n<100;
outsheet vars-p_val_mo_dif_fa using "Tables_paper\cct_table5_no_weights.out"  if _n<100 ,replace;	





 
******************************************;
******************************************;
******  TABLE 6  Child time use *******;
******************************************;
******************************************;


#delimit;
u "Output\workingtable8",clear;


***;
** We keep only data during the school period;
** before june 15: data after which we consider schools as closed ;
keep if survey_date<18428 & survey_date!=0;


global time_use "time_perso time_school time_homework time_school_activ time_chores 
time_careothers time_inwork time_outsidework time_social time_other time_leisure 
time_hhagriculture time_hhlivestock time_hhotherwork
time_outagriculture time_outlivestock time_outother time_play time_tv time_rest";


gen some_time_school=time_inschool>0 if time_inschool!=.;


global table6_var some_time_school
time_school time_inschool 
time_homework 
time_traveltoschool
time_chores 
time_inwork time_social 
time_perso time_other; 

gen vars="";
gen mean_control="";
for any anytransfer  : gen coef_X="";
gen N=.;
 
local i -1;
foreach var of global table6_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var'  if control==1;
replace mean_control=string(round(r(mean),.01)) if _n==`i';
replace mean_control=string(round(r(sd),.01)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' anytransfer  ${control_table6} sampling_frame_problem
	i.stratum , cluster(schoolid);

replace N=e(N) if _n==`i';
for any anytransfer : 	
			replace coef_X=string(round(_b[X],.01)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X=string(round(_se[X],.01)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;

};


*edit vars-N if _n<100;
outsheet vars-N using "Tables_paper\cct_table6_no_weights.out"  if _n<100 ,replace;	






******************************************;
******************************************;
******  TABLE 9 : Parental involment and beliefs *******;
******************************************;
******************************************;
#delimit;
u "Output\workingtable_returns",clear;


#delimit;
set more off;

global table9_var partic_cgestion education_index  
  dif_princomple_girls dif_prcomple_girls
  dif_princomple_boys dif_prcomple_boys 
pemployed_job_princompl_girls
pemployed_job_prcompl_girls
pemployed_job_college_girls
pemployed_job_princompl_boys
pemployed_job_prcompl_boys
pemployed_job_college_boys
mean_sal_empljob_princompl_girls
mean_sal_empljob_prcompl_girls
mean_sal_empljob_college_girls
mean_sal_empljob_princompl_boys
mean_sal_empljob_prcompl_boys
mean_sal_empljob_college_boys;

gen vars="";
gen mean_control="";
for any anytransfer: gen coef_X="";
gen N=.;
for any CCT_dif_UCT mo_dif_fa : gen p_val_X="";
 
local i -1;
foreach var of global table9_var {;
local i=`i'+2;

replace vars="`var'" if _n==`i';
	sum `var'  if control==1;
replace mean_control=string(round(r(mean),.001)) if _n==`i';
replace mean_control=string(round(r(sd),.001)) if _n==`i'+1;
replace mean_control="0"+mean_control if (substr(mean_control,1,1)=="." 
	| substr(mean_control,1,2)=="-.") &  (_n==`i'+1 | _n==`i');
replace mean_control=subinstr(mean_control,"0-","-0",.) if _n==`i';
replace mean_control="["+mean_control+"]" if _n==`i'+1 ;

xi: reg `var' anytransfer ${control_table9} sampling_frame_problem
	i.stratum , cluster(schoolid);

replace N=e(N) if _n==`i';
for any anytransfer: 	
			replace coef_X=string(round(_b[X],.001)) if _n==`i' \
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i' \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i' \
			replace coef_X="0.000" if coef_X=="0" &  _n==`i' \
			replace coef_X=string(round(_se[X],.001)) if _n==`i'+1\
			replace coef_X="0"+coef_X if (substr(coef_X,1,1)=="." | substr(coef_X,1,2)=="-.") &  _n==`i'+1 \
			replace coef_X=subinstr(coef_X,"0-","-0",.) if _n==`i'+1 \
			replace coef_X="("+coef_X+")" if _n==`i'+1 \
			test X=0 \
			replace coef_X=coef_X+"*" if r(p)<0.1 & r(p)>=0.05 & _n==`i'+1 \
			replace coef_X=coef_X+"**" if r(p)<0.05 & r(p)>=0.01 & _n==`i'+1 \
			replace coef_X=coef_X+"***" if r(p)<0.01 & _n==`i'+1 ;
	

};

*edit vars-N  if _n<400;

outsheet vars-N using "Tables_paper\cct_table9_no_weights.out"  if _n<400 ,replace	;





******************************************;
******************************************;
******  Graph  (ONLY FOR PRESENTATIONS)*******;
** SCHOOLING OUTCOMES;
******************************************;
******************************************;

/*;

#delimit;

***************************************************;
** Household sample;
***************************************************;


#delimit;
set more off;
global table5_1_var enroll_attend_May2010 
	dropout_since2008_grade_1234
	dropout08_enroll10 neverenrolled ; 

foreach var in $table5_1_var {;

u "Output\workingtable6",clear;
** treatment var;
gen graph_treat=0 if control==1;
replace graph_treat=1 if anycond==0 & pere==1;
replace graph_treat=2 if anycond==0 & mere==1;
replace graph_treat=3 if anycond==1 & pere==1;
replace graph_treat=4 if anycond==1 & mere==1;



forvalues i=0/4 {;
qui ci `var' [aw=weight_hh]
	if graph_treat==`i';
gen m_`var'_`i'=r(mean);
gen h_`var'_`i'=r(ub);
gen l_`var'_`i'=r(lb);
count if `var' !=.;
local n_size=r(N);
	};

keep  m_`var'_* h_`var'_* l_`var'_*;
keep if _n==1;

gen order=1;

reshape long m_`var'_ h_`var'_ l_`var'_,
	i(order) j(graph_treat);

	#delimit;
if "`var'"=="enroll_attend_May2010" {;
local title1 "Attenting school by the end of year 2";
local title2 "(among those 6-15 at baseline)";
};
if "`var'"=="dropout_since2008_grade_1234" {;
local title1 "Dropped out by end of year 2";
local title2 "(among those enrolled in grades 1-4 at baseline)";
};
if "`var'"=="dropout08_enroll10" {;
local title1 "Re-Enrolled by end of year 2";
local title2 "(if had dropped out at any time before baseline)";
};
if "`var'"=="neverenrolled" {;
local title1 "Never Enrolled by end of year 2";
local title2 "(among those 6-15 in year 0)";
};
		

#delimit;
*local var neverenrolled;

twoway (bar m_`var'_ graph_treat , barwidth(0.5) color(navy) , if graph_treat==0 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(edkblue), if graph_treat==1  )
(bar m_`var'_ graph_treat , barwidth(0.5) color(eltblue), if graph_treat==2 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(eltgreen), if graph_treat==3 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(emidblue), if graph_treat==4 )
(rcap h_`var'_ l_`var'_ graph_treat), legend(off)
xlabel(0 "Control" 1 "LCT fathers" 2 "LCT mothers" 3 "CCT fathers" 4 "CCT mothers" ,alternate)
xtitle("") title("`title1'") subtitle("`title2'")
note(N=`n_size');

graph save "Tables_paper\graph_`var'",replace;
};


#delimit;
 qui graph combine "Tables_paper\graph_enroll_attend_May2010.gph" 
 "Tables_paper\graph_dropout_since2008_grade_1234.gph"
 "Tables_paper\graph_dropout08_enroll10.gph"
 "Tables_paper\graph_neverenrolled.gph"
 ,xcommon rows(2) cols(2) graphregion(color(white) 
 fcolor(white))  saving( "Tables_paper\Schooling_households",replace); 

erase "Tables_paper\graph_enroll_attend_May2010.gph"; 
erase "Tables_paper\graph_dropout_since2008_grade_1234.gph";
erase "Tables_paper\graph_dropout08_enroll10.gph";
erase "Tables_paper\graph_neverenrolled.gph";



***************************************************;
** School sample;
***************************************************;

#delimit;
clear; 
set more off;
global table5_2_var dropout_g14 completed_g5 ;

local i -1;
foreach var of global table5_2_var {;
local i=`i'+2;

use "Output\workingtable3", clear;
gen cond_pere=anycond*pere;
gen cond_mere=anycond*mere;

** treatment var;
gen graph_treat=0 if control==1;
replace graph_treat=1 if anycond==0 & pere==1;
replace graph_treat=2 if anycond==0 & mere==1;
replace graph_treat=3 if anycond==1 & pere==1;
replace graph_treat=4 if anycond==1 & mere==1;


forvalues i=0/4 {;
qui ci `var'
	if graph_treat==`i';
gen m_`var'_`i'=r(mean);
gen h_`var'_`i'=r(ub);
gen l_`var'_`i'=r(lb);
count if `var' !=.;
local n_size=r(N);
	};

keep  m_`var'_* h_`var'_* l_`var'_*;
keep if _n==1;

gen order=1;

reshape long m_`var'_ h_`var'_ l_`var'_,
	i(order) j(graph_treat);

	#delimit;
if "`var'"=="dropout_g14" {;
local title1 "Dropped out by end of year 2";
local title2 "(among those enrolled in grades 1-4 at baseline)";
};
if "`var'"=="completed_g5" {;
local title1 "Completed primary school";
local title2 "(among those enrolled in grade 5 at baseline)";
};


#delimit;

twoway (bar m_`var'_ graph_treat , barwidth(0.5) color(navy) , if graph_treat==0 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(edkblue), if graph_treat==1  )
(bar m_`var'_ graph_treat , barwidth(0.5) color(eltblue), if graph_treat==2 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(eltgreen), if graph_treat==3 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(emidblue), if graph_treat==4 )
(rcap h_`var'_ l_`var'_ graph_treat), legend(off)
xlabel(0 "Control" 1 "LCT Fathers" 2 "LCT Mothers" 3 "CCT Fathers" 4 "CCT Mothers" ,alternate)
xtitle("") title("`title1'") subtitle("`title2'")
note(N=`n_size');

graph save "Tables_paper\graph_`var'",replace;
};




#delimit;
use "Output\workingtable5", clear;

gen cond_pere=anycond*pere;
gen uncond_mere=uncond*mere;
gen uncond_pere=uncond*pere;
gen cond_mere=anycond*mere;

replace visit=. if visit==1 | visit==4;
**If we want to exclude those in grade 5 at baseline;
*drop if v1_c4==5;

global table5_3_var attenance_all;

local var  attenance_all;

** treatment var;
gen graph_treat=0 if control==1;
replace graph_treat=1 if anycond==0 & pere==1;
replace graph_treat=2 if anycond==0 & mere==1;
replace graph_treat=3 if anycond==1 & pere==1;
replace graph_treat=4 if anycond==1 & mere==1;

forvalues i=0/4 {;
qui ci `var'
	if graph_treat==`i';
gen m_`var'_`i'=r(mean);
gen h_`var'_`i'=r(ub);
gen l_`var'_`i'=r(lb);
count if `var'!=.;
local n_size=r(N);
	};

keep  m_`var'_* h_`var'_* l_`var'_*;
keep if _n==1;

gen order=1;

reshape long m_`var'_ h_`var'_ l_`var'_,
	i(order) j(graph_treat);

	#delimit;
if "`var'"=="attenance_all" {;
local title1 "Attendance rate during surprise visits";
local title2 "(among those enrolled at baseline)";
};

#delimit;

twoway (bar m_`var'_ graph_treat , barwidth(0.5) color(navy) , if graph_treat==0 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(edkblue), if graph_treat==1  )
(bar m_`var'_ graph_treat , barwidth(0.5) color(eltblue), if graph_treat==2 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(eltgreen), if graph_treat==3 )
(bar m_`var'_ graph_treat , barwidth(0.5) color(emidblue), if graph_treat==4 )
(rcap h_`var'_ l_`var'_ graph_treat), legend(off)
xlabel(0 "Control" 1 "LCT fathers" 2 "LCT mothers" 3 "CCT fathers" 4 "CCT mothers" ,alternate)
xtitle("") title("`title1'") subtitle("`title2'")
note(N=`n_size');
graph save "Tables_paper\graph_`var'",replace;


#delimit;
 qui graph combine "Tables_paper\graph_dropout_g14.gph"
 "Tables_paper\graph_attenance_all.gph"
 "Tables_paper\graph_completed_g5.gph" 
 ,xcommon rows(2) cols(2) graphregion(color(white) 
 fcolor(white))  saving( "Tables_paper\Schooling_school",replace); 

erase "Tables_paper\graph_dropout_g14.gph";
erase "Tables_paper\graph_attenance_all.gph";
erase "Tables_paper\graph_completed_g5.gph";





