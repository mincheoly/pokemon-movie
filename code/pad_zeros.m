function [ padded_image ] = pad_zeros( input_image, new_dimensions, upper_left_corner)
    padded_image = zeros(new_dimensions);
    padded_image(upper_left_corner(1):upper_left_corner(1)+size(input_image, 1)-1, upper_left_corner(2):upper_left_corner(2)+size(input_image, 2)-1, :) = input_image;
    padded_image = uint8(padded_image);
end

