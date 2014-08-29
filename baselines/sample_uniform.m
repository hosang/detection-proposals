function [candidates, scores] = sample_uniform(im, num_samples, truncate)
  if nargin < 3
    truncate = true;
  end
  load('data/pascal_voc07_random_sampling_params.mat');
  
  mid_x = random('Uniform', ...
    uniform_params.relative_x.min, uniform_params.relative_x.max, ...
    [num_samples, 1]);
  mid_y = random('Uniform', ...
    uniform_params.relative_y.min, uniform_params.relative_y.max, ...
    [num_samples, 1]);
  relative_scale = random('Uniform', ...
    sqrt(uniform_params.relative_scale.min), sqrt(uniform_params.relative_scale.max), ...
    [num_samples, 1]) .^ 2;
  aspect_ratio = 2 .^ random('Uniform', ...
    log2(uniform_params.aspect_ratio.min), log2(uniform_params.aspect_ratio.max), ...
    [num_samples, 1]);
  % aspect ratio = w/h
  im_width = size(im, 2);
  im_height = size(im, 1);
  image_area = im_width * im_height;
  box_area = relative_scale .* image_area;
  h = sqrt(box_area ./ aspect_ratio);
  w = box_area ./ h;
  candidates = zeros(num_samples, 4);
  candidates(:,1) = round(mid_x .* im_width - w/2);
  candidates(:,2) = round(mid_y .* im_height - h/2);
  candidates(:,3) = round(candidates(:,1) + w - 1);
  candidates(:,4) = round(candidates(:,2) + h - 1);
  
  if truncate
    candidates(:,1) = max(1, candidates(:,1));
    candidates(:,2) = max(1, candidates(:,2));
    candidates(:,3) = min(im_width, candidates(:,3));
    candidates(:,4) = min(im_height, candidates(:,4));
  end
  
  scores = [];
  scores = -1*ones(num_samples, 1, 'single');
end
