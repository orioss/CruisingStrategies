function [unnorm_dist,accum_distance,normal_fact,optimal_path,signal1_warped,signal2_warped]=Calculate_2D_DTW(signal1,signal2,print_flag)
% Calculate_2D_DTW is an implementation of Dynamic Time Warping algorithm on 2D signals. 
%
%% Syntax
% [unnorm_dist,accum_distance,normal_fact,optimal_path,signal1_warped,signal2_warped]=Calculate_2D_DTW(signal1,signal2,print_flag)
%
%% Description
% Calculate_2D_DTW gets two 2D signals and performs Dynamic Time Warping
% (DTW) on them. The function returns the similairty between them (as a distance
% measure and the normalization factor and the warped signals. 
%
% Required Input.
% signal1: the vector you are testing against (partner 1 path)
% signal2: the vector you are testing (partner 2 path)
% print_flag: plot flag: 1 (yes), 0(no)
%
% Output. 
% unnorm_dist: unnormalized distance between the two signals
% accum_distance: the accumulated distance matrix
% normal_fact: the normalizing factor
% optimal_path: the DTW optimal path 
% signal1_warped: the warped signal1 vector
% signal2_warped: the warped signal2 vector

%% Calcuates 2D similarity (as distance)
M=size(signal1,1); 
N=size(signal2,1); 
for x=1:M
    for y=1:N
       d(x,y) = calcdist([signal1(x,:);signal2(y,:)]);
    end
end

%% run the implementation of the dynamic time warping algorithm 
accum_distance=zeros(size(d));
accum_distance(1,1)=d(1,1);

for m=2:M
    accum_distance(m,1)=d(m,1)+accum_distance(m-1,1);
end
for n=2:N
    accum_distance(1,n)=d(1,n)+accum_distance(1,n-1);
end
for m=2:M
    for n=2:N
        accum_distance(m,n)=d(m,n)+min(accum_distance(m-1,n),min(accum_distance(m-1,n-1),accum_distance(m,n-1))); 
    end
end

unnorm_dist=accum_distance(M,N);
n=N;
m=M;
normal_fact=1;
optimal_path=[M N];
while ((n+m)~=2)
    if (n-1)==0
        m=m-1;
    elseif (m-1)==0
        n=n-1;
    else 
      [values,number]=min([accum_distance(m-1,n),accum_distance(m,n-1),accum_distance(m-1,n-1)]);
      switch number
      case 1
        m=m-1;
      case 2
        n=n-1;
      case 3
        m=m-1;
        n=n-1;
      end
  end
    normal_fact=normal_fact+1;
    optimal_path=[m n; optimal_path]; 
end

signal1_warped=signal1(optimal_path(:,1));
signal2_warped=signal2(optimal_path(:,2));

%% Printing the DTW procedure with warped signals 
if print_flag
    
    % Prints accumulated distance matrix and optimal path
    figure('Name','DTW - Accumulated distance matrix and optimal path', 'NumberTitle','off');
    
    main1=subplot('position',[0.19 0.19 0.67 0.79]);
    image(accum_distance);
    cmap = contrast(accum_distance);
    colormap(cmap); 
    hold on;
    x=optimal_path(:,1); y=optimal_path(:,2);
    ind=find(x==1); x(ind)=1+0.2;
    ind=find(x==M); x(ind)=M-0.2;
    ind=find(y==1); y(ind)=1+0.2;
    ind=find(y==N); y(ind)=N-0.2;
    plot(y,x,'-w', 'LineWidth',1);
    hold off;
    axis([1 N 1 M]);
    set(main1, 'FontSize',7, 'XTickLabel','', 'YTickLabel','');

    colorb1=subplot('position',[0.88 0.19 0.05 0.79]);
    nticks=8;
    ticks=floor(1:(size(cmap,1)-1)/(nticks-1):size(cmap,1));
    mx=max(max(accum_distance));
    mn=min(min(accum_distance));
    ticklabels=floor(mn:(mx-mn)/(nticks-1):mx);
    colorbar(colorb1);
    set(colorb1, 'FontSize',7, 'YTick',ticks, 'YTickLabel',ticklabels);
    set(get(colorb1,'YLabel'), 'String','Distance', 'Rotation',-90, 'FontSize',7, 'VerticalAlignment','bottom');
    
    left1=subplot('position',[0.07 0.19 0.10 0.79]);
    plot(signal1,M:-1:1,'-b');
    set(left1, 'YTick',mod(M,10):10:M, 'YTickLabel',10*rem(M,10):-10:0)
    axis([min(signal1) 1.1*max(signal1) 1 M]);
    set(left1, 'FontSize',7);
    set(get(left1,'YLabel'), 'String','Samples', 'FontSize',7, 'Rotation',-90, 'VerticalAlignment','cap');
    set(get(left1,'XLabel'), 'String','Amp', 'FontSize',6, 'VerticalAlignment','cap');
    
    bottom1=subplot('position',[0.19 0.07 0.67 0.10]);
    plot(signal2,'-r');
    axis([1 N min(signal2) 1.1*max(signal2)]);
    set(bottom1, 'FontSize',7, 'YAxisLocation','right');
    set(get(bottom1,'XLabel'), 'String','Samples', 'FontSize',7, 'VerticalAlignment','middle');
    set(get(bottom1,'YLabel'), 'String','Amp', 'Rotation',-90, 'FontSize',6, 'VerticalAlignment','bottom');
    
    % Prints warped signals
    figure('Name','DTW - warped signals', 'NumberTitle','off');
    subplot(1,2,1);
    set(gca, 'FontSize',7);
    hold on;
    plot(signal1,'-bx');
    plot(signal2,':r.');
    hold off;
    axis([1 max(M,N) min(min(signal1),min(signal2)) 1.1*max(max(signal1),max(signal2))]);
    grid;
    legend('signal 1','signal 2');
    title('Original signals');
    xlabel('Samples');
    ylabel('Amplitude');
    subplot(1,2,2);
    set(gca, 'FontSize',7);
    hold on;
    plot(signal1_warped,'-bx');
    plot(signal2_warped,':r.');
    hold off;
    axis([1 normal_fact min(min([signal1_warped; signal2_warped])) 1.1*max(max([signal1_warped; signal2_warped]))]);
    grid;
    legend('signal 1','signal 2');
    title('Warped signals');
    xlabel('Samples');
    ylabel('Amplitude');
end