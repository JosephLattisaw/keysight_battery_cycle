#ifndef IEEE488_COMMON_COMMANDS_HPP
#define IEEE488_COMMON_COMMANDS_HPP

#include <string>

class IEEE488CommonCommands {
public:
    IEEE488CommonCommands();

    // Aborts the sequence in progress. When a sequence is aborted,
    // the power connections open into a high impedence state.
    void abort();

    // Runs channel calibration on all channels. Same as CAL:AUTO
    // returns a zero when successful, and a 1 otherwise.
    void calibrate(std::string channels);

    // Clears the event register in all register groups.
    // Also clears the status byte and Error Queue.
    void clear_status();

    // TODO do we need the return of this value
    // Sets the value of the enable register for the Standard Operation Group.
    // Each set bit of the register enables a corresponding event.
    // All enabled events are logically ORed into the ESB bit of the status byte.
    void event_status_enable_command(std::string value);
    void event_status_enable_query();

    // TODO do we need the return of this value
    // reads and clears the event register fo the Standard Operation Group.
    // The event register latches all standard events.
    void event_status_event_query();

    // Returns the instruments identification string, which contains the following fields:
    // manufacturer, product number, serial number, major.minor system rev(build id) - major.minor card
    // rev(card build id) - major.minor fpga rev - cardFpgaRev - boardId - cardBoardId - #of DigitalPins
    void identification_query();

    //*OPC Sets the OPC (operation complete) bit in the
    // standard event register when the instrument has completed all pending operations sent before *OPC.
    // This occurs at the completion of the current operation
    void operation_complete_command();
    void operation_complete_query();

    // Resets the instrument to pre-defined values that are either typical or safe. These
    // settings are described under Reset Settings.
    void reset_command();

    // Reads the Status Byte Register, which contains the status summary bits and the
    // Output Queue MAV bit. The Status Byte is a read-only register and the bits are not cleared when it is
    // read.
    void status_byte_query();

    // Performs an instrument self-test. A 0 (zero) indicates the instrument passed self-test.
    // If self-test fails, one or more error messages will provide additional information. Use SYSTem:ERRor?
    // to read the error queue
    void self_test_query();

    // Pauses additional command processing until updated data has been received from all connected
    // channels.
    void wait();
};

#endif