#delimit;

cap clear matrix;  
clear;
set mem 400m;
set maxvar 17000;
set more off;


use "Output\temp_indivD_main.dta", clear;

		* we check merged kids are the same in baseline and endline;
			count if d3==bs_name & _merge==3;
			* differences are spelling problems;

		
	* FIRST, we check if not merged kids are in the same HH with a different ID;
			sort bs_idmember;
			gen idhh=substr(bs_idmember,1,7);

			gen tomerge=(_merge==2);
				sort idhh;
				egen sumtomerge=sum(tomerge), by(idhh);
				codebook idhh if sumtomerge>0;
	
			*edit bs_idmember idhh _merge d3 age_endline girl bs_name bs_girl bs_age bs_age_d4 bs_enrolled tomerge sumtomerge if sumtomerge>0;
			*when we look at the obs per HH we discover that not merged kids are not in the same HH with a different ID;

			drop tomerge sumtomerge idhh bs_child_column; 
		
			save "Output\temp_indivD.dta", replace;  

#delimit;
set more off;

	* SECOND, look for kids that we have only at Baseline Section D among all kids we ave in the HH at endline (we merge with endline at the HH level), 
			among the rest of hh members in the endline survey; 

			use "Input\cct_endline_an", clear;
				sort hhid;
				keep hhid hhid_endline a1_* a2_* a2_2_* a3_* a4_* a5_* a13_* d1_* d2_* d3_* d4_1_* d4_1_* d5_* d6_*;
				save "Output\end_temp2",replace;


			use "Output\temp_indivD.dta", clear;
				gen order=substr(bs_idmember,8,2);
				destring order,replace;


			sort hhid;
			merge hhid using "Output\end_temp2.dta";
				tab _merge;
				drop if _merge==2;
				drop _merge;

			gen end_name="";
			gen end_age=.;
			gen end_member=.;
			gen end_only=0;
				qui foreach i of numlist 1/32 {;
					replace end_name=a2_`i' if order==`i';
					replace end_age=a13_`i' if order==`i';
					replace end_member=a5_`i' if order==`i';
					replace end_only=a2_2_`i' if order==`i';
					};
					recode end_only (1=0) (2=1);

			gen samekid=(end_name==bs_name & end_name!="" & status=="only baseline");


			* we look at spelling differences and we find the additional following kids;

			foreach id in 

A00900803
A01500404
A01600205
A01600407
A02000303
A02000304
A02400305
A03800807
A03900404
A04900504
A05300103
A06000404
A06200603
A06200804
A06200805
A06200806
A06600804
A07500405
A07700704
A08400105
A08900303
A08900704
A09100104
A09200605
A09200808
A10200604
A10600606
A11000205
A11300304
A11300305
A11300306
A11500505
A11500506
A11800403
A11900305
A12000605
A13100705
A13300305
A14300405
A14400804
A14600206
A14600207
A15400104
A15700208
A17100205
A17100408
A17900105
A18600606
A19000607
A19300503
A19400803
A19900304
A20000304
A20300205
A20300207
A20900505
A21000507
A21000605
A21400403
A21800406
A22500905
A22501102
A22700403
A22900803
A24200203
A24800504
A24900105
A24900408
A25800409
A26000110
A26000605
A26100206
A26100703
A27200309
A27600205
A28100103
A28700207
A29600705
A29700405
A29900605
A29900704
A30900705
A31300207
A32000604
A32100809
A32100810
A32600505
A32600806
A32600807
A32900705
A33700605
A33900505
A33900606
A34500405
A35200306
A35300804
A36200304
A36300603
A37000103
A37400704
A37600710
A37800105
A37800506
A37800803
A38000203
A38000406
A38300604
A38700207
A39100204
A39400206
A39900803
A40500603
A40900101
A41200603
A41400305
A41500605
A41800203
A41800401
A41800604
A42000103
A42700205
A42700604
A45300403
A45600603
A45700504
A46100507
A46600603
A46600604
A47000103
A47300106
A47300403
A47500806
A47700303
A47700403
A47700703
A47700705
A47800607
A48100404
A48200304
A48500404
A48900104
A49000507
A49100804
A49300404
A49500204
A49600106
A49600604
A49700604
A50500606
A52000403
A53800203
A53900808
A55100803
A55200503
A55700304
A56300803
A56600303
A56700803
A56900503
A58100504
A58700505
A59200105
A59300703
A59500304
A59800507
A60700305
A61100504
A62600203
A62600204
A63100607
A63100709
A63300704
A63300705
A63400504
A63500606
A00600605
A08900704
A11900404
			{;

			replace samekid=1 if bs_idmember=="`id'";
			}; 



	replace status="onlybase-not 6-17 at endline" if end_age<6 
		| (end_age>17 & end_age!=.) & samekid==1;
	replace status="onlybase-not HH member at endline" if 
		(inrange(end_age,6,17) | end_age==.) & inrange(end_member,4,8) & samekid==1;
			tab status;

			

	* THIRD, we merge with the baseline survey (HH level) to look for kids that we have only in Endline Section D, among the rest of hh members in the baseline survey; 
			sort hhid;
			merge hhid using "Output\temp_base_forsectionD.dta";
				tab _merge;
				drop if _merge==2;

			replace status="onlyend-new HH" if _merge==1;

			gen bs_member=.;
			qui foreach i of numlist 1/23 {;
					replace bs_name=bs_a2_`i' if order==`i' & status=="only endline";
					replace bs_age=bs_a13_`i' if order==`i' & status=="only endline";
					replace bs_member=bs_a5_`i' if order==`i' & status=="only endline";
					};


			replace samekid=1 if (end_name==bs_name & end_name!=""
							& status=="only endline");


foreach id in 

A00100307
A00100607
A00200608
A00300704
A00300805
A00400604
A00400608
A00500205
A00600407
A00700404
A00700606
A00800105
A00900804
A01000803
A01200104
A01200107
A01200606
A01700806
A01900409
A02000205
A02000307
A02000308
A02100606
A02100705
A02200404
A02500405
A02500605
A02700506
A02900105
A03200505
A03300104
A03300106
A03300107
A03300705
A03500204
A03600606
A04000505
A04200504
A04200605
A04300307
A04400105
A04700805
A05300106
A06000203
A06400505
A06400604
A06400705
A06700205
A06900407
A07000704
A07000806
A07100404
A07300307
A07400805
A07500106
A07800506
A07800607
A07800805
A07900606
A08000407
A08200705
A08300107
A08300306
A08400107
A08400505
A08400605
A08500105
A08500204
A08600216
A08700305
A09100105
A09100704
A09200106
A09200307
A09400306
A09500205
A09700209
A09700604
A09900306
A10100804
A10200206
A10300306
A10400403
A10500405
A10800805
A10900106
A11000107
A11200404
A11300204
A11300608
A11600106
A11600704
A11900705
A12000206
A12000704
A12000813
A12200109
A12300206
A12300305
A12400805
A12500709
A12800105
A13300308
A13300508
A13500705
A13600208
A13700104
A14100407
A14300503
A14800303
A15000708
A15400504
A15400605
A15500808
A15600206
A15600404
A15600407
A15600805
A16100306
A16200404
A16300104
A16500311
A16600105
A16600304
A17000206
A17300105
A17300806
A17600406
A17600409
A17600806
A17800406
A18200109
A18300406
A18500307
A18600609
A18700104
A18800807
A19200106
A19300506
A19500805
A19600307
A19900307
A19900407
A20000108
A20200504
A20300105
A20500205
A20600109
A20600304
A20600809
A21100404
A21200305
A21200406
A21200705
A21300510
A21500206
A21600705
A21900306
A22100304
A22300307
A22600405
A22900306
A22900607
A23200303
A23600207
A23700710
A23800207
A23900505
A24100305
A24300607
A24300706
A24500804
A24600305
A24600606
A24800407
A24800603
A24900107
A24900307
A24900606
A25100206
A25100606
A25200807
A25400206
A25400805
A25600405
A25700307
A25900405
A25900507
A26100707
A26400806
A27000206
A27400808
A27700507
A28100306
A28100706
A28500206
A28500409
A28500606
A28500608
A28800407
A29200504
A29800205
A29800704
A30100609
A30200706
A30300305
A30400106
A30400206
A30400706
A30500506
A30800108
A31100107
A31300209
A31300318
A31300608
A31400805
A31700604
A32000507
A32100508
A32400404
A32600606
A32800508
A33000607
A33300508
A33300805
A34100404
A34300205
A34300706
A34700807
A34800105
A34900304
A34900609
A35000304
A35000806
A35400406
A35500505
A35600409
A35800408
A36000708
A36200405
A36300607
A36400405
A36500409
A36500508
A36600804
A36800405
A36800706
A37000609
A37100405
A37700507
A37900108
A38500205
A38600208
A38600308
A38900706
A39200106
A39300304
A39600604
A40000105
A40000506
A40100306
A40200307
A40400108
A40600106
A40900808
A41000708
A41200606
A41300505
A41800605
A42000705
A42300111
A42600204
A42600506
A43000307
A43000405
A43000707
A43000805
A43400104
A43400205
A43400706
A43600303
A44200505
A44200705
A44300206
A44500305
A44900709
A45000208
A45500706
A45600406
A46200507
A46600308
A46700207
A46700805
A46800605
A46800808
A46900805
A47200509
A47200808
A47500504
A47500706
A47600106
A48500105
A48600605
A48700405
A49100306
A49100406
A49600605
A49700808
A50000804
A50100304
A50300807
A50600204
A50600305
A50600605
A50600704
A50800206
A51000207
A51400107
A51400305
A51400307
A51500504
A51700609
A51800205
A52100104
A52100206
A52300808
A52500305
A52600205
A52600708
A52700304
A52800207
A52900405
A53000306
A53400407
A53600104
A53700405
A53700808
A53900704
A54000808
A54100603
A54400307
A54400506
A54500105
A54700705
A55000507
A55600206
A55600207
A55700606
A56300509
A56500106
A56600503
A56600606
A56900405
A56900605
A57100507
A57100805
A57200503
A57200506
A57200708
A57500705
A57800806
A58600805
A58700306
A58700307
A58800108
A58900204
A59000608
A59100105
A59500308
A59500706
A60000205
A60400108
A60500610
A60700206
A60800504
A60800609
A60800807
A60900705
A61300504
A61300609
A61400506
A61900705
A61900706
A62000106
A62100105
A62100705
A62400108
A62500205
A62600708
A62700609
A63000407
A63200105
A63200408
A63400207
A63400507
A63800405
A63800809
A15100706
A22200205
A29100411
A30800705
A63900305
A00300509

			{;

			replace samekid=1 if bs_idmember=="`id'";
			}; 
			
			replace samekid=0 if bs_idmember=="A53600505";
			replace samekid=0 if bs_idmember=="A60800304";
			

	replace status="onlyend-not 6-15 at baseline" if 
					(bs_age<6 | (bs_age>15 & bs_age!=.)) & samekid==1 
					& status=="only endline";
	replace status="onlyend-not HH member at baseline" if 
				(inrange(bs_age,6,15) | bs_age==.) & inrange(bs_member,4,8) 
				& samekid==1 & status=="only endline";
	replace status="onlyend-missing section D at baseline" if inrange(bs_age,6,15) 
				& inrange(bs_member,1,3) & samekid==1 & status=="only endline";
	replace status="onlyend-new kid" if status=="only endline" & end_only==1;
			tab status;
			tab status end_only, miss;
	


	** FOURTH, checking by hand we identify the following kid status;

foreach id in 
A00900803
A01600407
A05300103
A06200804
A06200805
A06200806
A07500405
A14600206
A14600207
A17100205
A18600606
A21000605
A24200203
A25800409
A26000110
A27200309
A28100103
A29700405
A32000604
A33900505
A37800105
A38700207
A38800508
A45300403
A45700504
A46100507
A47300106
A48100404
A53700605
A56300803
A58700505
A59300703 {;
	replace status="onlybase-missing section D at endline" if bs_idmember=="`id'";
	};

foreach id in A13100705 A15400104 {;
	replace status="onlybase-not 6-17 at endline" if bs_idmember=="`id'";
	};

foreach id in 
A32100404 
A32100405 
A32100406
A61800808
A61800809 
A00800205 {;
	replace status="onlybase-not HH member at endline" if bs_idmember=="`id'";
	};

foreach id in 
A00400505
A03800807
A11300304
A11300305
A11300306
A11500505
A11500506
A14300405
A15100703
A17100408
A19300503
A20000304
A20300205
A20300207
A21000507
A21400403
A22700403
A29500303
A32100809
A32100810
A35200306
A37600710
A41800604
A46600603
A46600604
A47000103
A47700703
A47700705
A50100606
A51200407
A62600203
A62600204
A63300704
A63300705
A00800406
{;
	replace status="onlybase-not HH member at endline?" if bs_idmember=="`id'";
	};


foreach id in 
A16400305
A28200105
{;
	replace status="onlybase-unknown reason" if bs_idmember=="`id'";
	};


foreach id in 
A02300704
A02300705
A02300706
A10400505
A15600105
A17100409
A18200712
A26100202
A27700105
A28000105
A28000804
A43500607
A59800405
A61100504
A61800412
A62600405
A19800508
{;
	replace status="onlyend-missing section D at baseline" if bs_idmember=="`id'";
	};


foreach id in 
A01600311
A02500107
A02500108
A02500112
A02500113
A02500119
A10900110
A10900111
A16500408
A18500822
A25500816
A28100105
A28100106
A28100110
A29400108
A59100508
A59600705
A61300408
A63000107
A63000108
A04400710
A28900105
A28900106
A28900306
A28900307
{;
	replace status="onlyend-new kid" if bs_idmember=="`id'";
	};

foreach id in 
A14800405
A25500810
A26100708
A39100607
A44100614
A46500104
A52000806
A52600405
A53600505
A53800405
A57200708
A58100404
A63300811
A02100806
A44100606
A46500505
A61800405
{;
	replace status="onlyend-not 6-15 at baseline" if bs_idmember=="`id'";
	};


foreach id in 
A29800803
A29800806
A01300805
{;
	replace status="onlyend-not HH member at baseline?" if bs_idmember=="`id'";
	};

foreach id in 
A08900106
A08900705
A16400306
A32600803
A41800603
A60800304
{;
	replace status="onlyend-unknown reason" if bs_idmember=="`id'";
	};



	** FIFTH, final check of not merged that remains not explained;
		gen notmerged=(status=="only endline" | status=="only baseline");
			count if notmerged==1;

		sort bs_idmember;
			drop notmerged;

	drop order a1_1-bs_member;

*** We save kid status to be merged with main Section D individual database; 
rename status status_desc;
	keep bs_idmember status_desc;
	sort bs_idmember;


save "Output\kid_statusD.dta", replace;

erase "Output\temp_indivD.dta";
erase "Output\end_temp2.dta;
