%% Setting up opt structure
fileName = "NW_FAVAR_opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
tmp     = jsondecode(str);

opts = BEARsettings(tmp.VARtype, 'ExcelFile', fullfile(bearroot(), tmp.Datafolder,tmp.Datafile));
fn = fieldnames(tmp);
for ii = 1:numel(fieldnames(tmp))
    try
    opts.(fn{ii}) = tmp.(fn{ii});
    end
end

fileName = "NW_FAVAR_favar.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
favar    = jsondecode(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs, sigma_gibbs, favar] = get_NW_FAVAR_draws(opts,favar);