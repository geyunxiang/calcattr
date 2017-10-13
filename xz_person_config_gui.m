
function persondict = xz_person_config_gui(groupfolder, currentpeople)
%groupfolder = 'E:/Work/';
%currentstate = {};
if strcmp(groupfolder,'')==1
    persondict={};
    fprintf('specify folder first\n');
    return;
end

f = figure('Name','SelectPeople','NumberTitle','off',...
    'SizeChangedFcn', @cb_figure_size_change,'CloseRequestFcn',@cb_btn_figclose,'Visible', 'off',...
    'MenuBar','none','ToolBar','none','Position',[100,100,200,500],...
    'WindowStyle','modal');

xgh = struct('structname','xzguiholder');
xgh.groupfolder = groupfolder;

%top-left person table
colname = {'Person','Run'};
colformat = {'char','logical'};
coledit = [false, true];
uicontrol(f,'Style','text','String',groupfolder,'Units','normalized',...
    'Position',[0.05,0.84,0.9,0.12],'HorizontalAlignment','left');
xgh.persontable = uitable(f,'Units','normalized','Position',[0.05,0.2,0.9,0.7],...
    'ColumnName',colname,'ColumnFormat',colformat,'ColumnEditable',coledit,'RowName',[]);

if isempty(currentpeople)
    tabledata = folder_people_reload(groupfolder);
    if isempty(tabledata)==1
        persondict={};
        fprintf('no person folder in folder\n');
        delete(gcf);
        return;
    end
else
    for iperson = 1:size(currentpeople,1)
        curitem = currentpeople(iperson,:);
        tabledata{iperson,1} = curitem{1};
        tabledata{iperson,2} = curitem{2};
    end
end
xgh.persontable.Data = tabledata;
%end table init

r2dis = 0.25;
xgh.btn_select_all = uicontrol(f,'Style','pushbutton','String','All','Units','normalized',...
    'Position',[0.0,0.1,r2dis,0.08],'Callback',@cb_btn_select);
xgh.btn_select_None = uicontrol(f,'Style','pushbutton','String','None','Units','normalized',...
    'Position',[r2dis*1,0.1,r2dis,0.08],'Callback',@cb_btn_select);
xgh.btn_select_Invert = uicontrol(f,'Style','pushbutton','String','Invert','Units','normalized',...
    'Position',[r2dis*2,0.1,r2dis,0.08],'Callback',@cb_btn_select);
xgh.btn_select_Reload = uicontrol(f,'Style','pushbutton','String','Reload','Units','normalized',...
    'Position',[r2dis*3,0.1,r2dis,0.08],'Callback',@cb_btn_select);

xgh.btn_select_all = uicontrol(f,'Style','pushbutton','String','OK','Units','normalized',...
    'Position',[0,0,0.5,0.1],'BackgroundColor',[0.7,0.9,0.7],'Callback',@cb_btn_ok);
xgh.btn_select_all = uicontrol(f,'Style','pushbutton','String','Cancel','Units','normalized',...
    'Position',[0.5,0,0.5,0.1],'Callback',@cb_btn_ok);






guidata(f,xgh);
f.Visible = 'on';

uiwait(f);


    function cb_btn_ok(hObject, eventdata)
        fig = gcbo;
        lxgh = guidata(fig);
        tabmod = lxgh.persontable;
        tabdata = tabmod.Data;
        switch hObject.String
            case 'OK'
                persondict = tabdata;
            case 'Cancel'
                persondict = currentpeople;
        end
        delete(gcf);
    end

    function cb_btn_figclose(hObject, eventdata)
        persondict = currentpeople;
        delete(gcf);
    end

end



function cb_btn_select(hObject, eventdata)
    fig = gcbo;
    xgh = guidata(fig);
    tabmod = xgh.persontable;
    
    tabdata = tabmod.Data;
    for i = 1:size(tabdata,1)
        switch hObject.String
            case 'All'
                tabdata{i,2} = true;
            case 'None'
                tabdata{i,2} = false;
            case 'Invert'
                tabdata{i,2} = ~tabdata{i,2};
            case 'Reload'
                tabdata = folder_people_reload(xgh.groupfolder);
        end
        
    end
    tabmod.Data = tabdata;
    
end



function cb_figure_size_change(hObject, eventdata)
    fig = gcbo;
    xgh = guidata(fig);
    tabmod = xgh.persontable;
    unitsold = tabmod.Units;
    tabmod.Units = 'pixels';
    tabpos = tabmod.Position;
    tabwidth = tabpos(3);
    tabcolwidth = {tabwidth*0.6 tabwidth*0.2};
    tabmod.ColumnWidth = tabcolwidth;
    tabmod.Units = unitsold;
end

function tabledata = folder_people_reload(groupfolder)
    folderdict = dir(groupfolder);
    iperson = 0;
    tabledata = {};
    for iitem = 3:length(folderdict)
        curitem = folderdict(iitem);
        if curitem.isdir ~= 1%not a dir, skip
            continue;
        end
        iperson = iperson + 1;
        tabledata{iperson,1} = curitem.name;
        tabledata{iperson,2} = true;
    end

end

