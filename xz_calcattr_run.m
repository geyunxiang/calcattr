function xz_calcattr_run

load('current_config_calcattr.mat', 'xzconfig_calcattr');

xzconfig = xzconfig_calcattr;
% folder1name: group1 folder name
% folder1people: person name, run(0/1)
% folder2name: group2 folder name
% folder2people: person name, run(0/1)
% itemcks(1:3) inter-region, intra-region, inter-voxel
% Atlasfname
% RootCSVout

folder1name = xzconfig.folder1name;
folder1people = xzconfig.folder1people;
folder2name = xzconfig.folder2name;
folder2people = xzconfig.folder2people;
itemcks = xzconfig.itemcks;
atlasfname = xzconfig.Atlasfname;

fprintf('please wait...\n');

% inter-region
if itemcks(1) == 1
	fprintf(1, '%s --- calculating inter region attrs...\n', datetime)
    xz_inter_region(folder1name, folder1people, atlasfname);
    xz_inter_region(folder2name, folder2people, atlasfname);
    fprintf(1, '%s --- inter region attrs calculation finished...\n', datetime)
end

% intra-region
if itemcks(2) == 1
	fprintf(1, '%s --- calculating intra region attrs...\n', datetime)
    xz_intra_region(folder1name, folder1people, atlasfname);
    xz_intra_region(folder2name, folder2people, atlasfname);
    fprintf(1, '%s --- intra region attrs calculation finished...\n', datetime)
end

% inter-voxel, not implemented yet
if itemcks(3) == 1
	fprintf(1, 'Currently inter-voxel calculation is not implemented.\n');
end

fprintf('\ndone at %s.\n', datetime);

end
