AAL_Template = read_data('rrrbrodmann');
%AAL_Template = reshape(AAL_Template, 61*73*61, 1);

Template_2 = load_nii('rrrbrodmann.nii');
tplt_2nii = Template_2.img;

%Template_2 = reshape(tplt_2nii, 61*73*61, 1);
%AAA
m = AAL_Template(:,:,20);
n = tplt_2nii(:,:,20);

boldfile = 'Preprocessed\normal\yanshuyu150711\Filtered_4DVolume';
bold_1 = read_data(boldfile);
bold_2_nii = load_nii([boldfile,'.nii']);
bold_2 = bold_2_nii.img;
%BBB
bm = bold_1(:,:,20,5);
bn = bold_2(:,:,20,5);


%在AAA，是反着的；在BBB，也是反着的。大概可以认为，只要配套就正确，也就是，
%模板和数据的读取都是用read_data或者都使用load_nii就可以了。

