function plot_overlap_recall_curve(iou_files, methods, num_candidates, fh, ...
  names_in_plot, legend_location, use_long_labels, custom_legend)
  
  if nargin < 7
    use_long_labels = false;
  end
  if nargin < 8
    custom_legend = [];
  end
  
  [~,method_order] = sort([methods.sort_key]);
  methods = methods(method_order);
  iou_files = iou_files(method_order);
  if ~isempty(custom_legend)
    custom_legend = custom_legend(method_order);
  end
  
  labels = {methods.short_name};
  long_labels = {methods.name};
  assert(numel(iou_files) == numel(labels));
  n = numel(iou_files);

  num_pos = zeros(n, 1);
  
  figure(fh);
  for i = 1:n
    data = load(iou_files{i});
    thresh_idx = find( ...
      [data.best_candidates.candidates_threshold] <= num_candidates, 1, 'last');
    experiment = data.best_candidates(thresh_idx);
    [overlaps, recall, auc] = compute_average_recall(experiment.best_candidates.iou);
    
    display_auc = auc * 100;
    % round to first decimal
    display_auc = round(display_auc * 10) / 10;
    display_num_candidates = mean([experiment.image_statistics.num_candidates]);
    display_num_candidates = round(display_num_candidates * 10) / 10;
    number_str = sprintf('%g (%g)', display_auc, display_num_candidates);
    if names_in_plot
      labels{i} = sprintf('%s %s', labels{i}, number_str);
      long_labels{i} = sprintf('%s %s', long_labels{i}, number_str);
    else
      labels{i} = number_str;
      long_labels{i} = number_str;
    end
    num_pos(i) = numel(overlaps);
    line_style = '-';
    if methods(i).is_baseline
      line_style = '--';
    end
    if ~isempty(methods(i).line_style)
      line_style = methods(i).line_style;
    end
    plot(overlaps, recall, 'Color', methods(i).color, 'LineWidth', 1.5, 'LineStyle', line_style);
    hold on;
  end
  grid on;
  xlabel('IoU overlap threshold');
  ylabel('recall');
  xlim([0.5, 1]);
  ylim([0, 1]);
  if ~strcmp(legend_location, 'none')
    if ~isempty(custom_legend)
      lgnd = legend(custom_legend, 'Location', legend_location);
    elseif use_long_labels
      lgnd = legend(long_labels, 'Location', legend_location);
    else
      lgnd = legend(labels, 'Location', legend_location);
    end
  %   set(lgnd, 'color','none');
  %   legendshrink(0.5);
    legend boxoff;
  end
end
