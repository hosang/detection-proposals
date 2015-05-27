function plot_correlation_edge_boxes()
% Plots for analyzing the correlation between detector performance
% (R-CNN) on the different variants of EdgeBoxes.
% Also plots the recall curves for all the variants.
%
% Bonus feature: Rainbow colormap! Hand-tuned nice colors on the curve!

  methods = get_method_configs();
 
  IoUs = 0.5:0.05:0.9;
  custom_names = arrayfun(@(x) sprintf('%.2f', x), IoUs, 'UniformOutput', false);
  custom_names = [custom_names {'AR'}];
  
  % select all edge box variants
  method_selection = [13 14 16 19 20:25];
  n_methods = numel(method_selection);
  [~,order] = sort({methods(method_selection).short_name});
  method_selection = method_selection(order);
  methods = methods(method_selection);
  for i = 1:numel(methods)
    methods(i).sort_key = i;
  end

  % Recall matrix used for experiments nThresholds x nAlgorithms
  ld = load('data/pascal_voc07_test_recall.mat');
  R = ld.recalls(method_selection,:)';
  ARs = ld.ARs(method_selection)';

  T = ld.iou_thresholds;

  ld = load('data/pascal_voc07_test_rcnn_aps.mat');
  rcnn_AP = ld.aps(method_selection);
  ld = load('data/pascal_voc07_test_frcn_aps.mat');
  frcn_AP = ld.aps(method_selection);
  ld = load('data/pascal_voc07_test_frcn_noregr_aps.mat');
  frcn_noregr_AP = ld.aps(method_selection);
  
  % assign distinct colors to the methods
  n = numel(methods);
  for i = 1:n
    methods(i).line_style = '-';
  end
  
  % average recall
  mirror_offset = 0.060;
  offsets = zeros(n, 2);
  offsets(:,1) = 0.010;
  offsets(1,1) = offsets(1,1)-mirror_offset;
  offsets(2,1) = offsets(2,1)-mirror_offset;
  offsets(6,1) = offsets(6,1)-mirror_offset;
  offsets(7,1) = offsets(7,1)-mirror_offset;
  methods = plot_weighted_area_color_coded(ARs, ...
    rcnn_AP, methods, custom_names, [0.3 0.6 43 55.5], true, offsets);
  hei = 7; wid = 7;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/RCNN_mAP_recall_area_voc07_edge_boxes.pdf');
  
  mirror_offset = 0.060;
  offsets = zeros(n, 2);
  offsets(:,1) = 0.010;
  offsets(1:4,1) = offsets(1:4,1)-mirror_offset;
  offsets(5,2) = offsets(5,2)+0.5;
  offsets(6:9,2) = offsets(6:9,2)-0.5;
  plot_weighted_area_color_coded(ARs, ...
    frcn_AP, methods, custom_names, [0.3 0.6 43 65], false, offsets);
  hei = 7; wid = 7;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/FRCN_mAP_recall_area_voc07_edge_boxes.pdf');
  
  mirror_offset = 0.060;
  offsets = zeros(n, 2);
  offsets(:,1) = 0.010;
  offsets(6:9,1) = offsets(6:9,1)-mirror_offset;
  offsets(5:6,2) = offsets(5:6,2)+0.5;
  offsets(1:4,2) = offsets(1:4,2)-0.6;
  offsets(1:4,1) = offsets(1:4,1)-0.006;
  plot_weighted_area_color_coded(ARs, ...
    frcn_noregr_AP, methods, custom_names, [0.3 0.6 43 60], false, offsets);
  hei = 7; wid = 7;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/FRCN_noregr_mAP_recall_area_voc07_edge_boxes.pdf');
  
  % plot recall curves for each parameter setting
  fh = figure;
  plot_overlap_recall_curve({methods.best_voc07_candidates_file}, ...
    methods, 1000, fh, true, 'NorthEast', false, ...
    custom_names);
  lh = legend(custom_names);
  legend boxoff;
  hei = 7;
  wid = 7;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  P = get(lh, 'Position');
  P(1) = P(1) + 0.11;
  P(2) = P(2) + 0.1;
  set(lh, 'Position', P);

  printpdf('figures/recall_1000_voc07_edge_boxes.pdf')
end

function [methods] = plot_weighted_area_color_coded(areas, AP, methods, ...
  custom_names, axis_lim, reassign_colors, label_offsets)
  additional_methods = methods(end);
  additional_areas = areas(end);
  additional_AP = AP(end);
  
  methods = methods(1:end-1);
  areas = areas(1:end-1);
  AP = AP(1:end-1);

  S=corrcoef([areas' AP']); s = S(1,end);
  figure;

  x = 0.5:0.05:0.9;
  y = cat(1, areas, AP);
  xx = 0.5:0.002:0.9;
  yy = spline(x, y, xx);
  
  dists = sqrt(sum((yy(:,2:end) - yy(:,1:end-1)) .^ 2, 1));
  dists = dists .* linspace(6,1,numel(dists));
  dists = cumsum(dists);

  colors = rainbow(dists, max(dists));
  n = numel(xx);
  for i = 2:n
    plot(yy(1,(i-1):i), yy(2,(i-1):i), 'Color', colors(i-1,:), 'LineWidth', 1.5);
    if i == 2; hold on; end
  end

  if reassign_colors
    for i = 1:numel(methods)
      [~,c_idx] = min((yy(1,:) - areas(i)) .^ 2 + (yy(2,:) - AP(i)) .^ 2);
      c_idx = max(c_idx - 1, 1);
      methods(i).color = colors(c_idx,:);
    end
  end
  hold on;

  p=polyfit(areas,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3);

  for i = 1:numel(methods)
    plot(areas(i), AP(i), '.', 'MarkerSize', 20, 'Color', methods(i).color);
  end
  for i = 1:numel(additional_methods)
    plot(additional_areas(i), additional_AP(i), '.', 'MarkerSize', 20, 'Color', 'k');
    additional_methods(i).color = [0 0 0];
  end
  grid on;
  % move the labels around, so it looks nice
  xpos = [areas additional_areas];
  ypos = [AP additional_AP];
  xpos = xpos + label_offsets(:,1)';
  ypos = ypos + label_offsets(:,2)';

  text(xpos,ypos,custom_names);
  xlabel(sprintf('average recall')); axis(axis_lim)
  title(sprintf('correlation=%.3f',s)); ylabel('mAP'); hold on;
  hold off
  
  methods = [methods additional_methods];
end

function cmap = rainbow(k,n)
  rainbow_cmap = [
    255, 0, 0
    255, 127, 0
    255, 255, 0
    0, 255, 0
    0, 0, 255
    75, 0, 130
    143, 0, 255]/255;
  idx = (k/n*size(rainbow_cmap,1));
  idx = max(1, min(size(rainbow_cmap,1), idx));
  
  x = (1:size(rainbow_cmap,1))';
  y = rainbow_cmap;
  cmap = interp1(x, y, idx);
end


