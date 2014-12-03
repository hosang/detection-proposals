function [candidates, score] = run_edge_boxes(im, num_candidates)

  if ~isdeployed
    old_path = path;
      
    addpath('../edge_box');
    addpath('../edge_box/toolbox/matlab/');
    addpath('../edge_box/toolbox/channels/');
  end

  % Demo for Edge Boxes (please see readme.txt first).

  %% load pre-trained edge detection model (see edgesDemo.m)
  model=load('/path/to/edge_box/models/forest/modelBsds.mat'); model=model.model;

  %% set up opts for edgeBoxes (see edgeBoxes.m)
  opts = edgeBoxes;
  opts.alpha = .65;     % step size of sliding window search
  opts.beta  = .75;     % nms threshold for object proposals
  opts.minScore = .01;  % min score of boxes to detect
  opts.maxBoxes = 1e4;  % max number of boxes to detect

  %% detect bbs (no visualization code for now)
  tic, bbs=edgeBoxes(im,model,opts); toc
  candidates = double(bbs(:,1:4));
  candidates(:,3:4) = candidates(:,3:4) + candidates(:,1:2);
  score = double(bbs(:,end));
  
  if ~isdeployed
    path(old_path);
  end
end

