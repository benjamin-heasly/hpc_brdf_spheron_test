% register two images (render and photo) using intensity-based registration

% Author @gizem
% based on the example from: http://www.mathworks.com/help/images/examples/registering-multimodal-mri-images.html
% 2/25/2015
function register_result = register_images(percent_gloss)
% before doinf this make sure to run sample_render.m
% example function call:
% register_result = register_images('DSC_0102_40gloss.pgm', 'sample_render.pgm', 40)
% variables:
% photoname: string, filename for .pgm photo
% rendername: string, filename for saved render output in .pgm format (get this from renderIm.m)
% percent_gloss: % gloss of the object in the photo
% the rendered image should have a similar look to the photo, but what we
% actually care about is the location and scale, so the render should have
% locx=0, locy=0 and scalex = 2.2 () 

% the photos are linearized by dcraw -4 -d -v -w -b 2.0 filename.NEF
% so they were made twice as bright

% load images, adjust image types so they match
% pgm_name = [int2str(percent_gloss),'gloss.pgm'];
pgm_name = ['gloss',int2str(percent_gloss),'v2.pgm'];
photoname = strcat('/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/pgms_spray/',pgm_name);
glossIm = imread(photoname,'pgm');
% black = imread('DSC_0112.pgm')';
% imdiff = gloss-black;
% for 0percent we need to rotate and then flip the image
B = imrotate(glossIm, -90);
C = flip(B,2);
glossIm = C;
rescaledIm = double(glossIm)/65535;
photo = imresize(rescaledIm, [1005,668]);

sample_name = ['sample_render', int2str(percent_gloss),'.mat'];
imname = strcat('/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/sample_renders/', sample_name);
load(imname, 'imtosave');
renderedIm = imtosave;
% image2 = imread(rendername,'pgm');
% renderedIm = double(image2)/255;

%% 
figure, imshowpair(photo, renderedIm, 'montage')
title('Unregistered')

%% overlapping version
figure, imshowpair(photo, renderedIm);
title('Unregistered');
% green and magenta show places where one image is brigther than the other
% gray areas have similar intensities

%% Registration bit
% makes it easy to pick the correct optimizer and metric configuration
% these two images have different intensity distributions, which suggests a
% multimodal configuration
[optimizer,metric] = imregconfig('multimodal');

% renderRegisteredDefault = imregister(photo, renderedIm, 'affine', optimizer, metric);
% figure, imshowpair(renderRegisteredDefault, renderedIm)
% title('A: Default registration')

%% Adjust initial radius to improve the fit
optimizer.InitialRadius = optimizer.InitialRadius/15;
optimizer.MaximumIterations = 2000;

renderRegisteredAdjusted = imregister(photo2, renderedIm, 'affine', optimizer, metric);
figure, imshowpair(renderRegisteredAdjusted, renderedIm);
title('Adjusted InitialRadius');
%%
registered_photoname = ['registered', int2str(percent_gloss),'v2.mat'];
imname = strcat('/Local/Users/gizem/Documents/Research/GlossBump/Gloss_Level_Sphere_Photos/registered_imgs_translation_spray/', registered_photoname);
save(imname, 'renderRegisteredAdjusted');
register_result = renderRegisteredAdjusted;


