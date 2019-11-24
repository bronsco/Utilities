function out = fillDescription(in,bez)
out = in;
for ii = 1:size(in,2)
    if isempty(in{1,ii})
        out{1,ii} = [bez,'_{',num2str(ii),'}'];
    else
        out{1,ii} = in{1,ii};
    end
end
end % end fillDescription