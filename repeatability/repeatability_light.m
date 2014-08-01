function [im2, H] = repeatability_light(im, light_percent)
 
    tmp_filename = tempname();
    tmp_in_filename = [tmp_filename '.in.png'];
    tmp_out_filename = [tmp_filename '.out.png'];
    imwrite(im, tmp_in_filename, 'png');
    system(sprintf('convert "%s" -set option:modulate:colorspace hsb -modulate %f "%s"', ...
      tmp_in_filename, light_percent, tmp_out_filename));
    im2 = imread(tmp_out_filename);
    if size(im2,3) == 1
      im2 = repmat(im2, [1 1 3]);
    end
    assert(all(size(im) == size(im2)));
    delete(tmp_in_filename);
    delete(tmp_out_filename);
  
  H = eye(3);
end
