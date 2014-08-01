function [im2, H] = repeatability_blur(im, sigma)
  hsize = ceil(20 * sigma);
  if sigma == 0 || hsize < 3
    im2 = im;
  else
    filter = fspecial('gaussian', hsize, sigma);
    im2 = imfilter(im, filter, 'symmetric', 'same');
  end
  H = eye(3);
end
