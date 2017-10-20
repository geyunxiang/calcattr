function xz_intra_region(infolder,inpeople,fnametemplate)
% This function basically calculates attributes within each brain region

    if isempty(infolder) || isempty(inpeople)
        return;
    end
    templateNii = load_nii(fnametemplate);
    templateImg = templateNii.img;
    templateSize = size(templateImg);
    % reshape the template to a column vector
    templateLong = reshape(templateImg, prod(templateSize), 1);

    parfor iperson = 1:size(inpeople, 1)
        curperson = inpeople{iperson, 1};
        curpersonrun = inpeople{iperson, 2};
        if curpersonrun == 0
            continue;
        end
        %xz_intra_region_person(infolder, curperson, 'weak', 0.5);
        xz_intra_region_person(infolder, curperson, 'strong', 0.5, templateLong);
        fprintf(1, 'person: %s finished\n', curperson);
    end
end

function xz_intra_region_person(infolder, curperson, weakstrong, netthreshold, templateLong)
    person_folder = fullfile(infolder, curperson);
    niis = dir(fullfile(person_folder, '*.nii'));
    niiName = fullfile(person_folder, niis(1).name);
    nii = load_nii(niiName);
    niiImg = nii.img;
    niiImgSize = size(niiImg);
    % a matrix, each column represents each time point. size = (# voxels, # time points)
    niiImgLong = reshape(niiImg, niiImgSize(1)*niiImgSize(2)*niiImgSize(3), niiImgSize(4));

    if strcmp(weakstrong, 'strong')
        attr_folder = fullfile(person_folder, 'attrcsvs');
    else
        attr_folder = fullfile(person_folder, 'attrcsvsweak');
    end
    
    if ~isdir(attr_folder)
        mkdir(attr_folder);
    end

    regions = unique(templateLong); % select the unique value in the template column vector
    regions = regions(2:83); % abandon the first element (zero)
    regionNum = length(regions); % number of regions

    % several column vectors
    CC = zeros(regionNum, 1);
    CCFS = zeros(regionNum, 1);
    BC = zeros(regionNum, 1);
    PATH = zeros(regionNum, 1);

    for networkIdx = 1:regionNum
        % Compute the regional network
        % extract data belonging to one region
        % results in a smaller matrix, with each column represents voxels belonging to one
        % brain region at one time. size = (# voxels in brain region, # time points)
        regionalData = double(niiImgLong(templateLong == regions(networkIdx), :));
        if isempty(regionalData)
            continue;
        end
        zeroActiveVoxels = 0;
        for i = 1:size(regionalData, 1) % # voxels in this brain region
            if(sum(abs(regionalData(i, :))) == 0) % this voxel's signal is all zero
                zeroActiveVoxels = [zeroActiveVoxels, i];
            end
        end
        if(size(zeroActiveVoxels, 2) > 1) % if there is more than one zero active voxels
            % delete those voxels signal from the matrix
            % but the first zero voxel is preserved
            regionalData(zeroActiveVoxels(2:size(zeroActiveVoxels, 2)), :) = [];
        end
        % each column of regionalData' is the signal from each voxel (a random variable)
        % each row of regionalData' is # time points
        correlationMatrix = corrcoef(regionalData');
        correlationMatrix = abs(correlationMatrix);
        numOfVoxels = size(correlationMatrix, 1); % number of voxels
        for i = 1:numOfVoxels
            correlationMatrix(i, i) = 0;
        end
        threshedCorMatrix = correlationMatrix;
        
        if strcmp(weakstrong, 'strong')
            %strong
            for i = 1:numOfVoxels %slow
                for m = 1:numOfVoxels
                    if(threshedCorMatrix(i, m) < netthreshold)
                        threshedCorMatrix(i, m) = 0;
                    else
                        threshedCorMatrix(i, m) = threshedCorMatrix(i, m);
                    end
                end
            end 
        else
            %weak
            for i = 1:numOfVoxels %slow
                for m = 1:numOfVoxels
                    if(threshedCorMatrix(i, m) > netthreshold)
                        threshedCorMatrix(i, m) = 0;
                    else
                        threshedCorMatrix(i, m) = threshedCorMatrix(i, m);
                    end
                end
            end 
        end
        threshedCorMatrix = sparse(threshedCorMatrix);

        % Compute the network features
        %  c= mean(mean(atanh(correlationMatrix)*sqrt(D-3), 1));
        c = efficiency_wei(correlationMatrix, 0); %very very slow
        ccfs = mean(clustering_coefficients(double(threshedCorMatrix > 0))); %kindof slow
        reciprocalCorMatrix = zeros(numOfVoxels, numOfVoxels);
        for i = 1:numOfVoxels %slow
            for m = 1:numOfVoxels
                if(correlationMatrix(i, m) ~= 0)
                    reciprocalCorMatrix(i, m) = 1/correlationMatrix(i, m);
                end
            end
        end
        reciprocalCorMatrix = sparse(reciprocalCorMatrix);
        bc = mean(betweenness_centrality(reciprocalCorMatrix)); %slow
        path1 = all_shortest_paths(reciprocalCorMatrix); %kindof slow
        route = sum(sum(path1))/numOfVoxels/(numOfVoxels - 1);

        CC(networkIdx) = c;
        CCFS( networkIdx) = ccfs;
        BC(networkIdx) = bc;
        PATH(networkIdx) = route;
    end

    %attr_folder
    %put each attr result to a simple csv, just one column data
    fnameattr = fullfile(attr_folder,'intra-region_ge.csv');
    xzfn_write_simple_csv(fnameattr, curperson, CC);
    fnameattr = fullfile(attr_folder,'intra-region_ccfs.csv');
    xzfn_write_simple_csv(fnameattr, curperson, CCFS);
    fnameattr = fullfile(attr_folder,'intra-region_bc.csv');
    xzfn_write_simple_csv(fnameattr, curperson, BC);
    fnameattr = fullfile(attr_folder,'intra-region_path.csv');
    xzfn_write_simple_csv(fnameattr, curperson, PATH);
end



