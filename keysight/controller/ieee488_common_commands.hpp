#ifndef IEEE488_COMMON_COMMANDS_HPP
#define IEEE488_COMMON_COMMANDS_HPP

#include <visa.h>

#include <string>

class IEEE488CommonCommands {
public:
    IEEE488CommonCommands();

    // Returns the instruments identification string, which contains the following fields:
    // manufacturer, product number, serial number, major.minor system rev(build id) - major.minor card
    // rev(card build id) - major.minor fpga rev - cardFpgaRev - boardId - cardBoardId - #of DigitalPins
    std::string identification_query(const ViSession &session) const;
};

#endif