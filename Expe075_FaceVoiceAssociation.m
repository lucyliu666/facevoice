%clear all window variables and figures
%clc;clear all;close all

%Initialize random number generator
rand('state',GetSecs);

%% define your experiment parameter
Expe=[];%To avoid the structure overwritte warning
Expe.Code=75;%The experiment number
Expe.Name='FaceVoiceAssociation';
Expe.Description={'a french face is paired with French or Chinese'};
Expe.StimFolderName='Expe075_FaceVoiceAssociation\Stimuli\'
Expe.FolderName='Expe075_FaceVoiceAssociation'; 
Expe.MainPath=cd;%
Expe.DispSize=get(0,'screensize');
Expe.colscreen=[0 0 0];
Expe.ElSampRate=250;%the eyelink desired samprate (250 or 500)
Expe.FixationPoint=[Expe.DispSize(3)/2 80];
Expe.Date=datestr(now);
Expe.ImPath='E:\Phd\FaceVoiceAss\Expe075_FaceVoiceAssociation\Stimuli\Images\';
Expe.SdPath='E:\Phd\FaceVoiceAss\Expe075_FaceVoiceAssociation\Stimuli\Sounds\';
Expe.NorSdPath='E:\Phd\FaceVoiceAss\Expe075_FaceVoiceAssociation\Normalizedsound\';
Expe.NumPres=6;%number of presentation
Expe.PresDur=10;%duration of stimulus either for presentation or for looking time
Expe.wRect = get(0,'screensize');



%% GetImageList depending on condition
Expe.Con=input('Choose the experiment condition (C/A): ','s');%C for caucasian faces and A for asian faces
Expe.Con=upper(Expe.Con);

if Expe.Con=='C'
    ListIm=dir(strcat(Expe.ImPath,'C*.jpg'));
else
    ListIm=dir(strcat(Expe.ImPath,'A*.jpg'));
end
ListIm={ListIm.name}';

%% GetSoundList depending on speaker
Expe.Speaknum=input('Choose the speaker(1 2 3 4): ','s'); 

if Expe.Speaknum=='1'
    ListSd=dir(strcat(Expe.SdPath,'01*.wav'));
elseif Expe.Speaknum=='2'
    ListSd=dir(strcat(Expe.SdPath,'02*.wav'));
elseif Expe.Speaknum=='3'
    ListSd=dir(strcat(Expe.SdPath,'03*.wav'));    
else 
    ListSd=dir(strcat(Expe.SdPath,'04*.wav')); 
end
ListSd={ListSd.name}';

%% load the image
Stim=[];% what does it mean
Expe.ImOrder=randperm(length(ListIm)); % randomize the order of the images presented
for i = 1 : length(ListIm)
    Stim(i).Image=imread(strcat(Expe.ImPath,char(ListIm{Expe.ImOrder(i)})));
end
% imshow(Stim(i).Image);
%define its positioning (centered)
% Expe.AOI=[266 57 758 710];
%define the corresponding AOI on a mask
% AOI=zeros(Expe.wRect(4),Expe.wRect(3));
% AOI(Expe.AOI(1,2):Expe.AOI(1,4),Expe.AOI(1,1):Expe.AOI(1,3))=1;

%% load the sound and normalize
Expe.SdOrder=randperm(length(ListSd)); % randomize the order of the audio played
for j = 1 : length(ListSd)
    [Y,FS]=audioread(strcat(Expe.SdPath,char(ListSd{Expe.SdOrder(j)}))); % what does Y mean exactly?
    Ym=max(max(max(Y)),max(abs(min(Y))));% find the maximum value of Y
    X=Y/Ym; % normalized the sample data (volume)
    Stim(j).Sound= X;
    Stim(j).Freq= FS;
    audiowrite(strcat(Expe.NorSdPath,char(ListSd{Expe.SdOrder(j)})),X,FS); % convert variables to WAV files and save in a new folder
    Stim(j).playerobj=audioplayer(X,FS)
end


% gong = audioplayer(Stim(i).Sound,Stim(i).Freq);
play(Stim(j).playerobj);

% draw the audio file
timeArray = (0:size(X,1)-1)/FS;
plot(timeArray, X)

return
%sound(Stim(i).Sound,Stim(i).Freq)

commandwindow
pause(1)
% for n = 1:100000
%     fprintf('%d\n',n)
% end
% 
% return
%define its positioning (centered)
%Expe.AOI=[266 57 758 710];
%define the corresponding AOI on a mask
%AOI=zeros(Expe.wRect(4),Expe.wRect(3));
%AOI(Expe.AOI(1,2):Expe.AOI(1,4),Expe.AOI(1,1):Expe.AOI(1,3))=1;


%%I use a number of animation to display movie target during fixation
AnimPath='Animations';%The name of the folder where are situated the animations
%Must be in the mainpath (mainpath\Animations;
%HERE WE MUST GIVE THE NAME OF NON SOUND TARGET
AnimList={'Anim64_1.avi' 'Anim64_2.avi' 'Anim64_3.avi' 'Anim64_4.avi' 'Anim64_5.avi' 'Anim64_6.avi' 'Anim64_7.avi'...
    'Anim64_8.avi' 'Anim64_9.avi' 'Anim64_10.avi' 'Anim64_11.avi' 'Anim64_12.avi'};

%% Enable unified mode of KbName:
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
trialKey = KbName('t');
moveKey=KbName('SPACE');

%% Step 2: define your subject and its condition
%Give subject info, check for existing subject, give group and condition
if ~exist('Subject','var');Subject=[];
elseif isfield(Subject,'Expe')
    Subject=rmfield(Subject,'Expe')
    Subject.Expe=[];
end%
%an empty var to the function below
[Expe,Subject] = RecordSubject(Expe,Subject)

%% Step 3: Open a Psychtoolbox window and launch the calibration procedure if needed
if ~exist('el','var');el=[];end%if no el structure yet pass an empty var to the function below
[winptr Expe Subject el]=CalEye(Expe,Subject,el);

Expe.FrameRate=screen('FrameRate',winptr);

%define starting state
State='AttGetter';
trial=1;

%launch ET
if ~isempty(el)
    Eyelink('StartRecording');
    WaitSecs(0.1);
    eye_used = Eyelink('EyeAvailable');
    if eye_used == el.BINOCULAR; % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end
end

FPass=0;
commandwindow
hidecursor

CurrTime=GetSecs;
Results=zeros(Expe.NumPres,3);

ifi=1/Expe.FrameRate;
vbl  = Screen('Flip', winptr);

while 1

    switch(State)

        case 'AttGetter'
            %show a fixation target on center
            AnimIndex=floor(rand(1)*size(AnimList,2)+1);
            % Place a message in the eyelink result file to remember what we are showing
            NameMessageStart=strcat('Expe_',num2str(Expe.Code,'%03d'), '_Anim_',num2str(AnimIndex,'%03d'),'_',num2str(trial,'%0.3d'));
            if ~isempty(el)
                Eyelink('Message', NameMessageStart);
            end
            % Show the fixation target until spacebar keypress
            % type help ShowFixationTarget for instruction
            % in this case I want that the fixation appears on center of the screen
            ShowFixationTarget(winptr,AnimPath,char(AnimList(AnimIndex)),...
                Expe.FixationPoint,el);
            State = 'Display';
            FPass=1;
            TrialTime=GetSecs;
        
        case 'Display'

            %set or update variables in the program
            if FPass==1;
                NameMessageStart=strcat('start_',num2str(trial,'%03d'));
                Eyelink('Message', NameMessageStart);
                tex1=Screen('MakeTexture', winptr, Im);
                %tex2=Screen('MakeTexture', winptr, ImageStore(ListIm(trial,2)).Im);
                Screen('DrawTexture', winptr, tex1, [0 0 size(Im,2) size(Im,1)], [Expe.AOI(1,:)])
                %Screen('DrawTexture', winptr, tex2, [0 0 ImageStore(ListIm(trial,2)).Sz(2) ImageStore(ListIm(trial,2)).Sz(1)], [xy2])
                vbl  = Screen('Flip', winptr);%, vbl + (0.5 * ifi));%show it
                FPass=0;
                CurrTime=GetSecs;
                TrialTime=GetSecs;
            else
            end
    end

    % Check the state of the keyboard.
    [keyIsDown, seconds, keyCode] = KbCheck;
    % If the user is pressing a key, then display its code number and name.
    if keyIsDown
        kC=find(keyCode);
        kC=kC(1);
        fprintf('You pressed key %i which is %s\n', kC, KbName(kC));

        if kC==escapeKey
            vbl=Screen('Flip', winptr);

            NameMessage=strcat('ended_',num2str(trial,'%0.3d'));
            if ~isempty(el)
                Eyelink('Message', NameMessage);
            end
            Tdur(trial,1)=GetSecs-TrialTime;
        %trial=trial+1;
        Screen('Close',[tex1]);
            sca;break;%return;%break;
            
        end

        if kC==moveKey
            NameMessage=strcat('ended_',num2str(trial,'%0.3d'));
            if ~isempty(el)
                Eyelink('Message', NameMessage);
            end
            Tdur(trial,1)=GetSecs-TrialTime;
            trial=trial+1;
            State='AttGetter';
            Screen('Close',[tex1]);
        end

        % If the user holds down a key, KbCheck will report multiple events.
        % To condense multiple 'keyDown' events into a single event, we wait until all
        % keys have been released.
        while KbCheck; end
    end

    switch State
        case 'Display'
            if ~isempty(el) & FPass==0
                if Eyelink( 'NewFloatSampleAvailable') > 0
                    % get the sample in the form of an event structure
                    evt = Eyelink('NewestFloatSample');
                    if eye_used ~= -1 % do we know which eye to use yet?
                        % if we do, get current gaze position from sample
                        x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                        y = evt.gy(eye_used+1);
                        % do we have valid data and is the pupil visible?
                        if x~=el.MISSING_DATA & y~=el.MISSING_DATA & evt.pa(eye_used+1)>0
                            y=round(y);
                            x=round(x);
                        else
                            x=0;
                            y=0;
                        end
                    end

                    if x<=0 | y<=0 | x>=Expe.wRect(3) | y>=Expe.wRect(4);
                        CurrTime=GetSecs;
                    else
                        islook=AOI(y,x);
                        Results(trial,islook+1)=Results(trial,islook+1)+(GetSecs-CurrTime);
                        CurrTime=GetSecs;
                    end
                else% If there are no new sample available
                    % I don't know if this can occurs, just in case.
                end
            else% if eyelink is not present don't count
            end
    end

    %if GetSecs-TrialTime>Expe.PresDur;%presentation time
    if sum(Results(trial,2:3))>Expe.PresDur;%looking time
        State='AttGetter';
        vbl=Screen('Flip', winptr);
        NameMessage=strcat('ended_',num2str(trial,'%0.3d'));
        if ~isempty(el)
            Eyelink('Message', NameMessage);
        end
        Tdur(trial,1)=GetSecs-TrialTime
        trial=trial+1;
        Screen('Close',[tex1])
    end
    %check termination of expe based on trial
    if trial>Expe.NumPres;
        %Screen('Close',[tex1])
        Screen('closeall');
        break;
    end
end
%screen('closeall');
if ~isempty(el)
    %wait a bit
    WaitSecs(0.1);
    %and stop the eyelink recording
    Eyelink('StopRecording');
end

% finish up: close the eye-movements data file,
if ~isempty(el)
    Eyelink('CloseFile');
    % download the data file
    try
        fprintf('Receiving data file ''%s''\n', Expe.EdfFileName );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(Expe.EdfFileName, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', Expe.EdfFileName, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', Expe.EdfFileName );
    end
end

%save the results
save(Expe.OutFileName,'Expe','Subject','Results');%,'Result');
%clear unecessary variables to avoid carryover effect on next expe
 clear AOI AnimIndex AnimList AnimPath Bool Border CurrTime Expe FileName FilePath ...
     Im Im1 ImWidth ImageStore Lim ListIm NameMessage NameMessageStart NearCent NearEdge ...
     Results Tdur TrialTime VBEdge VTEdge ans escapeKey evt eye_used i islook moveKey ...
     sim status surface tex1 tex2 trialKey winptr xy1 xy2...
     FPass State ifi kC keyCode keyIsDown seconds trial vbl x y;
%Subject=rmfield(Subject,'Expe')


