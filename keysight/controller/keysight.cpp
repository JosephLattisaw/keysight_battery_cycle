#include "keysight.hpp"

#include "common.hpp"
#include "logger.hpp"

#define LOG_OUT LogOut("keysight")
#define LOG_ERR LogOut("keysight")

namespace keysight {
extern ViSession resource_manager;
extern ViSession session;

}  // namespace keysight

using namespace keysight;

Keysight::Keysight(boost::asio::io_service &io_service, ActiveCardsCallback ac_cb, CapAhrDataCallback cahr_cb, CapWhrDataCallback cawh_cb)
    : io_service(io_service),
      cell_status_timer(io_service),
      active_cards_callback{ac_cb},
      cap_ahr_data_callback{cahr_cb},
      cap_whr_data_callback{cawh_cb} {}

Keysight::~Keysight() { disconnect(); }

void Keysight::connect() {
    // opening the Keysight BT2203A
    if (open_resource_manager()) {
        if (open_instrument()) {
            if (enable_read_termination_character()) {
                if (identification_query()) {
                    LOG_OUT << "identified " << VISA_ADDRESS_BT2203A;
                    if (detect_cards_at_boot()) {
                        LOG_OUT << "successfully detected all cards at boot";
                        if (define_cells_for_all_cards()) {
                            LOG_OUT << "successfully set all cell names";
                            start_polling_cell_status();
                        } else {
                            LOG_ERR << "failed to set all active cells";
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
}

void Keysight::disconnect() {
    viUnlock(session);
    viClose(session);
    viClose(resource_manager);

    keysight::resource_manager = 0;
    keysight::session = 0;

    active_cards.clear();
    cell_names.clear();
    cell_cap_ahr_data.clear();
    cell_cap_whr_data.clear();

    cell_status_timer.cancel();
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
            return res;
        } else
            return true;  // success
    } else
        return false;  // we failed
#else
    return true;
#endif
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

bool Keysight::detect_cards_at_boot() {
    LOG_OUT << "sending the detect cards command";

#ifndef SOFTWARE_ONLY
    std::vector<int> result;

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
            std::string delimiter = ",";

            std::size_t pos = 0;
            std::string token;

            std::size_t expected_size = 7;

            while ((pos = s.find(delimiter)) != std::string::npos) {
                token = s.substr(0, pos);
                result.push_back(static_cast<bool>(std::stoi(token)));
                s.erase(0, pos + delimiter.length());
            }

            result.push_back(std::stoi(s));

            if (result.size() == 1) {
                // if result is same number across the board we need to initialize the entire vector
                bool val = result.at(0);
                result = std::vector<int>(8, val);
                LOG_OUT << "all cards were same value: " << static_cast<int>(val);
            } else if (result.size() != 8) {
                // if we get an invalid result size, just say all the cards are off to be safe
                result = std::vector<int>(8, false);
                LOG_ERR << "cards returned an invalid size: " << result.size() << ", marking all cards off";
            } else {
                LOG_OUT << "successfully detected all the cards";
            }
        } else
            return false;
    } else
        return false;

    active_cards = result;
    return true;
#else
    active_cards = {true, true, true, false, false, false, false, false};
    return true;
#endif
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
            LOG_OUT << "getting cell status";
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
    auto res = get_cap_ahr();

    if (res) {
        res = get_cap_whr();
        if (res) {
            res = get_cell_verbose();
            if (res) return true;
        }
    }

    return false;
}

bool Keysight::get_cap_ahr() {
#ifndef SOFTWARE_ONLY
    ViChar cap_ahr[65535];

    // TODO this is hardcoded, don't do that
    auto status = viPrintf(session, "MEAS:CELL:CAP:AHR? (@1001:3032)\n");
    auto res =
        keysight::verify_vi_status(session, status, "retrieving capacity ahr", "There was a problem sending capacity ahr command, error code: ");

    if (res) {
        status = viScanf(session, "%t", cap_ahr);
        res = keysight::verify_vi_status(session, status, "getting capacity ahr", "There was a problem getting capacity ahr command, error code: ");
        if (res) {
            status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
            if (res) {
                // TODO
                LOG_OUT << "got cap ahr status";
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
    return true;
#endif
}

bool Keysight::get_cap_whr() {
#ifndef SOFTWARE_ONLY
    ViChar cap_whr[65535];

    // TODO this is hardcoded, don't do that
    auto status = viPrintf(session, "MEAS:CELL:CAP:WHR? (@1001:3032)\n");
    auto res =
        keysight::verify_vi_status(session, status, "retrieving capacity whr", "There was a problem sending capacity whr command, error code: ");

    if (res) {
        status = viScanf(session, "%t", cap_whr);
        res = keysight::verify_vi_status(session, status, "getting capacity whr", "There was a problem getting capacity whr command, error code: ");
        if (res) {
            status = viFlush(session, VI_READ_BUF);  // discards any read buf so next scan is fine
            res = keysight::verify_vi_status(session, status, "flusing keysight buffer", "There was a problem flushing the keysight buffer");
            if (res) {
                // TODO
                LOG_OUT << "got cap whr status";
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
    std::vector<double> cell_cap_whr = {0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
                                        16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.1};

    cell_cap_ahr_data[0] = cell_cap_whr;
    cell_cap_ahr_data[1] = cell_cap_whr;
    cell_cap_ahr_data[2] = cell_cap_whr;

    return true;
#endif
}

bool Keysight::get_cell_verbose() {
#ifndef SOFTWARE_ONLY
    for (auto i = 1; i < 4; i++) {
        for (auto k = 1; k < 33; k++) {
            std::string s1 = "STAT:CELL:VERB? ";
            std::string s2 = std::to_string(i);
            std::string s3 = (k < 10) ? "00" : "0";
            std::string s4 = std::to_string(k);
            std::string s5 = "\n";
            std::string s = s1 + s2 + s3 + s4 + s5;

            ViChar verb[65535];
            auto status = viPrintf(session, s.c_str());
            auto res = keysight::verify_vi_status(session, status, "sending cell verbose", "There was a problem sending the cell verbose command");

            if (res) {
                status = viScanf(session, "%t", verb);
                res = keysight::verify_vi_status(session, status, "getting cell verbose", "There was a problem reading the cell verbose response");
                if (res) {
                    status = viFlush(session, 0x10);
                    res = keysight::verify_vi_status(session, status, "flushing buffer", "There was a problem flushing the buffer");
                    if (!res) return false;
                } else
                    return false;
            } else
                return false;
        }
    }

    return true;
#else
    return true;
#endif
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