#ifndef SYSTEM_COMMANDS_HPP
#define SYSTEM_COMMANDS_HPP

#include <visa.h>

#include <string>
#include <vector>

class SystemCommands {
public:
    SystemCommands();

    std::vector<int> detect_cards_at_boot(const ViSession &session);
};

#endif