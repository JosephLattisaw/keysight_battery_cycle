#ifndef SYSTEM_COMMANDS_HPP
#define SYSTEM_COMMANDS_HPP

#include <string>

class SystemCommands {
public:
    SystemCommands();

    // Returns what module cards are detected. SYSTem:CARD:DETect:BOOT? returns the cards detected
    // at bootup. SYSTem:CARD:DETect:NOW? returns the cards detected at present.
    void card_detect_boot(std::string card);
    void card_detect_now(std::string card);

    // Disables or enables instrument's use of DHCP. DHCP stands for Dynamic Host Configuration Protocol,
    // a protocol for assigning dynamic IP addresses to networked devices. With dynamic addressing, a
    // device can have a different IP address every time it connects to the network.
    // ON - the instrument tries to obtain an IP address from a DHCP server. If a DHCP server is found, it
    // assigns a dynamic IP address, Subnet Mask, and Default Gateway to the instrument.
    // OFF or DHCP unavailable - the instrument uses the static IP address, Subnet Mask, and Default
    // Gateway during power-on.
    void communicate_lan_dhcp(std::string value);
    void communicate_lan_dhcp();

    // Returns the domain name assigned to the instrument.
    void communicate_lan_domain();

    // Assigns a default gateway for the instrument. The specified IP Address sets the default gateway,
    // which allows the instrument to communicate with systems that are not on the local subnet. Thus, this
    // is the default gateway where packets are sent that are destined for a device not on the local subnet,
    // as determined by the Subnet Mask setting. Contact your LAN administrator for details.
    // The optional CURRent query returns the address currently being used. The optional STATic returns
    // the static address from non-volatile memory. This address is used if DHCP is disabled or unavailable.
    // The optional PENDing returns the value sent, but is not yet committed to non-volatile memory.
    void communicate_lan_gateway(std::string address);
    void communicate_lan_gateway_(std::string static_host);

    // Assigns a hostname to the instrument. A hostname is the host portion of the domain name, which is
    // translated into an IP address. If Dynamic Domain Name System (Dynamic DNS) is available on your
    // network and your instrument uses DHCP, the hostname is registered with the Dynamic DNS service at
    // power-on. If DHCP is enabled, the DHCP server can change the specified hostname. Contact your
    // LAN administrator for details.
    // The optional CURRent query returns the name currently being used. The optional STATic returns the
    // name from non-volatile memory. This may not be the actual name used by the instrument if DHCP is
    // enabled. The optional PENDing returns the value sent, but is not yet committed to non-volatile
    // memory.
    void communicate_lan_hostname(std::string address);
    void communicate_lan_hostname_(std::string static_host);

    // Assigns a static Internet Protocol (IP) address for the instrument. If DHCP is enabled, the specified
    // static IP address is not used. Contact your LAN administrator for details.
    // The optional CURRent query returns the address currently being used. The optional STATic returns
    // the static address from non-volatile memory. This address may not be the actual address used by the
    // instrument if DHCP is enabled. The optional PENDing returns the value sent, but is not yet committed
    // to non-volatile memory.
    void communicate_lan_ipaddress(std::string address);
    void communicate_lan_ipaddress_(std::string static_host);

    // Returns the instrument's Media Access Control (MAC) address as an ASCII string of 12 hexadecimal
    // characters (0-9 and A-F) enclosed in quotation marks.
    void communicate_lan_mac();

    // Assigns a subnet mask for the instrument to use in determining whether a client IP address is on the
    // same local subnet. When a client IP address is on a different subnet, all packets must be sent to the
    // Default Gateway. Contact your LAN administrator for details.
    // The optional CURRent query returns the address currently being used. The optional STATic returns
    // the static address from non-volatile memory. The optional PENDing returns the value sent, but is not
    // yet committed to non-volatile memory.
    void communicate_lan_smask(std::string mask);
    void communicate_lan_smask_(std::string mask);

    // Specifies the command prompt seen when communicating with the instrument via Telnet.
    void communicate_lan_telnet_prompt(std::string value);
    void communicate_lan_telnet_prompt();

    // Specifies the welcome message seen when communicating with the instrument via Telnet.
    void communicate_lan_telnet_wmessage(std::string value);
    void communicate_lan_telnet_wmessage();

    // Stores any changes made to the LAN settings into non-volatile memory and restarts the LAN driver
    // with the updated settings.
    void communicate_lan_update();

    // Reads and clears one error from the error queue.
    void error();

    // Sets the upper limit for the probe check for all channels in ohms. It has a maximum value of 10 ohms.
    // The default is 0.5 Ω. The zero following the value must be included as a placeholder for the channel
    // list, otherwise an error will be generated.
    void probe_check_limit(std::string value);
    void probe_check_limit();

    // Reboots the entire charge/discharge system including all installed cards.
    void reboot_system();

    // Tests the entire charge/discharge system, including modules. If 0 (zero) is returned, no errors found. If
    // 1 is returned, errors have occurred. Use SYSTem:ERRor? to return the error. Same as *TST?
    void test_all();

    // Tests the charge-discharge system mainframe. If 0 (zero) is returned, no errors found. If 1 is returned,
    // errors have occurred. Use SYSTem:ERRor? to return the error.
    void test_mainframe();

    // Tests the specified channel(s). If 0 (zero) is returned, no errors found. If 1 is returned, errors have
    // occurred. Use SYSTem:ERRor? to return the error.
    void test_channel();

    // Returns the time that the CDS has been running since its last power-on. The returned values indicate
    // days, hours, minutes, and seconds, respectively.
    void uptime();
};

#endif