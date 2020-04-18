function [clusters_array]=ClusterSubjectsPeakDensity(mdist,density_cutoff)
% ClusterSubjectsPeakDensity is an implementation of density-peak clustering. 
%
%% Syntax
% [clusters_array]=ClusterSubjectsPeakDensity(mdist_square,percent)
%
%% Description
% ClusterSubjectsPeakDensity gets a similiarity between each pair of samples and a cutoff distance 
% and returns an array with the cluster number for each dyad. The
% clustering is based on calculating the density between all samples
% (according to the similarity matrix) and the distance between each
% sample and the most densed sample that follows. The "percent" variable
% provides a cutoff radius that can be calculated based on changes in
% entropy.
%
% Required Input.
% mdist_square: the similiarity values between each pair of samples 
% percent: cut_off radius for calculating density
%
% Output.
% clusters_array: includes the cluster number for each sample

ND=max(mdist(:,2));
NL=max(mdist(:,1));
if (NL>ND)
  ND=NL;
end
N=size(mdist,1);
for i=1:ND
  for j=1:ND
    dist(i,j)=0;
  end
end
for i=1:N
  ii=mdist(i,1);
  jj=mdist(i,2);   
  dist(ii,jj)=mdist(i,3);
  dist(jj,ii)=mdist(i,3);
end

% calculates the radius based on the density cut_off (in percentage)
position=round(N*density_cutoff/100);
sda=sort(mdist(:,3));
dc=sda(position);
fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);

%% Calculates density for each sample (rho array) and distance (delta array)
for i=1:ND
  rho(i)=0.;
end
for i=1:ND-1
 for j=i+1:ND
   if (dist(i,j)<dc)
      rho(i)=rho(i)+1.;
      rho(j)=rho(j)+1.;
   end
 end
end
maxd=max(max(dist));

% sort density to calculate delta
[rho_sorted,ordrho]=sort(rho,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

% builds delta array
for ii=2:ND
   delta(ordrho(ii))=maxd;
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));
disp('Generated file:DECISION GRAPH')
disp('column 1:Density')
disp('column 2:Delta')

%% Choosing outlier version (gamma is calculated automatically in the next section)
fid = fopen('DECISION_GRAPH', 'w');
for i=1:ND
   fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
end

disp('Select a rectangle enclosing cluster centers')
scrsz = get(0,'ScreenSize');
figure('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);
for i=1:ND
  ind(i)=i;
  gamma(i)=rho(i)*delta(i);
end
subplot(2,1,1)
tt=plot(rho(:),delta(:),'o','MarkerSize',1,'MarkerFaceColor','k','MarkerEdgeColor','k');
text(rho(:),delta(:),strread(num2str(ind)','%s'));
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')
subplot(2,1,2)
tt=plot(ones(length(ind),1),gamma(:),'o','MarkerSize',1,'MarkerFaceColor','k','MarkerEdgeColor','k');
text(ones(length(ind),1),gamma(:),strread(num2str(ind)','%s'));
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')
subplot(2,1,1)
rect = getrect;
rhomin=rect(1);
deltamin=rect(2);
NCLUST=0;
for i=1:ND
  clusters_array(i)=-1;
end
for i=1:ND
  if ( (rho(i)>rhomin) && (delta(i)>deltamin))
     NCLUST=NCLUST+1;
     clusters_array(i)=NCLUST;
     icl(NCLUST)=i;
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')

%% calculating gamma automatically from standard deviation
% gamma_outliers = find(gamma>(mean(gamma)+3*std(gamma)));
% for i=1:ND
%   if (ismember(i,gamma_outliers))
%      NCLUST=NCLUST+1;
%      clusters_array(i)=NCLUST;
%      icl(NCLUST)=i;
%   end
% end

%% assignation to clusters
for i=1:ND
  if (clusters_array(ordrho(i))==-1)
    clusters_array(ordrho(i))=clusters_array(nneigh(ordrho(i)));
  end
end

%% Calculating halo around the clusters
for i=1:ND
  halo(i)=clusters_array(i);
end
if (NCLUST>1)
  for i=1:NCLUST
    bord_rho(i)=0.;
  end
  for i=1:ND-1
    for j=i+1:ND
      if ((clusters_array(i)~=clusters_array(j))&& (dist(i,j)<=dc))
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(clusters_array(i))) 
          bord_rho(clusters_array(i))=rho_aver;
        end
        if (rho_aver>bord_rho(clusters_array(j))) 
          bord_rho(clusters_array(j))=rho_aver;
        end
      end
    end
  end
  for i=1:ND
    if (rho(i)<bord_rho(clusters_array(i)))
      halo(i)=0;
    end
  end
end
for i=1:NCLUST
  nc=0;
  nh=0;
  for j=1:ND
    if (clusters_array(j)==i) 
      nc=nc+1;
    end
    if (halo(j)==i) 
      nh=nh+1;
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(i),nc,nh,nc-nh);
end

%% Print MDS space for the clusters
cmap=colormap;
for i=1:NCLUST
   ic=int8((i*64.)/(NCLUST*1.));
   subplot(2,1,1)
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
end
subplot(2,1,2)
disp('Performing 2D nonclassical multidimensional scaling')
Y1 = mdscale(dist, 2, 'criterion','metricstress');
plot(Y1(:,1),Y1(:,2),'o','MarkerSize',2,'MarkerFaceColor','k','MarkerEdgeColor','k');
text(Y1(:,1),Y1(:,2),strread(num2str(ind)','%s'));
title ('2D Nonclassical multidimensional scaling','FontSize',15.0)
xlabel ('X')
ylabel ('Y')
for i=1:ND
 A(i,1)=0.;
 A(i,2)=0.;
end
for i=1:NCLUST
  nn=0;
  ic=int8((i*64.)/(NCLUST*1.));
  for j=1:ND
    if (halo(j)==i)
      nn=nn+1;
      A(nn,1)=Y1(j,1);
      A(nn,2)=Y1(j,2);
    end
  end
  hold on
  plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',6,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
end
faa = fopen('CLUSTER_ASSIGNATION', 'w');
disp('Generated file:CLUSTER_ASSIGNATION')
disp('column 1:element id')
disp('column 2:cluster assignation without halo control')
disp('column 3:cluster assignation with halo control')
for i=1:ND
   fprintf(faa, '%i %i %i\n',i,clusters_array(i),halo(i));
end
