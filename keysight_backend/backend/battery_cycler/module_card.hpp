#ifndef MODULE_CARD_HPP
#define MODULE_CARD_HPP

#include <array>
#include <memory>

#include "battery_cell.hpp"

class ModuleCard {
public:
    ModuleCard();

    bool is_active() { return active; }
    void set_card_active(bool flag) { active = flag; }

private:
    bool active = false;
    std::array<std::shared_ptr<BatteryCell>, 32> cells;
};

#endif