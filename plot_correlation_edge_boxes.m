function plot_correlation_edge_boxes()
% Plots for analyzing the correlation between detector performance
% (R-CNN) on the different variants of EdgeBoxes.
% Also plots the recall curves for all the variants.
%
% Bonus feature: Rainbow colormap! Hand-tuned nice colors on the curve!

  methods = get_method_configs();
 
  IoUs = 0.5:0.05:0.9;
  custom_names = arrayfun(@(x) sprintf('%.2f', x), IoUs, 'UniformOutput', false);
  
  % select all edge box variants
  method_selection = [13 14 16 19 20:24];
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

  T = ld.iou_thresholds;

  ld = load('data/pascal_voc07_test_rcnn_aps.mat');
  rcnn_AP = ld.aps(method_selection);
  
  % assign distinct colors to the methods
  for i = 1:numel(methods)
    methods(i).line_style = '-';
  end
  
  % average recall
  const_weights = ones(numel(T),1) ./ numel(T);
  integral_area = sum(R .* repmat(const_weights, [1, n_methods]), 1);
  methods = plot_weighted_area_color_coded(integral_area, ...
    rcnn_AP, methods, custom_names, [0.3 0.6 45 55], true);
  hei = 7; wid = 7;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/RCNN_mAP_recall_area_voc07_edge_boxes.pdf');
  
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

function [methods] = plot_weighted_area_color_coded(areas, AP, methods, custom_names, axis_lim, use_rainbow)
  S=corrcoef([areas' AP']); s = S(1,end);
  figure;

  x = 0.5:0.05:0.9;
  y = cat(1, areas, AP);
  xx = 0.5:0.002:0.9;
  yy = spline(x, y, xx);
  if use_rainbow
    dists = sqrt(sum((yy(:,2:end) - yy(:,1:end-1)) .^ 2, 1));
    dists = dists .* linspace(6,1,numel(dists));
    dists = cumsum(dists);


    colors = rainbow(dists, max(dists));
    n = numel(xx);
  %   colors = rainbow(1:(n-1),n-1);
    for i = 2:n
      plot(yy(1,(i-1):i), yy(2,(i-1):i), 'Color', colors(i-1,:), 'LineWidth', 1.5);
      if i == 2; hold on; end
    end

    for i = 1:numel(methods)
      [~,c_idx] = min((yy(1,:) - areas(i)) .^ 2 + (yy(2,:) - AP(i)) .^ 2);
      c_idx = max(c_idx - 1, 1);
      methods(i).color = colors(c_idx,:);
    end
  else
    plot(yy(1,:), yy(2,:), '--', 'Color', [1 1 1]/3*2, 'LineWidth', 1.5);
  end
  hold on;

  p=polyfit(areas,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3);

  for i = 1:numel(methods)
    plot(areas(i), AP(i), '.', 'MarkerSize', 20, 'Color', methods(i).color);
  end
  grid on;
  % move the labels aroundm so it looks nice
  xpos = areas+.007;
  ypos = AP;
  mirror_offset = 0.055;
  xpos(2) = xpos(2)-0.005;
  ypos(2) = ypos(2)-0.4;
  xpos(6) = xpos(6)-0.02;
  ypos(6) = ypos(6)+0.6;
  xpos(7) = xpos(7)-mirror_offset;
  xpos(8) = xpos(8)-mirror_offset;

  text(xpos,ypos,custom_names);
  xlabel(sprintf('average recall')); axis(axis_lim)
  title(sprintf('correlation=%.3f',s)); ylabel('AP'); hold on;
  hold off
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


