%% Prettify function - Make mean of image at 128 and std 80

function pretty_im = island_prettify(im)
    
    avg = mean(mean(im(find(im~=0))));
    std_dev = std(im(find(im~=0)), reshape(im, size(im,1)*size(im,2),1) );
    scale_factor = 80/std_dev;
    pretty_im = round((im-avg)*scale_factor+128);
    pretty_im(find(pretty_im > 255)) = 255;
    pretty_im(find(pretty_im < 0)) = 0;
end