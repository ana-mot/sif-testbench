
package environment_pkg;
    typedef enum {WRITE, READ} direction;
    typedef enum { NO_DELAY, MAX_DELAY} delay_mode_g;
    `include "transaction.svh"
    `include "config.svh"
    `include "generator.svh"
    `include "driver.svh"
    `include "monitor.svh"
    `include "scoreboard.svh"
endpackage

