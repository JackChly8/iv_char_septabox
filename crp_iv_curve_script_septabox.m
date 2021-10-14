%initialize workspace 
clear
clc
close all
disp 'running'

%% 2. tell  matlab what files you are giving it 

my_files=dir('*.csv');

%% 3. set your inputs


%how many csv files in the structure my_files (same # as in the directory)
%MAXIMUM IS 9 (without the color bar), because you will run out of colors
%to plot
num_files=6;

%from the filenames, put what they are. ML reads in the files
%"alphabetically-ish" so you need to check manually what order they are
%by going in the dir output
CRP=[1,2,3,4,5,6];

%from the filenames, identify the samples here
%yes, you have to fill in both
%they are different data types and are used for different things 
Figure_titles=char({'100U/L'});
legcol={'0.01V','0.025V','0.05V','0.1V','0.2V','0.3V'};

%Define Vds used for each file
Vds = [0.01, 0.025, 0.05, 0.1, 0.2, 0.3];

%Define window for data
window_min = 1;
window_max = 7200;


%Do you wanna subtract the reference sensor data from the test sensor data?
subtract_ref = 0;

%I commented the rescaling out because when you rescale the data, it does
%not overwrite the input data. So the boolean is neutral. You want to
%rescale the data if you are averaging the sensors, because the Leti
%sensors are all over the place. 

% %Do you wanna rescale your data?
% rescale_data = 1;

%what range in x-values are the samples you want to highlight

crp_start_time = 1300; %x coordinate 
crp_end_time = 2500;

crp_width=crp_end_time-crp_start_time; %width 

control_start_time_1= 440; %x coordinate
control_end_time_1 = 1300;

ctrl1_w=control_end_time_1-control_start_time_1; %width 

control_start_time_2 = 2500; %x_coordinate
control_end_time_2 = 3600;

ctrl2_w=control_end_time_1-control_start_time_1; %width 

% %What range in Y-values are the samples you want to highlight? (For scaled, -0.2 to 1.2 is generally good)

%y coordinate of rectangle
rect_y=0.1;

%how high do you want the rectangle
rect_height=0.7;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%nine distinguisable colors
C={[0.80,0.40,0.43],[0.20,0.13,0.53],[0.87,	0.80,0.47], [0.07,0.47,0.20], [0.53,0.80,0.93],[0.53,0.13,0.33],[0.27,0.67,0.60],[0.60,0.60,0.20],[0.67,0.27,0.60]};


%how many types
%it has to be the maximum type
types=15;

%subplot titles
my_titles={'Type1', 'Type2', 'Type3', 'Type4','Type5', 'Type6', 'Type7', 'Type8', 'Type9', 'Type10', 'Type11', 'Type12', 'Type13', 'Type14', 'Type15', 'Type16'}; 

%Open figures
Fig_1=figure('position', [30 20 1800 1800], 'Name', 'Boxcar Average, Test Sensors');
Fig_2=figure('position', [30 20 1800 1800], 'Name', 'Boxcar Average, Ref Sensors');
Fig_4=figure('position', [30 20 1800 1800], 'Name', 'iv characteristics');
if subtract_ref == 1
    Fig_3=figure('position', [30 20 1800 1800], 'Name', 'Boxcar Average, T-R');
    my_titles2={'Type1-Type9', 'Type2-Type10', 'Type3-Type11', 'Type4-Type12','Type5-Type13', 'Type6-Type14', 'Type7-Type15', 'Type8-Type16'}; 
end

%set this to a high number. higher than the number of measurement cycles 
max_cycles=200;


for m =1:num_files
 
    % organize the data
    A=readmatrix(my_files(m).name); %load the data
    dat(m).filename=my_files(m).name; %store the filename
    dat(m).CRP=CRP(m); %store CRP concentration
    dat(m).Time=A(:, 1); %store time
    dat(m).Test_Current=A(:,3)*1e9; %store test current
    dat(m).Test_Type=A(:, 4); %store test type
    dat(m).Ref_Current=A(:,6)*1e9; %store ref current
    dat(m).Ref_Type=A(:, 7); %store ref type

    %split by sensor and do the boxcar average, by measurement cycle
   [dat(m).Test_BCAvg, dat(m).Test_BC_Split]=cycle_boxcar7(dat(m).Test_Type, dat(m).Time, dat(m).Test_Current);  
   [dat(m).Ref_BCAvg, dat(m).Ref_BC_Split]=cycle_boxcar7(dat(m).Ref_Type, dat(m).Time, dat(m).Ref_Current);
   
    if size(dat(m).Test_BCAvg,1) > max_cycles %throw an error if you have more than 200 cycles
        error('help me obi-wan! you are my only hope!')
    end
    
    banana=1; % initialize counter for subplots and matrix columns 
    
    for gg=2:size(dat(m).Test_BCAvg,2)

        %hampel filter of test and reference sensors to remove the outliers
        dat(m).Test_BCAvg_H(:,banana)=hampel(dat(m).Test_BCAvg(:,gg),3);
        dat(m).Ref_BCAvg_H(:,banana)=hampel(dat(m).Ref_BCAvg(:,gg),3);
        
        %logical index goes here, select current in measurement window 
        dat(m).T_logical = dat(m).Test_BCAvg(:,1) > window_min & dat(m).Test_BCAvg(:,1) < window_max;
        dat(m).Test_BCAvg_L(:,banana)=dat(m).Test_BCAvg_H(dat(m).T_logical,banana);
        dat(m).Ref_BCAvg_L(:,banana)=dat(m).Ref_BCAvg_H(dat(m).T_logical,banana);
        
        %baseline
        dat(m).Tbaseline(banana)=max(dat(m).Test_BCAvg_H(:,banana));
        dat(m).Rbaseline(banana)=max(dat(m).Ref_BCAvg_H(:,banana));

        %plot test sensors
        figure(Fig_1)
        subplot (2,4,banana)
        hold on
        plot(dat(m).Test_BCAvg(dat(m).T_logical,1),dat(m).Test_BCAvg_L(:,banana) , 'o', 'color', C{m}, 'MarkerFaceColor', C{m}, 'MarkerSize', 5) %only is plotting time that meets the logical condition
        hold off

        %plot reference sensors
        figure(Fig_2)
        subplot (2,4,banana)
        hold on
        plot(dat(m).Ref_BCAvg(dat(m).T_logical,1),dat(m).Ref_BCAvg_L(:,banana) , 'o', 'color', C{m}, 'MarkerFaceColor', C{m}, 'MarkerSize', 5) %only is plotting time that meets the logical condition
        hold off
        
        %Find Average Current
        dat(m).avgcurrent(banana)=mean(dat(m).Test_BCAvg_L(:,banana));
        
        %Plot Average Current vs. Vds
        figure(Fig_4)
        subplot (2,4,banana)
        hold on
        plot(Vds(m),dat(m).avgcurrent(:,banana) , 'o', 'color', C{m}, 'MarkerFaceColor', C{m}, 'MarkerSize', 5) %only is plotting time that meets the logical condition
        hold off
        
        %subtract the reference, if you want 
        if subtract_ref == 1
            dat(m).TsubR(:,banana)=dat(m).Test_BCAvg_L(:,banana)-dat(m).Ref_BCAvg_L(:,banana);
            figure(Fig_3)
            subplot (2,4,banana)
            hold on
            plot(dat(m).Ref_BCAvg(dat(m).T_logical,1), dat(m).TsubR(:,banana) , 'o', 'color', C{m}, 'MarkerFaceColor', C{m}, 'MarkerSize', 5) %only is plotting time that meets the logical condition
            hold off
        end
        banana=banana+1; %
    end %end statement for number of sensors 
end %end statement for number of files

%% make the boxcar avg plots presentable 
peach=1; %subplot counter is back 

for gg=1:types
    if gg < 8
       figure(Fig_1)
       subplot(2,4,gg)
       title(my_titles{gg})
       ylabel('I(nA)')
       xlabel('Time (s)')
       grid on; box on;
       set(gca, 'Fontsize', 14)
       legend(legcol{:}, 'location', 'Northeast');
       
       figure(Fig_4)
       subplot(2,4,gg)
       title(my_titles{gg})
       ylabel('I(nA)')
       xlabel('Vds (V)')
       grid on; box on;
       set(gca, 'Fontsize', 14)
       legend(legcol{:}, 'location', 'Northwest');
    elseif gg > 8
        figure(Fig_2)
        subplot(2,4,peach)
        title(my_titles{gg})
        ylabel('I(nA)')
        xlabel('Time (s)')
        peach=peach+1;
        grid on; box on;
        set(gca, 'Fontsize', 14)
        legend(legcol{:}, 'location', 'northeast');
    end
end