function methods = get_method_configs()
% Get properties of all proposal methods. For examples, this includes paths to
% candidate files, intermediate files, and also information about how to sort
% candidates.

% If you want to add your own method, add it at the bottom.

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
31,120,180
177,89,40
177,89,40
177,89,40
177,89,40
177,89,40
177,89,40
177,89,40
] ./ 256;

  config = get_config();
  
  methods = [];
  
  i = numel(methods) + 1;
  methods(i).name = 'Objectness';
  methods(i).short_name = 'O';
  methods = add_paths(methods(i), config, 'objectness/');
  methods(i).order = 'descend';
  methods(i).extract = @run_objectness;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;

  i = numel(methods) + 1;  
  methods(i).name = 'Rahtu';
  methods(i).short_name = 'R1';
  methods(i) = add_paths(methods(i), config, 'categ_indep_detection/');
  methods(i).order = 'none';
  methods(i).extract = @run_categ_independent;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'SelectiveSearch';
  methods(i).short_name = 'SS';
  methods(i) = add_paths(methods(i), config, 'selective_search/');
  methods(i).order = 'ascend';
  methods(i).extract = @run_selective_search;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;

  i = numel(methods) + 1;
  methods(i).name = 'RandomizedPrims';
  methods(i).short_name = 'RP';
  methods(i) = add_paths(methods(i), config, 'randomized_prims/');
  methods(i).gt_recall_num_candidates = 20000;
  methods(i).rerun_num_candidates = [];
  methods(i).repeatability_num_candidates = 5000;
  methods(i).order = 'none';
  methods(i).extract = @run_randomized_prims;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'Uniform';
  methods(i).short_name = 'U';
  methods(i) = add_paths(methods(i), config, 'random_uniform/');
  methods(i).order = 'random';
  methods(i).extract = @sample_uniform;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = true;
  
  i = numel(methods) + 1;
  methods(i).name = 'Gaussian';
  methods(i).short_name = 'G';
  methods(i) = add_paths(methods(i), config, 'random_gaussian/');
  methods(i).order = 'random';
  methods(i).extract = @sample_gaussian;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = true;

  i = numel(methods) + 1;
  methods(i).name = 'CPMC';
  methods(i).short_name = 'C';
  methods(i) = add_paths(methods(i), config, 'CPMC/');
  methods(i).order = 'descend';
  methods(i).extract = @run_cpmc;
  methods(i).num_candidates = false;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'Bing';
  methods(i).short_name = 'B';
  methods(i) = add_paths(methods(i), config, 'BING/');
  methods(i).order = 'descend';
  methods(i).extract = @run_bing;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'Endres';
  methods(i).short_name = 'E';
  methods(i) = add_paths(methods(i), config, 'endres/');
  methods(i).order = 'none';
  methods(i).extract = @run_prop;
  methods(i).num_candidates = false;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'Rantalankila';
  methods(i).short_name = 'R4';
  methods(i) = add_paths(methods(i), config, 'Rantalankila/');
  methods(i).order = 'none';
  methods(i).extract = @run_rantalankila;
  methods(i).num_candidates = true;
  methods(i).rerun_num_candidates = [100 1000 10000];
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'Superpixels';
  methods(i).short_name = 'SP';
  methods(i) = add_paths(methods(i), config, 'segmentation_baseline/');
  methods(i).order = 'none';
  methods(i).extract = @run_felsen_candidates;
  methods(i).num_candidates = false;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = true;
  
  i = numel(methods) + 1;
  methods(i).name = 'Sliding window';
  methods(i).short_name = 'SW';
  methods(i) = add_paths(methods(i), config, 'sliding_window/');
  methods(i).order = 'none';
  methods(i).extract = @sample_bing_windows;
  methods(i).num_candidates = true;
  methods(i).rerun_num_candidates = ceil(10 .^ (2:0.5:4));
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = true;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes';
  methods(i).short_name = 'EB70';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_70/');
  methods(i).order = 'descend';
  methods(i).extract = @run_edge_boxes;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes50';
  methods(i).short_name = 'EB50';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_50/');
  methods(i).order = 'descend';
  methods(i).extract = @run_edge_boxes50;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  methods(i).line_style = ':';
  
  i = numel(methods) + 1;
  methods(i).name = 'MCG';
  methods(i).short_name = 'M';
  methods(i) = add_paths(methods(i), config, 'MCG2015/');
  methods(i).order = 'none';
  methods(i).extract = @run_MCG2015;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes90';
  methods(i).short_name = 'EB90';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_90/');
  methods(i).order = 'descend';
  methods(i).extract = @run_edge_boxes90;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  methods(i).line_style = '-.';
  
  i = numel(methods) + 1;
  methods(i).name = 'Rigor';
  methods(i).short_name = 'Ri';
  methods(i) = add_paths(methods(i), config, 'rigor/');
  methods(i).order = 'none';
  methods(i).extract = @run_rigor;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  methods(i).rerun_num_candidates = [10 100 1000 2000 10000];

  i = numel(methods) + 1;
  methods(i).name = 'Geodesic';
  methods(i).short_name = 'G';
  methods(i) = add_paths(methods(i), config, 'geodesic/');
  methods(i).order = 'none';
  methods(i).extract = @run_gop;
  methods(i).num_candidates = false;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  methods(i).rerun_num_candidates = [10 100 1000 2000 10000];
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes60';
  methods(i).short_name = 'EB60';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_60/');
  methods(i).order = 'descend';
  methods(i).extract = @run_edge_boxes60;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes80';
  methods(i).short_name = 'EB80';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_80/');
  methods(i).order = 'descend';
  methods(i).extract = @run_edge_boxes80;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes55';
  methods(i).short_name = 'EB55';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_55/');
  methods(i).order = 'descend';
  methods(i).extract = @(im,num) run_edge_boxes(im, num, 0.65, 0.60);
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes65';
  methods(i).short_name = 'EB65';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_65/');
  methods(i).order = 'descend';
  methods(i).extract = @(im,num) run_edge_boxes(im, num, 0.65, 0.70);
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes75';
  methods(i).short_name = 'EB75';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_75/');
  methods(i).order = 'descend';
  methods(i).extract = @(im,num) run_edge_boxes(im, num, 0.70, 0.80);
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'EdgeBoxes85';
  methods(i).short_name = 'EB85';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_85/');
  methods(i).order = 'descend';
  methods(i).extract = @(im,num) run_edge_boxes(im, num, 0.80, 0.90);
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  i = numel(methods) + 1;
  methods(i).name = 'Edge Boxes AR';
  methods(i).short_name = 'EBAR';
  methods(i) = add_paths(methods(i), config, 'edge_boxes_AR/');
  methods(i).order = 'descend';
  methods(i).extract = @run_edge_boxes_AR;
  methods(i).num_candidates = true;
  methods(i).color = colormap(i,:);
  methods(i).is_baseline = false;
  
  % add your own method here:
  if false
  i = numel(methods) + 1;
  methods(i).name = 'The full name of your method';
  methods(i).short_name = 'a very short version of the name';
  methods(i) = add_paths(methods(i), config, 'ours-wip/');
  % This specifies how to order candidates so that the first n, are the best n
  % candidates. For example we run a method for 10000 candidates and then take
  % the first 10, instead of rerunning for 10 candidates. Valid orderings are:
  %   none: candidates are already sorted, do nothing
  %   ascend/descend: sort by score descending or ascending
  %   random: random order
  %   biggest/smallest: sort by size of the bounding boxes
  methods(i).order = 'descend';
  % A function pointer to a method that runs your proposal detector.
  methods(i).extract = @run_edge_boxes90;
  % If your method supports sorting this should be empty. If your method has to
  % be rerun for every number of candidates we want, specify the number of
  % candidates here:
  methods(i).rerun_num_candidates = []; % ceil(10 .^ (2:0.5:4));
  % Specifies whether or not your method takes the desired number of candidates
  % as an input.
  % TODO(hosang): Is this actually used anywhere?
  methods(i).num_candidates = true;
  % color for drawing
  methods(i).color = colormap(i,:);
  % This should be false. Is used for drawing baselines dashed.
  methods(i).is_baseline = false;
  end
  
  % do the sorting dance
  sort_keys = [num2cell([methods.is_baseline])', {methods.name}'];
  for i = 1:numel(methods)
    sort_keys{i,1} = sprintf('%d', sort_keys{i,1});
  end
  [~,idx] = sortrows(sort_keys);
  for i = 1:numel(methods)
    methods(idx(i)).sort_key = i;
  end
end

function method = add_paths(method, config, method_subdir)
  method.candidate_dir = fullfile(config.precomputed_candidates, method_subdir, 'mat');
  method.repeatability_candidate_dir = fullfile(config.precomputed_candidates, method_subdir, 'repeatability_mat');
  method.best_voc07_candidates_file = fullfile(config.precomputed_candidates, method_subdir, 'best_candidates.mat');
  method.best_imagenet_candidates_file = fullfile(config.precomputed_candidates, method_subdir, 'best_candidates_imagenet.mat');
  method.repeatability_matching_file = fullfile(config.precomputed_candidates, method_subdir, 'repeatability_matching.mat');
  method.candidate_dir_coco = fullfile(config.precomputed_candidates_coco, method_subdir, 'mat');
  method.best_coco14_candidates_file = fullfile(config.precomputed_candidates_coco, method_subdir, 'best_candidates_coco14.mat');
end