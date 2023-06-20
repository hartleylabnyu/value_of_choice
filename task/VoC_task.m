%% Value of Choice Task %%
% Perri Katzman - 2019 %
% Requires Psychtoolbox-3 %

%% 
clear all; close all; clc; KbName('UnifyKeyNames');

%reset random number generator
RandStream('mlfg6331_64');

for getSubjInfo = 1:1
    % Get subject Info
    subjectID=input('Subject ID (###x): ','s');
    
    if exist(['data/voc' subjectID '.mat'],'file') == 0 % New participant
        statusCheck = input('New Participant. Correct? (1=Yes, 0=No) ', 's');
        startingTrial = 1;
        subjStruct.subjInfo.subjID = subjectID;
        subjStruct.subjInfo.day1Date = datestr(now, 'mm/dd/yy');
        subjStruct.subjInfo.progress = 0;
        
    else % participant file exists
        load(['data/voc' subjectID '.mat'])
        % reinstate some variables
        randBandits = subjStruct.taskInfo.randBandits;
        
        % Determine how much of the task has been completed
        if subjStruct.subjInfo.progress >= .5
            fprintf('   Phase 1 (Bandit Task) Started... ')
        end
        if subjStruct.subjInfo.progress >= 1
            fprintf('   Phase 1 Complete\n')
        end
        if subjStruct.subjInfo.progress >= 1.5
            fprintf('   Phase 2 (Reward Preference) Started... ')
        end
        if subjStruct.subjInfo.progress >= 2
            fprintf('   Phase 2 Complete\n ')
        end
        if subjStruct.subjInfo.progress >= 2.5
            fprintf('   Phase 3 (Reward Knowledge) Started... ')
        end
        if subjStruct.subjInfo.progress >= 3
            fprintf('Experiment complete!\n')
            return
        end
        
        
        % Status check
        if round(subjStruct.subjInfo.progress) == subjStruct.subjInfo.progress % if they are NOT in the middle of a task
            statusCheck = input(['\n\nParticipant has completed Phase ' num2str(subjStruct.subjInfo.progress) '.' ...
                '\nScript will start at the beginning of Phase ' num2str(subjStruct.subjInfo.progress+1) '.' ...
                '\nIs this correct? (1 = yes, 0 = no) ']);
            startingTrial = 1;
        else % they are in the middle of a task
            statusCheck = input(['\n\nParticipant has partially completed Phase ' num2str(subjStruct.subjInfo.progress+.5) '.' ...
                '\nScript will continue where it left off.' ...
                '\nIs this correct? (1 = yes, 0 = no) ']);
        end
        
        if statusCheck == 1 % status check correct
            disp('Great! Continuing...')
        else
            disp('Uh oh! Terminating script.')
            return
        end
        
        % Figure out what trial they're on
        currentPhase = subjStruct.subjInfo.progress + 0.5;
        if currentPhase==1
            try startingTrial = length([subjStruct.banditTask.reward]) + 1;
            catch ME
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    startingTrial = 1;
                end
            end
        elseif currentPhase==2
            try startingTrial = length([subjStruct.rewardSenseTask.selectedBandit]) + 1;
            catch ME
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    startingTrial = 1;
                end
            end
         elseif currentPhase==3
            try startingTrial = length([subjStruct.explicitKnow.response]) + 1;
            catch ME
                if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                    startingTrial = 1;
                end
            end
        end
    end
end


for screenSetUp = 1:1
    % Create stimulus window
    sca
    windowSize = 1; % hard code for now
    if windowSize==1
        windowSize= [0 0 1280 1024]; % [0 0 1920 1200] size of testing room display
        %windowSize = [0 0 1000 1000];
        screenSize=1;
    elseif windowSize==2
        windowSize=[];
        screenSize=2;
    end
    screenid = max(Screen('Screens'));
    Screen('Preference', 'SkipSyncTests', 1);
    win = Screen('OpenWindow', 0, 0, windowSize);
    Screen('TextColor', win, [255 255 255]);
    Screen('TextSize',win, 38);
    Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % format screen to show background-less images
    HideCursor;
    
    % Get screen dimensions
    rect = Screen('Rect', win);
    x_center=(rect(3)-rect(1))/2;
    y_center=(rect(4)-rect(2))/2;
    x_length=rect(3);
    y_height=rect(4);
    
    % Initialize keys
    key_1=KbName('1!');
    key_2=KbName('2@');
    key_3=KbName('3#');
    key_4=KbName('4$');
    key_5=KbName('5%');
    key_6=KbName('6^');
    key_7=KbName('7&');
    key_8=KbName('8*');
    key_9=KbName('9(');
    spaceKey = KbName('Space');
    nextScreen = KbName('RightArrow');
    backScreen = KbName('LeftArrow');
    respSetInstruct = [spaceKey nextScreen backScreen key_1 key_2];
    respSet9 = [key_1 key_2 key_3 key_4 key_5 key_6 key_7 key_8 key_9];
    respSet4=[key_1 key_2 key_3 key_4];
    respSet2=[key_1 key_2];
    inputDevice = -1;
    
    % load stim
    bandit_names = {'banditA', 'banditB', 'banditC', ...
        'banditD', 'banditE', 'banditF'};
    door_names = {'doorAB', 'doorCD', 'doorEF'};
    bandit_up_names = dir('stimuli/bandit*up*');
    bandit_up_names = {bandit_up_names.name};
    bandit_down_names = dir('stimuli/bandit*down*');
    bandit_down_names = {bandit_down_names.name};
    coin_names = dir('stimuli/coin_bandit*');
    coin_names={coin_names.name};
    
    % Make textures
    % bandits
    for ii = 1:length(bandit_names)
        [img, ~, alpha] = imread(['stimuli/' bandit_up_names{ii}]);
        img(:,:,4) = alpha; % need to do this to make them background-less
        bandit_up_tex(ii) = Screen('MakeTexture', win, img);
        [img, ~, alpha] = imread(['stimuli/' bandit_down_names{ii}]);
        img(:,:,4) = alpha; % need to do this to make them background-less
        bandit_down_tex(ii) = Screen('MakeTexture', win, img);
    end
    % bandit coins
    for ii = 1:length(coin_names)
        [img, ~, alpha] = imread(['stimuli/' coin_names{ii}]);
        img(:,:,4) = alpha; % need to do this to make them background-less
        coin_tex(ii) = Screen('MakeTexture', win, img);
    end
    [img, ~, alpha] = imread('stimuli/coin_edge.png');
    img(:,:,4) = alpha; % need to do this to make them background-less
    coinEdge_tex = Screen('MakeTexture', win, img);
    [img, ~, alpha] = imread('stimuli/coin_side.png');
    img(:,:,4) = alpha; % need to do this to make them background-less
    coinSide_tex = Screen('MakeTexture', win, img);

    % door
    [img, ~, alpha] = imread('stimuli/door.png');
    img(:,:,4) = alpha; % need to do this to make them background-less
    door1_tex = Screen('MakeTexture', win, img);
    % window pane
    [img, ~, alpha] = imread('stimuli/windowPane.png');
    img(:,:,4) = alpha; % need to do this to make them background-less
    window_tex = Screen('MakeTexture', win, img);
    % tokens
    token_names = dir('stimuli/token*');
    token_names = {token_names.name};
    for ii = 1:length(token_names)
        [img, ~, alpha] = imread(['stimuli/' token_names{ii}]);
        img(:,:,4) = alpha; % need to do this to make them background-less
        token_tex(ii) = Screen('MakeTexture', win, img);
    end
    %button
    [img, ~, alpha] = imread('stimuli/button.png');
    img(:,:,4) = alpha; % need to do this to make them background-less
    button_tex = Screen('MakeTexture', win, img);
    
    % Calculate image size
    % Left image x-coordinates
    L_x1 = 150;
    L_x2 = x_center-125;
    % Right image x-coordinates
    R_x1 = x_center+125;
    R_x2 = x_length-150;
    % Image width and height
    imageWidth = L_x2 - L_x1;
    imageHeight = imageWidth;
    % Y-coordinates
    y1 = (y_height - imageHeight)/2;
    y2 = imageHeight + y1;
    
    % Stimuli size
    leftImageSize = [L_x1, y1, L_x2, y2];
    rightImageSize = [R_x1, y1, R_x2, y2];
    doorSize = [x_center-250 y_height-700 x_center+250 y_height];
    leftPreviewSize = [x_center-135 y_height-600 x_center-10 y_height-500];
    rightPreviewSize = [x_center+10 y_height-600 x_center+135 y_height-500];
    windowSize = [x_center-145 y_height-620 x_center+145 y_height-480];
    leftOfferBox = [x_center/6 y_center/5 x_center*5/6 y_center*2/5];
    rightOfferBox = [x_center+x_center/6 y_center/5 x_center+x_center*5/6 y_center*2/5];
    leftOfferTextPositionX = x_center/5+10;
    rightOfferTextPositionX = x_center+x_center/5+10;
    offerTextPositionY = y_center*1.7/5;
    
    % generic bandit info
    allBandits = {'bandit50a', 'bandit50b', 'bandit70', 'bandit30', 'bandit90', 'bandit10'};
    [bandits5050] = allBandits(1:2);
    [bandits7030] = allBandits(3:4);
    [bandits9010] = allBandits(5:6);
end

if subjStruct.subjInfo.progress == 0 % if this is a new participant
    for taskSetUp = 1:1
        %% assign bandits to conditions
        [randPairs, randConditionIdx] = Shuffle({randperm(2), randperm(2)+2, randperm(2)+4});
        randSequence = [randPairs{:}];
        randBandits = allBandits(randSequence);
        banditConditions = {'bandits5050', 'bandits7030', 'bandits9010'};
        randConditions = banditConditions(randConditionIdx);
        subjStruct.taskInfo.randBandits = randBandits;
        
        % save to struct
        subjStruct.taskInfo.bandit50a = bandit_names{contains(randBandits,'bandit50a')};
        subjStruct.taskInfo.bandit50b = bandit_names{contains(randBandits,'bandit50b')};
        subjStruct.taskInfo.bandit70 = bandit_names{contains(randBandits,'bandit70')};
        subjStruct.taskInfo.bandit30 = bandit_names{contains(randBandits,'bandit30')};
        subjStruct.taskInfo.bandit90 = bandit_names{contains(randBandits,'bandit90')};
        subjStruct.taskInfo.bandit10 = bandit_names{contains(randBandits,'bandit10')};
        
        
        %% generate pseudo-random reward outcomes
        
        % counts are for keeping track during task
        subjStruct.taskInfo.bandit50a_count = 1; subjStruct.taskInfo.bandit50b_count = 1;
        subjStruct.taskInfo.bandit70_count = 1; subjStruct.taskInfo.bandit30_count = 1;
        subjStruct.taskInfo.bandit90_count = 1; subjStruct.taskInfo.bandit10_count = 1;
        subjStruct.taskInfo.bandits5050_count = 1;
        subjStruct.taskInfo.bandits7030_count = 1;
        subjStruct.taskInfo.bandits9010_count = 1;
        subjStruct.taskInfo.bandits5050_compCount = 1;
        subjStruct.taskInfo.bandits7030_compCount = 1;
        subjStruct.taskInfo.bandits9010_compCount = 1;
        
        % computer's left-right choices for each room
        subjStruct.taskInfo.bandits5050_compChoice = [];
        subjStruct.taskInfo.bandits7030_compChoice = [];
        subjStruct.taskInfo.bandits9010_compChoice = [];
        
        % random left/right choices for computer
        for ii = 1:100
             subjStruct.taskInfo.bandits5050_compChoice = ...
                 [subjStruct.taskInfo.bandits5050_compChoice Shuffle([1, 1, 2, 2])];
             subjStruct.taskInfo.bandits7030_compChoice = ...
                 [subjStruct.taskInfo.bandits7030_compChoice Shuffle([1, 1, 2, 2])];
             subjStruct.taskInfo.bandits9010_compChoice = ...
                 [subjStruct.taskInfo.bandits9010_compChoice Shuffle([1, 1, 2, 2])];
        end

        
        % build pseudo-random reward outcome order
        % initialize
        bandit50a_outcomes = []; bandit50b_outcomes = [];
        bandit70_outcomes = []; bandit30_outcomes = [];
        bandit90_outcomes = []; bandit10_outcomes = [];
        for ii = 1:50
            bandit50a_outcomes = [bandit50a_outcomes Shuffle([1 1 0 0])];
            bandit50b_outcomes = [bandit50b_outcomes Shuffle([1 1 0 0])];
        end
        for ii = 1:20
            bandit70_outcomes = [bandit70_outcomes Shuffle([ones(1,7), zeros(1,3)])];
            bandit30_outcomes = [bandit30_outcomes Shuffle([ones(1,3), zeros(1,7)])];
            bandit90_outcomes = [bandit90_outcomes Shuffle([ones(1,9), 0])];
            bandit10_outcomes = [bandit10_outcomes Shuffle([1, zeros(1,9)])];
        end
        
        % save to struct
        subjStruct.taskInfo.bandit50a_outcomes = bandit50a_outcomes;
        subjStruct.taskInfo.bandit50b_outcomes = bandit50b_outcomes;
        subjStruct.taskInfo.bandit70_outcomes = bandit70_outcomes;
        subjStruct.taskInfo.bandit30_outcomes = bandit30_outcomes;
        subjStruct.taskInfo.bandit90_outcomes = bandit90_outcomes;
        subjStruct.taskInfo.bandit10_outcomes = bandit10_outcomes;
        
        %% generate pseudo-random condition order
        conditionOrder = {};
        for ii = 1:105
            conditionOrder = [conditionOrder banditConditions(randperm(3))];
        end
        
        % save to struct
        subjStruct.taskInfo.conditionOrder = conditionOrder;
        
        %% generate pseudo-random offer order
        bandits5050_offers = [];
        bandits7030_offers = [];
        bandits9010_offers = [];
        for ii = 1:17
            bandits5050_offers = [bandits5050_offers randperm(7)-1];
            bandits7030_offers = [bandits7030_offers randperm(7)-1];
            bandits9010_offers = [bandits9010_offers randperm(7)-1];
        end
        
        % save to struct
        subjStruct.taskInfo.bandits5050_offers = bandits5050_offers;
        subjStruct.taskInfo.bandits7030_offers = bandits7030_offers;
        subjStruct.taskInfo.bandits9010_offers = bandits9010_offers;
        
        
        % make design struct
        for ii = 1:length(conditionOrder)
            subjStruct.banditTask(ii).subID = ['voc' subjectID];
            subjStruct.banditTask(ii).trial = ii;
            subjStruct.banditTask(ii).condition = conditionOrder{ii};
        end
        
        
        % intialize value estimates
        subjStruct.taskInfo.valueEst.bandit90 = 0;
        subjStruct.taskInfo.valueEst.bandit10 = 0;
        subjStruct.taskInfo.valueEst.bandit70 = 0;
        subjStruct.taskInfo.valueEst.bandit30 = 0;
        subjStruct.taskInfo.valueEst.bandit50a = 0;
        subjStruct.taskInfo.valueEst.bandit50b = 0;
        
        
        % for reward sensitivity task
        % compare each bandit against each other
        randMixedBandits = [];
        for ii = 1:3
        mixedBandits1 = nchoosek(allBandits,2);
        mixedBandits1 = mixedBandits1(randperm(length(mixedBandits1)),:);
        mixedBandits2 = fliplr(mixedBandits1);
        mixedBandits2 = mixedBandits2(randperm(length(mixedBandits2)),:);
        mixedBandits = [mixedBandits1; mixedBandits2];
        % randomize order
        randMixedBandits = [randMixedBandits; mixedBandits];
        end
        
        
        % make design struct
        for ii = 1:length(randMixedBandits)
            subjStruct.rewardSenseTask(ii).subID = ['voc' subjectID];
            subjStruct.rewardSenseTask(ii).trial = ii;
            subjStruct.rewardSenseTask(ii).leftBandit = randMixedBandits{ii,1};
            subjStruct.rewardSenseTask(ii).rightBandit = randMixedBandits{ii,2};
        end
        
        
        
        
        
    end
    
    for instructions = 1:1
        
        % load instruction screens
        screen_names = dir('instructions/Slide*');
        screen_names = {screen_names.name};
        specialScreens = [9, 10, 13, 14, 19]; % when you need to make specific response
        
        % Make textures
        for ii = 1:length(screen_names)
            screen_tex(ii) = Screen('MakeTexture', win, imread(['instructions/' screen_names{ii}]));
        end
        % display first screen
        Screen('DrawTexture', win, screen_tex(1),[],[0 0 x_length y_height]);
        Screen('Flip',win);
        currentScreen = 1;
        instructionsDone = 0;
        
        while instructionsDone == 0 % wait response
            [keyIsDown, secs, keyCode] = KbCheck(-1); % continuously check if key has been pressed
            keyPressed=find(keyCode);
            if keyIsDown==1 && ismember(keyPressed(1),respSetInstruct)
                while 1
                    if keyCode(key_2) && (currentScreen==10 || currentScreen==13)
                        Screen('DrawTexture', win, screen_tex(currentScreen+1),[],[0 0 x_length y_height]);
                        currentScreen = currentScreen+1;
                        WaitSecs(.2);
                        Screen('Flip',win);
                        break
                    elseif keyCode(key_1) && (currentScreen==9 || currentScreen==14)
                        Screen('DrawTexture', win, screen_tex(currentScreen+1),[],[0 0 x_length y_height]);
                        currentScreen = currentScreen+1;
                        WaitSecs(.2);
                        Screen('Flip',win);
                        break
                    elseif keyCode(nextScreen)  && currentScreen<20 && sum(ismember(specialScreens, currentScreen))==0 % participant presses right arrow
                        Screen('DrawTexture', win, screen_tex(currentScreen+1),[],[0 0 x_length y_height]);
                        currentScreen = currentScreen+1;
                        WaitSecs(.2);
                        Screen('Flip',win);
                        break
                    elseif keyCode(backScreen) && currentScreen>1 && sum(ismember(specialScreens, currentScreen))==0 % participant presses left arrow
                        Screen('DrawTexture', win, screen_tex(currentScreen-1),[],[0 0 x_length y_height]);
                        currentScreen=currentScreen-1;
                        WaitSecs(.2);
                        Screen('Flip',win);
                        break
                    elseif keyCode(spaceKey) && currentScreen==19
                        instructionsDone=1;
                        WaitSecs(.2);
                        break
                    else
                        break
                    end
                end
            end
        end % end waiting for response
    end % end instructions loop
end % end new participant to-dos

if subjStruct.subjInfo.progress < 1
    %% Bandit Task
    for banditTask = 1:1
        subjStruct.subjInfo.progress = .5; % update progress
        subjStruct.subjInfo.banditTask_startTime = datetime;
        
        for trialNum = startingTrial:length(subjStruct.banditTask)
            %% Break if needed
            if trialNum == 106 || trialNum == 211
                DrawFormattedText(win, ['Great job!\n\n' ...
                    'You''ve gotten ' num2str(sum([subjStruct.banditTask.tokensEarned])) ' tokens so far.\n\n' ...
                    'Take a quick break and\n'...
                    'press the SPACE bar to continue.'], 'center', 'center', [255 255 255]);
                Screen('Flip',win);
                while 1
                    [keyIsDown, secs, keyCode] = KbCheck(inputDevice);
                    if find(keyCode) == KbName('space')
                        break
                    end
                end
            end
            
            %% Trial SetUp
            % select banditCondition
            thisTrial_condition = subjStruct.banditTask(trialNum).condition; %e.g. 'bandits5050'
            
            % assign left and right bandit
            eval(['[leftBandit, rightBandit] = ' thisTrial_condition '{randperm(2)};']) % e.g. leftBandit = 'bandit50a'
            subjStruct.banditTask(trialNum).leftBandit = leftBandit;
            subjStruct.banditTask(trialNum).rightBandit = rightBandit;
            
            % token offer
            thisTrial_conditionCountStr = ['subjStruct.taskInfo.' thisTrial_condition '_count'];
            thisTrial_offer = eval(['subjStruct.taskInfo.' thisTrial_condition '_offers(' thisTrial_conditionCountStr ');']);
            subjStruct.banditTask(trialNum).tokenOffer = thisTrial_offer;
            
            %% Agency Selection
            % display door
            Screen('DrawTexture', win, door1_tex, [], doorSize);
            Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,leftBandit)),[], leftPreviewSize);
            Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,rightBandit)),[], rightPreviewSize);
            Screen('DrawTexture', win, window_tex, [], windowSize);
            
            % display offer boxes
            Screen('DrawTexture', win, button_tex, [], leftOfferBox);
            Screen('DrawTexture', win, button_tex, [], rightOfferBox);

            % display offer amounts
            DrawFormattedText(win, ['RANDOM +' num2str(thisTrial_offer) ' tokens'], leftOfferTextPositionX, offerTextPositionY, [0 0 0]);
            DrawFormattedText(win, 'I WANT TO CHOOSE', rightOfferTextPositionX, offerTextPositionY, [0 0 0]);
            choiceOnset_raw = Screen('Flip',win);
            
            while 1 % wait for agency choice
                [keyIsDown, secs, keyCode] = KbCheck(inputDevice); % continuously check if key has been pressed
                keyPressed=find(keyCode);
                if keyIsDown==1 && ismember(keyPressed(1),respSet2)
                    while 1
                        if keyCode(key_1) % participant presses key 1
                            subjStruct.banditTask(trialNum).agencyResp = 1;
                            subjStruct.banditTask(trialNum).agency = 0;
                            agency = 0;
                            WaitSecs(.2)
                            break
                        elseif keyCode(key_2) % participant presses key 2
                            subjStruct.banditTask(trialNum).agencyResp = 2;
                            subjStruct.banditTask(trialNum).agency = 1;
                            agency = 1;
                            WaitSecs(.2);
                            break
                        end
                    end
                    break
                end
            end % waiting for agency choice
            subjStruct.banditTask(trialNum).agencyRT = secs - choiceOnset_raw;
            
            %% Bandit Selection
            
            % get computer's choice
            if agency == 0
                % 1 = first bandit (i.e., 50a, 70, or 90); 
                % 2 = second bandit (i.e., 50b, 30, or 10)
                bandit_number = eval(['subjStruct.taskInfo.' thisTrial_condition '_compChoice(subjStruct.taskInfo.' thisTrial_condition '_compCount)']);
                
                % e.g., 'bandit90', 'bandit50a', etc.
                compSelection_banditName = eval([thisTrial_condition '{' num2str(bandit_number) '}']);
                
                % figure out if compSelection_banditName is on the left or right
                if strcmp(compSelection_banditName,leftBandit)
                    resp_bandit = 1;
                else
                    resp_bandit = 2;
                end
                eval(['subjStruct.taskInfo.' thisTrial_condition '_compCount = subjStruct.taskInfo.' thisTrial_condition '_compCount + 1;'])
            end
            
            if agency == 1 % participant chooses bandit
                % display bandits
                DrawFormattedText(win, 'YOU CHOOSE:', 'center', y_height/6, [255 255 255]);
                Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,leftBandit)),[], leftImageSize);
                Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,rightBandit)),[], rightImageSize);
                banditOnset_raw = Screen('Flip',win);
                while 1 % wait for bandit selection
                    [keyIsDown, secs, keyCode] = KbCheck(inputDevice); % continuously check if key has been pressed
                    keyPressed=find(keyCode);
                    if keyIsDown==1 && ismember(keyPressed(1),respSet2)
                        while 1
                            if keyCode(key_1) % participant presses key 1
                                resp_bandit = 1;
                                subjStruct.banditTask(trialNum).selectedBandit = leftBandit;
                                subjStruct.banditTask(trialNum).nonSelectedBandit = rightBandit;
                                subjStruct.banditTask(trialNum).banditResp = 1;
                                selectedBandit = leftBandit;
                                selectedImageSize = leftImageSize;
                                WaitSecs(.2)
                                break
                            elseif keyCode(key_2) % participant presses key 2
                                resp_bandit = 2;
                                subjStruct.banditTask(trialNum).selectedBandit = rightBandit;
                                subjStruct.banditTask(trialNum).nonSelectedBandit = leftBandit;
                                subjStruct.banditTask(trialNum).banditResp = 2;
                                selectedBandit = rightBandit;
                                selectedImageSize = rightImageSize;
                                WaitSecs(.2);
                                break
                            end
                        end
                        break
                    end
                end % waiting for bandit choice (sub pick)
                
            else % computer chooses bandit

                % call coin flip function
                coin1=coin_tex(contains(randBandits,leftBandit));
                coin2=coin_tex(contains(randBandits,rightBandit));
                if resp_bandit == 1
                    finalSide = coin1;
                else
                    finalSide = coin2;
                end
                leftBandit_tex = bandit_up_tex(contains(randBandits,leftBandit));
                rightBandit_tex = bandit_up_tex(contains(randBandits,rightBandit));

                coinFlip_VoC(win, coin1, coin2, finalSide, coinSide_tex, coinEdge_tex, leftBandit_tex, rightBandit_tex,leftImageSize,rightImageSize)

                banditOnset_raw = GetSecs();
                
                while 1 % wait for bandit selection
                    [keyIsDown, secs, keyCode] = KbCheck(inputDevice); % continuously check if key has been pressed
                    keyPressed=find(keyCode);
                    if keyIsDown==1 && ismember(keyPressed(1),respSet2(resp_bandit))
                        while 1
                            if resp_bandit == 1
                                subjStruct.banditTask(trialNum).selectedBandit = leftBandit;
                                subjStruct.banditTask(trialNum).nonSelectedBandit = rightBandit;
                                subjStruct.banditTask(trialNum).banditResp = 1;
                                selectedBandit = leftBandit;
                                selectedImageSize = leftImageSize;
                            else
                                subjStruct.banditTask(trialNum).selectedBandit = rightBandit;
                                subjStruct.banditTask(trialNum).nonSelectedBandit = leftBandit;
                                subjStruct.banditTask(trialNum).banditResp = 2;
                                selectedBandit = rightBandit;
                                selectedImageSize = rightImageSize;
                            end
                            break
                        end
                        break
                    end
                end % waiting for bandit choice (comp pick)
            end % end bandit choice
            subjStruct.banditTask(trialNum).banditRT = secs - banditOnset_raw;
            
            %% display selected bandit & reward outcome
            % reward text
            dotStr = '.';
            for ii = 1:5
                DrawFormattedText(win, dotStr, 'center', y_height/6, [255 255 255]);
                Screen('DrawTexture',win, bandit_down_tex(contains(randBandits,selectedBandit)),[], selectedImageSize);
                Screen('Flip', win); WaitSecs(.1);
                dotStr = [dotStr '.'];
            end
            
            % get reward probability for selected bandit
            thisTrial_countStr = ['subjStruct.taskInfo.' selectedBandit '_count'];
            thisTrial_reward = eval(['subjStruct.taskInfo.' selectedBandit '_outcomes(' thisTrial_countStr ');']);
            subjStruct.banditTask(trialNum).reward = thisTrial_reward;
            
            % display outcome
            if thisTrial_reward == 1
                DrawFormattedText(win, 'YOU WON 10 TOKENS!', 'center', y_height/6, [255 255 255]);
            else
                DrawFormattedText(win, 'YOU LOST!', 'center', y_height/6, [255 255 255]);
            end
            
            % display tokens earned
            if agency==1
                thisTrial_tokensEarned = 10*thisTrial_reward;
            else
                thisTrial_tokensEarned = 10*thisTrial_reward + thisTrial_offer;
            end
            subjStruct.banditTask(trialNum).tokensEarned = thisTrial_tokensEarned;
            % display tokens
            if thisTrial_tokensEarned == 1
                DrawFormattedText(win, ['You get ' num2str(thisTrial_tokensEarned) ' token'], 'center', y_height*5/6, [255 255 255]);
            else
                DrawFormattedText(win, ['You get ' num2str(thisTrial_tokensEarned) ' tokens'], 'center', y_height*5/6, [255 255 255]);
            end
            Screen('DrawTexture',win, token_tex(thisTrial_tokensEarned+1),[],[0 y_height*.85 x_length y_height]);
            
            % display selected bandit
            Screen('DrawTexture',win, bandit_down_tex(contains(randBandits,selectedBandit)),[], selectedImageSize);
            Screen('Flip', win);
            WaitSecs(1.5);
            
            % determine if optimal decision
                % EV_choose = max(leftBandit, rightBandit)
                % EV_comp = .5*(leftBandit + rightBandit) + offer
            subjStruct.banditTask(trialNum).EV_choose = ...
                eval(['max(subjStruct.taskInfo.valueEst.' leftBandit ', subjStruct.taskInfo.valueEst.' rightBandit ')']);
            subjStruct.banditTask(trialNum).EV_comp = ...
                eval(['.5*(subjStruct.taskInfo.valueEst.' leftBandit '+ subjStruct.taskInfo.valueEst.' rightBandit ')']) + .1*thisTrial_offer;
    
            % record EV of selected and non-selected actions (choose or comp)
            if subjStruct.banditTask(trialNum).agency == 1 % opted to choose
                subjStruct.banditTask(trialNum).EV_selectedAction = subjStruct.banditTask(trialNum).EV_choose;
                subjStruct.banditTask(trialNum).EV_nonselectedAction = subjStruct.banditTask(trialNum).EV_comp;
            else % accepted offer
                subjStruct.banditTask(trialNum).EV_selectedAction = subjStruct.banditTask(trialNum).EV_comp;
                subjStruct.banditTask(trialNum).EV_nonselectedAction = subjStruct.banditTask(trialNum).EV_choose;
            end
            subjStruct.banditTask(trialNum).EV_selectedMinusNonselected = ...
                subjStruct.banditTask(trialNum).EV_selectedAction - subjStruct.banditTask(trialNum).EV_nonselectedAction;
            
            if subjStruct.banditTask(trialNum).EV_choose > subjStruct.banditTask(trialNum).EV_comp % choice optimal
                subjStruct.banditTask(trialNum).optimalToChoose = 1;
                if agency == 1 % sub picks
                    subjStruct.banditTask(trialNum).optimal = 1;
                else
                    subjStruct.banditTask(trialNum).optimal = -1;
                end
            elseif subjStruct.banditTask(trialNum).EV_choose < subjStruct.banditTask(trialNum).EV_comp % comp optimal
                subjStruct.banditTask(trialNum).optimalToChoose = 0;
                if agency == 0 % comp picks
                    subjStruct.banditTask(trialNum).optimal = 1;
                else
                    subjStruct.banditTask(trialNum).optimal = -1;
                end
            else
                subjStruct.banditTask(trialNum).optimal = 0;
            end
            
            % update value estimate of selected bandit
            eval(['subjStruct.taskInfo.valueEst.' selectedBandit '=' ...
            'mean([subjStruct.banditTask(find(strcmp({subjStruct.banditTask.selectedBandit},''' selectedBandit ''')==1)).reward]);']);
            
            subjStruct.banditTask(trialNum).trialOfCond = eval(thisTrial_conditionCountStr);
            eval([thisTrial_conditionCountStr ' = ' thisTrial_conditionCountStr ' + 1;']); % increment count how many times this condition has been seen (starts at 1)
            eval([thisTrial_countStr '=' thisTrial_countStr '+ 1;']) % increment count of how many times this bandit has been played (starts at 1)

            % Save Subject Struct on every trial
            save(['data/voc' subjectID], 'subjStruct');
        end % end trial loop
        subjStruct.subjInfo.progress = 1; % update progress
        subjStruct.subjInfo.banditTask_endTime = datetime;
        subjStruct.subjInfo.banditTask_duration = ...
            subjStruct.subjInfo.banditTask_endTime - subjStruct.subjInfo.banditTask_startTime;
    end % task
    DrawFormattedText(win, ['Congrats! You earned ' num2str(sum([subjStruct.banditTask.tokensEarned])) ...
        ' tokens!\n\n Press SPACE to continue to the next part of the game.'], 'center', 'center', [255 255 255]);
    Screen('Flip', win);
    while 1
        [keyIsDown, secs, keyCode] = KbCheck(inputDevice);
        if find(keyCode) == KbName('space')
            WaitSecs(.5)
            break
        end
    end
    
end
if subjStruct.subjInfo.progress < 2
    %% Reward Sensitivity Task
    for rewardSensitivityTask = 1:1
        subjStruct.subjInfo.progress = 1.5; % update progress
        subjStruct.subjInfo.rewardSenseTask_startTime = datetime;
        
        
        % Instructions
        if startingTrial == 1
            DrawFormattedText(win, ['Now you will see pairs of slot machines. Sometimes\n' ...
                'you will see machines paired together that were\n' ...
                'not in the same room during the first game.\n\n' ...
                'Choose the slot machine that you think will most\n' ...
                'likely give you tokens. If you are not sure which\n' ...
                'machine to pick, use your gut. You will not see\n' ...
                'whether you win or lose on each trial.\n\n'...
                'Press SPACE to start!'], 'center', 'center', [255 255 0]);
            Screen('Flip', win); WaitSecs(1);
            while 1
                [keyIsDown, secs, keyCode] = KbCheck(inputDevice);
                if find(keyCode) == KbName('space')
                    break
                end
            end
        end
        
        
        for trialNum = startingTrial:length(subjStruct.rewardSenseTask)
            leftBandit = subjStruct.rewardSenseTask(trialNum).leftBandit;
            rightBandit = subjStruct.rewardSenseTask(trialNum).rightBandit;
            
            DrawFormattedText(win, 'YOU CHOOSE:', 'center', y_height/6, [255 255 255]);
            Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,leftBandit)),[], leftImageSize);
            Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,rightBandit)),[], rightImageSize);
            banditOnset_raw = Screen('Flip',win);
            while 1 % wait for bandit selection
                [keyIsDown, secs, keyCode] = KbCheck(inputDevice); % continuously check if key has been pressed
                keyPressed=find(keyCode);
                if keyIsDown==1 && ismember(keyPressed(1),respSet2)
                    while 1
                        if keyCode(key_1) % participant presses key 1
                            resp_bandit = 1;
                            subjStruct.rewardSenseTask(trialNum).selectedBandit = leftBandit;
                            nonSelectedBandit = rightBandit;
                            subjStruct.rewardSenseTask(trialNum).banditKeyResp = 1;
                            selectedBandit = leftBandit;
                            selectedImageSize = leftImageSize;
                            WaitSecs(.2)
                            break
                        elseif keyCode(key_2) % participant presses key 2
                            resp_bandit = 2;
                            subjStruct.rewardSenseTask(trialNum).selectedBandit = rightBandit;
                            nonSelectedBandit = leftBandit;
                            subjStruct.rewardSenseTask(trialNum).banditKeyResp = 2;
                            selectedBandit = rightBandit;
                            selectedImageSize = rightImageSize;
                            WaitSecs(.2);
                            break
                        end
                    end
                    break
                end
            end
            subjStruct.rewardSenseTask(trialNum).RT = secs - banditOnset_raw;
            Screen('DrawTexture',win, bandit_down_tex(contains(randBandits,selectedBandit)),[], selectedImageSize);
            Screen('Flip', win); WaitSecs(.5)
            
            % score accuracy
            selectedProb = str2double(selectedBandit(7:8));
            nonSelectedProb = str2double(nonSelectedBandit(7:8));
            if selectedProb>nonSelectedProb
                subjStruct.rewardSenseTask(trialNum).accuracy = 1;
            elseif selectedProb<nonSelectedProb
                subjStruct.rewardSenseTask(trialNum).accuracy = -1;
            else
                subjStruct.rewardSenseTask(trialNum).accuracy = 0;
            end
            
            % Save Subject Struct on every trial
            save(['data/voc' subjectID], 'subjStruct');
            
        end % end trial loop
        subjStruct.subjInfo.progress = 2; % update progress
        subjStruct.subjInfo.rewardSenseTask_endTime = datetime;
        subjStruct.subjInfo.rewardSenseTask_duration = ...
            subjStruct.subjInfo.rewardSenseTask_endTime - subjStruct.subjInfo.rewardSenseTask_startTime;
    end
end
if subjStruct.subjInfo.progress < 3
    %% Explicit Reward Knowledge
    % test explicit knowledge of reward probability
    for explicitKnowledgeQs = 1:1
        subjStruct.subjInfo.progress = 2.5; % update progress
        subjStruct.subjInfo.explicitKnow_startTime = datetime;
        % randomize bandit order
        reRandBandits = allBandits(randperm(length(allBandits)));
        
        % Instructions
        if startingTrial == 1
            DrawFormattedText(win, ...
                ['Now you will see each slot machines one at a\n' ...
                'time and say what you think its chance of winning is.\n' ...
                'Use keys 1-9 to answer from 10% (1 out of every 10\n' ...
                'trials) to 90% (9 out of every 10 trials). Even if\n' ...
                'you are not sure, just make your best guess.\n\n'...
                'Press SPACE to start!'], 'center', 'center', [255 255 0]);
            Screen('Flip', win); WaitSecs(1);
            while 1
                [keyIsDown, secs, keyCode] = KbCheck(inputDevice);
                if find(keyCode) == KbName('space')
                    break
                end
            end
        end
        
        for trialNum = startingTrial:length(reRandBandits)
            subjStruct.explicitKnow(trialNum).subID = ['voc' subjectID];
            subjStruct.explicitKnow(trialNum).trial = trialNum;
            subjStruct.explicitKnow(trialNum).bandit = reRandBandits{trialNum};
            Screen('DrawTexture',win, bandit_up_tex(contains(randBandits,reRandBandits{trialNum})),[], [x_center-100 100 x_center+100 300]);
            DrawFormattedText(win, 'What is the chance of winning at this machine?\n\nUse keys 1-9 to respond.', 'center', 'center', [255 255 255]);
            DrawFormattedText(win, '10%  20%  30%  40%  50%  60%  70%  80%  90%', 'center', y_center+150, [255 255 255]);
            onsetRaw = Screen('Flip', win);
            while 1
                [keyIsDown, secs, keyCode] = KbCheck(inputDevice);
                keyPressed = find(keyCode);
                fullKeyCode = KbName(keyPressed);
                if keyIsDown==1 && ismember(keyPressed(1),respSet9)
                    subjStruct.explicitKnow(trialNum).response = str2double(fullKeyCode(1));
                    subjStruct.explicitKnow(trialNum).trueProb = str2double(reRandBandits{trialNum}(7));
                    break
                end
            end
            subjStruct.explicitKnow(trialNum).RT = secs - onsetRaw;
            Screen('Flip', win)
            WaitSecs(.2)
            
            % Save Subject Struct on every trial
            save(['data/voc' subjectID], 'subjStruct');
        end
        subjStruct.subjInfo.progress = 3; % update progress
        subjStruct.subjInfo.explicitKnow_endTime = datetime;
        subjStruct.subjInfo.explicitKnow_duration = ...
            subjStruct.subjInfo.explicitKnow_endTime - subjStruct.subjInfo.explicitKnow_startTime;
    end
end

%% End of experiment

% calculate money earned
% (based on quintiles from simulated data)
totalEarnings = sum([subjStruct.banditTask.tokensEarned]);
if totalEarnings <= 2300
    bonusMoney = 1;
elseif totalEarnings > 2300 && totalEarnings <= 2400
    bonusMoney = 2;
elseif totalEarnings > 2400 && totalEarnings <= 2500
    bonusMoney = 3;
elseif totalEarnings > 2500 && totalEarnings <= 2600
    bonusMoney = 4;
elseif totalEarnings > 2600
    bonusMoney = 5;
end

% save to subjStruct
subjStruct.subjInfo.totalEarnings = totalEarnings;
subjStruct.subjInfo.bonusMoney = bonusMoney;
save(['data/voc' subjectID], 'subjStruct');

% save csv files for phases 1, 2, and 3
struct2csv(subjStruct.banditTask,['data/voc' subjectID '_banditTask.csv']);
struct2csv(subjStruct.rewardSenseTask,['data/voc' subjectID '_rewardSense.csv']);
struct2csv(subjStruct.explicitKnow,['data/voc' subjectID '_explicitKnow.csv']);


% Display end of experiment message
DrawFormattedText(win, ['Congrats! You''re done!\n\n' ...
    'You won $' num2str(bonusMoney) ' bonus money.\n\n' ...
    'Please let the experimenter know.'], 'center', 'center', [255 255 255]);
Screen('Flip', win);
while 1
    [keyIsDown, secs, keyCode] = KbCheck(inputDevice);
    if find(keyCode) == KbName('space')
        break
    end
end
sca



