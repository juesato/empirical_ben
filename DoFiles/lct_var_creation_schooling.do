#delimit;
cap clear matrix;
clear;
set mem 600m;
set more off;

***************************************************;
**** VARIABLE creation schooling ******************;
***************************************************;

***************************;
**************School VISITS data;
use "Input\cct_school_visits_an.dta", clear;


*******************************************************;
** We want to generate the status of each children and the date of dropout if so;
*******************************************************;



#delimit cr
***********************************
*** on veut creer des var statut et absence pour 
** chaque visite


label define statut_visite 1 "1-inscrit" 2 "2-abandon" /*
*/ 3 "3-changement etab meme SS" /*
*/ 34 "34-changement etab indeterminé" /*
*/4 "4-changement etab autre SS" 5 "5-pas encore scolarisé"/*
*/ 6 "6-autre" 8 "8-primaire completé" -99 "info non dispo"

label define presence_visite 1 "1-present" 2 "2-absent" /*
*/ 4 "4-horraire de classe dif" -88 "-88 enseignant absent" /*
*/ -99 "info non dispo"

forvalues i=0/6 {
gen v`i'_statut=.
label var v`i'_statut "statut en visite `i'"
label values v`i'_statut statut_visite
gen v`i'_presence=.
label var v`i'_presence "présence en visite `i'"
label values v`i'_presence presence_visite
}

gen v0_sept_statut=.
label var v0_sept_statut "statut en sept 2008"
label values v0_sept_statut statut_visite



**********
** V0

replace v0_statut=1 if v0_a9==2 | v0_a9==3 | v0_a9==0
replace v0_statut=2 if v0_a9==1

** on utilise q3
replace v0_statut=1 if q3_q11==1 & v0_statut==.
replace v0_statut=2 if q3_q11==2
replace v0_statut=5 if q3_q11==3
replace v0_statut=5 if niv_ann==1 & v0_id_enf=="" & q3_q11==.

** le nouveau eleves
replace v0_statut=34 if v0_statut==. & q3_q11==4
replace v0_statut=5 if v1_c4==0 & v0_statu==.

** on utilise Q4
replace v0_statut=1 if v0_sta==. & q4_j9_2==1
replace v0_statut=2 if v0_sta==. & q4_j9_2==2
replace v0_statut=34 if v0_sta==. & q4_j9_2==3
replace v0_statut=5 if v0_sta==. & q4_j9_2==4

replace v0_statut=34 if v0_sta==. & q4_j9_1==3

** on corrige ceux qui ont un statut en v0_a9=4
** que l'on considère comme inscrit
** car c était horaire de classe dif ou ens absent
replace v0_statut=1 if v0_sta==. & v0_a9==4



************************
**** statut V0_sept

replace v0_sept_statut=1 if v1_c10==1
replace v0_sept_statut=2 if v1_c10==2
replace v0_sept_statut=3 if v1_c10==3
replace v0_sept_statut=4 if v1_c10==4
** si -99 en sept et 1 en v1 on met 1
replace v0_sept_statut=1 if v1_c10==-99 & v1_c12==1

** on utilise q4
replace v0_sept_statut=1 if q4_j9_1==1 & v0_sept_st==.
replace v0_sept_statut=2 if q4_j9_1==2 & v0_sept_st==.
replace v0_sept_statut=34 if q4_j9_1==3 & v0_sept_st==.
replace v0_sept_statut=5 if q4_j9_1==4 & v0_sept_st==.

** si nouveau inscrit en v4
replace v0_sept_statut=5 if v4_enf_nou==1 /*
*/ & v4_c4==0 & v0_sept_st==.

replace v0_sept_statut=5 if v4_enf_nou==1 /*
*/ & v4_c11==1 & v4_c11_b==2 & v0_sept_st==.



*********************
*** statut V1

replace v1_statut=1 if v1_c12==1 
replace v1_statut=2 if v1_c12==2
replace v1_statut=3 if v1_c12==3
replace v1_statut=4 if v1_c12==4

replace v1_statut=2 if v0_sept==2 & v1_stat==.
replace v1_statut=3 if v0_sept==3 & v1_stat==.
replace v1_statut=34 if v0_sept==34 & v1_stat==.
replace v1_statut=4 if v0_sept==4 & v1_stat==.
replace v1_statut=5 if v0_sept==5 & v1_stat==.

replace v1_statut=1 if v1_stat==. & q4_j9_1==1
replace v1_statut=5 if v1_stat==. & q4_j9_1==4
replace v1_statut=5 if v1_stat==. & v4_c4==0 & v4_c12==1

replace v1_statut=1 if v4_enf_nouv==. /*
*/ & v4_c12==8 & v1_statut==.

*replace v1_statut=-99 if v1_c12==-99 & v1_stat==. 




*********************
*** statut V2
replace v2_statut=1 if v2_c12==1
replace v2_statut=2 if v2_c12==2
replace v2_statut=3 if v2_c12==3
replace v2_statut=4 if v2_c12==4

replace v2_stat=3 if v1_stat==3 & v2_stat==.
replace v2_stat=34 if v1_stat==34 & v2_stat==.
replace v2_stat=4 if v1_stat==4 & v2_stat==.
replace v2_stat=5 if v1_stat==5 & v2_stat==.

*replace v2_stat=-99 if v2_c12==-99 & v2_stat==.
replace v2_stat=6 if v2_c12==5 & v2_stat==.


*********************
*** statut V3
replace v3_statut=1 if v3_c12==1
replace v3_statut=2 if v3_c12==2
replace v3_statut=3 if v3_c12==3
replace v3_statut=4 if v3_c12==4

replace v3_statut=3 if v1_stat==3 & v3_stat==.
replace v3_statut=4 if v1_stat==4 & v3_stat==.
replace v3_statut=5 if v1_stat==5 & v3_stat==.
replace v3_statut=34 if v1_stat==34 & v3_stat==.
replace v3_statut=6 if v3_c12==5 | v3_c12==6 & v3_stat==.

replace v3_statut=1 if v4_enf_nouv==. /*
*/ & v4_c12==8 & v3_statut==.
*replace v3_statut=-99 if v3_c12==-99 & v3_stat==.



************************
*** statut V4
replace v4_statut=1 if v4_c12==1
replace v4_statut=2 if v4_c12==2
replace v4_statut=3 if v4_c12==3
replace v4_statut=4 if v4_c12==4
replace v4_statut=8 if v4_c12==8

replace v4_stat=3 if v3_stat==3 & v4_stat==.
replace v4_stat=34 if v3_stat==34 & v4_stat==.
replace v4_stat=4 if v3_stat==4 & v4_stat==.

replace v4_statut=6 if v4_c12==6 & v4_stat==.
*replace v4_statut=-99 if v4_c12==-99 & v4_statut==.


************************
*** statut V5
replace v5_statut=1 if v5_c12==1
replace v5_statut=2 if v5_c12==2
replace v5_statut=3 if v5_c12==3
replace v5_statut=4 if v5_c12==4

replace v5_stat=3 if v4_stat==3 & v5_stat==.
replace v5_stat=34 if v4_stat==34 & v5_stat==.
replace v5_stat=4 if v4_stat==4 & v5_stat==.
replace v5_stat=8 if v4_stat==8 & v5_stat==.


*replace v5_statut=-99 if v5_c12==-99 & v5_stat==.


************************
*** statut V6
replace v6_statut=1 if v6_c12==1
replace v6_statut=2 if v6_c12==2
replace v6_statut=3 if v6_c12==3
replace v6_statut=4 if v6_c12==4
replace v6_statut=8 if v6_c12==8

replace v6_statut=3 if v5_stat==3 & v6_stat==.
replace v6_statut=34 if v5_stat==34 & v6_stat==.
replace v6_statut=4 if v5_stat==4 & v6_stat==.
replace v6_statut=8 if v5_stat==8 & v6_stat==.

*replace v6_statut=-99 if v6_c12==-99 & v6_stat==.



***********************************************
*********** ON FAIT DES HYPOTHESES


*******************************
** lien entre les visites
replace v0_sept_s=1 if v1_statut==1 & v0_sept==.

** si inscrit en v4 et v6 alors inscrit en v5
replace v5_sta=v6_stat if v5_stat==. & v6_stat==v4_stat

** idem pour v2 avec v1 et V3
replace v2_stat=v3_stat if v1_stat==v3_stat & v2_stat==.



*** on corrige les abandons
gen tot_abandon=0
gen tot_inscrit=0
foreach var of varlist *statut {
replace tot_abandon=tot_abandon+1 if `var'==2
replace tot_inscrit=tot_inscrit+1 if `var'==1
}
**** HYP
** si v3 miss et v1 et v4 == inscrit
** et l eleve et augmente d un niveau

replace v3_statut=1 if v1_stat==1 & v4_stat==1 /*
*/ & v4_c11==v1_c11+1 & (v3_stat==. | v3_stat==-99 /*
*/ | v3_stat==6)

replace v3_stat=1 if v0_stat!=2 & v1_stat==1 & v4_stat==1/*
*/ & v5_stat!=2 & v6_stat!=2 & (v3_stat==. | v3_stat==-99 /*
*/ | v3_stat==6)



**** si V0=inscrit ET V4=Inscrit
** ET V1 à V3 missing ET Niveau augmente de 2 entre
** 2008 et 2010
** --> on consdère que l'eleve ete inscrit l annee 1

gen tp1=(v0_stat==1 & v4_stat==1 & v1_stat==. & v2_stat==. /*
*/ & v3_stat==. & v4_c11==2+v0_i12_niv)
foreach var of varlist v0_sep v1_stat v2_stat v3_stat{
replace `var'=1 if tp1==1
}
drop tp1


*****************************************
******** HYPOTHESE SUR LES ABANDONS

** HYP
*** on met en abandon si 
** l eleve n est jamais signale comme inscrit
** est signale au moins 2 fois comme abandon

foreach var of varlist *_statut v0_sept {
replace `var'=2 if tot_ab>1 & tot_insc==0
}

drop tot_ab tot_inscr

gen tot_abandon=0
gen tot_inscrit=0
foreach var of varlist v1_statut-v6_statut {
replace tot_abandon=tot_abandon+1 if `var'==2
replace tot_inscrit=tot_inscrit+1 if `var'==1
}

foreach var of varlist v1_statut v2_statut v3_st v4_stat v5_stat v6_stat {
replace `var'=2 if tot_ab>1 & tot_insc==0 & v0_sept_statut==2
}


** si abandon en V4 signalé en 06/09
** et statut missing en V1 V2 et V3
** --> on met inscrit en v1 v2 et v3
gen tp2=(v1_stat==. & v2_stat==. & v3_stat==. & v0_sep==. /*
*/ & v4_stat==2 & v5_stat==2 & (v4_c13=="06/09" /*
*/ | v4_c13=="09/09"))

foreach var of varlist v0_sept v1_sta v2_sta v3_stat{
qui replace `var'=1 if tp2==1
}
drop tp2


gen tp1=((v1_statut==2 | v0_sept==2) & v2_statut==. & v3_stat==. & /*
*/ v4_stat==. & v5_stat==. & v6_stat==.)

foreach var of varlist v2_statut v3_st v4_stat v5_stat v6_stat {
replace `var'=2 if tp1==1
}


****************************
** correction de statut: incoherence avec toutes les visites
** pour les abandons
replace v6_statut=3 if stud_id=="A58711008"
replace v0_sep=2 if stud_id=="A42411007"
replace v5_stat=2 if stud_id=="A23911002"
replace v5_stat=2 if stud_id=="A48911016"
replace v4_stat=4 if stud_id=="A13011011"
replace v6_stat=4 if stud_id=="A13011011"
replace v5_stat=2 if stud_id=="A57812008"
replace v5_stat=2 if stud_id=="A47315016"
replace v6_stat=4 if stud_id=="A42213006"
replace v6_statut=3 if stud_id=="A03014012"
replace v5_statut=2 if stud_id=="A01912026"
replace v6_sta=4 if stud_id=="A54911005"

replace v1_statut=2 if stud_id=="A29112004"
replace v4_statut=2 if stud_id=="A29112004"
replace v5_statut=2 if stud_id=="A29112004"
replace v6_statut=2 if stud_id=="A29112004"
replace tp1=1 if stud_id=="A29112004"


********************************************
***** CREATION VARIABLES LAST_DATE ET AB_MANQUE
*******************************************

********************************
*** on veut creer la derniere date ou l'eleve est a l'ecole
** = 06/2010 si toutjours inscrit en V6
** et creer une variable pour le nombre de mois raté
** si l'eleve a abandonné puis et inscrit en v6


gen last_date=""
label var last_date "derniere date à l'ecole"

gen ab_manque=0
label var ab_manque "nombre de mois manqués" 

**1 si V6 = Inscrit on met last_date== 06/2010
** (on regarde juste apres les cas particuliers
** si abandon...
replace last_date="06/2010" if v6_statut==1

** =06/2009 si primaire completé
replace last_date="06/2009" if v6_statut==8 | v4_stat==8

** =-77 si changement d'etab
replace last_date="-77" if v6_statut==3 | v6_stat==34 /*
*/ | v6_stat==4

** si abandon entre v0 et les autre visites
replace last_date="06/2008" if v0_sept==2 & v2_stat!=1/*
*/ & v3_stat!=1 & v4_stat!=1 & v5_stat!=1 & v6_stat!=1

replace last_date="06/2008" if tp1==1
drop tp1


**********************************
** Si V6= abandon
** on corrige en suivant les règles suivantes

**** 1 (V6=abandon) si V3= inscrit,
**** ET (V4 ET V5 different de Inscrit)
**** OU (V4 OU V5 =abandon)
** alors on note last_date==06/2009
replace last_date="06/2009" if v6_stat==2 & v3_stat==1 /*
*/ &((v4_stat!=1 & v5_stat!=1) | (v4_stat==2 | v5_stat==2))



*** pour le reste on regarde à la main
** pour voir en meme temps toutes les differentes dates

***** 2 HYP
** si la date d abandon signale une date anterieur
** a une autre visite, on fait confiance à notre équipe
** sauf si plusieurs visites signalent la meme date
** ou si lors de la visite en question l eleve est absent
** si plusieurs date differente
** on prend la plus plausible
** et celle signalé par la 1ere visite signalant l abandon

/*
** pour voir les données que l on a corrigées à la 
** main
foreach var of varlist v1_c13 v3_c13 v4_c13 {
gen `var'_a=""
gen `var'_b=""
replace `var'_a=substr(`var',1,2)
replace `var'_b=substr(`var',-2,2)
}
*/

** on ajoute la base de correction
sort stud_id
merge stud_id using "Input\cct_correction_dropout_date_an"
ta _merge
** les 3 _merge==2 sont des duplicates que l'on a viré
** aprés avoir ajouter les V2(cad apres avoir fais ce 
** fichier)
drop if _merge==2
drop _merge

** on corrige les donnees

replace last_date=last_date_cor if last_date_cor!=""
replace ab_manque=ab_manq if ab_manq!=.

drop last_date_cor ab_manq


*****
** 2- Si v6=Abandon

** HYP: last date
** si inscrit en v6 et abandon autre date

** pour chaque HYP on regarde avec l'editeur
** si on ne trouve pas des réponses illogiques


*** A-
** 9 mois manqués si inscrit en 2009-2010
** mais abandon en 2008-2009 (non inscrit en v1 et
** non inscrit en v3)
replace ab_manque=9 if/*
*/ v6_stat==1 & tot_ab!=0 & v0_stat==1 & v5_stat!=2 /*
*/ & v4_stat!=2 & v0_sep!=1 & v3_stat!=1


*** B-
** 9 mois si abandon v1 mais dans les registres de 
** septembre 08 mais declare comme abandon mois 9/08
** puis 8 mois si abandon mois 10/08 puis 7 si mois 11...

*** on fait aussi pareil pour V3

gen ab_manq_cor=""
#delimit ;
local varlist " `"06 9"' `"09 9"' `"10 8"' `"11 7"' 
`"12 6"' `"01 5"' `"02 4"' `"03 3"' `"04 2"' `"05 1"'"; 
foreach var of local varlist {;
local mois = substr("`var'",1,2);
local nbr_manq = substr("`var'",-1,1);

replace ab_manq_cor="`nbr_manq'" if
   substr(v1_c13,1,2)=="`mois'" & v6_stat==1 & 
   tot_ab!=0 & v0_stat==1 & ab_manque==0 
   & v4_stat!=2 & v5_stat!=2 & v0_sep==1 
   & v1_stat!=1 & v3_c16!=1;

replace ab_manq_cor="`nbr_manq'" if
   substr(v3_c13,1,2)=="`mois'" & v6_stat==1 
   & tot_ab!=0 & v0_stat==1 & ab_manque==0 
   & v4_stat!=2 & v5_stat!=2 & v0_sep==1 
   & v3_stat==2 & v1_c13==""; 

};

#delimit cr

replace ab_manque=real(ab_manq_cor) if ab_manq_cor!=""
drop ab_manq_cor

** NB: pour les cas ou 
** v6= inscrit et V5=V4="non-abandon"
** ab_manque n'est missing que pour les cas ou 
** V3 =inscrit et l'enfant est present
** il faudra trancher à l'aide des V2... 


*****
** si V4 ou V5 ==abandon

**C- si v4 & v5=abandon
** ET si l'élèves n'est pas présent en V6
** alors on considère que v6=abandon

replace last_date="06/2009" /*
*/if v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0 /*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1 /*
*/ & (v4_c13=="06/09" | v4_c13=="09/09")

replace last_date="06/2009" if stud_id=="A32011010"

replace last_date="06/2008" /*
*/if v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0 /*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1 /*
*/ & (v4_c13=="06/08" | v4_c13=="09/08" /*
*/ | v4_c13=="01/08" | v4_c13=="06/07")

replace last_date="12/2008" /*
*/if v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0 /*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1 /*
*/ & v4_c13=="12/08"

replace last_date="04/2009" /*
*/if v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0 /*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1 /*
*/ & v4_c13=="04/09"

replace last_date="03/2009" /*
*/if v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0 /*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1 /*
*/ & v4_c13=="03/09"

replace last_date="06/2008" /*
*/if v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0 /*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1 /*
*/ & v4_c13=="" & v3_c13=="06/08"


gen temp_control=(v6_stat==1 & tot_ab!=0 & /*
*/ v6_stat==1 & tot_ab!=0 & v0_stat==1 /*
*/  & ab_manque==0  &  (v4_c13!="" | v3_c13=="06/08")/*
*/ & (v4_stat!=1 & v5_stat!=1) & v6_c16!=1)  



*************************
** si statut v6 missing et v3=inscrit et v4=abandon
** et v5 c16!=1 alors last_date=="06/2009"
replace last_date="06/2009" if (v6_stat==-99 | v6_stat==.) /*
*/ & v4_stat==2 & v3_stat==1 & v5_c16!=1


** autre hyp:
**1
replace last_date="06/2008" if (v6_stat==-99 | v6_stat==.) /*
*/ & tot_ab==3 & v0_stat==1

**2
replace last_date="06/2008" if (v6_stat==-99 | v6_stat==.) /*
*/ & tot_ab==2 & v0_stat==1 & ((v4_sta==. /*
*/| v4_stat==-99 | v4_stat==6) /*
*/ | v5_stat==. | v5_stat==-99 | v5_stat==6)


** 3 
replace last_date="06/2008" if last_date=="" /*
*/ & v0_sept==2 & v0_stat==1 & v2_stat==2 & v6_stat==2

**4
replace last_date="06/2008" if last_date=="" /*
*/ & (v0_sept==2 | v0_sep==.) & v0_stat==1 /*
*/ & v2_stat==2 & v6_stat==2

** 5 verifier avec l'editeur
replace last_date="03/2009" if stud_id=="A57514004" /*
*/ | stud_id=="A57514014" 


** si last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.)
** on remplace par la date signalée comme abandon
** et si l'eleve n'a jamais été présent

** avec v2_c13
replace last_date=substr(v2_c13,1,2)+"/20"+substr(v2_c13,-2,2)/*
*/ if temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v2_c13!="" & v3_c16!=1 & v4_c16!=1 & v5_c16!=1 & /*
*/ v1_c13=="" & v3_c13==""

** correction d'erreur probale sur v2_c13 (meme hyp que 
** juste au dessus juste v2_c13 et faux)
replace last_date="01/2009" if stud_id=="A56513016"
replace last_date="02/2009" if stud_id=="A28114006"
replace last_date="06/2008" if stud_id=="A52911022" | /*
*/ stud_id=="A52912013" | stud_id=="A01012002"

** idem avec v1_c13
replace last_date="06/2008" /*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v1_c13!="" &v2_c16!=1 & v3_c16!=1 & v4_c16!=1 & v5_c16!=1 /*
*/ & v0_stat!=2 & v1_c13=="09/08"

replace last_date=substr(v1_c13,1,2)+"/20"+substr(v1_c13,-2,2)/*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v1_c13!="" &v2_c16!=1 & v3_c16!=1 & v4_c16!=1 & v5_c16!=1 /*
*/ & v0_stat!=2

** idem avec v3_c13
replace last_date="06/2008" /*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v3_c13!=""  & v4_c16!=1 & v5_c16!=1 /*
*/ & v0_stat!=2 & v3_c13=="09/08"

replace last_date=substr(v3_c13,1,2)+"/20"+substr(v3_c13,-2,2)/*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v3_c13!=""  & v4_c16!=1 & v5_c16!=1 /*
*/ & v0_stat!=2

** idem avec v4_c13
replace last_date="06/2009" /*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v4_c13!=""  & v5_c16!=1 & v0_stat!=2 & v4_c13=="09/09"

replace last_date=substr(v4_c13,1,2)+"/20"+substr(v4_c13,-2,2)/*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v4_c13!=""  & v5_c16!=1 & v0_stat!=2

** idem avec v5_c13
replace last_date="06/2009" /*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v5_c13_a!="" & v0_stat!=2 & v5_c13_a=="9" 

replace last_date=substr(v5_c13_a,1,2)+"/2009" /*
*/ if  temp_contr!=1  & ab_manque==0 & /*
*/ last_date=="" & tot_ab!=0 & (v6_stat==-99 | v6_stat==.) /*
*/ & v5_c13_a!="" & v0_stat!=2 & (v5_c13_a!="6" /*
*/| (v5_c13_a=="6" & v4_c16!=1)) & v5_c13_a!="-99"

replace last_date="0"+last_date if length(last_date)==6



*** HYP
** si plus de 3 abandon et moins de 2 inscrit (inclu v0)
** alors abandon en 06/08
** et jamais signalé comme present
replace last_date="06/2008" /*
*/ if tot_ab>3 & v0_stat==1 & v6_stat==2 & last_date=="" /*
*/ & tot_inscrit<3 & v2_statut!=1 & v1_c16!=1

** idem mais prob de date (c13)
replace last_date="10/2008" if stud_id=="A09014025"
replace last_date="10/2008" if stud_id=="A22912020"


*****************************
****** STAT SUR LE NETOYAGE FINAL

drop tot_aba tot_inscrit temp_control


*************
** pourcentage de non complet par etab

gen statut_complet=((v0_sta!=. & v0_sep!=. & v1_sta!=. /*
*/ & v2_stat!=. & v3_sta!=. & v4_sta!=. /*
*/ & v5_sta!=. & v6_sta!=.) )| last_date!=""

gen annee_1_existe=(((v1_stat!=. & v1_stat!=-99) | /*
*/ (v2_stat!=. & v2_stat!=-99) | (v3_stat!=. & v3_stat!=-99))) | last_date!=""

gen annee_2_existe=(((v4_stat!=. & v4_stat!=-99) | /*
*/ (v5_stat!=. & v5_stat!=-99) | (v6_stat!=. & v6_stat!=-99))) | last_date!=""

*******************************************************;
*******************************************************;





#delimit;

************************************************;
* getting database ready;

gen niv_baseline=v1_c4;
replace niv_baseline=99 if niv_baseline==.;
	

* create a satellite dummy;
 	gen satellite=0;
		replace satellite=1 if type_unit=="Satellite";
		move satellite province;

*create dummies for treatment groups;
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
	gen uncond_pere=uncond*pere;

* we merge with stratification data;
	sort schoolid;
	merge schoolid using "Input\cct_stratum_an.dta";
		tab _merge;
		assert _merge==3;
		drop _merge;

	sort  schoolid schoolunitid stud_id;
save "Output\workingtable1", replace;


*****************************;
** Vars for Balance check at student level;
*****************************;
* school level  variables;
	gen elec=(v0_i15 == 1);

* grade level variables;
	gen multiniveau=(v0_i12_1==2);
	gen teacher_presence= (v0_i13==1) if v0_i13!=. & v0_i13!=0;
	replace v0_presence= (v0_a9==2) if v0_a9!=. & v0_a9!=0 & teacher_presence==1;
	gen v0_age=v0_a3;
		replace v0_age=. if v0_a3>19|v0_a3<5;
	gen v0_female=(v0_a4=="F") if v0_a4!="";
	gen obs=1;

	gen v0_dropout=v0_statut==2 if v0_statut==1 | v0_statut==2;
	gen missing_info_dropout_y2=last_date=="" | last_date=="-77" if v0_statut==1;
	gen missing_info_reenroll_y2=last_date=="" | last_date=="-77" if v0_statut==2;
destring age_2010, replace;
	gen age_2008=age_2010-2;
		replace age_2008=. if age_2008<5|age_2008>18;
		gen agemissing=(age_2008==.);
		bys v1_c4: egen meanage=mean(age_2008);
		replace age_2008=meanage if agemissing==1;
	gen female=(gender=="2");
		replace female=1 if gender=="0";

* at the end we decide to do the balance check only on those enrolled at baseline;
keep if v0_statut==1;

save "Output\temp_workingtableA2", replace;



**************************************************;
****** Var for balance check  ; 
use "Output\workingtable1", clear;

drop if v0_i12_niveau==0;
drop if v0_statut!=1;

*****************************;
* VARIABLES OF INTEREST *****;
*****************************;
* school level variables;
	gen elec=(v0_i15 == 1);

* grade level variables;
	gen multiniveau=(v0_i12_1==2);
	gen teacher_presence= (v0_i13==1) if v0_i13!=. & v0_i13!=0;
	replace v0_presence= (v0_a9==2) if v0_a9!=. & v0_a9!=0 & teacher_presence==1;
	gen v0_age=v0_a3;
		replace v0_age=. if v0_a3>19|v0_a3<5;
	gen v0_female=(v0_a4=="F") if v0_a4!="";
	gen obs=1;

	save "Output\temp", replace;

****************************************************************************;
* get info on number of sections per grade, and whether grade is multilevel;
*****************************************************************************;
	collapse v0_i12_niveau  (sum) obs ,by (schoolunitid v1_c4 v0_i17);
	sort  schoolunitid v1_c4 v0_i17;
	gen multiniveau_b=0;
		replace multiniveau_b=1 if schoolunitid==schoolunitid[_n-1]&v1_c4!=v1_c4[_n-1]&v0_i17==v0_i17[_n-1];
		replace multiniveau_b=1 if schoolunitid==schoolunitid[_n+1]&v1_c4!=v1_c4[_n+1]&v0_i17==v0_i17[_n+1];
	gen num_sections=1;
		replace num_sections=2 if schoolunitid==schoolunitid[_n-1]&v1_c4==v1_c4[_n-1]&v0_i17!=v0_i17[_n-1];
		replace num_sections=2 if schoolunitid==schoolunitid[_n+1]&v1_c4==v1_c4[_n+1]&v0_i17!=v0_i17[_n+1];
		replace num_sections=3 if schoolunitid==schoolunitid[_n-2]&v1_c4==v1_c4[_n-2]&v0_i17!=v0_i17[_n-2];
		replace num_sections=3 if schoolunitid==schoolunitid[_n+2]&v1_c4==v1_c4[_n+2]&v0_i17!=v0_i17[_n+2];
		replace num_sections=3 if schoolunitid==schoolunitid[_n+1]&v1_c4==v1_c4[_n+1]&v0_i17!=v0_i17[_n+1]&schoolunitid==schoolunitid[_n-1]&v1_c4==v1_c4[_n-1]&v0_i17!=v0_i17[_n-1];
		replace num_sections=4 if schoolunitid==schoolunitid[_n-3]&v1_c4==v1_c4[_n-3]&v0_i17!=v0_i17[_n-3];
		replace num_sections=4 if schoolunitid==schoolunitid[_n-2]&v1_c4==v1_c4[_n-2]&v0_i17!=v0_i17[_n-2]&schoolunitid==schoolunitid[_n+1]&v1_c4==v1_c4[_n+1]&v0_i17!=v0_i17[_n+1];
		replace num_sections=4 if schoolunitid==schoolunitid[_n+2]&v1_c4==v1_c4[_n+2]&v0_i17!=v0_i17[_n+2]&schoolunitid==schoolunitid[_n-1]&v1_c4==v1_c4[_n-1]&v0_i17!=v0_i17[_n-1];;
		replace num_sections=4 if schoolunitid==schoolunitid[_n+3]&v1_c4==v1_c4[_n+3]&v0_i17!=v0_i17[_n+3];
	
	collapse multiniveau_b num_sections, by(schoolunitid v1_c4);
	sort schoolunitid v1_c4; 
	save "Output\classinfo", replace;

	
**************************************************************;	
use "Output\temp", clear;
	sort schoolunitid v1_c4;
	merge schoolunitid v1_c4 using "Output\classinfo.dta";

	foreach num of numlist 1/5 {;
		bys schoolunitid: egen enroll_`num'=count(v1_c4) if v1_c4==`num';
		};

** particular case with level 1 and 2 together (problem with classes data);
	replace enroll_1=enroll_1/2 if schoolunitid=="A446";
	replace enroll_2=enroll_1/2 if schoolunitid=="A446";

	save "Output\workingtable2", replace;


	
**************;
*** Geting school level info;
by schoolunitid,sort: egen v0_tot_classe=max(v0_i17);

collapse (sum)obs (mean) elec multiniveau multiniveau_b num_sections 
v0_age v0_female v0_tot_classe teacher_presence v0_presence enroll* mere, by(schoolunitid group schoolid);

	gen control=0 if group!=.;
		replace control=1 if group==0;
	gen anytransfer=1 if group!=.;
		replace anytransfer=0 if group==0;	
	gen anycond=0 if group!=.;
		replace anycond=1 if group==2|group==3|group==4;



********;
** We merge with the preliminary survey;
sort schoolunitid;
merge schoolunitid using "Input\cct_preliminary_survey_an", sort;
*ta _merge;
drop if _merge==2;
ren _merge merging_vis_eq_prel;


******;
** We create variables with the prelininary survey;
gen prel_elec=a16_1==1 if a16_1!=.;

gen prel_dist_road=g10;

gen prel_dist_post=g15;
replace prel_dist_post=0 if g13==1;

gen prel_inacc_winter=g5==3 if g5!=.;
replace prel_inacc_winter=1 if g4==3 | g4==2;
replace prel_inacc_winter=0 if g4==1;

gen prel_toilet=a19==6 if a19!=.;




*******;
** we want to include the list of units with no HH ever surveyed;
sort schoolunitid;
merge schoolunitid using "Output\list_unit_never_surveyed";
*ta _merge;
drop if _merge==1;
drop _merge;



******;
** adding strata dummies and treatment variables;
sort schoolid;
merge schoolid using "Input\cct_stratum_an";
ta _merge;
drop if _merge==2;
drop _merge;

gen v0_student_classroom_ratio=obs/v0_tot_classe;
gen uncond= group==1;
gen pere=mere==0 & group!=0;
gen cond_pere=anycond*pere;
gen cond_mere=anycond*mere;
gen uncond_mere=uncond*mere;
gen uncond_pere=uncond*pere;



*******************;
sort schoolunitid;
save "Output\school_level_data", replace;
erase "Output\temp.dta";



************;
** removing schools not surveyed from the ;


u "Output\temp_workingtableA2", clear;
erase "Output\temp_workingtableA2.dta";

cap drop _merge;
sort schoolunitid;
merge schoolunitid using "Output\list_unit_never_surveyed";
ta _merge;
keep if _merge==3;
drop _merge;

save "Output\workingtableA2", replace;


******************************************;
******************************************;
******  Var creation *******;
******************************************;
******************************************;

* We define variables for kids enrolled in school in June 2008;
#delimit;
use "Output\workingtable2", clear;

* indiv controls;
	destring age_2010, replace;
	gen age_2008=age_2010-2;
		replace age_2008=. if age_2008<5|age_2008>18;
		gen agemissing=(age_2008==.);
		bys v1_c4: egen meanage=mean(age_2008);
		replace age_2008=meanage if agemissing==1;
	gen female=(gender=="2");
		replace female=. if gender=="0";

*reformat last_date to make it usable;
	split last_date, p("/") gen(bub) destring;
	gen month_dropout=bub1;
		replace month_dropout=. if month_dropout==-77;
	gen year_dropout=bub2;

* sampling frame: those enrolled in school in june 08, in grades 1-5;
	drop if year_dropout==2008 & month_dropout<6;
	drop if v1_statut==5;
	drop if v1_c4==6;
	drop if v0_statut!=1;

*dropouts between june2008 and sep2008;
gen dropout_summer08=0 if year_dropout==2009|year_dropout==2010;
	replace dropout_summer08=0 if year_dropout==2008 & month_dropout>6 & month_dropout!=.;
	replace dropout_summer08=1 if year_dropout==2008 & month_dropout==6;
	replace dropout_summer08=. if v1_c4==6;

*dropouts between june2009 and sep2009;
gen dropout_summer09=0 if year_dropout==2010;
	replace dropout_summer09=0 if year_dropout==2009 & month_dropout>6 & month_dropout!=.;
	replace dropout_summer09=1 if year_dropout==2009 & month_dropout==6;
	replace dropout_summer09=. if v1_c4==5|v1_c4==6;

* dropouts in the middle of the first year;
gen dropout_y1=0 if year_dropout==2010;
	replace dropout_y1=0 if year_dropout==2009&month_dropout>=6;
	replace dropout_y1=1 if year_dropout==2009&month_dropout<6;
	replace dropout_y1=1 if year_dropout==2008&month_dropout>=9;

* dropouts in the middle of the second year;
gen dropout_y2=0 if year_dropout==2010 & month_dropout==6;
	replace dropout_y2=1 if year_dropout==2009&month_dropout>6;
	replace dropout_y2=1 if year_dropout==2010&month_dropout<6;
	replace dropout_y2=. if v1_c4==5;

*any dropout;
egen dropout=rsum(dropout_summer08 dropout_summer09 dropout_y1 dropout_y2) if last_date!="" & last_date!="-77";
	replace dropout=1 if dropout>1 & dropout!=.;

*any dropout, by grade;
gen dropout_g12=dropout if v1_c4==1|v1_c4==2;
gen dropout_g3=dropout if v1_c4==3;
gen dropout_g4=dropout if v1_c4==4;
gen dropout_g34=dropout if v1_c4==4 | v1_c4==3;
gen dropout_g5=dropout if v1_c4==5;

*** dropout grade 1-4 at baseline;
gen dropout_g14=dropout if v1_c4==1 | v1_c4==2 | v1_c4==3 | v1_c4==4;

*** dropout by year grade1-4 at baseline;
gen dropout_g14_y1=dropout_summer08==1 | dropout_y1==1 if (dropout_y1!=. | dropout_summer08!=.) 
			& (v1_c4==1 | v1_c4==2 | v1_c4==3 | v1_c4==4);
gen dropout_g14_y2=dropout_summer09==1 | dropout_y2==1 if (dropout_y2!=. | dropout_summer09!=.) 
			& (v1_c4==1 | v1_c4==2 | v1_c4==3 | v1_c4==4);
gen dropout_g24_y1=dropout_summer08==1 | dropout_y1==1 if (dropout_y1!=. | dropout_summer08!=.) 
			& (v1_c4==2 | v1_c4==3 | v1_c4==4);
gen dropout_g13_y2=dropout_summer09==1 | dropout_y2==1 if (dropout_y2!=. | dropout_summer09!=.) 
			& (v1_c4==1 | v1_c4==2 | v1_c4==3);
			

* by gender and type of school;
*dropout, by gender;
gen dropout_g14_G=dropout_g14 if female==1;
gen dropout_g14_B=dropout_g14 if female==0;
*dropout, by type of school;
gen dropout_g14_sat=dropout_g14 if satellite==1;
gen dropout_g14_ecolemere=dropout_g14 if satellite==0;

*** in gade 5 at baseline and completed primary school;
gen completed_g5=v4_statut==8 if  v1_c4==5 & v0_statut==1 & v4_statut!=3 & v4_statut!=4 & v4_statut!=.;
 replace completed_g5=0 if completed_g5==. & v1_c4==5 & v0_statut==1 & (v5_statut==1 | v5_statut==2) ;
 replace completed_g5=1 if completed_g5==. & v1_c4==5 & v0_statut==1 & v5_statut==8;
 replace completed_g5=0 if completed_g5==. & v1_c4==5 & v0_statut==1 & (v6_statut==1 | v6_statut==2) ;
 replace completed_g5=1 if completed_g5==. & v1_c4==5 & v0_statut==1 & v6_statut==8;
* by gender and type of school;
*dropout, by gender;
gen completed_g5_G=completed_g5 if female==1;
gen completed_g5_B=completed_g5 if female==0;
*dropout, by type of school;
gen completed_g5_sat=completed_g5 if satellite==1;
gen completed_g5_ecolemere=completed_g5 if satellite==0;


*dropout, by gender;
gen dropout_G=dropout if female==1;
gen dropout_B=dropout if female==0;

*dropout, by type of school;
gen dropout_sat=dropout if satellite==1;
gen dropout_ecolemere=dropout if satellite==0;

*promotions;
destring v5_niveau_quest, replace;
gen promoted=0 if v1_c11!=.  & dropout_y1==0 & dropout_summer08==0;
	replace promoted=1 if v4_c11>v1_c11&v4_c11!=.;
	replace promoted=1 if promoted==0&v5_niveau_quest>v1_c11&v5_niveau_quest!=.;
	replace promoted=1 if  v1_c11==6 & (v4_statut==8 |v5_statut==8 |v6_statut==8 );

*promotion, by grade;
gen promoted_g1=promoted if v1_c11==1;
gen promoted_g2=promoted if v1_c11==2;
gen promoted_g3=promoted if v1_c11==3;
gen promoted_g4=promoted if v1_c11==4;
gen promoted_g5=promoted if v1_c11==5;
gen promoted_g6=promoted if v1_c11==6;
replace promoted=. if v1_c4==5;

*promotion, by gender;
gen promoted_G=promoted if female==1;
gen promoted_B=promoted if female==0;

*promotion 2 years after year 0 if enrol in grade X in year 0;
gen niveau_temp_y2=v4_c11;
replace niveau_temp_y2=v5_niveau_quest if niveau_temp_y2==.;
gen info_year2=(v4_statut==1 | v4_statut==2) | (v5_statut==1 | v5_statut==2)
	| (v6_statut==1 | v6_statut==2);

gen promoted_y0_y2=niveau_temp_y2==v1_c4+2 if v1_c4!=. & v0_statut==1  & info_year2==1;
gen promoted_g1y0_g3y2=niveau_temp_y2==3 if v1_c4==1 & v0_statut==1 & info_year2==1;
gen promoted_g2y0_g4y2=niveau_temp_y2==4 if v1_c4==2 & v0_statut==1 & info_year2==1;
gen promoted_g3y0_g5y2=niveau_temp_y2==5 if v1_c4==3 & v0_statut==1 & info_year2==1;
gen promoted_g4y0_g6y2=niveau_temp_y2==6 if v1_c4==4 & v0_statut==1 & info_year2==1;

drop niveau_temp_y2;


*******;
** Moved to another school;
#delimit;
gen moved_y0_y2=v4_statut==4 if v4_statut!=. & v0_statut==1 ;
replace moved_y0_y2=0 if v5_statut==1 | v5_statut==2 | v5_statut==8
	| v6_statut==1 | v6_statut==2 | v6_statut==8;
replace moved_y0_y2=1 if moved_y0_y2==. & (v5_statut==4 | v6_statut==4);
replace moved_y0_y2=. if v1_c4==. | v1_c4==5;

* by gender and type of school;
*dropout, by gender;
gen moved_y0_y2_f=moved_y0_y2 if female==1;
gen moved_y0_y2_m=moved_y0_y2 if female==0;
*dropout, by type of school;
gen moved_y0_y2_sat=moved_y0_y2 if satellite==1;
gen moved_y0_y2_ecolemere=moved_y0_y2 if satellite==0;	
	

******;
*absence of students;
foreach num of numlist 1/6 {;
	replace v`num'_presence=0 if v`num'_c16==2;
	replace v`num'_presence=1 if v`num'_c16==1;
	gen v`num'_absence=1-v`num'_presence;
};

** average absence over all surprise visits;
*note: v1 and v4 were announced, i'm not counting them;

egen absence_all=rmean(v2_absence v3_absence v5_absence v6_absence);

gen absence_girls=absence_all if female==1;
gen absence_boys=absence_all if female==0;
gen absence_sat=absence_all if satellite==1;
gen absence_ecolemere=absence_all if satellite==0;

** average absence in year 1; 
egen absence_y1=rmean(v2_absence v3_absence);

** average absence in year 2; 
egen absence_y2=rmean(v5_absence v6_absence);
replace absence_y2=. if v1_c4==5;


*absence of teachers - pupil level data (in tables we use the teacher database, not this one);
foreach num of numlist 1/6 {;
	gen v`num'_teacher_absence=.; 
	replace v`num'_teacher_absence=1 if v`num'_c16==-88;
	replace v`num'_teacher_absence=0 if v`num'_c16==1 | v`num'_c16==2;
	};

** average teacher absence over all surprise visits;
*note: v1 and v4 were announced, i'm not counting them;

egen teacher_absence_all=rmean(v2_teacher_absence v3_teacher_absence v5_teacher_absence v6_teacher_absence);

** average teacher absence in year 1; 
egen teacher_absence_y1=rmean(v2_teacher_absence v3_teacher_absence);

** average teacher absence in year 2; 
egen teacher_absence_y2=rmean(v5_teacher_absence v6_teacher_absence);



******;
** we want to keep only data in the sample;
cap drop _merge;
sort schoolunitid;
merge schoolunitid using "Output\list_unit_never_surveyed";
ta _merge;
keep if _merge==3;



************;
**** we add school level data;
drop _merge;
sort schoolunitid;
save tp1,replace;
u "Output\school_level_data",clear;

global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid $school_var;
sort schoolunitid;
 save tp2,replace;
u tp1,clear;
merge schoolunitid using tp2;
ta _merge;
drop if _merge==2;
drop _merge;
foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};
erase tp1.dta;	
erase tp2.dta;	




********************************************;
save "Output\workingtable3", replace;
********************************************;








*******************************************************;
*******************************************************;
* We define variables for kids who had dropped out school by June 2008;
#delimit;
use "Output\workingtable1", clear;
*******************************************************;

* sampling frame;
drop if v1_c4==6;
gen dropout08=(v0_statut==2);

** dropout out in 2008 and not enrolled in 2008;
keep if dropout08==1 | v0_statut==5;


* indiv controls;
	destring age_2010, replace;
	gen age_2008=age_2010-2;
		replace age_2008=. if age_2008<5|age_2008>18;
		gen agemissing=(age_2008==.);
		bys v1_c4: egen meanage=mean(age_2008);
		replace age_2008=meanage if agemissing==1;
	gen female=(gender=="2");
		replace female=. if gender=="0";

* dep var of interest;
gen enrolled_y1= (v1_statut==1 | v2_statut==1 | v3_statut==1);
	replace enrolled_y1=. if v1_statut==. & v2_statut==. & v3_statut==.;
gen enrolled_y2= (v4_statut==1 | v5_statut==1 | v6_statut==1);
	replace enrolled_y2=. if v4_statut==. & v5_statut==. & v6_statut==.;

* by gender and school type;
	gen enrolled_y1g=enrolled_y1 if female==1;
	gen enrolled_y1b=enrolled_y1 if female==0;
	gen enrolled_y2_g12=enrolled_y2 if v1_c4<=2;
	gen enrolled_y2_g3=enrolled_y2 if v1_c4==3;
	gen enrolled_y2_g4=enrolled_y2 if v1_c4==4;
	gen enrolled_y2_g5=enrolled_y2 if v1_c4==5;
	gen enrolled_y2g=enrolled_y2 if female==1;
	gen enrolled_y2b=enrolled_y2 if female==0;
	gen enrolled_y1sat=enrolled_y1 if satellite==1;
	gen enrolled_y1ecolemere=enrolled_y1 if satellite==0;
	gen enrolled_y2sat=enrolled_y2 if satellite==1;
	gen enrolled_y2ecolemere=enrolled_y2 if satellite==0;



************;
**** we add school level data;
sort schoolunitid;
save tp1,replace;
u "Output\school_level_data",clear;

global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid $school_var;
sort schoolunitid;
 save tp2,replace;
u tp1,clear;
merge schoolunitid using tp2;
drop if _merge==1;
assert _merge!=1;
drop if _merge==2;
drop _merge;
foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};
erase tp1.dta;	
erase tp2.dta;	


**************************************************;
save "Output\workingtable4", replace;
**************************************************;

* we define absences for child-day observations (instead of child);
#delimit;
use "Output\workingtable3", clear;

keep  stud_id-satellite control
 uncond cond* any* pere mere stratum niv_baseline
 age_2008 agemissing female v1_c4 v1_absence-v6_absence v?_date;

** renaming;
	foreach date in v1 v2 v3 v4 v5 v6 {;
		rename `date'_absence absence_`date';
		ren `date'_date date_`date';
		};
	foreach j of numlist 1/6 {;
		rename absence_v`j' absence`j'; 
		ren date_v`j' date`j';
		};

	
	* we reshape 1 obs = 1 child-day;
	reshape long absence date, i(stud_id) j(visit);
 
	* we only consider visits 2, 3, 5 and 6 since 1 and 4 were announced;
	gen absence_y1=absence if visit==2 | visit==3;
	gen absence_y2=absence if visit==5 | visit==6;
	gen absence_all=absence if visit==2 | visit==3 | visit==5 | visit==6;
		
	gen absence_girls=absence_all if female==1;
	gen absence_boys=absence_all if female==0;
	gen absence_sat=absence_all if satellite==1;
	gen absence_ecolemere=absence_all if satellite==0;

	* same var but for attendance;
	gen attenance_y1=1-absence_y1;
gen attenance_y1_g14=attenance_y1 if niv_baseline>0 & niv_baseline<5;
	gen attenance_y2=1-absence_y2;
gen attenance_y2_g14=attenance_y2 if niv_baseline>0 & niv_baseline<5;
	gen attenance_all=1-absence_all;
	
	gen attenance_girls=1-absence_girls;
	gen attenance_boys=1-absence_boys;
	gen attenance_sat=1-absence_sat;
	gen attenance_ecolemere=1-absence_ecolemere;


	gen date_td=mdy(real(substr(date,3,2)),
	real(substr(date,1,2)),2000+real(substr(date,5,2))) if substr(date,1,2)!="00";
	format date_td %td;
	move date_td date;	

	gen day_of_week=dow(date_td);
	replace day_of_week=0 if date_td==.;
	gen day_of_week_miss=date_td==.;


************;
**** we add school level data;
sort schoolunitid;
save tp1,replace;
u "Output\school_level_data",clear;

global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid $school_var;
sort schoolunitid;
 save tp2,replace;
u tp1,clear;
merge schoolunitid using tp2;
assert _merge!=1;
ta _merge;
drop if _merge==2;
drop _merge;
foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};
erase tp1.dta;	
erase tp2.dta;	


*******************************************;
save "Output\workingtable5", replace;
*******************************************;






******************************************;
******************************************;
********** HH SURVEY DATA;
******************************************;
******************************************;

*********************;
** VARIABLE CREATION WITH INDIV HH DATA ;
*********************;

*************************************;
#delimit;
use "Output\indiv_sectionD.dta", clear;


**************************************;
*** MISSING HH CONTROLS;
**************************************;
foreach var in bs_pchildren_enrolled bs_nchildren 
bs_nchildren615 bs_pchildren_dropout bs_pchildren_neverenrolled bs_own_cellphone bs_age_head{;
	gen `var'_miss=(`var'==.);
	replace `var'=0 if `var'==.; 
	};

**********************************;
** OTHER CONTROL AND GROUP VAR;
gen satellite=type_unit=="Satellite";
move satellite uncond;
gen age_baseline=age_endline-2;

gen age59_baseline=.;
	replace age59_baseline=1 if inrange(age_baseline,5,9);
	replace age59_baseline=0 if inrange(age_baseline,10,15);

gen allkids_endline=(status=="merged" | status=="only endline");
gen allkids_endbase=(status=="merged");
gen inschool_baseline= (status=="merged" & bs_enrolled==1);

* Among "new kids" we are going to look at different subgroups;
	gen onlyendline=0 if allkids_endline==1; 
		replace onlyendline=1 if allkids_endline==1 & allkids_endbase==0;

	gen onlyend_oldkids=0 if allkids_endline==1;
		replace onlyend_oldkids=1 if (status_des=="onlyend-missing section D at baseline" | status_des=="onlyend-new HH" | status_des=="onlyend-not 6-15 at baseline") & onlyendline==1;

	gen onlyend_newcomers=0 if allkids_endline==1;
		replace onlyend_newcomers=1 if onlyendline==1 & onlyend_oldkids==0;

		*tab1 status allkids_end allkids_endbase inschool_baseline if age_baseline>=5 & age_baseline<=15;

 gen allkids_endold = 0 if allkids_endline==1;
	replace allkids_endold = 1 if allkids_endbase==1 |  onlyend_oldkids==1;



********************************;
**** SCHOOLING;
*****************************;

gen enrolled=0 if d5==1 | d5==2;
	replace enrolled=1 if d5==1;

gen dropout=0 if d5==1 | (d5==2 & (d6==1 | d6==2));
	replace dropout=1 if d5==2 & d6==1;

gen neverenrolled=0 if d5==1 | (d5==2 & (d6==1 | d6==2));
	replace neverenrolled=1 if d5==2 & d6==2; 

gen neverenrolled_boys=neverenrolled if girl==0;
gen neverenrolled_girls=neverenrolled if girl==1;
gen neverenrolled_sch_sec=neverenrolled if satellite==0;
gen neverenrolled_sat=neverenrolled if satellite==1;

gen dropout0810=0 if dropout==0 | (dropout==1 & inrange(d9_m,1,12) & inrange(d9_a,1990,2010));
	replace dropout0810=1 if (d9_a==2008 & inrange(d9_m,9,12)) | d9_a==2009 | d9_a==2010;
*note: dropout0810: for the time being we exclude missing dates, we could also assume all missing dates are older than Sept 2008;

gen dropout_since2008=enrolled==0 if bs_enrolled==1 & enrolled!=.;
gen dropout_since2008_boys=dropout_since2008 if bs_girl==0;
gen dropout_since2008_girls=dropout_since2008 if bs_girl==1;
gen dropout_since2008_sch_sec=dropout_since2008 if satellite==0;
gen dropout_since2008_sat=dropout_since2008 if satellite==1;

gen reenrolled=0 if enrolled==0 | (enrolled==1 & (d48==1 | d48==2));
	replace reenrolled=1 if d48==1; 
	*note: we have missing info on re-enrollement for 813 kids that are in school in 2010 (question D48);

gen reenrolled0810_endline=0 if enrolled==0 | d48==2 | (enrolled==1 & inrange(d52_m,1,12) & inrange(d52_a,1990,2010));
	replace reenrolled0810_endline=1 if (d52_a==2008 & inrange(d52_m,9,12)) | d52_a==2009 | d52_a==2010;

	*note: only for half of the kids that reenrolled in school we have the date;	
	*note: reenrolled0810: for the time being we exclude missing dates, we could also assume all missing dates are older than Sept 2008;
gen dropout08_enroll10= enrolled==1 if bs_dropout==1 & enrolled!=.;

gen dropout08_enroll10_boys=dropout08_enroll10 if bs_girl==0;
gen dropout08_enroll10_girls=dropout08_enroll10 if bs_girl==1;
gen dropout08_enroll10_sch_sec=dropout08_enroll10 if satellite==0;
gen dropout08_enroll10_sat=dropout08_enroll10 if satellite==1;

gen dropout_07_08_enroll10=dropout08_enroll10 if bs_dropout_2007_2008==1;
	
gen reenrolled0810_2rounds=0 if enrolled!=. & bs_dropout!=.;
	replace reenrolled0810_2rounds=1 if bs_dropout==1 & enrolled==1;
 	
	
******;
* Never enrolled in school;
	* Reasons;

	gen ne_young=0 if neverenrolled!=.;
		replace ne_young=1 if d7_1==1;

	gen ne_health=0 if neverenrolled!=.;
		replace ne_health=1 if d7_2==1;

	gen ne_schoolquality=0 if neverenrolled!=.;
		replace ne_schoolquality=1 if d7_3==1;  

	gen ne_schoolaccess=0 if neverenrolled!=.;
		replace ne_schoolaccess=1 if d7_5==1 | d7_6==1;  

	gen ne_financial=0 if neverenrolled!=.;
		replace ne_financial=1 if d7_9==1 | d7_10==1 | d7_11==1;

	gen ne_hhwork=0 if neverenrolled!=.;
		replace ne_hhwork=1 if d7_12==1 | d7_13==1;

	gen ne_work_outside=0 if neverenrolled!=.;
		replace ne_work_outside=1 if d7_14==1;
	
	gen ne_risky_for_girls=0 if neverenrolled!=.;
		replace ne_risky_for_girls=1 if d7_16==1;
	
	gen ne_kidwanted=0 if neverenrolled!=.;
		replace ne_kidwanted=1 if d7_18==1;

	egen nomiss=rsum(d7_1-d7_18);
	foreach var of varlist ne_young-ne_kidwanted{;
		replace `var'=. if nomiss==0 & neverenrolled==1;
		};
		drop nomiss;


* Dropouts;
	* Reasons;

	gen do_old=0 if dropout!=.;
		replace do_old=1 if d10_1==1;

	gen do_health=0 if dropout!=.;
		replace do_health=1 if d10_2==1;

	gen do_schoolquality=0 if dropout!=.;
		replace do_schoolquality=1 if d10_3==1 | d10_5==1 | d10_6==1;  

	gen do_schoolaccess=0 if dropout!=.;
		replace do_schoolaccess=1 if d10_13==1 | d10_14==1 | d10_15==1;  

	gen do_financial=0 if dropout!=.;
		replace do_financial=1 if d10_9==1 | d10_10==1 | d10_11==1 | d10_12==1;

	gen do_hhwork=0 if dropout!=.;
		replace do_hhwork=1 if d10_18==1 | d10_19==1;
		
	gen do_work_outside=0 if dropout!=.;
		replace do_work_outside=1 if d10_20==1;

	gen do_kidwanted=0 if dropout!=.;
		replace do_kidwanted=1 if d10_24==1;

	egen nomiss=rsum(d10_1-d10_24);

	foreach var of varlist do_old-do_kidwanted {;
		replace `var'=. if nomiss==0 & dropout==1;
		};
		drop nomiss;

*** reason for dropout since 2008;

foreach var of varlist do_old-do_kidwanted {;
	gen `var'_since2008=`var' if dropout_since2008!=.;	
};

	* Other variables;

	gen do_repeated=0 if dropout==0 | (dropout==1 & inrange(d13,1,4));
		replace do_repeated=1 if inrange(d13,2,4);

	gen do_satellite=0 if dropout==0 | (dropout==1 & inrange(d16,1,2));
		replace do_satellite=1 if d16==2;

	gen do_timegoschool=0 if dropout==0 | (dropout==1 & d22_1>0 & d22_1!=.);
		replace do_timegoschool=do_timegoschool+d22_1 if d22_1>0 & d22_1!=.;

	gen do_timebackschool=0 if dropout==0 | (dropout==1 & d22_2>0 & d22_2!=.);
		replace do_timebackschool=do_timebackschool+d22_2 if d22_2>0 & d22_2!=.;

	gen do_timetripschool=do_timegoschool+do_timebackschool;


 

* Enrolled;

	gen in_repeated=0 if enrolled==0 | (enrolled==1 & inrange(d25,1,4));
		replace in_repeated=1 if inrange(d25,2,4);

	gen in_satellite=0 if enrolled==0 | (enrolled==1 & inrange(d31,1,2));
		replace in_satellite=1 if d31==2;

	gen in_timegoschool=0 if enrolled==0 | (enrolled==1 & d34>0 & d34!=.);
		replace in_timegoschool=in_timegoschool+d34 if d34>0 & d34!=.;

	gen in_timebackschool=0 if enrolled==0 | (enrolled==1 & d34_a>0 & d34_a!=.);
		replace in_timebackschool=in_timebackschool+d34_a if d34_a>0 & d34_a!=.;

	gen in_timetripschool=in_timegoschool+in_timebackschool;

	gen in_mealinschool=0 if enrolled==0 | (enrolled==1 | inrange(d37,1,2));
		replace in_mealinschool=1 if d37==1;

	* Absenteeism;
		* First 14 days of May 2010;

	gen ndays_teachabs_12days=0 if enrolled!=.;
		replace ndays_teachabs_12days=ndays_teachabs_12days+d41 if d41>0 & d41!=.;
		replace ndays_teachabs_12days=ndays_teachabs_12days+d42 if d42>0 & d42!=.;
		replace ndays_teachabs_12days=. if enrolled==1 & ((d41==. | d41==-99 ) & (d42==. | d42==-99));  

	gen ndays_holiday_12days=0 if enrolled!=.;
		replace ndays_holiday_12days=ndays_holiday_12days+d43 if d43>0 & d43!=.;
		replace ndays_holiday_12days=. if enrolled==1 & (d43==. | d43==-99);  

	gen ndays_childabs_12days=0 if enrolled!=.;
		replace ndays_childabs_12days=d44 if d44>0 & d44!=.;
		replace ndays_childabs_12days=. if d44==-99 | (enrolled==1 & (d44==. | d44==-99));

	egen ndays_notattending_12days=rsum(ndays_teachabs_12days ndays_holiday_12days ndays_childabs_12days);
		replace ndays_notattending_12days=. if ndays_teachabs_12days==. & ndays_holiday_12days==. & ndays_childabs_12days==.;

	gen pdays_notattending_12days=ndays_notattending_12days/12;


		foreach var in ndays_teachabs_12days ndays_holiday_12days ndays_childabs_12days ndays_notattending_12days pdays_notattending_12days {;
			replace `var'=. if ndays_notattending_12days>14;
			};

	gen teachabs_12days=0 if ndays_teachabs_12days!=.;
		replace teachabs_12days=1 if ndays_teachabs_12days>0 & ndays_teachabs_12days!=.;

	gen holiday_12days=0 if ndays_holiday_12days!=.;
		replace holiday_12days=1 if ndays_holiday_12days>0 & ndays_holiday_12days!=.;

	gen childabs_12days=0 if ndays_childabs_12days!=.;
		replace childabs_12days=1 if ndays_childabs_12days>0 & ndays_childabs_12days!=.;

	gen notattending_12days=0 if ndays_notattending_12days!=.;
		replace notattending_12days=1 if ndays_notattending_12days>0 & ndays_notattending_12days!=.;

******;
** Overall measure: if enrolled and if attendented the whole month in May2010;
gen enroll_attend_May2010=enrolled==1;
replace enroll_attend_May2010=0 if  ndays_notattending_12days>11 & ndays_childabs_12days>0 
										& ndays_notattending_12days!=. & ndays_childabs_12days!=.;
gen enroll_attend_May2010_boys=enroll_attend_May2010 if bs_girl==0;
gen enroll_attend_May2010_girls=enroll_attend_May2010 if bs_girl==1;
gen enroll_attend_May2010_sch_sec=enroll_attend_May2010 if satellite==0;
gen enroll_attend_May2010_sat=enroll_attend_May2010 if satellite==1;

    
		* At least a week during school year 2009/2010;

	gen notattending_oneweek=0 if enrolled!=.;
		replace notattending_oneweek=1 if d46==1;
		replace notattending_oneweek=. if enrolled==1 & (d46==. | d46==-99);

	gen childabs_health_oneweek=0 if notattending_oneweek!=.;
		replace childabs_health_oneweek=1 if d47_11==1;
		replace childabs_health_oneweek=. if d46==1 & (d47_11==-99 | d47_11==.);
		
	gen childabs_weather_oneweek=0 if notattending_oneweek!=.;
		replace childabs_weather_oneweek=1 if d47_61==1;
		replace childabs_weather_oneweek=. if d46==1 & (d47_61==-99 | d47_61==.);

	gen teacher_absent_oneweek=0 if notattending_oneweek!=.;
		replace teacher_absent_oneweek=1 if d47_31==1;
		replace teacher_absent_oneweek=. if d46==1 & (d47_31==-99 | d47_31==.);

	gen childabs_other_oneweek=0 if notattending_oneweek!=.;
		foreach j in 2 4 5 7 {;
			replace childabs_other_oneweek=1 if d47_`j'1==1;
			replace childabs_other_oneweek=. if d46==1 & (d47_`j'1==-99 | d47_`j'1==.);
			};

	gen ndays_childabs_health_pastyear=0 if childabs_health_oneweek!=.;
		replace ndays_childabs_health_pastyear=d47_12 if d47_12>0 & d47_12!=.;
		replace ndays_childabs_health_pastyear=. if d47_11==1 & (d47_12==. | d47_12==-99);
		replace ndays_childabs_health_pastyear=. if ndays_childabs_health_pastyear==90;

	gen ndays_childabs_weather_pastyear=0 if childabs_weather_oneweek!=.;
		replace ndays_childabs_weather_pastyear=d47_62 if d47_62>0 & d47_62!=.;
		replace ndays_childabs_weather_pastyear=. if d47_61==1 & (d47_62==. | d47_62==-99);
		
	 	
	gen ndays_teacher_absent_pastyear=0 if teacher_absent_oneweek!=.;
		replace ndays_teacher_absent_pastyear=d47_32 if d47_32>0 & d47_32!=.;
		replace ndays_teacher_absent_pastyear=. if d47_31==1 & (d47_32==. | d47_32==-99);


	gen ndays_childabs_other_pastyear=0 if childabs_other_oneweek!=.;
		foreach j in 2 4 5 7 {;
		replace ndays_childabs_other_pastyear=ndays_childabs_other_pastyear+d47_`j'2 if d47_`j'2>0 & d47_`j'2!=.;
		};

		replace ndays_childabs_other_pastyear=. if (d47_21==1 & (d47_22==. | d47_22==-99)) 
										& (d47_41==1 & (d47_42==. | d47_42==-99)) 
										& (d47_51==1 & (d47_52==. | d47_52==-99)) 
										& (d47_71==1 & (d47_72==. | d47_72==-99)) ;

** we tag kids who go to prim school by foot only;
gen transport_foot_only=d20_1==1 if d20_1!=.;
forvalues i=2/8 {;
	replace transport_foot_only=0 if d20_`i'==1;
	};								
replace transport_foot_only=1 if d32_1==1; 
replace transport_foot_only=0 if d32_1==0;	
forvalues i=2/8 {;
	replace transport_foot_only=0 if d32_`i'==1;
	};
label var transport_foot_only "go/were going to primary school by foot only";


global newvar dropout08_enroll10 dropout08_enroll10_boys dropout08_enroll10_girls
dropout08_enroll10_sch_sec dropout08_enroll10_sat;

foreach var in $newvar {;
	gen `var'_0708=`var' if bs_dropout_2007_2008==1;
};
	

*****;
** Grade 1 2 and grade 3 4 at baseline;
gen bs_grade1_2=bs_grade==1 | bs_grade==2 if bs_grade!=. & bs_grade!=-99;
gen bs_grade3_4=bs_grade==3 | bs_grade==4 if bs_grade!=. & bs_grade!=-99;										
gen bs_grade5_6=bs_grade==5 | bs_grade==6 if bs_grade!=. & bs_grade!=-99;										

gen dropout_since2008_grade_12=dropout_since2008 if bs_grade1_2==1;
gen dropout_since2008_grade_34=dropout_since2008 if bs_grade3_4==1;
gen dropout_since2008_grade_56=dropout_since2008 if bs_grade5_6==1;
gen dropout_since2008_grade_5=dropout_since2008 if bs_grade==5;
gen dropout_since2008_grade_6=dropout_since2008 if bs_grade==6;


gen dropout_since2008_grade_1234=dropout_since2008 if bs_grade1_2==1 | bs_grade3_4==1;
gen dropout_since2008_grade_12345=dropout_since2008 if bs_grade1_2==1 | bs_grade3_4==1 | bs_grade==5;

** by gender and type of school;
gen dropout_since2008_grade_14_b=dropout_since2008_grade_1234 if bs_girl==0;
gen dropout_since2008_grade_14_g=dropout_since2008_grade_1234 if bs_girl==1;
gen dropout_since2008_grade_14_c=dropout_since2008_grade_1234 if satellite==0;
gen dropout_since2008_grade_14_sat=dropout_since2008_grade_1234 if satellite==1;


*****;
** In grade 5 at baseline and primary school completed;
gen completed_g5=(d24_cycle==4 | d24_cycle==5) if bs_grade==5 & d5==1 
		& (d24_cycle==3 | d24_cycle==4 | d24_cycle==5); 
replace completed_g5=1 if bs_grade==5 & d5==2 & (d12_cycle==4 |  d12_cycle==5);
replace completed_g5=1 if bs_grade==5 & d5==2 & d12_cycle==3  
		&  d12_niveau==6 & (d9_m==6 | d9_m==7);
replace completed_g5=0 if bs_grade==5 & d5==2 & d12_cycle==3 & d12_niveau<6;
replace completed_g5=0 if bs_grade==5 & d5==2 & d12_cycle==3 & d12_niveau==6 & d9_m!=6 & d9_m!=7;

** by gender and type of school;
gen completed_g5_b=completed_g5 if bs_girl==0;
gen completed_g5_g=completed_g5 if bs_girl==1;
gen completed_g5_c=completed_g5 if satellite==0;
gen completed_g5_sat=completed_g5 if satellite==1;


*****;
** grade 5 enrolled in any school;
gen enrol_any_g5=d5==1 if bs_grade==5 & hhmid!="";

** by gender and type of school;
gen enrol_any_g5_b=enrol_any_g5 if bs_girl==0;
gen enrol_any_g5_g=enrol_any_g5 if bs_girl==1;
gen enrol_any_g5_c=enrol_any_g5 if satellite==0;
gen enrol_any_g5_sat=enrol_any_g5 if satellite==1;


*****;
** grade 5 and still enrolled in primary school;
gen enrol_prim_g5=d5==1 & d24_cycle==3 if bs_grade==5 & hhmid!="";

** by gender and type of school;
gen enrol_prim_g5_b=enrol_prim_g5 if bs_girl==0;
gen enrol_prim_g5_g=enrol_prim_g5 if bs_girl==1;
gen enrol_prim_g5_c=enrol_prim_g5 if satellite==0;
gen enrol_prim_g5_sat=enrol_prim_g5 if satellite==1;

*****;
** Same for grade 6;
gen enrol_prim_g6=d5==1 & d24_cycle==3 if bs_grade==6 & hhmid!="";

** by gender and type of school;
gen enrol_prim_g6_b=enrol_prim_g6 if bs_girl==0;
gen enrol_prim_g6_g=enrol_prim_g6 if bs_girl==1;
gen enrol_prim_g6_c=enrol_prim_g6 if satellite==0;
gen enrol_prim_g6_sat=enrol_prim_g6 if satellite==1;


*****;
** grade 5 at baseline and droped out before primary school completion;
gen dropout_bef_prim_g5=d5==2 & d12_cycle==3 & d12_niveau<6 if bs_grade==5 & hhmid!="";
replace dropout_bef_prim_g5=1 if d5==2 & d12_cycle==3 & d12_niveau==6 & d9_m!=6 & d9_m!=7
	& bs_grade==5 & hhmid!="";
** by gender and type of school;
gen dropout_bef_prim_g5_b=dropout_bef_prim_g5 if bs_girl==0;
gen dropout_bef_prim_g5_g=dropout_bef_prim_g5 if bs_girl==1;
gen dropout_bef_prim_g5_c=dropout_bef_prim_g5 if satellite==0;
gen dropout_bef_prim_g5_sat=dropout_bef_prim_g5 if satellite==1;


*****;
** grade 5 and completed prim school and dropped out;
gen prim_com_drop_g5=0 if bs_grade==5 & hhmid!="";
replace prim_com_drop_g5=1 if bs_grade==5 & d5==2 & (d12_cycle==4 |  d12_cycle==5);
replace prim_com_drop_g5=1 if bs_grade==5 & d5==2 & d12_cycle==3  
		&  d12_niveau==6 & (d9_m==6 | d9_m==7);

** by gender and type of school;
gen prim_com_drop_g5_b=prim_com_drop_g5 if bs_girl==0;
gen prim_com_drop_g5_g=prim_com_drop_g5 if bs_girl==1;
gen prim_com_drop_g5_c=prim_com_drop_g5 if satellite==0;
gen prim_com_drop_g5_sat=prim_com_drop_g5 if satellite==1;
		
	
******;
** Enrolled in SHS among those in grade 5 or 6 at baseline;
gen enrol_SHS_g56=d24_cycle==4 | d24_cycle==5  if bs_grade5_6==1 & hhmid!="";

** by gender and type of school;
gen enrol_SHS_g56_b=enrol_SHS_g56 if bs_girl==0;
gen enrol_SHS_g56_g=enrol_SHS_g56 if bs_girl==1;
gen enrol_SHS_g56_c=enrol_SHS_g56 if satellite==0;
gen enrol_SHS_g56_sat=enrol_SHS_g56 if satellite==1;

** Enrolled in SHS among those in grade 5 at baseline;
gen enrol_SHS_g5=d24_cycle==4 | d24_cycle==5  if bs_grade==5 & hhmid!="";

** by gender and type of school;
gen enrol_SHS_g5_b=enrol_SHS_g5 if bs_girl==0;
gen enrol_SHS_g5_g=enrol_SHS_g5 if bs_girl==1;
gen enrol_SHS_g5_c=enrol_SHS_g5 if satellite==0;
gen enrol_SHS_g5_sat=enrol_SHS_g5 if satellite==1;


** Enrolled in SHS among those grade 6 at baseline;
gen enrol_SHS_g6=d24_cycle==4 | d24_cycle==5  if bs_grade==6 & hhmid!="";

** by gender and type of school;
gen enrol_SHS_g6_b=enrol_SHS_g6 if bs_girl==0;
gen enrol_SHS_g6_g=enrol_SHS_g6 if bs_girl==1;
gen enrol_SHS_g6_c=enrol_SHS_g6 if satellite==0;
gen enrol_SHS_g6_sat=enrol_SHS_g6 if satellite==1;


** enroll at endline if not in school at baseline and 6-15 at baseline;
gen not_enrol08_enrol10=enrolled if bs_enrolled==0;

		
******;
** control vars for baseline status;
gen bs_inschool08=bs_enrolled;
gen bs_neverenrolled08=bs_neverinschool;
foreach var in bs_inschool08 bs_neverenrolled08 {;
gen `var'_miss=`var'==.;
	qui sum `var';
replace `var'=r(mean) if `var'==.;
};	

		

***************************************;
* We keep all 6-15 kids surveyed at endline; 
	keep if age_baseline>=6 & age_baseline<=15;
***************************************;

	
************;
**** we add school level data;
sort schoolunitid;
save tp1,replace;
u "Output\school_level_data",clear;

global school_var "multiniveau num_sections v0_age v0_female 
 teacher_presence v0_presence prel_elec 
 prel_toilet prel_dist_road prel_dist_post prel_inacc_winter";
keep schoolunitid $school_var;
sort schoolunitid;
 save tp2,replace;
u tp1,clear;
merge schoolunitid using tp2;
ta _merge;
drop if _merge==2;
drop _merge;
foreach var in $school_var {;
gen `var'_miss=`var'==.;
qui sum `var';
replace `var'=r(mean) if `var'==.;
};
erase tp1.dta;	
erase tp2.dta;	


** we add weights;
sort hhid_endline;
merge hhid_endline using "Input\cct_hh_weights_an";
ta _merge;
drop if _merge==2;
assert _merge==3;
drop _merge;

** and treament variables;
gen pere=benef=="Father";
gen mere=benef=="Mother";
gen cond_pere=anycond*pere;
cap gen uncond_mere=uncond*mere;
cap gen uncond_pere=uncond*pere;
cap gen cond_mere=anycond*mere;
gen control=group==0;



*************;
*** cuting sample in two based on predicted proba of enrolment;
gen bs_monthly_consump_pc_d100=bs_monthly_consump_pc/100;
 
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
 foreach var in $dropout_list {;
gen `var'2=`var';
 gen `var'2_miss=`var'==.;
 qui sum `var'2;
 replace `var'2=r(mean) if `var'2_miss==1;
local reg_list "`reg_list'`var'2 `var'2_miss "; 
 };
	
** we predict enrolment based on the control group;
qui xi: reg enroll_attend_May2010 `reg_list' i.stratum [pw=weight_hh], 
	cluster(schoolid), if control==1;
predict enroll_predict;

foreach var in $dropout_list {;
drop `var'2 `var'2_miss;
	};

sum enroll_predict,detail;
gen low_proba_enroll=enroll_predict<r(p50);

** by category for each outcome;
foreach var in enroll_attend_May2010
	dropout_since2008_grade_1234
	dropout08_enroll10 neverenrolled {;
gen `var'_lp=`var' if low_proba_enroll==1;
gen `var'_hp=`var' if low_proba_enroll==0;
	};

	
	
**************************************************;
save "Output\workingtable6",replace;
**************************************************;
