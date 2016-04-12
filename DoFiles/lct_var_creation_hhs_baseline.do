#delimit;
capture clear matrix;
clear;
set mem 500m;
set more off;


****************************************************;
** CREATION VARIABLE FOR HH baseline surveys and attrition;
****************************************************;


** merging with monitoring data;
u "Input\cct_monitoring_endline_an",clear;
sort hhid;
save tp1,replace;
use "Output\baseline_randomization.dta", clear; 
sort hhid;
merge hhid using tp1;
erase tp1.dta;

** surveyed at baseline;
ren _merge baseline_surveyed;
recode baseline_surveyed 3=1 2=0;
by schoolunitid, sort: egen tot_baseline_sur=total(baseline_surveyed);
by schoolunitid,sort: gen tp1=_n if	tot_baseline_sur==0;
gen count_etab_miss_baseline=tp1==1;

by schoolid, sort: egen tot_rat_baseline_sur=total(baseline_surveyed);
by schoolid,sort: gen tp2=_n if tot_rat_baseline_sur==0;
gen count_sector_miss_baseline=tp2==1;
drop tp1 tp2; 


** never surveyed; 
gen never_surveyed=baseline_surveyed==0 & ps_result!=1;
by schoolunitid,sort: egen tot_never_sur_etab=total(baseline_surveyed);
by schoolunitid,sort: gen tp1=_n if	tot_never_sur_etab==0;
gen count_etab_never_sur=tp1==1;
drop tp1;

** never surveyed; 
by schoolid,sort: egen tot_never_sur_cd_rat=total(baseline_surveyed);
by schoolid,sort: gen tp1=_n if	tot_never_sur_cd_rat==0;
gen count_cd_rat_never_sur=tp1==1;
drop tp1;


******;
** we merge with the unit list;
sort schoolunitid;
save tp1,replace;
u "Input\cct_monitoring_endline_an",clear;
keep schoolunitid-province;
duplicates drop schoolunitid,force;
sort schoolunitid;
merge 1:m schoolunitid using "tp1";
erase tp1.dta;
assert _merge==3;
drop _merge;


******;
** we merge with ASER data;
sort hhid;
merge hhid using "Input\cct_aser_an";
drop if _merge==2;
drop  _merge;


******;
** attrition endline;
replace ps_reason_autre="INACCESSIBLE" if ps_reason_autre=="Inaccessible";

gen attrition_refused=attrition==1 & ps_reason_noncomplete==2 if baseline==1;
gen attrition_unknown=attrition==1 & ps_reason_noncomplete==3 if baseline==1;
gen attrition_not_in_town=attrition==1 & ps_reason_noncomplete==4 if baseline==1;
gen attrition_moved=attrition==1 & ps_reason_noncomplete==5 if baseline==1;
gen attrition_unreachable=attrition==1 & ps_reason_noncomplete==6
	& ps_reason_autre=="INACCESSIBLE" if baseline==1;
	
gen attrition_fusion=attrition==1 & ps_reason_noncomplete==6
	& (ps_reason_autre=="2ROSTER POUR LE MEME MENAGE (2 ET 4)"
	| ps_reason_autre=="DOUBLANT AVEC 6"
	| ps_reason_autre=="DOUBLON AVEC N°5"
	| ps_reason_autre=="ENQUETE AVEC 104"
	| ps_reason_autre=="MEME MENAGE QUE N°2"
	| ps_reason_autre=="MEME MENAGE QUE N°4"
	| ps_reason_autre=="MEME MENAGE QUE N°5"
	| ps_reason_autre=="MEME MENAGE QUE N°6"
	| ps_reason_autre=="MEME MENAGE QUE N°7"
	| ps_reason_autre=="MENAGE ENQUETE AVEC N°6 ET N°5"
	| ps_reason_autre=="MENAGE ENQUETE AVEC N°6 ET N°8"
	| ps_reason_autre=="MENAGE ENQUETE AVEC N°8"
	| ps_reason_autre=="MENAGE IDENTIQUE A NUM7"
	| ps_reason_autre=="MENAGE REGROUPE AVEC N°1"
	| ps_reason_autre=="Meme menage que 5"
	| ps_reason_autre=="Menage 5 et 2 font parti de menage 8."
	| ps_reason_autre=="Ménage 1 fait parti de Ménage 5"
	| ps_reason_autre=="fait parti du ménage1"
	| ps_reason_autre=="menage 7 fait parti du menage 5 ") if baseline==1;

gen attrition_other=attrition_fusion==0 & attrition_unreachable==0 
& attrition_moved==0 & attrition_not_in_town==0 &
 attrition_unknown==0 & attrition_refused==0 & attrition==1 if baseline==1;

gen additional_survey_end=ps_result==1 & baseline==0;

gen attrition_endline_whole=attrition;
replace attrition_endline_whole=0 if additional_survey_end==1;
replace attrition_endline_whole=1 if attrition_endline_whole==.;

gen attrition_endline_whole_cor=attrition_endline_whole;

replace attrition_endline_whole_cor=. if (attrition_fusion==1 | attrition_other==1 
	| ps_reason_autre=="pas de Roster") & attrition_endline_whole_cor==1;


******;
** attrition ASER variables;
foreach x in t3_2 t4_2 t5_2 t6 {;
foreach y in t3_2 t4_2 t5_2 t6 {;
	if "`x'"!="`y'" {;
	if "`x'"=="t6" {;
	replace `x'=2 if `y'!=. & `x'==.;  
			};
	else {;
	replace `x'=0 if `y'!=. & `x'==.;  
			};
		};
	};
};	

replace t1=1 if t6!=.;
replace t1=2 if t1==1 & t6==. &  t3_2==. &  t4_2==. &  t5_2==.;


gen attrition_aser=t1!=1 | attrition==1 | prenom_enf_test=="pas d'enfant à tester" if baseline==1  ;
** problem with one survey cheked (merged with another study hh);
replace attrition_aser=1 if hhid=="A487006";

gen attrition_aser_no_test=prenom_enf_test=="pas d'enfant à tester"
	if baseline==1;
	
gen attrition_aser_menage_not_sur=attrition==1 
  & attrition_aser_no_test==0 & attrition_aser==1 if baseline==1 ;
replace attrition_aser_menage_not_sur=1 if hhid=="A487006";

replace t2_2="" if attrition_aser_no_test==1 & baseline==1  ;
replace t2_1=.  if attrition_aser_no_test==1 & baseline==1 ;
replace t2_1=. if t3_1!=. ;
gen attrition_aser_absent=t2_1==1 & attrition==0 if baseline==1 ;
replace attrition_aser_absent=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="A LéCOLE" |
	t2_2=="CHEZ SA GRAND MéRE" |
	t2_2=="DANS UN AUTRE DOUAR" |
	t2_2=="ELLE DANS AUTRE DOUAR DEPUIS DEUX JOUR" |
	t2_2=="ELLE EST ALLER AU VILLAGE" |
	t2_2=="ELLE SE TROUVE DANS UN AUTRE DOUAR" |
	t2_2=="EN VACANCE" |
	t2_2=="EN VACANCE AVEC LA MAMAN" |
	t2_2=="EN VOIYAGE" |
	t2_2=="EN VOIYAGE A CASABLANCA" |
	t2_2=="EN VOIYAGE AVEC SON PéRE" |
	t2_2=="EN VOYAGE" |
	t2_2=="EN VOYAGE CHEZ SA FAMILLE" |
	t2_2=="ENQUETE FAIT AU SOUK" ) & attrition==0;
replace attrition_aser_absent=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="EST INACCESSIBLE DE LE FAIRE" |
	t2_2=="GARDER LES CHEVRES" |
	t2_2=="GARDER LES CHéVRES" |
	t2_2=="IL EST AU MARIAGE" |
	t2_2=="IL EST ENVOIYé A AGADIR" |
	t2_2=="IL ÉTAIT A UN MARIAGE DE LA FAMILLE" |
	t2_2=="INDISPONIBLE (VOIYAGE)" |
	t2_2=="JOUER AVEC LES ENFANTS" |
	t2_2=="L'ENFANT N'EST PAS DISPONIBLE" |
	t2_2=="LENFANT A QUITé L'COLE ET INDISPONIBLE" |
	t2_2=="LENFANT EST PARTI CHEZ SON ONCLE" |
	t2_2=="LENFANT LOIN DU PÈRE" |
	t2_2=="PARTIR AU VILLAGE" |
	t2_2=="PARTIR VISITER SA SŒUR ASOUIRA" |
	t2_2=="PAS PRESNTE AU SOUK" |
	t2_2=="VISITE LA FAMILLE" |
	t2_2=="VOIYAGE" |
	t2_2=="au comping(voiyage)" ) & attrition==0;
	
replace attrition_aser_absent=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="chez son oncle" |
	t2_2=="colonie scolaire" |
	t2_2=="en vacance chez sa famille a rabat" |
	t2_2=="en vacances a agadir" |
	t2_2=="en voiayge" |
	t2_2=="en voiyage" |
	t2_2=="en voiyage avec sa mére" |
	t2_2=="en voiyage hors douar" |
	t2_2=="en voyage" |
	t2_2=="enfant en voiyage hors douar" |
	t2_2=="enfant n'est plus venu au souk" |
	t2_2=="enfant trop loin de son menage" |
	t2_2=="enquete a la commune" |
	t2_2=="enquete était a la commune" |
	t2_2=="enquéte eté a la comune" |
	t2_2=="envoiyage" |
	t2_2=="epveyere" |
	t2_2=="eté en voiyage" |
	t2_2=="garde les chévres") & attrition==0;
	
replace attrition_aser_absent=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="garder les mouton hors douar" |
	t2_2=="il est en voiyage" |
	t2_2=="invité au mariage" |
	t2_2=="l'enquete a ete fait au souk" |
	t2_2=="l'enquete est passé a lécole" |
	t2_2=="lenfant na pa était present au souk" |
	t2_2=="lenquete est passé a lécole" |
	t2_2=="lenquete est passé dans la commune" |
	t2_2=="ménage enquéter dans le souk" |
	t2_2=="n'est pa venu au souk" |
	t2_2=="rendre visite a sa grand mére" |
	t2_2=="voiyage cher l'oncle" |
	t2_2=="voiyage" |
	t2_2=="voiyage ver casablanca" |
	t2_2=="voiyages" |
	t2_2=="éTé VOIAYGé" |
	t2_2=="était en voiyage" |
	t2_2=="été en voiyage" ) & attrition==0;
gen attrition_aser_refuse=t2_1==2  & attrition==0 if baseline==1 ;
replace attrition_aser_refuse=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="ELLE A REFUSER DE VENIR" |
	t2_2=="ENFANT A UN PROBEME DE PRONONTIATION" |
	t2_2=="N'A JAMAIS Eté SCOLARISé" |
	t2_2=="il a peur de passer le test" |
	t2_2=="n'a jamais été scolarisé" |
	t2_2=="n'est pas encor scolarisé" |
	t2_2=="trp timide") & attrition==0;
gen attrition_aser_moved=attrition_aser==1 & attrition==0 &
	t2_1==4 & (t2_2=="DéMENAGé" |
	t2_2=="ENFANT A DéMéNAGé" |
	t2_2=="HABITE DANS UN AUTRE LIEU" |
	t2_2=="IL TRAVAILLE DANS UNE AUTRE VILLE" |
	t2_2=="L4ENFANT A CHANGé LE LOGEMENT" |
	t2_2=="LENFANT  A QUITTé LE MENAGE" |
	t2_2=="LENFANT A QUITé LE MéNAGE" |
	t2_2=="LENFANT EST A CASABLANCA" |
	t2_2=="LENFANT NE RéSIDE PA AU MéNAGE" |
	t2_2=="RESIDE A ESSAOUIRA" |
	t2_2=="RéSIDRA RABAT" |
	t2_2=="change l'ecole a autre douar" |
	t2_2=="demenager" |
	t2_2=="déménage a casablanca" |
	t2_2=="déménage pour l'etude" |
	t2_2=="déménagé en europ" |
	t2_2=="elle est a casa" |
	t2_2=="en Espagne" ) if baseline==1 ;
	
replace attrition_aser_moved=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="enfant ayoub n°4 a quité le menage" |
	t2_2=="enfant deménagé" |
	t2_2=="enfant habite dans un autre lieu" |
	t2_2=="il a quité le ménage" |
	t2_2=="il est pa membre du ménage" |
	t2_2=="il taraville a tantan" |
	t2_2=="il travail a kenitra" |
	t2_2=="il travaille a casa" |
	t2_2=="l'ENFANT A QUITER LE MENAGE" |
	t2_2=="l'enafant habite chez sa grand mére" |
	t2_2=="l'enfant a quitté le menage" |
	t2_2=="l'enfant a quité la maison" |
	t2_2=="l'enfant n'est plus un membre du ménage") & attrition==0;
	
replace attrition_aser_moved=1 if attrition_aser==1 & 
	t2_1==4 & (t2_2=="l'enfant travaille ailleurs" |
	t2_2=="le ménage a déménagé en hors du douar " |
	t2_2=="lenfant a quitté le ménage" |
	t2_2=="lenfant est en travail a casablanca" |
	t2_2=="mariée" |
	t2_2=="membre ayant kitté le menage" |
	t2_2=="membre ayant quité le ménage" |
	t2_2=="pas membre de ménage" |
	t2_2=="plus  membre de ménage" |
	t2_2=="quitté le menage" |
	t2_2=="quité le ménage" |
	t2_2=="transfer a autre ville pour étudier" |
	t2_2=="travail hors ménage") & attrition==0;

gen attrition_aser_other=attrition_aser==1 & attrition==0 
	& attrition_aser_absent==0 & attrition_aser_moved==0
	& attrition_aser_refuse==0 & attrition_aser_no_test==0 
	if baseline==1 ;
 
 
** attrition at baseline;
gen attrition_baseline=1-baseline;


***********;
** we want to withdraw school never surveyed at both endline and baseline;
save "tp1",replace;

*******************;
** List of SCHOOLS surveyed at endline HH survey;
#delimit;
u "Input\cct_endline_an",clear;
keep hhid_endline-province;
sort hhid;
merge hhid using "Input\cct_baseline_an";
keep hhid_endline-province;
duplicates drop schoolunitid,force;
sort schoolunitid;

********************;
** SAVING;
save "Output\list_unit_never_surveyed",replace;

u "tp1",clear;
erase tp1.dta;
sort schoolunitid;
merge schoolunitid using "Output\list_unit_never_surveyed";
*ta _merge;
drop if _merge==1;
drop _merge;


** adding strata dummies;
sort schoolid;
merge schoolid using "Input\cct_stratum_an";
drop if _merge==2;
drop _merge;




preserve;
** addition weights;
u "Input\cct_hh_weights_an",clear;
drop if hhid=="";
duplicates drop hhid,force;
sort hhid;
save tp1,replace; 

restore;
sort hhid;
merge hhid using tp1;
erase tp1.dta;
assert _merge!=2;
drop _merge;


******;
** other treatment variables;
replace anytransfer=group!=0 if group!=.;
replace pere=benef=="Father";
replace mere=benef=="Mother";
replace control=group==0;
replace anycond=group!=1 & group!=0;
replace uncond=group==1;
gen cond_pere=anycond*pere;
gen uncond_mere=uncond*mere;
gen uncond_pere=uncond*pere;
gen cond_mere=anycond*mere;



********************************;
** SAVING;
sort hhid;
save "Output\workingtable_hh_baseline",replace;

