#ifndef BATTERY_CELL
#define BATTERY_CELL

#include <cmath>
#include <cstdint>

class BatteryCell {
public:
    BatteryCell();

private:
    // cell statuses
    std::double_t capacity_ahr = 0;
    std::double_t capacity_whr = 0;

    // verbose statuses
    std::double_t voltage = 0;
    std::double_t current = 0;
    std::uint16_t states = 0;
    std::uint16_t statuses = 0;
    std::uint16_t sequences = 0;
    std::uint16_t steps = 0;
};

#endif