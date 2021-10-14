

%%function to do a boxcar average based on measurement cycle

%output is a matrix and a cell array. 
%C1 of matrix is avg time
%C2-C9 is avg current at types 1-8
%C1 of cell array is all of the types in that cycle
%C2 of cell array is all of the time in that cycle
%C3-C10 of cell array is all current at types 1-8

function[array_out, cell_out]=cycle_boxcar7(my_type, my_time, my_current)

 diff_types=unique(my_type);

if length(diff_types) ~=7 %this function will only work for 7 types
    error('now young skywalker, you will die!')
end

%decision statement whether this is test or reference 

switch max(diff_types)
    case 7
        where_cycles_are=find(my_type(1:end-1)==6 & my_type(2:end)==1); %find the indicies where 6 is followed by 1. Each of these is the end of a cycle 
    case 15
        where_cycles_are=find(my_type(1:end-1)==14 & my_type(2:end)==9); %find the indicies where 6 is followed by 1. Each of these is the end of a cycle 
end

number_cycles=length(where_cycles_are); %number of cycles

cell_out=cell(number_cycles,9); %preallocate an empty cell array 

 cell_out{1,1}=my_type(1:where_cycles_are(1)); %assign type of first cycle
 cell_out{1,1}(:,2)=my_time(1:where_cycles_are(1)); %assign time of first cycle
 cell_out{1,1}(:,3)=my_current(1:where_cycles_are(1)); %assign current of first cycle
 
 indexer=where_cycles_are(1)+1; %index the beginning of second cycle 
 counter=2; %counter for cycle number. Each cycle is a row of the array. 
 
 for zz=2:length(where_cycles_are) %assign type, time, current of remaining cycles to cell array 
   cell_out{counter,1}(:,1)=my_type(indexer:where_cycles_are(zz));
   cell_out{counter,1}(:,2)=my_time(indexer:where_cycles_are(zz));
   cell_out{counter,1}(:,3)=my_current(indexer:where_cycles_are(zz));
   counter=counter+1;
   indexer=where_cycles_are(zz)+1;
 end

 switch max(diff_types)
     case 7
        for zz=1:number_cycles
            cell_out{zz,2}=cell_out{zz,1}(:,2); %assign cycle time to row zz column 2 cell array
            cell_out{zz,3}=cell_out{zz,1}(cell_out{zz,1}(:,1)==1,3); %assign type 1 to row zz column 3 of cell array
            cell_out{zz,4}=cell_out{zz,1}(cell_out{zz,1}(:,1)==2,3); %assign type 2 to row zz column 4 of cell array
            cell_out{zz,5}=cell_out{zz,1}(cell_out{zz,1}(:,1)==3,3); %assign type 3 to row zz column 5 of cell array
            cell_out{zz,6}=cell_out{zz,1}(cell_out{zz,1}(:,1)==4,3); %assign type 4 to row zz column 6 of cell array
            cell_out{zz,7}=cell_out{zz,1}(cell_out{zz,1}(:,1)==5,3); %assign type 5 to row zz column 7 of cell array
            cell_out{zz,8}=cell_out{zz,1}(cell_out{zz,1}(:,1)==6,3); %assign type 6 to row zz column 8 of cell array
            cell_out{zz,9}=cell_out{zz,1}(cell_out{zz,1}(:,1)==7,3); %assign type 7 to row zz column 9 of cell array
        end
     case 15
        for zz=1:number_cycles
            cell_out{zz,2}=cell_out{zz,1}(:,2); %assign cycle time to row zz column 2 cell array
            cell_out{zz,3}=cell_out{zz,1}(cell_out{zz,1}(:,1)==9,3); %assign type 1 to row zz column 3 of cell array
            cell_out{zz,4}=cell_out{zz,1}(cell_out{zz,1}(:,1)==10,3); %assign type 2 to row zz column 4 of cell array
            cell_out{zz,5}=cell_out{zz,1}(cell_out{zz,1}(:,1)==11,3); %assign type 3 to row zz column 5 of cell array
            cell_out{zz,6}=cell_out{zz,1}(cell_out{zz,1}(:,1)==12,3); %assign type 4 to row zz column 6 of cell array
            cell_out{zz,7}=cell_out{zz,1}(cell_out{zz,1}(:,1)==13,3); %assign type 5 to row zz column 7 of cell array
            cell_out{zz,8}=cell_out{zz,1}(cell_out{zz,1}(:,1)==14,3); %assign type 6 to row zz column 8 of cell array
            cell_out{zz,9}=cell_out{zz,1}(cell_out{zz,1}(:,1)==15,3); %assign type 7 to row zz column 9 of cell array
        end
 end

array_out=cellfun(@mean, cell_out(:, 2:9));  
end %end function 