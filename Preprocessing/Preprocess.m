clear variables; close all; fclose('all'); clc;
dbstop if error;
commandwindow;

folders.data = [pwd filesep 'data'];
ending = 'gazedata';

subc = 1;   % Subject
sessc = 2;  % Session
idc = 3;    % ID
tetc = 4;   % TETTime
rtc = 5;    % RTTime
curxc = 6;  % CursorX
curyc = 7;  % CursorY
timesc = 8; % TimestampSec
timemsc = 9;% TimestampMicroSec
xplc = 10;  % XGazePosLeftEye
yplc = 11;  % YGazePosLeftEye
xclc = 12;  % XCameraPosLeftEye
yclc = 13;  % YCameraPosLeftEye
dialc = 14; % DiameterPupilLeftEye
distlc = 15;% DistanceLeftEye
vallc = 16; % ValidityLeftEye
xprc = 17;  % XGazePosRightEye
yprc = 18;  % YGazePosRightEye
xcrc = 19;  % XCameraPosRightEye
ycrc = 20;  % YCameraPosRightEye
diarc = 21; % DiameterPupilRightEye
distrc = 22;% DistanceRightEye
valrc = 23; % ValidityRightEye
trialc = 24;% TrialId
objc = 35;  % CurrentObject
image1c = 26;   % SceneOneImageName
image2c = 27;   % SceneTwoImageName
image3c = 28;   % SceneThreeImageName

csvheaders = {'Subject', 'Session', 'ID', 'TETTime', 'RTTime', 'CursorX', ...
    'CursorY', 'TimestampSec', 'TimestampMicroSec', 'XGazePosLeftEye', ...
    'YGazePosLeftEye', 'XCameraPosLeftEye', 'YCameraPosLeftEye', ...
    'DiameterPupilLeftEye', 'DistancLeftEye', 'ValidityLeftEye', ...
    'XGazePosRightEye', 'YGazePosRightEye', 'XCameraPosRightEye', ...
    'YCameraPosRightEye', 'DiameterPupilRightEye', 'DistanceRightEye', ...
    'ValidityRightEye', 'TrialId'};

% adding functions to Matlab path
addpath(genpath('gazeanalysislib functions'));

if ~isfolder('output')
    mkdir('output');
end

fid = fopen(fullfile('output', 'summary.txt'), 'w');
fprintf(fid, 'Duration\tStart Time\tDataclip\tImage\n');

cd ../I2MC/input;

files = findGazeFilesInFolder(folders.data, ending);

for j = 1:length(files)
    [DATA, HEADERS] = loadCsvAutomatic(files{j});
    %remove rows for fixations
    DATA = removeRowsContainingValue(DATA, objc, 'Fixation');
    
    % make individual folder for subject
    foldername = num2str(getValueGAL(DATA, 1, subc));
    if ~isfolder(foldername)
        mkdir(foldername);
    end
    
    dataclips = clipDataWhenChangeInCol(DATA, objc);
    
    count = 1;
    
    for i = 1:length(dataclips)
        % saving info file for algorithm input use
        dataclip = dataclips{i};
        scene = getValueGAL(dataclip, 1, objc);
        trial = getValueGAL(dataclip, 1, trialc);
        filename = strcat('trial', num2str(trial, '%03d'), scene, '.txt');
        
        saveCsvFile([foldername filesep filename], csvheaders, ...
            getColumnGAL(dataclip, subc), getColumnGAL(dataclip, sessc), ...
            getColumnGAL(dataclip, idc), getColumnGAL(dataclip, tetc), ...
            getColumnGAL(dataclip, rtc), getColumnGAL(dataclip, curxc), ...
            getColumnGAL(dataclip, curyc), getColumnGAL(dataclip, timesc), ...
            getColumnGAL(dataclip, timemsc), getColumnGAL(dataclip, xplc), ...
            getColumnGAL(dataclip, yplc), getColumnGAL(dataclip, xclc), ...
            getColumnGAL(dataclip, yclc), getColumnGAL(dataclip, dialc), ...
            getColumnGAL(dataclip, distlc), getColumnGAL(dataclip, vallc), ...
            getColumnGAL(dataclip, xprc), getColumnGAL(dataclip, yprc), ...
            getColumnGAL(dataclip, xcrc), getColumnGAL(dataclip, ycrc), ...
            getColumnGAL(dataclip, diarc), getColumnGAL(dataclip, distrc), ...
            getColumnGAL(dataclip, valrc), getColumnGAL(dataclip, trialc));
        
        % saving additional info file for postprocessing use
        clip_duration = getDuration(dataclip, tetc);
        clip_name = strcat('trial', num2str(trial, '%03d'), scene);
        clip_starttime = getValueGAL(dataclip, 1, tetc);
        switch scene
            case 'Scene1'
                clip_image = getValueGAL(dataclip, 1, image1c);
            case 'Scene2'
                clip_image = getValueGAL(dataclip, 1, image2c);
            case 'Scene3'
                clip_image = getValueGAL(dataclip, 1, image3c);
            otherwise
                error("Error with recognising scene image");
        end
                
        fprintf(fid, '%.3f\t', clip_duration);
        fprintf(fid, '%.3f\t', clip_starttime);
        fprintf(fid, '%s\t', clip_name);
        fprintf(fid, '%s\n', clip_image);
    end
    
end

fclose(fid);

cd ..;
  
        