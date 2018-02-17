%% Globals
clear;
FRAME_SIZE = [480 720];
vidObj = VideoWriter('../test/boss_2.mp4','MPEG-4');
open(vidObj);
start_image = imread('../images/boss_fight_1_end.jpg');
frames_per_image = 4;

%% Ineffective!
textbox = pad_zeros(imresize(imread('../images/bottom_long_textbox.jpg'), 1/8), [FRAME_SIZE, 3], [375, 160]);
not_effective_text = pad_ones(imresize(imread('../images/not_effective_text.jpg'), 1/4)  , [FRAME_SIZE, 3], [385, 170] );
for k = 0:0.1:1
    fading_image = start_image + k*textbox;
    fading_image(not_effective_text<150) = (1-k)*start_image(not_effective_text < 150);
    for n = 1:frames_per_image
        writeVideo(vidObj,uint8(fading_image));
    end
end
%Prolong for a while
for n = 1:30
    writeVideo(vidObj,uint8(fading_image));
end

%% Switch to options/toggle between options/select color adjust
background_textbox = start_image+textbox;

% Options
boss_option1 =  pad_ones(imresize(imread('../images/boss_options_1.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option2 =  pad_ones(imresize(imread('../images/boss_options_2.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option4 =  pad_ones(imresize(imread('../images/boss_options_4.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option_unselected =  pad_ones(imresize(imread('../images/boss_options_blank.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);

% Color options
color_option_blank = pad_ones(imresize(imread('../images/color_blank_text.jpg'), 1/6), [FRAME_SIZE, 3], [385, 170]);
color_option_red = pad_ones(imresize(imread('../images/color_red_text.jpg'), 1/6), [FRAME_SIZE, 3], [385, 170]);
color_option_green = pad_ones(imresize(imread('../images/color_green_text.jpg'), 1/6), [FRAME_SIZE, 3], [385, 170]);
color_option_blue = pad_ones(imresize(imread('../images/color_blue_text.jpg'), 1/6), [FRAME_SIZE, 3], [385, 170]);

% Options images
options_image_1 = background_textbox;
options_image_1(boss_option1<150)  = 0;
options_image_2 = background_textbox;
options_image_2(boss_option2<150) = 0;
options_image_4 = background_textbox;
options_image_4(boss_option4<150) = 0;
options_image_unselected = background_textbox;
options_image_unselected(boss_option_unselected<150) = 0;

% Color options images
color_image_blank = background_textbox;
color_image_blank(color_option_blank<150) = 0;
color_image_red = background_textbox;
color_image_red(color_option_red<150) = 0;
color_image_green = background_textbox;
color_image_green(color_option_green<150) = 0;
color_image_blue = background_textbox;
color_image_blue(color_option_blue<150) = 0;

frames_per_image = 20;
for n = 1:frames_per_image %lowpass
    writeVideo(vidObj,uint8(options_image_1));
end
for n = 1:frames_per_image %highpass
    writeVideo(vidObj,uint8(options_image_2));
end
for n = 1:frames_per_image %lowpass
    writeVideo(vidObj,uint8(options_image_1));
end
for n = 1:frames_per_image %color
    writeVideo(vidObj,uint8(options_image_4));
end
for n = 1:3 % no option selected
    writeVideo(vidObj,uint8(options_image_unselected));
end
for n = 1:10 %color
    writeVideo(vidObj,uint8(options_image_4));
end
for n = 1:10 % only textbox
    writeVideo(vidObj,uint8(background_textbox));
end
for n = 1:frames_per_image %color options red
    writeVideo(vidObj,uint8(color_image_red));
end
for n = 1:frames_per_image %color options green
    writeVideo(vidObj,uint8(color_image_green));
end
for n = 1:frames_per_image %color options blue
    writeVideo(vidObj,uint8(color_image_blue));
end
for n = 1:frames_per_image %color options green
    writeVideo(vidObj,uint8(color_image_green));
end
for n = 1:frames_per_image %color options red
    writeVideo(vidObj,uint8(color_image_red));
end
for n = 1:3 %color options blank
    writeVideo(vidObj,uint8(color_image_blank));
end
for n = 1:10 %color options blue
    writeVideo(vidObj,uint8(color_image_red));
end

%% Titan loses color red
titan_only_orig = imresize(imread('../images/titan.jpg'), FRAME_SIZE);
im_pikachu = pad_zeros(imresize(imread('../images/pikachu_back.jpg'), 1/8), [FRAME_SIZE, 3], [325, 60]);
titan_full_orig = imresize(imread('../images/titan.jpg'), FRAME_SIZE);
im_aura_1 = pad_zeros(imresize(imread('../images/red_aura_cropped.jpg'), 1.5), [FRAME_SIZE, 3], [130, 120]);
im_aura_2 = pad_zeros(imresize(imread('../images/red_aura_cropped.jpg'), 1.5), [FRAME_SIZE, 3], [140, 110]);
extracting_text = pad_ones(imresize(imread('../images/extracting_text.jpg'), 1/6)  , [FRAME_SIZE, 3], [385, 170] );

titan_only_orig = titan_only_orig(1:384, :, :);
old_intensities = uint8(sum(titan_only_orig, 3));
titan_only = titan_only_orig;
toggle = 1;

% For dimming/brightning aura
brightness = [0.2:0.05:0.9, 1:0.05:0.2, 0.2:0.05:0.9, 1:0.05:0.2, 0.2:0.05:0.9, 1:0.05:0.2, 0.2:0.05:0.9, 1:0.05:0.2, 0.2:0.05:0.9, 1:0.05:0.2, 0.2:0.05:0.9, 1:0.05:0.2, 0.35:0.05:0.9];
for k = 0:0.01:1 % for every color loss
    titan_only(:, :, 1) = (1-k)*titan_only_orig(:, :, 1);
    titan_full = titan_full_orig;
    titan_full(1:384, :, :) = titan_only;
    titan_full(im_pikachu ~= 0) = im_pikachu(im_pikachu ~= 0);
    
    if mod(toggle, 10) < 5 %toggle aura position
        titan_full(:, :, 1) = titan_full(:, :, 1)+brightness(toggle)*im_aura_1(:, :, 1);
    else
        titan_full(:, :, 1) = titan_full(:, :, 1)+brightness(toggle)*im_aura_2(:, :, 1);
    end
    titan_full = titan_full + textbox;
    titan_full(extracting_text<150) = 0;
    for n = 1:2
        writeVideo(vidObj,uint8(titan_full));
    end
    toggle = toggle + 1;
end

%% Titan is weakened, attack!
titan_only(:, :, 1) = (1-k)*titan_only_orig(:, :, 1);
titan_full = titan_full_orig;
titan_full(1:384, :, :) = titan_only;
titan_full(im_pikachu ~= 0) = im_pikachu(im_pikachu ~= 0);
titan_full = titan_full + textbox;
weakened_text = pad_ones(imresize(imread('../images/weakened_attack.jpg'), 1/6), [FRAME_SIZE, 3], [385, 170]);
titan_full(weakened_text<150) = 0;
for n = 1:50
        writeVideo(vidObj,uint8(titan_full));
end

%% Dissolve into super sayian mode and return
super_image = imresize(imread('../images/super_pikachu.jpg'), FRAME_SIZE);
TMAX = 10;
im1 = super_image;
im2 = titan_full;
for t = TMAX:-1:0
    frac = t/TMAX;
    pixels = rand(size(im1,1),size(im1,2));
    pixels(pixels<=frac) = 0;
    pixels(pixels>frac) = 1;
    d1 = zeros(size(im1,1),size(im1,2));
    d2 = zeros(size(im1,1),size(im1,2));
    d3 = zeros(size(im1,1),size(im1,2));
    im11 = im1(:,:,1); im12 = im1(:,:,2); im13 = im1(:,:,3);
    im21 = im2(:,:,1); im22 = im2(:,:,2); im23 = im2(:,:,3);
    d1(pixels==1) = im11(pixels==1);
    d1(pixels==0) = im21(pixels==0);
    d2(pixels==1) = im12(pixels==1);
    d2(pixels==0) = im22(pixels==0);
    d3(pixels==1) = im13(pixels==1);
    d3(pixels==0) = im23(pixels==0);
    dissolved = cat(3,d1,d2,d3);
    writeVideo(vidObj,uint8(dissolved));
end
for n = 1:60
        writeVideo(vidObj,uint8(super_image));
end
for n = 1:50
        writeVideo(vidObj,uint8(titan_full));
end

%% Thunder appears
get_wrekt = titan_full;
for t = 15:-1:1
    col = randi([200, 550]);
    row = randi([30, 70]);
    im_lightning = pad_zeros(imresize(imread('../images/lightning.png'),1/2), [FRAME_SIZE, 3], [row, col]);
    get_wrekt (im_lightning ~= 0) = im_lightning(im_lightning ~= 0);
    for n = 1:t
        writeVideo(vidObj,uint8(get_wrekt));
    end
end
for n = 1:15
    writeVideo(vidObj,uint8(get_wrekt));
end
%% Blink titan + thunders in and out
no_titan = titan_full_orig;
no_titan(1:384, :) = 0;

for t = 1:20
    if mod(t, 2) == 0
        for n = 1:2
            writeVideo(vidObj,uint8(get_wrekt));
        end
    else
        for n = 1:2
            writeVideo(vidObj,uint8(no_titan));
        end
    end
end
for n = 1:15
    writeVideo(vidObj,uint8(get_wrekt));
end
%% close video object
imwrite(get_wrekt, '../images/boss_fight_2_end.jpg', 'jpg');
close(vidObj);