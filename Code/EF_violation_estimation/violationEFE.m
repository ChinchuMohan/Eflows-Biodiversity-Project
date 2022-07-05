function [violation_annual, violation_annual_severity]= violationEFE(EFE_state)

% function for calculating the percentage of months with EFE state
% violation
% input:
%   EFE_state: EF envolop violation state; 
%   -ve -> violated lower bound, 0 -> no violation, >100 -> upper bound
%   violation

Startdate = datenum('1976-01-01','yyyy-mm-dd');
Enddate = datenum('2005-12-31','yyyy-mm-dd');

EFE_state=EFE_state'; % the cols rep basin and row rep monthly data

x=Startdate:Enddate;
dd=datevec(x);
filterdate=dd(:,3)==1;
yearMonth=dd(filterdate,1:2);

i=1;
for yy=1976:2005
    filter1=yearMonth(:,1)==yy;
    EFE_state_filtered=EFE_state(filter1,:);
    filter_violate_all=(EFE_state_filtered<0 | EFE_state_filtered>100);
    filter_violate_upper= EFE_state_filtered>100;
    filter_violate_lower= EFE_state_filtered<0;
    
    for t=1:4376
    % calculating severity
    violation_annual_severity.EFE_violation_s_all(i,t)=nanmean(EFE_state_filtered(filter_violate_all(:,t),t));
    violation_annual_severity.EFE_violation_s_lower(i,t)=nanmean(EFE_state_filtered(filter_violate_lower(:,t),t));
    violation_annual_severity.EFE_violation_s_upper(i,t)=nanmean(EFE_state_filtered(filter_violate_upper(:,t),t));
    end
    % percentage of months violated
% %     EFE_violation_all(i,1)=yy; EFE_violation_upper(i,1)=yy;
% %     EFE_violation_lower(i,1)=yy;
    
    violation_annual.EFE_violation_all(i,:)=nansum(filter_violate_all)./12;
    violation_annual.EFE_violation_upper(i,:)=nansum(filter_violate_upper)./12;
    violation_annual.EFE_violation_lower(i,:)=nansum(filter_violate_lower)./12;
    
    violation_annual.violate_year(i,1)=yy;
    
    i=i+1;
    
end

% changing back to normal form
violation_annual.EFE_violation_all=violation_annual.EFE_violation_all';
violation_annual.EFE_violation_upper=violation_annual.EFE_violation_upper';
violation_annual.EFE_violation_lower=violation_annual.EFE_violation_lower';

violation_annual_severity.EFE_violation_s_all=violation_annual_severity.EFE_violation_s_all';
violation_annual_severity.EFE_violation_s_upper=violation_annual_severity.EFE_violation_s_upper';
violation_annual_severity.EFE_violation_s_lower=violation_annual_severity.EFE_violation_s_lower';


end    
        
    