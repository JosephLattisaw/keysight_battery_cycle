#ifndef CALIBRATION_COMMANDS_HPP
#define CALIBRATION_COMMANDS_HPP

#include <string>

class CalibrationCommands {
public:
    CalibrationCommands();

    // Runs Channel Calibration on the specified channels. During channel calibration, each individual
    // channel is sequentially connected to the internal reference and gain and offset corrections are
    // calculated and stored in non-volatile memory. The command returns a 0 (zero) when successful, and
    // a +1 when a channel failed
    void auto_command(std::string channels);

    // Initiates the calibration procedure.
    void start();

    // Steps through the different calibration processes; executes a reset after the command is sent. The
    // query returns 0 (zero) if no step is sent
    int step_command(std::string step);

    // Calculates and stores the calibration constants in the EEPROM if they are within reasonable limits.
    // This step overwrites the previous calibration constants.
    void store();

    // TODO find out if there is actually a return
    // Stores a message in calibration memory. Common messages include the last calibration date,
    // calibration due date, or calibration contact information. You can save calibrations strings for the
    // mainframe as well as the charge/discharge modules. An index value, which is required for the
    // charge/discharge modules, lets you save up to two string per target.
    void string_command(std::string target, std::string message, std::string log_number);
    void string_command(std::string target, std::string log_number);

    // Sends the valid calibration measurement to the instrument. Values are either in volts or amps
    // depending on the step. The command returns a 0 (zero) when successful, and a +1 otherwise.
    void value_command(std::string step, std::string value);
};

#endif