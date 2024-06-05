function [endo, exo, n] = endo_exo(opts)

%% get endogenous and exogenous
varendo=bear.utils.fixstring(opts.varendo);
varexo=bear.utils.fixstring(opts.varexo);

findspace=isspace(varendo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(varendo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numendo=nspace+1;
% now finally identify the endogenous
endo=cell(numendo,1);
for ii=1:numendo
    endo{ii,1}=varendo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end
n=size(endo,1);

if isempty(varexo==1)
    exo={};
    % if not empty, repeat what has been done with the exogenous
else
    findspace=isspace(varexo);
    locspace=find(findspace);
    delimiters=[0 locspace numel(varexo)+1];
    nspace=sum(findspace(:)==1);
    numexo=nspace+1;
    exo=cell(numexo,1);
    for ii=1:numexo
        exo{ii,1}=varexo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
    end
end