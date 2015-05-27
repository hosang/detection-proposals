function convert_to_rcnn()
  method_configs = get_method_configs();
  dirs = {'objectness', 'rahtu', 'selective_search_bmvc', ...
    'randomized_prims', 'random_uniform', 'random_gaussian', ...
    'CPMC', 'bing', 'endres', 'rantalankila', 'superpixels', ...
    'sliding_window', 'edge_boxes_70', 'edge_boxes_50', ...
    'MCG', 'edge_boxes_90', 'rigor', 'geodesic', 'edge_boxes_60', ...
    'edge_boxes_80', 'edge_boxes_55', 'edge_boxes_65', 'edge_boxes_75', ...
    'edge_boxes_85', 'edge_boxes_AR'};
  
  for i = 1:numel(method_configs)
    dest_dir = fullfile('/BS/hosang/work/src/rcnn/data/', dirs{i});
    convert(method_configs(i), dest_dir);
  end
end

function convert(config, dest_dir, num_proposals)
  if nargin < 3
    num_proposals = 1000;
  end
  assert(numel(config) == 1);

  if ~exist(dest_dir, 'dir')
    mkdir(dest_dir);
  end

  fprintf('\nconverting %d boxes of %s...\n', num_proposals, config.name);
  test = load('data/pascal_voc07_test_annotations.mat');
  train = load('data/pascal_voc07_trainval_annotations.mat');
  save_to([dest_dir '/voc_2007_test.mat'], config, test, num_proposals);
  save_to([dest_dir '/voc_2007_trainval.mat'], config, train, num_proposals);
end

function save_to(output_filename, config, image_set, num_proposals)
  try
    load(output_filename, 'images', 'boxes');
    % success
    fprintf('already exported\n');
    return;
  catch
  end
  
  try
    images = {image_set.impos.im};
    boxes = cell(size(images));
    for i = 1:numel(images)
      [boxes{i}, ~] = get_candidates(config, images{i}, ...
          num_proposals);
      % change format from [x1 y1 x2 y2] to [y1 x1 y2 x2]
      if ~isempty(boxes{i})
        boxes{i} = boxes{i}(:, [2 1 4 3]);
      end
    end
    save(output_filename, 'images', 'boxes');
    fprintf('wrote %s\n', output_filename);
  catch
    fprintf('error! probably not computed yet\n');
  end
end
