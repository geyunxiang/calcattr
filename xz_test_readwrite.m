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


%��AAA���Ƿ��ŵģ���BBB��Ҳ�Ƿ��ŵġ���ſ�����Ϊ��ֻҪ���׾���ȷ��Ҳ���ǣ�
%ģ������ݵĶ�ȡ������read_data���߶�ʹ��load_nii�Ϳ����ˡ�

