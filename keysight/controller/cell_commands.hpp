#ifndef CELL_COMMANDS_HPP
#define CELL_COMMANDS_HPP

#include <visa.h>

#include <boost/asio.hpp>
#include <string>
#include <vector>

// Cell commands program a group of channels that have been paralleled together using the
// CELL:DEFine command. Use the <cell_ID> or <cell_list> parameter to send commands to multiple
// cells. Refer to Cell ID for more information.

class CellCommands {
public:
    CellCommands(boost::asio::io_service &io_service);

    std::vector<std::string> define_cells_for_all_cards(const ViSession &session, std::vector<int> active_cards) const;

    void start_polling_cell_status(const ViSession &session, std::vector<std::string> cells);

private:
    boost::asio::io_service &io_service;

    boost::asio::steady_timer cell_status_timer;
};

#endif