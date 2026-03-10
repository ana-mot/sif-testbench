class Configuration;
    rand int unsigned nr_frames;
    rand int unsigned max_delay;
    rand delay_mode_g delay_mode;
    rand int n_resets;
    
    constraint c_reset { soft n_resets inside {[1:100]}; }
    constraint c_frames { nr_frames inside {[1:1000]}; }
    constraint c_delay { max_delay inside {[0:20]}; }

endclass //Configuration