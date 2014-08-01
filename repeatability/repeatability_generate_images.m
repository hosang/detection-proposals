function repeatability_generate_images()
  load('data/pascal_voc07_test_annotations.mat', 'impos');
  config = get_config();
  rep_config = repeatability_get_config();
  
  homographies = [];
  fields = fieldnames(rep_config);
  for field_i = 1:numel(fields)
    homographies.(fields{field_i}) = zeros(numel(impos), 3, 3);
  end
  
  for im_i=1:numel(impos)
    tic_toc_print('image %d/%d\n', im_i, numel(impos));
    orig_img_id = impos(im_i).im;
    im = imread(sprintf(config.pascal_images, orig_img_id));
    
    fields = fieldnames(rep_config);
    for field_i = 1:numel(fields)
      %tic_toc_print('running %s\n', fields{field_i});
      
      sub_config = rep_config.(fields{field_i});
      for i = 1:numel(sub_config.params), param = sub_config.params(i);
        % skip parameters that are not plotted
        if isfield(sub_config, 'display_points')
          if ~ismember(i, sub_config.display_points)
            continue;
          end
        end
        [transformed_im, H] = sub_config.func(im, param);
        homographies.(fields{field_i})(im_i,:,:) = H;
        
        img_id = sprintf(sub_config.img_id, orig_img_id, i);
        imwrite(transformed_im, sprintf(config.transformed_pascal_images, img_id));
      end
    end
  end
  
  save('data/pascal_voc07_test_repeatability_homographies.mat', 'homographies');
end
