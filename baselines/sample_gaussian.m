function [candidates, scores] = sample_gaussian(im, num_samples, truncate)
  if nargin < 3
    truncate = true;
  end
  load('data/pascal_voc07_random_sampling_params.mat');
  
  % we need to reject samples that make no sense, to not totally screw up the
  % distribution
  invalid = true(num_samples, 1);
  features = zeros(num_samples, 4);
  while any(invalid)
    % only resample invalid ones
    t_num_samples = sum(invalid);
    features(invalid,:) = mvnrnd(gaussian_params.mean, gaussian_params.covar, t_num_samples);
    log_aspect_ratio = features(:,1);
    sqrt_relative_scale = features(:,2);
    relative_x = features(:,3);
    relative_y = features(:,4);
    invalid = sqrt_relative_scale <= 0 | sqrt_relative_scale > 1 | ...
      relative_x < 0 | relative_x > 1 | relative_y < 0 | relative_y > 1;
  end
  
  relative_scale = sqrt_relative_scale .^ 2;
  aspect_ratio = 2 .^ log_aspect_ratio;
  
  im_width = size(im, 2);
  im_height = size(im, 1);
  image_area = im_width * im_height;
  box_area = relative_scale .* image_area;
  h = sqrt(box_area ./ aspect_ratio);
  w = box_area ./ h;
  h = max(h, 5);
  w = max(w, 5);
  
  candidates = zeros(num_samples, 4);
  candidates(:,1) = round(relative_x .* im_width - w/2);
  candidates(:,2) = round(relative_y .* im_height - h/2);
  candidates(:,3) = round(candidates(:,1) + w - 1);
  candidates(:,4) = round(candidates(:,2) + h - 1);
  
  if truncate
    offset = max(0, 1 - candidates(:,1));
    candidates(:,1) = candidates(:,1) + offset;
    candidates(:,3) = candidates(:,3) + offset;

    offset = max(0, 1 - candidates(:,2));
    candidates(:,2) = candidates(:,2) + offset;
    candidates(:,4) = candidates(:,4) + offset;

    candidates(:,3) = min(im_width, candidates(:,3));
    candidates(:,4) = min(im_height, candidates(:,4));

    assert(all(candidates(:,1) <= candidates(:,3)));
    assert(all(candidates(:,2) <= candidates(:,4)));
  end
  
  scores = [];
  scores = -1*ones(num_samples, 1, 'single');  
end
