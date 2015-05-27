function plot_detector_wiggle_voc07()

  colormap = [ ...
    83, 136, 173 ; ...
    219, 135, 45 ; ...
    218, 71, 56 ; ...
    135, 130, 174 ; ...
    142, 195, 129 ; ...
    138, 180, 66 ; ...
    223, 200, 51 ; ...
    92, 172, 158 ; ...
    ] ./ 256;

  config = [];
  config(1).name = 'R-CNN';
  config(1).func = @detector_wiggle_rcnn;
  config(1).filename = '/BS/candidate_detections/work/v1/pascal_voc07_test_rcnn_scoremaps-3d.mat';
  config(2).name = 'LM-LLDA';
  config(2).func = @detector_wiggle_rcnn;
  config(2).filename = '/BS/candidate_detections/work/v1/pascal_voc07_test_dpm_scoremaps-3d.mat';
  config(3).name = 'LM-LLDA bboxpred';
  config(3).func = @detector_wiggle_rcnn;
  config(3).filename = '/BS/candidate_detections/work/v1/pascal_voc07_test_dpm_bboxpred_scoremaps-3d.mat';
  config(4).name = 'Fast R-CNN';
  config(4).func = @detector_wiggle_from_iou_score;
  config(4).filename = '/BS/candidate_detections/work/v1/pascal_voc07_test_frcn_iou_score.mat';
  config(5).name = 'Fast R-CNN bboxpred';
  config(5).func = @detector_wiggle_from_iou_score;
  config(5).filename = '/BS/candidate_detections/work/v1/pascal_voc07_test_frcn_regr_iou_score.mat';
  
  autoscale = true;

  bin_edges = 0.2:0.05:1;
  bin_centers = (bin_edges(1:end-1) + bin_edges(2:end)) / 2;
  
  hists = build_histograms(config, bin_edges);
  if autoscale
    hists = autoscale_per_class(hists);
  end
  
  plot_histograms(config, bin_centers, bin_edges, hists.avg_scores, hists.class_avg_scores, colormap);
%   plot_histograms(config, bin_centers, bin_edges, hists.median_scores, hists.class_median_scores, colormap);

%   figure;
%   bar(bin_centers', hists.bin_counts');
%   legend({config.name}, 'Location', 'SouthEast');
  
  if false
    scale_factors = [0.8182    0.8485    0.8864    0.9242    0.9621    1.0000    1.0455    1.0833    1.1288  1.1742    1.2273];
    x = (-5:5) .* 4*227/128;
    y = x;
    ticks = [-5 -2 0 2 5] .* 4*227/128;
    tick_labels = arrayfun(@(t) sprintf('%.0f', t), ticks(:), 'UniformOutput', false);
    method_i = 1;
    n_steps = size(hists.avg_cubes{method_i},1);
    class_cubes = hists.method_class_avg_cubes(method_i,:);
    n_classes = numel(class_cubes);
    % normalize per class
    for c = 1:n_classes
      clims = [min(class_cubes{c}(:)), max(class_cubes{c}(:))];
      class_cubes{c} = (class_cubes{c} - clims(1)) ./ (clims(2) - clims(1));
    end
    cube = nanmean(cat(4, class_cubes{:}), 4);
    
    clims = [min(cube(:)), max(cube(:))];
    
    figure;
    scale_idxs = [1 3 6 9 11];
    for j = 1:numel(scale_idxs), i = scale_idxs(j); % 1:n_steps
      subplot(1,6,j);
      imagesc(x, y, cube(:,:,i), clims);
      set(gca, 'XTick', ticks, 'XTickLabels', tick_labels);
      set(gca, 'YTick', ticks, 'YTickLabels', tick_labels);
      axis square
      title(sprintf('scale %.2f', scale_factors(i)));
    end
    subplot(1,6,6);
    axis off
    cbh = colorbar();
    P = get(cbh, 'Position');
    set(cbh, 'Position', [P(1)-0.01, P(2)+0.1, P(3)+0.01, P(4)-0.2]);
    hei = 3.5; wid = 25;
    set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
    set(gcf, 'PaperPositionMode','auto');
    printpdf('figures/detector_scoremaps_pos_scale_voc07.pdf');
    printpng('figures/detector_scoremaps_pos_scale_voc07.png');

%     figure;
%     for i = 1:n_steps
%       subplot(4,3,i);
%       imagesc(reshape(hists.avg_cubes{method_i}(:,i,:), [n_steps n_steps]), clims);
%       axis equal
%       title(sprintf('x jitter %d', i - floor((n_steps+1)/2)));
%     end
% 
%     figure;
%     for i = 1:n_steps
%       subplot(4,3,i);
%       imagesc(reshape(hists.avg_cubes{method_i}(i,:,:), [n_steps n_steps]), clims);
%       axis equal
%       title(sprintf('y jitter %d', i - floor((n_steps+1)/2)));
%     end
  end
end

function plot_histograms(config, bin_centers, bin_edges, avg_scores, class_avg_scores, colormap)
  ld = load('data/classes.mat');
  classes = ld.classes;
  
  fh_all_classes = figure; hold on;
  for i = 1:numel(config)
    plot(bin_centers, avg_scores(i,:), '.-', 'LineWidth', 1.5, 'Color', colormap(i,:), 'MarkerSize', 20);
  end
  legend({config.name}, 'Location', 'SouthEast');
  xlabel('IoU with GT'); ylabel('detector score');
  xlim([min(bin_edges), max(bin_edges)]);
  hei = 8; wid = 12;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/detector_scoremaps_voc07.pdf');
  
  fh_per_class = figure;
  for c = 1:20
    for i = 1:numel(config)
      figure(fh_per_class); subplot(4,5,c);
      plot(bin_centers, class_avg_scores{c}(i,:), '-o', 'LineWidth', 2, 'Color', colormap(i,:));
      hold on;
      xlim([min(bin_edges), max(bin_edges)]);
      title(classes{c});
    end
  end
end

% function [avg_scores, bin_counts, class_avg_scores, class_bin_counts, avg_cubes] = build_histograms(config, bin_edges)
function hists = build_histograms(config, bin_edges)
  histogram_cache_file = 'data/score_histogram_cache.mat';
  try
    hists = load(histogram_cache_file);
  catch
    n_methods = numel(config);
    n_classes = 20;
    n_bins = numel(bin_edges)-1;
    
    % allocate
    avg_scores = zeros(n_methods, n_bins);
    median_scores = zeros(n_methods, n_bins);
    bin_counts = zeros(n_methods, n_bins);
    class_avg_scores = cell(1, n_classes);
    class_median_scores = cell(1, n_classes);
    class_bin_counts = cell(1, n_classes);
    for c = 1:n_classes
      class_avg_scores{c} = zeros(n_methods, n_bins);
      class_median_scores{c} = zeros(n_methods, n_bins);
      class_bin_counts{c} = zeros(n_methods, n_bins);
    end
    avg_cubes = cell(n_methods,1);
    method_class_avg_cubes = cell(n_methods,n_classes);

    % compute stuff
    for i = 1:n_methods, conf = config(i);
      fprintf('computing %d/%d %s\n', i, numel(config), conf.name);
      [overlap, score, class_ids, avg_cubes{i}, class_avg_cubes] = conf.func(conf.filename);
      if ~isempty(class_avg_cubes)
        method_class_avg_cubes(i,:) = class_avg_cubes;
      end

      [bin_counts(i,:), avg_scores(i,:), median_scores(i,:)] = build_histogram(overlap, score, bin_edges);

      fprintf('per class: ');
      for c = 1:n_classes
        fprintf('%d ', c);
        class_mask = class_ids == c;
        class_overlap = overlap(class_mask);
        class_score = score(class_mask);
        [class_bin_counts{c}(i,:), class_avg_scores{c}(i,:), class_median_scores{c}(i,:)] = build_histogram(class_overlap, class_score, bin_edges);
      end
      fprintf('\n');
    end
    
    save(histogram_cache_file, 'avg_scores', 'median_scores', 'bin_counts', ...
      'class_avg_scores', 'class_median_scores', 'class_bin_counts', ...
      'avg_cubes', 'method_class_avg_cubes');
    hists = load(histogram_cache_file);
  end
end

function [hists] = autoscale_per_class(hists)
  n_classes = 20;
  n_methods = size(hists.avg_scores,1);
  n_bins = size(hists.avg_scores,2);
  
  denom = zeros(n_methods,n_bins);
  hists.avg_scores = zeros(n_methods,n_bins);
  hists.median_scores = zeros(n_methods,n_bins);
  for c = 1:n_classes
    hists.class_avg_scores{c} = autoscale_scores(hists.class_avg_scores{c});
    hists.class_median_scores{c} = autoscale_scores(hists.class_median_scores{c});
    
    hists.avg_scores = hists.avg_scores + hists.class_avg_scores{c} .* hists.class_bin_counts{c};
    hists.median_scores = hists.median_scores + hists.class_median_scores{c} .* hists.class_bin_counts{c};
    denom = denom + hists.class_bin_counts{c};
  end
  hists.avg_scores = hists.avg_scores ./ denom;
  hists.median_scores = hists.median_scores ./ denom;
  assert(all(denom(:) == hists.bin_counts(:)));
end

function scaled_scores = autoscale_scores(avg_scores)
  minscore = min(avg_scores, [], 2);
  maxscore = max(avg_scores, [], 2);
  minscore = repmat(minscore, [1, size(avg_scores, 2)]);
  maxscore = repmat(maxscore, [1, size(avg_scores, 2)]);
  scaled_scores = (avg_scores - minscore) ./ (maxscore - minscore);
end

function [counts, avg_scores, median_scores] = build_histogram(overlap, score, bin_edges)
%     [counts,~,bin_idxs] = histcounts(overlap, bin_edges);
  [counts,bin_idxs] = histc(overlap, bin_edges);
  counts = counts(1:end-1);
    
  n_centers = numel(bin_edges)-1;
  avg_scores = zeros(1, n_centers);
  median_scores = zeros(1, n_centers);
  % average over the elements in each bin
  for j = 1:n_centers
    bin_scores = score(bin_idxs == j);
    if ~isempty(bin_scores)
      avg_scores(j) = mean(bin_scores);
      median_scores(j) = median(bin_scores);
    end
  end
end
