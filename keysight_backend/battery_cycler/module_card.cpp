#include "module_card.hpp"

ModuleCard::ModuleCard() { cells.fill(std::make_shared<BatteryCell>()); }