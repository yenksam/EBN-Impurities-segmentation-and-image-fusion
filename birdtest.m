close all; clear; clc

sample_no = 27;

% Load images
cir = imread(sprintf('M%d.png',sample_no)); % read circle mask
cir = double(rgb2gray(cir))/255; 
cir = imbinarize(cir,0.05);
cir = cat(3,-cir,cir,-cir); % circle mask

ref = imread(sprintf('W%d.png',sample_no)); % read reference image (white)
ref = double(ref)/255;
ref = ref + cir; % marked by circle mask to show impurities first found by human 

blu = imread(sprintf('B%d.png',sample_no)); % read blue image
b = double(blu)/255;
b = imadjust(rgb2gray(b)); % grayscale of blue image

red = imread(sprintf('R%d.png',sample_no)); % read red image
r = double(red)/255;
r = imadjust(rgb2gray(r)); % grayscale of red image

% EBN determination
mag = blu + red; % fuse red & blue image to get magenta image
ebn_gry = imfilter(double(rgb2gray(mag))/255,fspecial('average',3)); % grayscale of magenta image

hsv = rgb2hsv(mag);
sat = imadjust(hsv(:,:,2).^0.5); % saturation-channel of magenta image
sav = imfilter(sat,fspecial('average',3));
ebn = sav > 0.5; % EBN binary, foreground = EBN

% Intensity distribution for grayscale of magenta image
[Y,E] = discretize(ebn_gry(:),100);
gry_y = zeros(length(E)-1,1);
for i = min(Y):max(Y)
    gry_y(i) = sum(Y == i);
end
gry_x = (E(1:(end-1)) + E(2:end))'/2; 

% Intensity distribution for saturation channel of magenta image
[Y,E] = discretize(sav(:),100);
sat_y = zeros(length(E)-1,1);
for i = min(Y):max(Y)
    sat_y(i) = sum(Y == i);
end
sat_x = (E(1:(end-1)) + E(2:end))'/2; 

% Impurities determination
super_gry = b + r; % fuse grayscale of red & blue image to get a grayscale image
imp = (super_gry < 0.3) & ebn; % Impurities binary, foreground = impurities

% Total segmentation (black = impurities, dark gray = EBN, light gray = background)
seg = 0.8*ones(size(ebn)) - 0.4*double(ebn) - 0.4*double(imp);

i1 = cat(3,imp,-imp,-imp) + cir + ref; % reference image (red = impurities by algorithm, green circle = impurities by human)
i2 = cat(3,ebn,-ebn,-ebn) + cir + ref; % reference image (red = ebn, green circle = impurities by human)

figure, 
subplot(2,3,1), plot(gry_x,gry_y,'r',sat_x,sat_y,'b') % Plot intensity distribution curves
subplot(2,3,2), imshow(mag)
subplot(2,3,3), imshow(super_gry)
subplot(2,3,4), imshow(seg)
subplot(2,3,5), imshow(i1)
subplot(2,3,6), imshow(i2)

% imwrite(mag,'magenta.png')
% imwrite(super_gry,'super gray.png')
% imwrite(seg,'segmentation.png')
% imwrite(i1,'reference.png')

