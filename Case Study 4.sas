data case_study4;
infile '/folders/myfolders/cohortscore1.csv' dlm=',' firstobs=2;
input opeid $ state $ type $ num denom drate region $;
run;

*Clean up Data;
data case4;
set case_study4;
where drate ne . ;
run;

data case4_1;
set case4;
if type = '5' then type = '4';
if type = '6' then type = '4';
if type = '7' then type = '4';
run;

proc sort data = case4_1;
by type;
run;

*Sample;
*Birthday 1 = 3-22, Birthday 2 = 3-17. Seed = 22*17 = 374;
proc surveyselect data = case4_1 method = srs n = 50 seed = 374
out= sample;
strata type;
run;

*Data Analysis and Exploration;
proc sgplot data=sample;
	vline type /response=drate stat=mean markers datalabel;
run;

proc sgplot data=sample;
vbox drate/ category=type;
run;

*ANOVA;
proc anova data=sample;
class type;
model drate=type;
run;

*Post-HOC Analysis - Tukey Test;
proc anova data=sample;
class type;
model drate=type;
means type/ tukey lines;
run;

*ANOVA Assumptions;
proc sgpanel data=sample;
panelby type;
histogram drate;
density drate /type=normal;
run;

proc sgplot data=sample;
vbox drate/ category=type;
run;

proc anova data=sample;
class type;
model drate=type;
means type/ hovtest=levene(type=abs);
run;

*===========================================================;
data case4_2;
 set sample;
 sqrtdrate=drate**0.5;
 lndrate=log(drate);
run;

proc sgpanel data=case4_2;
panelby type;
histogram sqrtdrate;
density sqrtdrate /type=normal;
run;

proc sgplot data=case4_2;
vbox sqrtdrate/ category=type;
run;


proc anova data=case4_2;
class type;
model sqrtdrate=type;
means type/ hovtest=bartlett;
run;
*ln transformation;
proc sgpanel data=case4_2;
panelby type;
histogram lndrate;
density lndrate /type=normal;
run;

proc sgplot data=case4_2;
vbox lndrate/ category=type;
run;

proc anova data=case4_2;
class type;
model lndrate=type;
means type/ hovtest=bartlett;
run;

*ANOVA - ln transformation;
proc anova data=case4_2;
class type;
model lndrate=type;
run;

*Post-HOC Analysis - Tukey Test;
proc anova data=case4_2;
class type;
model lndrate=type;
means type/ tukey lines;
run;

* Confidence Interval;
proc anova data=sample;
class type;
model drate=type;
means type/ tukey cldiff ;
run;