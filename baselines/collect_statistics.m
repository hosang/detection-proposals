function collect_statistics()
% Estimate the parameters for the uniform and gaussian random sampling
% baselines.
%
% Parameters are estimated on the training set and saved in a mat file.
  load('data/pascal_voc07_trainval_annotations.mat');
  
  uniform_params = [];
  [ar] = get_aspect_ratio(pos);
  uniform_params.aspect_ratio = select_uniform_parameters(ar);
  figure; hist(log2(ar), 100); xlabel('log(aspect ratio)');
  hold on;
  plot(log2([uniform_params.aspect_ratio.min uniform_params.aspect_ratio.max]), ...
    [100 100], 'r', 'LineWidth', 2);
  
  [areas, relative_scale] = get_scales(pos);
  uniform_params.relative_scale = select_uniform_parameters(relative_scale);
  figure; hist(sqrt(areas), 100); xlabel('sqrt(annotation area)');
  figure; hist(sqrt(relative_scale), 100); xlabel('sqrt(relative annotation area)');
  hold on;
  plot(sqrt([uniform_params.relative_scale.min uniform_params.relative_scale.max]), ...
    [100 100], 'r', 'LineWidth', 2);
  
  [relative_x, relative_y] = get_positions(pos);
  uniform_params.relative_x = select_uniform_parameters(relative_x);
  uniform_params.relative_y = select_uniform_parameters(relative_y);
  figure; hist(relative_x, 100); xlabel('relative x position');
  hold on;
  plot([uniform_params.relative_x.min uniform_params.relative_x.max], ...
    [100 100], 'r', 'LineWidth', 2);
  figure; hist(relative_y, 100); xlabel('relative y position');
  hold on;
  plot([uniform_params.relative_y.min uniform_params.relative_y.max], ...
    [100 100], 'r', 'LineWidth', 2);
  
  gaussian_params = [];
  [gaussian_params.mean, gaussian_params.covar] = estimate_multivariate_gaussian( ...
    [log2(ar)', sqrt(relative_scale)', relative_x', relative_y']);
  gaussian_params.dimensions = {'log2(aspect ratio)', ...
    'sqrt(relative scale)', 'relative_x', 'relative_y'};
  
  save('data/pascal_voc07_random_sampling_params.mat', 'uniform_params', 'gaussian_params');
end


function [param] = select_uniform_parameters(values)
  coverage = 0.99; % cover 99% of the data
  
  param = [];
  values = sort(values);
  n = numel(values);
  fraction = (1 - coverage) / 2;
  param.min = values(round(fraction * n));
  param.max = values(round((1 - fraction) * n));
end


function [mean_val, covar] = estimate_multivariate_gaussian(values)
% values: one columns is one 'feature' like x position, rows are different
% data points
  mean_val = mean(values, 1);
  covar = cov(values);
end


function pos = add_image_sizes(pos, image_sizes)
  images = unique({pos.im});
  img_ids = {image_sizes.img_id};
  pos(1).img_area = [];
  pos(1).img_size = [];
  for i = 1:numel(images)
    [~,img_id,~] = fileparts(images{i});
    mask = strcmp(img_ids, img_id);
    assert(sum(mask) == 1);
    img_size = image_sizes(mask).size;
    img_area = prod(img_size);
    
    this_image_idxs = find(strcmp({pos.im}, images{i}));
    for idx = this_image_idxs(:)'
      pos(idx).img_area = img_area;
      pos(idx).img_size = img_size;
    end
  end
end

function [ar] = get_aspect_ratio(pos)
  w = [pos.x2] - [pos.x1] + 1;
  h = [pos.y2] - [pos.y1] + 1;
  ar = w ./ h;
end

function [areas, relative_scale] = get_scales(pos)
  w = [pos.x2] - [pos.x1] + 1;
  h = [pos.y2] - [pos.y1] + 1;
  areas = w .* h;
  relative_scale = areas ./ [pos.img_area];
end

function [relative_x, relative_y] = get_positions(pos)
  mid_x = ([pos.x1] + [pos.x2]) / 2;
  mid_y = ([pos.y1] + [pos.y2]) / 2;
  sizes = reshape([pos.img_size], 2, numel(pos))';
  relative_x = mid_x ./ sizes(:,1)';
  relative_y = mid_y ./ sizes(:,2)';
end
