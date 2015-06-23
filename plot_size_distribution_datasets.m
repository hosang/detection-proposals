function plot_size_distribution_datasets()
colormap = [
228, 229, 97
163, 163, 163
218, 71, 56
219, 135, 45
145, 92, 146
83, 136, 173
106,61,154
225, 119, 174
142, 195, 129
51,160,44
223, 200, 51
92, 172, 158
177,89,40
177,89,40
188, 128, 189
177,89,40
251,154,153
31,120,180]./255;

  box_size_bins = 0:10:600;
  box_size_bin_centers = (box_size_bins(1:(end-1)) + box_size_bins(2:end)) / 2;
  box_size_bins(1) = -inf;
  box_size_bins(end) = inf;
  num_bins = numel(box_size_bins) - 1;
  
  handles = [];
  legend_labels = {};
  
  figure; hold on;
  
  load('data/pascal_voc07_test_annotations.mat');
  gt_w = [pos.x2] - [pos.x1] + 1;
  gt_h = [pos.y2] - [pos.y1] + 1;
  areas = sqrt(gt_w .* gt_h);
  [gt_h,arg_hist] = histc(areas, box_size_bins);
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  gt_h = gt_h(1:end-1)';
  gt_h = gt_h / sum(gt_h);
  handles(end+1) = plot(box_size_bin_centers, gt_h, '-', ...
    'LineWidth', 1.5, 'Color', colormap(1,:), 'MarkerSize', 10);
  legend_labels{end+1} = 'VOC test 2007';
  
  val = load('data/ILSVRC2013_val_annotations.mat');
  pos = val.pos;
  gt_w = [pos.x2] - [pos.x1] + 1;
  gt_h = [pos.y2] - [pos.y1] + 1;
  areas = sqrt(gt_w .* gt_h);
  [gt_h,arg_hist] = histc(areas, box_size_bins);
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  gt_h = gt_h(1:end-1)';
  gt_h = gt_h / sum(gt_h);
  handles(end+1) = plot(box_size_bin_centers, gt_h, '-', ...
    'LineWidth', 1.5, 'Color', colormap(2,:), 'MarkerSize', 10);
  legend_labels{end+1} = 'ILSVRC val 2013';
  
  val = load('data/coco2014_val_annotations.mat');
  pos = val.pos;
  gt_w = [pos.x2] - [pos.x1] + 1;
  gt_h = [pos.y2] - [pos.y1] + 1;
  areas = sqrt(gt_w .* gt_h);
  [gt_h,arg_hist] = histc(areas, box_size_bins);
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  gt_h = gt_h(1:end-1)';
  gt_h = gt_h / sum(gt_h);
  handles(end+1) = plot(box_size_bin_centers, gt_h, '-', ...
    'LineWidth', 1.5, 'Color', colormap(3,:), 'MarkerSize', 10);
  legend_labels{end+1} = 'COCO val 2014';
  
  legend(legend_labels, 'Location', 'northeast');
  legend boxoff;
  xlabel('sqrt(annotation area)');
  ylabel('frequency');
  xlim([0, 400]);
  hei = 10;
  wid = 8;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/datasets_size_histogram.pdf')
  
  
end

function h = get_size_statistics(candidates, im_size, box_size_bins)
  boxes = candidates;
  w = boxes(:,3) - boxes(:,1) + 1;
  h = boxes(:,4) - boxes(:,2) + 1;
  areas = sqrt(w .* h ./ prod(im_size));
  [h,arg_hist] = histc(areas, box_size_bins);
  
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  
  assert(h(end) == 0);
  h = h(1:end-1)';
end
