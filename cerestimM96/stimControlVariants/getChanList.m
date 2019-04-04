% all groups of 5 electrodes
chanList={11,12,16,20,21,29}; % pick some channels 4

chanListAppend = {}; % DO NOT WRITE INTO THIS ONE

for c = 1:numel(chanList)
    chanListAppend{end+1} = [chanList{[1:c-1 c+1:end]}];
end

chanList = [chanList,chanListAppend];


%             % all combinations of those channels
%             chanListAppend = {}; % DO NOT USE THIS ONE
%             for c = 1:numel(chanList)
%                 for j = c+1:numel(chanList)
%                     chanListAppend{end+1} = [chanList{c},chanList{j}];
%                 end
%             end
%             chanList = [chanList,chanListAppend];