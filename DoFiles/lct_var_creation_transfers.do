

#delimit;
cap clear matrix;
clear;
set mem 500m;
set more off;


***************************************************;
**** TRANSFERS DATA ****;
***************************************************;


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
 bs_pchildren_dropout bs_pchildren_neverenrolled bs_own_cellphone bs_age_head{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};


*****************************;
** CARTABLES;

gen cart_know=0;
	replace cart_know=1 if m1==1;

gen cart_benefited08=0;
	replace cart_benefited08=1 if m2==1;

	gen cart_nkids08=0;
		replace cart_nkids08=m3 if m3>0 & m3!=.; 

	gen got_cartable08=0;
		replace got_cartable08=1 if m4_1==1;
 
	gen got_supplies08=0;
		replace got_supplies08=1 if m4_2==1;

	gen got_books08=0; 
		replace got_books08=1 if m4_3==1;

gen cart_benefited09=0;
	replace cart_benefited09=1 if m5==1;

	gen cart_nkids09=0;
		replace cart_nkids09=m6 if m6>0 & m3!=.; 

	gen got_cartable09=0;
		replace got_cartable09=1 if m7_1==1;
 
	gen got_supplies09=0;
		replace got_supplies09=1 if m7_2==1;

	gen got_books09=0; 
		replace got_books09=1 if m7_3==1;


********************************;
** TAYSSIR;

gen ty_know=0 if m8!=. | m9!=.;
	replace ty_know=1 if m8==1 | m9==1;
	label var ty_know "1 if knows tayssir program";

gen ty_invillage=0;
	replace ty_invillage=1 if m10==1;

gen ty_eligibility=0 if m11!=.;
	replace ty_eligibility=1 if (m11==3 |m11==2);

gen ty_uncond=1 if (m11==2|m11==1) & m13==1;
	replace ty_uncond=0 if m11==3|m13==2;

gen ty_cond_enroll=0 if m11==1|m11==2;
	replace ty_cond_enroll=1 if (m11==3 | index(m11_autre, "INSCRIT")) & (m13==1 | m14==4);
 	replace ty_cond_enroll=1 if m11==3 & m13==2 & m14==4;
 	replace ty_cond_enroll=1 if m11==3 & m13==. & m14==.;
 
gen ty_cond_pres=1 if  m13==2 & (m14<=3 | index(m14_autre, "ABSENCES")) & m14!=-99;
	replace ty_cond_pres=0 if ty_cond_pres==. & (m13==1 | ty_cond_enroll==1 | ty_uncond==1);

gen ty_cond_dk=(m14==-99) if m13!=.;
	replace ty_cond_dk=1 if m11==-99 & (m13==1|m13==-99);
	replace ty_cond_dk=1 if m11==3 & ((m13==-99 & m14!=4)|m14==-99);
	replace ty_cond_dk=1 if m11==4 & m11_autre=="" & ty_cond_pres!=1;
	replace ty_cond_dk=1 if m11==3 & m13==2 & m14==.;
	replace ty_cond_dk=1 if m11==3 & m13==2 & m14==5 & m14_autre=="";


replace ty_cond_dk=0 if m11==1 & m13==1 & m14==-99;

replace ty_cond_enroll=0 if ty_cond_enroll==. & (ty_cond_pres==1 | ty_cond_dk==1 | ty_uncond==1);
replace ty_cond_pres=0 if ty_cond_pres==. & (ty_cond_enroll==1 | ty_cond_dk==1 | ty_uncond==1);
replace ty_cond_dk=0 if ty_cond_dk==. & (ty_cond_enroll==1 | ty_cond_pres==1 | ty_uncond==1);
replace ty_uncond=0 if ty_uncond==. & (ty_cond_enroll==1 | ty_cond_pres==1 | ty_cond_dk==1); 

*check;
egen sum=rsum( ty_cond_enroll ty_uncond ty_cond_pres ty_cond_dk);
tab sum if control==0;

foreach var in ty_cond_enroll ty_uncond ty_cond_pres ty_cond_dk {;
	replace `var'=. if `var'==0 & (m8==1 | m9==1) & sum==0;
	replace `var'=. if `var'==0 & (m8==. & m9==.) & sum==0;
	};

foreach var in ty_cond_enroll ty_uncond ty_cond_pres ty_cond_dk {;
	replace `var'=0 if `var'==. & (m8==2 | m9==2) & sum==0;
	};

	drop sum;
 
sum ty_uncond-ty_cond_dk if control==0;

gen ty_cond_4abs=0;
	replace ty_cond_4abs=1 if m14==1;


gen ty_enrolled=0 if m17!=. | ty_know==0;
	replace ty_enrolled=1 if m17==1;
	replace ty_enrolled=1 if m17==. & m18>0 & m18!=.;

** for those who had at least one dropout kid at baseline;
gen ty_enrolled_dropout=ty_enrolled if bs_pchildren_dropout>0 & bs_pchildren_dropout!=.;
gen ty_enrolled_enrolled=ty_enrolled if bs_pchildren_dropout==0 & bs_pchildren_dropout!=.;

	
gen ty_nkids=0 if m18!=. | ty_enrolled==0;
	replace ty_nkids=m18 if m18>0 & m18!=.;
	
** tot members and tot children 6-17;
gen tp_tot_member_6_17=0;
forvalues i=1/32 {;
replace tp_tot_member_6_17=tp_tot_member_6_17+1 if a13_`i'>5 & a13_`i'<18;
};
gen ty_percent_kids=ty_nkids/tp_tot_member_6_17;
replace ty_percent_kids=1 if ty_percent_kids>1 & ty_percent_kids!=.;
replace ty_percent_kids=1 if ty_percent_kids==. & ty_nkids>0 & ty_nkids!=.;
replace ty_percent_kids=0 if ty_percent_kids==. & ty_nkids==0;
drop tp_tot_member_6_17;

gen ty_got_transfer=0 if m19!=. | ty_enrolled==0;
	replace ty_got_transfer=1 if m19==1;
	label var ty_got_transfer "got at least one Tayssir transfer - QM19";

gen ty_father_benef=0 if m20!=. | ty_got_transfer==0;
	replace ty_father_benef=1 if m20==1;

gen ty_mother_benef=0 if m20!=. | ty_got_transfer==0;
	replace ty_mother_benef=1 if m20==2;

gen ty_tutor_benef=0 if m20!=. | ty_got_transfer==0;
	replace ty_tutor_benef=1 if m20==3;

gen ty_withdrawl_village=0 if (m22!=. & m22!=-99) | ty_got_transfer==0;
	replace ty_withdrawl_village=1 if m22==1 | m22==2;

gen ty_withdrawl_less10km=0 if (m22!=. & m22!=-99) | ty_got_transfer==0;
	replace ty_withdrawl_less10km=1 if m22==3;

gen ty_withdrawl_more10km=0 if (m22!=. & m22!=-99) | ty_got_transfer==0;
	replace ty_withdrawl_more10km=1 if m22==4; 

gen ty_transp=0 if (m23!=. & m23!=-99) | ty_got_transfer==0;
	replace ty_transp=1 if m23==1;

gen ty_transp_amount=0 if ty_transp!=. & m24!=-99;
	replace ty_transp_amount=m24 if m24>0 & m24!=.;
	
gen ty_onlyfather_paid=0 if (m25!=-99 & m25!=.) | ty_got_transfer==0;
	replace ty_onlyfather_paid=1 if m25==1;

gen ty_onlymother_paid=0 if (m25!=-99 & m25!=.) | ty_got_transfer==0;
	replace ty_onlymother_paid=1 if m25==2;

gen ty_motherfather_paid=0 if (m25!=-99 & m25!=.) | ty_got_transfer==0;
	replace ty_motherfather_paid=1 if m25==4;

gen ty_mothersomeone_paid=0 if (m25!=-99 & m25!=.) | ty_got_transfer==0;
	replace ty_mothersomeone_paid=1 if m25==6;

gen ty_fathersomeone_paid=0 if (m25!=-99 & m25!=.) | ty_got_transfer==0;
	replace ty_fathersomeone_paid=1 if m25==5;	
	
gen ty_ntransfer_m26=0 if (m26!=. & m26!=-99) | ty_got_transfer==0;
	replace ty_ntransfer_m26=m26 if m26>0 & m26!=.;

gen ty_got_transfer_m26=(ty_ntransfer_m26>0 & ty_ntransfer_m26!=.);
	label var ty_got_transfer_m26 "got at least one Tayssir transfer - QM26";

gen ty_ntransfer=0;
	foreach j of numlist 1(1)16 {;
		replace ty_ntransfer=ty_ntransfer+1 if m27_transfert`j'==1;
		};

	replace ty_enrolled=1 if ty_ntransfer>0 & ty_enrolled==.;
	replace ty_ntransfer=. if ty_enrolled==. & ty_ntransfer==0;
	replace ty_got_transfer=0 if ty_ntransfer==0 & ty_got_transfer==.;
	replace ty_got_transfer=1 if ty_ntransfer>0 & ty_ntransfer!=. & ty_got_transfer==.;
	

gen ty_got_transfer_list=(ty_ntransfer>0);
	label var ty_got_transfer_list "got at least one Tayssir transfer - QM27";

gen ty_ntransfer_amt=0;
	foreach j of numlist 1(1)16 {;
		replace ty_ntransfer_amt=ty_ntransfer_amt+1 if m28_transfert`j'>0 & m28_transfert`j'!=. ;
		};

gen ty_montant_tot=0;
	foreach j of numlist 1(1)16 {;
		replace ty_montant_tot=ty_montant_tot+m28_transfert`j' if m28_transfert`j'>0 & m28_transfert`j'!=. ;
		};


foreach j of numlist 1(1)16 {;
			gen year0809_`j'=0;
			replace year0809_`j'=1 if (inrange(m29_transfert`j'_m,7,12) & m29_transfert`j'_a==2008)
			| (inrange(m29_transfert`j'_m,1,6) & m29_transfert`j'_a==2009);

			gen year0910_`j'=0;
			replace year0910_`j'=1 if (inrange(m29_transfert`j'_m,7,12) & m29_transfert`j'_a==2009) 
			| (inrange(m29_transfert`j'_m,1,6) & m29_transfert`j'_a==2010);
				};

gen ty_montant_0809=0;
	foreach j of numlist 1(1)16 {;
		replace ty_montant_0809=ty_montant_0809+m28_transfert`j' if m28_transfert`j'>0 & m28_transfert`j'!=. & year0809_`j'==1;
		};

gen ty_montant_0910=0;
	foreach j of numlist 1(1)16 {;
		replace ty_montant_0910=ty_montant_0910+m28_transfert`j' if m28_transfert`j'>0 & m28_transfert`j'!=. & year0910_`j'==1;
		};

	*note: do not use ty_montant_0809 and ty_montant_0910 - many transfer dates missing;
	drop year0809* year0910*;


gen ty_consumption=0;
	foreach j of numlist 1(1)16 {;
		replace ty_consumption=ty_consumption+1 if m32_transfert`j'_1==1;
		};
		gen ty_n_consump=ty_consumption;
		replace ty_consumption=1 if ty_consumption>1; 

gen ty_schoolsupplies=0;
	foreach j of numlist 1(1)16 {;
		replace ty_schoolsupplies=ty_schoolsupplies+1 if m32_transfert`j'_3==1;
		};
		gen ty_n_schoolsupplies=ty_schoolsupplies;
		replace ty_schoolsupplies=1 if ty_schoolsupplies>1;

gen ty_childclothes=0;
	foreach j of numlist 1(1)16 {;
		replace ty_childclothes=ty_childclothes+1 if m32_transfert`j'_4==1;
		};
		gen ty_n_childclothes=ty_childclothes;
		replace ty_childclothes=1 if ty_childclothes>1;

gen ty_otherexpenses=0;
	foreach j of numlist 1(1)16 {;
		replace ty_otherexpenses=ty_otherexpenses+1 if m32_transfert`j'_2==1;
		foreach i of numlist 5(1)12 {; 
			replace ty_otherexpenses=ty_otherexpenses+1 if m32_transfert`j'_`i'==1; 
		};
		};
		gen ty_n_otherexpenses=ty_otherexpenses;
		replace ty_otherexpenses=1 if ty_otherexpenses>1;


foreach var in ty_got_transfer_list ty_ntransfer_amt ty_montant_tot 
			ty_montant_0809 ty_montant_0910 
			ty_consumption ty_schoolsupplies ty_childclothes ty_otherexpenses {;
				replace `var'=. if ty_ntransfer==.;
				};
			
				
****************************;
*** We look at use of the transfer for old and new transfers;
gen use_cons_old=0;
	foreach j of numlist 1(1)3 {;
		replace use_cons_old=use_cons_old+1 if m32_transfert`j'_1==1;
		};

gen use_supplies_old=0;
	foreach j of numlist 1(1)3 {;
		replace use_supplies_old=use_supplies_old+1 if m32_transfert`j'_3==1;
		};

gen use_clothes_old=0;
	foreach j of numlist 1(1)3 {;
		replace use_clothes_old=use_clothes_old+1 if m32_transfert`j'_4==1;
		};

gen use_other_old=0;
	foreach j of numlist 1(1)3 {;
		replace use_other_old=use_other_old+1 if m32_transfert`j'_2==1;
		foreach i of numlist 5(1)12 {; 
			replace ty_otherexpenses=ty_otherexpenses+1 if m32_transfert`j'_`i'==1; 
		};
		};

gen use_cons_new=0;
	foreach j of numlist 4(1)16 {;
		replace use_cons_new=use_cons_new+1 if m32_transfert`j'_1==1;
		};

gen use_supplies_new=0;
	foreach j of numlist 4(1)16 {;
		replace use_supplies_new=use_supplies_new+1 if m32_transfert`j'_3==1;
		};

gen use_clothes_new=0;
	foreach j of numlist 4(1)16 {;
		replace use_clothes_new=use_clothes_new+1 if m32_transfert`j'_4==1;
		};

gen use_other_new=0;
	foreach j of numlist 4(1)16 {;
		replace use_other_new=use_other_new+1 if m32_transfert`j'_2==1;
		foreach i of numlist 5(1)12 {; 
			replace ty_otherexpenses=ty_otherexpenses+1 if m32_transfert`j'_`i'==1; 
		};
		};

	foreach var in  use_cons_old use_cons_new use_supplies_old use_supplies_new
	use_clothes_old use_clothes_new use_other_old use_other_new {;
		replace `var'=1 if `var'>0;
		};


******;
*** Tayssir admin data;
	* not merge between Tayssir admin database and endline survey, we assume variables are 0 if not enrolled in Tayssir based on survey data;

	foreach var in amt_transfer_admin0809 paid_transfer_admin0809
					ntransf_admin0809 ntransf_paid_admin0809 {;
		replace `var'=0 if `var'==. & ty_enrolled==0;
		};

	foreach var in amt_transfer_admin0809 paid_transfer_admin0809 {;
		replace `var'=. if amt_transfer_admin0809>10000;
		};

*** Share of transfers of monthly baseline consumption;
gen share_transfer_admin0809=paid_transfer_admin0809/bs_monthly_consump;
	replace share_transfer=. if share_transfer>10;

gen share_pc_transfer_admin0809=paid_transfer_admin0809/ bs_monthly_consump_pc;
replace share_pc_transfer=. if share_pc_transfer>100;

	
*** dif between what hh recalled and admin data;
gen dif_hh_admin_n_transf= ntransf_paid_admin0809-ty_ntransfer;


*** HHs not matched;
gen tayssir_not_matched=ntransf_admin0809==. & m17==1;



************;
**** we add school level data;
cap drop _merge;
sort schoolunitid;
preserve;

u "Output\school_level_data",clear;
global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid-province $school_var;
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
** we add weights;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;


******;
** treatment dummies;
gen cond_mere=anycond*mere;
gen uncond_pere=uncond*pere;




**********************************************************;
save "Output\workingtable_transfer_data",replace;
**********************************************************;
