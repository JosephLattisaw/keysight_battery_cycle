#ifndef LXI_COMMANDS_HPP
#define LXI_COMMANDS_HPP

#include <string>

// LXI commands program the LXI functions of the instrument.

class LXICommands {
public:
    LXICommands();

    // Turns the front panel LXI identify indicator on or off. When turned on, the "LAN" status indicator on the
    // front panel blinks on and off to identify the instrument that is being addressed.
    void identify_state(std::string status);
    void identify_state();

    // Enables or disables the multicast Domain Name System (mDNS),which provides the capabilities of a
    // DNS server for service discovery in a small network without a DNS server. This setting is non-volatile.
    void mdns_enable(std::string status);
    void mdns_enable();

    // Returns the resolved (unique) mDNS hostname in the form K-<model number>-<serial>, where
    //<serial> is the last 5 digits of the instrument's serial number.
    void mdns_hnam_e_resolved();

    // Sets the desired mDNS service name. Enter any ASCII string up to 63 characters. This setting is non-
    // volatile.
    void mdns_sname_desired(std::string name);
    void mdns_sname_desired();

    // The resolved mDNS service name will be the desired service name.
    void mdns_sname_resolved();

    // Resets all network settings to their factory settings. Refer to Reset Settings.
    void reset();

    // Resets the LAN to the settings specified by the SYSTem:COMMunicate:LAN commands.
    void restart();
};

#endif