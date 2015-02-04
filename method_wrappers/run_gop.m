function [boxes, scores] = run_gop(im, num_proposals)

  if ~isdeployed
    old_path = path;
    addpath('/path/to/geodesic/gop_matlab/matlab');
  end
  
  
  interp_data = load('/path/to/gop_num_candidates_interpolation_data.mat');
  interp_data.num_candidates = [-1; interp_data.num_candidates; 1e10];
  interp_data.all_params = [interp_data.all_params(1,:); interp_data.all_params; interp_data.all_params(end,:)];
  params = interp1(interp_data.num_candidates, interp_data.all_params, num_proposals);
  assert(~any(isnan(params)));
  N_S = params(1);
  N_T = params(2);
  
  boxes = gop_wrapper(im, N_S, N_T);
  scores = [];
    
  if ~isdeployed
    path(old_path);
  end
end


function boxes = gop_wrapper(im, N_S, N_T)
% reimplementation of eval_box.py
  gop_mex( 'setDetector', 'MultiScaleStructuredForest("/path/to/geodesic/gop_matlab/data/sf.dat")' );
  data_path = '/path/to/geodesic/gop_matlab/data/';
  max_iou = 0.7;
  args = {};
  if N_S > 3
    args = [args {'seed', [data_path 'seed_final.dat']}];
  end
  if N_T >= 5
    max_iou = 0.8;
  end
  if N_T > 6
    max_iou = 0.9;
  end
  if N_S > 40
    args = [args {'unary', N_S, N_T, 'seedUnary()', 'backgroundUnary({0,1,15})', ...
                  'unary', 0, N_T,   'seedUnary()', 'backgroundUnary({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15})', 0.1, 1}];
  elseif N_S > 1
    args = [args {'unary', N_S, N_T, 'seedUnary()', 'backgroundUnary({0,15})'}];
  else
    args = [args {'unary', N_S, N_T, 'seedUnary()', 'backgroundUnary({15})'}];
  end
  
  args = [{'max_iou', max_iou}, args];
  p = Proposal(args{:});
  tic();
  os = OverSegmentation( im );
  props = p.propose( os );
  boxes = double(os.maskToBox( props ));
  toc();
end
