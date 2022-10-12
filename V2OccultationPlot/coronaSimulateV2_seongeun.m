% CORONASIMULATE  Simulate coronagraph and Gerchberg-Saxton algorithm
%
% A simulation of a coronagraph and the Gerchberg-Saxton algorithm, in the
% context of NASA's Roman Space Telescope, developed to help teach ENCMP
% 100 Computer Programming for Engineers at the University of Alberta. The
% program saves data to a MAT file for subsequent evaluation.

%{
    Copyright (c) 2021, University of Alberta
    Electrical and Computer Engineering
    All rights reserved.

    Student name:Kevin Yu
    Student CCID:seongeun
    Others:

    To avoid plagiarism, list the names of persons, other than a lecture
    instructor, whose code, words, ideas, or data were used. To avoid
    cheating, list the names of persons, other than a lab instructor, who
    provided substantial editorial or compositional assistance.

    After each name, including the student's, enter in parentheses an
    estimate of the person's contributions in percent. Without these
    numbers, adding to 100%, follow-up questions may be asked.

    For anonymous sources, enter code names in uppercase, e.g., SAURON,
    followed by percentages as above. Email a list of online sources
    (links suffice) to a teaching assistant before submission.
%}
clear
rng('default')

im = loadImage;
[im,Dphi,mask] = opticalSystem(im,300);
[images,errors] = gerchbergSaxton(im,20,Dphi,mask);

frames = getFrames(images,errors);
save frames frames

% im = loadImage returns an indexed image, im, of an exoplanet (2M1207b)
% orbiting a distant star. The image, a 2D matrix, is downloaded from a
% NASA website. It should be displayed with a grayscale colour map.
function im = loadImage
path = 'https://exoplanets.nasa.gov/system/resources/';
file = 'detail_files/300_26a_big-vlt-s.jpg';
im = imread(strcat(path,file));
im = rgb2gray(im);
end

%function with two input and 3 output arguement. the system determines the
%value of im,Dphi,mask using the value of im and width.the total im is
%calculated using the last statement in the function.
function [im,Dphi,mask] = opticalSystem(im,width)
[im,mask] = occultCircle(im,width);
[IMa,IMp] = dft2(im);
imR = uint8(randi([0 255],size(im)));
[~,Dphi] = dft2(imR);
im = idft2(IMa,IMp-Dphi);

end

% im = occultSquare(im,width) function with two input arguement and two output argument,
%the function determines position of the circl by using the inputed value
%of im. and returns position of the circle to be in the center and the
%width/2 is the total required diameter. We implemented the shape and the
%position by the insertShape function.
function [im,mask] = occultCircle(im,width)
[rows,column] = size(im); %one input of im and two output arguement of rows and column
im = rgb2gray(insertShape(im,'FilledCircle', [column/2 rows/2 width/2],'Color','black','opacity',1)); 
% rgb2gray to remove any additional color and the used insershape function
% to add a filled circle with the position column/2 rows/2 width/2 and the
% color is black and the opacity of the inside of circle is 1 
mask = zeros(rows,column); %assigns mask to the zeros rows,column it implents the 2D

%creation of forloop to inplement every pixel of black to be true and else
%false.
for i = 1:1:column %for the range 1:1:column
    for k = 1:1:rows %for the range of 1:1:rows
        if im(k,i) == 0 %and when im(k,i) == 0 the mask(k,i) is true
            mask(k,i) = 1;
        end %end check
    end %end check
end %end check 
end %end check


% [IMa,IMp] = dft2(im) returns the amplitude, IMa, and phase, IMp, of the
% 2D discrete Fourier transform of an indexed image, im. The image, a 2D
% matrix, is expected to be of class 'uint8'. The phase is in degrees.
function [IMa,IMp] = dft2(im)
IM = fft2(im);
IMa = abs(IM);
IMp = rad2deg(angle(IM));
end

% im = idft2(IMa,IMp) returns an indexed image, im, of class 'uint8' that
% is the inverse 2D discrete Fourier transform (DFT) of a 2D DFT specified
% by its amplitude, IMa, and phase, IMp. The phase must be in degrees.
function im = idft2(IMa,IMp)
IM = IMa.*complex(cosd(IMp),sind(IMp));
im = uint8(ifft2(IM,'symmetric'));
end

% images = gerchbergSaxton(im,maxIters,Dphi)function has four input argument
% while it outputs two arguement. The function correctly corrects the data
% in  im ,with the different stages of maxItters, and exports them as cell
% array. and once its all the done calculation it returns the value in
% errors
function [images,errors] = gerchbergSaxton(im,maxIters,Dphi,mask)
[IMa,IMp] = dft2(im);
images = cell(maxIters+1,1);
errors = zeros(maxIters+1,1); %creation of zero vector for (maxIters+1,1)
for k = 0:maxIters
    fprintf('Iteration %d of %d\n',k,maxIters)
    im = idft2(IMa,IMp+k/maxIters*Dphi); %accounting dor Dphi addition
    images{k+1} = im;
    for y = 1:800 %for the y range to be 1 to 800
        for x = 1:750 %for the x range to be 1 to 750
            if mask(x,y) == 1 %if the following statement is true then run the calculation.
                errors(k+1,1) = errors(k+1,1)+(double(im(x,y)))^2; %general formula to calculate the correct error.
            end
        end
    end
end
end

%frames = getFrames(images) has two input argument also having one output
%argument. Overall usage of this function is too account for each frames of
%the movie. we used an forloop to account for each frames, and change, and
%add things like: color scheme, titles, and delete axis images.
%additionally for version two we added things like xlim ylim to correctly
%set the limit, and calulcated the ratio in order to set the y aspect ratio
%and  y axis direction we then combined the two graph together to show both
%graph in one animation.
function frames = getFrames(images,errors)
numFrames = numel(images);
 xlim = [0 numFrames]; %x limit
 ylim = [max(errors) 0];%y limit
 [xrat,yrat] = size(images{1}); %assigns the m,n to the images
 ratio = [xrat/ylim(1) yrat/xlim(2) 1]; %calculates the ratio using m,n , and xlim ylim
for k = 1:numFrames %reversed the video by changing the order
    image(xlim, ylim,images{k}) %creates a image using xlim for x ylim for y, and images of k
    colormap(gray); %changes the color scale to gray
    title("Coronagraph Simulation") %adds a title to the graph
    set(gca,'DataAspectRatio',ratio)%set the y aspect ratio
    set(gca,'YDir','normal') %y axis direction
    xlabel('Iteration') %x axis labels
    ylabel('Sum Square Error')%y axis labels
    hold on %keeps the graph layouts and all
    plot(0:k-1, errors(1:k),"r-") %plotting the animated line graph in red
    hold off 
    frames(k) = getframe(gcf);
end
close all
end
