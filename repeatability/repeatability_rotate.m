function [im, H] = repeatability_rotate(im_ref, params)
  angle_degree = params.angle;
  
  im_size = [];
  for max_angle_degree = params.max_angles
    [im_max_rot, ~] = rotate(im_ref, max_angle_degree);
    if isempty(im_size)
      im_size = [size(im_max_rot, 2), size(im_max_rot, 1)];
    else
      im_size = min([im_size; size(im_max_rot, 2), size(im_max_rot, 1)], [], 1);
    end
  end
  
  [im, H] = rotate(im_ref, angle_degree);
  
  % because reference and rotated image will be cropped to im_size,
  % we need to offset that additional cropping in H
  
  ref_size_diff = [size(im_ref, 2), size(im_ref, 1)] - im_size;
  assert(all(ref_size_diff >= 0));
  Htrans_ref = eye(3);
  Htrans_ref(1:2,3) = floor(ref_size_diff/2)';
  
  rot_im_size = [size(im, 2), size(im, 1)];
  rot_size_diff = rot_im_size - im_size;
  rot_offset = floor(rot_size_diff / 2);
  assert(all(rot_size_diff >= 0));
  Htrans_rot = eye(3);
  Htrans_rot(1:2,3) = -rot_offset';
  x_y_min = rot_offset + 1;
  x_y_max = rot_im_size - ceil(rot_size_diff / 2);
  im = im(x_y_min(2):x_y_max(2), x_y_min(1):x_y_max(1), :);
  
  % H * x_reference = x_rotated
  H = Htrans_rot * H * Htrans_ref;
  
end


function [im, H] = rotate(im_ref, angle_degree)
  angle_rad = angle_degree / 180 * pi;
  im_rot = imrotate(im_ref, angle_degree, 'bilinear', 'crop');
  
  center = [size(im_ref, 2), size(im_ref, 1)] / 2;

  Htrans1 = eye(3);
  Htrans1(1:2,3) = (center' + 1);
  Htrans2 = eye(3);
  Htrans2(1:2,3) = -(center' + 1);
  
  Hrot = eye(3);
  Hrot(1,1) = cos(-angle_rad);
  Hrot(1,2) = -sin(-angle_rad);
  Hrot(2,1) = sin(-angle_rad);
  Hrot(2,2) = cos(-angle_rad);
  
  % H * x_reference = x_rotated
  H = Htrans1 * Hrot * Htrans2;
  
  % crop so there is no 'made up' image content
  % upper left, upper right, lower left, lower right
  x_ref_max = size(im_ref, 2);
  y_ref_max = size(im_ref, 1);
  corners_ref = [1, x_ref_max, x_ref_max, 1; ...
    1, 1, y_ref_max, y_ref_max; ...
    1, 1, 1, 1];
  proj_corners_ref = H * corners_ref;
  proj_corners_ref = proj_corners_ref(1:2,:) ./ repmat(proj_corners_ref(3,:), [2 1]);
%   x_min = ceil(max(proj_corners_ref(1,1), proj_corners_ref(1,3)));
%   y_min = ceil(max(proj_corners_ref(2,1), proj_corners_ref(2,2)));
%   x_max = floor(min(proj_corners_ref(1,2), proj_corners_ref(1,4)));
%   y_max = floor(min(proj_corners_ref(2,3), proj_corners_ref(2,4)));
  [x_min, y_min, x_max, y_max] = get_biggest_rect(proj_corners_ref', im_rot);
  im = im_rot(y_min:y_max, x_min:x_max,:);
  
  Htrans3 = eye(3);
  Htrans3(1,3) = -(x_min - 1);
  Htrans3(2,3) = -(y_min - 1);
  H = Htrans3 * H;
end

function [x_min, y_min, x_max, y_max] = get_biggest_rect(proj_corners, im_ref)
  diag1 = [1, 1; size(im_ref, 2), size(im_ref, 1)];
  diag2 = [size(im_ref, 2), 1; 1, size(im_ref, 1)];
  
  points = [...
    intersect_lines(proj_corners(1:2,:), diag1); ...
    intersect_lines(proj_corners(1:2,:), diag2); ...
    intersect_lines(proj_corners(2:3,:), diag1); ...
    intersect_lines(proj_corners(2:3,:), diag2); ...
    intersect_lines(proj_corners(3:4,:), diag1); ...
    intersect_lines(proj_corners(3:4,:), diag2); ...
    intersect_lines(proj_corners([1 4],:), diag1); ...
    intersect_lines(proj_corners([1 4],:), diag2)];
  points = unique(points, 'rows');
  bottom_right = [size(im_ref, 2), size(im_ref, 1)];
  dists = sum((repmat(bottom_right/2, [size(points,1), 1]) - points) .^ 2, 2);
  [~,idx] = sort(dists);
  closest_points = points(idx(1:4),:);
  sorted_x = sort(closest_points(:,1));
  sorted_y = sort(closest_points(:,2));
  x_min = ceil(max(sorted_x(1:2)));
  x_max = floor(min(sorted_x(3:4)));
  y_min = ceil(max(sorted_y(1:2)));
  y_max = floor(min(sorted_y(3:4)));

%   figure; hold on;
%   lines = [proj_corners; proj_corners(1,:)];
%   line(lines(:,1), lines(:,2), ...
%       'LineWidth', 3, 'Color', 'r');
%   line(diag1(:,1), diag1(:,2), ...
%       'LineWidth', 3, 'Color', 'b');
%   line(diag2(:,1), diag2(:,2), ...
%       'LineWidth', 3, 'Color', 'b');
%     line(closest_points(:,1), closest_points(:,2), ...
%       'LineWidth', 3, 'Color', 'k');
%     plot(points(:,1), points(:,2), 'x');
%   rectangle('Position', [x_min, y_min, (x_max - x_min + 1), (y_max - y_min + 1)]);
%     axis equal;
end

function [p_int, intersect] = intersect_lines(ps1, ps2)
% ps1 = [x1 y1; x2 y2];

% float delta = A1*B2 - A2*B1;
% if(delta == 0) 
%     throw new ArgumentException("Lines are parallel");
% 
% float x = (B2*C1 - B1*C2)/delta;
% float y = (A1*C2 - A2*C1)/delta;

% A = y2-y1; B = x1-x2; C = A*x1+B*y1 
%   figure;
%   hold on;
%   line(ps1(:,1), ps1(:,2), 'Color', 'r');
%   line(ps2(:,1), ps2(:,2), 'Color', 'k');
  A1 = ps1(2,2) - ps1(1,2);
  B1 = ps1(1,1) - ps1(2,1);
  C1 = A1 * ps1(1,1) + B1 * ps1(1,2);
  A2 = ps2(2,2) - ps2(1,2);
  B2 = ps2(1,1) - ps2(2,1);
  C2 = A2 * ps2(1,1) + B2 * ps2(1,2);
  
  delta = A1 * B2 - A2 * B1;
  intersect = delta == 0;
  if intersect
    return;
  end

  p_int = [(B2 * C1 - B1 * C2) / delta, (A1 * C2 - A2 * C1) / delta];
%   plot(p_int(:,1), p_int(:,2), 'x');
end

