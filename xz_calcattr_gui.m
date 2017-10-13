function xz_calcattr_gui

%size callback will be called if visible is on(default)
f = figure('Name','Calc Attr','NumberTitle','off',...
    'SizeChangedFcn', @cb_figure_size_change,'Visible', 'off',...
    'MenuBar','none','ToolBar','none','Position',[100,100,500,600]);

xgh = struct('structname','xzguiholder');
xgh.g_panel1 = uipanel(f,'Title','DataProc');
xgh.g_panel2 = uipanel(f,'Title','Info');

%top-left raw data folders
xgh.rawdatafolder = uipanel(xgh.g_panel1,'Title','Raw Data Folders','Units','normalized',...
    'Position',[0,0.3,0.5,0.7]);
xgh.rawdatafolder_folder1 = uicontrol(xgh.rawdatafolder,'Style','edit','Units','normalized',...
    'Position',[0.0,1-0.2,0.65,0.12],'Enable','Inactive',...
    'Tag','rawdatafolder1','ButtonDownFcn',@cb_rawdatafolder_folder,'FontSize',10);
xgh.rawdatafolder_config1 = uicontrol(xgh.rawdatafolder,'Style','pushbutton','String','Config','Units','normalized',...
    'Position',[0.67,1-0.2,0.3,0.12],'Callback',@cb_btn_config1);
xgh.rawdatafolder_config1.UserData = {};
xgh.rawdatafolder_folder2 = uicontrol(xgh.rawdatafolder,'Style','edit','Units','normalized',...
    'Position',[0.0,1-0.35,0.65,0.12],'Enable','Inactive',...
    'Tag','rawdatafolder2','ButtonDownFcn',@cb_rawdatafolder_folder,'FontSize',10);
xgh.rawdatafolder_config2 = uicontrol(xgh.rawdatafolder,'Style','pushbutton','String','Config','Units','normalized',...
    'Position',[0.67,1-0.35,0.3,0.12],'Callback',@cb_btn_config2);
xgh.rawdatafolder_config2.UserData = {};

%top-right
xgh.btngrp = uipanel(xgh.g_panel1,'Title','Items to Run','Units','normalized',...
    'Position',[0.5,0.3,0.5,0.7]);
icks = 0;
xgh.btngrp_ck1 = uicontrol(xgh.btngrp,'Style','checkbox','String','inter-region','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.4,0.12],'Value',0);
icks = icks + 1;
xgh.btngrp_ck2 = uicontrol(xgh.btngrp,'Style','checkbox','String','intra-region','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.4,0.12],'Value',0);
icks = icks + 1;
xgh.btngrp_ck3 = uicontrol(xgh.btngrp,'Style','checkbox','String','inter-voxel','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.4,0.12],'Value',0);
icks = icks + 2;

%atlas
xgh.lblatlas = uicontrol(xgh.btngrp,'Style','text','String','Atlas','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.3,0.12],'HorizontalAlignment','left');
xgh.fileatlas = uicontrol(xgh.btngrp,'Style','edit','Units','normalized',...
    'Position',[0.3,0.8-icks*0.15,0.65,0.14],'Enable','Inactive',...
    'Tag','Atlas','ButtonDownFcn',@cb_btngrp_atlas,'Max',2,'FontSize',9);
%root csv out directory
icks = icks + 1;
xgh.lblmerge = uicontrol(xgh.btngrp,'Style','text','String','CSV out','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.3,0.12],'HorizontalAlignment','left');
xgh.filerootcsvdir = uicontrol(xgh.btngrp,'Style','edit','Units','normalized',...
    'Position',[0.3,0.8-icks*0.15,0.65,0.14],'Enable','Inactive',...
    'Tag','Atlas','ButtonDownFcn',@cb_btngrp_rootcsvout,'Max',2,'FontSize',9);

%bottom-left buttons
btnshorz = 2;
btnsvert = 12;
ibtn = 0;
btnpos = [0,ibtn/btnsvert,1/btnshorz,1/btnsvert];
uicontrol(xgh.g_panel1,'Style','pushbutton','String','Help','Units','normalized',...
    'Position',btnpos,'Callback',@cb_btn_help);
ibtn = ibtn + 1;
btnpos = [0,ibtn/btnsvert,1/btnshorz*2/3,1/btnsvert];
xgh.g_panel1_botleft_run = uicontrol(xgh.g_panel1,'Style','pushbutton','String','Run','Units','normalized',...
    'Position',btnpos,'BackgroundColor',[0.7,0.9,0.7],'Callback',@cb_btn_run);
btnpos = [1/btnshorz*2/3,ibtn/btnsvert,1/btnshorz/3,1/btnsvert];
xgh.g_panel1_botleft_merge = uicontrol(xgh.g_panel1,'Style','pushbutton','String','Merge cvs','Units','normalized',...
    'Position',btnpos,'BackgroundColor',[0.8,0.9,0.8],'Callback',@cb_btn_merge);

ibtn = ibtn + 1;
btnpos = [0,ibtn/btnsvert,1/btnshorz/2,1/btnsvert];
uicontrol(xgh.g_panel1,'Style','pushbutton','String','Load Config','Units','normalized',...
    'Position',btnpos,'Callback',@cb_btn_loadsave);
btnpos = [1/btnshorz/2,ibtn/btnsvert,1/btnshorz/2,1/btnsvert];
uicontrol(xgh.g_panel1,'Style','pushbutton','String','Save Config','Units','normalized',...
    'Position',btnpos,'Callback',@cb_btn_loadsave);

guidata(f,xgh);
f.Visible = 'on';

end

function cb_btn_loadsave(hObject, eventdata)
    btnstr = hObject.String;
    if strcmp(btnstr,'Load Config')
        fname_config = uigetfile('*.mat');
        if fname_config == 0
            return;
        else
            %fname_config
            load(fname_config,'xzconfig_calcattr');
            fig = gcbo;
            xgh = guidata(fig);
            
            xgh.rawdatafolder_folder1.String = xzconfig_calcattr.folder1name;
            xgh.rawdatafolder_config1.UserData = xzconfig_calcattr.folder1people;
            xgh.rawdatafolder_folder2.String = xzconfig_calcattr.folder2name;
            xgh.rawdatafolder_config2.UserData = xzconfig_calcattr.folder2people;
            xgh.btngrp_ck1.Value = xzconfig_calcattr.itemcks(1);
            xgh.btngrp_ck2.Value = xzconfig_calcattr.itemcks(2);
            xgh.btngrp_ck3.Value = xzconfig_calcattr.itemcks(3);
            xgh.fileatlas.String = xzconfig_calcattr.Atlasfname;
            xgh.filerootcsvdir.String = xzconfig_calcattr.RootCSVout;
            
        end
    elseif strcmp(btnstr,'Save Config')
        fname_config = uiputfile('*.mat');
        if fname_config == 0
            return;
        else
            %fname_config
            fig = gcbo;
            xzsave_config(fig,fname_config);
        end
    end
end

function xzsave_config(fig,fname_config)
    xgh = guidata(fig);
    
    xzconfig_calcattr = struct();
    xzconfig_calcattr.folder1name = xgh.rawdatafolder_folder1.String;
    xzconfig_calcattr.folder1people = xgh.rawdatafolder_config1.UserData;
    xzconfig_calcattr.folder2name = xgh.rawdatafolder_folder2.String;
    xzconfig_calcattr.folder2people = xgh.rawdatafolder_config2.UserData;
    itemcks(1) = xgh.btngrp_ck1.Value;
    itemcks(2) = xgh.btngrp_ck2.Value;
    itemcks(3) = xgh.btngrp_ck3.Value;
    xzconfig_calcattr.itemcks = itemcks;
    xzconfig_calcattr.Atlasfname = xgh.fileatlas.String;
    xzconfig_calcattr.RootCSVout = xgh.filerootcsvdir.String;
    
    save(fname_config,'xzconfig_calcattr');
end

function cb_btn_run(hObject, eventdata)
    fig = gcbo;
    xzsave_config(fig,'current_config_calcattr.mat');
    %RUN BATCH
    xgh = guidata(fig);
    runbtn = xgh.g_panel1_botleft_run;
    % runbtn.Enable = 'off'; %disable run button while running
    fprintf(1, 'program started on %s\n', datetime);
    xz_calcattr_run;
    runbtn.Enable = 'on';
    fprintf(1, 'program finished on %s\n', datetime);
    %fprintf('%d%d%d\n',ck1v,ck2v,ck3v);
end

function cb_btn_merge(hObject, eventdata)
    fig = gcbo;
    xgh = guidata(fig);
    xzsave_config(fig,'current_config_calcattr.mat');
    %merge all csvs
    xz_mergeattr_run;
    %fprintf('%d%d%d\n',ck1v,ck2v,ck3v);
end

function cb_btngrp_atlas(hObject, eventdata)
    [fname,pname,~] = uigetfile('*.nii');
    if fname ~= 0
        hObject.String = [pname,fname];%BE careful!
    end
end

function cb_btngrp_rootcsvout(hObject, eventdata)
    dirname = uigetdir();
    if dirname ~= 0
        hObject.String = dirname;%BE careful!
    end
end

function cb_btn_help(hObject, eventdata)
    %open('DataProcManual.docx');
end

function cb_rawdatafolder_folder(hObject, eventdata)
    %edittag = hObject.Tag;
    dirname = uigetdir();
    if dirname ~= 0
        hObject.String = dirname;
    end
end

function cb_btn_config1(hObject, eventdata)
    fig = gcbo;
    xgh = guidata(fig);
    fname = xgh.rawdatafolder_folder1.String;
	xgh.rawdatafolder_config1.UserData = xz_person_config_gui(fname,xgh.rawdatafolder_config1.UserData);
end

function cb_btn_config2(hObject, eventdata)    
    fig = gcbo;
    xgh = guidata(fig);
    fname = xgh.rawdatafolder_folder2.String;
	xgh.rawdatafolder_config2.UserData = xz_person_config_gui(fname,xgh.rawdatafolder_config2.UserData);
end

function cb_figure_size_change(hObject, eventdata)
    fig = hObject;
    
    xgh = guidata(fig);
    %panel use normalized units for default,[0 0 1 1]
    p1 = xgh.g_panel1;
    p2 = xgh.g_panel2;
    p1.Position = [0 0.3 1 0.7];
    p2.Position = [0 0 1 0.3];
    %restore units 
end
