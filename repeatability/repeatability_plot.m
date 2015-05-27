function repeatability_plot(method_selection, only_caching, per_method_plot)
% Given the proposals on the repeatability dataset have already been
% extracted and the matching is finished, this function does the evaluation
% of the results and plots them.
%
% The evaluation needs a lot of memory, so watch out. Once the evaluation
% is done, the curve is subsampled and saved to disk, so any further
% plotting is fast and doesn't need so much memory anymore.
%
% method_selection: the methods that you want to evalute and plot
%
% only_caching:     only run the evaluation and save results to disk, don't
%                   do the plotting yet
%
% per_method_plot:  plots more detailed plots

  if nargin < 2
    only_caching = false;
  end
  if nargin < 3
    per_method_plot = false;
  end
  weighted = false;
  methods = get_method_configs();
  if nargin > 0
    methods = methods(method_selection);
  else
    methods([7 9 14 16 19:25]) = [];
  end
  
  load('data/pascal_voc07_test_annotations.mat');
  images = {impos.im};
  
  box_size_bins = 0:0.1:1;
  box_size_bin_centers = (box_size_bins(1:(end-1)) + box_size_bins(2:end)) / 2;
  box_size_bins(1) = -inf;
  box_size_bins(end) = inf;
  num_bins = numel(box_size_bins) - 1;
  exp_config = repeatability_get_config();

  files_missing = false(size(methods));
  method_repeatability = cell(numel(methods), 1);
  for method_i = 1:numel(methods)
    method = methods(method_i);
    fprintf('method: %s\n', method.name);
    try
      load(method.repeatability_matching_file);
    catch
      empties = cell(numel(images), 1);
      matching = struct('scale', empties, 'rotate', empties, 'light', empties, 'jpeg', empties, 'blur', empties, 'saltnpepper', empties);
      for im_i = 1:numel(images)
        [~,img_id,~] = fileparts(images{im_i});
        subdir = img_id(1:5);
        matfile = fullfile(methods(method_i).repeatability_candidate_dir, ...
          subdir, sprintf('%s_matchings.mat', img_id));
  %       fixfile(matfile);
        try
          data = load(matfile);
        catch
          fprintf('couldn''t find file %s\n', matfile);
          files_missing(method_i) = true;
          break;
        end
        matching(im_i) = data.matching;
        clear data;
      end
      if files_missing(method_i)
        continue;
      end
      disp('computing statistics');
      bins = get_bin_statistics(matching, box_size_bins);
      transformations = fieldnames(matching);
      num_transformations = numel(transformations);
      clear matching;

      disp('computing recall curves');
      for trafo_i = 1:num_transformations
        num_params = size(bins{trafo_i}, 2);
        for param_i = 1:num_params
          for bin_i = 1:num_bins
            if numel(bins{trafo_i}(bin_i,param_i).values) > 500
              bins{trafo_i}(bin_i,param_i).values = sort(bins{trafo_i}(bin_i,param_i).values(:)', 'ascend');
              n = numel(bins{trafo_i}(bin_i,param_i).values);
              step_size = n/500;
              bins{trafo_i}(bin_i,param_i).values = bins{trafo_i}(bin_i,param_i).values(round(1:step_size:n));
            end
            [bins{trafo_i}(bin_i,param_i).overlap, bins{trafo_i}(bin_i,param_i).recall, ...
              bins{trafo_i}(bin_i,param_i).area_under_recall] = compute_average_recall_entire_curve(...
              bins{trafo_i}(bin_i,param_i).values);
  %           if trafo_i == 3 && param_i == 7
  %             figure(12); hold on;
  %             dash = '-';
  %             plot(bins{trafo_i}(bin_i,param_i).overlap, bins{trafo_i}(bin_i,param_i).recall, dash, 'Color', cmap(bin_i,:), 'LineWidth', 2);
  % %             title(mat2str(bins{trafo_i}(bin_i,param_i).area_under_recall));
  %           end
          end
        end
      end
      
      save(method.repeatability_matching_file, 'bins', '-v7.3');
    end
    if only_caching
      continue;
    end

    transformations = fieldnames(exp_config);
    num_transformations = numel(transformations);
    
    % remove the stuff that won't be displayed
    for trafo_i = 1:num_transformations
      if isfield(exp_config.(transformations{trafo_i}), 'display_points')
        param_idxs = exp_config.(transformations{trafo_i}).display_points;
        bins{trafo_i} = bins{trafo_i}(:,param_idxs);
      end
    end
    
%     method_bins{method_i} = bins;
    
    for trafo_i = 1:num_transformations
      num_params = size(bins{trafo_i}, 2);
      trafo = transformations{trafo_i};
      trafo_aur_bars = zeros(num_params, numel(box_size_bin_centers));
      trafo_num_boxes_bars = zeros(size(trafo_aur_bars));
      labels = cell(num_params, 1);
      param_vals = zeros(num_params, 1);
      for param_i = 1:num_params
        if isfield(exp_config.(transformations{trafo_i}), 'display_points')
          param_idxs = exp_config.(transformations{trafo_i}).display_points;
        else
          param_idxs = 1:numel(exp_config.(trafo).params);
        end
        if isstruct(exp_config.(trafo).params(param_idxs(param_i)))
          param_val = exp_config.(trafo).params(param_idxs(param_i)).(exp_config.(trafo).display_param);
        else
          param_val = exp_config.(trafo).params(param_idxs(param_i));
        end
        labels{param_i} = sprintf('%f', param_val);
        trafo_num_boxes_bars(param_i,:) = cellfun(@numel, {bins{trafo_i}(:,param_i).values});
        
        trafo_aur_bars(param_i,:) = [bins{trafo_i}(:,param_i).area_under_recall];
        param_vals(param_i) = param_val;
      end
      
      if per_method_plot
        [~,order] = sort(param_vals);
        figure; hold on;
        bar(box_size_bin_centers, trafo_num_boxes_bars(order,:)');
        title(sprintf('%s: number of boxes, %s', method.name, trafo));
        legend(labels(order));

        figure; hold on;
        bar(box_size_bin_centers, trafo_aur_bars(order,:)');
        title(sprintf('%s: area under recall curve, %s', method.name, trafo));
        legend(labels(order), 'Location', 'SouthEast');
      end
      
      if weighted
        weights = trafo_num_boxes_bars ./ repmat(sum(trafo_num_boxes_bars, 2), [1, numel(box_size_bin_centers)]);
        method_repeatability{method_i}.trafo(trafo_i).area_under_recall = sum(trafo_aur_bars .* weights, 2);
      else
        method_repeatability{method_i}.trafo(trafo_i).area_under_recall = mean(trafo_aur_bars, 2);
      end
      method_repeatability{method_i}.trafo(trafo_i).labels = labels;
      method_repeatability{method_i}.trafo(trafo_i).param_vals = param_vals;
      method_repeatability{method_i}.trafo(trafo_i).name = trafo;
    end
  end
  if only_caching
    return;
  end
  
  methods(files_missing) = [];;
  method_repeatability(files_missing) = [];
  
  [~,method_order] = sort([methods.sort_key]);
  methods = methods(method_order);
  method_repeatability = method_repeatability(method_order);
  
  plot_legend(methods);
  printpdf('figures/repeatability_legend.pdf');
  
  transformations = fieldnames(exp_config);
  num_transformations = numel(transformations);
  symbols = {'.', 'o', 's', '*', 'd'};
  if ~per_method_plot
    num_trafo = numel(method_repeatability{1}.trafo);
    for trafo_i = 1:num_trafo
      trafo_config = exp_config.(transformations{trafo_i});
      num_params = numel(method_repeatability{1}.trafo(trafo_i).param_vals);
      areas = zeros(numel(methods), num_params);
      for method_i = 1:numel(methods)
        areas(method_i, :) = method_repeatability{method_i}.trafo(trafo_i).area_under_recall;
        assert(all(method_repeatability{method_i}.trafo(trafo_i).param_vals == method_repeatability{1}.trafo(trafo_i).param_vals));
      end
      figure; hold on; grid on;
      x = method_repeatability{1}.trafo(trafo_i).param_vals;
      if isfield(trafo_config, 'plot_x_transform')
        x = trafo_config.plot_x_transform(x);
      end
      [x, order] = sort(x);
      areas = areas(:,order);
      assert(all(all(areas <= 1)));
      
      plot([trafo_config.id_value trafo_config.id_value], ylim, 'LineStyle','--', 'Color', 'black');
      
      % make some of the markers fatter if they overlap
      if isfield(trafo_config, 'big_dots_for_id') && trafo_config.big_dots_for_id
        marker_sizes = ones(numel(methods), 1) * 80;
        x_pos = trafo_config.id_value;
        for method_i = 1:numel(methods)
          y_pos = areas(method_i,(x == x_pos));
          d = abs(y_pos - areas(1:method_i-1,(x == x_pos)));
          min_size = min(marker_sizes(find(d < 0.05))-8);
          if isempty(min_size)
            min_size = marker_sizes(method_i);
          end
          marker_sizes(method_i) = min_size;
        end
        for method_i = 1:numel(methods)
%            symbols{mod(method_i-1, numel(symbols))+1}, ...
          plot(x_pos, areas(method_i,(x == x_pos)), '.', ...
            'LineWidth', 1.5, ...
            'MarkerSize', marker_sizes(method_i), ...
            'Color', methods(method_i).color);
        end
      end
      
      plot_handles = zeros(numel(methods),1);
      for method_i = 1:numel(methods)
        line_style = '-';
        if methods(method_i).is_baseline
          line_style = '--';
        end
        plot_handles(method_i) = plot(x, areas(method_i,:)', '.', ...
          'LineWidth', 1.5, 'MarkerSize', 10, ...
          'Color', methods(method_i).color, 'LineStyle', line_style);
      end
%       if isfield(trafo_config, 'legend_location')
%         legend_labels = cell(numel(methods), 1);
%         for method_i = 1:numel(methods)
%           legend_labels{method_i} = methods(method_i).(trafo_config.name_version);
%         end
%         [lgnd,hObj] = legend(plot_handles, legend_labels, ...
%           'Location', trafo_config.legend_location);
% %         legendshrink(0.5);
%         legend boxoff;
%         if isfield(trafo_config, 'legend_offset')
%           lpos = get(lgnd, 'pos');
%           lpos = lpos + trafo_config.legend_offset;
%           set(lgnd, 'pos', lpos);
%         end
%       end
%       legend({methods.name});
%       title(method_repeatability{1}.trafo(trafo_i).name);
      ylabel('repeatability');
      xlabel(trafo_config.xlabel);
      
      left = min(x);
      right = max(x);
      if left == trafo_config.id_value
        left = left - 0.2;
      end
      if right == trafo_config.id_value
        right = right * 1.08;
      end
      xlim([left, right]);
      ylim([0.1 1.01]);
      
      if isfield(trafo_config, 'xticks')
        xticks = trafo_config.xticks;
        xticklabels = trafo_config.xticklabels;
        set(gca, 'XTick', xticks);
        set(gca, 'XTickLabel', xticklabels);
      end
      if isfield(trafo_config, 'xreverse') && trafo_config.xreverse
        set(gca,'XDir','reverse');
      end
      
      hei = 10;
      wid = 10;
      set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
      set(gcf, 'PaperPositionMode','auto');
      printpdf(sprintf('figures/repeatability_%s.pdf', transformations{trafo_i}));
    end
  end
  
%   save('repeatability_method_bins.mat', 'method_bins');
end




function [bins] = get_bin_statistics(matchings, box_size_bins)
  num_imgs = numel(matchings);
  num_bins = numel(box_size_bins) - 1;
%   bins = [];
%   bins(num_bins,5).values = [];
%   bins(num_bins).count = 0;
%   matchings = matchings_info.matchings;
  
  transformations = fieldnames(matchings);
  num_transformations = numel(transformations);
  bins = cell(num_transformations,1);
  for trafo_i = 1:num_transformations
    transformation_field = matchings(1).(transformations{trafo_i});
    num_params = numel(transformation_field);
    bins{trafo_i}(num_bins,num_params).values = [];
    for param_i = 1:num_params
      for bin_i = 1:num_bins
        bins{trafo_i}(bin_i,param_i).values_per_im = cell(num_imgs,1);
      end
    end
  end
  
  for im_i = 1:num_imgs
    for trafo_i = 1:num_transformations
      transformation_field = matchings(im_i).(transformations{trafo_i});
      num_params = numel(transformation_field);
      for param_i = 1:num_params
        ious = transformation_field(param_i).iou;
        if isempty(ious)
          continue;
        end
        boxes = transformation_field(param_i).reference_boxes;
        if isempty(boxes)
          continue
        end
        im_size = transformation_field(param_i).ref_im_size;
        w = boxes(:,3) - boxes(:,1) + 1;
        h = boxes(:,4) - boxes(:,2) + 1;
        areas = sqrt(w .* h ./ prod(im_size));
        [~,arg_hist] = histc(areas, box_size_bins);
        assert(sum(arg_hist == 0) == 0);
        assert(min(arg_hist) >= 1);
        assert(max(arg_hist) <= numel(box_size_bins) - 1);
        for bin_i = 1:num_bins
          bins{trafo_i}(bin_i,param_i).values_per_im{im_i} = ious(arg_hist == bin_i);
%           bins{trafo_i}(bin_i,param_i).values = ...
%             [bins{trafo_i}(bin_i,param_i).values; ious(arg_hist == bin_i)];
  %           bins(bin_i).count = bins(bin_i).count + sum(arg_hist == bin_i);
        end
      end
    end
  end
  
  for trafo_i = 1:num_transformations
    transformation_field = matchings(im_i).(transformations{trafo_i});
    num_params = numel(transformation_field);
    for param_i = 1:num_params
      for bin_i = 1:num_bins
        bins{trafo_i}(bin_i,param_i).values = cat(1, bins{trafo_i}(bin_i,param_i).values_per_im{:});
        bins{trafo_i}(bin_i,param_i).values_per_im = [];
      end
    end
  end
  
end


function [overlap, recall, area] = compute_average_recall_entire_curve(unsorted_overlaps)
  overlap = sort(unsorted_overlaps(:)', 'ascend');
  num_pos = numel(overlap);
  if max(overlap) < 1
    overlap = [0, overlap, max(overlap)+0.001];
    recall = [1, (num_pos:-1:1)/num_pos, 0];
  else
    overlap = [0, overlap];
    recall = [1, (num_pos:-1:1)/num_pos];
  end
  
  dx = overlap(2:end) - overlap(1:end-1);
  y = (recall(1:end-1) + recall(2:end)) / 2;
  area = sum(dx .* y);
end
