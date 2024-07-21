function vid = make_video(vid_name, t,y, vid_framerate, robots, targ)
for i = 1:size(y,1)
    time = t(i);
    if i == 1
        frame = 1;
    elseif time < (t_prev+1/vid_framerate)
        continue
    end
    mydisplay(robots, [y(i,1) y(i,3)], targ, time)
    drawnow
    vid(frame) = getframe(gcf);
    t_prev = time;
    frame = frame+1;
end
vidfile = VideoWriter(vid_name, 'MPEG-4');
vidfile.FrameRate = vid_framerate;
open(vidfile)
writeVideo(vidfile,vid)
close(vidfile)
end