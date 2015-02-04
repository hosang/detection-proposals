function [conf] = repeatability_get_config()
  conf.scale.params = [2 .^ (-1:0.2:1), 0.9, 0.95, 0.99, 1.01, 1.05, 1.1];
  conf.scale.func = @repeatability_scale;
  conf.scale.img_id = '%s_scale%d';
  conf.scale.plot_x_transform = @log2;
  conf.scale.xlabel = 'log_2(scale)';
  conf.scale.id_value = 0;
  conf.scale.legend_location = 'SouthWest';
  conf.scale.name_version = 'short_name';
  conf.scale.big_dots_for_id = true;
  
  degrees = [-20:5:20, -1, -0.5, 0.5, 1, 0];
  empties = cell(numel(degrees), 1);
  conf.rotate.params = struct('angle', empties, 'max_angles', empties);
  for i = 1:numel(degrees)
    conf.rotate.params(i).angle = degrees(i);
    conf.rotate.params(i).max_angles = [min(degrees) max(degrees)];
  end
  conf.rotate.display_param = 'angle';
  conf.rotate.func = @repeatability_rotate;
  conf.rotate.img_id = '%s_rotate%d';
  conf.rotate.ref_params_idx = numel(degrees);
  conf.rotate.ref_params = conf.rotate.params(conf.rotate.ref_params_idx);
  conf.rotate.display_points = 1:(numel(degrees)-1);
  conf.rotate.xlabel = 'rotation in degree';
  conf.rotate.id_value = 0;
  conf.rotate.legend_location = 'SouthWest';
  conf.rotate.name_version = 'short_name';
  conf.rotate.big_dots_for_id = true;
  
  conf.light.params = [50:20:160, 100, 99, 101];
  conf.light.func = @repeatability_light;
  conf.light.img_id = '%s_light%d';
  conf.light.xlabel = 'lighting in %';
  conf.light.id_value = 100;
  conf.light.legend_location = 'SouthWest';
  conf.light.name_version = 'short_name';
  
  conf.jpeg.params = [5 10 20 50 80 100 99 120];
  conf.jpeg.func = @repeatability_jpeg;
  conf.jpeg.img_id = '%s_jpeg%d';
  conf.jpeg.xlabel = 'quality of compression in %';
  conf.jpeg.id_value = 120;
  conf.jpeg.xticks = [5 20 40 60 80 100 120];
  conf.jpeg.xticklabels = {'5', '20', '40', '60', '80', '100', 'lossless'};
  conf.jpeg.legend_location = 'SouthEast';
  conf.jpeg.name_version = 'short_name';
  conf.jpeg.xreverse = true;
  
  conf.blur.params = [0.3 0.6 1 2 3 0 0.2 4 8];
  conf.blur.display_points = [3 4 5 6 8 9];
  conf.blur.func = @repeatability_blur;
  conf.blur.img_id = '%s_blur%d';
  conf.blur.xlabel = 'sigma in pixels';
  conf.blur.id_value = 0;
  conf.blur.legend_location = 'SouthWest';
  conf.blur.name_version = 'short_name';
  
  function y = mylog(x)
    oor = x <= 0;
    y = x;
    y(oor) = -1;
    y(~oor) = log10(x(~oor));
  end
  conf.saltnpepper.params = [0 1 10 100 1000];
  conf.saltnpepper.func = @repeatability_saltnpepper;
  conf.saltnpepper.img_id = '%s_snp%d';
  conf.saltnpepper.id_value = -1;
  conf.saltnpepper.legend_location = 'SouthWest';
  conf.saltnpepper.name_version = 'short_name';
  conf.saltnpepper.plot_x_transform = @mylog;
  conf.saltnpepper.xlabel = 'log_{10}(number of pixels)';
  conf.saltnpepper.xticks = [-1 0 1 2 3];
  conf.saltnpepper.xticklabels = {'none', '0', '1', '2', '3'};
end
