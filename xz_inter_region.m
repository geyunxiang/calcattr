function xz_inter_region(infolder, inpeople, fnametemplate)
% This function basically calculates attributes between brain regions

    if isempty(infolder) || isempty(inpeople)
        return;
    end
    templateNii = load_nii(fnametemplate);
    templateImg = templateNii.img;
    templateSize = size(templateImg);
    % reshape the template to a column vector
    templateLong = reshape(templateImg, prod(templateSize), 1);

    for iperson = 1:size(inpeople, 1)
        curperson = inpeople{iperson, 1}; % person name
        curpersonrun = inpeople{iperson, 2}; % if run this person
        if curpersonrun == 0
            continue;
        end
        %xz_inter_region_person(infolder, curperson, 'weak', 0.5);
        xz_inter_region_person(infolder, curperson, 'strong', 0.5);
        fprintf('%s finished.\n', curperson);
    end
    fprintf('inter region finished.\n');

%-------------------------------------------------------------------------
    function xz_inter_region_person(infolder, curperson, weakstrong, netthreshold)
        person_folder = fullfile(infolder, curperson); % get full path to this person's folder
        niis = dir(fullfile(person_folder, '*.nii')); % list all nii files under the person's folder
        % TODO: fix nii choose logic here
        niiName = fullfile(person_folder, niis(1).name); % choose the first nii...This is quesionable
        nii = load_nii(niiName);
        niiImg = nii.img; % get the 4 dimensional img of the nii file
        niiImgSize = size(niiImg); % (a, b, c, # time point)
        % put all voxels scanned at one time point to a single long vector
        niiImgLong = reshape(niiImg, niiImgSize(1)*niiImgSize(2)*niiImgSize(3), niiImgSize(4));
        
        if strcmp(weakstrong, 'strong')
            attr_folder = fullfile(person_folder, 'attrcsvs');
        else
            attr_folder = fullfile(person_folder, 'attrcsvsweak');
        end
        
        if ~isdir(attr_folder)
            mkdir(attr_folder);
        end
        
        % why 116?
        C = zeros(116, 1);
        BC = zeros(116, 1);
        CCFS = zeros(116, 1);
        LE = zeros(116, 1);
        WD = zeros(116, 1);
        
        % --- Construct the Whole brain network---
        Num = unique(templateLong)'; % select the unique value in the template column vector
        Num = Num(2:83); % abandon the first element (zero)
        % Brodmann does not contain brain region 12-16, 31, 33, 49, 50, 62-66, 81, 83
        % count up to 98
        % size(Num, 2) = 82, i.e. 82 different brain regions
        % niiImgSize(4) is # time points
        WholeNode = zeros(size(Num, 2), niiImgSize(4));
        for i = 1:size(Num, 2) % for each brain region
            NodeId = find(templateLong == Num(i)); % find linear (column-first) indices
            WholeNode(i, :) = mean(niiImgLong(NodeId, :), 1); % take mean value to one row
        end
        % To this point, nodes of brain network are built
        % and stored in WholeNode
        % data diagram of WholeNode:
        % COL1  COL2    COL3    ...
        % BA1   AVE1    AVE2    ...
        % BA2   ...
        % BA3   ...
        % BA4   ...
        % ...
        % each row is the time series of signal associated with one brain region
        % Taking the transpose, each column is the brain region average signal time series
        % Here calculate the Pearson correlation coefficients between each brain regions (each column of WholeNode')
        % with # time points observations(each row of WholeNode' is an observation)
        [WholeCor, WholeP] = corrcoef(WholeNode');
        % save the correlation to file
        fnameWholeCor = fullfile(attr_folder, 'inter-region-WholeCor.mat');
        save(fnameWholeCor, 'WholeCor');
        % fnameWholeCor
        
        % get the absolute value of the correlation matrix
        % and set the diagnal values to zero
        WholeCor = abs(WholeCor);
        for i = 1:82
            WholeCor(i, i) = 0;
        end
        
        %Whole_Cor = WholeCor;
        %Whole_Cor = reshape(Whole_Cor, 1, []);
        %Whole_Cor = abs(Whole_Cor);
        
        % threshold the correlation matrix and store it in WholeCor1
        WholeCor1 = WholeCor;
        if strcmp(weakstrong, 'strong')
            %strong
            for i = 1:82
                for m = 1:82
                    if(WholeCor1(i, m) < netthreshold)
                        WholeCor1(i, m) = 0;
                    else
                        WholeCor1(i, m) = 1;
                    end
                end
            end
        else
            %weak
            for i = 1:82
                for m = 1:82
                    if(WholeCor1(i, m) > netthreshold)
                        WholeCor1(i, m) = 0;
                    else
                        WholeCor1(i, m) = 1;
                    end
                end
            end
        end
        
        % convert the thresholded matrix to a sparse matrix
        WholeNet = sparse(WholeCor1);

        % Whole_c = sum(atanh(WholeCor)*sqrt(230-3), 1);
        % This basically sums up all correlation coefficients of one brain region
        % to other brain regions, with certain transformation.
        % And this value is set to C
        Whole_c = sum(atanh(WholeCor)*sqrt(227), 1);

        % calculate clustering coefficients
        % The clustering coefficient is the ratio of the number
        % of edges between a vertex's neighbors to the total possible number of 
        % edges between the vertex's neighbors.
        % David Gleich
        % Copyright, Stanford University, 2006-2008
        % Who developed these functions and algorithms?
        Whole_ccfs = clustering_coefficients(double(WholeNet > 0));

        % Half brain?
        % Prepare data for the following attribute calculation?
        Whole_Net = zeros(41, 41);
        for i = 1:82
            for m = 1:82
                if(WholeCor(i, m) ~= 0)
                    Whole_Net(i, m) = 1/WholeCor(i, m);
                end
            end
        end

        Whole_Net = sparse(Whole_Net);

        % calculate betweenness centrality
        % David Gleich
        % Copyright, Stanford University, 2006-2008
        Whole_bc = betweenness_centrality(Whole_Net);

        % Compute the weighted all pairs shortest path problem.
        % David Gleich
        % Copyright, Stanford University, 2006-2008
        Whole_path = all_shortest_paths(Whole_Net);

        % sum the Whole_path to one number??
        Whole_path = sum(sum(Whole_path))/41/40;

        % reshape Whole_path to a row vector
        route = reshape(Whole_path, 1, []);

        % find indices where path is neither zero nor inf
        pathid = find((route ~= 0) & (route ~= inf));

        % calculate efficiency
        % harmonic mean
        efficiency = 1/harmmean(route(pathid));
        
        % Weight is just the sum of all correlation coefficients
        Weight = sum(WholeCor, 1);

        % This seems to be calculating degree
        % Input: undirected (binary/weighted) connection matrix
        % output is the degree
        % but would the input WholeCor contains zero elements? (zero correlation coefficients?)
        %   Olaf Sporns, Indiana University, 2002/2006/2008
        degree = degrees_und(WholeCor);

        % Density is the fraction of present connections to possible connections.
        % Anyway some calculation
        %   Olaf Sporns, Indiana University, 2002/2006/2008
        density = density_und(WholeCor);

        % Global efficiency, local efficiency. With 1 calculates local efficiency.
        % Anyway some calculation
        E = efficiency_wei(WholeCor, 1);
        % This is global efficiency.
        Efficiency = efficiency_wei(WholeCor, 0);

        C = Whole_c';
        BC = Whole_bc;
        CCFS = Whole_ccfs;
        LE = E;
        WD = Weight';
        
        fnameattr = fullfile(attr_folder, 'inter-region_c.csv');
        xzfn_write_simple_csv(fnameattr, curperson, C);

        fnameattr = fullfile(attr_folder, 'inter-region_bc.csv');
        xzfn_write_simple_csv(fnameattr, curperson, BC);

        fnameattr = fullfile(attr_folder, 'inter-region_ccfs.csv');
        xzfn_write_simple_csv(fnameattr, curperson, CCFS);

        fnameattr = fullfile(attr_folder, 'inter-region_le.csv');
        xzfn_write_simple_csv(fnameattr, curperson, LE);

        fnameattr = fullfile(attr_folder, 'inter-region_wd.csv');
        xzfn_write_simple_csv(fnameattr, curperson, WD);
    end
end
