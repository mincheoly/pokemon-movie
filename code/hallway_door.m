%% Globals
FRAME_SIZE = [480 720];
vidObj = VideoWriter('../videos/hallway_door.mp4','MPEG-4');
open(vidObj);
num_frame = 20;

%% Original Hallway
im_hallway_raw = imread('../images/hallway.jpg');
im_hallway = imresize(im_hallway_raw, FRAME_SIZE);
for n = 1:num_frame
    writeVideo(vidObj,uint8(im_hallway));
end

%% First zoom
im_hallway_zoom1 = imresize(im_hallway_raw(300:1100, 600:1500, :), FRAME_SIZE);
%imagesc(im_hallway_zoom1);
for n = 1:num_frame
    writeVideo(vidObj,uint8(im_hallway_zoom1));
end

%% Second zoom
im_hallway_zoom2 = imresize(im_hallway_zoom1(100:325, 150:400, :), FRAME_SIZE);
% imagesc(im_hallway_zoom2);
for n = 1:num_frame
    writeVideo(vidObj,uint8(im_hallway_zoom2));
end

%% Third zoom
im_hallway_zoom3 = imresize(im_hallway_zoom2(25:300, 125:550, :), FRAME_SIZE);
% imagesc(im_hallway_zoom3);
% axis image;
for n = 1:num_frame
    writeVideo(vidObj,uint8(im_hallway_zoom3));
end
%% Door to hell (morph)
%http://www.scaryforkids.com/truth-about-hell/
im_hell_door = imresize(imread('../images/hell_door.jpg'), FRAME_SIZE);
load 'door_points.mat'; %Grab the points
x=linspace(1,FRAME_SIZE(2),FRAME_SIZE(2));
y=linspace(1,FRAME_SIZE(1),FRAME_SIZE(1));
[xi,yi]=meshgrid(x,y);
displacement_vectors = hallway_door_points-hell_door_points;
shiftx=griddata(hallway_door_points(:,1),hallway_door_points(:,2),displacement_vectors(:, 1),xi,yi,'linear');
shifty=griddata(hallway_door_points(:,1),hallway_door_points(:,2),displacement_vectors(:, 2),xi,yi,'linear');
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
            final(j,i, :) = im_hallway_zoom3(locy(j,i),locx(j,i), :)*(1-frac) + im_hell_door(locyy(j,i),locxx(j,i), :)*frac;
        end
    end

    % Save as movie
    for n = 1:2
        writeVideo(vidObj,uint8(final));
    end
end;

%% Put "woah...." Text (fade in)
textbox = pad_zeros(imresize(imread('../images/bottom_long_textbox.jpg'), 1/8), [FRAME_SIZE, 3], [360, 100]);
woah_text = pad_ones(imresize(imread('../images/woah_text.jpg'), 1/4)  , [FRAME_SIZE, 3], [370, 120] );
for k = 0:0.1:1
    fading_image = im_hell_door + k*textbox;
    fading_image(find(woah_text==0)) = (1-k);
    for n = 1:5
        writeVideo(vidObj,uint8(fading_image));
    end
end

%% Fade out overall
for k = 0:0.1:1
    for n = 1:5
        writeVideo(vidObj,uint8(fading_image*(1-k)));
    end
end

%% close video object
close(vidObj);