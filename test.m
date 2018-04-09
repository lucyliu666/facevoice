%clear all window variables and figures
%clc;clear all;close all

%Initialize random number generator
rand('state',GetSecs);

save(Expe.OutFileName,'Expe','Subject','Results');%,'Result');
%clear unecessary variables to avoid carryover effect on next expe
 clear AOI AnimIndex AnimList AnimPath Bool Border CurrTime Expe FileName FilePath ...
     Im Im1 ImWidth ImageStore Lim ListIm NameMessage NameMessageStart NearCent NearEdge ...
     Results Tdur TrialTime VBEdge VTEdge ans escapeKey evt eye_used i islook moveKey ...
     sim status surface tex1 tex2 trialKey winptr xy1 xy2...
     FPass State ifi kC keyCode keyIsDown seconds trial vbl x y;
%Subject=rmfield(Subject,'Expe')


