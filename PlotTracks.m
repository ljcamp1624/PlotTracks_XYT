function PlotTracks(image,tracks,varargin)

a = unique(tracks(:,4));
time_list = tracks(:,3);
color_scheme = lines(length(a));

flag = 1;
if nargin == 3
    close all
    display_figure = imshow(image(:,:,1)); hold on;
    
    pause(5);
    vv = VideoWriter(varargin{1});
    vv.FrameRate = 12; 
    open(vv);
    
elseif nargin == 4
    display_figure = imshow(image(:,:,1)); hold on;
    
elseif nargin == 6
    close all
    
    vx = varargin{1};
    vy = varargin{2};
    flowFac = varargin{3};
    [ix, iy, ~] = ndgrid(1:size(vx, 1), 1:size(vx, 2), 1:size(vx, 3));
    idx = (mod(ix, flowFac) == 0) .* (mod(iy, flowFac) == 0); idx = idx == 1;
    vxShow = vx; vxShow(~idx) = 0;
    vyShow = vy; vyShow(~idx) = 0;
    
    figure;
    display_figure = imshow(image(:,:,1)); hold on;
    figure_flow = quiver(vxShow(:,:,1),vyShow(:,:,1),3*flowFac,'r');
    
    pause(5);
    vv = VideoWriter(varargin{4});
    open(vv);
else
    display_figure = imshow(image(:,:,1)); hold on;
end



while flag == 1
    
    for i = min(time_list(:)):max(time_list(:))
        
        set(display_figure,'CData',image(:,:,i)); hold on;
        
        
        all_ids_t = unique(tracks(tracks(:,3) == i,4));
        
        for j = 1:length(all_ids_t)
            
            curr_id = all_ids_t(j);
            curr_path = tracks((tracks(:,4) == curr_id).*(tracks(:,3) <= i) > 0,[1,2]);
            if size(curr_path,1) == 0
            elseif size(curr_path,1) == 1
                lead_point{a == curr_id} = scatter(curr_path(:,1),curr_path(:,2),75,color_scheme(a == curr_id,:), 'filled'); hold on;
                path_plots{a == curr_id} = plot(curr_path(:,1),curr_path(:,2),'-','Color',color_scheme(a == curr_id,:), 'LineWidth', 4); hold on;
            else
                set(lead_point{a == curr_id},'XData',curr_path(end,1),'YData',curr_path(end,2));
                set(path_plots{a == curr_id},'XData',[get(path_plots{a == curr_id},'XData'),curr_path(end,1)],'YData',[get(path_plots{a == curr_id},'YData'),curr_path(end,2)]);
            end
            
        end
        
        hold off;
        if nargin == 6
            hold on;
            set(figure_flow,'UData',vxShow(:,:,i),'VData',vyShow(:,:,i)); hold on;
            hold off;
        end
        drawnow; pause(1/60);
        if nargin == 3 | nargin == 6
            currFrame = getframe(gca);
            writeVideo(vv, currFrame);
        end
    end
    
    for i = 1:length(lead_point)
        set(lead_point{i}, 'Visible', 'off');
    end
    drawnow;
    clear lead_point
    
    if nargin == 3 | nargin == 6
        flag = 0;
        close(vv);
    elseif nargin == 4
        flag = 0;
    end
    
    
end

end