#ifndef ROOT_COMMANDS_HPP
#define ROOT_COMMANDS_HPP

#include <string>

// Root commands program the watchdog timer

class RootCommands {
public:
    RootCommands();

    // Enables/disables the IO watchdog timer. When enabled, the sequence is aborted if there is no IO
    // activity on any remote interface within the time period specified by ROOT:WATChdog:TOUT.
    // When a sequence is aborted, the power connections open into a high impedance state.
    void watchdog_enable(std::string status);
    void watchdog_enable();

    // Sets the watchdog delay time. When the watchdog timer is enabled, the sequence is aborted if there
    // is no IO activity on any remote interface within the time period specified by the delay time.
    // Programmed values can range from 1 to 3600 seconds in 1 second increments.
    void watchdog_tout(std::string value);
    void watchdog_tout();

    // Resets the watchdog timer to the specified delay time (TOUT), which restarts the watchdog
    // countdown. Any other SCPI command will also reset the timer.
    void watchdog_reset();
};

#endif