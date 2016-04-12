#delimit;
cap clear matrix;
clear;
set mem 500m;
set more off;
clear mata;
set maxvar 20000;

capture log close;
log using session.log, text replace;
*********************************************************************;
***** TURNING A SHOVE INTO A NUDGE: A LABELED CASH TRANSFER FOR EDUCATION;
***** MASTER DOFILE;
*********************************************************************;
** Master Do file that generates all the tables for the article;
** Coauthors: Najy Benhassine, Florencia Devoto;
**                          Esther Duflo, Pascaline Dupas, Victor Pouliquen;

* This version: April 16 2013;
* Victor;


********************************;
** INSTRUCTIONS TO GENERATE THE TABLES;
********************************;
/*;
1- You need a Master folder with the following sub-folders;
  -"Input": where all the databases are;
  -"Output": an empty folder where all the temporary databases will be created;
  -"Tables_paper": where all the tables will be created;
2- Specify bellow the path to these Master folder.

3- Run this dofile;

4-In the "Tables_paper" folder, update the master Excel file
	with all the tables with the created tables (.out format).  
*/;



**************;
* Path to the master folder;

	*update this with your own path;
*	cd "C:/Users/pdupas/Documents/Pascaline's Work/Research projects/MAROC CCT/data/Final anonymous data/";
*  cd ".."
cd "/bbkinghome/juesato/benhassine_et_al/data_online/";

dir;
pwd;

***********************************;
* We get databases ready for analysis;

do "DoFiles/lct_foranalysis";


*********************************;
* Analysis;

******;
** variables creation;

** HH baseline charac and attrition;
do "DoFiles/lct_var_creation_hhs_baseline";
*generate the following temporary databases;
* workingtable_hh_baseline;

** schooling variables;
do "DoFiles/lct_var_creation_schooling";
*generate the following temporary databases;
* workingtable1 ;
* workingtable2 ;
* workingtable3 ;
* workingtable4 ;
* workingtable5 ;
* workingtable6 ;
* workingtableA2 ;
* school_level_data ;

** Knowledge variables;
do "DoFiles/lct_var_creation_knowledge";
*generate the following temporary databases;
* working_knowledge1 ;
* working_knowledge2 ;
* working_knowledge3 ;
* working_knowledge4 ;

** Transfers databases;
do "DoFiles/lct_var_creation_transfers";
*generate the following temporary databases;
* workingtable_transfer_data ;
* workingtable_transfer_data_all ;

** ASER databases;
do "DoFiles/lct_var_creation_ASER";
*generate the following temporary databases;
* workingtable_aser ;

** Perception and Educ returns databases;
do "DoFiles/lct_var_creation_perception_returns";
*generate the following temporary databases;
* workingtable_returns ;

** Child's time use (sect C);
do "DoFiles/lct_var_creation_time_use";
*generate the following temporary databases;
* workingtable8 ;

** Educational expenses;
do "DoFiles/lct_var_creation_sectE_educ_exp";
*generate the following temporary databases;
* workingtable_sectE ;

** return to educ (sect A and G);
do "DoFiles/lct_var_creation_returns_educ";
*generate the following temporary database;
* workingtable_educ_return ;

** child work; 
* Sect G;
do "DoFiles/lct_sectG_child_work";
*generate the following temporary database;
* workingtable_child_work ;


******;
** Table construction;

do "DoFiles/lct_tables_creation";

/*;
******;
** We erase temporary databases;
#delimit;
global database_name workingtable_hh_baseline
working_knowledge1 working_knowledge2 working_knowledge3
working_knowledge4 working_knowledge_append
workingtable1 workingtable2 workingtable3 workingtable4
workingtable5 workingtable6 workingtable_transfer_data
workingtable_aser workingtable_returns workingtable8
workingtable_sectE ASERdata baseline_cov baseline_randomization
bs_indiv_sectionD  classinfo end_temp2 foranalysis
indiv_sectionA indiv_sectionC indiv_sectionD indiv_sectionG
kid_statusD list_unit_never_surveyed school_level_data
tayssir_admin_data tayssir_admin_data_allpilot
workingtable_educ_return workingtableA2;

foreach x in $database_name {;
	erase "Output/`x'.dta";
	};


