#include "cell_commands.hpp"

#include "logger.hpp"

#define LOG_OUT LogOut("cell_command_handler")
#define LOG_ERR LogOut("cell_command_handler")

CellCommands::CellCommands(boost::asio::io_service &io_service) : io_service(io_service), cell_status_timer(io_service) {}

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
            for (auto k = 0; k < 32; k++) {
                auto mod_nbr = std::to_string(i + 1);
                auto card_nbr = std::to_string(k + 1);

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

void CellCommands::start_polling_cell_status(const ViSession &session, std::vector<std::string> cells) {
    cell_status_timer.expires_after(std::chrono::seconds(1));
    cell_status_timer.async_wait([&, session, cells](const boost::system::error_code &error) {
        ViChar cell_voltage[65535];
        viPrintf(session, "MEAS:CELL:VOLT? (@1001:3032)\n");
        // viPrintf(session, "MEAS:CELL:VOLT? (@1001:3032)\n");
        viScanf(session, "%t", cell_voltage);
        viFlush(session, 0x10);
        LOG_OUT << ": cell voltage: "
                << " " << cell_voltage;

        ViChar cap_ahr[65535];
        viPrintf(session, "MEAS:CELL:CAP:AHR? (@1001:3032)\n");
        viScanf(session, "%t", cap_ahr);
        viFlush(session, 0x10);
        LOG_OUT << ": cap ahr: "
                << " " << cap_ahr;

        ViChar current[65535];
        viPrintf(session, "MEAS:CELL:CURR? (@1001:3032)\n");
        viScanf(session, "%t", current);
        viFlush(session, 0x10);
        LOG_OUT << ": current: "
                << " " << current;

        ViChar watthr[65535];
        viPrintf(session, "MEAS:CELL:CAP:WHR? (@1001:3032)\n");
        viScanf(session, "%t", watthr);
        viFlush(session, 0x10);
        LOG_OUT << ": watthr: "
                << " " << watthr;

        // viPrintf(session, "MEAS:CELL:VOLT? (@1001:3032)\n");
        // viScanf(session, "%t", cell_voltage);
        /*for (auto i = 1; i < 4; i++) {
            for (auto k = 1; k < 33; k++) {
                std::string s1 = "STAT:CELL:VERB? ";
                std::string s2 = std::to_string(k);
                std::string s3 = (k < 10) ? "00" : "0";
                std::string s4 = std::to_string(i);
                std::string s5 = "\n";
                std::string s = s1 + s2 + s3 + s4 + s5;

                // viPrintf(session, "STAT:CELL:VERB? 1001\n");
                viPrintf(session, s.c_str());
                viScanf(session, "%t", cell_voltage);

                LOG_OUT << ": cell voltage: " << std::to_string(k) << " " << cell_voltage;
            }
        }*/
        /*for (auto i = 0; i < cells.size(); i++) {
            ViChar cell_voltage[65535];
            viPrintf(session, "MEAS:CELL:VOLT? (@3001:3032)\n");
            viScanf(session, "%t", cell_voltage);
            viFlush(session, 0x10);
            // viPrintf(session, "MEAS:CELL:VOLT? (@1001)\n");
            std::string s1 = "MEAS:CELL:VOLT? (@";
            std::string s2 = ")\n";
            auto s = s1 + cells.at(i) + s2;
            LOG_OUT << "command: " << s;
            // viPrintf(session, s.c_str());
            // viScanf(session, "%t", cell_voltage);
            // viFlush(session, 0x10);
            LOG_OUT << cells.at(i) << ": cell voltage: " << cell_voltage;
        }*/
        start_polling_cell_status(session, cells);
    });
}