%% Globals
FRAME_SIZE = [480 720];
vidObj = VideoWriter('../test/boss_1.mp4','MPEG-4');
open(vidObj);
frames_per_image = 4;
%Starts with blank (all zeros);

%% Make background from pikachu and titan
background = imresize(imread('../images/titan.jpg'), FRAME_SIZE);
im_pikachu = pad_zeros(imresize(imread('../images/pikachu_back.jpg'), 1/8), [FRAME_SIZE, 3], [325, 60]);
background(find(im_pikachu ~= 0)) = im_pikachu(find(im_pikachu ~= 0));

%% Background flies in/wiggle a bit
angles = [0, 36, 72, 108, 144, 216, 252, 288, 324, 360, 36, 72, 108, 144, 216, 252, 288, 324, 360];
scale = 0:0.055:1;
for index = 1:19
    current_bg = scale(index)*imrotate(background, angles(index), 'crop');
    for n = 1:frames_per_image
        writeVideo(vidObj,uint8(current_bg));
    end
end
wiggle_angles = [10, -19, 8, -7, 6, -6, 4, -3, 2, -1, 1, 0];
for index = 1:12
    current_bg = imrotate(background, wiggle_angles(index), 'crop');
    %imagesc(current_bg);
    for n = 1:frames_per_image
        writeVideo(vidObj,uint8(current_bg));
    end
end
imagesc(background(:, :, 1));
fig = getframe;
toggle = 0;
for n = 1:50
    if toggle == 0
        writeVideo(vidObj,uint8(imresize(fig.cdata, FRAME_SIZE)));
    else
        writeVideo(vidObj,uint8(background));
    end
    if mod(n,2) == 0
        toggle = ~toggle;
    end
end
%% Boss room title (fade in)
textbox = pad_zeros(imresize(imread('../images/bottom_long_textbox.jpg'), 1/8), [FRAME_SIZE, 3], [375, 160]);
boss_intro_text = pad_ones(imresize(imread('../images/boss_stage_text.jpg'), 1/6)  , [FRAME_SIZE, 3], [380, 165] );
for k = 0:0.1:1
    fading_image = background + k*textbox;
    fading_image(boss_intro_text<150) = (1-k)*start_image(boss_intro_text < 150);
    for n = 1:frames_per_image
        writeVideo(vidObj,uint8(fading_image));
    end
end
% Prolong for a while
for n = 1:50
    writeVideo(vidObj,uint8(fading_image));
end

%% Clear text
for n = 1:5
    writeVideo(vidObj,uint8(background+textbox));
end

%% Give Player 4 options/toggle between a few of them
background_textbox = background+textbox;
boss_option1 =  pad_ones(imresize(imread('../images/boss_options_1.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option2 =  pad_ones(imresize(imread('../images/boss_options_2.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option3 =  pad_ones(imresize(imread('../images/boss_options_3.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option_unselected =  pad_ones(imresize(imread('../images/boss_options_blank.jpg'), 1/8), [FRAME_SIZE, 3], [390, 165]);
boss_option_selected =  pad_ones(imresize(imread('../images/low_pass_select.jpg'), 1/3), [FRAME_SIZE, 3], [390, 165]);
options_image_1 = background_textbox;
options_image_1(boss_option1<150)  = 0;
options_image_2 = background_textbox;
options_image_2(boss_option2<150) = 0;
options_image_3 = background_textbox;
options_image_3(boss_option3<150) = 0;
options_image_unselected = background_textbox;
options_image_unselected(boss_option_unselected<150) = 0;
options_image_select = background_textbox;
options_image_select(boss_option_selected<150) = 0;

% Default selection at option 1
frames_per_image = 20;
for n = 1:frames_per_image %lowpass
    writeVideo(vidObj,uint8(options_image_1));
end
for n = 1:frames_per_image %highpass
    writeVideo(vidObj,uint8(options_image_2));
end
for n = 1:frames_per_image %run away
    writeVideo(vidObj,uint8(options_image_3));
end
for n = 1:frames_per_image %high pass
    writeVideo(vidObj,uint8(options_image_2));
end
for n = 1:frames_per_image %lowpass
    writeVideo(vidObj,uint8(options_image_1));
end
for n = 1:3 % no option selected
    writeVideo(vidObj,uint8(options_image_unselected));
end
for n = 1:10 % lowpass for short
    writeVideo(vidObj,uint8(options_image_1));
end
for n = 1:10 % only textbox
    writeVideo(vidObj,uint8(background_textbox));
end
for n = 1:frames_per_image % option selected
    writeVideo(vidObj,uint8(options_image_select));
end

%% Fade out speech bubble
for k = 0:0.1:1
    fading_image = background + (1-k)*textbox;
    fading_image(boss_option_selected < 150) = k*background(boss_option_selected < 150);
    for n = 1:5
        writeVideo(vidObj,uint8(fading_image));
    end
end

%% Perform low pass filter, generate image matrix
titan_only = imresize(imread('../images/titan.jpg'), FRAME_SIZE);
titan_only = titan_only(1:384, :, :);
mask = zeros(384, FRAME_SIZE(2));
mask_width = 300;
mask(round(384/2)-floor(mask_width/2):round(384/2)+floor(mask_width/2), round(FRAME_SIZE(2)/2)-floor(mask_width/2):round(FRAME_SIZE(2)/2)+floor(mask_width/2)) = 1;

% Calculate transforms
titan_F_red = fft2(fftshift(titan_only(:, :, 1)));
titan_F_green = fft2(fftshift(titan_only(:, :, 2)));
titan_F_blue = fft2(fftshift(titan_only(:, :, 3)));

% Filter
filtered_titan_F_red = titan_F_red .* mask;
filtered_titan_F_green = titan_F_green .* mask;
filtered_titan_F_blue = titan_F_blue .* mask;

% Inverse Transforms
filtered_titan_red = fftshift(ifft2(filtered_titan_F_red));
filtered_titan_green = fftshift(ifft2(filtered_titan_F_green));
filtered_titan_blue = fftshift(ifft2(filtered_titan_F_blue));

% Combine
titan_only_lowfreq = zeros(384, FRAME_SIZE(2), 3);
titan_only_lowfreq(:, :, 1) = real(filtered_titan_red);
titan_only_lowfreq(:, :, 2) = real(filtered_titan_green);
titan_only_lowfreq(:, :, 3) = real(filtered_titan_blue);

titan_only_lowfreq = uint8(image_normalize(titan_only_lowfreq, 160, 80, titan_only_lowfreq));

background = imresize(imread('../images/titan.jpg'), FRAME_SIZE);
background(im_pikachu ~= 0) = im_pikachu(im_pikachu ~= 0);
background_lowfreq = background;
background_lowfreq(1:384, :, :) = titan_only_lowfreq;
background_lowfreq(im_pikachu ~= 0) = im_pikachu(im_pikachu ~= 0);

%% Morph from Original to low pass 
load 'bg_points.mat';
x=linspace(1,FRAME_SIZE(2),FRAME_SIZE(2));
y=linspace(1,FRAME_SIZE(1),FRAME_SIZE(1));
[xi,yi]=meshgrid(x,y);
displacement_vectors = bg_points-lowpass_bg_points;
shiftx=griddata(bg_points(:,1),bg_points(:,2),displacement_vectors(:, 1),xi,yi,'linear');
shifty=griddata(bg_points(:,1),bg_points(:,2),displacement_vectors(:, 2),xi,yi,'linear');
shiftx(find(isnan(shiftx)))=0;
shifty(find(isnan(shifty)))=0;
for k=1:11,
    frac=(k-1)/10;
    % get the new locations of the pixels, moving the first image towards the second, and
    % the second towards the first. Clip so that the pixels fit.
    locx = clip(round(xi+shiftx*frac), 1, FRAME_SIZE(2));
    locy = clip(round(yi+shifty*frac), 1, FRAME_SIZE(1));
    locxx = clip(round(xi-shiftx*(1-frac)), 1, FRAME_SIZE(2));
    locyy = clip(round(yi-shifty*(1-frac)), 1, FRAME_SIZE(1));

    % now map the pixels to their new positions and blend
    for i=1:FRAME_SIZE(2)
        for j=1:FRAME_SIZE(1)
            final(j,i, :) = background(locy(j,i),locx(j,i), :)*(1-frac) + background_lowfreq(locyy(j,i),locxx(j,i), :)*frac;
        end
    end

    % Save as movie
    for n = 1:5
        writeVideo(vidObj,uint8(final));
    end
end;

% make it last few seconds
for n = 1:50
        writeVideo(vidObj,uint8(final));
end

%% Bring back to background
x=linspace(1,FRAME_SIZE(2),FRAME_SIZE(2));
y=linspace(1,FRAME_SIZE(1),FRAME_SIZE(1));
[xi,yi]=meshgrid(x,y);
displacement_vectors = lowpass_bg_points - bg_points;
shiftx=griddata(lowpass_bg_points(:,1),lowpass_bg_points(:,2),displacement_vectors(:, 1),xi,yi,'linear');
shifty=griddata(lowpass_bg_points(:,1),lowpass_bg_points(:,2),displacement_vectors(:, 2),xi,yi,'linear');
shiftx(find(isnan(shiftx)))=0;
shifty(find(isnan(shifty)))=0;
for k=1:11,
    frac=(k-1)/10;
    % get the new locations of the pixels, moving the first image towards the second, and
    % the second towards the first. Clip so that the pixels fit.
    locx = clip(round(xi+shiftx*frac), 1, FRAME_SIZE(2));
    locy = clip(round(yi+shifty*frac), 1, FRAME_SIZE(1));
    locxx = clip(round(xi-shiftx*(1-frac)), 1, FRAME_SIZE(2));
    locyy = clip(round(yi-shifty*(1-frac)), 1, FRAME_SIZE(1));

    % now map the pixels to their new positions and blend
    for i=1:FRAME_SIZE(2)
        for j=1:FRAME_SIZE(1)
            final(j,i, :) = background_lowfreq(locy(j,i),locx(j,i), :)*(1-frac) + background(locyy(j,i),locxx(j,i), :)*frac;
        end
    end

    % Save as movie
    for n = 1:5
        writeVideo(vidObj,uint8(final));
    end
end;

% make it last few seconds
for n = 1:50
        writeVideo(vidObj,uint8(final));
end
%% close video object
close(vidObj);
imwrite(background, '../images/boss_fight_1_end.jpg', 'jpg');
