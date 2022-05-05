#include "keysight.hpp"

#include <algorithm>

#include "common.hpp"
#include "logger.hpp"

#define LOG_OUT LogOut("keysight")
#define LOG_ERR LogOut("keysight")

namespace keysight {
extern ViSession resource_manager;
extern ViSession session;

}  // namespace keysight

using namespace keysight;

Keysight::Keysight(boost::asio::io_service &io_service, ActiveCardsCallback ac_cb, ConnectionStatusCallback conn_cb, PortDoubleCallback pd_cb,
                   PortUint16Callback pu16_cb, LoadedProfilesCallback lp_cb, ProfilesStatusCallback ps_cb, ProfilesStatusCallback ss_cb,
                   TimeStatusCallback ts_cb, ProfilesStatusCallback cyc_cb, TimeStatusCallback tt_cb)
    : io_service(io_service),
      cell_status_timer(io_service),
      active_cards_callback{ac_cb},
      connection_status_callback{conn_cb},
      port_double_callback{pd_cb},
      port_uint16_callback{pu16_cb},
      loaded_profiles_callback{lp_cb},
      profile_status_callback{ps_cb},
      slot_status_callback{ss_cb},
      time_status_callback{ts_cb},
      cycles_status_callback{cyc_cb},
      total_time_callback{tt_cb} {
    currently_loaded_profiles.fill("");
    current_profile_statuses.fill(0);
    current_seq_uptime.fill(0.0);
    total_seq_uptime.fill(0.0);
    total_seq_uptime_offset.fill(0.0);
    cycles_count.fill(0);
}

Keysight::~Keysight() { disconnect(); }

void Keysight::connect() {
    if (!connected) {
        // opening the Keysight BT2203A
        if (open_resource_manager()) {
            if (open_instrument()) {
                if (enable_read_termination_character()) {
                    if (identification_query()) {
                        LOG_OUT << "identified " << VISA_ADDRESS_BT2203A;

                        if (detect_cards_at_boot()) {
                            if (reset()) {
                                LOG_OUT << "successfully detected all cards at boot";
                                if (define_cells_for_all_cards()) {
                                    LOG_OUT << "successfully set all cell names";
                                    update_connection_status(true);
                                    start_polling_cell_status();
                                } else {
                                    LOG_ERR << "failed to set all active cells";
                                    disconnect();
                                }
                            } else {
                                LOG_ERR << "failed to reset all data";
                                disconnect();
                            }
                        } else {
                            LOG_ERR << "failed to determine the active cards";
                            disconnect();
                        }

                    } else {
                        LOG_ERR << "failed to find identify: " << VISA_ADDRESS_BT2203A;
                        disconnect();
                    }
                } else {
                    LOG_ERR << "failed to enabled read termination character";
                    disconnect();
                }
            } else {
                LOG_ERR << "failed to open instrument";
                disconnect();
            }
        } else {
            LOG_ERR << "failed to open resoucrce manager";
            disconnect();
        }
    } else
        LOG_ERR << "already connected";
}

void Keysight::update_connection_status(bool flag) {
    connected = flag;
    connection_status_callback(connected);
}

void Keysight::disconnect() {
    if (connected) {
        viUnlock(session);
        viClose(session);
        viClose(resource_manager);

        keysight::resource_manager = 0;
        keysight::session = 0;

        active_cards.clear();
        cell_names.clear();
        cell_cap_ahr_data.clear();
        cell_cap_whr_data.clear();
        cell_voltage_data.clear();
        cell_current_data.clear();
        cell_sequence_id_data.clear();
        cell_step_id_data.clear();

        cell_status_timer.cancel();

        currently_loaded_profiles.fill("");
        current_profile_statuses.fill(0);

        update_connection_status(false);
        loaded_profiles_callback(currently_loaded_profiles);
        profile_status_callback(current_profile_statuses);
    }
}

bool Keysight::open_resource_manager() {
    LOG_OUT << "attempting to open resource manager...";

#ifndef SOFTWARE_ONLY
    auto status = viOpenDefaultRM(&resource_manager);  // opening resource manager

    auto res = keysight::verify_vi_status(session, status, "opened resource manager",
                                          "There was a problem opening the default resource manager, error code: ");
#else
    auto res = true;
#endif

    return res;
}

bool Keysight::open_instrument() {
    LOG_OUT << "attempting to open instrument";

#ifndef SOFTWARE_ONLY
    auto status = viOpen(resource_manager, VISA_ADDRESS_BT2203A.c_str(), VI_NULL, VI_NULL, &session);

    auto res = keysight::verify_vi_status(session, status, "opened instrument",
                                          "There was a problem opening the connection to the instrument, error code: ");

    if (res) {
        ViChar full_address[65535];
        // TODO check that this lock crap works
        status = viLock(session, VI_SHARED_LOCK, VI_TMO_IMMEDIATE, "IBEOS", full_address);

        res = keysight::verify_vi_status(session, status, "locked instrument", "There was a problem locking the instrument, error code: ");
        if (res) {
            return true;
        }
    }

    return false;
#else
    return true;
#endif
}

bool Keysight::enable_read_termination_character() {
#ifndef SOFTWARE_ONLY
    // For Serial and TCP/IP socket connections enable the read Termination character, or read's will timeout
    ViChar full_address[100];
    ViStatus status;
    bool res;

    status = viGetAttribute(session, VI_ATTR_RSRC_NAME, full_address);
    res = keysight::verify_vi_status(session, status, "enabled read termination character",
                                     "There was a problem getting the attributes resource name, error code: ");

    if (res) {
        if (std::string("ASRL").compare(full_address) == 0 || std::string("SOCKET").compare(full_address) == 0) {
            LOG_OUT << "controller: detected Serial or TCP/IP connection, enabling read termination character";
            status = viSetAttribute(session, VI_ATTR_TERMCHAR_EN, VI_TRUE);
            res = keysight::verify_vi_status(session, status, "enabled read termination character",
                                             "There was a problem setting the attributes termination character name, error code: ");

            status = viSetAttribute(session, VI_ATTR_TMO_VALUE, 2000);
            res = keysight::verify_vi_status(session, status, "timeout", "There was a problem setting the attributes timeout, error code: ");
            return res;
        } else
            return true;  // success
    } else
        return false;  // we failed
#else
    return true;
#endif
}

bool Keysight::reset() {
    LOG_OUT << "attempting to reset state";

#ifndef SOFTWARE_ONLY
    bool res;

    auto status = viPrintf(session, "CELL:ABORT 0\n");  // sending identification query command
    res = keysight::verify_vi_status(session, status, "aborting any cells", "There was a problem aborting cells, error code: ");

    if (res) {
        status = viPrintf(session, "CELL:CLEAR 0\n");  // sending identification query command
        res = keysight::verify_vi_status(session, status, "clearing cells", "There was a problem clearing cells, error code: ");
        if (res) {
            status = viPrintf(session, "SEQ:CLEAR 0\n");  // sending identification query command
            res = keysight::verify_vi_status(session, status, "clearing sequences", "There was a problem clearing any sequences, error code: ");
        }
    }

    return res;
#endif

    return true;
}

bool Keysight::identification_query() {
    LOG_OUT << "sending the identification query command";

#ifndef SOFTWARE_ONLY
    bool res;

    auto status = viPrintf(session, "*IDN?\n");  // sending identification query command
    res = keysight::verify_vi_status(session, status, "sent id query command", "There was a problem sending the id queury, error code: ");

    if (res) {
        // getting the response from the identification query
        ViChar idn_response[65535];
        status = viScanf(session, "%t", idn_response);
        res =
            keysight::verify_vi_status(session, status, "read id query response", "There was a problem reading the id queury response, error code: ");

        if (res) {
            LOG_OUT << "identification query response: " << idn_response;

            return res;
        } else {
            LOG_ERR << "unable to retrieve identification query response";
            return false;
        }
    } else {
        LOG_ERR << "unabled to send identification query command " << status;
        return false;
    }
#else
    return true;
#endif
}

std::vector<std::string> Keysight::comma_delimiter(std::string x) {
    std::string s = x;
    std::string delimiter = ",";
    std::size_t pos = 0;
    std::string token;

    std::vector<std::string> result;

    while ((pos = s.find(delimiter)) != std::string::npos) {
        token = s.substr(0, pos);
        result.push_back(token);
        s.erase(0, pos + delimiter.length());
    }

    result.push_back(s);

    return result;
}

bool Keysight::detect_cards_at_boot() {
    LOG_OUT << "sending the detect cards command";

#ifndef SOFTWARE_ONLY
    std::vector<std::uint8_t> result;

    auto status = viPrintf(session, "SYST:CARD:DET:BOOT? 0\n");  // sending the detect all cards command
    auto res =
        keysight::verify_vi_status(session, status, "detect system cards at boot", "There was a problem detecting the system cards, error code: ");

    if (res) {
        // getting the response for the card detection query
        ViChar cards_detected[65535];
        status = viScanf(session, "%t", cards_detected);
        res =
            keysight::verify_vi_status(session, status, "reading system cards at boot", "There was a problem reading the system cards, error code: ");

        if (res) {
            LOG_OUT << "cards detected: " << cards_detected;

            std::string s = std::string(cards_detected);
            auto s_vec = comma_delimiter(s);

            for (auto i : s_vec) {
                LOG_OUT << "stoi-ing" << i;
                result.push_back(std::stoi(i));
            }

            if (result.size() == 1) {
                // if result is same number across the board we need to initialize the entire vector
                bool val = result.at(0);
                result = std::vector<std::uint8_t>(8, val);
                LOG_OUT << "all cards were same value: " << static_cast<int>(val);
            } else if (result.size() != 8) {
                // if we get an invalid result size, just say all the cards are off to be safe
                result = std::vector<std::uint8_t>(8, false);
                LOG_ERR << "cards returned an invalid size: " << result.size() << ", marking all cards off";
            } else {
                LOG_OUT << "successfully detected all the cards";
            }
        } else
            return false;
    } else
        return false;

    active_cards = result;
#else
    active_cards = {true, true, true, false, false, false, false, false};
#endif
    active_cards_callback(active_cards);
    return true;
}

bool Keysight::define_cells_for_all_cards() {
    std::string s1 = "CELL:DEFINE ";
    std::string s2 = "0";
    std::string s3 = ",(@";
    std::string s4 = "";
    std::string s5 = ")\n";

    std::vector<std::string> result;

    for (auto i = 0; i < active_cards.size(); i++) {
        if (static_cast<bool>(active_cards.at(i))) {
            // card is active if we make it here
            for (auto k = 0; k < 32; k++) {
                auto mod_nbr = std::to_string(i + 1);
                auto card_nbr = std::to_string(k + 1);

                s2 = ((k + 1) < 10) ? "00" : "0";
                s4 = ((k + 1) < 10) ? "0" : "";

                auto s = s1 + mod_nbr + s2 + card_nbr + s3 + mod_nbr + s4 + card_nbr + s5;
                auto sx = mod_nbr + s2 + card_nbr;
                LOG_OUT << "command: " << s;
                LOG_OUT << "cell number: " << sx;
#ifndef SOFTWARE_ONLY
                auto status = viPrintf(session, s.c_str());
                auto res =
                    keysight::verify_vi_status(session, status, "defining cell number", "There was a problem defining a cell number, error code: ");
                if (res)
                    result.push_back(sx);
                else {
                    LOG_ERR << "error defining cell number: " << s.c_str();
                    return false;
                }
#else
                result.push_back(sx);
#endif
            }
        }
    }

    cell_names = result;
    return true;
}

void Keysight::start_polling_cell_status() {
    cell_status_timer.expires_after(std::chrono::seconds(1));
    cell_status_timer.async_wait([&](const boost::system::error_code &error) {
        if (error == boost::asio::error::operation_aborted) {
            LOG_OUT << "cell status timer was cancelled";  // this isn't necessarily an error
        } else if (error) {
            LOG_ERR << "timer encountered error: " << error.message();
            disconnect();
        } else {
            // LOG_OUT << "getting cell status";
            if (get_cell_status()) {
                start_polling_cell_status();
            } else {
                LOG_ERR << "error getting the cell status";
                disconnect();
            }
        }
    });
}

bool Keysight::get_cell_status() {
    for (auto i = 0; i < active_cards.size(); i++) {
        auto active = active_cards.at(i);

        if (active) {
            auto res = get_cap_ahr(i);
            if (!res) return false;

            res = get_cap_whr(i);
            if (!res) return false;

            last_valid_verbose_response.clear();

            res = get_cell_verbose(i);
            if (!res) return false;

            std::vector<std::uint16_t> sequences;
            std::vector<std::uint16_t> steps;
            std::vector<double> volts;
            std::vector<double> current;
            std::vector<std::uint16_t> states;
            std::vector<std::uint16_t> statuses;
            for (auto k = 0; k < last_valid_verbose_response.size(); k++) {
                auto x = last_valid_verbose_response.at(k);
                if (x.size() == 10) {
                    // 0 = state
                    // 1 = sequence id
                    // 2 = step id
                    // 3 = volts
                    // 4 = amps
                    // 5 = cellStat
                    // TODO 6 = testId
                    // TODO 7 = testType
                    // TODO 8 = expLim
                    // TODO 9 = meadLim
                    if (x.at(0).compare("RUNNING") == 0)
                        states.push_back(2);
                    else
                        states.push_back(1);

                    if (x.at(5).compare("NEXT") == 0) {
                        statuses.push_back(5);
                    } else if (x.at(5).compare("ABORTED") == 0) {
                        statuses.push_back(4);
                    } else if (x.at(5).compare("FAIL") == 0) {
                        statuses.push_back(3);
                    } else if (x.at(5).compare("OK") == 0) {
                        statuses.push_back(2);
                    } else {
                        statuses.push_back(1);
                    }

                    sequences.push_back(std::stoi(x.at(1)));
                    steps.push_back(std::stoi(x.at(2)));
                    volts.push_back(std::stod(x.at(3)));
                    current.push_back(std::stod(x.at(4)));
                    auto cell = ((i + 1) * 1000) + (k + 1);
                    if (logging_map.find(cell) != logging_map.end()) {
                        // we have an open file
                        auto slot = logging_map.at(cell);

                        // TODO some bounds checking
                        auto cap_ahr = cell_cap_ahr_data.at(i).at(k);
                        auto cap_whr = cell_cap_whr_data.at(i).at(k);

                        log_data(cell, slot, volts.back(), current.back(), cap_ahr, cap_whr);
                    }
                } else {
                    LOG_ERR << "invalid response size";
                    return false;
                }
            }

            cell_sequence_id_data[i] = sequences;
            cell_step_id_data[i] = steps;
            cell_voltage_data[i] = volts;
            cell_current_data[i] = current;
            cell_run_state_data[i] = states;
            cell_run_status_data[i] = statuses;
        }
    }

    port_double_callback(PortTypes::port_double_data_type::CAP_AHR, cell_cap_ahr_data);
    port_double_callback(PortTypes::port_double_data_type::CAP_WHR, cell_cap_whr_data);
    port_double_callback(PortTypes::port_double_data_type::VOLTAGE, cell_voltage_data);
    port_double_callback(PortTypes::port_double_data_type::CURRENT, cell_current_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::SEQUENCE, cell_sequence_id_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::STEP, cell_step_id_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::STATES, cell_run_state_data);
    port_uint16_callback(PortTypes::port_uint16_data_type::STATUSES, cell_run_status_data);

    auto res = get_cells_running_uptime();
    if (!res) {
        return res;
    } else {
        res = check_cells_sequence_rollover_and_failures();
        if (!res) return res;
    }

    cycles_status_callback(cycles_count);

    return true;
}

bool Keysight::get_cap_ahr(int card_number) {
#ifndef SOFTWARE_ONLY
    ViChar cap_ahr[65535];

    auto s1 = "MEAS:CELL:CAP:AHR? (@";
    auto s2 = std::to_string(card_number + 1);
    auto s3 = "001:";
    auto s4 = s2;
    auto s5 = "032)\n";
    auto s = s1 + s2 + s3 + s4 + s5;

    auto status = viPrintf(session, s.c_str());
    auto res =
        keysight::verify_vi_status(session, status, "retrieving capacity ahr", "There was a problem sending capacity ahr command, error code: ");

    if (res) {
        status = viScanf(session, "%t", cap_ahr);
        res = keysight::verify_vi_status(session, status, "getting capacity ahr", "There was a problem getting capacity ahr command, error code: ");
        if (res) {
            status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
            if (res) {
                // LOG_OUT << "got cap ahr status: " << cap_ahr;
                std::string s = std::string(cap_ahr);
                auto s_vec = comma_delimiter(s);

                std::vector<double> result;
                for (auto i : s_vec) {
                    result.push_back(std::stod(i));
                }
                cell_cap_ahr_data[card_number] = result;
            } else {
                LOG_ERR << "error flushing buffer";
                return false;
            }
        } else {
            LOG_ERR << "error getting cap ahr data";
            return false;
        }
    } else {
        LOG_ERR << "error sending cap ahr command";
        return false;
    }

    return true;
#else
    std::vector<double> cell_cap_ahr = {0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    cell_cap_ahr_data[0] = cell_cap_ahr;
    cell_cap_ahr_data[1] = cell_cap_ahr;
    cell_cap_ahr_data[2] = cell_cap_ahr;
    port_double_callback(PortTypes::port_double_data_type::CAP_AHR, cell_cap_ahr_data);
    return true;
#endif
}

std::vector<int> Keysight::get_catalog() {
    std::string s = "SEQ:CAT?\n";
    ViChar catalog[65535];
    auto status = viPrintf(session, s.c_str());
    auto res = keysight::verify_vi_status(session, status, "get catalog", "There was a problem sending get catalog command, error code: ");

    std::vector<int> result;

    if (res) {
        status = viScanf(session, "%t", catalog);
        res = keysight::verify_vi_status(session, status, "get catalog", "There was a problem getting catalog, error code: ");
        if (res) {
            status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");

            LOG_OUT << "get_catalog: " << catalog;
            auto values = comma_delimiter(catalog);

            for (const auto &i : values) {
                try {
                    auto val = std::stoi(i) - 1;
                    result.push_back(val);
                } catch (...) {
                    // do nothing
                }
            }
        } else {
            disconnect();
        }
    } else {
        disconnect();
    }

    return result;
}

bool Keysight::get_cap_whr(int card_number) {
#ifndef SOFTWARE_ONLY
    ViChar cap_whr[65535];

    // TODO this is hardcoded, don't do that
    auto s1 = "MEAS:CELL:CAP:WHR? (@";
    auto s2 = std::to_string(card_number + 1);
    auto s3 = "001:";
    auto s4 = s2;
    auto s5 = "032)\n";
    auto s = s1 + s2 + s3 + s4 + s5;

    // auto status = viPrintf(session, "MEAS:CELL:CAP:WHR? (@1001:3032)\n");
    auto status = viPrintf(session, s.c_str());
    auto res =
        keysight::verify_vi_status(session, status, "retrieving capacity whr", "There was a problem sending capacity whr command, error code: ");

    if (res) {
        status = viScanf(session, "%t", cap_whr);
        res = keysight::verify_vi_status(session, status, "getting capacity whr", "There was a problem getting capacity whr command, error code: ");
        if (res) {
            status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
            if (res) {
                // LOG_OUT << "got cap whr status: " << cap_whr;
                std::string s = std::string(cap_whr);
                auto s_vec = comma_delimiter(s);

                std::vector<double> result;
                for (auto i : s_vec) {
                    result.push_back(std::stod(i));
                }
                cell_cap_whr_data[card_number] = result;
            } else {
                LOG_ERR << "error flushing buffer";
                return false;
            }
        } else {
            LOG_ERR << "error getting cap whr data";
            return false;
        }
    } else {
        LOG_ERR << "error sending cap whr command";
        return false;
    }

    return true;
#else
    std::vector<double> cell_cap_whr = {34.0, 1.0,  42.0, 33.0, 44.0, 5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    cell_cap_whr_data[0] = cell_cap_whr;
    cell_cap_whr_data[1] = cell_cap_whr;
    cell_cap_whr_data[2] = cell_cap_whr;
    port_double_callback(PortTypes::port_double_data_type::CAP_WHR, cell_cap_whr_data);
    return true;
#endif
}

bool Keysight::get_cell_verbose(int card_number) {
#ifndef SOFTWARE_ONLY
    for (auto k = 1; k < 33; k++) {
        std::string s1 = "STAT:CELL:VERB? ";
        std::string s2 = std::to_string(card_number + 1);
        std::string s3 = (k < 10) ? "00" : "0";
        std::string s4 = std::to_string(k);
        std::string s5 = "\n";
        std::string s = s1 + s2 + s3 + s4 + s5;

        // LOG_OUT << "sending: " << s;

        ViChar verb[65535];
        auto status = viPrintf(session, s.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending cell verbose", "There was a problem sending the cell verbose command");

        if (res) {
            status = viScanf(session, "%t", verb);
            res = keysight::verify_vi_status(session, status, "getting cell verbose", "There was a problem reading the cell verbose response");
            if (res) {
                status = viFlush(session, VI_READ_BUF);
                res = keysight::verify_vi_status(session, status, "flushing buffer", "There was a problem flushing the buffer");
                if (!res) return false;
            } else
                return false;
        } else
            return false;

        auto vec = comma_delimiter(verb);
        if (vec.size() == 10) {
            // LOG_OUT << "got cell verbose: " << verb;
            last_valid_verbose_response.push_back(vec);
        } else {
            LOG_ERR << "received invalid verb response size: " << vec.size();
            return false;
        }
    }

    return true;
#else
    std::vector<double> cell_voltage = {12.0, 1.0,  42.0, 33.0, 44.0, 5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};
    std::vector<double> cell_current = {12.0, 1.0,  42.0, 33.0, 44.0, 5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};
    std::vector<std::uint16_t> cell_sequence = {12, 1,  42, 33, 44, 5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15,
                                                16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
    std::vector<std::uint16_t> cell_step = {3,  2,  12, 33, 44, 5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15,
                                            16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
    std::vector<std::uint16_t> cell_state = {0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1};
    std::vector<std::uint16_t> cell_status = {0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1};

    cell_voltage_data[0] = cell_voltage;
    cell_voltage_data[1] = cell_voltage;
    cell_voltage_data[2] = cell_voltage;
    port_double_callback(PortTypes::port_double_data_type::VOLTAGE, cell_voltage_data);

    cell_current_data[0] = cell_current;
    cell_current_data[1] = cell_current;
    cell_current_data[2] = cell_current;
    port_double_callback(PortTypes::port_double_data_type::CURRENT, cell_current_data);

    cell_sequence_id_data[0] = cell_sequence;
    cell_sequence_id_data[1] = cell_sequence;
    cell_sequence_id_data[2] = cell_sequence;
    port_uint16_callback(PortTypes::port_uint16_data_type::SEQUENCE, cell_sequence_id_data);

    cell_step_id_data[0] = cell_step;
    cell_step_id_data[1] = cell_step;
    cell_step_id_data[2] = cell_step;
    port_uint16_callback(PortTypes::port_uint16_data_type::STEP, cell_step_id_data);

    cell_run_state_data[0] = cell_state;
    cell_run_state_data[0] = cell_state;
    cell_run_state_data[0] = cell_state;
    port_uint16_callback(PortTypes::port_uint16_data_type::STATES, cell_run_state_data);

    cell_run_status_data[0] = cell_status;
    cell_run_status_data[0] = cell_status;
    cell_run_status_data[0] = cell_status;
    port_uint16_callback(PortTypes::port_uint16_data_type::STATUSES, cell_run_status_data);
    return true;
#endif
}

std::string Keysight::get_mode(int value) {
    switch (value) {
        case 1:
            return "CHARGE";
        case 2:
            return "DISCHARGE";
        default:
            return "REST";
    }
}

std::string Keysight::get_time_type(int value) {
    switch (value) {
        case 1:
            return "AFTER";
        case 2:
            return "BEFORE";
        case 3:
            return "BEFORE_START";
        default:
            return "AT";
    }
}

std::string Keysight::get_test_action(int value) {
    switch (value) {
        case 1:
            return "NEXT";
        default:
            return "FAIL";
    }
}

std::string Keysight::get_test_type(int value) {
    switch (value) {
        case 0:
            return "VOLT_GE";
        case 1:
            return "VOLT_LE";
        case 2:
            return "CURR_GE";
        case 3:
            return "CURR_LE";
        case 4:
            return "POWER_GE";
        case 5:
            return "POWER_LE";
        case 6:
            return "AMPH_GE";
        case 7:
            return "AMPH_LE";
        case 8:
            return "WATTH_GE";
        case 9:
            return "WATTH_LE";
        case 10:
            return "POS_DVDT_GE";
        case 11:
            return "POS_DVDT_LE";
        case 12:
            return "NEG_DVDT_GE";
        case 13:
            return "NEG_DVDT_LE";
        case 14:
            return "POS_DIDT_GE";
        case 15:
            return "POS_DIDT_LE";
        case 16:
            return "NEG_DIDT_GE";
        case 17:
            return "NEG_DIDT_LE";
        case 18:
            return "DVMAX_GE";
        case 19:
            return "DVMAX_LE";
        case 20:
            return "DVMIN_GE";
        case 21:
            return "DVMIN_LE";
        case 22:
            return "DIMAX_GE";
        case 23:
            return "DIMAX_LE";
        case 24:
            return "DIMIN_GE";
        case 25:
            return "DIMIN_LE";
        default:
            return "NONE";
    }
}

void Keysight::start_logging(std::vector<std::uint32_t> cells) {
    // TODO this is not the right way to log files
    std::ofstream csv_file;
    auto c = new std::ofstream;
    logging_files.push_back(c);
    logging_files.back()->open("test.csv", std::ios::out | std::ios::app);
    *logging_files.back() << "Cell Number, Voltage (V), Current (A), Capacity (aH), Capacity (Wh), Timestamp\n";
    logging_files.back()->flush();

    for (const auto &i : cells) {
        logging_map[i] = logging_files.size() - 1;
    }
}

void Keysight::stop_logging(std::vector<std::uint32_t> cells) {
    // TODO this is not the right way to stop logging files
    // close all the files and delete all the file pointers
    for (auto i : logging_files) {
        if (i) {
            i->close();
            delete i;
        }
    }

    logging_files.clear();
    logging_map.clear();
}

void Keysight::log_data(std::uint32_t cell, std::uint32_t slot, double volts, double current, double cap_ahr, double cap_whr) {
    LOG_OUT << "log data called on: " << cell << ", slot: " << slot;

    std::time_t time = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    // TODO some bounds checking
    auto s1 = std::to_string(cell) + ", ";
    auto s2 = std::to_string(volts) + ", ";
    auto s3 = std::to_string(current) + ", ";
    auto s4 = std::to_string(cap_ahr) + ", ";
    auto s5 = std::to_string(cap_whr) + ",";
    auto s6 = std::string(std::ctime(&time));
    auto s = s1 + s2 + s3 + s4 + s5 + s6;

    *logging_files.at(slot) << s;
    logging_files.at(slot)->flush();
}

bool Keysight::check_cells_sequence_rollover_and_failures() {
    LOG_OUT << "checking cells seq rollover";
    for (const auto &i : cells_being_run_map) {
        std::string s1 = "(@";
        for (auto k = 0; k < i.second.size(); k++) {
            s1 += std::to_string(i.second.at(k));
            if (k != i.second.size() - 1) s1 += ",";
        }

        std::string report = "STAT:CELL:REP? " + s1 + ")\n";
        LOG_OUT << "getting report: " << report;

#ifndef SOFTWARE_ONLY
        auto status = viPrintf(session, report.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending report query", "There was a problem sendfing report error code: ");

        if (res) {
            ViChar report_res[65535];
            status = viScanf(session, "%t", report_res);
            res = keysight::verify_vi_status(session, status, "getting cell report", "There was a problem getting cell report error code: ");
            LOG_OUT << "report: " << report_res;
            if (res) {
                status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
                res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
                if (res) {
                    auto cell_rep = comma_delimiter(report_res);

                    // check if they are all "OK"
                    bool cell_rep_finished = true;
                    for (auto t : cell_rep) {
                        t.erase(std::remove_if(t.begin(), t.end(), ::isspace), t.end());
                        if (t.compare("4") != 0) {
                            LOG_OUT << "didnt match: " << t;
                            cell_rep_finished = false;
                            break;
                        }
                    }

                    LOG_OUT << "cell rep finished: " << cell_rep_finished;

                    if (cell_rep_finished && (successively_slots.at(i.first) == true)) {
                        if (cells_being_run_map.find(i.first) != cells_being_run_map.end() &&
                            cells_slots_being_run_map.find(i.first) != cells_slots_being_run_map.end()) {
                            auto c = cells_being_run_map.at(i.first);
                            auto slot = cells_slots_being_run_map.at(i.first);
                            total_seq_uptime_offset[i.first] += current_seq_uptime[i.first];
                            start_sequence(i.first, slot, c, true);
                            cycles_count[i.first]++;
                        }
                    }

                } else
                    return false;
            } else {
                return false;
            }
        } else {
            return false;
        }
#endif
    }
    return true;
}

bool Keysight::get_cells_running_uptime() {
    for (const auto &i : cells_being_run_map) {
        std::string s1 = "(@";
        for (auto k = 0; k < i.second.size(); k++) {
            s1 += std::to_string(i.second.at(k));
            if (k != i.second.size() - 1) s1 += ",";
        }

        std::string time = "CELL:TIME? " + s1 + ")\n";
        LOG_OUT << "getting uptime: " << time;

#ifndef SOFTWARE_ONLY
        auto status = viPrintf(session, time.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending cell time", "There was a problem sendfing cell time error code: ");

        if (res) {
            ViChar time_res[65535];
            status = viScanf(session, "%t", time_res);
            res = keysight::verify_vi_status(session, status, "getting cell time", "There was a problem getting cell time error code: ");
            LOG_OUT << "uptime: " << time_res;
            if (res) {
                status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
                res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
                if (res) {
                    auto times = comma_delimiter(time_res);
                    double greatest_time = 0.0;
                    for (const auto &t : times) {
                        double current_time = std::stod(t);
                        if (current_time > greatest_time) greatest_time = current_time;
                    }
                    current_seq_uptime[i.first] = greatest_time;
                    total_seq_uptime[i.first] = greatest_time + total_seq_uptime_offset[i.first];

                } else
                    return false;
            } else {
                return false;
            }
        } else {
            return false;
        }

#endif
    }
    time_status_callback(current_seq_uptime);
    total_time_callback(total_seq_uptime);
    return true;
}

void Keysight::start_sequence(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells, bool successively) {
    std::string s1 = "(@";

    for (auto i = 0; i < cells.size(); i++) {
        s1 += std::to_string(cells.at(i));
        if (i != cells.size() - 1) s1 += ",";
    }

    std::string enab = "CELL:ENABLE " + s1 + ")," + std::to_string(slot + 1) + "\n";
    std::string init = "CELL:INIT " + s1 + ")\n";

    LOG_OUT << "enabled cells: " << enab;
    LOG_OUT << "init cells: " << init;

    if (test < slot_status.size()) {
        slot_status[test] = 2;
        successively_slots[test] = successively;
        slot_status_callback(slot_status);
    }

#ifndef SOFTWARE_ONLY
    auto status = viPrintf(session, enab.c_str());
    auto res = keysight::verify_vi_status(session, status, "sending enab", "There was a problem enabling cells error code: ");

    if (!res) {
        disconnect();
        return;
    }

    status = viPrintf(session, init.c_str());
    res = keysight::verify_vi_status(session, status, "sending enab", "There was a problem enabling cells error code: ");

    if (!res) {
        disconnect();
        return;
    }
#endif

    start_logging(cells);
    cells_being_run_map[test] = cells;
    cells_slots_being_run_map[test] = slot;
}

void Keysight::stop_sequence(std::uint32_t test, std::uint32_t slot, std::vector<std::uint32_t> cells) {
    std::string s1 = "(@";

    for (auto i = 0; i < cells.size(); i++) {
        s1 += std::to_string(cells.at(i));
        if (i != cells.size() - 1) s1 += ",";
    }

    std::string abort = "CELL:ABORT " + s1 + ")\n";
    LOG_OUT << "sending command: " << abort;

    if (test < slot_status.size()) {
        slot_status[test] = 0;
        successively_slots[test] = false;
        slot_status_callback(slot_status);
    }

#ifndef SOFTWARE_ONLY
    auto status = viPrintf(session, abort.c_str());
    auto res = keysight::verify_vi_status(session, status, "sending enab", "There was a problem enabling cells error code: ");

    if (!res) {
        disconnect();
        return;
    }
#endif

    stop_logging(cells);

    if (cells_being_run_map.find(test) != cells_being_run_map.end()) {
        cells_being_run_map.erase(test);
    }

    if (cells_slots_being_run_map.find(test) != cells_slots_being_run_map.end()) {
        cells_slots_being_run_map.erase(test);
    }
}

void Keysight::load_sequence(std::string name, int slot, sequence_step_vector steps, sequence_test_map tests) {
    if (slot < currently_loaded_profiles.size()) {
        currently_loaded_profiles[slot] = name;
        loaded_profiles_callback(currently_loaded_profiles);

#ifdef SOFTWARE_ONLY

        current_profile_statuses[slot] = 1;
        if (slot > 3) current_profile_statuses[slot] = 2;
        profile_status_callback(current_profile_statuses);
#endif
        auto clear_str = "SEQ:CLE " + std::to_string(slot + 1) + "\n";
        auto status = viPrintf(session, clear_str.c_str());
        auto res = keysight::verify_vi_status(session, status, "sending sequence clear", "There was a problem cearing sequence: ");
        if (!res) {
            disconnect();
            return;
        }

        for (auto i = 0; i < steps.size(); i++) {
            auto step = steps.at(i);
            auto mode_value = step.at(SequenceTypes::sequence_step_access_type::MODE);

            auto seq_id = slot + 1;  // 1 indexed
            auto step_id = i + 1;
            auto mode = get_mode(mode_value);
            auto duration = static_cast<int>(step.at(SequenceTypes::sequence_step_access_type::SECONDS));
            auto current = step.at(SequenceTypes::sequence_step_access_type::CURRENT);
            auto voltage = step.at(SequenceTypes::sequence_step_access_type::VOLTAGE);

            std::string s1 = "SEQ:STEP:DEF ";
            std::string s2 = std::to_string(seq_id) + ",";
            std::string s3 = std::to_string(step_id) + ",";
            std::string s4 = mode + ",";
            std::string s5 = std::to_string(duration) + ",";
            std::string s6 = std::to_string(current) + ",";
            std::string s7 = std::to_string(voltage) + "\n";

            auto s = s1 + s2 + s3 + s4 + s5 + s6 + s7;

            LOG_OUT << "step command: " << s;
#ifndef SOFTWARE_ONLY

            // LOG_OUT << "clear command: " << clear_str;
            //
            //

            status = viPrintf(session, s.c_str());
            res = keysight::verify_vi_status(session, status, "sending step", "There was a problem sending step error code: ");

            if (!res) {
                disconnect();
                return;
            }
#endif
        }

        for (const auto &i : tests) {
            auto test_vec = i.second;

            for (auto k = 0; k < test_vec.size(); k++) {
                auto test = test_vec.at(k);
                auto test_type_value = test.at(SequenceTypes::sequence_test_access_type::TEST_TYPE);
                auto time_type_value = test.at(SequenceTypes::sequence_test_access_type::TIME_TYPE);
                auto test_action_value = test.at(SequenceTypes::sequence_test_access_type::TEST_ACTION);

                auto seq_id = slot + 1;
                auto step_id = i.first + 1;
                auto test_id = k + 1;
                auto test_type = get_test_type(test_type_value);
                auto value = test.at(SequenceTypes::sequence_test_access_type::VALUE);
                auto time_type = get_time_type(time_type_value);
                auto time_limit = test.at(SequenceTypes::sequence_test_access_type::TIME_LIMIT);
                auto test_action = get_test_action(test_action_value);

                std::string s1 = "SEQ:TEST:DEF ";
                std::string s2 = std::to_string(seq_id) + ",";
                std::string s3 = std::to_string(step_id) + ",";
                std::string s4 = std::to_string(test_id) + ",";
                std::string s5 = test_type + ",";
                std::string s6 = std::to_string(value) + ",";
                std::string s7 = time_type + ",";
                std::string s8 = std::to_string(time_limit) + ",";
                std::string s9 = test_action + "\n";

                auto s = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9;

                LOG_OUT << "test command: " << s;
#ifndef SOFTWARE_ONLY
                auto status = viPrintf(session, s.c_str());
                auto res = keysight::verify_vi_status(session, status, "sending step", "There was a problem sending step error code: ");

                if (!res) {
                    disconnect();
                    return;
                }
#endif
            }
        }

#ifndef SOFTWARE_ONLY
        auto catalog = get_catalog();
        for (const auto &i : catalog) {
            if (i == slot) {
                current_profile_statuses[slot] = 2;
                profile_status_callback(current_profile_statuses);
                return;
            }
        }

        current_profile_statuses[slot] = 1;
        profile_status_callback(current_profile_statuses);
#endif
    }
}

//
/*
    // sequence example

    // clear any initial setups
    cell_commands->abort(session, "0");

    // define four parallel channels
    cell_commands->define(session, "1025", "125");
    cell_commands->define(session, "1026", "126");
    cell_commands->define(session, "1027", "127");
    cell_commands->define(session, "1028", "128");
    cell_commands->define(session, "1029", "129");

    // define a small sequence
    sequence_commands->step_define(session, "1", "1", "REST", "30");

    // assign the cells to run sequence 1
    cell_commands->enable(session, "(@1025,1026)", "1");

    cell_commands->initiate(session, "(@1025,1026)");

    std::this_thread::sleep_for(std::chrono::seconds(2));
    viPrintf(session, "CELL:STEP:TIME? (@1025,1026)\n");
    ViChar step_time_response[65535];
    viScanf(session, "%t", step_time_response);
    std::cout << "step time: " << step_time_response << std::endl;*/

// sequence example
/*viPrintf(session, "CELL:ABORT 0\n");
viPrintf(session, "CELL:CLEAR 0\n");
viPrintf(session, "SEQ:CLEAR 0\n");

viPrintf(session, "CELL:DEFINE 1025,(@125)\n");
viPrintf(session, "CELL:DEFINE 1026,(@126)\n");
viPrintf(session, "CELL:DEFINE 1027,(@127)\n");
viPrintf(session, "CELL:DEFINE 1028,(@128)\n");

viPrintf(session, "SEQ:STEP:DEF 1, 1, REST, 300\n");
viPrintf(session, "SEQ:STEP:DEF 2, 1, REST, 30\n");

viPrintf(session, "CELL:ENABLE (@1025,1026),1\n");
viPrintf(session, "CELL:ENABLE (@1027,1028),2\n");

ViChar enab_response[65535];
viScanf(session, "%t", enab_response);
std::cout << "response: " << enab_response << std::endl;

viPrintf(session, "CELL:INITiate (@1025,1026)\n");

std::this_thread::sleep_for(std::chrono::seconds(10));
viPrintf(session, "CELL:INITiate (@1027,1028)\n");
ViChar step_time_response[65535];
viScanf(session, "%t", step_time_response);
std::cout << "response: " << step_time_response << std::endl;

viPrintf(session, "STAT:CELL:VERBose? 1025\n");
viScanf(session, "%t", step_time_response);

std::cout << "response: " << step_time_response << std::endl;
std::this_thread::sleep_for(std::chrono::seconds(10));
viPrintf(session, "CELL:STEP:TIME? (@1025,1026)\n");
viScanf(session, "%t", step_time_response);
std::cout << "response: " << step_time_response << std::endl;

viPrintf(session, "STAT:CELL:VERBose? 1027\n");
viScanf(session, "%t", step_time_response);

std::cout << "response: " << step_time_response << std::endl;

viPrintf(session, "CELL:STEP:TIME? (@1027,1028)\n");
viScanf(session, "%t", step_time_response);
std::cout << "response: " << step_time_response << std::endl;*/

// first step
// get the system cards detected
// cards detected
/*viPrintf(session, "SYST:CARD:DET:BOOT? 0\n");
ViChar cards_detected[65535];
viScanf(session, "%t", cards_detected);
std::cout << "cards detected: " << cards_detected << std::endl;*/

// second step
// get the status of the cells
/*for (auto i = 0; i < 33; i++) {
    ViChar cell_status[65535];
    viPrintf(session, ("STATUS:CELL:VERBOSE? 100" + std::to_string(i) + "\n").c_str());
    viScanf(session, "%t", cell_status);
    std::cout << "cell status: " << cell_status << std::endl;
}*/
/*
ViChar cards_status[65535];
viPrintf(session, "STAT:OPER:ENAB 16\n");
viPrintf(session, "STAT:CELL:REP? (@1001:1004)\n");
viScanf(session, "%t", cards_status);
std::cout << "cards status: " << cards_status << std::endl;*/
/*viPrintf(session, "CELL:DEFINE 1001,(@101)\n");
viPrintf(session, "CELL:DEFINE 1002,(@102)\n");
viPrintf(session, "CELL:DEFINE 1003,(@103)\n");
viPrintf(session, "CELL:DEFINE 1004,(@104)\n");*/

/*ViChar cell_voltage[65535];
viPrintf(session, "MEAS:CELL:VOLT? (@1001:1004)\n");
viScanf(session, "%t", cell_voltage);
std::cout << "cell voltage: " << cell_voltage << std::endl;

viPrintf(session, "MEAS:VOLT? (@101,102,103,104)\n");
viScanf(session, "%t", cell_voltage);
std::cout << "cell voltage: " << cell_voltage << std::endl;

ViChar cell_status[65535];
viPrintf(session, "STATUS:CELL:VERBOSE? 1001\n");
viScanf(session, "%t", cell_status);
std::cout << "cell status: " << cell_status << std::endl;*/