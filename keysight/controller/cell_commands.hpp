#ifndef CELL_COMMANDS_HPP
#define CELL_COMMANDS_HPP

#include <visa.h>

#include <string>
#include <vector>

// Cell commands program a group of channels that have been paralleled together using the
// CELL:DEFine command. Use the <cell_ID> or <cell_list> parameter to send commands to multiple
// cells. Refer to Cell ID for more information.

class CellCommands {
public:
    CellCommands();

    std::vector<std::string> define_cells_for_all_cards(const ViSession &session, std::vector<int> active_cards) const;
};

#endif