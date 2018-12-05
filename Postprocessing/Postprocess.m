clear variables; close all; fclose('all'); clc;
dbstop if error;
commandwindow;

% define some variables
xres = 1366;
yres = 768;

% load additional clip data and add function path
cd ../Preprocessing;
addpath(genpath('gazeanalysislib functions'));
sumfile = findGazeFilesInFolder([pwd filesep 'output'], '.txt');
[SUMDATA, SUMHEADERS] = loadCsvAutomatic(sumfile{1});
namec = 3;
durc = 1;
startc = 2;
imgc = 4;

% load I2MC output
cd ../I2MC;
fixfile = findGazeFilesInFolder([pwd filesep 'output'], '.txt');
[FIXDATA, FIXHEADERS] = loadCsvAutomatic(fixfile{1});

fixstart = 1;
fixend = 2;
fixdur = 3;
xc = 4;
yc = 5;
subjectc = 13;
trialc = 14;

% load aois data
cd ..;
aois = containers.Map;
aoisfile = findGazeFilesInFolder([pwd filesep 'Postprocessing'], '.csv');
[AOISDATA, AOISHEADERS] = loadCsvAutomatic(aoisfile{1});

image = 1;
xstart = 3;
xend = 4;
ystart = 5;
yend = 6;

for n = 1:rowCount(AOISDATA)
    imagename = getValueGAL(AOISDATA, n, image);
    x1 = getValueGAL(AOISDATA, n, xstart);
    x2 = getValueGAL(AOISDATA, n, xend);
    y1 = getValueGAL(AOISDATA, n, ystart);
    y2 = getValueGAL(AOISDATA, n, yend);
    aois(imagename) = [x1, x2, y1, y2];
end

% calculate stats and output to text file
cd ./Postprocessing;
if ~isfolder('final output')
    mkdir('final output');
end

cd './final output'

% separate I2MC output into clips by subject id
dataclips = clipDataWhenChangeInCol(FIXDATA, subjectc);

for i = 1:length(dataclips)
    dataclip = dataclips{i};
    sub = getValueGAL(FIXDATA, 1, subjectc);
    
    if ~isfolder(num2str(sub))
        mkdir(num2str(sub));
    end
   
    % make summary file
    cd (num2str(sub));
    fid = fopen(fullfile('summary.txt'), 'w');
    fprintf(fid, 'Total AOI Fixations\tTotal Time in AOI\tFirst time in AOI\tPercentage\t');
    fprintf(fid, 'Image\tDataclip\tParticipant\n');
    
    for j = 1:rowCount(SUMDATA)
        trialscene = getValueGAL(SUMDATA, j, namec);
        CLIPDATA = getRowsContainingValue(FIXDATA, trialc, trialscene);
        
        totalfix = 0;
        totalfixtime = 0;
        firstfix = 0;
        photo = getValueGAL(SUMDATA, j, imgc);
        aoi = aois(photo);
        
        for k = 1:rowCount(CLIPDATA)
            x = getValueGAL(CLIPDATA, k, xc);
            y = getValueGAL(CLIPDATA, k ,yc);
            x1 = aoi(1) * xres;
            x2 = aoi(2) * xres;
            y1 = aoi(3) * yres;
            y2 = aoi(4) * yres;
            
            if x >= x1 && x <= x2 && y >= y1 && y <= y2
                if totalfix == 0
                    starttime = getValueGAL(SUMDATA, j, startc);
                    firstfix = starttime + getValueGAL(CLIPDATA, k, fixstart);
                end

                totalfix = totalfix + 1;
                fixtime = getValueGAL(CLIPDATA, k, fixdur);
                totalfixtime = totalfixtime + fixtime;
            else
                continue
            end
        end
       
        totaldur = getValueGAL(SUMDATA, j, durc);
        percentage = totalfixtime / totaldur;
        fprintf(fid, '%d\t%.3f\t%.3f\t%.4f\t', ...
        [totalfix, totalfixtime, firstfix, percentage]);
        fprintf(fid, '%s', photo);
        fprintf(fid, '\t%s', trialscene);
        fprintf(fid, '\t%d', sub);
        fprintf(fid, '\n');
    end 
    
    fclose(fid);
    cd ..;
    
    csvheaders = {'FixStart', 'FixEnd', 'FixDur', 'XPos', 'YPos', ...
        'FlankedByDataLoss', 'FractionInterpolated', 'WeightCutoff', ...
        'RMSxy', 'BCEA', 'FixRangeX', 'FixRangeY', 'Participant', 'Trial'};
    foldername = num2str(sub);
    filename = 'fixations.txt';
    saveCsvFile([foldername filesep filename], csvheaders, ...
        getColumnGAL(dataclip, 1), getColumnGAL(dataclip, 2), ...
        getColumnGAL(dataclip, 3), getColumnGAL(dataclip, 4), ...
        getColumnGAL(dataclip, 5), getColumnGAL(dataclip, 6), ...
        getColumnGAL(dataclip, 7), getColumnGAL(dataclip, 8), ...
        getColumnGAL(dataclip, 9), getColumnGAL(dataclip, 10), ...
        getColumnGAL(dataclip, 11), getColumnGAL(dataclip, 12), ...
        getColumnGAL(dataclip, 13), getColumnGAL(dataclip, 14));
end

cd ..;














