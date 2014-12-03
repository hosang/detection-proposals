function [candidates, priority] = run_rantalankila(im, num_candidates, varargin)
  if ~isdeployed
    old_path = path;
    addpath(fullfile('..', 'Rantalankila'));
    addpath(fullfile('..', 'Rantalankila', 'GCMex'));
    addpath(fullfile('..', 'Rantalankila', 'features'));
    addpath(fullfile('..', 'Rantalankila', 'vlfeat-0.9.18', 'toolbox', 'mex', 'mexa64'));
    
  end
  
  opts = get_opts();
  
  interp_data = load('/path/to/all/rantalankila_num_candidates_interpolation_data.mat');
  if num_candidates <= min(interp_data.num_candidates)
    opts.gc_branches = 0;
  elseif num_candidates >= max(interp_data.num_candidates)
    opts.gc_branches = 500;
  else
    opts.gc_branches = interp1(interp_data.num_candidates, interp_data.gc_branches, num_candidates);
    assert(~isnan(opts.gc_branches));
  end
    
  
  
  argl = length(varargin);
  if mod(argl,2) ~= 0 % string-value pairs
      error('Give pairs of extra arguments.');
  end
  for argi = 0:((argl/2) - 1)
      arg_str = varargin(2*argi + 1);
      arg_val = varargin(2*argi + 2);
      assert(isfield(opts, arg_str{1}));
      opts.(arg_str{1}) = arg_val{1};
  end
  
  opts.seg_method = 'felz';
  try
    [region_parts{1}, orig_sp{1}] = spagglom(im, opts);
  catch
    fprintf('rantalankila run on felsenzwalb segmentation failed\n');
  end
  opts.seg_method = 'slic';
  [region_parts{2}, orig_sp{2}] = spagglom(im, opts);
  
  candidates = sp_to_candidates(im, region_parts, orig_sp);
  priority = [];
  
  if ~isdeployed
    path(old_path);
  end
end


function bboxes = sp_to_candidates(im, region_parts, orig_sp)
%   candidates = [];
%   for sus = 1:length(orig_sp)
%     ys = double(orig_sp{sus}.pixels(:,1));
%     xs = double(orig_sp{sus}.pixels(:,2));
%     candidates = cat(1, candidates, [min(xs), min(ys), max(xs), max(ys)]);
%   end
  
  [h, w, ~] = size(im);

    % For each sp of orig_sp, find its bounding box
    for region_set = 1:length(region_parts)
        sp_edges{region_set} = zeros(length(orig_sp{region_set}), 4);
        bboxes{region_set} = zeros(length(region_parts{region_set}), 4);

        % find edges of Ri
        for ses = 1:length(orig_sp{region_set})
            Ri = false(h, w); % note ',', not '*' as below
            Ri(orig_sp{region_set}{ses}.spind) = 1;
            Xi = sum(Ri,1);
            Yi = sum(Ri,2);
            sp_edges{region_set}(ses,:) = [find(Xi,1,'first'), find(Yi,1,'first'), find(Xi,1,'last'), find(Yi,1,'last')];               
        end

        % Using the above bounding boxes, solve bounding box of each region
        % proposal
        for j = 1:length(region_parts{region_set})
            sus = region_parts{region_set}{j};
            if ~isempty(sus)
                tg = sp_edges{region_set}(sus,:);
                bboxes{region_set}(j,:) = [min(tg(:,1)), min(tg(:,2)), max(tg(:,3)), max(tg(:,4))]; % bounding box is the most extreme values of individual bounding boxes
            else
              error('what is this?');
                bboxes = [];
            end
        end
    end % for each region set
    
    bboxes = cat(1, bboxes{:});
end


function [opts] = get_opts()
% Sets options for spagglom.m that are propagated through the functions. Many of the
% options are zero/one flags. The default settings were used to produce the
% results presented in the paper.


%% Superpixelation stage
opts.seg_method = 'slic'; % 'felz', 'slic' or 'qshift'. Two first recommended

% Felzenswalb superpixelation parameters
opts.felz_k = 50; % default 50
opts.felz_sigma = 0.8; % default 0.8
opts.felz_min_area = 150; % default 150

% SLIC superpixelation parameters
opts.slic_regularizer = 800; % default 800 (uses different definition than SLIC authors)
opts.slic_region_size = 20; % default 20

%% Features
opts.diagonal_connections = 0; % default 0. Whether only diagonally connected pixels are considered connected.
opts.dsift_step = 2; % default 2. calculate dsfit only every n step (quadratic speedup in n).

% Histogram features to use
opts.feature_dsift_bow = 1;    % 1 % denseSIFT bag-of-words
opts.feature_color_bow = 1;    % 2 % color bag-of-words in various color spaces
opts.feature_rgb_raw = 0;      % 3 % raw rgb histograms
opts.feature_grad_texture = 0; % 4 % feature used by van de Sande. Has two implementations, see code
opts.feature_lbp = 0;          % 6 % Local binary patterns
opts.feature_size = 1;         % 8 % size of combined superpixel
opts.features = 1:6; % This will be used in similarity.m to change histogram distances feature-wise
opts.features = opts.features(logical([opts.feature_dsift_bow, opts.feature_color_bow, opts.feature_rgb_raw, opts.feature_grad_texture, opts.feature_lbp ,opts.feature_size]));

opts.feature_weights = [1,1,2]; % default [1,1,2] with above dsift_bow, color_bow, size enabled and rest disabled

opts.collect_merged_regions = 1; % default 1. Every time a pair is merged during the greedy pairing algorithm, the new pair is saved as a region

opts.gc_branches = 15; % default 15. Number of graphcut branches.

opts.start_phase2 = 0.8; % 0.8 default. Score at which to change features and/or start branching

% Load precalculated data
opts.load_color_dict = 1; % default 1. 0 means dictionary will be created from the image (very slow). This option is used for both, rgb and lab features.
opts.load_dsift_dict = 1; % default 1. same as above but for dsift
opts.load_dsift_words = 0; % default 0. load precalculated dsift words using precalculated dict. This option overrides opts.load_dsift_dict.
opts.load_init_segs = 0; % default 0. Load initial felz or slic rgb segmentations with "default" parameters (see conditionals in code at spagglom.m)

if opts.load_dsift_dict
    load('/path/to/Rantalankila/dicts/dsift_dict_k500');
    opts.dsift_dict = dsift_dict;
    clear dsift_dict;
end
end
