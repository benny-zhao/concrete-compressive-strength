/* The following options are described in HomeworkOptionsAnnotated.sas in compass.
Please refer to that file to determine which settings you wish to use or modify
for your report.
*/
ods html close;
options nodate nonumber leftmargin=1in rightmargin=1in;
title;
ods escapechar="~";
ods graphics on / width=4in height=3in;
ods rtf file="C:\Users\bzhao22\Downloads\STAT 448 Final Project\Benny Zhao Final Project.rtf"
        nogtitle startpage=no;
ods noproctitle;

/* Importing and Processing Data */

/* 

   The data is based on 

	Concrete Compressive Strength Data Set, copyright I-Cheng Yeh, https://archive.ics.uci.edu/ml/datasets/Concrete+Compressive+Strength, 
		originally from I-Cheng Yeh, "Modeling of strength of high performance concrete using artificial neural networks," Cement and Concrete Research, 
		Vol. 28, No. 12, pp. 1797-1808 (1998).

	published on

  	Dua, D. and Karra Taniskidou, E. (2017). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
		School of Information and Computer Science.

   The data in concreteratios.csv divides the concrete components by the water content to specify component content as a ratio to water content. 
   The variables are

	Cement/Water ratio
 	Blast Furnace Slag/Water ratio
    Fly Ash/Water ratio
    Superplasticizer/Water ratio
	Coarse Aggregate/Water ratio
	Fine Aggregate/Water ratio
	Age (days)
	Concrete compressive strength (MPa, megapascals)

*/

data concreterats;
	infile "C:\Users\bzhao22\Downloads\STAT 448 Final Project\concreteratios.csv" dlm=",";
	input cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
	agegroup= 6;
	if age<7 then agegroup=1;
	if 7<=age<28 then agegroup=2;
	if 28<=age<56 then agegroup=3;
	if 56<=age<90 then agegroup=4;
	if 90<=age<180 then agegroup=5;
run;

*Introduction;
ods text='Introduction';

*Analysis 1:;
ods text='Analysis 1: Exploratory analysis';


proc univariate data=concreterats;
	var compressivestrength age;
	hist;
	ods select BasicMeasures Histogram;
run;

proc sort data=concreterats;
	by age;
run;



proc sgplot data=concreterats;
	scatter x=age y=compressivestrength / group=agegroup;
run;


*compressive strength statistics across age groups;
proc means n mean median max min range data=concreterats;
	var compressivestrength;
	by agegroup;
run;

proc sgscatter data=concreterats;
	matrix cementwater slagwater flyashwater superplasticizerwater coarsewater finewater compressivestrength age;
run;

proc corr data=concreterats  spearman;
	var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater compressivestrength age;
	ods select SpearmanCorr;
run;

*Analysis 2:;
ods text='Analysis 2:';

proc means n mean stddev min max range data=concreterats;
	var cementwater--finewater age;
run;

proc cluster data=concreterats standard method=average ccc pseudo print=15 outtree=stdconcretecluster plots=all noprint;
	var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
	copy compressivestrength;
run;

proc tree out=stdconcretetree data=stdconcretecluster nclusters=6 noprint;
	copy cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
run;

proc sort data=stdconcretetree;
	by cluster;
run;

proc means data=stdconcretetree;
	var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
	by cluster;
run;

proc anova data=stdconcretetree;
	class cluster;
	model compressivestrength = cluster;
	means cluster/ hovtest;
	ods select HOVFTest ;
run;

proc anova data=stdconcretetree;
	class cluster;
	model compressivestrength = cluster;
	means cluster/ welch;
	ods select OverallAnova FitStatistics Welch;
run;



*Analysis 3:;
ods text='Analysis 3:';

*Take a subset of concreterats containing only samples w/ age >= 90 days;

data cr90;
	set work.concreterats;
	where age>=90;
run;


proc reg data=cr90;
	model compressivestrength = cementwater--finewater age / selection=stepwise sle=.05 sls=.05;
	ods select SelectionSummary;
run;

proc reg data=cr90;
	model compressivestrength = cementwater slagwater flyashwater finewater/ vif;
	output out=regdiagnostics cookd=cd;
	ods select FitStatistics ANOVA ParameterEstimates DiagnosticsPanel;
run;


*Analysis 4:;
ods text='Analysis 4:';

data concreterats;
	set work.concreterats;
	if compressivestrength>=50 then cs50='Yes';
		else cs50='No';
run;

proc logistic data=concreterats desc PLOTS=INFLUENCE(UNPACK);
	where age>=90 and age<=100;
	model cs50 = cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age / selection=stepwise sle=.05 sls=.05 influence;
	output out=cs50_log_diagnostics cbar=Cbar;
	ods select ModelBuildingSummary; *CBarPlot;
run;

*Removing unduly influential points;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar<0.63;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar2;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar2<0.8;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar3;
run;

proc logistic data=cs50_log_diagnostics desc  PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar3<1;
	model cs50 = superplasticizerwater cementwater slagwater / selection=stepwise sle=.05 sls=.05 influence;
	output out=cs50_log_diagnostics cbar=Cbar4;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar4<1;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar5;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK);
	where age>=90 and age<=100 and Cbar5<1;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar6;
	ods select GlobalTests ParameterEstimates;
run;


*Analysis 5:;
ods text='Analysis 5:';

proc stepdisc data=concreterats sle=.05 sls=.05;
	class agegroup;
	var cementwater--finewater compressivestrength;
	ods select Summary;
run;

proc discrim data=concreterats method=normal pool=test manova crossvalidate crosslisterr;
   class agegroup;
   var compressivestrength cementwater slagwater flyashwater finewater superplasticizerwater coarsewater;
   priors proportional;
   ods select ChiSq MultStat ClassifiedCrossVal ErrorCrossVal;
run;


*Conclusion;
ods text='Conclusion';

*Appendix;
ods text='Appendix';

*Appendix A: Cluster diagnostics;
ods text='Appendix A: Cluster diagnostics';

proc cluster data=concreterats standard method=average ccc pseudo print=15 outtree=stdconcretecluster plots=all;
	var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
	copy compressivestrength;
	ods select CccPsfAndPsTSqPlot;
run;

proc tree out=stdconcretetree data=stdconcretecluster nclusters=6;
	copy cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
run;

*Appendix B: Analysis of variance using 9 clusters;
ods text='Appendix B: Analysis of variance using 9 clusters';

proc tree out=stdconcretetree9 data=stdconcretecluster nclusters=9 noprint;
	copy cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
run;

proc sort data=stdconcretetree9;
	by cluster;
run;

proc anova data=stdconcretetree9;
	class cluster;
	model compressivestrength = cluster;
	means cluster/ hovtest;
	ods select HOVFTest;
run;

proc anova data=stdconcretetree9;
	class cluster;
	model compressivestrength = cluster;
	means cluster/ welch;
	ods select OverallAnova FitStatistics Welch;
run;

*Appendix C: Multiple linear regression diagnostics;
ods text='Appendix C: Multiple linear regression diagnostics';
proc reg data=cr90;
	model compressivestrength = cementwater slagwater flyashwater finewater/ vif;
	output out=regdiagnostics cookd=cd;
	ods select ParameterEstimates DiagnosticsPanel;
run;

*Appendix D: Removal of unduly influential points;
ods text='Appendix D: Removal of unduly influential points';

proc logistic data=concreterats desc PLOTS=INFLUENCE(UNPACK);
	where age>=90 and age<=100;
	model cs50 = cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age / selection=stepwise sle=.05 sls=.05 influence;
	output out=cs50_log_diagnostics cbar=Cbar;
	ods select CBarPlot;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar<0.63;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar2;
	ods select GlobalTests ParameterEstimates CBarPlot;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar2<0.8;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar3;
	ods select GlobalTests ParameterEstimates CBarPlot;
run;

proc logistic data=cs50_log_diagnostics desc  PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar3<1;
	model cs50 = superplasticizerwater cementwater slagwater / selection=stepwise sle=.05 sls=.05 influence;
	output out=cs50_log_diagnostics cbar=Cbar4;
	ods select GlobalTests ParameterEstimates CBarPlot;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK) noprint;
	where age>=90 and age<=100 and Cbar4<1;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar5;
	ods select GlobalTests ParameterEstimates;
run;

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK);
	where age>=90 and age<=100 and Cbar5<1;
	model cs50 = superplasticizerwater cementwater slagwater;
	output out=cs50_log_diagnostics cbar=Cbar6;
	ods select CBarPlot;
run;

*Appendix E: Logistic regression residual diagnostics plot;
ods text='Appendix E: Logistic regression residual diagnostics plot';

proc logistic data=cs50_log_diagnostics desc PLOTS=INFLUENCE(UNPACK);
	where age>=90 and age<=100 and Cbar5<1;
	model cs50 = superplasticizerwater cementwater slagwater / lackfit influence;
	output out=cs50_log_resid_diagnostics PREDICTED=Predicted CBAR=Cbar STDRESCHI=StdResChi STDRESDEV=StdResDev RESLIK=ResLik;
	ods select LackFitChiSq FitStatistics;
run;


proc sgscatter data=cs50_log_resid_diagnostics;
	compare x=Predicted y=(StdResChi StdResChi ResLik) / group=cs50;
run;

*Appendix F: Discriminant analsysis using training & testing partition;
ods text='Appendix F: Discriminant analsysis using training & testing partition';

data crpartition;
	set work.concreterats;
	partition = ranuni(448);
run;

data crtrain crtest;
	set work.crpartition;
	if partition<=0.8 then output crtrain;
    else output crtest;
run;

proc stepdisc data=crtrain sle=.05 sls=.05;
	class agegroup;
	var cementwater--finewater compressivestrength;
	ods select Summary;
run;

proc discrim data=crtrain outstat=crstat method=normal pool=test manova crossvalidate crosslisterr;
  	class agegroup;
  	var compressivestrength cementwater slagwater flyashwater finewater superplasticizerwater coarsewater;
  	priors proportional;
  	ods select ChiSq MultStat ClassifiedCrossVal ErrorCrossVal;
run;

proc discrim data=crstat testdata=crtest testout=tout testlisterr;
	class agegroup;
	var compressivestrength cementwater slagwater flyashwater finewater superplasticizerwater coarsewater;
  	ods select ClassifiedTestClass ErrorTestClass;
run;

ods rtf close;