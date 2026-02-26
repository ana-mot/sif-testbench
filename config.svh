class Configuration;
    rand int unsigned nr_frames;
    rand int unsigned max_delay;
    rand delay_mode_g delay_mode;

    constraint c_frames { nr_frames inside {[1:30]}; }
    constraint c_delay { max_delay inside {[0:20]}; }
    
    function new();
        nr_frames = 10;
        max_delay = 5;
        delay_mode = MAX_DELAY;
    endfunction //new()
endclass //Configuration