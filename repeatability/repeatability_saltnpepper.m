function [im2, H] = repeatability_saltnpepper(im, n_pixels)
  seed = sum(im(:));
  s = RandStream('mt19937ar', 'Seed', seed);
  
  [h,w,~] = size(im);
  num_missing = n_pixels;
  coords = [];
  while num_missing > 0
    x = randi(s, [1 w], num_missing, 1);
    y = randi(s, [1 h], num_missing, 1);
    coords = unique([coords; [x y]], 'rows');
    num_missing = n_pixels - size(coords, 1);
  end
  
  im2 = im;
  H = eye(3);
  if isempty(coords)
    return;
  end
  
  im_gray = rgb2gray(im);
  coord_inds = sub2ind(size(im_gray), coords(:,2), coords(:,1));
  is_dark = im_gray(coord_inds) < 128;
  chan_stride = h * w;
  for ch = 1:3
    % dark goes bright
    im2(coord_inds(is_dark) + (ch - 1) * chan_stride) = 255;
    % bright goes dark
    im2(coord_inds(~is_dark) + (ch - 1) * chan_stride) = 0;
  end
end
