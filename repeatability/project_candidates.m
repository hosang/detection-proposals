function [candidates, exact] = project_candidates(candidates, H)
  n = size(candidates, 1);
  
  % project all 4 coordinates of the bbox
  %   1 ---- 2
  %   |      |
  %   4 ---- 3
  points = [cat(1, ...
    candidates(:,1:2), candidates(:,[3,2]), ...
    candidates(:,3:4), candidates(:,[1,4])), ...
    ones(4*n, 1)];
  projected_points = points * H';
  projected_points = projected_points ./ repmat(projected_points(:,3), [1 3]);
%   p1 = projected_points(1:n, 1:2);
%   p2 = projected_points((n+1):(2*n), 1:2);
%   p3 = projected_points((2*n+1):(3*n), 1:2);
%   p4 = projected_points((3*n+1):end, 1:2);
  xs = reshape(projected_points(:,1), [n 4]);
  ys = reshape(projected_points(:,2), [n 4]);
  exact = [xs(:,1), ys(:,1), xs(:,2), ys(:,2), xs(:,3), ys(:,3), xs(:,4), ys(:,4)];

  xs = sort(xs, 2);
  ys = sort(ys, 2);
  candidates(:,1) = mean(xs(:,1:2), 2);
  candidates(:,3) = mean(xs(:,3:4), 2);
  candidates(:,2) = mean(ys(:,1:2), 2);
  candidates(:,4) = mean(ys(:,3:4), 2);
end