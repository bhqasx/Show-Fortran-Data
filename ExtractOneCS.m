function ExtractOneCS
% extract and draw simulation results at a given cross-section

FrameJump=160;        %frame refreshing rate
nCS=56;    %total number of cross-sections in computational domain
iCS=49;      %number of cross-section to extract data from
t_start=330;     %time to extract data;
field_o='TbFrd';       %variable to be output

nfile=0;
file_id=fopen(['FCSLPF  ',num2str(nfile),'.TXT']);

jump=1;
x_out=[];
y_out=[];
while file_id>=3           %open successfully
    while ~feof(file_id)
        tline=fgetl(file_id);
        g_title=tline;       %title to be shown in the graph
        tline=fgetl(file_id);
        hn=textscan(tline,'%s');
      
        n_head=length(hn{1});
        
        icol_tb_zi=get_head_col('TbZI');
        icol_o=get_head_col(field_o);
        
        if icol_tb_zi==0       %there is no turbidity current
            tb_flag=0;
        else
            tb_flag=1;
        end
        
        a=textscan(g_title,'%s%f%s%s%f');
        x=a{2}(1);        %get time
              
        if (jump>=FrameJump)&&(tb_flag==1)&&(x>=t_start)
            for k=1:1:nCS
                tline=fgetl(file_id);
                
                if k==iCS
                    a=textscan(tline,'%f');                    
                    y=a{1}(icol_o);       %read the variable requierd by user
                end
            end
            
            x_out=[x_out;x];
            y_out=[y_out;y];
            jump=1;           
        else
            for k=1:1:nCS
                tline=fgetl(file_id);
            end
            jump=jump+1;
        end       
    end
    fclose(file_id);
    nfile=nfile+1;
    file_id=fopen(['FCSLPF  ',num2str(nfile),'.TXT']);
end

plot(x_out,y_out);
disp('finished');

%-----------------------nested function----------------------------
function kkk=get_head_col(HdName)
LL=strfind(hn{1},HdName);

for j=1:n_head
    kkk=isempty(LL{j});
    if kkk==0
        kkk=j;
        break;
    end
end

if kkk==1      %head not found
    kkk=0;
end

end
%-----------------------------------------------------------------------

end
