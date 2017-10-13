function xz_mergeattr_run
%merge all csvs
load('current_config_calcattr.mat', 'xzconfig_calcattr');
xzconfig = xzconfig_calcattr;
%folder1name group1 folder name
%folder1people row:person, run
%folder2name group2 folder name
%folder2people row:person, run
%itemcks(1:3) inter-region, intra-region, inter-voxel
%Atlasfname 

folder1name = xzconfig.folder1name;
folder1people = xzconfig.folder1people;
folder2name = xzconfig.folder2name;
folder2people = xzconfig.folder2people;
itemcks = xzconfig.itemcks;
atlasfname = xzconfig.Atlasfname;
rootdir = xzconfig.RootCSVout;

%reorder people in folder
if isempty(folder1name) ~= 1
    folder1people = xzfn_get_people_order(folder1name);
end
if isempty(folder2name) ~= 1
    folder2people = xzfn_get_people_order(folder2name);
end



%inter-region
if itemcks(1)==1
    attrs = {'c', 'ccfs', 'bc', 'le', 'wd'};
    xzfn_merge_csvs(rootdir, 'inter-region', folder1name, folder1people, attrs);
    fprintf('-\n');
    xzfn_merge_csvs(rootdir, 'inter-region', folder2name, folder2people, attrs);
    fprintf('-\n');
end

%intra-region
if itemcks(2)==1
    attrs = {'ge', 'ccfs', 'bc', 'path'};
    xzfn_merge_csvs(rootdir, 'intra-region', folder1name, folder1people, attrs);
    fprintf('-\n');
    xzfn_merge_csvs(rootdir, 'intra-region', folder2name, folder2people, attrs);
    fprintf('-\n');
end

%inter-voxel
if itemcks(3)==1
    
end



end

%collect csvs for conveninet later use
function xzfn_merge_csvs(rootcsv, curmodal, curfolder, curpeople, attrs)
    if isempty(curfolder)
        return;
    end
    [~,foldername] = fileparts(curfolder);
    outcsvpath = fullfile(rootcsv,curmodal,foldername);
    if ~isdir(outcsvpath)
        mkdir(outcsvpath);
    end
    
    idx_valid = 0;
    header_people = {};
    for iperson = 1:length(curpeople)
        fprintf('.');
        curperson = curpeople{iperson};
        %curperson = curpeople{iperson,1};
        %curpersonrun = curpeople{iperson,2};
        %if curpersonrun == 0
        %    continue;
        %end
        idx_valid = idx_valid + 1;
        header_people{idx_valid} = curperson;
        
        %attrcsvsfolder = 'attrcsvsweak';
        attrcsvsfolder = 'attrcsvs';
        
        for iattr = 1:length(attrs)
            curattr = attrs{iattr};
            if strcmp(curattr, 'ge')
                fcurincsv = fullfile(curfolder,curperson,attrcsvsfolder,[curmodal,'_','ge','.csv']);
                if ~exist(fcurincsv, 'file')
                    fcurincsv = fullfile(curfolder,curperson,attrcsvsfolder,[curmodal,'_','cc','.csv']);
                end
            else
                fcurincsv = fullfile(curfolder,curperson,attrcsvsfolder,[curmodal,'_',curattr,'.csv']);
            end
            
            
            try 
                curattrdata = csvread(fcurincsv,1,0);
                ModalDataAll(:,idx_valid,iattr) = curattrdata;
            catch ME
                fprintf('csvread error, file: %s', fcurincsv);
                rethrow(ME)
            end
        end
    end
    
    %write out a csv for each attr
    if idx_valid==0
        return;
    end
    for iattr = 1:length(attrs)
        curattr = attrs{iattr};
        fcuroutcsv = fullfile(outcsvpath,[curmodal,'_',curattr,'.csv']);
        
        xzfn_write_matrix_csv(fcuroutcsv,header_people,ModalDataAll(:,:,iattr));
        
    end
    
end

function xzfn_write_matrix_csv(fname,header,indata)
    fcsv = fopen(fname,'w');
    for i = 1:length(header)-1
        fprintf(fcsv,[header{i},',']);
    end
    fprintf(fcsv,[header{end},'\n']);%header{i+1},only one column also works
    
    rowcnt = size(indata,1);
    colcnt = size(indata,2);
    if length(header) ~= colcnt
        warning(['header cnt unequal to indata column cnt.',fname]);
    end
    for irow = 1:rowcnt
        for icol = 1:colcnt-1
            fprintf(fcsv,[num2str(indata(irow,icol)),',']);
        end
        fprintf(fcsv,[num2str(indata(irow,end)),'\n']);
    end
    
    fclose(fcsv);
end

% reorder the order of people in a group folder
function foldernames = xzfn_get_people_order(curfolder)

    [folderpath,foldername] = fileparts(curfolder);
    peopleorder_fname = fullfile(folderpath, [foldername,'_peopleorder.txt']);
    
    if exist(peopleorder_fname, 'file')
        % file exist, use the content
        peopleorder_file = fopen(peopleorder_fname, 'r');
        peopleinfolder = {};
        tline = fgetl(peopleorder_file);
        while ischar(tline)
            peopleinfolder{end+1} = tline;
            tline = fgetl(peopleorder_file);
        end
        fclose(peopleorder_file);

        %peopleinfolder
    else
        % file not exist, use all the person folders in group folder, and
        % create the file
        peoplefolder = curfolder;
        folderdict = dir(peoplefolder);
        tabledata = {};
        for iitem = 3:length(folderdict)
            curitem = folderdict(iitem);
            if curitem.isdir ~= 1 %not a dir, skip
                continue;
            end
            tabledata{end+1} = curitem.name;
        end
        peopleinfolder = tabledata;

        peopleorder_file = fopen(peopleorder_fname, 'w');
        for item = peopleinfolder
            fprintf(peopleorder_file, '%s\n', item{1});
        end
        fclose(peopleorder_file);
    end

    
    %dispstr = strjoin(peopleinfolder, ', ');
    dispstr = cells_to_dispstr(peopleinfolder);
    
    choice = questdlg({'OK with this order or Edit order yourself?', '', dispstr},...
        'OK or Edit?',...
        'OK',...
        'Edit',...
        'Reload&Edit',...
        'OK');
    
    %fprintf(choice);
    if isempty(choice)
        %click X will enter here, Edit should be better
        choice = 'Edit';
    end
    
    switch choice
        case 'OK'
            foldernames = peopleinfolder;
        case 'Edit'
			%dirty copy
            open(peopleorder_fname);
            h = msgbox('Click OK when order modification is done', 'OK to proceed?');
            uiwait(h);
            %get edited order
            peopleorder_file = fopen(peopleorder_fname, 'r');
            peopleinfolder = {};
            tline = fgetl(peopleorder_file);
            while ischar(tline)
                peopleinfolder{end+1} = tline;
                tline = fgetl(peopleorder_file);
            end
            fclose(peopleorder_file);
            foldernames = peopleinfolder;
        case 'Reload&Edit'
			%dirty copy
			peoplefolder = curfolder;
			folderdict = dir(peoplefolder);
			tabledata = {};
			for iitem = 3:length(folderdict)
				curitem = folderdict(iitem);
				if curitem.isdir ~= 1 %not a dir, skip
					continue;
				end
				tabledata{end+1} = curitem.name;
			end
			peopleinfolder = tabledata;

			peopleorder_file = fopen(peopleorder_fname, 'w');
			for item = peopleinfolder
				fprintf(peopleorder_file, '%s\n', item{1});
			end
			fclose(peopleorder_file);

            
            open(peopleorder_fname);
            h = msgbox('Click OK when order modification is done', 'OK to proceed?');
            uiwait(h);
            %get edited order
            %dirty copy again...
            peopleorder_file = fopen(peopleorder_fname, 'r');
            peopleinfolder = {};
            tline = fgetl(peopleorder_file);
            while ischar(tline)
                peopleinfolder{end+1} = tline;
                tline = fgetl(peopleorder_file);
            end
            fclose(peopleorder_file);
            foldernames = peopleinfolder;
    end

    %the resulted reordered people dict is foldernames
end

function outstr = cells_to_dispstr(thedict)
    outd = {};
    for i = 1:length(thedict)
        outd{end+1} = [int2str(i),':',thedict{i}];
    end
    outstr = strjoin(outd, '; ');

end