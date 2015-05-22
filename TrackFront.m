clear all;
nfile=0;
file_id=fopen(['LYR_FCSLPF  ',num2str(nfile),'.TXT']);
prompt={'Input jumps:','Input the number of cross sections:'};
dlg_ans=inputdlg(prompt);
dtjump=str2num(dlg_ans{1});
nCS=str2num(dlg_ans{2});

cs_dist=zeros(1,nCS);
tbsus=zeros(1,nCS);                   %concentration of suspended load(kg/m3)
tbzi=zeros(1,nCS);                 %交界面高程
x_front=0;
ndt_front=0;

jump=1;
ndt=0;
while file_id>=3           %open successfully
    while ~feof(file_id)
        tline=fgetl(file_id);
        g_title=tline;       
        tline=fgetl(file_id);
        ndt=ndt+1;
        for k=1:1:nCS
            tline=fgetl(file_id);
            a=textscan(tline,'%f');
            if size(a{1},1)<17
                %异重流还没产生
                continue;
            end
            cs_dist(k)=a{1}(2);       %extract x coordinate of CS
            % track the front by tbsus
            tbsus(k)=a{1}(16);
            %tbzi(k)=a{1}(14);
        end
        
        if jump==dtjump
            front_ncs=find(tbsus>=0.001,1,'last');
            %front_ncs=find(tbzi>1.007,1,'last');
            x_front=[x_front,cs_dist(front_ncs)];
            ndt_front=[ndt_front,ndt];
            jump=1;
        else
            jump=jump+1;
        end
    end
    
    fclose(file_id);
    nfile=nfile+1;
    file_id=fopen(['LYR_FCSLPF  ',num2str(nfile),'.TXT']);
end

x_front=x_front.';
ndt_front=ndt_front.';
disp('refer to ndt_front and x_front to see the result');