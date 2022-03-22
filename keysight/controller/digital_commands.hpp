#ifndef DIGITAL_COMMANDS_HPP
#define DIGITAL_COMMANDS_HPP

#include <string>

// Digital commands program the digital control port(s) on the rear panel of the instrument.
// For Keysight BT2202A, the digital commands program the 23 digital IO pins located on both the 8-pin
// and the 25-pin digital connectors.
// For Keysight BT2203A, the digital commands program the 7 digital IO pins located on the 8-pin digital
// connector.

class DigitalCommands {
public:
    DigitalCommands();

    // Assigns a cell-abort list to a digital IO pin. Whenever the digital pin receives an abort signal (logic
    // true), the sequences running on the cells assigned to that pin will be aborted. The signal logic is set by
    // the DIGital:POLarity command.When a sequence is aborted, the power connections open into a high
    // impedance state. If a CELL:INIT is executed while a pin is in the Abort state, none of the cells assigned
    // to that digital pin will be initiated.
    void cell_abort(std::string pin, std::string cell_list);
    void cell_abort(std::string pin);

    // Returns the number of digital IO pins available in the mainframe.
    void channels();

    // Specifies the pin function.
    // CABort - Cell abort mode - applies to all pins
    // DIO - Digital input/output mode - applies to all pins
    // DINPut - Digital input-only mode - applies to all pins
    // FAULt - Pin 1 functions as an isolated fault output; pin 2 is common for pin 1
    // INHibit - Pin 3 functions as an inhibit input
    void function_command(std::string pin, std::string function_type);
    void function_command(std::string pin);

    // Reads the state of the digital control port. For BT2202A, returns the binary-weighted value of the
    // state of pins 1 through 23 in bits 0 through 22 respectively. For BT2203A, returns the binary-weighted
    // value of the state of pins 1 through 7 in bits 0 through 6 respectively.
    void input_data();

    // Sets the state of the digital control port. This only affects the pins whose function has been set to
    // Digital IO operation. For the BT2202A, the ports have 23 signal pins and up to 8 common (ground) pins.
    // For the BT2203A, the ports have seven signal pins and one common (ground) pin.
    void output_data(std::string value);
    void output_data();

    // Sets the pin polarity. POSitive means a logical true signal is a voltage high at the pin. NEGative means
    // a logical true signal is a voltage low at the pin.
    void polarity(std::string pin, std::string polarity);
    void polarity(std::string pin);
};

#endif