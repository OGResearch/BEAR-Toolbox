%% Setting up opt structure
fileName = "+nw_favar/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opts      = jsondecode(str);

% opts = BEARsettings(tmp.VARtype, 'ExcelFile', fullfile(bearroot(), tmp.Datafolder,tmp.Datafile));

% fn = fieldnames(opts);
% [a,b]=ismember(fieldnames(opts),fieldnames(tmp));
% fn = fn(a);
% opts.Bu = tmp.Bu;
% 
% for ii = 1:numel(fieldnames(tmp))
%     try
%     opts.(fn{ii}) = tmp.(fn{ii});
%     end
% end

data_endo_table = readtable("+nw_favar/data_endo.csv");
data_exo = readmatrix("+nw_favar/data_exo.csv");
informationnames = readcell("informationnames.csv","FileType", "text");
informationdata = readmatrix("informationdata.csv","FileType", "text");


fileName = "+nw_favar/favar.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
favar    = jsondecode(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[sample, favar] = nw_favar.get_draws_new(data_endo_table,data_exo,informationdata,informationnames,opts,favar);