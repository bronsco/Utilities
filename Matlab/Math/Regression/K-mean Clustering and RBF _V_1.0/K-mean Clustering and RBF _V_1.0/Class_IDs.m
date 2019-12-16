function [Class_IDS]=Class_IDs(NC,NS);
%% Function for Generation Class_ids
% NC=Number of Classes
% NS=Number of Subjects
Class_IDS=zeros(NC*NS,NC);
pointer=1;
for j=1:NC
    for i=1:NS
        Class_IDS(pointer,j)=1;
        pointer=pointer+1;
    end
end
