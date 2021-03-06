%Hand-picked Selection Code
%Sibgrapi 2018
%Natalia_Bruno_Eduardo


%{
Information about this version: the algorithm receives 3 images as
input; then, an output image is generated with the 3 input images. 
The action map construction considers only the pixel value.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the code reads the 3 chosen images in format PNG and places them in a
cell called 'im_init'.

These 3 images should be chosen manually and must be placed in the same
directory as this code.

*Note that you must edit the image names below before running the code.
%}

image1 = imread('*Complete with image1 name.png*');
image2 = imread('*Complete with image2 name.png*');
image3 = imread('*Complete with image3 name.png*');

im_init = {image1, image2, image3};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, some parameters are defined for the code.
%}

% f = number of input images
f = length(im_init);

% k = number of layers for the image Laplacian pyramids
% A recommended value for k is 6.
k = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, all input images are converted from RGB format to YCbCr format.
%}

YCbCr = cell(1,f);
for (count=1 : 1 : f)
    YCbCr{count} = rgb2ycbcr(im_init{count});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the cell containing the YCbCr images are decomposed in 3 others cells,
each of them representing the Y, the Cb and the Cr layers.
%}

Y = cell(1,f);
Cb = cell(1,f);
Cr = cell(1,f);
for (count=1 : 1 : f)
    [Y{count}, Cb{count}, Cr{count}] = decomposeYCbCr(YCbCr{count});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, all input images are converted from unit8 to double format.
Also, pixel values are placed in an interval of 0 to 1.
%}

for (count=1 : 1 : f)
    Y{count} = double(Y{count})/255;
    Cb{count} = double(Cb{count})/255;
    Cr{count} = double(Cr{count})/255;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the output pyramid cells (Y, Cb and Cr layers) are defined.
%}

p_out_Y = cell (1, k);
p_out_Cb = cell (1, k);
p_out_Cr = cell (1, k);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, all input images go through the process of Laplacian pyramid
decomposition in k levels.
%}

Y_pyr = cell(1,f);
Cb_pyr = cell(1,f);
Cr_pyr = cell(1,f);

for (count=1 : 1 : f)
    Y_pyr{count} = genPyr(Y{count}, 'laplace', k);
    Cb_pyr{count} = genPyr(Cb{count}, 'laplace', k);
    Cr_pyr{count} = genPyr(Cr{count}, 'laplace', k);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the action map is created and defined.
*Note that this process is done only for pyramid Y.
%}

act = cell(1,f);
for (count=1 : 1 : f)
    act{count} = actionMap(Y_pyr{count});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the decision map is created and defined.
%}

dec_map = cell(1,k);
dec_map = pixelDecision(act,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the final version of the output pyramids is elaborated accordingly to
the decision map.
%}

for (c=1 : 1 : k)
    if (c == k)
        p_out_Y{c} = Y_pyr{1}{c};
        p_out_Cb{c} = Cb_pyr{1}{c};
        p_out_Cr{c} = Cr_pyr{1}{c};
    else
        [m, n] = size(dec_map{c});
        for (q=1 : 1 : f)
            for (i=1 : 1 : m)
                for (j=1 : 1 : n)
                    if (dec_map{c}(i,j) == q)
                        p_out_Y{c}(i,j) = Y_pyr{q}{c}(i,j);
                        p_out_Cb{c}(i,j) = Cb_pyr{q}{c}(i,j);
                        p_out_Cr{c}(i,j) = Cr_pyr{q}{c}(i,j);
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the output image is reconstructed based on the output pyramids.
The output image is called 'final_image_rgb' and is shown as a figure.
%}

[im_final_Y] = pyrReconstruct(p_out_Y);
[im_final_Cb] = pyrReconstruct(p_out_Cb);
[im_final_Cr] = pyrReconstruct(p_out_Cr);


final_image_ycbcr = cat(3, im_final_Y, im_final_Cb, im_final_Cr);

final_image_rgb = ycbcr2rgb(final_image_ycbcr);

figure(1); imshow(final_image_rgb)
