function [proposals, scores] = deduplicate_proposals(proposals, scores)
% Be sure to call this AFTER the proposals are in the right order.
% We cannot just order by score, because not all proposal methods are
% sorted by the same rule.

  if isempty(proposals)
    return;
  end

  rproposals = proposals;
  rproposals(:,1:2) = round(rproposals(:,1:2));
  rproposals(:,3:4) = ceil(rproposals(:,3:4));
  [~, idxs] = unique(rproposals, 'rows', 'stable');
  proposals = proposals(idxs,:);
  if ~isempty(scores)
    scores = scores(idxs);
  end

end
