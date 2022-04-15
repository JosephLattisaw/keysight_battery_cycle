#include "cell_commands.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("cell_command_handler")
#define LOG_ERR LogOut("cell_command_handler")

CellCommands::CellCommands() {}

std::vector<std::string> CellCommands::define_cells_for_all_cards(const ViSession &session, std::vector<int> active_cards) const {
    // viPrintf(session, "CELL:DEFINE 1025,(@125)\n");

    std::string s1 = "CELL:DEFINE ";
    std::string s2 = "0";
    std::string s3 = ",(@";
    std::string s4 = "";
    std::string s5 = ")\n";

    std::vector<std::string> cell_names;

    for (auto i = 0; i < active_cards.size(); i++) {
        if (static_cast<bool>(active_cards.at(i))) {
            // card is active if we make it here
            for (auto k = 0; k < 33; k++) {
                auto mod_nbr = std::to_string(i + 1);
                auto card_nbr = std::to_string(k);

                s2 = (k < 10) ? "00" : "0";
                s4 = (k < 10) ? "0" : "";

                auto s = s1 + mod_nbr + s2 + card_nbr + s3 + mod_nbr + s4 + card_nbr + s5;
                auto sx = mod_nbr + s2 + card_nbr;
                LOG_OUT << "command: " << s;
                LOG_OUT << "cell number: " << sx;
                viPrintf(session, s.c_str());
                cell_names.push_back(sx);
            }
        }
    }

    return cell_names;
}