function plot_size_distribution()
  num_candidates = 10000;
  
  box_size_bins = 0:0.1:1;
  box_size_bin_centers = (box_size_bins(1:(end-1)) + box_size_bins(2:end)) / 2;
  box_size_bins(1) = -inf;
  box_size_bins(end) = inf;
  num_bins = numel(box_size_bins) - 1;
  
  load('data/pascal_voc07_test_annotations.mat');
  images = {impos.im};
  image_sizes = {impos.img_size};
  
  
  methods = get_method_configs();
  methods([14 16 19:25]) = [];
  
  handles = [];
  
  histograms = zeros(numel(methods), num_bins);
  legend_labels = cell(numel(methods), 1);
  valid = true(numel(methods), 1);
  for method_i = 1:numel(methods)
    method = methods(method_i);
    fprintf('method: %s\n', method.name);
    legend_labels{method_i} = method.name;
    cache_file = fullfile(method.candidate_dir, 'size_hist.mat');
    try
      data = load(cache_file);
      h = data.h;
    catch
      h = zeros(1, num_bins);
      for im_i = 1:numel(images)
        tic_toc_print('%s %d/%d\n', method.name, im_i, numel(images));
        [~,img_id,~] = fileparts(images{im_i});
        try
          [candidates] = get_candidates(method, img_id, ...
            num_candidates);
        catch
          valid(method_i) = false;
          fprintf('candidates for img_id %s are missing!\n', img_id);
          break;
        end
        if isempty(candidates)
          continue;
        end
        t_h = get_size_statistics(candidates, image_sizes{im_i}, box_size_bins);
        h = h + t_h(:)';
      end
      if valid(method_i)
        save(cache_file, 'h');
      end
    end
    if valid(method_i)
      histograms(method_i,:) = h;
    end
  end
  
  % normalize histograms
  histograms = histograms ./ repmat(sum(histograms, 2), [1, num_bins]);
  
  histograms = histograms(valid,:);
  legend_labels = legend_labels(valid);
  methods = methods(valid);
  
  [~,method_order] = sort([methods.sort_key]);
  methods = methods(method_order);
  histograms = histograms(method_order,:);
  legend_labels = legend_labels(method_order);
  figure; hold on;
  for i = 1:numel(methods)
    line_style = '-';
    if methods(i).is_baseline
      line_style = '--';
    end
    if ~isempty(methods(i).line_style)
      line_style = methods(i).line_style;
    end
    handles(end+1) = plot(box_size_bin_centers, histograms(i,:), '.', 'LineWidth', 1.5, 'Color', methods(i).color, 'MarkerSize', 10, 'LineStyle', line_style);
  end
  
  gt_w = [pos.x2] - [pos.x1] + 1;
  gt_h = [pos.y2] - [pos.y1] + 1;
  areas = gt_w .* gt_h;
  for i = 1:numel(pos)
    areas(i) = sqrt(areas(i) / prod(pos(i).img_size));
  end
  [gt_h,arg_hist] = histc(areas, box_size_bins);
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  gt_h = gt_h(1:end-1)';
  gt_h = gt_h / sum(gt_h);
  handles(end+1) = plot(box_size_bin_centers, gt_h, '.-', 'LineWidth', 1.5, 'Color', 'black', 'MarkerSize', 10);
  legend_labels{end+1} = 'Ground truth VOC 2007';
  
  val = load('data/ILSVRC2013_val_annotations.mat');
  pos = val.pos;
  gt_w = [pos.x2] - [pos.x1] + 1;
  gt_h = [pos.y2] - [pos.y1] + 1;
  areas = gt_w .* gt_h;
  for i = 1:numel(pos)
    areas(i) = sqrt(areas(i) / prod(pos(i).img_size));
  end
  [gt_h,arg_hist] = histc(areas, box_size_bins);
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  gt_h = gt_h(1:end-1)';
  gt_h = gt_h / sum(gt_h);
  handles(end+1) = plot(box_size_bin_centers, gt_h, '.--', 'LineWidth', 1.5, 'Color', 'black', 'MarkerSize', 10);
  legend_labels{end+1} = 'Ground truth ILSVRC 2013';
  
  val = load('data/coco2014_val_annotations.mat');
  pos = val.pos;
  gt_w = [pos.x2] - [pos.x1] + 1;
  gt_h = [pos.y2] - [pos.y1] + 1;
  areas = gt_w .* gt_h;
  for i = 1:numel(pos)
    areas(i) = sqrt(areas(i) / prod(pos(i).img_size));
  end
  [gt_h,arg_hist] = histc(areas, box_size_bins);
  assert(min(arg_hist) >= 1);
  assert(max(arg_hist) <= numel(box_size_bins) - 1);
  gt_h = gt_h(1:end-1)';
  gt_h = gt_h / sum(gt_h);
  handles(end+1) = plot(box_size_bin_centers, gt_h, '^-', 'LineWidth', 1.5, 'Color', 'black', 'MarkerSize', 5);
  legend_labels{end+1} = 'Ground truth COCO 2014';
  
  xlabel('sqrt(relative candidate size)');
  ylabel('frequency');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/candidate_size_histogram.pdf')
  
  
  legend(legend_labels);
  legend boxoff;
  for i = 1:numel(handles)
    set(handles(i), 'visible', 'off');
  end
  set(gca, 'visible', 'off');
  printpdf('figures/candidate_size_histogram_legend.pdf')

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
