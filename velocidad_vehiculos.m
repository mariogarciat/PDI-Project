close all, clear all, clc

video = VideoReader('video.mp4');

rowSize = video.Height;
space = rowSize*0.05;
numFrames = get(video,'NumberOfFrames');
shot = read(video,1);
[fil,col,cap] = size(shot); 

maskDown = shot * 0;
maskUp = shot * 0;

maskDown(953:973, 885:1090, :) = 150;
maskUp(410:430, 910:1000, :) = 150;

indDown = find(maskDown ~= 0);
indUp = find(maskUp ~= 0);

auxMaskDownActual = maskDown;
auxMaskUpActual = maskUp;
auxMaskDownSiguiente = maskDown;
auxMaskUpSiguiente = maskUp;

frameId = 1;
while (frameId+1 < numFrames)
    frameActual = read(video, frameId);
    frameSiguiente = read(video, frameId+1);
    
    auxMaskDownActual(indDown) = frameActual(indDown);
    auxMaskUpActual(indUp) = frameActual(indUp);
    auxMaskDownSiguiente(indDown) = frameSiguiente(indDown);
    auxMaskUpSiguiente(indUp) = frameSiguiente(indUp);
    
    diferenciaDown = auxMaskDownActual - auxMaskDownSiguiente;
    diferenciaUp = auxMaskUpActual - auxMaskUpSiguiente;
    
    figure(1); imshow(diferenciaDown);
    figure(2); imshow(diferenciaUp);
%     figure(3); imshow(frameActual-frameSiguiente);
    frameId = frameId + 1;
end




% while hasFrame(video)
%     img1 = readFrame(video);
%     img2 = readFrame(video);
%     upMark = space;
%     downMark = rowSize - space;
%    
% end
% 906 430 izq up
% 1000 430 der up
% x = 1;
% while (x < 3)
%     imgs{x} = read(video, x);
%     x = x +1;
% end
% b = imgs{1, 1} - imgs{1, 2};
% figure(1); imshow(maskDown);
% figure(3); imshow(maskUp);
% figure(2); imshow(imgs{1, 2}); impixelinfo;

% 885 973 izq down
% 1090 973 der down

