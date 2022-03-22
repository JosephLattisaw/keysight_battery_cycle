#ifndef MEASURE_COMMANDS_HPP
#define MEASURE_COMMANDS_HPP

#include <string>

// Measure commands return measurements from the specified channel or cell.

class MeasureCommands {
public:
    MeasureCommands();

    // Returns the accumulated ampere-hour capacity of the specified channels (or cells).
    void capacity_ahr(std::string channel_list);
    void cell_capacity_ahr(std::string cell_list);

    // Returns the accumulated watt-hour capacity of the specified channels (or cells).
    void capacity_whr(std::string channel_list);
    void cell_capacity_whr(std::string cell_list);

    // Returns the latest measured current of the specified channels (or cells) in amperes.
    void current(std::string channel_list);
    void cell_current(std::string cell_list);

    // Clears the ampere-hour and watt-hour capacity measurement of the specified channels (or cells).
    void reset(std::string channel_list);
    void cell_reset(std::string cell_list);

    // Returns the latest measured voltage at the specified channels (or cells) in volts.
    void voltage(std::string channel_list);
    void cell_voltage(std::string cell_list);
};

#endif