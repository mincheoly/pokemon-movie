function im_stretch = image_normalize(im, new_mean, new_std, im_orig)

% stretchs non-zero parts of image

im_arr = reshape(im, numel(im), 1);
im_orig_arr = reshape(im_orig, numel(im_orig), 1);
im_mean = mean(im_arr(im_orig_arr>0));
im_std = std(im_arr(im_orig_arr>0));

im_stretch = zeros(size(im));
im_stretch(find(im_orig>0)) = (im(im_orig>0) - im_mean)/im_std * new_std + new_mean;
im_stretch(find(im_stretch < 0)) = 0;
im_stretch(find(im_stretch > 255)) = 255;

end