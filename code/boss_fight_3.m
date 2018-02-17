%% Globals
clear;
FRAME_SIZE = [480 720];
vidObj = VideoWriter('../test/boss_3.mp4','MPEG-4');
open(vidObj);
start_image = imread('../images/boss_fight_2_end.jpg');
frames_per_image = 4;

%% Blank out text
weakened_text = pad_ones(imresize(imread('../images/weakened_attack.jpg'), 1/6), [FRAME_SIZE, 3], [385, 170]);
im_blank_text_image = start_image;
for n = 1:10
        writeVideo(vidObj,uint8(im_blank_text_image));
end


%% Generate door image
titan_wall = imresize(imread('../images/titan.jpg'), FRAME_SIZE);
night_sky = imresize(imread('../images/night_sky.jpg'), [384, FRAME_SIZE(2)]);
titan_wall(1:384, :, :) = night_sky;
im_pikachu = pad_zeros(imresize(imread('../images/pikachu_back.jpg'), 1/8), [FRAME_SIZE, 3], [325, 60]);
im_door = pad_zeros(imresize(imread('../images/ending_door.jpg'), 1/22), [FRAME_SIZE, 3], [50, 300]);
titan_wall(im_pikachu ~= 0) = im_pikachu(im_pikachu ~= 0);
titan_wall(im_door ~= 0) = im_door(im_door ~= 0);

%% morph into door image
load 'ending_door_points.mat';

x=linspace(1,FRAME_SIZE(2),FRAME_SIZE(2));
y=linspace(1,FRAME_SIZE(1),FRAME_SIZE(1));
[xi,yi]=meshgrid(x,y);
displacement_vectors = titan_points-door_points;
shiftx=griddata(titan_points(:,1),titan_points(:,2),displacement_vectors(:, 1),xi,yi,'linear');
shifty=griddata(titan_points(:,1),titan_points(:,2),displacement_vectors(:, 2),xi,yi,'linear');
shiftx(find(isnan(shiftx)))=0;
shifty(find(isnan(shifty)))=0;
for k=1:11
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
            final(j,i, :) = im_blank_text_image(locy(j,i),locx(j,i), :)*(1-frac) + titan_wall(locyy(j,i),locxx(j,i), :)*frac;
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

%% Congratz message fade in
textbox = pad_zeros(imresize(imread('../images/bottom_long_textbox.jpg'), 1/8), [FRAME_SIZE, 3], [375, 160]);
congrats_text = pad_ones(imresize(imread('../images/congrats_text.jpg'), 1/6)  , [FRAME_SIZE, 3], [385, 175] );
for k = 0:0.1:1
    fading_image = titan_wall + k*textbox;
    fading_image(congrats_text<150) = (1-k)*start_image(congrats_text < 150);
    for n = 1:frames_per_image
        writeVideo(vidObj,uint8(fading_image));
    end
end
% Prolong for a while
for n = 1:70
    writeVideo(vidObj,uint8(fading_image));
end

%% White everything out
for k=1:0.2:8
    for n = 1:3
        writeVideo(vidObj,uint8(30*k+fading_image));
    end
end

%% focus into prof zebkar
im_prof = imresize(imread('../images/prof_zebker.jpg'), FRAME_SIZE);
for k=8:-0.2:1
    for n = 1:3
        writeVideo(vidObj,uint8(30*k+im_prof));
    end
end
for n = 1:50
        writeVideo(vidObj,uint8(im_prof));
end
%% Thank you for watching
thank_you_text = pad_zeros(imresize(imread('../images/thank_you.jpg'), 1/3)  , [FRAME_SIZE, 3], [100, 70] );
for k=0:0.05:1
    for n = 1:5
        writeVideo(vidObj,uint8(k*thank_you_text));
    end
end

for n = 1:100
    writeVideo(vidObj,uint8(thank_you_text));
end
%% close video object
close(vidObj);