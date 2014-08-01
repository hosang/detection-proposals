function [im, H] = repeatability_scale(im, scale_factor)
  im = imresize(im, scale_factor);
  H = eye(3);
  H(1,1) = scale_factor;
  H(2,2) = scale_factor;
  % because indices are 1 based:
  H(1,3) = -scale_factor + 1;
  H(2,3) = -scale_factor + 1;
end
