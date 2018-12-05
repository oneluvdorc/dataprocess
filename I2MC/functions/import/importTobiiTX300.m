function [timestamp,lx,ly,rx,ry] = importTobiiTX300(file,nskip,res,missingx,missingy)
% Imports data from Tobii TX300 as returned by Tobii SDK
% res = [xres yres] --> must know the resolution of screen (measures in
                        % pixels)

dat = readintfile(file,nskip,24);

timestamp   = dat(:,4);           % RelTimestamp (turn into millisecond)
timestamp   = timestamp-timestamp(1); % convert to relative timestamp
lx          = dat(:,10 ) * res(1);  % LGazePos2dx
ly          = dat(:,11 ) * res(2);  % LGazePos2dy
lv          = dat(:,16);           % LValidity
rx          = dat(:,17) * res(1);  % RGazePos2dx
ry          = dat(:,18) * res(2);  % RGazePos2dy
rv          = dat(:,23);           % RValidity

% sometimes we have weird peaks where one sample is (very) far outside the
% monitor. Here, count as missing any data that is more than one monitor
% distance outside the monitor.
qMiss = lx<-res(1) | lx>2*res(1) | ly<-res(2) | ly>2*res(2) | lv>1;
lx(qMiss) = missingx;
ly(qMiss) = missingy;
qMiss = rx<-res(1) | rx>2*res(1) | ry<-res(2) | ry>2*res(2) | rv>1;
rx(qMiss) = missingx;
ry(qMiss) = missingy;

return
