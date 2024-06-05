function favar = initfavar(favar)

%% set up FAVAR
% FAVAR: additional strings
if favar.FAVAR==1
    favar.plotX=bear.utils.fixstring(favar.plotX);
    favar.IRFplotXshock=favar.plotXshock;
    if favar.blocks==1 || favar.slowfast==1
        favar.blocknames=bear.utils.fixstring(favar.blocknames);
    end
    if favar.blocks==1
        favar.blocknumpc=bear.utils.fixstring(favar.blocknumpc);
    end
    if favar.IRFplot==1
        favar.IRFplotXshock=bear.utils.fixstring(favar.IRFplotXshock);
    end
    favar.transform_endo=bear.utils.fixstring(favar.transform_endo);

    % favar.plotX
    findspace=isspace(favar.plotX);
    locspace=find(findspace);
    % use this to set the delimiters: each variable string is located between two delimiters
    delimiters=[0 locspace numel(favar.plotX)+1];
    % count the number of endogenous variables
    % first count the number of spaces
    nspaceplotX=sum(findspace(:)==1);
    % each space is a separation between two variable names, so there is one variable more than the number of spaces
    numplotX=nspaceplotX+1;
    % now finally identify the endogenous
    favar.pltX=cell(numplotX,1);
    for ii=1:numplotX
        favar.pltX{ii,1}=favar.plotX(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
    end

    if favar.blocks==1 || favar.slowfast==1
        findspace=isspace(favar.blocknames);
        locspace=find(findspace);
        % use this to set the delimiters: each variable string is located between two delimiters
        delimiters=[0 locspace numel(favar.blocknames)+1];
        % count the number of endogenous variables
        % first count the number of spaces
        nspaceblocknames=sum(findspace(:)==1);
        % each space is a separation between two variable names, so there is one variable more than the number of spaces
        numblocknames=nspaceblocknames+1;
        % now finally identify the endogenous
        favar.bnames=cell(numblocknames,1);
        for ii=1:numblocknames
            favar.bnames{ii,1}=favar.blocknames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
        end
    end

    if favar.blocks==1
        findspace=isspace(favar.blocknumpc);
        locspace=find(findspace);
        % use this to set the delimiters: each variable string is located between two delimiters
        delimiters=[0 locspace numel(favar.blocknumpc)+1];
        % count the number of endogenous variables
        % first count the number of spaces
        nspaceblocknumpc=sum(findspace(:)==1);
        % each space is a separation between two variable names, so there is one variable more than the number of spaces
        numblocknumpc=nspaceblocknumpc+1;
        % now finally identify the endogenous
        favar.bnumpc=cell(numblocknumpc,1);
        for ii=1:numblocknumpc
            favar.bnumpc{ii,1}=str2num(favar.blocknumpc(delimiters(1,ii)+1:delimiters(1,ii+1)-1)); %convert strings here to numbers
        end
    end

    if favar.IRFplot==1
        findspace=isspace(favar.IRFplotXshock);
        locspace=find(findspace);
        % use this to set the delimiters: each variable string is located between two delimiters
        delimiters=[0 locspace numel(favar.IRFplotXshock)+1];
        % count the number of endogenous variables
        % first count the number of spaces
        nspaceplotXshock=sum(findspace(:)==1);
        % each space is a separation between two variable names, so there is one variable more than the number of spaces
        numplotXshock=nspaceplotXshock+1;
        % now finally identify the endogenous
        favar.IRF.pltXshck=cell(numplotXshock,1);
        for ii=1:numplotXshock
            favar.IRF.pltXshck{ii,1}=favar.IRFplotXshock(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
        end
    end

    findspace=isspace(favar.transform_endo);
    locspace=find(findspace);
    % use this to set the delimiters: each variable string is located between two delimiters
    delimiters=[0 locspace numel(favar.transform_endo)+1];
    % count the number of endogenous variables
    % first count the number of spaces
    nspacetransform_endo=sum(findspace(:)==1);
    % each space is a separation between two variable names, so there is one variable more than the number of spaces
    numtransform_endo=nspacetransform_endo+1;
    % now finally identify the endogenous
    favar.trnsfrm_endo=cell(numtransform_endo,1);
    for ii=1:numtransform_endo
        favar.trnsfrm_endo{ii,1}=str2num(favar.transform_endo(delimiters(1,ii)+1:delimiters(1,ii+1)-1)); %convert strings here to numbers
    end

end