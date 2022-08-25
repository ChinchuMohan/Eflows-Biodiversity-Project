function [Rho P] = fcnMatrixPlots2grp(A, VarA, B, VarB, alpha1, alpha2)
% This function produces matrix scatterplots of 2 sets of variables (A & B)
% with least-squared fit lines.
% Input A is a mxn matrix (m: # of observations, n: # of variables).
% Input B is a mxs matrix (m: # of observations, s: # of variables).
% VarA is a cell array with variable names correspond to columns of A (left labels).
% VarB is a cell array with variable names correspond to columns of B (bottom labels).
% Values displayed in each plot are Pearson correlation coefficient[p-value]sample size.
% In-plot values in red if <= alpha1, red+BOLD if <= alpha2.
% Output: Correlation coefficients (Rho) and the associated p-values (P).
% Change values in gap, marg_x, & marg_y to adjust spacing of subplots.
% In the main program, use orient tall or landscape to save the plots.
% Example:
% VarA = {'Age' 'Height' 'Mass' 'BMI'};
% A = [58 193 80 22; 49 175 71 23; 47 178 77 24; NaN 175 75 28;...
%  60 185 84 24;45 165 55 20; 43 198 75 22; 36 173 66 22];
% VarB = {'GaitSpd' 'StrLgn' 'Cadence' 'StpWidth'};
% B = [139 165 101 10; 133 152 105 10; 126 148 101 10; 132 146 108 13;...
%  113 150 90 7; 170 162 123 6; 146 164 106 12; 125 133 113 6];
% fcnCorrMatrixPlots2grp(A, VarA, B, VarB, .05, 0.01)
% John W. Chow, jchow@mmrcrehab.org, July 21, 2020
% Methodist Rehabilitation Center, Jackson, Mississippi, USA
% Created using R2015a
scrsz = get(0,'ScreenSize');
% Define a figure window position and size (full screen)
figure('Position',[.05*scrsz(3) .05*scrsz(4) .9*scrsz(3) .87*scrsz(4)]);
[m,n] = size(A);    % # of rows and columns of the A matrix
[r,s] = size(B);    % # of rows and columns of the B matrix
% Adjust marker and font sizes and spacing according to the # of rows and columns
if mean([n s]) < 14
 gapsize = .0195-.00175*mean([n s]);        % Gap size
 symbolsize = 8.909-.50*mean([n s]);        % Marker size
 labelsize1 = 12.909-.55*mean([n s]);       % Font size for ticklabel
 labelsize2 = 12.909-.7*s;             % Font size for text inside plots
else
 gapsize = 0;
 symbolsize = 3;
 labelsize1 = 20;
 labelsize2 = 20;
end
if m ~= r
 disp('Error: # of observations not matched ...'), pause
end
if n ~= length(VarA)
 disp('Warning: # of variables not matched in A ...'), pause
end
if s ~= length(VarB)
 disp('Warning: # of variables not matched in B ...'), pause
end
%% Create subplot axes %%
% Modification of the function 'tight_subplot' by Pekka Kumpulainen
% www.mathworks.com/matlabcentral/fileexchange/27991-tight-subplot
gap = [gapsize gapsize];     % Gap height and width btw adjacent subplots
marg_x = [.1 .05];      % Left and right margins of the figure
marg_y = [.1 .05];      % Bottom and top margins of the figure
% Determine the axis lengths of each subplot %
yAxLg = (1-sum(marg_y)-(n-1)*gap(1))/n;
xAxLg = (1-sum(marg_x)-(s-1)*gap(2))/s;
px = marg_x(1);              % x-origin of subplots in the 1st column
py = 1-marg_y(2)-yAxLg;      % y-origin of subplots in the 1st row
ha = zeros(n*s,1);      % Define an array of handles
for i = 1:n      % # of rows of subplots = # of VarA
 
 for j = 1:s      % # of columns of subplots = # of VarB
  
  pos = (i-1)*s+j;    % Subplot position (ID)
  ha(pos) = axes('Units','normalized','Position',[px py xAxLg yAxLg],...
   'XTickLabel','','YTickLabel','');
  
  px = px+xAxLg+gap(2);    % x-origin of subplots in the next column
  
 end     % j-loop for columns of subplot
 
 px = marg_x(1);        % Reset x-origin of subplots to the 1st column
 py = py-yAxLg-gap(1);  % y-origin of the next subplot in the same column
 
end      % i-loop for rows of subplot
%% End creating axes
%% Create scatterplots with least-squared fitted lines
ll=1;
for i = 1:n        % # of rows of subplots = # of VarA
 for j = 1:s       % # of columns of subplots = # of VarB
  
  X = B(:,j); Y = A(:,i);    % 2 sets of data to be processed
  
  % Remove data pairs with missing data %
  for k = m:-1:1
   if isnan(X(k)) == 1 || isnan(Y(k)) == 1
    X(k) = [];  Y(k) = [];
   end
  end
  
  N = length(X);   % Number of data pairs to analyze
  
  % Pearson's correlation coefficient & associated p-value
  % (no Statistics Toolbox needed)
  [rho,p] = corrcoef(X,Y);  
  Rho(i,j) = rho(2,1);
  P(i,j) = p(2,1);
  
  loc = (i-1)*s+j;     % Subplot location ID
  axes(ha(loc));
% % %   plot(X, Y, 'ob', 'filled','MarkerSize', symbolsize,'MarkerFaceAlpha',0.5)      % Marker shape: circle

% % % % p=scatter(X, Y,'o','MarkerFaceColor','b','MarkerEdgeColor','b');     % Marker shape: circle

X(isnan(X))=0;
Y(isnan(Y))=0;

% Heat map based on X value
% % % % % cmap = jet(256);
% % % % % v = rescale(X, 1, 256); % Nifty trick!
% % % % % numValues = length(X);
% % % % % markerColors = zeros(numValues, 3);
% % % % % % Now assign marker colors according to the value of the data.
% % % % % for k = 1 : numValues
% % % % %     row = round(v(k));
% % % % %     markerColors(k, :) = cmap(row, :);
% % % % % end
% % % % % % Create the scatter plot.
% % % % % scatter(X, Y, [], markerColors);

% 
% figure()
heatscatter(X, Y)
colormap jet
caxis([0 50])


% % coef = polyfit(X,Y);
% %  h = refline(coef(1), coef(2));
refline;             % least-squared fitted line
 h = refline;
 set(h,'color','r','Linewidth',1)  % fitted line in red color
% % %     p.MarkerFaceAlpha = .3;
% % % p.MarkerEdgeAlpha = .3;
  % Define the ranges for the x- and y-axis and text location %
  axis([min(X)-.1*(max(X)-min(X)) max(X)+.1*(max(X)-min(X))...
   min(Y)-.1*(max(Y)-min(Y)) max(Y)+.25*(max(Y)-min(Y))]);
  xLimit = get(gca, 'xlim');
  xLoc = xLimit(1) + .05*range(xLimit);     % x location for text
  yLimit = get(gca, 'ylim');
  yLoc = yLimit(1) + .915*range(yLimit);    % y location for text
  
  % Add corr coef, p-value, and sample size to each plot %
% % %   if P(i,j) <= alpha2   % Red+BOLD if p <= alpha2 (very significant corr)
% % %    text(xLoc,yLoc,[num2str(Rho(i,j),'%.3f') ' [' num2str(P(i,j),'%.4f')...
% % %     '] ' ],'FontSize',labelsize2,'Color','r','Fontweight','bold');
% % %   elseif P(i,j) <= alpha1    % Red if p <= alpha1 (significant corr)
% % %    text(xLoc,yLoc,[num2str(Rho(i,j),'%.3f') ' [' num2str(P(i,j),'%.4f')...
% % %     '] ' ],'FontSize',labelsize2,'Color','r');
% % %   else             % Otherwise, black (non-significant corr)
% % %    text(xLoc,yLoc,[num2str(Rho(i,j),'%.3f') ' [' num2str(P(i,j),'%.3f')...
% % %     '] '],'FontSize',labelsize2,'Color','k');
% % %   end
  
  if j == 1   % Add ylabels to the subplots in the first column (VarA)
   ylabel(regexprep(VarA(i), '_', '-'),'FontSize',16,'FontWeight','bold');
   ax = gca;
   ax.FontSize = labelsize1;     % Ticklabel size
  else
   set(gca, 'YTickLabel','');
  end
  
  if i == n   % Add xlabels to the subplots in the last row (VarB)
   xlabel(regexprep(VarB(j), '_', '-'),'FontSize',16,'FontWeight','bold');
   ax = gca;
   ax.FontSize = labelsize1;
  else
   set(gca, 'XTickLabel','');
  end
  % saving transparent figs
  cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_paper_revision\Fig\no AmR\test'
  set(gcf, 'color', 'none');   
set(gca, 'color', 'none');
set(gca,'FontSize',16,'FontWeight','Bold');
  exportgraphics(gca,sprintf('plot%d.pdf',ll),'BackgroundColor','none')
  ll=ll+1;
  cd 'D:\Academic Backups\PostDoc-Usask\PB_files\Analysis\Data_MattisGroup\EFE data\MatlabData\WeightedAnalysis\Amphi_IUNC_RichData\RichnessCompare'

  clear X Y
  
 end
end
Rho, P;
