

fnametemplate = 'rrrbrodmann.nii';
template_vol = load_nii(fnametemplate);
template_img = template_vol.img;
template_size = size(template_img);
template_long = reshape(template_img,prod(template_size),1);

group_path = 'Preprocessed/normal/';
group_folders = dir(group_path); %TODO: each person can be selected or not

for iperson = 3:length(group_folders)
    person_folder = fullfile(group_path,group_folders(iperson).name);
    theniis = dir(fullfile(person_folder,'*.nii'));
    theniiname = fullfile(person_folder,theniis(1).name);
    thenii = load_nii(theniiname);
    theimg = thenii.img;
    theimg_size = size(theimg);
    theimg_long = reshape(theimg,theimg_size(1)*theimg_size(2)*theimg_size(3), theimg_size(4));
    
    attr_folder = fullfile(person_folder,'attrcsvs');
    if ~isdir(attr_folder)
        mkdir(attr_folder);
    end
    
    CC = zeros(116,1);
    CCFS = zeros(116,1);
    BC = zeros(116,1);
    PATH = zeros(116,1);
    
    for Network_Num = 1:116
        % Compute the regional network
        Regional_Data = double(theimg_long(template_long == Network_Num, :));
        if isempty(Regional_Data)
            continue;
        end
        Temp = Regional_Data;
        PP = 0;
        for i = 1:size(Temp, 1)
            if(sum(abs(Temp(i, :)))==0)
                PP = [PP, i];
            end
        end
        if(size(PP, 2)>1)
            Regional_Data(PP(2:size(PP, 2)), :) = [];
        end
        clear PP
        [Cor, P] = corrcoef(Regional_Data');
        Cor = abs(Cor);
        Size = size(Cor, 1);
        for i = 1:Size
            Cor(i, i) = 0;
        end
        Cor1 = Cor;
        for i = 1:Size
            for m = 1:Size
                if(Cor1(i, m)<0.5)
                    Cor1(i, m) = 0;
                else
                    Cor1(i, m) = Cor1(i, m);
                end
            end
        end
        Cor1 = sparse(Cor1);
        % Compute the network features
        %  c= mean(mean(atanh(Cor)*sqrt(D-3), 1));
        c = efficiency_wei(Cor,0);
        ccfs= mean(clustering_coefficients(double(Cor1>0)));
        Net = zeros(size(Cor, 1),Size);
        for i = 1:Size
            for m = 1:Size
                if(Cor(i, m) ~= 0)
                    Net(i, m) = 1/Cor(i, m);
                end
            end
        end
        Net = sparse(Net);
        bc = mean(betweenness_centrality(Net));
        path1 = all_shortest_paths(Net);
        path = sum(sum(path1))/Size/(Size-1);

        CC( Network_Num,1) =c;        %%¼ÆËã¾ùÖµ
        CCFS( Network_Num,1) = ccfs;
        BC( Network_Num,1) = bc;
        PATH( Network_Num,1) = path;
    end
    
    
    
    
end


