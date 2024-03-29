function [dist, zb_av0, zb_av, zw_max]=ShowFig(handles)
FrameJump=6;        %frame refreshing rate
DrawMode=1;         %=0, draw turbidity current and open channel current; =1, only draw open channel; =2 only draw the levels of surface and and interface.
                               %0 and 1 are determined automatically

nfile=0;
file_id=fopen(['FCSLPF',num2str(nfile),'.TXT']);

vline_flag=1;          %=1时画垂直辅助线
xcs=[53, 55, 56, 58, 61];        %添加辅助线的断面位置

%get user's setting
nCS=handles.nCS;
nplg_lim=handles.nplg_lim;             %限制潜入位置
DrawMode=handles.DrawMode;
DrawMode0=DrawMode;
filter=handles.filter;        %=1时，含沙量小于3kg/m3部分的异重流不画
yn_video=handles.yn_video;

zb_av=zeros(1,nCS);
csqq=zeros(1,nCS);
cszw=zeros(1,nCS);
zw_max=zeros(1,nCS);
dist=zeros(1,nCS);
csBW=zeros(1,nCS);
sus=zeros(1,nCS);
scc=zeros(1,nCS);
idx_plg=zeros(1,nCS);                %index for finding plunging point
tb_zi=zeros(1,nCS);                    %elevation of the interface between two layers
tbqq=zeros(1,nCS);                   %discharge of turbidity flow
tbsus=zeros(1,nCS);                   %concentration of suspended load(kg/m3)
NetSFlx=zeros(1,nCS);                %垂向泥沙净通量
csqbstar=zeros(1,nCS);               %推移质平衡输沙率
csqb=zeros(1,nCS);

first_flag=1;        %flag to mark the first step

fh=figure;
set(gcf,'WindowButtonDownFcn',@LeftClickFcn);
set(gcf, 'Position', [100 100 900 450]);

if yn_video==1
    vidObj=VideoWriter('TbVideo.avi');
    open(vidObj);
    set(gcf,'Position',[680,558,1000,420]);        %set the figure size
end

jump=3;

while file_id>=3           %open successfully
    while ~feof(file_id)
        tline=fgetl(file_id);
        g_title=tline;       %title to be shown in the graph
        tline=fgetl(file_id);
        hn=textscan(tline,'%s');
      
        n_head=length(hn{1});
        head_col.dist=get_head_col('DistLG(km)');
        head_col.zb_av=get_head_col('ZBmin(m)');
        head_col.csqq=get_head_col('QD(m3/s)');
        head_col.cszw=get_head_col('ZW(m)');
        head_col.csBW=get_head_col('BW(m)');
        head_col.sus=get_head_col('CSSUS');
        head_col.scc=get_head_col('CSSCC');
        head_col.idx_plg=get_head_col('IdxPlunge');
        
        head_col.tb_zi=get_head_col('TbZI');
        head_col.tbqq=get_head_col('TbQQ');
        head_col.tbsus=get_head_col('TbSUS');
        head_col.NetSFlx=get_head_col('NetSFlx');
        head_col.csqbstar=get_head_col('CSQbs');
        head_col.csqb=get_head_col('CSQb');
        
        DrawMode=DrawMode0;
        if (head_col.tb_zi==0&&DrawMode~=1) 
            DrawMode=1;
        end
                      
        for k=1:1:nCS
            tline=fgetl(file_id);
            a=textscan(tline,'%f');
            dist(k)=a{1}(head_col.dist);       %extract x coordinate of CS
            zb_av(k)=a{1}(head_col.zb_av); 
            csqq(k)=a{1}(head_col.csqq);
            cszw(k)=a{1}(head_col.cszw);
            zw_max(k)=max([zw_max(k), cszw(k)]);
            csBW(k)=a{1}(head_col.csBW);
            sus(k)=a{1}(head_col.sus);
            scc(k)=a{1}(head_col.scc);
            
            NoBedLd=0;
            try
                csqbstar(k)=a{1}(head_col.csqbstar);
                csqb(k)=a{1}(head_col.csqb);
            catch
                NoBedLd=1;
            end
            
            try
                idx_plg(k)=a{1}(head_col.idx_plg);       %if the colume of idx_plg exsits, the turbidity current exsits
                MarkPP=1;
            catch 
                MarkPP=0;
                if DrawMode~=2
                    DrawMode=1;
                end
            end
            
            if DrawMode~=1
                tb_zi(k)=a{1}(head_col.tb_zi);
                tbqq(k)=a{1}(head_col.tbqq);
                tbsus(k)=a{1}(head_col.tbsus);
                NetSFlx(k)=a{1}(head_col.NetSFlx);
            end
        end
        
        if first_flag==1         %record the initial state
            dist0=dist;
            zb_av0=zb_av;
            cszw0=cszw;
            csBW0=csBW;
            first_flag=0;
        end        
        
        if (DrawMode~=1)||(MarkPP==1)
            npt_plg=0;
            for k=1:1:nCS
                if (idx_plg(k)<=0.6)&&(k>nplg_lim)
                    npt_plg=k;             %cross-section number of plunging point
                    break;
                end
            end
        end        
%------------------------------plot----------------------------------
       if jump==FrameJump
           set(0,'CurrentFigure',fh)          %set current figue, this trick instead of figure(fh) helps to prevent the current figure getting focus over and over again
           if DrawMode==0
               subplot(3,2,1);
               draw_zw;
               
               subplot(3,2,2);
               plot(dist,csqq,'b-');
               hold on;
               addVerticalLine;
               plot([dist(1),dist(end)],[0,0]);           %添加0网格线
               title('CSQQ');
               hold off;                
               
               subplot(3,2,3);
               plot(dist,sus,'g-');
               hold on;
               addVerticalLine;
               plot(dist,scc,'k-');
               hold off;
               title('SUS and SCC');
               
               if npt_plg~=0
                   subplot(3,2,4);
                   plot(dist(npt_plg+1:end),tbqq(npt_plg+1:end),'b-');
                   hold on;
                   addVerticalLine;
                   hold off;
                   title('TbQQ');
                   
                   subplot(3,2,5);
                   plot(dist(npt_plg+1:end),tbsus(npt_plg+1:end),'g-');
                   hold on;
                   addVerticalLine;
                   hold off;                   
                   title('TbSUS');
                   
                   subplot(3,2,6);
                   plot(dist(npt_plg+1:end),NetSFlx(npt_plg+1:end),'b-');
               end
           elseif DrawMode==2
               draw_zw;     %only plot the water depth profile
           else
               %only plot open channel flow
               draw_open_chan;
           end
           %------------------------save as avi-----------------
           if yn_video==1
               currFrame=getframe(gcf);
               writeVideo(vidObj,currFrame);
           end
           pause(0.0001);
           % Check if the left mouse button was clicked, and if so, pause the plot
           if getappdata(gcf, 'is_paused')
               pause;
           end
           jump=1;
       else
           jump=jump+1;
       end
       
       c_char=get(gcf,'CurrentCharacter');
       if c_char=='s'
          button=questdlg('Pause','Waiting','Continue','Quit','Continue');
          if strcmp(button,'Quit')
              if yn_video==1
                  close(vidObj);
              end
              return;
          end
          set(gcf,'CurrentCharacter','a');
       elseif c_char==' '
          pause;
          set(gcf,'CurrentCharacter','a');
       end       
    end
    fclose(file_id);
    nfile=nfile+1;
    file_id=fopen(['FCSLPF',num2str(nfile),'.TXT']);
end

disp('finished');
if yn_video==1
    close(vidObj);
end
fclose('all');

%-----------------------nested function----------------------------
function draw_zw

plot(dist,cszw,'m-');
hold on;
addVerticalLine;
if npt_plg~=0
    plot(dist(npt_plg),cszw(npt_plg),'co');            %标记潜入点
end
if any(tb_zi>0)==1       %plot the interface
    if filter==1
        for i=npt_plg+1:1:nCS
            if (tbsus(i)<3.0)
                tb_zi(i)=zb_av(i);
            end
        end
        for i=npt_plg+1:1:nCS-1
            if (tbsus(i-1)<3.0)&&(tbsus(i+1)<3.0)&&(tbsus(i)>=3.0)
                tb_zi(i)=zb_av(i);
            end
        end
    end
    plot(dist(npt_plg+1:end),tb_zi(npt_plg+1:end),'k-');
end
plot(dist,zb_av,'b-');
axis([-inf,inf,-inf,inf]);            %adjust the axis
set(gca,'Xtick',min(dist):10:max(dist));           %设置分度数字标识

title(g_title);
hold off;

end


%-----------------------nested function----------------------------
    function addVerticalLine
        
        if vline_flag==1
            nline=numel(xcs);
            for j=1:1:nline
                xline=dist(xcs(j));
                ylimits=get(gca, 'ylim');
                line([xline xline], ylimits, 'Color', [0.5 0.5 0.5]);
            end
        end
    end
        

%----------------------------------------------------------------------
%-----------------------nested function----------------------------
 function draw_open_chan
 
     subplot(2,3,[1 2 3]);              %拉长单幅图
     plot(dist,cszw,'m-');
     hold on;
     plot(dist,zb_av,'bo-');
     %  if npt_plg~=0
     %     hold on;
     %     plot(dist(npt_plg),cszw(npt_plg),'co');            %标记潜入点
     %  end
     title(g_title);
     axis([handles.xlim_minV, handles.xlim_maxV, handles.ylim_minV, handles.ylim_maxV]);
     hold off;
     
     subplot(2,3,4);
     plot(dist,csqq,'b-');
     hold on;
     plot([dist(1),dist(end)],[0,0]);           %添加0网格线
     title('CSQQ');
     hold off;
     
     subplot(2,3,5);
     plot(dist,sus,'g-');
     hold on;
     plot(dist,scc,'k-');
     hold off;
     title('SUS and SCC');
     
     if NoBedLd==0
         subplot(2,3,6);
         ics1=240;
         plot(dist(ics1:end), csqbstar(ics1:end), 'k-');
         hold on;
         plot(dist(ics1:end), csqb(ics1:end), 'g-');
         hold off;
         title('csqb* and csqb');
         legend('csqb*', 'csqb');
     end
     
     axis([-inf,inf,-inf,inf]);            %adjust the axis
     %set(gca,'Xtick',min(dist):10:max(dist));           %设置分度数字标识
 end
%-----------------------------------------------------------------------
%-----------------------nested function----------------------------
function kkk=get_head_col(HdName)
%LL=strfind(hn{1},HdName);
LL=find(strcmp(hn{1}, HdName), 1);

if isempty(LL)
    kkk=0;
else
    kkk=LL;
end

end
%-----------------------------------------------------------------------
end


function LeftClickFcn(hObject,callbackdata)
    % Check if the left mouse button was clicked
    if strcmp(get(hObject, 'SelectionType'), 'normal')
        % Set the 'is_paused' application data to true
        setappdata(hObject, 'is_paused', true);
    end
end

        